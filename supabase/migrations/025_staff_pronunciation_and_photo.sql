-- Migration 025: add Pronunciation and Image URL fields to staff.
-- Run this in the Supabase SQL Editor.

alter table staff add column if not exists pronunciation text;
alter table staff add column if not exists image_url text;
