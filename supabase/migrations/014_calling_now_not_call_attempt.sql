-- Migration 014: explicitly exclude "Calling Now" from the call-attempts
-- count (it was already excluded implicitly, since it doesn't match
-- 'Call Attempted:%' or 'Email Requested' -- this just makes the intent
-- explicit and future-proofs it against any status renaming).
-- Run this in the Supabase SQL Editor.

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
    if new_status_name <> 'Calling Now'
       and (new_status_name like 'Call Attempted:%' or new_status_name = 'Email Requested') then
      new.call_attempts = coalesce(new.call_attempts, 0) + 1;
    end if;
  end if;

  return new;
end;
$$ language plpgsql;
