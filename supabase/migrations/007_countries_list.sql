-- Migration 007: managed Countries list
-- Run in the Supabase SQL Editor.
-- Country stays a free-text column on organisations (no data migration needed),
-- but the UI now offers a dropdown backed by this table instead of free entry,
-- same pattern as Categories/Departments/Seniority Levels.

create table if not exists countries (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

alter table countries enable row level security;

create policy "Authenticated users can do everything - countries" on countries
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- Seed with the countries already in use in your data.
insert into countries (name, sort_order)
select distinct country, row_number() over (order by country)
from organisations
where country is not null and country <> ''
on conflict (name) do nothing;
