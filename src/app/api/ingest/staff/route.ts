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
  table: "departments" | "seniority_levels",
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

// Expected JSON body:
// {
//   "created_by": "agent:claude-code-prospecting-routine",  // required -- see README
//   "organisation_id": "uuid"        // either this, or...
//   "organisation_name": "Acme Charity",  // ...this, to look the org up by name
//   "staff": [ { full_name, department, seniority, email, direct_dial, linkedin, background_notes, bio, bio_url, availability_notes } ]
// }
export async function POST(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const body = await req.json();
  const { organisation_id, organisation_name, staff = [], created_by } = body ?? {};
  const warnings: string[] = [];

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

  const inserted: string[] = [];

  for (const person of staff) {
    if (!person?.full_name) continue;
    const department_id = await findOrCreateLookup(supabase, "departments", person.department);
    const seniority_id = await findOrCreateLookup(supabase, "seniority_levels", person.seniority);

    let personLinkedin: string | null = person.linkedin ?? null;
    if (personLinkedin && !looksLikeUrl(personLinkedin)) {
      warnings.push(`staff "${person.full_name}": linkedin field ("${personLinkedin}") doesn't look like a URL -- left blank instead of storing it incorrectly.`);
      personLinkedin = null;
    }

    const { data, error } = await supabase
      .from("staff")
      .insert({
        organisation_id: orgId,
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
      })
      .select("id")
      .single();

    if (error) throw error;
    inserted.push(data.id as string);
  }

  if (inserted.length > 0) {
    await supabase
      .from("organisations")
      .update({ backfill_checked_at: new Date().toISOString() })
      .eq("id", orgId);
  }

  return NextResponse.json({ organisation_id: orgId, staff_ids: inserted, warnings });
}
