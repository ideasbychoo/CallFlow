-- CallFlow database schema
-- Run this once in the Supabase SQL Editor (Project > SQL Editor > New query)

-- ============ LOOKUP / SETTINGS TABLES ============

create table statuses (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null,
  created_at timestamptz not null default now()
);

create table departments (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table seniority_levels (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null default 0,
  color text,
  created_at timestamptz not null default now()
);

create table countries (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table source_types (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

-- A Source is a specific place an organisation was found (e.g. "Third Sector
-- Charity Awards", "NAVCA"). Each Source must have at least one Source Type
-- (enforced in the app) and can optionally have a Website.
create table sources (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  website text,
  created_at timestamptz not null default now()
);

create table source_source_types (
  source_id uuid not null references sources(id) on delete cascade,
  source_type_id uuid not null references source_types(id) on delete cascade,
  primary key (source_id, source_type_id)
);

-- Segments: a smaller, curated classification (unlike Categories, which had
-- become too fragmented to be meaningful).
create table segments (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

-- ============ CORE TABLES ============

create table organisations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category_id uuid references categories(id) on delete set null,
  segment_id uuid references segments(id) on delete set null,
  country text,
  similar_to_client text,
  angle text,
  notes text,
  website text,
  team_page text,
  annual_report text,
  impact_report text,
  linkedin text,
  beneficiaries integer,
  workers integer,
  status_id uuid references statuses(id) on delete set null,
  source_type_id uuid references source_types(id) on delete set null,
  source_id uuid references sources(id) on delete set null,
  date_spotted date not null default current_date,
  call_attempts integer not null default 0,
  last_interaction_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table office_locations (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references organisations(id) on delete cascade,
  location_name text not null,
  phone_number text,
  website_url text,
  availability text,
  created_at timestamptz not null default now()
);

create table staff (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references organisations(id) on delete cascade,
  department_id uuid references departments(id) on delete set null,
  seniority_id uuid references seniority_levels(id) on delete set null,
  full_name text not null,
  job_title text,
  email text,
  direct_dial text,
  linkedin text,
  background_notes text,
  bio text,
  bio_url text,
  availability_notes text,
  conversation_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table status_history (
  id uuid primary key default gen_random_uuid(),
  organisation_id uuid not null references organisations(id) on delete cascade,
  status_id uuid references statuses(id) on delete set null,
  changed_at timestamptz not null default now()
);

create table email_templates (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subject text not null default '',
  body text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_organisations_status on organisations(status_id);
create index idx_organisations_category on organisations(category_id);
create index idx_organisations_segment on organisations(segment_id);
create index idx_organisations_source_type on organisations(source_type_id);
create index idx_organisations_source on organisations(source_id);
create index idx_office_locations_org on office_locations(organisation_id);
create index idx_staff_org on staff(organisation_id);
create index idx_status_history_org on status_history(organisation_id, changed_at desc);

-- ============ SEED DATA: STATUSES (in brief's order) ============

insert into statuses (name, sort_order) values
  ('Not Contacted', 1),
  ('Calling Now', 2),
  ('Call Attempted: Dial tone', 3),
  ('Call Attempted: Voicemail', 4),
  ('Call Attempted: In Meeting', 5),
  ('Call Attempted: Work from home', 6),
  ('Email Requested', 7),
  ('1st Email Sent', 8),
  ('2nd Email (Followup) Sent', 9),
  ('Meeting Scheduling in Progress', 10),
  ('Meeting Booked', 11),
  ('Deal Created', 12),
  ('New Client Won', 13),
  ('Try Us Later', 14),
  ('Said No Thanks', 15);

-- ============ SEED DATA: DEPARTMENTS ============

insert into departments (name, sort_order) values
  ('Impact / MERL', 1),
  ('Operations', 2),
  ('Programmes / Services', 3),
  ('IT / CIO', 4),
  ('CEO / MD / ED', 5);

-- ============ SEED DATA: SENIORITY LEVELS ============

insert into seniority_levels (name, sort_order) values
  ('Head / Director', 1),
  ('Manager', 2);

-- ============ SEED DATA: SOURCE TYPES ============

insert into source_types (name, sort_order) values
  ('Awards', 1),
  ('Membership Body', 2);

-- ============ SEED DATA: SEGMENTS ============

insert into segments (name, sort_order) values
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
  ('Youth work', 33);

-- ============ ROW LEVEL SECURITY ============
-- The app's server-side API routes use the service_role key (bypasses RLS).
-- The browser only ever uses the anon key through an authenticated session,
-- so RLS below just requires a logged-in Supabase Auth user for any access.

alter table statuses enable row level security;
alter table departments enable row level security;
alter table seniority_levels enable row level security;
alter table categories enable row level security;
alter table countries enable row level security;
alter table source_types enable row level security;
alter table sources enable row level security;
alter table source_source_types enable row level security;
alter table segments enable row level security;
alter table organisations enable row level security;
alter table office_locations enable row level security;
alter table staff enable row level security;
alter table status_history enable row level security;
alter table email_templates enable row level security;

create policy "Authenticated users can do everything - statuses" on statuses
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - departments" on departments
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - seniority_levels" on seniority_levels
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - categories" on categories
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - countries" on countries
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - source_types" on source_types
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - sources" on sources
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - source_source_types" on source_source_types
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - segments" on segments
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - organisations" on organisations
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - office_locations" on office_locations
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - staff" on staff
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - status_history" on status_history
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "Authenticated users can do everything - email_templates" on email_templates
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ============ TRIGGER: auto-update updated_at ============

create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger organisations_set_updated_at
  before update on organisations
  for each row execute function set_updated_at();

create trigger staff_set_updated_at
  before update on staff
  for each row execute function set_updated_at();

create trigger email_templates_set_updated_at
  before update on email_templates
  for each row execute function set_updated_at();

-- ============ TRIGGERS: status changes -> history + last_interaction_at + call_attempts ============
-- Split into a BEFORE trigger (adjusts columns on the row being written) and an
-- AFTER trigger (logs to status_history). The history insert MUST be an AFTER
-- trigger: a BEFORE trigger fires before the row exists in `organisations`, so
-- an insert into status_history at that point would fail its foreign key check.
--
-- "Loggable" means: an actual status change on UPDATE, or an INSERT whose
-- initial status is anything other than the default 'Not Contacted' (so simply
-- adding a fresh prospect doesn't get stamped with a fake "just now" interaction).

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

create trigger organisations_after_status_change
  after insert or update on organisations
  for each row execute function organisations_after_status_change();

