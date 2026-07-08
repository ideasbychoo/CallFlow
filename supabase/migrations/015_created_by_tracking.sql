-- Migration 015: "created_by" transparency tracking.
-- Records who/what created each record: a person's email (for records added
-- via the CallFlow app UI, from their logged-in Supabase Auth session), or
-- an explicit agent label (for anything written via the ingest API or by an
-- assistant running SQL directly), e.g. 'agent:claude-code-prospecting-routine'.
-- Run this in the Supabase SQL Editor.

alter table organisations add column if not exists created_by text;
alter table staff add column if not exists created_by text;

-- Best-effort backfill for existing rows, based on known timestamps.
update organisations set created_by = 'import:initial-bulk-import'
where created_by is null and created_at = '2026-07-06 22:57:42.428584+00';

update organisations set created_by = 'agent:unknown (pre-dates created_by tracking)'
where created_by is null and created_at = '2026-07-06 23:57:17.825437+00';
