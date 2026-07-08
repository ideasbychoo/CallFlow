-- Migration 010: Location Website URL, Source Types, Sources, and the
-- Organisation's Source Type / Source fields.
-- Run this in the Supabase SQL Editor.

-- ============ Office Location: Website URL ============

alter table office_locations add column if not exists website_url text;

-- ============ Source Types (a settings list, like Departments etc.) ============

create table if not exists source_types (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

alter table source_types enable row level security;

drop policy if exists "Authenticated users can do everything - source_types" on source_types;
create policy "Authenticated users can do everything - source_types" on source_types
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

insert into source_types (name, sort_order)
select v.name, v.sort_order
from (values ('Awards', 1), ('Membership Body', 2)) as v(name, sort_order)
where not exists (select 1 from source_types where name = v.name);

-- ============ Sources ============
-- A Source is a specific place an organisation was found (e.g. "Third Sector
-- Charity Awards", "NAVCA"). Each Source must have at least one Source Type
-- (enforced in the app) and can optionally have a Website.

create table if not exists sources (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  website text,
  created_at timestamptz not null default now()
);

alter table sources enable row level security;

drop policy if exists "Authenticated users can do everything - sources" on sources;
create policy "Authenticated users can do everything - sources" on sources
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create table if not exists source_source_types (
  source_id uuid not null references sources(id) on delete cascade,
  source_type_id uuid not null references source_types(id) on delete cascade,
  primary key (source_id, source_type_id)
);

alter table source_source_types enable row level security;

drop policy if exists "Authenticated users can do everything - source_source_types" on source_source_types;
create policy "Authenticated users can do everything - source_source_types" on source_source_types
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ============ Organisation: Source Type + Source ============

alter table organisations add column if not exists source_type_id uuid references source_types(id) on delete set null;
alter table organisations add column if not exists source_id uuid references sources(id) on delete set null;

create index if not exists idx_organisations_source_type on organisations(source_type_id);
create index if not exists idx_organisations_source on organisations(source_id);
