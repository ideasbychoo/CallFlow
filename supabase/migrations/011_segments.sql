-- Migration 011: Segments.
-- Categories had become too fragmented to be meaningful, so Segments is a
-- new, deliberately smaller, curated list (Adult with learning disabilities,
-- Befriending, Foodbank, etc). Categories stays as-is; Segment is additional.
-- Run this in the Supabase SQL Editor.

create table if not exists segments (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

alter table segments enable row level security;

drop policy if exists "Authenticated users can do everything - segments" on segments;
create policy "Authenticated users can do everything - segments" on segments
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

alter table organisations add column if not exists segment_id uuid references segments(id) on delete set null;

create index if not exists idx_organisations_segment on organisations(segment_id);

-- Seed the segment list from "CUSTOMERS Target Audience: Detailed information
-- about each sector" (Segments and Categories for cold outreach).
insert into segments (name, sort_order)
select v.name, v.sort_order
from (values
  ('Adult with learning disabilities', 1),
  ('Befriending', 2),
  ('Children with disabilities', 3),
  ('Child poverty', 4),
  ('Christian', 5),
  ('Church-based projects and ministries', 6),
  ('Collective Impact', 7),
  ('Community Climate Action', 8),
  ('Criminal justice', 9),
  ('Crisis grants / grants to individuals', 10),
  ('Disabilities', 11),
  ('Early-onset dementia', 12),
  ('Early Years', 13),
  ('Foodbank', 14),
  ('HAF Holiday Activities and Food programme', 15),
  ('Grant making', 16),
  ('Incubators & Accelerators', 17),
  ('International Development', 18),
  ('Legal Aid', 19),
  ('Livelihoods', 20),
  ('Local Authorities', 21),
  ('Long-term unemployment', 22),
  ('Loneliness & Isolation', 23),
  ('Boutique Management Consultancy: Teamwork & Effectiveness', 24),
  ('Mental health & wellbeing', 25),
  ('Older people', 26),
  ('Outdoor Recreation', 27),
  ('Social mobility', 28),
  ('Social Housing community projects', 29),
  ('Sport-based youth engagement', 30),
  ('Staff wellbeing consultancy', 31),
  ('Youth justice', 32),
  ('Youth work', 33)
) as v(name, sort_order)
where not exists (select 1 from segments where name = v.name);
