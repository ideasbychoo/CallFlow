-- Migration 019: push the "gaps_only" filter/sort down into Postgres.
-- Run in the Supabase SQL Editor.
--
-- Context: fixing the gaps_only+limit ordering bug (see the ingest API route
-- change) means the endpoint can no longer apply `limit` before filtering --
-- but doing the filter/sort in JS instead means fetching EVERY organisation
-- row, with its full nested staff/office_locations payload, on every single
-- gaps_only call. That gets slower and more expensive (more DB egress, more
-- JSON to parse, more tokens for the calling agent to read) as the
-- organisations table grows -- exactly the scaling concern flagged in
-- conversation. This view lets the gaps_only branch of the route do the
-- filtering, sorting, AND limiting in the database, and only fetch the full
-- nested payload for the small number of organisations actually being
-- picked up this run.

create or replace view ingest_gaps_view as
select
  o.id,
  o.backfill_checked_at,
  (o.segment_id is null) as no_segment,
  coalesce(sc.staff_count, 0) as staff_count
from organisations o
left join (
  select organisation_id, count(*) as staff_count
  from staff
  group by organisation_id
) sc on sc.organisation_id = o.id;

-- The view has no RLS of its own -- it inherits from the underlying tables'
-- policies, and the ingest API only ever queries it with the service_role
-- key (which bypasses RLS), same as every other ingest query.
