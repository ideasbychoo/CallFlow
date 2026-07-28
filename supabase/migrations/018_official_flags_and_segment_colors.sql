-- Migration 018: "Official" flag for Departments/Seniority Levels, and colours for Segments.
-- Run in the Supabase SQL Editor.
--
-- Context: the prospecting/backfill agents were previously allowed to
-- auto-create new Departments and Seniority Levels via the ingest API
-- whenever a name didn't match exactly, which fragmented both lists into
-- dozens of near-duplicate, low-value entries. The ingest API no longer does
-- this (see the /api/ingest/organisations and /api/ingest/staff route
-- changes) -- agents must now match an existing entry (same strict rule
-- Segments already used) and assign the closest fit.
--
-- The new is_official flag lets Matt mark which entries in the (now
-- cluttered) existing lists are the "real" canonical ones. It defaults to
-- false for everything, including existing rows, since we can't safely infer
-- which of the current entries are legitimate. The 5 seeded Departments and
-- 2 seeded Seniority Levels from the original schema are marked official as
-- a reasonable starting point -- adjust freely from Settings.

alter table departments add column if not exists is_official boolean not null default false;
alter table seniority_levels add column if not exists is_official boolean not null default false;

update departments set is_official = true
where name in ('Impact / MERL', 'Operations', 'Programmes / Services', 'IT / CIO', 'CEO / MD / ED');

update seniority_levels set is_official = true
where name in ('Head / Director', 'Manager');

-- ============ Segment colours ============

alter table segments add column if not exists color text;

-- Initial heuristic colour assignment (same approach as migration 006 for
-- categories), purely a starting point -- fully editable from Settings.
update segments set color = case
  when lower(name) like '%youth%' or lower(name) like '%education%' or lower(name) like '%early%' or lower(name) like '%haf %' or lower(name) like '%children%'
    then '#3b82f6'      -- blue: youth / education / early years
  when lower(name) like '%mental health%' or lower(name) like '%wellbeing%' or lower(name) like '%dementia%' or lower(name) like '%disabilit%'
    then '#14b8a6'      -- teal: health & wellbeing / disabilities
  when lower(name) like '%befriending%' or lower(name) like '%older people%' or lower(name) like '%loneliness%'
    then '#a855f7'      -- purple: befriending / older people
  when lower(name) like '%foodbank%' or lower(name) like '%crisis grants%' or lower(name) like '%grant making%'
    then '#f97316'      -- orange: food / grants
  when lower(name) like '%christian%' or lower(name) like '%church%'
    then '#eab308'      -- amber: faith-based
  when lower(name) like '%employ%' or lower(name) like '%livelihoods%' or lower(name) like '%incubator%' or lower(name) like '%consultancy%'
    then '#22c55e'      -- green: employment / economic / consultancy
  when lower(name) like '%sport%'
    then '#ec4899'      -- pink: sport
  when lower(name) like '%community%' or lower(name) like '%collective impact%' or lower(name) like '%climate%' or lower(name) like '%social housing%'
    then '#0ea5e9'      -- sky: community / collective impact / climate
  when lower(name) like '%justice%' or lower(name) like '%legal aid%'
    then '#64748b'      -- slate: justice / legal aid
  when lower(name) like '%international development%'
    then '#8b5cf6'      -- violet: international development
  when lower(name) like '%local authorities%' or lower(name) like '%unemployment%' or lower(name) like '%social mobility%'
    then '#dc2626'      -- red: local authorities / unemployment / mobility
  else '#94a3b8'         -- default: neutral slate/gray
end
where color is null;
