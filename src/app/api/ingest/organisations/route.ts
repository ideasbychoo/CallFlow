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
  table: "categories" | "source_types",
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

// Departments and Seniority Levels are now a fixed, curated list (like
// Segments) -- the agents auto-creating a new one whenever a name didn't
// match exactly is exactly what fragmented both lists into dozens of
// near-duplicate, low-value entries. Ingest must only match an EXISTING
// entry by name -- never create a new one. If nothing matches, return null
// and surface a warning so the agent picks the closest existing fit instead.
async function lookupDeptOrSeniorityStrict(
  supabase: ReturnType<typeof createAdminClient>,
  table: "departments" | "seniority_levels",
  name: string | undefined | null
): Promise<{ id: string | null; warning: string | null }> {
  if (!name || !name.trim()) return { id: null, warning: null };
  const trimmed = name.trim();

  const { data: existing } = await supabase
    .from(table)
    .select("id")
    .ilike("name", trimmed)
    .maybeSingle();

  if (existing) return { id: existing.id as string, warning: null };

  const label = table === "departments" ? "Department" : "Seniority Level";
  return {
    id: null,
    warning: `${label} "${trimmed}" doesn't match any existing ${label} -- left blank. This is a fixed list; check GET .../reference-data and assign the closest existing fit rather than inventing a new one.`,
  };
}

// Segments are a deliberately fixed, curated list (unlike categories/
// source_types, which can grow freely). Departments and Seniority Levels are
// ALSO now a fixed, curated list -- see lookupDeptOrSeniorityStrict above.
// Ingest must only match an EXISTING segment by name -- never create a new
// one. If the name doesn't match anything, return null and surface a warning
// so the caller knows the segment wasn't recorded.
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
// Query params (all optional, pick ONE targeting mode -- q / gaps_only /
// missing_department / missing_phone are mutually exclusive):
//   q=<text>                 -- case-insensitive substring match on name, for dedup checks
//                                before adding a new prospect
//   gaps_only=true            -- orgs with no Segment assigned OR zero linked staff at all
//                                (general backfill routine)
//   missing_department=<name> -- orgs with NO staff member in the given Department, even if
//                                they already have other staff/a Segment (e.g. "Impact / MERL"
//                                staff-finding routine). Sorted by dept_focus_checked_at.
//   missing_phone=true        -- orgs with no phone number on ANY office_locations row
//                                (phone-number backfill routine). Sorted by phone_focus_checked_at.
//   limit=<n>                 -- cap the number of rows returned (default: no cap)
//
// Use this before creating a new organisation (dedup check) and before doing
// backfill research on existing organisations (to see what's already there
// and avoid re-adding the same staff member twice).
//
// Response includes total_gaps_backlog / total_missing_department_backlog /
// total_missing_phone_backlog (matching whichever mode was used): the total
// number of organisations currently matching that filter, before `limit` is
// applied, so a routine can see backlog size without fetching it all.
export async function GET(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const supabase = createAdminClient();
  const { searchParams } = new URL(req.url);
  const q = searchParams.get("q");
  const gapsOnly = searchParams.get("gaps_only") === "true";
  const missingDepartment = searchParams.get("missing_department");
  const missingPhone = searchParams.get("missing_phone") === "true";
  const limitParam = searchParams.get("limit");
  const limit = limitParam ? parseInt(limitParam, 10) : null;

  // Shared helper for the missing_department / missing_phone modes: given a
  // small set of organisation IDs that DO already satisfy the thing being
  // searched for, fetch every organisation's id + its own checked_at column
  // (cheap, no joins), exclude the "already has it" set, sort by checked_at
  // (never-checked first), slice to `limit`, then fetch the full nested
  // payload only for that handful of IDs. Mirrors the gaps_only/
  // ingest_gaps_view approach without needing a bespoke view per mode.
  async function fetchTargeted(
    excludeIds: Set<string>,
    checkedAtColumn: "dept_focus_checked_at" | "phone_focus_checked_at"
  ) {
    const { data: allOrgs, error: allOrgsError } = await supabase
      .from("organisations")
      .select("id, dept_focus_checked_at, phone_focus_checked_at");
    if (allOrgsError) throw allOrgsError;

    const typedOrgs = (allOrgs ?? []) as {
      id: string;
      dept_focus_checked_at: string | null;
      phone_focus_checked_at: string | null;
    }[];

    const candidates = typedOrgs.filter((o) => !excludeIds.has(o.id));
    candidates.sort((a, b) => {
      const aTime = a[checkedAtColumn] ? new Date(a[checkedAtColumn] as string).getTime() : -Infinity;
      const bTime = b[checkedAtColumn] ? new Date(b[checkedAtColumn] as string).getTime() : -Infinity;
      return aTime - bTime;
    });

    const total = candidates.length;
    const limitedIds = (limit && Number.isFinite(limit) ? candidates.slice(0, limit) : candidates).map((o) => o.id);

    if (limitedIds.length === 0) return { total, rows: [] as unknown[] };

    const { data, error } = await supabase.from("organisations").select(SELECT_FOR_AGENTS).in("id", limitedIds);
    if (error) throw error;

    const orderIndex = new Map(limitedIds.map((id, i) => [id, i]));
    const rows = [...(data ?? [])].sort(
      (a, b) => (orderIndex.get((a as { id: string }).id) ?? 0) - (orderIndex.get((b as { id: string }).id) ?? 0)
    );
    return { total, rows };
  }

  if (missingDepartment) {
    const { data: dept } = await supabase
      .from("departments")
      .select("id")
      .ilike("name", missingDepartment.trim())
      .maybeSingle();

    if (!dept) {
      return NextResponse.json(
        { error: `No Department found matching "${missingDepartment}". Check GET .../reference-data for valid names.` },
        { status: 400 }
      );
    }

    const { data: staffInDept, error: staffError } = await supabase
      .from("staff")
      .select("organisation_id")
      .eq("department_id", dept.id);
    if (staffError) {
      return NextResponse.json({ error: staffError.message }, { status: 500 });
    }
    const orgsWithDeptStaff = new Set((staffInDept ?? []).map((s) => s.organisation_id as string));

    const { total, rows } = await fetchTargeted(orgsWithDeptStaff, "dept_focus_checked_at");
    return NextResponse.json({
      count: rows.length,
      total_missing_department_backlog: total,
      organisations: rows,
    });
  }

  if (missingPhone) {
    const { data: locsWithPhone, error: locsError } = await supabase
      .from("office_locations")
      .select("organisation_id")
      .not("phone_number", "is", null)
      .neq("phone_number", "");
    if (locsError) {
      return NextResponse.json({ error: locsError.message }, { status: 500 });
    }
    const orgsWithPhone = new Set((locsWithPhone ?? []).map((l) => l.organisation_id as string));

    const { total, rows } = await fetchTargeted(orgsWithPhone, "phone_focus_checked_at");
    return NextResponse.json({
      count: rows.length,
      total_missing_phone_backlog: total,
      organisations: rows,
    });
  }

  if (gapsOnly) {
    // Filter, sort, AND limit at the database level via ingest_gaps_view
    // (migration 019) -- this avoids pulling every organisation's full
    // nested staff/office_locations payload into Node just to filter almost
    // all of it back out again, which would only get slower and more
    // expensive as the table grows. We only fetch the full payload for the
    // handful of organisation IDs actually being picked up this run.
    let gapsQuery = supabase
      .from("ingest_gaps_view")
      .select("id", { count: "exact" })
      .or("no_segment.eq.true,staff_count.eq.0")
      .order("backfill_checked_at", { ascending: true, nullsFirst: true });

    const { data: gapsRows, error: gapsError, count: totalGapsBacklog } = await gapsQuery;
    if (gapsError) {
      return NextResponse.json({ error: gapsError.message }, { status: 500 });
    }

    const orderedIds = (gapsRows ?? []).map((r) => r.id as string);
    const limitedIds = limit && Number.isFinite(limit) ? orderedIds.slice(0, limit) : orderedIds;

    if (limitedIds.length === 0) {
      return NextResponse.json({ count: 0, total_gaps_backlog: totalGapsBacklog ?? 0, organisations: [] });
    }

    const { data, error } = await supabase
      .from("organisations")
      .select(SELECT_FOR_AGENTS)
      .in("id", limitedIds);
    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 });
    }

    // The .in() query doesn't preserve the backlog-priority order from
    // ingest_gaps_view, so re-sort the (small) result set to match it.
    const orderIndex = new Map(limitedIds.map((id, i) => [id, i]));
    const rows = [...(data ?? [])].sort(
      (a, b) => (orderIndex.get((a as { id: string }).id) ?? 0) - (orderIndex.get((b as { id: string }).id) ?? 0)
    );

    return NextResponse.json({
      count: rows.length,
      total_gaps_backlog: totalGapsBacklog ?? 0,
      organisations: rows,
    });
  }

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

  return NextResponse.json({
    count: (data ?? []).length,
    organisations: data ?? [],
  });
}

export async function POST(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const body = await req.json();
  const { organisation, office_locations = [], staff = [], created_by, mark_checked } = body ?? {};
  const warnings: string[] = [];

  // Which "checked" timestamp(s) to bump on this organisation. Defaults to
  // just "general" (the existing backfill_checked_at) so the original
  // prospecting/backfill routines don't need any changes. Specialized
  // routines (e.g. the Impact/MERL staff-finder, the phone-number backfill)
  // should pass mark_checked: ["dept_focus"] / ["phone_focus"] so they don't
  // silently deprioritise this organisation in a DIFFERENT routine's queue
  // by bumping a shared timestamp they have no business updating.
  const markCheckedRaw: string[] = Array.isArray(mark_checked) && mark_checked.length > 0 ? mark_checked : ["general"];
  const VALID_CHECKED_KINDS = new Set(["general", "dept_focus", "phone_focus"]);
  const checkedAtUpdates: Record<string, string> = {};
  const now = new Date().toISOString();
  for (const kind of markCheckedRaw) {
    if (!VALID_CHECKED_KINDS.has(kind)) {
      warnings.push(`mark_checked value "${kind}" isn't recognised (expected "general", "dept_focus", or "phone_focus") -- ignored.`);
      continue;
    }
    if (kind === "general") checkedAtUpdates.backfill_checked_at = now;
    if (kind === "dept_focus") checkedAtUpdates.dept_focus_checked_at = now;
    if (kind === "phone_focus") checkedAtUpdates.phone_focus_checked_at = now;
  }

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
    const updateFields: Record<string, unknown> = { ...checkedAtUpdates };
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
      ...checkedAtUpdates,
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

    const deptResult = await lookupDeptOrSeniorityStrict(supabase, "departments", person.department);
    const department_id = deptResult.id;
    if (deptResult.warning) warnings.push(`staff "${person.full_name}": ${deptResult.warning}`);

    const seniorityResult = await lookupDeptOrSeniorityStrict(supabase, "seniority_levels", person.seniority);
    const seniority_id = seniorityResult.id;
    if (seniorityResult.warning) warnings.push(`staff "${person.full_name}": ${seniorityResult.warning}`);

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
