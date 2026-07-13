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
// `seniority`, or `segment` in a POST -- department and seniority will be
// auto-created if you send something that doesn't match (which can silently
// fragment a deliberately small list like Seniority Levels), and segment
// will simply be rejected with a warning if it doesn't match exactly.
export async function GET(req: NextRequest) {
  if (!checkAuth(req)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  const supabase = createAdminClient();
  const [departments, seniorityLevels, segments, sourceTypes, categories] = await Promise.all([
    supabase.from("departments").select("name, sort_order").order("sort_order"),
    supabase.from("seniority_levels").select("name, sort_order").order("sort_order"),
    supabase.from("segments").select("name, sort_order").order("sort_order"),
    supabase.from("source_types").select("name, sort_order").order("sort_order"),
    supabase.from("categories").select("name, sort_order").order("sort_order"),
  ]);

  return NextResponse.json({
    departments: (departments.data ?? []).map((d) => d.name),
    seniority_levels: (seniorityLevels.data ?? []).map((s) => s.name),
    segments: (segments.data ?? []).map((s) => s.name),
    source_types: (sourceTypes.data ?? []).map((s) => s.name),
    categories: (categories.data ?? []).map((c) => c.name),
    notes: {
      departments: "Auto-created if you send something new -- this list is expected to grow over time.",
      seniority_levels: "Auto-created if you send something new, but this is meant to stay a small, deliberate set (e.g. multiple 'Manager N' slots exist so several managers can be placed in one department). Prefer an existing empty slot over inventing a new label -- e.g. use 'Manager 2' if 'Manager 1' is already taken in that department, rather than creating a generic 'Manager'.",
      segments: "STRICT -- only an exact existing match will be used; anything else is rejected with a warning, never auto-created.",
      source_types: "Auto-created if you send something new.",
      categories: "Legacy free-text field, largely superseded by Segments. Auto-created if you send something new.",
    },
  });
}
