-- Migration 023: checked-at tracking for the new Segment backfill routine.
--
-- Same reasoning as migration 021 (dept_focus_checked_at / phone_focus_checked_at):
-- this routine targets organisations that already have staff/phone/etc (so
-- they're invisible to the general backfill routine's gaps_only queue) but
-- are missing a Segment specifically. It needs its own tracking column so
-- its POSTs don't silently deprioritise an organisation in a DIFFERENT
-- routine's queue.

alter table organisations add column if not exists segment_focus_checked_at timestamptz;
create index if not exists idx_organisations_segment_focus_checked on organisations(segment_focus_checked_at);
