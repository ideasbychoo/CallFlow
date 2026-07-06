# CallFlow

Internal calling/prospecting tool for Makerble. Built with Next.js (App Router) and Supabase.

## Pages
- **Call List** — wide, expandable/collapsible cards per Organisation, with search, sort, and filters. Also reachable per-status via the sidebar.
- **Pipeline** — kanban board, one column per Status, drag-and-drop to change status.
- **Settings** — manage Statuses, Departments, Seniority Levels, and Categories.

## Data model
See `supabase/schema.sql` — run this once in the Supabase SQL Editor to set up all tables, seed data, and the status-history/call-attempts trigger.

## Environment variables
See `.env.local.example`.

## Ingest API (for the Claude Code Routine / prospect research automation)
- `POST /api/ingest/organisations` — create/update an Organisation plus its Office Locations and Staff in one call.
- `POST /api/ingest/staff` — add Staff to an existing Organisation (by id or name).

Both require `Authorization: Bearer <CALLFLOW_INGEST_API_KEY>`.
