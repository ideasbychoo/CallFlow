import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";

function checkAuth(req: NextRequest): boolean {
  const header = req.headers.get("authorization") ?? "";
  const token = header.replace(/^Bearer\s+/i, "");
  return Boolean(token) && token === process.env.CALLFLOW_INGEST_API_KEY;
}

function looksLikeUrl(value: string): boolean {
  return /^https?:\/\//i.test(value.trim());
}

async function findOrCreateLookup(
  supabase: ReturnType<typeof createAdminClient>,
  table: "categories" | "departments" | "seniority_levels" | "source_types",
  name: string | undefined | null
): Promise<string | null> {
  if (!name || !name.trim()) return null;
  const trimmed = name.trim();

  const { data: existing } = await supabase
    .from(table)
    .select("id")
    .ilike("name", trimmed)
    .maybeSingle();

  if (existing) return existing.id as string;

  const { data: maxRow } = await supabase
    .from(table)
    .select("sort_order")
    .order("sort_order", { ascending: false })
    .limit(1)
    .maybeSingle();

  const nextOrder = (maxRow?.sort_order ?? 0) + 1;

  const { data: created, error } = await supabase
    .from(table)
    .insert({ name: trimmed, sort_order: nextOrder })
    .select("id")
    .single();

  if (error) throw error;
  return created.id as string;
}

// Segments are a deliberately fixed, curated list (unlike categories/
// departments/seniority/source_types, which can grow freely). Ingest must
// only match an EXISTING segment by name -- never create a new one. If the
// name doesn't match anything, return null and surface a warning so the
// caller knows the segment wasn't recorded.
async function lookupSegmentStrict(
  supabase: ReturnType<typeof createAdminClient>,
  name: string | undefined | null
): Promise<{ id: string | null; warning: string | null }> {
  if (!name || !name.trim()) return { id: null, warning: null };
  const trimmed = name.trim();

  const { data: existing } = await supabase
    .from("segments")
    .select("id")
    .ilike("name", trimmed)
    .maybeSingle();

  if (existing) return { id: existing.id as string, warning: null };

  return {
    id: null,
    warning: `Segment "${trimmed}" doesn't match any existing Segment -- left blank. Segments are a fixed list; only reuse an existing one, don't invent a new one.`,
  };
}

// Sources CAN be created (a Source needs at least one Source Type, so if
// we're creating a new Source we need a source_type_id resolved first).
async function findOrCreateSource(
  supabase: ReturnType<typeof createAdminClient>,
  name: string | undefined | null,
  sourceTypeId: string | null,
  website: string | undefined | null
): Promise<string | null> {
  if (!name || !name.trim()) return null;
  const trimmed = name.trim();

  const { data: existing } = await supabase
    .from("sources")
    .select("id")
    .ilike("name", trimmed)
    .maybeSingle();

  if (existing) return existing.id as string;

  const { data: created, error } = await supabase
    .from("sources")
    .insert({ name: trimmed, website: website ?? null })
    .select("id")
    .single();
  if (error) throw error;

  if (sourceTypeId) {
    await supabase
      .from("source_source_types")
      .insert({ source_id: created.id, source_type_id: sourceTypeId });
  }

  return created.id as string;
}

// Expected JSON body:
// {
//   "created_by": "agent:claude-code-prospecting-routine",  // required -- see README
//   "organisation": {
//     "name": "Acme Charity",             // required, used to match existing orgs
//     "segment": "Foodbank",              // must match an existing Segment exactly (or close); left blank if no match
//     "category": "Youth sport / physical activity",
//     "source_type": "Membership Body",   // created if it doesn't exist yet
//     "source": "NAVCA",                  // created if it doesn't exist yet (linked to source_type above)
//     "country": "United Kingdom",
//     "similar_to_client": "Sport4Life",
//     "angle": "...",
//     "notes": "...",
//     "website": "https://...",
//     "team_page": "https://...",
//     "annual_report": "https://...",
//     "impact_report": "https://...",
//     "linkedin": "https://linkedin.com/company/...",
//     "beneficiaries": 1200,
//     "workers": 22
//     // NOTE: do not pass date_spotted -- it defaults to today automatically.
//   },
//   "office_locations": [ { "location_name": "Head office", "phone_number": "+44...", "website_url": "https://..." } ],
//   "staff": [
//     {
//       "full_name": "Jane Smith",
//       "department": "Impact / MERL",
//       "seniority": "Head / Director",
//       "email": "...", "direct_dial": "...", "linkedin": "https://linkedin.com/in/...",
//       "background_notes": "...", "bio": "...", "bio_url": "...", "availability_notes": "..."
//     }
//   ]
// }
//
// Response includes a "warnings" array -- always check it. It flags things
// like an unrecognised Segment name, or a linkedin field that isn't a URL
// (in which case that field is dropped rather than stored incorrectly).
export async function POST(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const body = await req.json();
  const { organisation, office_locations = [], staff = [], created_by } = body ?? {};
  const warnings: string[] = [];

  if (!organisation?.name) {
    return NextResponse.json(
      { error: "organisation.name is required" },
      { status: 400 }
    );
  }
  if (!created_by || !String(created_by).trim()) {
    warnings.push(
      "No created_by was supplied -- please always identify the calling agent (e.g. 'agent:claude-code-prospecting-routine') for transparency."
    );
  }

  const supabase = createAdminClient();

  const category_id = await findOrCreateLookup(supabase, "categories", organisation.category);
  const { id: segment_id, warning: segmentWarning } = await lookupSegmentStrict(
    supabase,
    organisation.segment
  );
  if (segmentWarning) warnings.push(segmentWarning);

  const source_type_id = await findOrCreateLookup(
    supabase,
    "source_types",
    organisation.source_type
  );
  const source_id = await findOrCreateSource(
    supabase,
    organisation.source,
    source_type_id,
    organisation.source_website
  );

  let orgLinkedin: string | null = organisation.linkedin ?? null;
  if (orgLinkedin && !looksLikeUrl(orgLinkedin)) {
    warnings.push(`organisation.linkedin ("${orgLinkedin}") doesn't look like a URL -- left blank instead of storing it incorrectly.`);
    orgLinkedin = null;
  }

  // Match existing org by exact (case-insensitive) name to avoid duplicates
  const { data: existingOrg } = await supabase
    .from("organisations")
    .select("id")
    .ilike("name", organisation.name.trim())
    .maybeSingle();

  const orgFields = {
    name: organisation.name,
    category_id,
    segment_id,
    source_type_id,
    source_id,
    country: organisation.country ?? null,
    similar_to_client: organisation.similar_to_client ?? null,
    angle: organisation.angle ?? null,
    notes: organisation.notes ?? null,
    website: organisation.website ?? null,
    team_page: organisation.team_page ?? null,
    annual_report: organisation.annual_report ?? null,
    impact_report: organisation.impact_report ?? null,
    linkedin: orgLinkedin,
    beneficiaries: organisation.beneficiaries ?? null,
    workers: organisation.workers ?? null,
    created_by: created_by ?? null,
    // date_spotted intentionally omitted -- always defaults to today's date.
  };

  let organisationId: string;

  if (existingOrg) {
    organisationId = existingOrg.id as string;
    // Don't overwrite created_by on an update -- keep whoever originally created it.
    const { created_by: _omit, ...updateFields } = orgFields;
    void _omit;
    const { error } = await supabase
      .from("organisations")
      .update(updateFields)
      .eq("id", organisationId);
    if (error) throw error;
    warnings.push(`"${organisation.name}" already existed -- updated the existing record instead of creating a duplicate.`);
  } else {
    const { data: created, error } = await supabase
      .from("organisations")
      .insert(orgFields)
      .select("id")
      .single();
    if (error) throw error;
    organisationId = created.id as string;
  }

  for (const loc of office_locations) {
    if (!loc?.location_name) continue;
    await supabase.from("office_locations").insert({
      organisation_id: organisationId,
      location_name: loc.location_name,
      phone_number: loc.phone_number ?? null,
      website_url: loc.website_url ?? null,
      availability: loc.availability ?? null,
    });
  }

  for (const person of staff) {
    if (!person?.full_name) continue;
    const department_id = await findOrCreateLookup(supabase, "departments", person.department);
    const seniority_id = await findOrCreateLookup(supabase, "seniority_levels", person.seniority);

    let personLinkedin: string | null = person.linkedin ?? null;
    if (personLinkedin && !looksLikeUrl(personLinkedin)) {
      warnings.push(`staff "${person.full_name}": linkedin field ("${personLinkedin}") doesn't look like a URL -- left blank instead of storing it incorrectly.`);
      personLinkedin = null;
    }

    await supabase.from("staff").insert({
      organisation_id: organisationId,
      department_id,
      seniority_id,
      full_name: person.full_name,
      job_title: person.job_title ?? null,
      email: person.email ?? null,
      direct_dial: person.direct_dial ?? null,
      linkedin: personLinkedin,
      background_notes: person.background_notes ?? null,
      bio: person.bio ?? null,
      bio_url: person.bio_url ?? null,
      availability_notes: person.availability_notes ?? null,
      conversation_notes: person.conversation_notes ?? null,
      created_by: created_by ?? null,
    });
  }

  return NextResponse.json(
    { organisation_id: organisationId, warnings },
    { status: 200 }
  );
}
