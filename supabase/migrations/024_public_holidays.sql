-- Migration 024: public holidays per country
-- Run this in the Supabase SQL Editor.
-- Warns against calling an organisation on a day its country is likely
-- closed for a national holiday.

create table if not exists public_holidays (
  id uuid primary key default gen_random_uuid(),
  country_id uuid not null references countries(id) on delete cascade,
  name text not null,
  holiday_date date not null,
  created_at timestamptz not null default now()
);

create index if not exists public_holidays_country_date_idx
  on public_holidays(country_id, holiday_date);

alter table public_holidays enable row level security;

create policy "Authenticated users can do everything - public_holidays" on public_holidays
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
