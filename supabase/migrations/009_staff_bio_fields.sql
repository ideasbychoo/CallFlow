-- Migration 009: add Bio and Bio URL fields to staff.
-- Run this in the Supabase SQL Editor.

alter table staff add column if not exists bio text;
alter table staff add column if not exists bio_url text;
