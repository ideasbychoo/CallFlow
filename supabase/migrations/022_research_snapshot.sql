-- Migration 022: "Call or Chase" status flag, "Priority role-holder"
-- department flag, and a lightweight view backing the new Research page.
--
-- Performance approach: the Research page needs three tables (per-segment,
-- per-country, and a segment x country cross-tab) built from compound
-- conditions (has phone, has priority staff, is call-or-chase status) across
-- every organisation. Doing this as ~264 separate COUNT queries (one per
-- cross-tab cell) would be slow and wasteful. Instead, this migration adds a
-- single view that computes three cheap booleans per organisation ONCE;
-- the app fetches that view in one query (currently ~485 rows, a handful of
-- columns each) and does all the grouping/counting in memory. That scales
-- comfortably into the low thousands of organisations without needing to
-- revisit this approach.

alter table statuses add column if not exists is_call_or_chase boolean not null default false;
alter table departments add column if not exists is_priority_role_holder boolean not null default false;

-- Supports the has_priority_staff EXISTS check in the view below. Not
-- needed at the current ~485 organisations, but keeps that check fast as
-- the table grows (organisation_id was already indexed; department_id
-- wasn't).
create index if not exists idx_staff_department on staff(department_id);

-- Note on security_invoker: Supabase generally recommends `security_invoker
-- = true` on views over RLS-enabled tables, so the view enforces the
-- CALLING user's row-level policies rather than the view owner's. That
-- wasn't used here because every table this view touches already has the
-- same blanket "authenticated users can do everything" policy -- there's no
-- per-row restriction to preserve -- and in testing, security_invoker
-- caused the view to return zero rows in some execution contexts that
-- aren't running with a full Supabase Auth session (e.g. direct SQL tools),
-- since RLS then evaluates against whatever role that connection actually
-- is rather than bypassing it. Using the plain default (definer-style) view
-- avoids that fragility with no real reduction in security given the
-- existing policy is already fully permissive for any authenticated user.

create or replace view research_org_flags as
select
  o.id,
  o.segment_id,
  o.country,
  o.status_id,
  coalesce((select st.is_call_or_chase from statuses st where st.id = o.status_id), false) as is_call_or_chase,
  exists (
    select 1 from office_locations ol
    where ol.organisation_id = o.id and ol.phone_number is not null and ol.phone_number <> ''
  ) as has_phone,
  exists (
    select 1 from staff s
    join departments d on d.id = s.department_id
    where s.organisation_id = o.id and d.is_priority_role_holder = true
  ) as has_priority_staff
from organisations o;
