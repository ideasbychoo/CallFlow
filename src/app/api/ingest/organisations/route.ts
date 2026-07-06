import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";

function checkAuth(req: NextRequest): boolean {
  const header = req.headers.get("authorization") ?? "";
  const token = header.replace(/^Bearer\s+/i, "");
  return Boolean(token) && token === process.env.CALLFLOW_INGEST_API_KEY;
}

async function findOrCreateLookup(
  supabase: ReturnType<typeof createAdminClient>,
  table: "categories" | "departments" | "seniority_levels",
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
//   "organisation": {
//     "name": "Acme Charity",             // required, used to match existing orgs
//     "category": "Youth sport / physical activity",
//     "country": "United Kingdom",
//     "similar_to_client": "Sport4Life",
//     "angle": "...",
//     "notes": "...",
//     "website": "https://...",
//     "team_page": "https://...",
//     "annual_report": "https://...",
//     "impact_report": "https://...",
//     "date_spotted": "2026-07-06"
//   },
//   "office_locations": [ { "location_name": "Head office", "phone_number": "+44..." } ],
//   "staff": [
//     {
//       "full_name": "Jane Smith",
//       "department": "Impact / MERL",
//       "seniority": "Head / Director",
//       "email": "...", "direct_dial": "...", "linkedin": "...",
//       "background_notes": "...", "availability_notes": "..."
//     }
//   ]
// }
export async function POST(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const body = await req.json();
  const { organisation, office_locations = [], staff = [] } = body ?? {};

  if (!organisation?.name) {
    return NextResponse.json(
      { error: "organisation.name is required" },
      { status: 400 }
    );
  }

  const supabase = createAdminClient();

  const category_id = await findOrCreateLookup(
    supabase,
    "categories",
    organisation.category
  );

  // Match existing org by exact (case-insensitive) name to avoid duplicates
  const { data: existingOrg } = await supabase
    .from("organisations")
    .select("id")
    .ilike("name", organisation.name.trim())
    .maybeSingle();

  const orgFields = {
    name: organisation.name,
    category_id,
    country: organisation.country ?? null,
    similar_to_client: organisation.similar_to_client ?? null,
    angle: organisation.angle ?? null,
    notes: organisation.notes ?? null,
    website: organisation.website ?? null,
    team_page: organisation.team_page ?? null,
    annual_report: organisation.annual_report ?? null,
    impact_report: organisation.impact_report ?? null,
    ...(organisation.date_spotted
      ? { date_spotted: organisation.date_spotted }
      : {}),
  };

  let organisationId: string;

  if (existingOrg) {
    organisationId = existingOrg.id as string;
    const { error } = await supabase
      .from("organisations")
      .update(orgFields)
      .eq("id", organisationId);
    if (error) throw error;
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
    });
  }

  for (const person of staff) {
    if (!person?.full_name) continue;
    const department_id = await findOrCreateLookup(
      supabase,
      "departments",
      person.department
    );
    const seniority_id = await findOrCreateLookup(
      supabase,
      "seniority_levels",
      person.seniority
    );

    await supabase.from("staff").insert({
      organisation_id: organisationId,
      department_id,
      seniority_id,
      full_name: person.full_name,
      email: person.email ?? null,
      direct_dial: person.direct_dial ?? null,
      linkedin: person.linkedin ?? null,
      background_notes: person.background_notes ?? null,
      availability_notes: person.availability_notes ?? null,
      conversation_notes: person.conversation_notes ?? null,
    });
  }

  return NextResponse.json({ organisation_id: organisationId }, { status: 200 });
}
