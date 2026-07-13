-- Migration 016: track when an organisation was last touched by an ingest
-- write, so the backfill routine can prioritise never-checked or
-- longest-untouched records first, rather than repeatedly re-researching the
-- same organisations that turned out to have no findable staff.
-- Run this in the Supabase SQL Editor.

alter table organisations add column if not exists backfill_checked_at timestamptz;

create index if not exists idx_organisations_backfill_checked on organisations(backfill_checked_at);
