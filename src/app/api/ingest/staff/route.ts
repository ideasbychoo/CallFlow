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

// Departments and Seniority Levels are now a fixed, curated list (like
// Segments) -- auto-creating a new one whenever a name didn't match exactly
// is what fragmented both lists into dozens of near-duplicate, low-value
// entries. Only match an EXISTING entry by name -- never create a new one.
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

// Expected JSON body:
// {
//   "created_by": "agent:claude-code-prospecting-routine",  // required -- see README
//   "organisation_id": "uuid"        // either this, or...
//   "organisation_name": "Acme Charity",  // ...this, to look the org up by name
//   "staff": [
//     // include "id" to UPDATE an existing staff member (only the fields you
//     // provide are changed -- omit a field to leave it as-is). Omit "id" to
//     // ADD a brand-new person.
//     { id, full_name, department, seniority, email, direct_dial, linkedin, background_notes, bio, bio_url, availability_notes }
//   ]
// }
export async function POST(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const body = await req.json();
  const { organisation_id, organisation_name, staff = [], created_by, mark_checked } = body ?? {};
  const warnings: string[] = [];

  // See the matching comment in /api/ingest/organisations -- defaults to
  // "general" (backfill_checked_at) for backward compatibility; specialized
  // routines should pass mark_checked: ["dept_focus"] or ["phone_focus"] so
  // they don't deprioritise this org in a different routine's queue.
  const markCheckedRaw: string[] = Array.isArray(mark_checked) && mark_checked.length > 0 ? mark_checked : ["general"];
  const VALID_CHECKED_KINDS = new Set(["general", "dept_focus", "phone_focus"]);
  const checkedAtUpdates: Record<string, string> = {};
  const checkedNow = new Date().toISOString();
  for (const kind of markCheckedRaw) {
    if (!VALID_CHECKED_KINDS.has(kind)) {
      warnings.push(`mark_checked value "${kind}" isn't recognised (expected "general", "dept_focus", or "phone_focus") -- ignored.`);
      continue;
    }
    if (kind === "general") checkedAtUpdates.backfill_checked_at = checkedNow;
    if (kind === "dept_focus") checkedAtUpdates.dept_focus_checked_at = checkedNow;
    if (kind === "phone_focus") checkedAtUpdates.phone_focus_checked_at = checkedNow;
  }

  if (!created_by || !String(created_by).trim()) {
    warnings.push(
      "No created_by was supplied -- please always identify the calling agent (e.g. 'agent:claude-code-prospecting-routine') for transparency."
    );
  }

  const supabase = createAdminClient();

  let orgId = organisation_id as string | undefined;

  if (!orgId && organisation_name) {
    const { data } = await supabase
      .from("organisations")
      .select("id")
      .ilike("name", organisation_name.trim())
      .maybeSingle();
    orgId = data?.id;
  }

  if (!orgId) {
    return NextResponse.json(
      { error: "organisation_id or a matching organisation_name is required" },
      { status: 400 }
    );
  }

  const insertedOrUpdated: string[] = [];
  const KNOWN_STAFF_FIELDS = new Set([
    "id", "full_name", "job_title", "department", "seniority", "email", "direct_dial", "linkedin",
    "background_notes", "bio", "bio_url", "availability_notes", "conversation_notes",
  ]);

  for (const person of staff) {
    const provided = new Set(Object.keys(person ?? {}));
    for (const key of provided) {
      if (!KNOWN_STAFF_FIELDS.has(key)) {
        warnings.push(`staff "${person.full_name ?? person.id}": field "${key}" isn't recognised and was ignored.`);
      }
    }

    let department_id: string | null | undefined;
    if (provided.has("department")) {
      const result = await lookupDeptOrSeniorityStrict(supabase, "departments", person.department);
      department_id = result.id;
      if (result.warning) warnings.push(`staff "${person.full_name ?? person.id}": ${result.warning}`);
    }
    let seniority_id: string | null | undefined;
    if (provided.has("seniority")) {
      const result = await lookupDeptOrSeniorityStrict(supabase, "seniority_levels", person.seniority);
      seniority_id = result.id;
      if (result.warning) warnings.push(`staff "${person.full_name ?? person.id}": ${result.warning}`);
    }

    let personLinkedin: string | null | undefined = provided.has("linkedin") ? person.linkedin ?? null : undefined;
    if (personLinkedin && !looksLikeUrl(personLinkedin)) {
      warnings.push(`staff "${person.full_name ?? person.id}": linkedin field ("${personLinkedin}") doesn't look like a URL -- left blank instead of storing it incorrectly.`);
      personLinkedin = null;
    }

    if (person?.id) {
      // Update an existing staff member -- only touch fields actually provided.
      const updateFields: Record<string, unknown> = {};
      if (department_id !== undefined) updateFields.department_id = department_id;
      if (seniority_id !== undefined) updateFields.seniority_id = seniority_id;
      if (personLinkedin !== undefined) updateFields.linkedin = personLinkedin;
      for (const key of ["full_name", "job_title", "email", "direct_dial", "background_notes", "bio", "bio_url", "availability_notes", "conversation_notes"]) {
        if (provided.has(key)) updateFields[key] = person[key] ?? null;
      }

      if (Object.keys(updateFields).length === 0) continue;

      const { error } = await supabase
        .from("staff")
        .update(updateFields)
        .eq("id", person.id)
        .eq("organisation_id", orgId);
      if (error) throw error;
      insertedOrUpdated.push(person.id as string);
      continue;
    }

    if (!person?.full_name) continue;

    // Guard against the most common real-world duplicate: the caller meant
    // to update someone already on file but didn't include their `id` (e.g.
    // because they weren't spotted as already existing). An exact
    // case-insensitive name match at the SAME organisation is a strong
    // enough signal to skip the insert and point at the existing record
    // instead, rather than silently creating a duplicate person.
    const { data: existingPerson } = await supabase
      .from("staff")
      .select("id")
      .eq("organisation_id", orgId)
      .ilike("full_name", person.full_name.trim())
      .maybeSingle();

    if (existingPerson) {
      warnings.push(
        `staff "${person.full_name}": an existing staff record with this exact name already exists at this organisation (id: ${existingPerson.id}) -- skipped creating a duplicate. If this is the same person, resend with "id": "${existingPerson.id}" to update them instead. If they're genuinely a different person with the same name, include a distinguishing detail (e.g. in background_notes) and contact Matt to add manually.`
      );
      continue;
    }

    const { data, error } = await supabase
      .from("staff")
      .insert({
        organisation_id: orgId,
        department_id: department_id ?? null,
        seniority_id: seniority_id ?? null,
        full_name: person.full_name,
        job_title: person.job_title ?? null,
        email: person.email ?? null,
        direct_dial: person.direct_dial ?? null,
        linkedin: personLinkedin ?? null,
        background_notes: person.background_notes ?? null,
        bio: person.bio ?? null,
        bio_url: person.bio_url ?? null,
        availability_notes: person.availability_notes ?? null,
        conversation_notes: person.conversation_notes ?? null,
        created_by: created_by ?? null,
      })
      .select("id")
      .single();

    if (error) throw error;
    insertedOrUpdated.push(data.id as string);
  }

  if (insertedOrUpdated.length > 0) {
    await supabase
      .from("organisations")
      .update(checkedAtUpdates)
      .eq("id", orgId);
  }

  return NextResponse.json({ organisation_id: orgId, staff_ids: insertedOrUpdated, warnings });
}
