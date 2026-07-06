-- Migration 006: category colours
-- Run in the Supabase SQL Editor.

alter table categories add column if not exists color text;

-- Initial heuristic colour assignment, grouping thematically-similar categories
-- toward the same colour family. Purely a starting point -- fully editable
-- afterwards from Settings.
update categories set color = case
  when lower(name) like '%youth%' or lower(name) like '%education%' or lower(name) like '%mentoring%' or lower(name) like '%tutoring%' or lower(name) like '%literacy%' or lower(name) like '%school%'
    then '#3b82f6'      -- blue: youth / education
  when lower(name) like '%mental health%' or lower(name) like '%wellbeing%' or lower(name) like '%health%' or lower(name) like '%hiv%' or lower(name) like '%disability%'
    then '#14b8a6'      -- teal: health & wellbeing
  when lower(name) like '%carer%' or lower(name) like '%befriend%' or lower(name) like '%older people%'
    then '#a855f7'      -- purple: carers / befriending
  when lower(name) like '%food%' or lower(name) like '%poverty%' or lower(name) like '%foodbank%'
    then '#f97316'      -- orange: food / poverty
  when lower(name) like '%faith%'
    then '#eab308'      -- amber: faith-based
  when lower(name) like '%employ%' or lower(name) like '%economic%' or lower(name) like '%financial%' or lower(name) like '%enterprise%'
    then '#22c55e'      -- green: employment / economic
  when lower(name) like '%sport%' or lower(name) like '%cricket%'
    then '#ec4899'      -- pink: sport
  when lower(name) like '%community%' or lower(name) like '%development%' or lower(name) like '%capacity%'
    then '#0ea5e9'      -- sky: community development
  when lower(name) like '%justice%' or lower(name) like '%crime%' or lower(name) like '%rehabilitation%' or lower(name) like '%reoffending%'
    then '#64748b'      -- slate: justice / rehabilitation
  when lower(name) like '%housing%' or lower(name) like '%homeless%'
    then '#8b5cf6'      -- violet: housing / homelessness
  when lower(name) like '%gender%' or lower(name) like '%abuse%' or lower(name) like '%domestic%'
    then '#dc2626'      -- red: gender-based violence / abuse
  when lower(name) like '%child%' or lower(name) like '%ecd%' or lower(name) like '%early%'
    then '#06b6d4'      -- cyan: early childhood
  else '#94a3b8'         -- default: neutral slate/gray
end
where color is null;
