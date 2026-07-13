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
): Promise<{ id: string | null; created: boolean }> {
  if (!name || !name.trim()) return { id: null, created: false };
  const trimmed = name.trim();

  const { data: existing } = await supabase
    .from(table)
    .select("id")
    .ilike("name", trimmed)
    .maybeSingle();

  if (existing) return { id: existing.id as string, created: false };

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
  return { id: created.id as string, created: true };
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
const SELECT_FOR_AGENTS = `
  id, name, country, similar_to_client, angle, notes, website, team_page,
  annual_report, impact_report, linkedin, beneficiaries, workers, created_by, created_at,
  backfill_checked_at,
  category:categories(name),
  segment:segments(name),
  source_type:source_types(name),
  source:sources(name),
  office_locations(id, location_name, phone_number, website_url, availability),
  staff(id, full_name, job_title, email, direct_dial, linkedin, bio, bio_url,
    department:departments(name), seniority:seniority_levels(name))
`;

// GET /api/ingest/organisations
// Auth: same Bearer token as POST.
// Query params (all optional):
//   q=<text>          -- case-insensitive substring match on name, for dedup checks
//                         before adding a new prospect
//   gaps_only=true     -- only return organisations with no Segment assigned OR
//                         zero linked staff, for backfill/gap-filling work
//   limit=<n>          -- cap the number of rows returned (default: no cap)
//
// Use this before creating a new organisation (dedup check) and before doing
// backfill research on existing organisations (to see what's already there
// and avoid re-adding the same staff member twice).
export async function GET(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const supabase = createAdminClient();
  const { searchParams } = new URL(req.url);
  const q = searchParams.get("q");
  const gapsOnly = searchParams.get("gaps_only") === "true";
  const limitParam = searchParams.get("limit");
  const limit = limitParam ? parseInt(limitParam, 10) : null;

  let query = supabase.from("organisations").select(SELECT_FOR_AGENTS).order("name");

  if (q) {
    query = query.ilike("name", `%${q}%`);
  }
  if (limit && Number.isFinite(limit)) {
    query = query.limit(limit);
  }

  const { data, error } = await query;
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 });
  }

  type Row = { segment: unknown; staff: unknown[]; backfill_checked_at: string | null };
  let rows = (data ?? []) as unknown as Row[];

  if (gapsOnly) {
    rows = rows.filter((row) => !row.segment || (row.staff ?? []).length === 0);
    // Never-checked orgs first, then oldest-checked -- so the backfill routine
    // doesn't keep re-researching the same handful of genuinely-unfindable
    // organisations every single day.
    rows = rows.sort((a, b) => {
      const aTime = a.backfill_checked_at ? new Date(a.backfill_checked_at).getTime() : -Infinity;
      const bTime = b.backfill_checked_at ? new Date(b.backfill_checked_at).getTime() : -Infinity;
      return aTime - bTime;
    });
  }

  return NextResponse.json({ count: rows.length, organisations: rows });
}

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
  const provided = new Set(Object.keys(organisation ?? {}));
  const KNOWN_ORG_FIELDS = new Set([
    "name", "category", "segment", "source_type", "source", "source_website",
    "country", "similar_to_client", "angle", "notes", "website", "team_page",
    "annual_report", "impact_report", "linkedin", "beneficiaries", "workers",
  ]);
  for (const key of provided) {
    if (!KNOWN_ORG_FIELDS.has(key)) {
      warnings.push(`organisation.${key} isn't a recognised field and was ignored -- see the GET .../reference-data or the routine doc for the correct field name.`);
    }
  }

  // Lookups are only resolved (and only touched on update) when the caller
  // actually provided the corresponding raw field -- otherwise an update
  // call that's only adding e.g. a phone number would silently wipe out an
  // already-set category/segment/source by resolving an absent field to null.
  const category_id = provided.has("category")
    ? (await findOrCreateLookup(supabase, "categories", organisation.category)).id
    : undefined;

  let segment_id: string | null | undefined;
  if (provided.has("segment")) {
    const result = await lookupSegmentStrict(supabase, organisation.segment);
    segment_id = result.id;
    if (result.warning) warnings.push(result.warning);
  }

  const source_type_id = provided.has("source_type")
    ? (await findOrCreateLookup(supabase, "source_types", organisation.source_type)).id
    : undefined;
  const source_id = provided.has("source")
    ? await findOrCreateSource(supabase, organisation.source, source_type_id ?? null, organisation.source_website)
    : undefined;

  let orgLinkedin: string | null | undefined = provided.has("linkedin") ? organisation.linkedin ?? null : undefined;
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

  let organisationId: string;

  if (existingOrg) {
    organisationId = existingOrg.id as string;

    // Partial update: only include fields the caller actually provided, so
    // e.g. a backfill call that's only adding staff/a phone number doesn't
    // null out fields it simply didn't mention.
    const updateFields: Record<string, unknown> = { backfill_checked_at: new Date().toISOString() };
    if (category_id !== undefined) updateFields.category_id = category_id;
    if (segment_id !== undefined) updateFields.segment_id = segment_id;
    if (source_type_id !== undefined) updateFields.source_type_id = source_type_id;
    if (source_id !== undefined) updateFields.source_id = source_id;
    if (orgLinkedin !== undefined) updateFields.linkedin = orgLinkedin;
    for (const key of [
      "country", "similar_to_client", "angle", "notes", "website",
      "team_page", "annual_report", "impact_report", "beneficiaries", "workers",
    ]) {
      if (provided.has(key)) updateFields[key] = organisation[key] ?? null;
    }

    const { error } = await supabase
      .from("organisations")
      .update(updateFields)
      .eq("id", organisationId);
    if (error) throw error;
    warnings.push(`"${organisation.name}" already existed -- updated the existing record (only the fields you provided) instead of creating a duplicate.`);
  } else {
    const insertFields = {
      name: organisation.name,
      category_id: category_id ?? null,
      segment_id: segment_id ?? null,
      source_type_id: source_type_id ?? null,
      source_id: source_id ?? null,
      country: organisation.country ?? null,
      similar_to_client: organisation.similar_to_client ?? null,
      angle: organisation.angle ?? null,
      notes: organisation.notes ?? null,
      website: organisation.website ?? null,
      team_page: organisation.team_page ?? null,
      annual_report: organisation.annual_report ?? null,
      impact_report: organisation.impact_report ?? null,
      linkedin: orgLinkedin ?? null,
      beneficiaries: organisation.beneficiaries ?? null,
      workers: organisation.workers ?? null,
      created_by: created_by ?? null,
      backfill_checked_at: new Date().toISOString(),
      // date_spotted intentionally omitted -- always defaults to today's date.
    };
    const { data: created, error } = await supabase
      .from("organisations")
      .insert(insertFields)
      .select("id")
      .single();
    if (error) throw error;
    organisationId = created.id as string;
  }

  for (const loc of office_locations) {
    const hasAnyData = loc?.phone_number || loc?.website_url || loc?.availability || loc?.location_name;
    if (!hasAnyData) continue;

    if (loc?.id) {
      const updateFields: Record<string, unknown> = {};
      for (const key of ["location_name", "phone_number", "website_url", "availability"]) {
        if (Object.prototype.hasOwnProperty.call(loc, key)) updateFields[key] = loc[key] ?? null;
      }
      if (Object.keys(updateFields).length > 0) {
        const { error } = await supabase
          .from("office_locations")
          .update(updateFields)
          .eq("id", loc.id)
          .eq("organisation_id", organisationId);
        if (error) throw error;
      }
      continue;
    }

    // location_name defaults to something sensible rather than silently
    // dropping the whole entry when it's omitted -- a phone number or
    // website is still worth recording even with no distinct site name.
    const { error } = await supabase.from("office_locations").insert({
      organisation_id: organisationId,
      location_name: loc.location_name || "Main office",
      phone_number: loc.phone_number ?? null,
      website_url: loc.website_url ?? null,
      availability: loc.availability ?? null,
    });
    if (error) throw error;
  }

  const KNOWN_STAFF_FIELDS = new Set([
    "full_name", "department", "seniority", "email", "direct_dial", "linkedin",
    "background_notes", "bio", "bio_url", "availability_notes", "conversation_notes",
  ]);

  for (const person of staff) {
    if (!person?.full_name) continue;
    for (const key of Object.keys(person)) {
      if (!KNOWN_STAFF_FIELDS.has(key)) {
        warnings.push(`staff "${person.full_name}": field "${key}" isn't recognised and was ignored.`);
      }
    }

    const department_id = (await findOrCreateLookup(supabase, "departments", person.department)).id;
    const seniorityResult = await findOrCreateLookup(supabase, "seniority_levels", person.seniority);
    const seniority_id = seniorityResult.id;
    if (seniorityResult.created) {
      warnings.push(`staff "${person.full_name}": seniority "${person.seniority}" didn't match an existing level, so a new one was created. Check GET .../reference-data for the current list (e.g. "Manager 1", "Manager 2") and prefer an existing empty slot instead of inventing a new label.`);
    }

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
