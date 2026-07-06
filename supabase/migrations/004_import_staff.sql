-- One-time bulk import of the consolidated Staff tab.
-- Run in the Supabase SQL Editor AFTER migrations 001-003.
-- Matches each person to an existing Organisation by exact (case-insensitive)
-- name. If no match is found, a bare new Organisation is created (name only,
-- status 'Not Contacted') so the person isn't orphaned -- these are listed at
-- the end of this file's output for your attention.

do $$
declare
  v_department_id uuid;
  v_seniority_id uuid;
  v_org_id uuid;
  v_status_id uuid;
begin
  -- Christel House South Africa :: Adri Marais
  select id into v_org_id from organisations where lower(name) = lower('Christel House South Africa') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Christel House South Africa', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Adri Marais', 'CEO', 'info@sa.christelhouse.org', NULL, NULL);

  -- Thrive at Five :: Aida Cable
  select id into v_org_id from organisations where lower(name) = lower('Thrive at Five') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Thrive at Five', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Aida Cable', 'CEO', 'info@thriveatfive.org.uk', NULL, NULL);

  -- Second Step :: Aileen
  select id into v_org_id from organisations where lower(name) = lower('Second Step') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Second Step', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Aileen', 'CEO', NULL, NULL, NULL);

  -- Khulisa (UK) :: Aisling
  select id into v_org_id from organisations where lower(name) = lower('Khulisa (UK)') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Khulisa (UK)', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Aisling', '(Data & Insight Coordinator)', NULL, NULL, NULL);

  -- IntoUniversity :: Alex Quinn
  select id into v_org_id from organisations where lower(name) = lower('IntoUniversity') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('IntoUniversity', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Alex Quinn', 'Head of Data and Impact', 'info@intouniversity.org', NULL, NULL);

  -- George House Trust :: Alex Sparrowhark
  select id into v_org_id from organisations where lower(name) = lower('George House Trust') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('George House Trust', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Alex Sparrowhark', NULL, 'alex@ght.org.uk', NULL, '16 June - Try later');

  -- YES Futures :: Ali (surname TBC)
  select id into v_org_id from organisations where lower(name) = lower('YES Futures') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('YES Futures', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Ali (surname TBC)', 'CEO (new late 2025)', 'info@yesfutures.org', NULL, NULL);

  -- Food Bank Aid :: Alyson Walsh
  select id into v_org_id from organisations where lower(name) = lower('Food Bank Aid') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Food Bank Aid', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Alyson Walsh', 'CEO (new)', NULL, NULL, NULL);

  -- Pure Innovations :: Amanda Noon
  select id into v_org_id from organisations where lower(name) = lower('Pure Innovations') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Pure Innovations', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('HR / Learning & Development') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('HR / Learning & Development', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Amanda Noon', 'Director of Learning & Development', 'amanda.noon@pureinnovations.co.uk', NULL, NULL);

  -- Active Essex Foundation :: Amelia
  select id into v_org_id from organisations where lower(name) = lower('Active Essex Foundation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Active Essex Foundation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Amelia', 'Intelligence Manager', 'ml@activeessex.org', NULL, NULL);

  -- FoodForward SA :: Andy Du Plessis
  select id into v_org_id from organisations where lower(name) = lower('FoodForward SA') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('FoodForward SA', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Andy Du Plessis', 'Managing Director', NULL, NULL, NULL);

  -- Mpilonhle :: Anele Bukhosini
  select id into v_org_id from organisations where lower(name) = lower('Mpilonhle') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Mpilonhle', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Anele Bukhosini', 'M&E Officer', 'a.bukhosini@mpilonhle.org / gugu@mpilonhle.org (domain confirmed, format inferred)', NULL, NULL);

  -- Mpilonhle :: Gugu Ngidi (alt)
  select id into v_org_id from organisations where lower(name) = lower('Mpilonhle') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Mpilonhle', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Gugu Ngidi (alt)', 'HIV & AIDS Programmes Manager', 'a.bukhosini@mpilonhle.org / gugu@mpilonhle.org (domain confirmed, format inferred)', NULL, NULL);

  -- One25 :: Anna Smith
  select id into v_org_id from organisations where lower(name) = lower('One25') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('One25', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Anna Smith', 'CEO', 'office@one25.org.uk', NULL, NULL);

  -- Spurgeons :: Annelize Mynhardt
  select id into v_org_id from organisations where lower(name) = lower('Spurgeons') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Spurgeons', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Annelize Mynhardt', 'Chief Operating Officer', NULL, NULL, NULL);

  -- Common Youth :: Arlene McLaren
  select id into v_org_id from organisations where lower(name) = lower('Common Youth') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Common Youth', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Arlene McLaren', 'CEO', NULL, NULL, NULL);

  -- ThinkForward UK :: Ashley McCaul
  select id into v_org_id from organisations where lower(name) = lower('ThinkForward UK') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('ThinkForward UK', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Ashley McCaul', 'CEO', NULL, NULL, NULL);

  -- Leeds Mind :: Ayesha Alvés-Hey
  select id into v_org_id from organisations where lower(name) = lower('Leeds Mind') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Leeds Mind', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Ayesha Alvés-Hey', 'Director of Operations', NULL, NULL, NULL);

  -- Leeds Mind :: Lucy Hancock (CEO)
  select id into v_org_id from organisations where lower(name) = lower('Leeds Mind') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Leeds Mind', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Lucy Hancock (CEO)', 'CEO', NULL, NULL, NULL);

  -- The Girls' Network :: Becca Dean MBE
  select id into v_org_id from organisations where lower(name) = lower('The Girls'' Network') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('The Girls'' Network', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Becca Dean MBE', 'CEO', NULL, NULL, NULL);

  -- NICRO :: Betzi Pierce
  select id into v_org_id from organisations where lower(name) = lower('NICRO') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('NICRO', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Betzi Pierce', 'CEO', NULL, NULL, NULL);

  -- Greenhouse Sports :: Camilla Knight
  select id into v_org_id from organisations where lower(name) = lower('Greenhouse Sports') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Greenhouse Sports', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Camilla Knight', 'Director of Impact Innovation and Engagement (joined June 2025)', 'info@greenhousesports.org', NULL, NULL);

  -- Mamelani Projects :: Carly Tanur
  select id into v_org_id from organisations where lower(name) = lower('Mamelani Projects') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Mamelani Projects', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Carly Tanur', 'Director', 'contact@mamelani.org.za', NULL, NULL);

  -- Mamelani Projects :: Leroy De Klerk
  select id into v_org_id from organisations where lower(name) = lower('Mamelani Projects') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Mamelani Projects', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Leroy De Klerk', 'Programme Manager', 'contact@mamelani.org.za', NULL, NULL);

  -- ConnectFutures :: Carys Evans
  select id into v_org_id from organisations where lower(name) = lower('ConnectFutures') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('ConnectFutures', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Carys Evans', 'Head of Programmes and Impact', NULL, 'https://www.linkedin.com/in/carys-evans-0b7bb763/', NULL);

  -- FAMSA (Families South Africa) :: CEO / M&E Lead (TBC)
  select id into v_org_id from organisations where lower(name) = lower('FAMSA (Families South Africa)') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('FAMSA (Families South Africa)', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'CEO / M&E Lead (TBC)', 'CEO', NULL, NULL, NULL);

  -- ThinkForward UK :: Charlene Theophile
  select id into v_org_id from organisations where lower(name) = lower('ThinkForward UK') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('ThinkForward UK', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Charlene Theophile', 'Director of Programmes; Impact Analyst', 'charlene.theophile@thinkforward.org.uk', NULL, NULL);

  -- Sozo Foundation :: Charlotte Tinnion
  select id into v_org_id from organisations where lower(name) = lower('Sozo Foundation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Sozo Foundation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Charlotte Tinnion', 'Monitoring and Evaluation Director', NULL, 'https://www.linkedin.com/in/charlotte-tinnion-b54a18102/', NULL);

  -- Soul City Institute :: Chiedza Chagutah
  select id into v_org_id from organisations where lower(name) = lower('Soul City Institute') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Soul City Institute', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Chiedza Chagutah', 'Head of Programmes', 'info@soulcity.org.za', NULL, NULL);

  -- Keighley Healthy Living Network :: Chloe Flaherty
  select id into v_org_id from organisations where lower(name) = lower('Keighley Healthy Living Network') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Keighley Healthy Living Network', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Chloe Flaherty', NULL, NULL, NULL, NULL);

  -- Generation UK :: Christina Powers
  select id into v_org_id from organisations where lower(name) = lower('Generation UK') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Generation UK', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Christina Powers', 'Global Director – Data and Impact', NULL, NULL, NULL);

  -- Encompass Southwest :: Claire Fisher
  select id into v_org_id from organisations where lower(name) = lower('Encompass Southwest') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Encompass Southwest', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Claire Fisher', NULL, NULL, 'https://www.linkedin.com/in/claire-fisher-097209232/', NULL);

  -- Carers Leeds :: Claire Turner
  select id into v_org_id from organisations where lower(name) = lower('Carers Leeds') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Carers Leeds', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Claire Turner', 'Chief Executive', 'info@carersleeds.org.uk', NULL, NULL);

  -- Manchester Mind :: Clare Abbott
  select id into v_org_id from organisations where lower(name) = lower('Manchester Mind') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Manchester Mind', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Clare Abbott', 'Operations Director', NULL, 'https://www.linkedin.com/in/clare-abbott-929aa554/', NULL);

  -- b:friend :: Colette Bunker
  select id into v_org_id from organisations where lower(name) = lower('b:friend') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('b:friend', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Colette Bunker', 'CEO', NULL, NULL, NULL);

  -- Generation Kenya :: Country Director (to find)
  select id into v_org_id from organisations where lower(name) = lower('Generation Kenya') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Generation Kenya', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Country Director (to find)', 'Country Director', 'generationkenya@generation.org', NULL, NULL);

  -- Keighley Healthy Living Network :: Dan Brannan
  select id into v_org_id from organisations where lower(name) = lower('Keighley Healthy Living Network') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Keighley Healthy Living Network', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dan Brannan', NULL, NULL, NULL, '16 June - Darren on leave (back 22nd June); Chloe unavailable right now');

  -- 42nd Street :: Daniel Martin-Williams
  select id into v_org_id from organisations where lower(name) = lower('42nd Street') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('42nd Street', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Daniel Martin-Williams', 'Monitoring and Evaluation Manager', NULL, 'https://www.linkedin.com/in/daniel-martin-williams-a0a926125/', NULL);

  -- George House Trust :: Darren Knight
  select id into v_org_id from organisations where lower(name) = lower('George House Trust') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('George House Trust', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Darren Knight', 'CEO', 'press@ght.org.uk', NULL, NULL);

  -- Create Strength Group :: Dave Memery
  select id into v_org_id from organisations where lower(name) = lower('Create Strength Group') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Create Strength Group', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dave Memery', 'Chief Executive', NULL, NULL, NULL);

  -- City Year UK :: Dean Thomas-Lowde
  select id into v_org_id from organisations where lower(name) = lower('City Year UK') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('City Year UK', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dean Thomas-Lowde', 'Associate Director of Programmes', 'dthomaslowde@cityyear.org.uk', NULL, NULL);

  -- Heartlines :: Derek Muller
  select id into v_org_id from organisations where lower(name) = lower('Heartlines') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Heartlines', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Derek Muller', 'COO', NULL, NULL, '17 June - Connected! Good call - email sent');

  -- London Youth :: Dimitrios Tourountsis
  select id into v_org_id from organisations where lower(name) = lower('London Youth') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('London Youth', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dimitrios Tourountsis', 'Head of Learning', NULL, NULL, NULL);

  -- Carers' Resource :: Dolly Dalton
  select id into v_org_id from organisations where lower(name) = lower('Carers'' Resource') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Carers'' Resource', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dolly Dalton', 'Service Manager / senior ops lead', NULL, NULL, NULL);

  -- Greenhouse Sports :: Don Barrell
  select id into v_org_id from organisations where lower(name) = lower('Greenhouse Sports') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Greenhouse Sports', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Don Barrell', 'CEO', 'don.barrell@greenhousesports.org', NULL, NULL);

  -- Street League :: Dougie Stevenson
  select id into v_org_id from organisations where lower(name) = lower('Street League') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Street League', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dougie Stevenson', 'CEO', 'dougie.stevenson@streetleague.co.uk', NULL, NULL);

  -- One to One Africa :: Dr Emma Chademana
  select id into v_org_id from organisations where lower(name) = lower('One to One Africa') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('One to One Africa', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dr Emma Chademana', NULL, NULL, NULL, NULL);

  -- Heartlines :: Dr Garth Japhet
  select id into v_org_id from organisations where lower(name) = lower('Heartlines') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Heartlines', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dr Garth Japhet', 'CEO / Founder', NULL, NULL, NULL);

  -- The Green House Bristol :: Dr Gemma Halliwell
  select id into v_org_id from organisations where lower(name) = lower('The Green House Bristol') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('The Green House Bristol', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dr Gemma Halliwell', 'CEO & Director', NULL, 'https://uk.linkedin.com/in/gemma-halliwell-883a6084', NULL);

  -- Spitalfields Crypt Trust :: Dr Louisa Snow
  select id into v_org_id from organisations where lower(name) = lower('Spitalfields Crypt Trust') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Spitalfields Crypt Trust', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dr Louisa Snow', 'CEO (appointed Apr 2025)', NULL, NULL, NULL);

  -- Mpilonhle :: Dr Michael Bennish
  select id into v_org_id from organisations where lower(name) = lower('Mpilonhle') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Mpilonhle', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dr Michael Bennish', 'CEO / Co-Founder', 'mpilonhle@webafrica.org.za', NULL, NULL);

  -- Cotlands :: Dr Monica Stach
  select id into v_org_id from organisations where lower(name) = lower('Cotlands') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Cotlands', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dr Monica Stach', 'CEO', 'm.stach@cotlands.co.za', NULL, NULL);

  -- EmpowaYouth :: Dumisile Le Roux
  select id into v_org_id from organisations where lower(name) = lower('EmpowaYouth') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('EmpowaYouth', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Dumisile Le Roux', 'Acting General Manager', NULL, NULL, NULL);

  -- East Lothian Foodbank (Scotland) :: Elaine (surname TBC)
  select id into v_org_id from organisations where lower(name) = lower('East Lothian Foodbank (Scotland)') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('East Lothian Foodbank (Scotland)', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Elaine (surname TBC)', 'Manager / CEO', 'info@eastlothian.foodbank.org.uk', NULL, NULL);

  -- The Access Project :: Emily
  select id into v_org_id from organisations where lower(name) = lower('The Access Project') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('The Access Project', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Emily', 'Director of Delivery', NULL, NULL, NULL);

  -- Time to Talk Befriending :: Emily Kenward
  select id into v_org_id from organisations where lower(name) = lower('Time to Talk Befriending') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Time to Talk Befriending', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Emily Kenward', 'CEO & Founder', NULL, NULL, NULL);

  -- Re-engage :: Emily Mangroves
  select id into v_org_id from organisations where lower(name) = lower('Re-engage') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Re-engage', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Emily Mangroves', 'Head of Service Delivery and Volunteering', NULL, NULL, NULL);

  -- Isle of Wight Youth Trust :: Emily Thomas
  select id into v_org_id from organisations where lower(name) = lower('Isle of Wight Youth Trust') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Isle of Wight Youth Trust', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Emily Thomas', NULL, NULL, NULL, '16 June - put thru but no pickup');

  -- Together for Mental Wellbeing :: Emma
  select id into v_org_id from organisations where lower(name) = lower('Together for Mental Wellbeing') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Together for Mental Wellbeing', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Emma', 'Director of Operations', NULL, NULL, NULL);

  -- MYTIME Young Carers :: Emma Fry
  select id into v_org_id from organisations where lower(name) = lower('MYTIME Young Carers') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('MYTIME Young Carers', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Emma Fry', 'Head of Programmes', NULL, NULL, NULL);

  -- GoodWork :: Felicity Halstead
  select id into v_org_id from organisations where lower(name) = lower('GoodWork') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('GoodWork', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Felicity Halstead', 'Founder & CEO', NULL, 'https://www.linkedin.com/in/felicityhalstead/', NULL);

  -- Inyathelo :: Feryal Domingo
  select id into v_org_id from organisations where lower(name) = lower('Inyathelo') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Inyathelo', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Feryal Domingo', 'Acting Executive Director', NULL, NULL, NULL);

  -- Future First :: Find via main number
  select id into v_org_id from organisations where lower(name) = lower('Future First') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Future First', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Find via main number', 'Head of Impact / Programmes', NULL, NULL, NULL);

  -- Heartlines :: Garth Japhet
  select id into v_org_id from organisations where lower(name) = lower('Heartlines') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Heartlines', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Garth Japhet', 'CEO', NULL, NULL, NULL);

  -- PAPYRUS UK :: Ged Flynn
  select id into v_org_id from organisations where lower(name) = lower('PAPYRUS UK') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('PAPYRUS UK', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Ged Flynn', 'Chief Executive', NULL, NULL, NULL);

  -- Re-engage :: Gemma MacNulty
  select id into v_org_id from organisations where lower(name) = lower('Re-engage') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Re-engage', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Gemma MacNulty', 'Head of Org Effectiveness', NULL, NULL, NULL);

  -- Good Work Foundation :: Gemma Thompson
  select id into v_org_id from organisations where lower(name) = lower('Good Work Foundation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Good Work Foundation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Fundraising') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Fundraising', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Gemma Thompson', 'Head of Development', 'gemma@goodworkfoundation.org', NULL, NULL);

  -- One to One Africa :: Gqibelo Dandala
  select id into v_org_id from organisations where lower(name) = lower('One to One Africa') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('One to One Africa', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Gqibelo Dandala', 'Executive Director', NULL, NULL, NULL);

  -- Brentford FC Community Sports Trust :: Hannah Barnett
  select id into v_org_id from organisations where lower(name) = lower('Brentford FC Community Sports Trust') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Brentford FC Community Sports Trust', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Hannah Barnett', 'Head of Social Education and Health Hub', 'hbarnett@brentfordfccst.com', NULL, NULL);

  -- City Gateway :: Hannah Pilkington
  select id into v_org_id from organisations where lower(name) = lower('City Gateway') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('City Gateway', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Hannah Pilkington', 'Director of Programmes', NULL, NULL, NULL);

  -- FEAST With Us :: Hannah Style
  select id into v_org_id from organisations where lower(name) = lower('FEAST With Us') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('FEAST With Us', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Hannah Style', 'Founder & Chair', NULL, NULL, '16 June - Goldie doesn''t look after impact measurement - they have an impact coordinator starting in Mid-July. Suggested emailing info@...');

  -- loveLife :: Head of Programme Measurement and Design (PMD)
  select id into v_org_id from organisations where lower(name) = lower('loveLife') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('loveLife', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Head of Programme Measurement and Design (PMD)', 'Programme Measurement and Design Unit lead (to confirm)', NULL, NULL, NULL);

  -- Carers' Resource :: Heidi Watson
  select id into v_org_id from organisations where lower(name) = lower('Carers'' Resource') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Carers'' Resource', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Heidi Watson', 'CEO', NULL, NULL, NULL);

  -- Ranyaka Community Transformation :: Heleen Pienaar
  select id into v_org_id from organisations where lower(name) = lower('Ranyaka Community Transformation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Ranyaka Community Transformation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Fundraising') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Fundraising', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Heleen Pienaar', 'Marketing Operations & Reporting Lead', NULL, NULL, NULL);

  -- Thrive at Five :: Imogen
  select id into v_org_id from organisations where lower(name) = lower('Thrive at Five') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Thrive at Five', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Imogen', 'Associate Director for Impact', 'aida.cable@thriveatfive.org.uk', NULL, NULL);

  -- Resurgo (Spear) :: Iona Ledwidge
  select id into v_org_id from organisations where lower(name) = lower('Resurgo (Spear)') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Resurgo (Spear)', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Iona Ledwidge', 'CEO (since Jan 2024)', 'iona.ledwidge@resurgo.org.uk', NULL, NULL);

  -- Healthwatch Hertfordshire :: Ivana (surname not confirmed)
  select id into v_org_id from organisations where lower(name) = lower('Healthwatch Hertfordshire') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Healthwatch Hertfordshire', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Ivana (surname not confirmed)', 'CEO', NULL, NULL, NULL);

  -- Football Beyond Borders :: Jack Reynolds
  select id into v_org_id from organisations where lower(name) = lower('Football Beyond Borders') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Football Beyond Borders', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jack Reynolds', 'Co-Founder & CEO', 'jack@footballbeyondborders.org', NULL, NULL);

  -- Ubuntu Pathways :: Jacob Lief
  select id into v_org_id from organisations where lower(name) = lower('Ubuntu Pathways') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Ubuntu Pathways', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jacob Lief', 'CEO & Founder', NULL, NULL, NULL);

  -- Ubuntu Education Fund :: Jacob Lief
  select id into v_org_id from organisations where lower(name) = lower('Ubuntu Education Fund') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Ubuntu Education Fund', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jacob Lief', 'Co-Founder & CEO', NULL, NULL, NULL);

  -- SHiFT Organisation :: James Preston
  select id into v_org_id from organisations where lower(name) = lower('SHiFT Organisation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('SHiFT Organisation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'James Preston', 'COO', 'james.preston@shiftuk.org', NULL, NULL);

  -- CDRA — Community Development Resources Association :: James Taylor
  select id into v_org_id from organisations where lower(name) = lower('CDRA — Community Development Resources Association') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('CDRA — Community Development Resources Association', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'James Taylor', 'Director', NULL, 'https://www.linkedin.com/in/james-taylor-27592913/', NULL);

  -- loveLife :: Jaymie Dookran
  select id into v_org_id from organisations where lower(name) = lower('loveLife') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('loveLife', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jaymie Dookran', 'PMD Unit Programme Measurement & Design Unit Lead', 'jdookran@lovelife.org.za', NULL, NULL);

  -- Jigsaw :: Jeff Moore
  select id into v_org_id from organisations where lower(name) = lower('Jigsaw') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Jigsaw', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jeff Moore', 'Director of Research and Evaluation', NULL, 'https://www.linkedin.com/in/jeff-moore-14/', NULL);

  -- Black Country Foodbank :: Jen Coleman
  select id into v_org_id from organisations where lower(name) = lower('Black Country Foodbank') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Black Country Foodbank', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jen Coleman', 'CEO', 'jen.coleman@blackcountryfoodbank.org.uk', 'https://www.linkedin.com/in/jen-coleman-47437764', NULL);

  -- Action Tutoring :: Jen Fox
  select id into v_org_id from organisations where lower(name) = lower('Action Tutoring') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Action Tutoring', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jen Fox', 'CEO / Head of Impact & Quality', 'hello@actiontutoring.org.uk', NULL, NULL);

  -- Re-engage :: Jenny Willott OBE
  select id into v_org_id from organisations where lower(name) = lower('Re-engage') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Re-engage', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jenny Willott OBE', 'CEO', 'jenny.willott@reengage.org.uk', NULL, NULL);

  -- Re-engage :: Jess Doyle
  select id into v_org_id from organisations where lower(name) = lower('Re-engage') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Re-engage', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jess Doyle', 'Head of Impact', 'impact@reengage.org.uk', NULL, NULL);

  -- Church Urban Fund :: Jessica Walker
  select id into v_org_id from organisations where lower(name) = lower('Church Urban Fund') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Church Urban Fund', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jessica Walker', 'Programme Manager', NULL, NULL, NULL);

  -- Leap Confronting Conflict :: Jo Broadwood
  select id into v_org_id from organisations where lower(name) = lower('Leap Confronting Conflict') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Leap Confronting Conflict', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jo Broadwood', 'CEO', 'info@leapcc.org.uk', NULL, NULL);

  -- Coram Leap Confronting Conflict :: Jo Broadwood
  select id into v_org_id from organisations where lower(name) = lower('Coram Leap Confronting Conflict') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Coram Leap Confronting Conflict', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jo Broadwood', 'Managing Director', NULL, NULL, NULL);

  -- MYTIME Young Carers :: Jo Cooper
  select id into v_org_id from organisations where lower(name) = lower('MYTIME Young Carers') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('MYTIME Young Carers', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jo Cooper', 'Lead Author, annual report', 'info@mytimeyoungcarers.org', NULL, NULL);

  -- Sported :: Jo Lloyd
  select id into v_org_id from organisations where lower(name) = lower('Sported') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Sported', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jo Lloyd', 'Head of Strategy & Insight', NULL, NULL, NULL);

  -- Resurgo (Spear) :: Jo Rice
  select id into v_org_id from organisations where lower(name) = lower('Resurgo (Spear)') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Resurgo (Spear)', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jo Rice', 'CEO', NULL, NULL, NULL);

  -- Foyer Federation :: Joel Lewis
  select id into v_org_id from organisations where lower(name) = lower('Foyer Federation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Foyer Federation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Joel Lewis', 'Chief Executive', NULL, NULL, NULL);

  -- LEAP Science and Maths Schools :: John Gilmour
  select id into v_org_id from organisations where lower(name) = lower('LEAP Science and Maths Schools') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('LEAP Science and Maths Schools', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'John Gilmour', 'Founder', NULL, NULL, NULL);

  -- MYTIME Young Carers :: Josh Parker
  select id into v_org_id from organisations where lower(name) = lower('MYTIME Young Carers') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('MYTIME Young Carers', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Josh Parker', 'Head of Programmes', 'enquiries@mytimeyoungcarers.org', NULL, NULL);

  -- Making The Leap :: Karen Tullett
  select id into v_org_id from organisations where lower(name) = lower('Making The Leap') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Making The Leap', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Karen Tullett', 'CEO', NULL, NULL, NULL);

  -- Groundswell :: Kate
  select id into v_org_id from organisations where lower(name) = lower('Groundswell') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Groundswell', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Kate', 'Services Director', NULL, NULL, NULL);

  -- Action Tutoring :: Kate Farley
  select id into v_org_id from organisations where lower(name) = lower('Action Tutoring') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Action Tutoring', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Fundraising') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Fundraising', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Kate Farley', 'Fundraising Manager', 'kate.farley@actiontutoring.org.uk', NULL, NULL);

  -- ThinkForward UK :: Kathryn Wood
  select id into v_org_id from organisations where lower(name) = lower('ThinkForward UK') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('ThinkForward UK', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Kathryn Wood', 'Impact Analyst', NULL, 'https://www.linkedin.com/in/kathryn-kat-wood/', NULL);

  -- Brotherhood of St Laurence :: Katy Cornwell
  select id into v_org_id from organisations where lower(name) = lower('Brotherhood of St Laurence') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Brotherhood of St Laurence', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Katy Cornwell', 'Head of Monitoring Evaluation and Learning', NULL, NULL, NULL);

  -- LEAP Africa :: Kehinde Ayeni
  select id into v_org_id from organisations where lower(name) = lower('LEAP Africa') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('LEAP Africa', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Kehinde Ayeni', 'Executive Director', NULL, NULL, NULL);

  -- Carers' Resource :: Kelly Rust
  select id into v_org_id from organisations where lower(name) = lower('Carers'' Resource') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Carers'' Resource', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Kelly Rust', 'CEO (new Feb 2026)', NULL, NULL, NULL);

  -- Ranyaka Community Transformation :: Kgautsang Molelekeng
  select id into v_org_id from organisations where lower(name) = lower('Ranyaka Community Transformation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Ranyaka Community Transformation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Kgautsang Molelekeng', 'National Programme Manager', NULL, NULL, NULL);

  -- Street League :: Kirsty Steven
  select id into v_org_id from organisations where lower(name) = lower('Street League') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Street League', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Kirsty Steven', 'Director of Operations', NULL, NULL, NULL);

  -- MYTIME Young Carers :: Krista Cartlidge
  select id into v_org_id from organisations where lower(name) = lower('MYTIME Young Carers') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('MYTIME Young Carers', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Krista Cartlidge', 'CEO', NULL, 'https://www.linkedin.com/in/krista-cartlidge-a720b5aa/', NULL);

  -- MYTIME Young Carers :: Krista Sharp
  select id into v_org_id from organisations where lower(name) = lower('MYTIME Young Carers') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('MYTIME Young Carers', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Krista Sharp', 'CEO', 'enquiries@mytimeyoungcarers.org', NULL, NULL);

  -- Tomorrow's People :: L Neale
  select id into v_org_id from organisations where lower(name) = lower('Tomorrow''s People') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Tomorrow''s People', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'L Neale', NULL, NULL, 'lneale@tomorrows-people.co.uk', NULL);

  -- GoodWork :: Laura Quinn
  select id into v_org_id from organisations where lower(name) = lower('GoodWork') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('GoodWork', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Laura Quinn', 'Trustee / Impact Advisor', NULL, 'https://www.laurajquinn.com/', NULL);

  -- Street League :: Lauren Archdeacon
  select id into v_org_id from organisations where lower(name) = lower('Street League') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Street League', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Lauren Archdeacon', 'Head of Compliance Systems & Data', NULL, NULL, NULL);

  -- Street League :: Ivona Voroneckaja
  select id into v_org_id from organisations where lower(name) = lower('Street League') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Street League', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Ivona Voroneckaja', 'Principal Data Scientist', NULL, NULL, NULL);

  -- Tshikululu Social Investments :: Leanne Hunter
  select id into v_org_id from organisations where lower(name) = lower('Tshikululu Social Investments') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Tshikululu Social Investments', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Leanne Hunter', 'CEO', NULL, NULL, NULL);

  -- Tshikululu Social Investments :: Lebohang Letsela
  select id into v_org_id from organisations where lower(name) = lower('Tshikululu Social Investments') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Tshikululu Social Investments', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Lebohang Letsela', 'Head of Monitoring and Evaluation', NULL, 'https://www.linkedin.com/in/lebohang-letsela-456a5916/', NULL);

  -- Grootbos Foundation :: Leigh Berg
  select id into v_org_id from organisations where lower(name) = lower('Grootbos Foundation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Grootbos Foundation', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Leigh Berg', NULL, NULL, 'https://www.linkedin.com/in/leigh-berg/', NULL);

  -- Urban Synergy :: Leila Thomas
  select id into v_org_id from organisations where lower(name) = lower('Urban Synergy') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Urban Synergy', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Leila Thomas', 'Founder & CEO', NULL, NULL, NULL);

  -- Together for Mental Wellbeing :: Linda Bryant
  select id into v_org_id from organisations where lower(name) = lower('Together for Mental Wellbeing') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Together for Mental Wellbeing', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Linda Bryant', 'CEO', NULL, NULL, NULL);

  -- Street League :: Lindsey MacDonald
  select id into v_org_id from organisations where lower(name) = lower('Street League') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Street League', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Lindsey MacDonald', 'Managing Director', NULL, NULL, NULL);

  -- Key4Life :: Lizzy Rees
  select id into v_org_id from organisations where lower(name) = lower('Key4Life') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Key4Life', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Fundraising') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Fundraising', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Lizzy Rees', 'Fundraising Director', 'lizzy.rees@key4life.org.uk', NULL, NULL);

  -- Youth Adventure Trust :: Louise Balaam
  select id into v_org_id from organisations where lower(name) = lower('Youth Adventure Trust') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Youth Adventure Trust', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Fundraising') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Fundraising', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Louise Balaam', 'Director of Fundraising & Engagement', 'mark@youthadventuretrust.org.uk', NULL, NULL);

  -- XLP :: Luke Watson
  select id into v_org_id from organisations where lower(name) = lower('XLP') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('XLP', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Luke Watson', 'CEO', 'luke@xlp.org.uk', NULL, NULL);

  -- CareerSeekers :: Lynn Anderson
  select id into v_org_id from organisations where lower(name) = lower('CareerSeekers') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('CareerSeekers', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Lynn Anderson', 'Program Director', NULL, NULL, NULL);

  -- Step by Step :: Mae
  select id into v_org_id from organisations where lower(name) = lower('Step by Step') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Step by Step', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Mae', 'Head of Foyers & Wellbeing', NULL, NULL, NULL);

  -- NACOSA :: Mari Lotvonen
  select id into v_org_id from organisations where lower(name) = lower('NACOSA') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('NACOSA', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Mari Lotvonen', 'Monitoring and Evaluation Specialist', NULL, NULL, NULL);

  -- NACOSA :: Mariette Williams
  select id into v_org_id from organisations where lower(name) = lower('NACOSA') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('NACOSA', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('HR / Learning & Development / Training') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('HR / Learning & Development / Training', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Mariette Williams', 'Training & Capacity Manager', NULL, NULL, NULL);

  -- FoodCycle :: Mark Game
  select id into v_org_id from organisations where lower(name) = lower('FoodCycle') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('FoodCycle', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Mark Game', 'CEO', NULL, NULL, NULL);

  -- Toynbee Hall :: Matt Dronfield
  select id into v_org_id from organisations where lower(name) = lower('Toynbee Hall') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Toynbee Hall', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Matt Dronfield', 'Interim CEO (from 8 Jul 2026)', NULL, 'https://www.linkedin.com/in/mattdronfield/', NULL);

  -- Grassroot Soccer South Africa :: Mbulelo Malotana
  select id into v_org_id from organisations where lower(name) = lower('Grassroot Soccer South Africa') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Grassroot Soccer South Africa', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Mbulelo Malotana', 'Managing Director SA', NULL, NULL, NULL);

  -- Keighley Healthy Living Network :: Melanie Hey
  select id into v_org_id from organisations where lower(name) = lower('Keighley Healthy Living Network') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Keighley Healthy Living Network', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Melanie Hey', 'CEO', NULL, NULL, NULL);

  -- Future Africa International :: MERL Manager (to find name)
  select id into v_org_id from organisations where lower(name) = lower('Future Africa International') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Future Africa International', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'MERL Manager (to find name)', 'MERL Manager', NULL, NULL, NULL);

  -- Khulisa (UK) :: Michael Buraimoh
  select id into v_org_id from organisations where lower(name) = lower('Khulisa (UK)') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Khulisa (UK)', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Michael Buraimoh', 'Interim CEO', 'info@khulisa.co.uk', NULL, NULL);

  -- The Access Project :: Miguel Herdade
  select id into v_org_id from organisations where lower(name) = lower('The Access Project') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('The Access Project', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Fundraising') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Fundraising', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Miguel Herdade', 'Director of Partnerships', NULL, NULL, NULL);

  -- Palace For Life Foundation :: Mike Summers
  select id into v_org_id from organisations where lower(name) = lower('Palace For Life Foundation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Palace For Life Foundation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Mike Summers', 'CEO', NULL, NULL, NULL);

  -- Trevor Noah Foundation :: Milisa Janda
  select id into v_org_id from organisations where lower(name) = lower('Trevor Noah Foundation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Trevor Noah Foundation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Milisa Janda', 'MERL Manager', NULL, NULL, NULL);

  -- Hope Worldwide South Africa :: Mmatladi
  select id into v_org_id from organisations where lower(name) = lower('Hope Worldwide South Africa') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Hope Worldwide South Africa', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Mmatladi', 'Senior MEL', NULL, 'https://www.linkedin.com/in/mmatladi-lilian-ngwako-1149aa39/', '17 June - Mmatladi in different building but my number was taken so she can call me back');

  -- Hope Worldwide South Africa :: Modjadji Madiba
  select id into v_org_id from organisations where lower(name) = lower('Hope Worldwide South Africa') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Hope Worldwide South Africa', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Modjadji Madiba', 'MERL Officer', NULL, NULL, NULL);

  -- NACOSA :: Mohamed Motala
  select id into v_org_id from organisations where lower(name) = lower('NACOSA') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('NACOSA', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Mohamed Motala', 'Executive Director', 'RFAQueries@nacosa.org.za', NULL, NULL);

  -- Cotlands :: Monica Stach
  select id into v_org_id from organisations where lower(name) = lower('Cotlands') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Cotlands', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Monica Stach', 'CEO', 'marketing@cotlands.org', NULL, NULL);

  -- Grootbos Foundation :: Natasha Bredekamp
  select id into v_org_id from organisations where lower(name) = lower('Grootbos Foundation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Grootbos Foundation', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Natasha Bredekamp', 'Project Manager Sports', 'https://www.linkedin.com/in/natasha-bredekamp-b7065956/', NULL, NULL);

  -- Working Chance :: Natasha Finlayson
  select id into v_org_id from organisations where lower(name) = lower('Working Chance') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Working Chance', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Natasha Finlayson', 'CEO', 'media@workingchance.org', NULL, NULL);

  -- The Clink Charity :: Neil Delahay
  select id into v_org_id from organisations where lower(name) = lower('The Clink Charity') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('The Clink Charity', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Neil Delahay', 'National Employment Manager', NULL, NULL, NULL);

  -- The Clink Charity :: Donna-Marie Edmonds
  select id into v_org_id from organisations where lower(name) = lower('The Clink Charity') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('The Clink Charity', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Donna-Marie Edmonds', 'CEO (new in 2025)', NULL, NULL, NULL);

  -- Sport in Mind :: Neil Harris
  select id into v_org_id from organisations where lower(name) = lower('Sport in Mind') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Sport in Mind', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Neil Harris', 'CEO / Co-founder', 'info@sportinmind.org', NULL, NULL);

  -- EveryYouth :: Nick (surname not confirmed)
  select id into v_org_id from organisations where lower(name) = lower('EveryYouth') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('EveryYouth', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Nick (surname not confirmed)', 'CEO', 'info@everyyouth.org.uk', NULL, NULL);

  -- Waves for Change :: Nicola (Nicci) Van der Merwe
  select id into v_org_id from organisations where lower(name) = lower('Waves for Change') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Waves for Change', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Nicola (Nicci) Van der Merwe', 'MERL Director', 'nicci@waves-for-change.org', NULL, NULL);

  -- Young Somerset :: Nik Harwood
  select id into v_org_id from organisations where lower(name) = lower('Young Somerset') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Young Somerset', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Nik Harwood', 'CEO', NULL, NULL, NULL);

  -- Ranyaka Community Transformation :: Nomcebo Mgaga
  select id into v_org_id from organisations where lower(name) = lower('Ranyaka Community Transformation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Ranyaka Community Transformation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Nomcebo Mgaga', 'Programme Data & Systems Coordinator', NULL, NULL, NULL);

  -- MIET Africa :: Nonhlanhla Shabalala
  select id into v_org_id from organisations where lower(name) = lower('MIET Africa') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('MIET Africa', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Nonhlanhla Shabalala', 'Monitoring and Evaluation Officer', 'n.shabalala@miet.co.za', NULL, NULL);

  -- Development Action Group (DAG) :: Nosive
  select id into v_org_id from organisations where lower(name) = lower('Development Action Group (DAG)') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Development Action Group (DAG)', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Nosive', 'Programme Lead', 'nosive@dag.org.za', NULL, NULL);

  -- Cotlands :: Nozizwe Dladla-Qwabe
  select id into v_org_id from organisations where lower(name) = lower('Cotlands') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Cotlands', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Nozizwe Dladla-Qwabe', 'Acting CEO', 'marketing@cotlands.org', NULL, NULL);

  -- loveLife :: Nthabeleng Moshoeshoe
  select id into v_org_id from organisations where lower(name) = lower('loveLife') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('loveLife', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Nthabeleng Moshoeshoe', 'CEO', 'n.moshoeshoe@lovelife.org.za', NULL, NULL);

  -- New loveLife Trust :: Nthabeleng Motsomi-Moshoeshoe
  select id into v_org_id from organisations where lower(name) = lower('New loveLife Trust') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('New loveLife Trust', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Nthabeleng Motsomi-Moshoeshoe', 'CEO', NULL, NULL, NULL);

  -- Grassroot Soccer SA :: Ntiyiso Mahumani
  select id into v_org_id from organisations where lower(name) = lower('Grassroot Soccer SA') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Grassroot Soccer SA', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Ntiyiso Mahumani', 'Interim Managing Director SA', NULL, NULL, NULL);

  -- Football Beyond Borders :: Nuh Hakim Okomi
  select id into v_org_id from organisations where lower(name) = lower('Football Beyond Borders') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Football Beyond Borders', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Nuh Hakim Okomi', 'Impact Manager & HR Coordinator', 'nhakimokomi@footballbeyondborders.org', NULL, NULL);

  -- YouthBuild South Africa :: Oupa Mbiya Tshabalala
  select id into v_org_id from organisations where lower(name) = lower('YouthBuild South Africa') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('YouthBuild South Africa', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Oupa Mbiya Tshabalala', 'Executive Director', 'infoybsa@youthbuild.org', NULL, NULL);

  -- Young Roots :: Paola Uccellari
  select id into v_org_id from organisations where lower(name) = lower('Young Roots') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Young Roots', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Paola Uccellari', 'CEO', NULL, NULL, NULL);

  -- loveLife :: Patrick Lonwabo Kulati
  select id into v_org_id from organisations where lower(name) = lower('loveLife') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('loveLife', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Patrick Lonwabo Kulati', 'CEO', NULL, NULL, NULL);

  -- XLP :: Patrick Regan
  select id into v_org_id from organisations where lower(name) = lower('XLP') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('XLP', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Patrick Regan', 'Founder', NULL, NULL, NULL);

  -- Resurgo (Spear) :: Pete (surname to confirm)
  select id into v_org_id from organisations where lower(name) = lower('Resurgo (Spear)') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Resurgo (Spear)', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Pete (surname to confirm)', 'Quality & Impact Lead', NULL, NULL, NULL);

  -- Resurgo (Spear) :: Pete Bacon
  select id into v_org_id from organisations where lower(name) = lower('Resurgo (Spear)') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Resurgo (Spear)', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Pete Bacon', 'Executive Director of Impact', NULL, NULL, NULL);

  -- FoodCycle :: Pete McCabe
  select id into v_org_id from organisations where lower(name) = lower('FoodCycle') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('FoodCycle', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Pete McCabe', 'Head of Programmes', NULL, 'https://www.linkedin.com/in/pete-mccabe-780843119/', NULL);

  -- ACTIVATE! Change Drivers :: Pitso Ntokoane
  select id into v_org_id from organisations where lower(name) = lower('ACTIVATE! Change Drivers') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('ACTIVATE! Change Drivers', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Pitso Ntokoane', 'MERL Lead', NULL, NULL, NULL);

  -- Re-engage :: Policy / Impact team
  select id into v_org_id from organisations where lower(name) = lower('Re-engage') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Re-engage', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Policy / Impact team', 'Impact & Evaluation', 'impact@reengage.org.uk', NULL, NULL);

  -- Groundswell :: Rachel Brennan
  select id into v_org_id from organisations where lower(name) = lower('Groundswell') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Groundswell', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Rachel Brennan', 'Director of Participation Progression & Change', NULL, NULL, NULL);

  -- Church Urban Fund :: Rachel Whittington
  select id into v_org_id from organisations where lower(name) = lower('Church Urban Fund') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Church Urban Fund', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Rachel Whittington', 'CEO', 'hello@cuf.org.uk', NULL, NULL);

  -- City Gateway :: Rashmi
  select id into v_org_id from organisations where lower(name) = lower('City Gateway') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('City Gateway', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Rashmi', 'Leadership Team', NULL, NULL, NULL);

  -- Grootbos Foundation :: Rebecca Dames
  select id into v_org_id from organisations where lower(name) = lower('Grootbos Foundation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Grootbos Foundation', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Rebecca Dames', 'Conservation & Research', 'https://www.linkedin.com/in/rebecca-dames-ab8aa11aa/', NULL, NULL);

  -- One to One Africa :: Rhodwell Shamu
  select id into v_org_id from organisations where lower(name) = lower('One to One Africa') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('One to One Africa', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Rhodwell Shamu', 'Impact lead', NULL, NULL, NULL);

  -- Sonke Gender Justice :: RME Unit Manager (see team page)
  select id into v_org_id from organisations where lower(name) = lower('Sonke Gender Justice') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Sonke Gender Justice', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'RME Unit Manager (see team page)', 'Research Monitoring & Evaluation Unit Manager', 'hr@genderjustice.org.za', NULL, NULL);

  -- Sport 4 Life UK :: Rob Wells
  select id into v_org_id from organisations where lower(name) = lower('Sport 4 Life UK') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Sport 4 Life UK', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Rob Wells', 'COO', 'contact@sport4life.org.uk', NULL, NULL);

  -- Church Urban Fund :: Rob Wickham
  select id into v_org_id from organisations where lower(name) = lower('Church Urban Fund') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Church Urban Fund', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Rob Wickham', 'CEO', 'kate.mulkern@cuf.org.uk', NULL, NULL);

  -- Rise Up UK :: Roman Dibden
  select id into v_org_id from organisations where lower(name) = lower('Rise Up UK') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Rise Up UK', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Roman Dibden', 'Head of Charity (new)', NULL, NULL, NULL);

  -- Oasis Project :: Sam Price
  select id into v_org_id from organisations where lower(name) = lower('Oasis Project') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Oasis Project', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Sam Price', 'CEO', NULL, NULL, NULL);

  -- Power2 :: Samantha Marcus
  select id into v_org_id from organisations where lower(name) = lower('Power2') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Power2', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Samantha Marcus', 'Director of Services', NULL, 'https://www.linkedin.com/in/samantha-marcus-373256147/', NULL);

  -- Power2 :: Jennifer Smith
  select id into v_org_id from organisations where lower(name) = lower('Power2') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Power2', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Programmes / Services') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Programmes / Services', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Jennifer Smith', 'Head of Operations', NULL, NULL, NULL);

  -- Uhambo Foundation :: Sarah Driver-Jowitt
  select id into v_org_id from organisations where lower(name) = lower('Uhambo Foundation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Uhambo Foundation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Sarah Driver-Jowitt', 'Director', 'sarah@uhambofoundation.org', NULL, NULL);

  -- IDAS – Independent Domestic Abuse Services :: Sarah Hill
  select id into v_org_id from organisations where lower(name) = lower('IDAS – Independent Domestic Abuse Services') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('IDAS – Independent Domestic Abuse Services', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Sarah Hill', 'CEO', NULL, NULL, NULL);

  -- Sported :: Sarah Kaye
  select id into v_org_id from organisations where lower(name) = lower('Sported') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Sported', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Sarah Kaye', 'CEO', 'info@sported.org.uk', NULL, NULL);

  -- Open Road :: Sarah Wright
  select id into v_org_id from organisations where lower(name) = lower('Open Road') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Open Road', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Sarah Wright', 'CEO', NULL, NULL, NULL);

  -- New Horizon Youth Centre :: Shelagh O'Connor
  select id into v_org_id from organisations where lower(name) = lower('New Horizon Youth Centre') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('New Horizon Youth Centre', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Shelagh O''Connor', 'CEO', 'info@nhyouthcentre.org.uk', NULL, NULL);

  -- 42nd Street :: Simone Spray
  select id into v_org_id from organisations where lower(name) = lower('42nd Street') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('42nd Street', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Simone Spray', 'CEO', 'theteam@42ndstreet.org.uk', NULL, NULL);

  -- ACTIVATE! Change Drivers :: Siphelele Chirwa
  select id into v_org_id from organisations where lower(name) = lower('ACTIVATE! Change Drivers') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('ACTIVATE! Change Drivers', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Siphelele Chirwa', 'CEO', NULL, NULL, NULL);

  -- FoodCycle :: Sophie Tebbetts
  select id into v_org_id from organisations where lower(name) = lower('FoodCycle') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('FoodCycle', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Sophie Tebbetts', 'CEO', 'sophie@foodcycle.org.uk', NULL, NULL);

  -- Mason Foundation :: Stephen (founder — full name on website)
  select id into v_org_id from organisations where lower(name) = lower('Mason Foundation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Mason Foundation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Stephen (founder — full name on website)', 'Founder', 'hr.recruit@masonfoundation.co.uk', NULL, NULL);

  -- Christians Against Poverty :: Stewart McCulloch
  select id into v_org_id from organisations where lower(name) = lower('Christians Against Poverty') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Christians Against Poverty', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Stewart McCulloch', 'CEO (Bradford HQ)', NULL, NULL, NULL);

  -- Befriending Networks :: Susan Hunter
  select id into v_org_id from organisations where lower(name) = lower('Befriending Networks') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Befriending Networks', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Susan Hunter', 'CEO', 'susan@befriending.co.uk', NULL, NULL);

  -- The Tomorrow Trust :: Taryn Rae
  select id into v_org_id from organisations where lower(name) = lower('The Tomorrow Trust') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('The Tomorrow Trust', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Taryn Rae', NULL, NULL, NULL, NULL);

  -- TLG – Transforming Lives for Good :: Tim Morfin
  select id into v_org_id from organisations where lower(name) = lower('TLG – Transforming Lives for Good') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('TLG – Transforming Lives for Good', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Tim Morfin', 'Founder & CEO', NULL, NULL, NULL);

  -- Literacy Pirates :: Triona Larkin
  select id into v_org_id from organisations where lower(name) = lower('Literacy Pirates') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Literacy Pirates', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Fundraising') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Fundraising', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Triona Larkin', 'Head of Fundraising', NULL, NULL, NULL);

  -- Carers Leeds :: V.H.
  select id into v_org_id from organisations where lower(name) = lower('Carers Leeds') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Carers Leeds', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'V.H.', 'CEO', 'info@carersleeds.org.uk', NULL, NULL);

  -- The Bread and Butter Thing :: Vic Harper
  select id into v_org_id from organisations where lower(name) = lower('The Bread and Butter Thing') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('The Bread and Butter Thing', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Vic Harper', 'Chief Operating Officer', NULL, 'https://www.linkedin.com/in/victoriaharper1', NULL);

  -- StreetGames :: Vicky Weir
  select id into v_org_id from organisations where lower(name) = lower('StreetGames') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('StreetGames', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Vicky Weir', 'Head of Trusts & Foundations', 'vicky.weir@streetgames.org', NULL, NULL);

  -- Recycling Lives :: Victoria Blakeman
  select id into v_org_id from organisations where lower(name) = lower('Recycling Lives') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Recycling Lives', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Victoria Blakeman', 'CEO', NULL, NULL, NULL);

  -- FoodCycle :: Victoria Meier
  select id into v_org_id from organisations where lower(name) = lower('FoodCycle') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('FoodCycle', v_status_id, current_date) returning id into v_org_id;
  end if;
  v_department_id := null;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Victoria Meier', NULL, NULL, NULL, NULL);

  -- Ranyaka Community Transformation :: William Bila
  select id into v_org_id from organisations where lower(name) = lower('Ranyaka Community Transformation') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Ranyaka Community Transformation', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'William Bila', 'CEO / Co-Founder', 'admin@ranyaka.co.za', 'https://za.linkedin.com/company/ranyaka-community-transformation', NULL);

  -- Ilifa Labantwana :: Zaheera Mohamed
  select id into v_org_id from organisations where lower(name) = lower('Ilifa Labantwana') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Ilifa Labantwana', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Zaheera Mohamed', 'CEO', 'info@ilifalabantwana.co.za', NULL, NULL);

  -- GirlCode :: Zandile Mkwanazi
  select id into v_org_id from organisations where lower(name) = lower('GirlCode') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('GirlCode', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('CEO / MD / ED') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('CEO / MD / ED', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Head / Director' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Zandile Mkwanazi', 'Chairwoman', NULL, NULL, NULL);

  -- GoodWork :: Zoë Morgan
  select id into v_org_id from organisations where lower(name) = lower('GoodWork') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('GoodWork', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Zoë Morgan', NULL, NULL, NULL, NULL);

  -- The Green House Bristol :: Zoe Perran
  select id into v_org_id from organisations where lower(name) = lower('The Green House Bristol') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('The Green House Bristol', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Operations') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Operations', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  v_seniority_id := null;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Zoe Perran', NULL, NULL, NULL, NULL);

  -- Chance to Shine :: Zoya Zia
  select id into v_org_id from organisations where lower(name) = lower('Chance to Shine') limit 1;
  if v_org_id is null then
    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
    insert into organisations (name, status_id, date_spotted) values ('Chance to Shine', v_status_id, current_date) returning id into v_org_id;
  end if;
  select id into v_department_id from departments where lower(name) = lower('Impact / MERL') limit 1;
  if v_department_id is null then
    insert into departments (name, sort_order) values ('Impact / MERL', (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;
  end if;
  select id into v_seniority_id from seniority_levels where name = 'Manager' limit 1;
  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)
  values (v_org_id, v_department_id, v_seniority_id, 'Zoya Zia', 'Senior Impact and Evaluation Officer', NULL, NULL, NULL);

end $$;
