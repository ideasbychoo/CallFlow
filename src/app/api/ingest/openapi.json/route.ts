import { NextResponse } from "next/server";

// GET /api/ingest/openapi.json
// No auth required -- this is documentation, not data. An agent (or a
// person) can fetch this before doing anything else to get the exact,
// current field names for every ingest endpoint, rather than guessing field
// shapes from a possibly-stale doc and getting silently ignored fields back.
export async function GET() {
  const spec = {
    info: {
      title: "CallFlow Ingest API",
      version: "1.0",
      description:
        "Endpoints for research agents (Claude Code routines or others) to write prospects, staff, and office locations into CallFlow. All endpoints (except this one) require 'Authorization: Bearer <CALLFLOW_INGEST_API_KEY>'. Unrecognised fields are ignored, but reported back in the response's 'warnings' array -- always check it.",
    },
    endpoints: [
      {
        method: "GET",
        path: "/api/ingest/reference-data",
        auth: "required",
        description:
          "Fetch the current valid values for Departments, Seniority Levels, Segments, Source Types, and Categories. Check this before guessing a value for any of those fields.",
      },
      {
        method: "GET",
        path: "/api/ingest/organisations",
        auth: "required",
        query_params: {
          q: "case-insensitive substring match on organisation name (dedup check)",
          gaps_only: "'true' to only return organisations with no Segment or zero staff, sorted so never/longest-unchecked come first",
          limit: "cap the number of rows returned",
        },
        description: "List/search existing organisations, including their office_locations and staff.",
      },
      {
        method: "POST",
        path: "/api/ingest/organisations",
        auth: "required",
        body: {
          created_by: "string, required -- identifies the calling agent, e.g. 'agent:callflow-backfill-routine'",
          organisation: {
            name: "string, required -- also used to match an existing org (case-insensitive) to update instead of duplicating",
            segment: "string -- must exactly match an existing Segment name (see reference-data); rejected with a warning otherwise, never auto-created",
            category: "string -- legacy free-text field, auto-created if new",
            source_type: "string -- auto-created if new",
            source: "string -- auto-created if new (linked to source_type)",
            source_website: "string -- website for a newly-created Source",
            country: "string",
            similar_to_client: "string",
            angle: "string",
            notes: "string",
            website: "string (URL)",
            team_page: "string (URL)",
            annual_report: "string (URL)",
            impact_report: "string (URL)",
            linkedin: "string (URL) -- validated; non-URL values are dropped with a warning",
            beneficiaries: "integer",
            workers: "integer",
          },
          office_locations: [
            {
              id: "string (uuid) -- include to UPDATE an existing location instead of creating a new one",
              location_name: "string -- defaults to 'Main office' if omitted but other fields are present",
              phone_number: "string",
              website_url: "string",
              availability: "string",
            },
          ],
          staff: [
            {
              full_name: "string, required for a new person",
              department: "string -- see reference-data; auto-created if new",
              seniority: "string -- see reference-data (e.g. 'Head / Director', 'Manager 1', 'Manager 2', 'Manager 3'); prefer an existing empty slot over inventing a new label",
              email: "string",
              direct_dial: "string",
              linkedin: "string (URL)",
              background_notes: "string",
              bio: "string",
              bio_url: "string (URL)",
              availability_notes: "string",
            },
          ],
        },
        notes:
          "On update (existing org matched by name), only fields you actually include are changed -- omitted fields are left as-is, not cleared.",
      },
      {
        method: "POST",
        path: "/api/ingest/staff",
        auth: "required",
        body: {
          created_by: "string, required",
          organisation_id: "string (uuid) -- either this or organisation_name",
          organisation_name: "string -- matched case-insensitively",
          staff: [
            {
              id: "string (uuid) -- include to UPDATE an existing staff member (only provided fields change); omit to ADD a new person",
              full_name: "string, required when adding a new person",
              department: "string",
              seniority: "string",
              email: "string",
              direct_dial: "string",
              linkedin: "string (URL)",
              background_notes: "string",
              bio: "string",
              bio_url: "string (URL)",
              availability_notes: "string",
              conversation_notes: "string",
            },
          ],
        },
      },
      {
        method: "POST",
        path: "/api/ingest/test-connection",
        auth: "none (uses the server's own key)",
        description: "One-click test used by the Settings page. Not for agent use.",
      },
    ],
  };

  return NextResponse.json(spec);
}
