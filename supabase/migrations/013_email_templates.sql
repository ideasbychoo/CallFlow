-- Migration 013: Email Templates.
-- Run this in the Supabase SQL Editor.

create table if not exists email_templates (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subject text not null default '',
  body text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table email_templates enable row level security;

drop policy if exists "Authenticated users can do everything - email_templates" on email_templates;
create policy "Authenticated users can do everything - email_templates" on email_templates
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create trigger email_templates_set_updated_at
  before update on email_templates
  for each row execute function set_updated_at();
