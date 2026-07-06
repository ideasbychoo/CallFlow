-- Migration 005: fix the status-change trigger.
-- Run this in the Supabase SQL Editor BEFORE re-running 004_import_staff.sql.
--
-- The original trigger (organisations_status_change) was a single BEFORE
-- INSERT/UPDATE trigger that also inserted into status_history. That fails:
-- a BEFORE trigger fires before the row exists in `organisations`, so the
-- foreign key check on status_history.organisation_id fails for every insert
-- of an organisation with a non-'Not Contacted' status (this is what you hit).
--
-- This migration replaces it with two triggers: a BEFORE trigger that only
-- adjusts columns on the row itself (last_interaction_at, call_attempts), and
-- an AFTER trigger that logs to status_history once the row genuinely exists.

drop trigger if exists organisations_status_change on organisations;
drop function if exists handle_organisation_status_change();

create or replace function organisations_before_status_change()
returns trigger as $$
declare
  new_status_name text;
  is_loggable boolean;
begin
  select name into new_status_name from statuses where id = new.status_id;

  is_loggable := (tg_op = 'UPDATE' and new.status_id is distinct from old.status_id)
              or (tg_op = 'INSERT' and new.status_id is not null and coalesce(new_status_name, '') <> 'Not Contacted');

  if is_loggable then
    new.last_interaction_at = now();
    if new_status_name like 'Call Attempted:%' then
      new.call_attempts = coalesce(new.call_attempts, 0) + 1;
    end if;
  end if;

  return new;
end;
$$ language plpgsql;

drop trigger if exists organisations_before_status_change on organisations;
create trigger organisations_before_status_change
  before insert or update on organisations
  for each row execute function organisations_before_status_change();

create or replace function organisations_after_status_change()
returns trigger as $$
declare
  new_status_name text;
  is_loggable boolean;
begin
  select name into new_status_name from statuses where id = new.status_id;

  is_loggable := (tg_op = 'UPDATE' and new.status_id is distinct from old.status_id)
              or (tg_op = 'INSERT' and new.status_id is not null and coalesce(new_status_name, '') <> 'Not Contacted');

  if is_loggable then
    insert into status_history (organisation_id, status_id, changed_at)
    values (new.id, new.status_id, now());
  end if;

  return new;
end;
$$ language plpgsql;

drop trigger if exists organisations_after_status_change on organisations;
create trigger organisations_after_status_change
  after insert or update on organisations
  for each row execute function organisations_after_status_change();
