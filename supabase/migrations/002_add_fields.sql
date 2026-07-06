-- Migration 002: new fields requested after initial launch
-- Run this once in the Supabase SQL Editor. Safe to run even if some
-- columns already exist (uses IF NOT EXISTS throughout).

alter table organisations add column if not exists linkedin text;
alter table organisations add column if not exists beneficiaries integer;
alter table organisations add column if not exists workers integer;

alter table office_locations add column if not exists availability text;

alter table staff add column if not exists job_title text;
