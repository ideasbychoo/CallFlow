-- Migration 021: separate "checked" tracking for specialized backfill routines.
--
-- Context: the existing backfill routine's POST unconditionally bumps
-- `backfill_checked_at` on every organisation it touches, and its GET gaps
-- query prioritises by that same field. Two new specialized routines are
-- being added (find an Impact/MERL staff member; find a phone number) that
-- will touch organisations the general routine has NO gap for (e.g. an org
-- that already has staff + a Segment, but no MERL person specifically).
-- Giving each specialized routine its own tracking column means their POSTs
-- don't silently deprioritise that organisation in a DIFFERENT routine's
-- queue by touching a shared timestamp it has no business updating.

alter table organisations add column if not exists dept_focus_checked_at timestamptz;
alter table organisations add column if not exists phone_focus_checked_at timestamptz;

create index if not exists idx_organisations_dept_focus_checked on organisations(dept_focus_checked_at);
create index if not exists idx_organisations_phone_focus_checked on organisations(phone_focus_checked_at);
