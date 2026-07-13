-- Migration 017: default status on insert, a proper (non-name-hardcoded) way
-- to mark which statuses count as a call attempt, and "report groups" for
-- configurable Reporting summary columns like "Chatted".
-- Run this in the Supabase SQL Editor.

-- ============ 1. Default status = lowest sort_order status, on insert ============
-- Also replaces the previous name-hardcoded call-attempt logic ('Email
-- Requested' etc), which silently breaks whenever a status gets renamed --
-- exactly what just happened. See part 2 below.

create or replace function organisations_before_status_change()
returns trigger as $$
declare
  new_status_name text;
  new_counts_as_call_attempt boolean;
  is_loggable boolean;
begin
  if tg_op = 'INSERT' and new.status_id is null then
    select id into new.status_id from statuses order by sort_order limit 1;
  end if;

  select name, counts_as_call_attempt into new_status_name, new_counts_as_call_attempt
  from statuses where id = new.status_id;

  is_loggable := (tg_op = 'UPDATE' and new.status_id is distinct from old.status_id)
              or (tg_op = 'INSERT' and new.status_id is not null and coalesce(new_status_name, '') <> 'Not Contacted');

  if is_loggable then
    new.last_interaction_at = now();
    if coalesce(new_counts_as_call_attempt, false) then
      new.call_attempts = coalesce(new.call_attempts, 0) + 1;
    end if;
  end if;

  return new;
end;
$$ language plpgsql;

-- ============ 2. counts_as_call_attempt flag on statuses ============

alter table statuses add column if not exists counts_as_call_attempt boolean not null default false;

update statuses set counts_as_call_attempt = true
where name in (
  'Call Attempted: Dial tone',
  'Call Attempted: Voicemail',
  'Call Attempted: In Meeting',
  'Call Attempted: Work from home',
  'Chatted: Email Requested',
  'Call Attempt: Email Needed'
);

-- ============ 3. Report groups (configurable Reporting summary columns) ============

create table if not exists report_groups (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

alter table report_groups enable row level security;
drop policy if exists "Authenticated users can do everything - report_groups" on report_groups;
create policy "Authenticated users can do everything - report_groups" on report_groups
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create table if not exists report_group_statuses (
  report_group_id uuid not null references report_groups(id) on delete cascade,
  status_id uuid not null references statuses(id) on delete cascade,
  primary key (report_group_id, status_id)
);

alter table report_group_statuses enable row level security;
drop policy if exists "Authenticated users can do everything - report_group_statuses" on report_group_statuses;
create policy "Authenticated users can do everything - report_group_statuses" on report_group_statuses
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

insert into report_groups (name, sort_order)
select 'Chatted', 1
where not exists (select 1 from report_groups where name = 'Chatted');

insert into report_group_statuses (report_group_id, status_id)
select (select id from report_groups where name = 'Chatted'), s.id
from statuses s
where s.name in ('Chatted: Email Requested', 'Chatted: Meeting Scheduling in Progress', 'Chatted: Said No Thanks')
on conflict do nothing;
