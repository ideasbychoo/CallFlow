import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";

function checkAuth(req: NextRequest): boolean {
  const header = req.headers.get("authorization") ?? "";
  const token = header.replace(/^Bearer\s+/i, "");
  return Boolean(token) && token === process.env.CALLFLOW_INGEST_API_KEY;
}

// GET /api/ingest/reference-data
// Auth: same Bearer token as the other ingest endpoints.
//
// Returns the current valid values for every fixed/managed list an agent
// might need to pick from -- Departments, Seniority Levels, Segments, and
// Source Types. Always check this before guessing a value for `department`,
// `seniority`, or `segment` in a POST -- Departments, Seniority Levels, and
// Segments are ALL strict, fixed lists now: a name that doesn't match an
// existing entry exactly (case-insensitive) is simply left blank with a
// warning, never auto-created. Assign the closest existing fit instead of
// inventing a new label.
export async function GET(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const supabase = createAdminClient();
  const [departments, seniorityLevels, segments, sourceTypes, categories] = await Promise.all([
    supabase.from("departments").select("name, sort_order, is_official").order("sort_order"),
    supabase.from("seniority_levels").select("name, sort_order, is_official").order("sort_order"),
    supabase.from("segments").select("name, sort_order").order("sort_order"),
    supabase.from("source_types").select("name, sort_order").order("sort_order"),
    supabase.from("categories").select("name, sort_order").order("sort_order"),
  ]);

  return NextResponse.json({
    departments: (departments.data ?? []).map((d) => d.name),
    departments_official: (departments.data ?? []).filter((d) => d.is_official).map((d) => d.name),
    seniority_levels: (seniorityLevels.data ?? []).map((s) => s.name),
    seniority_levels_official: (seniorityLevels.data ?? []).filter((s) => s.is_official).map((s) => s.name),
    segments: (segments.data ?? []).map((s) => s.name),
    source_types: (sourceTypes.data ?? []).map((s) => s.name),
    categories: (categories.data ?? []).map((c) => c.name),
    notes: {
      departments: "STRICT -- only an exact existing match will be used; never auto-created. `departments_official` is the curated subset Matt has marked as canonical -- prefer one of those when it genuinely fits; otherwise pick the closest existing entry from the full `departments` list rather than inventing a new one.",
      seniority_levels: "STRICT -- only an exact existing match will be used; never auto-created. `seniority_levels_official` is the curated subset Matt has marked as canonical -- prefer one of those when it genuinely fits; otherwise pick the closest existing entry from the full `seniority_levels` list rather than inventing a new one.",
      segments: "STRICT -- only an exact existing match will be used; anything else is rejected with a warning, never auto-created.",
      source_types: "Auto-created if you send something new.",
      categories: "Legacy free-text field, largely superseded by Segments. Auto-created if you send something new.",
    },
  });
}
