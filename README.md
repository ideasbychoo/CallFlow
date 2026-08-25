# CallFlow

Internal calling/prospecting tool for Makerble. Built with Next.js (App Router) and Supabase.

> **Keep this section current.** Whenever a change to this repo adds, removes, or meaningfully changes what a page or endpoint does, update the relevant part of this README (and `CLAUDE.md`/`docs/ingest-api.md` if infra, conventions, or the ingest API itself changed) in the same push. This applies to Claude Code agents and human developers alike — it's the only way a fresh session (cloud or local) gets an accurate picture without re-deriving it from the code.

## Pages
- **Call List** — the main working view for outbound calling. Wide, expandable/collapsible cards per Organisation, with search, sort, and filters (Segment, Country, Category, Status). Also reachable filtered to a single Status via the sidebar. This is where a "no segment identified" / "no country" organisation shows up so gaps are visible during calling, not just during research.
- **Pipeline** — kanban board, one column per Status, drag-and-drop an Organisation card to change its status. Filterable by Category/Country like Call List.
- **Organisations** — the full spreadsheet-style record view: Angle, Beneficiaries, Annual report, Category, Country, Date spotted, Call attempts, Added by, etc. Inline-editable fields (`EditableText`/`EditableLink`). This is the detailed-record equivalent of Call List's card view.
- **Staff** — spreadsheet view of individual contacts across all organisations: Full name, Job title, Department, Direct dial, Email, LinkedIn, Bio/Bio URL, Availability notes, Background notes, Conversation notes. Filterable by organisation and Department.
- **Research** — cross-tab and hit-list views over `research_org_flags` (a single-query snapshot, not per-cell counts) surfacing where research/segment/phone/priority-role-holder gaps are, with deep links into Call List pre-filtered to that gap (e.g. click a "no segment" cell to jump to exactly those organisations).
- **Reporting** — status-history-driven activity reporting by week (built on `fetchAllStatusHistory`), grouped via configurable Report Groups (see Settings).
- **Sources** — manage the `sources` and `source_types` lookup tables (e.g. "NAVCA", "Membership Body") that the ingest API and manual entry use to record how a prospect was found.
- **Email Templates** — create/edit reusable outreach templates with mail-merge tags for use when emailing prospects.
- **Settings** — manage lookup/reference data: Statuses (incl. "counts as a call attempt", "is Call or Chase"), Departments (incl. "is priority role-holder"), Seniority Levels, Categories, Countries, and Report Groups.
- **Login** — auth entry point.

## Data model
See `supabase/schema.sql` — run this once in the Supabase SQL Editor to set up all tables, seed data, and the status-history/call-attempts trigger. Migrations live in `supabase/migrations`.

## Environment variables
See `.env.local.example`.

## Ingest API (for Claude Code routines / prospect research and backfill automation)
For agents: fetch `GET /api/ingest/openapi.json` first (no auth required) — it's the live, always-current spec for exact field names and query params, generated from the actual route code rather than a doc that can go stale.

- `GET /api/ingest/reference-data` — current valid values for Departments, Seniority Levels, Segments, Source Types, Categories.
- `GET /api/ingest/organisations` — search/list organisations, including office_locations and staff. Supports mutually-exclusive targeting modes for backfill: `q` (dedup search), `gaps_only`, `missing_department`, `missing_phone`, `missing_segment`, each with its own "longest unchecked first" ordering.
- `POST /api/ingest/organisations` — create/update an Organisation plus its Office Locations and Staff in one call.
- `POST /api/ingest/staff` — add or update Staff on an existing Organisation (by id or name).
- `GET /api/ingest/test-connection` — sanity-check auth/connectivity.

All except `openapi.json` require `Authorization: Bearer <CALLFLOW_INGEST_API_KEY>`. Unrecognised fields are ignored but reported in the response's `warnings` array — agents should always check it. See `docs/ingest-api.md` for the rules and conventions behind these endpoints (why there's no delete endpoint, dedup/duplicate-staff handling, the no-placeholder-text rule, etc.) — the kind of context that belongs in prose, not an OpenAPI spec.
