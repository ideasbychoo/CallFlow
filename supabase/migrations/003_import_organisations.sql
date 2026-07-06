-- One-time bulk import of consolidated prospect research.
-- Run in the Supabase SQL Editor AFTER migrations 001 and 002.
-- Disables the status-change trigger during import so historical
-- Date spotted / Call Attempts aren't double-counted or overwritten,
-- then re-enables it and manually inserts matching status_history rows.

alter table organisations disable trigger organisations_status_change;

do $$
declare
  v_category_id uuid;
  v_status_id uuid;
  v_org_id uuid;
begin
  -- 42nd Street
  select id into v_category_id from categories where lower(name) = lower('Mental health commissioned') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental health commissioned', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('42nd Street', v_category_id, 'United Kingdom', 'Commissioned mental health for 11-25 year olds. Manchester. 57 staff. NHS commissioned + grants. Multi-funder accountability. Tracks individual young people through therapeutic services. 87-91 Great Ancoats Street Manchester M4 5AG. Manchester charity for 11–25 yr olds. Income ~£4M. Co-op Foundation + NHS commissioned. Simone has led for 10+ years. Call first — ask who owns their impact data. Beneficiary journeys across multiple touchpoints = strong demo moment. Dedicated M&E Manager — clearest buying signal in this batch. Commissioned by Greater Manchester / MOPAC / NHS. Tracks named young people''s mental health journeys across multiple service lines. Youth Endowment Fund evaluation partner. New 2025–2030 business plan = growth phase = window for new data tools. CEO Simone Spray publicly committed to evidence-led design.', 'https://www.42ndstreet.org.uk', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/about-the-register-of-charities/-/charity-details/702687', NULL, 'https://uk.linkedin.com/company/42nd-street-charity', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044161 228 7321', NULL);

  -- Access Sport
  select id into v_category_id from categories where lower(name) = lower('Community sport / disadvantaged children') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community sport / disadvantaged children', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Access Sport', v_category_id, 'United Kingdom', 'Builds community sports clubs in disadvantaged areas for children. CIO structure = faster procurement. Find staff contacts at accesssport.org.uk/pages/faqs/category/staff — look for Head of Programmes or CEO.', 'https://www.accesssport.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-27'::date, 0, null)
  returning id into v_org_id;

  -- ACET Africa
  select id into v_category_id from categories where lower(name) = lower('Economic transformation / youth employment') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Economic transformation / youth employment', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('ACET Africa', v_category_id, 'Ghana', 'African Center for Economic Transformation. 30+ professionals in Accra. Youth Employment and Skills focus with M&E culture. Works across Africa including SA. Annual reports available at above URL. Start with email to info@ then follow up with call. +233 (0)302 760 441.', 'https://acetforafrica.org', NULL, 'https://acetforafrica.org/governance/annual-reports/', NULL, NULL, v_status_id, '2026-06-27'::date, 0, null)
  returning id into v_org_id;

  -- ACH
  select id into v_category_id from categories where lower(name) = lower('Refugee & migrant integration') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Refugee & migrant integration', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('ACH', v_category_id, 'United Kingdom', 'Bristol & West Midlands base; 130+ staff; 1581 people supported in 2025; uses HACT social value methodology. Individual journey tracking (housing → employment) is core to their model.', 'https://ach.org.uk/about-us/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-30'::date, 0, null)
  returning id into v_org_id;

  -- Action Tutoring
  select id into v_category_id from categories where lower(name) = lower('Youth education / social mobility') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth education / social mobility', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Action Tutoring', v_category_id, 'United Kingdom', 'CEO Jen Fox previously headed their Impact & Quality function she understands M&E deeply. Working with EEF on RCT 2025-26. Victoria SW1W 0DH. Ask to speak to their impact/data lead.', 'https://actiontutoring.org.uk/', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/5027464', 'https://actiontutoring.org.uk/wp-content/uploads/2025/05/Action-Tutoring-Impact-report-23-24-2.pdf', 'https://www.linkedin.com/company/action-tutoring', v_status_id, '2026-06-14'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+44 (0)300 102 0094', NULL);

  -- ACTIVATE Leadership
  select id into v_category_id from categories where lower(name) = lower('Youth civic leadership') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth civic leadership', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('ACTIVATE Leadership', v_category_id, 'South Africa', '~5000 young change drivers nationally. Multiple programme tracks. Multiple funders including Atlantic Fellows. Suite 13 Unit 23B Waverley Business Park Kotzee Rd Observatory Cape Town 7925. Dedicated M&E team Pitso Ntokoane is the MEL Lead.', 'https://activateleadership.co.za', NULL, NULL, NULL, 'https://za.linkedin.com/company/activate-change-drivers', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 447 2556', NULL);

  -- ACTIVATE! Change Drivers
  select id into v_category_id from categories where lower(name) = lower('Youth leadership & social development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth leadership & social development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('ACTIVATE! Change Drivers', v_category_id, 'South Africa', '4500+ young leaders trained across all 9 SA provinces. Pitso Ntokoane is the MERL Lead direct buyer. Joburg (Parktown) office. Strong M&E culture evidenced by dedicated MERL role.', 'https://activatechangedrivers.co.za/', NULL, NULL, NULL, 'https://za.linkedin.com/company/activate-change-drivers', v_status_id, '2026-06-14'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 (0)87 820 4873', NULL);

  -- Active Essex Foundation
  select id into v_category_id from categories where lower(name) = lower('Youth sport / physical activity') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth sport / physical activity', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Active Essex Foundation', v_category_id, 'United Kingdom', 'Charity reg 1166665; dedicated M&E toolkit for community sport providers; works with marginalised young people; Sport England funded. Amelia owns their intelligence & evaluation work direct in.', 'https://www.activeessexfoundation.org/meet-the-team/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-30'::date, 0, null)
  returning id into v_org_id;

  -- AFK
  select id into v_category_id from categories where lower(name) = lower('Disability / Youth Employment') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Disability / Youth Employment', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('AFK', v_category_id, 'United Kingdom', 'Disabled young people 14–25. 2024–25 Impact Report published June 2026. All voluntary funding (no government grants). 101 Pentonville Road, London N1 9LF.', 'https://www.afkcharity.org/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-29'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '004420 8347 8111', NULL);

  -- akt
  select id into v_category_id from categories where lower(name) = lower('Youth homelessness') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth homelessness', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('akt', v_category_id, 'United Kingdom', '791 LGBTQ+ young people supported 2023-24. 2025 national research report with 3 universities. 4 offices (London, Bristol, Manchester, Newcastle). HQ: 19-20 Parr St London N1 7GW.', 'https://www.akt.org.uk/our-team/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-28'::date, 0, null)
  returning id into v_org_id;

  -- b:friend
  select id into v_category_id from categories where lower(name) = lower('Befriending / older people') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Befriending / older people', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('b:friend', v_category_id, 'United Kingdom', '£350k income; 729 active friendships; 37,108 volunteering hours; South Yorkshire / Derbyshire / Notts; CEO role just advertised. Jenny Pitman is Programmes Manager.', 'https://letsbfriend.org.uk', NULL, 'https://letsbfriend.org.uk/2026/05/05/bfriend-annual-report-2025/', NULL, 'https://www.linkedin.com/company/b-friend', v_status_id, '2026-06-16'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00447523 698530', NULL);

  -- Baytree Centre
  select id into v_category_id from categories where lower(name) = lower('Youth Mentoring') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Mentoring', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Baytree Centre', v_category_id, 'United Kingdom', 'Youth Mentoring Report 2024/25 published. 1:1 mentoring for young women in Brixton/SW London. Track distance-travelled. Small/mid charity.', 'https://baytreecentre.org', NULL, 'https://baytreecentre.org/wp-content/uploads/2025/01/Youth-Mentoring-Report-2024-V-3.0.pdf', NULL, NULL, v_status_id, '2026-06-18'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044207 733 5428', NULL);

  -- Befriending Networks
  select id into v_category_id from categories where lower(name) = lower('Befriending / Umbrella Network') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Befriending / Umbrella Network', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Befriending Networks', v_category_id, 'United Kingdom', 'Scotland-based umbrella for befriending services. Has own programmes + membership network. Annual Report 2024–25 published.', 'https://befriending.co.uk/', NULL, 'https://befriending.co.uk/wp-content/uploads/2025/09/Extract-of-Befriending-Networks-Annual-Report-2024-25.pdf', NULL, 'https://uk.linkedin.com/company/befriending-networks-ltd', v_status_id, '2026-06-20'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044131 261 8799', NULL);

  -- Big Brothers Big Sisters South Africa
  select id into v_category_id from categories where lower(name) = lower('Youth mentoring (1:1 relationships)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth mentoring (1:1 relationships)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Big Brothers Big Sisters South Africa', v_category_id, 'South Africa', 'Long-term 1:1 mentoring for children 6–18. Match tracking + relationship longevity + outcome measurement is core to their model.', 'https://www.bbbssa.org.za', NULL, NULL, NULL, 'https://www.linkedin.com/company/big-brothers-big-sisters-of-south-africa', v_status_id, '2026-06-19'::date, 0, null)
  returning id into v_org_id;

  -- Birmingham City Mission
  select id into v_category_id from categories where lower(name) = lower('Faith-based community programmes') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Faith-based community programmes', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Birmingham City Mission', v_category_id, 'United Kingdom', 'Multiple programme streams (youth, children, homeless day centre, elderly) all tracking named individuals. 36 paid staff + 150 volunteers. £1.6m income (FY Mar 2024).', 'https://birminghamcitymission.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-10'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044121 766 6603', NULL);

  -- Black Country Foodbank
  select id into v_category_id from categories where lower(name) = lower('Food poverty') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Food poverty', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Black Country Foodbank', v_category_id, 'United Kingdom', 'CEO email confirmed. Independent (not Trussell) foodbank. 2024 Impact Report published. Referral-based. Currently recruiting Deputy CEO/Ops Manager.', 'https://blackcountryfoodbank.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-10'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00441384 671250', 'Mon–Fri 9am–1pm');

  -- Brentford FC Community Sports Trust
  select id into v_category_id from categories where lower(name) = lower('Sport / education / health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Sport / education / health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Brentford FC Community Sports Trust', v_category_id, 'United Kingdom', '72 staff. Has dedicated M&E team (Graham Goodden Sr Manager + Vikrant Dogra Views Officer). Hannah oversees the impact hub. CEO: Lee Doyle. Revenue ~£6-8M.', 'https://www.brentfordfccst.com', NULL, 'https://register-of-charities.charitycommission.gov.uk/charity-details/?regId=1112784&subid=0', NULL, 'https://uk.linkedin.com/company/brentford-fc-community-sports-trust', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00442083267030', NULL);

  -- Brotherhood of St Laurence
  select id into v_category_id from categories where lower(name) = lower('Employment / poverty relief') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Employment / poverty relief', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Brotherhood of St Laurence', v_category_id, 'Australia', 'Major Australian social welfare charity Melbourne. Katy Cornwell Head of MEL. Executive Director: Travers McLeod. NYEB evaluation programme 2025-2027 underway.', 'https://www.bsl.org.au', NULL, 'https://annual-report-2023.bsl.org.au', NULL, 'https://au.linkedin.com/company/brotherhood-of-st-laurence', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;

  -- Can-Survive UK
  select id into v_category_id from categories where lower(name) = lower('Cancer Support – Diverse Communities') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Cancer Support – Diverse Communities', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Can-Survive UK', v_category_id, 'United Kingdom', '2026 GSK IMPACT winner. Manchester. Supports culturally diverse communities with cancer. Individual journey tracking across support services.', 'Find website via Charity Commission search', NULL, NULL, NULL, NULL, v_status_id, '2026-06-11'::date, 0, null)
  returning id into v_org_id;

  -- Cape Mental Health
  select id into v_category_id from categories where lower(name) = lower('Mental health / psychosocial disability') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental health / psychosocial disability', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Cape Mental Health', v_category_id, 'South Africa', 'Cape Town-based. Commissioned by Dept of Social Development. Individual beneficiary tracking for people with intellectual + psychosocial disabilities.', 'https://www.capementalhealth.co.za', NULL, 'https://capementalhealth.co.za/wp-content/uploads/2022/01/CMH-Annual-Review-2020-21-Single-pages_compressed-2.pdf', NULL, 'https://www.linkedin.com/company/cape-mental-health', v_status_id, '2026-06-19'::date, 0, null)
  returning id into v_org_id;

  -- CareerSeekers
  select id into v_category_id from categories where lower(name) = lower('Refugee Employment') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Refugee Employment', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('CareerSeekers', v_category_id, 'Australia', 'Sydney. Helps humanitarian entrants into professional careers. Suite 1 Level 2 131 Clarence St Sydney. Tracks employment outcomes per participant.', 'https://careerseekers.org.au/about', NULL, 'https://www.acnc.gov.au/charity/7dea545fdedf92ab6fa6a8463d7fdd81', NULL, 'https://au.linkedin.com/company/careerseekers-new-australian-internship-program', v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;

  -- Carers First
  select id into v_category_id from categories where lower(name) = lower('Carer Support') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Carer Support', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Carers First', v_category_id, 'United Kingdom', 'SE England and London. Supports unpaid carers tracks carer journeys over time, funder accountability. Commissioned by councils + ICBs.', 'https://www.carersfirst.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-18'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044300 303 1555', NULL);

  -- Carers Leeds
  select id into v_category_id from categories where lower(name) = lower('Befriending / Carers Support') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Befriending / Carers Support', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Carers Leeds', v_category_id, 'United Kingdom', '34 staff; supports unpaid adult and parent carers across Leeds. Tracks carers (beneficiaries) over time. Published detailed 2024/25 impact report. Multiple funders. Income ~£1–2m. Advice line Mon–Thu 9–5 / Fri 9–4:30.', 'https://www.carersleeds.org.uk', NULL, 'https://www.carersleeds.org.uk/app/uploads/2025/11/Carers-Leeds-Impact-Report-20242025-Digital-Version.pdf', NULL, 'info@carersleeds.org.uk', v_status_id, '2026-06-17'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044113 246 8338', 'Advice line Mon–Thu 9–5 / Fri 9–4:30');

  -- Carers Plus Yorkshire
  select id into v_category_id from categories where lower(name) = lower('Carers Support (North Yorkshire)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Carers Support (North Yorkshire)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Carers Plus Yorkshire', v_category_id, 'United Kingdom', 'Independent carer support charity for North Yorkshire. Young and adult carers. Right ICP size. Check annual income on Charity Commission before calling.', 'https://www.carersplus.net/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-29'::date, 0, null)
  returning id into v_org_id;

  -- Carers Trust Solihull
  select id into v_category_id from categories where lower(name) = lower('Carers support (Midlands)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Carers support (Midlands)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Carers Trust Solihull', v_category_id, 'United Kingdom', 'Has 2024-25 Annual Report and Impact Report; carers individual tracking; commissioned by Solihull MBC and NHS. Part of wider Carers Trust network.', 'https://solihullcarers.org/about-us/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-30'::date, 0, null)
  returning id into v_org_id;

  -- Carers' Resource
  select id into v_category_id from categories where lower(name) = lower('Carers Support') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Carers Support', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Carers'' Resource', v_category_id, 'United Kingdom', 'Active M&E Officer vacancy. New CEO since April 2024. Young and adult carers across Bradford / Harrogate / Selby / Craven. 15 Park View Court, St Paul''s Road, Shipley BD18 3DZ.', 'https://www.carersresource.org/', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/1049278', NULL, 'https://www.linkedin.com/company/carers-resource', v_status_id, '2026-06-29'::date, 0, null)
  returning id into v_org_id;

  -- Caritas Diocese of Salford
  select id into v_category_id from categories where lower(name) = lower('Faith / Poverty Relief') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Faith / Poverty Relief', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Caritas Diocese of Salford', v_category_id, 'United Kingdom', 'Catholic social action across Greater Manchester and Lancashire. Poverty relief + refugee employment + community support. Charity reg 1125808.', 'https://www.caritassalford.org.uk/about/', NULL, 'https://www.caritassalford.org.uk/media/Caritas-Annual-Report-2024-25-F_WEB.pdf', NULL, NULL, v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0161 817 2250', NULL);

  -- Catch22
  select id into v_category_id from categories where lower(name) = lower('Youth / criminal justice / education') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth / criminal justice / education', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Catch22', v_category_id, 'United Kingdom', 'National charity: alternative education + apprenticeships + youth employability + justice. Multi-commissioner environment. Worth a conversation.', 'https://www.catch-22.org.uk', NULL, NULL, NULL, 'https://www.linkedin.com/company/catch22', v_status_id, '2026-06-19'::date, 0, null)
  returning id into v_org_id;

  -- CDRA — Community Development Resources Association
  select id into v_category_id from categories where lower(name) = lower('NGO capacity building') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('NGO capacity building', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('CDRA — Community Development Resources Association', v_category_id, 'South Africa', 'SA civil society capacity building organisation. James Taylor well-known in SA M&E. Cape Town-based.', 'https://cdra.org.za', NULL, NULL, NULL, NULL, v_status_id, '2026-06-24'::date, 0, null)
  returning id into v_org_id;

  -- Chance to Shine
  select id into v_category_id from categories where lower(name) = lower('Cricket / Youth Sport') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Cricket / Youth Sport', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Chance to Shine', v_category_id, 'United Kingdom', '626000 young people per year. Just hired Data & Insights Officer. Commissioned independent academic evaluation.', 'https://chancetoshine.org/', NULL, 'https://chancetoshine.org/wp-content/uploads/2025/03/Chance-to-Shine-Impact-Report-2025.pdf', NULL, NULL, v_status_id, '2026-06-26'::date, 0, null)
  returning id into v_org_id;

  -- Childline South Africa
  select id into v_category_id from categories where lower(name) = lower('Child Protection / Counselling') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Child Protection / Counselling', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Childline South Africa', v_category_id, 'South Africa', 'Child protection NGO. 300000+ calls annually. National 24-hour counselling service. Tracks child cases, referrals and follow-up across all provinces.', 'https://www.childlinesa.org.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-20'::date, 0, null)
  returning id into v_org_id;

  -- Christel House South Africa
  select id into v_category_id from categories where lower(name) = lower('Education') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Education', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Christel House South Africa', v_category_id, 'South Africa', 'Education charity Cape Town. ~1500 students from disadvantaged communities. CEO won 2025 Mail and Guardian Power of Women Award. Swallowcliffe Drive Ottery Cape Town 7800.', 'https://sa.christelhouse.org', NULL, 'https://issuu.com/sa.christelhouse/docs/christel_house_report_2024_final_digital', NULL, 'https://za.linkedin.com/company/christel-house-south-africa', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 704 9400', NULL);

  -- Christians Against Poverty
  select id into v_category_id from categories where lower(name) = lower('Faith-based / Debt Relief') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Faith-based / Debt Relief', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Christians Against Poverty', v_category_id, 'United Kingdom', 'Leading UK debt counselling charity, Bradford HQ. Tracks individual clients through debt-free journey. Merged with Community Money Advice March 2026. Stewart McCulloch joined Jan 2024.', 'https://capuk.org/', NULL, NULL, NULL, 'https://www.linkedin.com/company/christians-against-poverty', v_status_id, '2026-06-20'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00441274 760720', NULL);

  -- Church Urban Fund
  select id into v_category_id from categories where lower(name) = lower('Faith-based / Community / Poverty') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Faith-based / Community / Poverty', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Church Urban Fund', v_category_id, 'United Kingdom', '2025 Impact Report published Feb 2026. Funds + supports local churches doing community work across England. 22,000+ individuals through Places of Welcome. 821 locations. Kate Mulkern handles fundraising. Jessica Walker manages programmes.', 'https://cuf.org.uk/', NULL, 'https://cuf.org.uk/what-we-do/impact-report-2025', NULL, 'https://www.linkedin.com/company/church-urban-fund', v_status_id, '2026-06-20'::date, 0, null)
  returning id into v_org_id;

  -- City Gateway
  select id into v_category_id from categories where lower(name) = lower('Youth Training & Employment') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Training & Employment', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('City Gateway', v_category_id, 'United Kingdom', '25 years old. Trains young people 16–24 in Tower Hamlets into work and apprenticeships. Internal Data & Performance Manager. Ask for Hannah directly.', 'https://www.citygateway.org.uk', NULL, NULL, NULL, 'https://uk.linkedin.com/company/city-gateway', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '004420 7538 5015', NULL);

  -- City Year UK
  select id into v_category_id from categories where lower(name) = lower('Youth mentoring in schools') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth mentoring in schools', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('City Year UK', v_category_id, 'United Kingdom', '200a Pentonville Road London N1 9JP. Hired Impact Officer (Izzi) Aug 2025. Dean is the programmes lead. £2.6m income. CEO post currently vacant.', 'https://cityyear.org.uk/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-14'::date, 0, null)
  returning id into v_org_id;

  -- Common Youth
  select id into v_category_id from categories where lower(name) = lower('Sexual Health – Young People') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Sexual Health – Young People', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Common Youth', v_category_id, 'United Kingdom', '2025 GSK IMPACT winner. Belfast. Walk-in sexual health clinics for young people under 25. NHS-commissioned.', 'https://commonyouth.com/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-11'::date, 0, null)
  returning id into v_org_id;

  -- ConnectFutures
  select id into v_category_id from categories where lower(name) = lower('Youth exploitation prevention') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth exploitation prevention', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('ConnectFutures', v_category_id, 'United Kingdom', 'Head of Programmes and Impact title = exact ICP buyer. Commissioned school-based and community programmes. CIC not charity; verify revenue.', 'https://www.connectfutures.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-10'::date, 0, null)
  returning id into v_org_id;

  -- Coram Leap Confronting Conflict
  select id into v_category_id from categories where lower(name) = lower('Youth Work / Conflict Resolution') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Work / Conflict Resolution', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Coram Leap Confronting Conflict', v_category_id, 'United Kingdom', 'National charity training young people in conflict resolution skills. Joined Coram Group August 2025. Laura Johnson is Director of Delivery. Income ~£1–3m.', 'https://coramleapconfrontingconflict.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-17'::date, 0, null)
  returning id into v_org_id;

  -- Cotlands
  select id into v_category_id from categories where lower(name) = lower('Early Childhood Development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Early Childhood Development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Cotlands', v_category_id, 'South Africa', '86-year-old NPO. 114 staff. Toy libraries and ECD programmes reaching 40,000+ children. Named M&E Coordinator role reporting to COO. Head of Business Development: Irene Chetty. Monica Stach (CEO). 910 Bram Fischer Towers 20 Albert St Marshalltown Johannesburg 2001.', 'https://www.cotlands.org', NULL, 'https://iar2025.cotlands.org.za/', 'https://www.cotlands.org.za/', 'https://za.linkedin.com/company/cotlands', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 11 683 7200', NULL);

  -- Create Strength Group
  select id into v_category_id from categories where lower(name) = lower('Substance Misuse Recovery') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Substance Misuse Recovery', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Create Strength Group', v_category_id, 'United Kingdom', '2026 GSK IMPACT winner. Bradford. 3365 meeting attendances tracked. Commissioned Lived Experience Evaluation project. Bradford Council commissioner.', 'https://createstrengthgroup.org/about-us/', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/5172411', NULL, NULL, v_status_id, '2026-06-11'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00447759 053653', NULL);

  -- Depaul UK
  select id into v_category_id from categories where lower(name) = lower('Youth homelessness commissioned') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth homelessness commissioned', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Depaul UK', v_category_id, 'United Kingdom', 'Youth homelessness. LA-commissioned + grant funded. Tracks 16-25 year olds through housing and support services. Check 2024 income against ICP range.', 'https://depaul.org.uk', NULL, 'https://www.depaul.org.uk/wp-content/uploads/2025/09/Depaul-UK-Annual-Report-2024.pdf', NULL, 'https://uk.linkedin.com/company/depaul-uk', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;

  -- Development Action Group (DAG)
  select id into v_category_id from categories where lower(name) = lower('Housing / urban community development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Housing / urban community development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Development Action Group (DAG)', v_category_id, 'South Africa', 'Fighting poverty and inequality since 1986. Housing and urban development programmes across South Africa. nosive@dag.org.za cited as programme contact.', 'https://www.dag.org.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-23'::date, 0, null)
  returning id into v_org_id;

  -- Dorset Mind
  select id into v_category_id from categories where lower(name) = lower('Mental Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Dorset Mind', v_category_id, 'United Kingdom', 'Regional independent Mind charity delivering commissioned services in Dorset. Tracks individual clients across multiple programmes. Find CEO via dorsetmind.uk', 'https://dorsetmind.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-25'::date, 0, null)
  returning id into v_org_id;

  -- East Lothian Foodbank (Scotland)
  select id into v_category_id from categories where lower(name) = lower('Food poverty') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Food poverty', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('East Lothian Foodbank (Scotland)', v_category_id, 'United Kingdom', 'Independent Scottish foodbank (not Trussell). Tracks referrals + named individuals. Recruiting Service Co-ordinator + Referrals Co-ordinator 2024/25.', 'https://eastlothian.foodbank.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-10'::date, 0, null)
  returning id into v_org_id;

  -- Edinburgh Young Carers
  select id into v_category_id from categories where lower(name) = lower('Young Carers') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Young Carers', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Edinburgh Young Carers', v_category_id, 'United Kingdom', '13 staff + volunteers. Supports young carers in Edinburgh. Well-established (since 1999). Check staff team page for current CEO name.', 'https://www.youngcarers.org.uk', NULL, NULL, NULL, 'https://uk.linkedin.com/company/edinburgh-young-carers', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;

  -- Education Africa
  select id into v_category_id from categories where lower(name) = lower('Youth education') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth education', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Education Africa', v_category_id, 'South Africa', 'Poverty alleviation through youth education. Multiple impact projects reaching thousands of young people. Likely reporting to international grant funders.', 'https://educationafrica.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-24'::date, 0, null)
  returning id into v_org_id;

  -- ELRU – Early Learning Resource Unit
  select id into v_category_id from categories where lower(name) = lower('Early childhood development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Early childhood development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('ELRU – Early Learning Resource Unit', v_category_id, 'South Africa', 'Cape Town (19 Flamingo Cres / 7780); 33 staff; ~$4M revenue; established 1978; works in 3 provinces.', 'https://www.elru.co.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-30'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 762 7500', NULL);

  -- EmpowaYouth
  select id into v_category_id from categories where lower(name) = lower('Youth Economic Inclusion') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Economic Inclusion', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('EmpowaYouth', v_category_id, 'South Africa', 'National platform across 9 provinces. Youth aged 18–34. Skills development + job opportunities + entrepreneurship support. Simphiwe Masiza is Founder/CEO. Dumisile owns operations.', 'https://empowayouth.co.za/', NULL, 'https://empowayouth.co.za/impact/', NULL, NULL, v_status_id, '2026-06-15'::date, 0, null)
  returning id into v_org_id;

  -- Encompass Southwest
  select id into v_category_id from categories where lower(name) = lower('Community Health – Trauma Support') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community Health – Trauma Support', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Encompass Southwest', v_category_id, 'United Kingdom', '2026 GSK IMPACT winner. South West England. Find their website and verify Claire Fisher''s role.', 'Find website via Charity Commission search', NULL, NULL, NULL, NULL, v_status_id, '2026-06-11'::date, 0, null)
  returning id into v_org_id;

  -- Equal Education
  select id into v_category_id from categories where lower(name) = lower('Education advocacy + direct programmes') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Education advocacy + direct programmes', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Equal Education', v_category_id, 'South Africa', 'Isivivana Centre 2nd Floor 8 Mzala Street Khayelitsha 7784 Cape Town. Education advocacy NGO with direct school-level programmes. M&E sits within Operations Manager role.', 'https://equaleducation.org.za/', NULL, 'https://equaleducation.org.za/annual-reports-and-audited-financial-statements/', NULL, NULL, v_status_id, '2026-06-23'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 021 387 0022', NULL);

  -- EveryYouth
  select id into v_category_id from categories where lower(name) = lower('Youth homelessness') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth homelessness', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('EveryYouth', v_category_id, 'United Kingdom', '£1m income; 9 staff + 20 partner charities; 16–25 yr olds facing homelessness. Faye Edmondson = Head of Fundraising & Comms. Kristina Hedderley-Perez = Director of Public Engagement. Actively building new data & research tools.', 'https://everyyouth.org.uk', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/5207562', NULL, NULL, v_status_id, '2026-06-16'::date, 0, null)
  returning id into v_org_id;

  -- Extern
  select id into v_category_id from categories where lower(name) = lower('Young People / Families') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Young People / Families', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Extern', v_category_id, 'United Kingdom', 'NI + ROI. 12600+ children young people and families supported annually. Commissioned services. NI charity reg 105869.', 'https://www.extern.org/pages/category/young-people-and-families', NULL, 'https://www.charitycommissionni.org.uk/charity-details/?regId=105869', NULL, NULL, v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;

  -- FAMSA (Families South Africa)
  select id into v_category_id from categories where lower(name) = lower('Family Counselling / Mental Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Family Counselling / Mental Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('FAMSA (Families South Africa)', v_category_id, 'South Africa', 'National network of family and relationship counselling centres. Individual client tracking across sessions essential. Find CEO at famsa.org.za', 'https://famsa.org.za', NULL, NULL, NULL, NULL, v_status_id, '2026-06-25'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 11 975 7106', NULL);

  -- FEAST With Us
  select id into v_category_id from categories where lower(name) = lower('Food Poverty / Community Meals') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Food Poverty / Community Meals', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Try Us Later' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('FEAST With Us', v_category_id, 'United Kingdom', 'Actively hiring M&E Lead (deadline April 2026 — call to check if still open). London (Camden & Redbridge).', 'https://feastwithus.org.uk', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/5098318', NULL, NULL, v_status_id, '2026-06-11'::date, 1, '2026-06-11'::timestamptz)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '004420 7871 0094', NULL);
  insert into status_history (organisation_id, status_id, changed_at) values (v_org_id, v_status_id, '2026-06-11'::timestamptz);

  -- Fitted for Work
  select id into v_category_id from categories where lower(name) = lower('Women''s Employment') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Women''s Employment', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Fitted for Work', v_category_id, 'Australia', 'Melbourne. 40000+ women helped since 2005. Tracks beneficiary journeys from intake to employment.', 'https://www.fittedforwork.org/about-us/', NULL, 'https://www.acnc.gov.au/', NULL, 'https://au.linkedin.com/company/fittedforwork', v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;

  -- Food Bank Aid
  select id into v_category_id from categories where lower(name) = lower('Foodbank Network') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Foodbank Network', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Food Bank Aid', v_category_id, 'United Kingdom', 'New CEO. Supports 30+ foodbank partners with regular deliveries. Platform could serve the whole network.', 'https://foodbankaid.org.uk', NULL, NULL, NULL, 'https://www.linkedin.com/company/food-bank-aid', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;

  -- FoodCycle
  select id into v_category_id from categories where lower(name) = lower('Foodbanks & poverty relief') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Foodbanks & poverty relief', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('FoodCycle', v_category_id, 'United Kingdom', 'New CEO (Apr 2025) from The Bread and Butter Thing. Tracks volunteers AND beneficiaries across UK hubs. 82 Tanner St SE1 3GN. Income £1m–£10m.', 'https://foodcycle.org.uk/', NULL, 'https://foodcycle.org.uk/wp-content/uploads/2025/04/Foodcycle-Impact-Report-2024-FINAL-compressed.pdf', NULL, NULL, v_status_id, '2026-06-14'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+44 (0)20 7729 2775', NULL);

  -- FoodForward SA
  select id into v_category_id from categories where lower(name) = lower('Food Security') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Food Security', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('FoodForward SA', v_category_id, 'South Africa', 'Food rescue and distribution, 2,000+ beneficiary organisations reached. Track food parcels and beneficiaries. Find Head of Monitoring or COO.', 'https://www.foodforwardsa.org', NULL, NULL, NULL, 'https://za.linkedin.com/company/foodforwardsa', v_status_id, '2026-06-18'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 932 6126', NULL);

  -- Football Beyond Borders
  select id into v_category_id from categories where lower(name) = lower('Education through sport') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Education through sport', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Football Beyond Borders', v_category_id, 'United Kingdom', 'Football to support disadvantaged young people 10-24 in deprived London communities. Impact Manager already in post. Unit 4 Warwick House Overton Road London SW9 7JP. Impetus portfolio charity. Nuh Hakim Okomi is the M&E buyer. 60 staff. Revenue ~£3m.', 'https://www.footballbeyondborders.org', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/5043801/accounts-and-annual-returns', NULL, 'https://uk.linkedin.com/company/footballbeyondborders', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00447969523766', NULL);

  -- Foyer Federation
  select id into v_category_id from categories where lower(name) = lower('Youth Housing / Collective Impact') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Housing / Collective Impact', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Foyer Federation', v_category_id, 'United Kingdom', 'Membership org for ~35 Foyer providers across the UK. 2025–30 strategy just launched. Income ~£800k–1.5m. Manchester. Siobhan Cunningham (Head of Dev & Partnerships).', 'https://foyer.net', NULL, NULL, NULL, NULL, v_status_id, '2026-06-17'::date, 0, null)
  returning id into v_org_id;

  -- Fresh Futures
  select id into v_category_id from categories where lower(name) = lower('Youth Employability & Family Support') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Employability & Family Support', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Fresh Futures', v_category_id, 'United Kingdom', '110 staff, 150 volunteers. Employability programme for 18–26 year olds plus family support services. Founded 1974. Based in Kirklees.', 'https://freshfutures.org.uk', NULL, NULL, NULL, 'https://www.facebook.com/FreshFutures', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00441484 519988', NULL);

  -- Future Africa International
  select id into v_category_id from categories where lower(name) = lower('Youth leadership / development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth leadership / development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Future Africa International', v_category_id, 'South Africa', 'Youth leadership climate action entrepreneurship. SA plus Namibia and Mozambique. MERL Manager role recently advertised. Norwood Johannesburg.', 'https://futureafricainternational.org', NULL, NULL, NULL, 'https://za.linkedin.com/company/future-africa-international-fai', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 60 727 8195', NULL);

  -- Future First
  select id into v_category_id from categories where lower(name) = lower('Youth social mobility / education alumni') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth social mobility / education alumni', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Future First', v_category_id, 'United Kingdom', 'Tracks alumni of state schools over time. 86-90 Paul Street London EC2A 4NE. Call and ask for their impact or evaluation lead.', 'https://futurefirst.org.uk/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-14'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+44 (0)20 7239 8933', NULL);

  -- Future Frontiers
  select id into v_category_id from categories where lower(name) = lower('Youth employability / career mentoring') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth employability / career mentoring', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Future Frontiers', v_category_id, 'United Kingdom', 'Career mentoring for disadvantaged young people; aspirations and work readiness; London-based; tracks outcomes across year-long programme journeys.', 'https://futurefrontiers.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-16'::date, 0, null)
  returning id into v_org_id;

  -- Generation Kenya
  select id into v_category_id from categories where lower(name) = lower('Youth employability') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth employability', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Generation Kenya', v_category_id, 'Kenya', '35000+ young people trained since 2015. 85% job placement rate. West End Towers 4th Floor Muthangari Drive Nairobi.', 'https://kenya.generation.org', NULL, NULL, NULL, 'https://ke.linkedin.com/company/generation-kenya', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;

  -- Generation South Africa
  select id into v_category_id from categories where lower(name) = lower('Youth employment') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth employment', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Generation South Africa', v_category_id, 'South Africa', 'SA chapter of Generation global org; tracks individual youth employment outcomes and 2-yr career journeys; Johannesburg.', 'https://southafrica.generation.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-16'::date, 0, null)
  returning id into v_org_id;

  -- Generation UK
  select id into v_category_id from categories where lower(name) = lower('Youth Employability') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Employability', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Generation UK', v_category_id, 'United Kingdom', 'McKinsey-backed youth employment charity. Published detailed 2025 impact report. London (100 Museum St WC1A 1PB). Income ~£3–5m. Ideal entry point via Christina.', 'https://uk.generation.org', NULL, 'https://uk.generation.org/wp-content/uploads/2026/04/GenerationUK_Impact_Report_2025.pdf', NULL, NULL, v_status_id, '2026-06-17'::date, 0, null)
  returning id into v_org_id;

  -- George House Trust
  select id into v_category_id from categories where lower(name) = lower('Health & Wellbeing – HIV Support') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Health & Wellbeing – HIV Support', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Call Attempted: In Meeting' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('George House Trust', v_category_id, 'United Kingdom', '25 staff. Commissioned HIV support services Manchester. 2025 GSK IMPACT winner.', 'https://ght.org.uk/our-staff', NULL, NULL, NULL, NULL, v_status_id, '2026-06-11'::date, 1, '2026-06-11'::timestamptz)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044161 274 4499', NULL);
  insert into status_history (organisation_id, status_id, changed_at) values (v_org_id, v_status_id, '2026-06-11'::timestamptz);

  -- Girl Effect South Africa
  select id into v_category_id from categories where lower(name) = lower('Adolescent Girls / Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Adolescent Girls / Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Girl Effect South Africa', v_category_id, 'South Africa', 'MERL Manager role advertised for SA. Find SA country lead via girleffect.org/about/our-team or LinkedIn.', 'https://www.girleffect.org/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-15'::date, 0, null)
  returning id into v_org_id;

  -- GirlCode
  select id into v_category_id from categories where lower(name) = lower('Tech Skills / Youth') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Tech Skills / Youth', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('GirlCode', v_category_id, 'South Africa', 'NPO 158-642. BBBEE Level 1. Girls and young women in technology / design / leadership. Annual hackathon.', 'https://www.girlcode.co.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-29'::date, 0, null)
  returning id into v_org_id;

  -- Good Work Foundation
  select id into v_category_id from categories where lower(name) = lower('Digital education (rural)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Digital education (rural)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Good Work Foundation', v_category_id, 'South Africa', 'Pioneering digital education in rural Bushbuckridge. 10000+ learners since 2006 across 6 campuses. Kate Groch is CEO. Gemma Thompson is Head of Development.', 'https://www.goodworkfoundation.org/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-14'::date, 0, null)
  returning id into v_org_id;

  -- GoodWork
  select id into v_category_id from categories where lower(name) = lower('Youth Employability') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Employability', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('GoodWork', v_category_id, 'United Kingdom', 'Small London youth employment & social mobility charity. Tracks young people into work over 6-month programme. Felicity Halstead is CEO/Founder. Recently gained charity status (2025). Supported 80+ young people across 4 programmes. Laura Quinn handles impact evaluation.', 'https://www.goodwork.org.uk', 'https://www.goodwork.org.uk/our-team', NULL, NULL, 'https://uk.linkedin.com/company/goodwork', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;

  -- Grassroot Soccer SA
  select id into v_category_id from categories where lower(name) = lower('Health / Youth (HIV Prevention)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Health / Youth (HIV Prevention)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Grassroot Soccer SA', v_category_id, 'South Africa', 'HIV prevention through sport for adolescents. 61 staff, $4.2m budget. 390,000+ youth reached. Parktown Johannesburg.', 'https://grassrootsoccer.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-25'::date, 0, null)
  returning id into v_org_id;

  -- Grassroot Soccer South Africa
  select id into v_category_id from categories where lower(name) = lower('Sport + Adolescent Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Sport + Adolescent Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Grassroot Soccer South Africa', v_category_id, 'South Africa', 'Parktown Johannesburg + Cape Town Centre of Excellence. Has MEL Coordinator role. Feryal Domingo (MD Cape Town).', 'https://grassrootsoccer.org/southafrica/', NULL, 'https://grassrootsoccer.org/wp-content/uploads/2025/08/2024-Annual-Report.pdf', NULL, NULL, v_status_id, '2026-06-15'::date, 0, null)
  returning id into v_org_id;

  -- Greenhouse Sports
  select id into v_category_id from categories where lower(name) = lower('Sport for development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Sport for development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Greenhouse Sports', v_category_id, 'United Kingdom', 'Inner-city London youth development through sport. Newly created Director of Impact role filled June 2025. CEO: Don Barrell. 35 Cosway Street London. ~120 staff. 7,000+ students in London secondary schools each year.', 'https://www.greenhousesports.org', NULL, 'https://register-of-charities.charitycommission.gov.uk/charity-details/?regId=1098744&subid=0', NULL, 'https://uk.linkedin.com/company/greenhousesports', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;

  -- Grootbos Foundation
  select id into v_category_id from categories where lower(name) = lower('Youth Enterprise – Conservation') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Enterprise – Conservation', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Grootbos Foundation', v_category_id, 'South Africa', 'Founded 2003. Enterprise development and skills training for local youth near Gansbaai / Hermanus area. Find M&E contact on team page.', 'https://grootbosfoundation.org/meet-the-team/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-11'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0027 (0)28 384 8038', NULL);

  -- Groundswell
  select id into v_category_id from categories where lower(name) = lower('Homelessness / Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Homelessness / Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Groundswell', v_category_id, 'United Kingdom', 'Peer health advocacy. 540 homeless clients tracked through 3688 one-to-one health appointments (2024-25). NHS/NHSE commissioned. Charity reg 1089987.', 'https://groundswell.org.uk/our-team/', NULL, 'https://groundswell.org.uk/wp-content/uploads/2024/11/A201-Groundswell-annual-report-and-accounts-23-24-CHARITY-COMMISSION.pdf', NULL, 'https://uk.linkedin.com/company/groundswell-uk', v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;

  -- Groundwork UK
  select id into v_category_id from categories where lower(name) = lower('Community / collective impact') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community / collective impact', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Groundwork UK', v_category_id, 'United Kingdom', 'Federation of local environmental and community development charities. Each local Groundwork trust delivers commissioned services and tracks beneficiaries separately.', 'https://www.groundwork.org.uk', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/293705/contact-information', NULL, NULL, v_status_id, '2026-06-24'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044121 236 8565', NULL);

  -- Grow Great
  select id into v_category_id from categories where lower(name) = lower('Early childhood development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Early childhood development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Grow Great', v_category_id, 'South Africa', 'National ECD campaign; tracks outcomes across communities; evidence-based; government and donor funded.', 'https://growgreat.co.za', NULL, NULL, NULL, NULL, v_status_id, '2026-06-16'::date, 0, null)
  returning id into v_org_id;

  -- Healthwatch Hertfordshire
  select id into v_category_id from categories where lower(name) = lower('Community health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Healthwatch Hertfordshire', v_category_id, 'United Kingdom', 'Kings Court / London Road / Stevenage / Hertfordshire SG1 2NG; community health voice commissioned by NHS. New CEO (2024).', 'https://www.healthwatchhertfordshire.co.uk/our-staff', NULL, NULL, NULL, NULL, v_status_id, '2026-06-30'::date, 0, null)
  returning id into v_org_id;

  -- Heartlines
  select id into v_category_id from categories where lower(name) = lower('Behaviour Change – Values') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Behaviour Change – Values', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = '1st Email Sent' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Heartlines', v_category_id, 'South Africa', 'M&E is central to their programme model. Johannesburg-based. Garth Japhet is CEO. COO: Derek Muller. West Centre 281 Jan Smuts Ave Dunkeld JHB 2196. Flagship programme: Fathers Matter.', 'https://www.heartlines.org.za/our-team/staff', NULL, NULL, NULL, NULL, v_status_id, '2026-06-11'::date, 1, '2026-06-11'::timestamptz)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0027 117712540', NULL);
  insert into status_history (organisation_id, status_id, changed_at) values (v_org_id, v_status_id, '2026-06-11'::timestamptz);

  -- Hertfordshire Mind Network
  select id into v_category_id from categories where lower(name) = lower('Mental Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Hertfordshire Mind Network', v_category_id, 'United Kingdom', 'Independent Mind affiliate (not Mind national). Commissioned mental health services across Hertfordshire. 10 Leeming Road Borehamwood WD6 4DU.', 'https://www.hertsmindnetwork.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-25'::date, 0, null)
  returning id into v_org_id;

  -- HIVSA
  select id into v_category_id from categories where lower(name) = lower('HIV / community health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('HIV / community health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('HIVSA', v_category_id, 'South Africa', 'Established 2002; 100+ staff; strategic partner of Gauteng Depts of Health and Social Development; multiple M&E Officer posts advertised in 2025. PO Box 3869 Southgate Johannesburg 2082.', 'https://hivsa.com/contact-us/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-30'::date, 0, null)
  returning id into v_org_id;

  -- HOPE Africa
  select id into v_category_id from categories where lower(name) = lower('Youth / Social Development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth / Social Development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('HOPE Africa', v_category_id, 'South Africa', 'Pan-African — SA HQ. Holistic community development: health + education + livelihoods. Reports to international funders.', 'https://hopeafrica.org.za/who-we-are/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;

  -- Hope Cape Town
  select id into v_category_id from categories where lower(name) = lower('ECD / Youth') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('ECD / Youth', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Hope Cape Town', v_category_id, 'South Africa', 'Delft area Cape Town. Holistic from pregnancy to career: ECD + youth + training + education + sustainable livelihoods.', 'https://hopecapetown.org/our-organisation-staff-2/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 001 2175', NULL);

  -- Hope for the Future
  select id into v_category_id from categories where lower(name) = lower('Community Climate Action') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community Climate Action', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Hope for the Future', v_category_id, 'United Kingdom', 'Trains people in climate change communications; community behaviour-change programmes tracking participant journeys.', 'https://www.hftf.org.uk/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-15'::date, 0, null)
  returning id into v_org_id;

  -- Hope Worldwide South Africa
  select id into v_category_id from categories where lower(name) = lower('ECD – Community Development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('ECD – Community Development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Hope Worldwide South Africa', v_category_id, 'South Africa', 'Founded 1993. ECD focus. 134855 children served. Robust M&E culture.', 'https://hopeworldwidesa.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-11'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 11 795 1071', NULL);

  -- IDAS – Independent Domestic Abuse Services
  select id into v_category_id from categories where lower(name) = lower('Domestic abuse (commissioned)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Domestic abuse (commissioned)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('IDAS – Independent Domestic Abuse Services', v_category_id, 'United Kingdom', 'Largest specialist DA charity in Yorkshire; revenue ~£4M; 8014 adults and children in 2025; 200+ staff.', 'https://idas.org.uk/who-we-are/our-team/', NULL, 'https://idas.org.uk/impact-report-2025/', NULL, NULL, v_status_id, '2026-06-30'::date, 0, null)
  returning id into v_org_id;

  -- Ikamva Labantu
  select id into v_category_id from categories where lower(name) = lower('Social development (children / youth / elderly)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Social development (children / youth / elderly)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Ikamva Labantu', v_category_id, 'South Africa', '60+ year Cape Town NPO. Programmes: ECD / Child Youth & Parenting / Older Person. 95% female staff from communities served. Buchanan Square 160 Sir Lowry Rd Woodstock Cape Town 7925.', 'https://www.ikamvalabantu.org.za/our-team/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-28'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 461 8338', NULL);

  -- Ilifa Labantwana
  select id into v_category_id from categories where lower(name) = lower('Early childhood development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Early childhood development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Ilifa Labantwana', v_category_id, 'South Africa', 'Advocacy and funding body for early childhood development in South Africa. Reports to funders like Atlantic Philanthropies and DG Murray Trust. Also try: Chantell Witten (Director Health Systems Strengthening).', 'https://www.ilifalabantwana.org.za', NULL, NULL, NULL, NULL, v_status_id, '2026-06-24'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 670 9848', NULL);

  -- IntoUniversity
  select id into v_category_id from categories where lower(name) = lower('Education / employability') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Education / employability', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('IntoUniversity', v_category_id, 'United Kingdom', '38 centres across UK. Tracks individual young people from primary school to university/employment. Alex Quinn is ideal Makerble buyer. Chloe Cheetham joined as Impact and Evaluation Manager Jan 2025. CEO: Dr Rachel Carr. 95 Sirdar Road London W11 4EQ.', 'https://intouniversity.org', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/4028737', NULL, 'https://uk.linkedin.com/company/intouniversity', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00442072430242', NULL);

  -- Inyathelo
  select id into v_category_id from categories where lower(name) = lower('NPO Capacity Building') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('NPO Capacity Building', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Inyathelo', v_category_id, 'South Africa', 'Cape Town (160 Sir Lowry Rd, Woodstock). Builds capacity of SA nonprofits — 20 staff.', 'https://www.inyathelo.org.za', NULL, NULL, NULL, NULL, v_status_id, '2026-06-17'::date, 0, null)
  returning id into v_org_id;

  -- IRMO – Indoamerican Refugee and Migrant Organisation
  select id into v_category_id from categories where lower(name) = lower('Migrant support') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Migrant support', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('IRMO – Indoamerican Refugee and Migrant Organisation', v_category_id, 'United Kingdom', 'London-based; actively hiring a Communications M&E Officer (June 2026 closing).', 'https://irmo.org.uk/about-us/', NULL, NULL, NULL, 'https://uk.linkedin.com/company/irmo-indoamerican-refugee-migrant-organisation', v_status_id, '2026-06-30'::date, 0, null)
  returning id into v_org_id;

  -- Isle of Wight Youth Trust
  select id into v_category_id from categories where lower(name) = lower('Youth Mental Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Mental Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Call Attempted: Dial tone' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Isle of Wight Youth Trust', v_category_id, 'United Kingdom', '2025 GSK IMPACT overall winner (£50k). Commissioned counselling and wellbeing services for young people.', 'https://www.iowyouthtrust.co.uk', NULL, 'https://www.iowyouthtrust.co.uk/wp-content/uploads/2026/03/Isle-of-Wight-Youth-Trust-Annual-Report-2024.2025.-Fully-Signed.pdf', NULL, NULL, v_status_id, '2026-06-11'::date, 1, '2026-06-11'::timestamptz)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00441983 529 569', NULL);
  insert into status_history (organisation_id, status_id, changed_at) values (v_org_id, v_status_id, '2026-06-11'::timestamptz);

  -- Jigsaw
  select id into v_category_id from categories where lower(name) = lower('Youth Mental Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Mental Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Jigsaw', v_category_id, 'Ireland', '26 services across Ireland. HSE-commissioned early intervention. Active Research & Evaluation team with dedicated strategy 2025–27. Ask for Head of Research & Evaluation.', 'https://jigsaw.ie/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-26'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+353 1 472 7010', NULL);

  -- Keighley Healthy Living Network
  select id into v_category_id from categories where lower(name) = lower('Community Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Call Attempted: In Meeting' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Keighley Healthy Living Network', v_category_id, 'United Kingdom', '2025 GSK IMPACT winner. Community health inequalities in Bradford / Keighley area. 1700+ beneficiaries. Melanie will feel the reporting burden.', 'https://www.khl.org.uk/staff/', NULL, 'https://www.khl.org.uk/wp-content/uploads/2025/07/Connect-Report-24-25.pdf', NULL, NULL, v_status_id, '2026-06-11'::date, 1, '2026-06-11'::timestamptz)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00441535 677177', NULL);
  insert into status_history (organisation_id, status_id, changed_at) values (v_org_id, v_status_id, '2026-06-11'::timestamptz);

  -- Key4Life
  select id into v_category_id from categories where lower(name) = lower('Justice / Rehabilitation') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Justice / Rehabilitation', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Key4Life', v_category_id, 'United Kingdom', '8% reoffending vs 50% national. Tracks young men through prison → community → employment. London/Bristol/SW.', 'https://key4life.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-18'::date, 0, null)
  returning id into v_org_id;

  -- Khulisa (UK)
  select id into v_category_id from categories where lower(name) = lower('Youth emotional wellbeing') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth emotional wellbeing', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Khulisa (UK)', v_category_id, 'United Kingdom', 'Dedicated Data and Insight Coordinator role. Award-winning youth wellbeing programmes. ~£750k–£1m income. CEO transition. NOTE: UK Khulisa, different from SA Khulisa.', NULL, NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/1120562/charity-overview', NULL, NULL, v_status_id, '2026-06-10'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044207 183 2647', NULL);

  -- Kick London
  select id into v_category_id from categories where lower(name) = lower('Sport-based youth engagement') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Sport-based youth engagement', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Kick London', v_category_id, 'United Kingdom', 'Uses sport to prevent youth crime and engage young people in London. Faith-based roots (formerly Kickz).', 'https://kicklondon.org.uk/contact-us/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-28'::date, 0, null)
  returning id into v_org_id;

  -- Kids First Australia (incorp. Whitelion)
  select id into v_category_id from categories where lower(name) = lower('Youth employment & children') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth employment & children', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Kids First Australia (incorp. Whitelion)', v_category_id, 'Australia', 'Formed by merger of Whitelion (youth-at-risk employment) and Kids First. Supports young people to age 24. Dynamic evaluation and analysis system.', 'https://www.kidsfirstaustralia.org.au', NULL, NULL, NULL, NULL, v_status_id, '2026-06-28'::date, 0, null)
  returning id into v_org_id;

  -- LEAP Africa
  select id into v_category_id from categories where lower(name) = lower('Youth leadership development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth leadership development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('LEAP Africa', v_category_id, 'Nigeria', 'Youth-focused leadership development across Africa. Find M&E or MERL contact at leapafrica.org/team. Published 2025 evaluation reports. 2/4 Custom Street Nigerian Exchange Group Building Marina Lagos.', 'https://leapafrica.org', 'https://leapafrica.org/programmes-report/', NULL, NULL, 'https://ng.linkedin.com/company/leapafrica', v_status_id, '2026-06-27'::date, 0, null)
  returning id into v_org_id;

  -- Leap Confronting Conflict
  select id into v_category_id from categories where lower(name) = lower('Youth work / conflict') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth work / conflict', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Leap Confronting Conflict', v_category_id, 'United Kingdom', '£1.21m income 2024; 30 staff; Director of Delivery: Laura Johnson; 35+ years youth conflict work; N4 3JU London.', 'https://leapconfrontingconflict.org.uk', NULL, 'https://register-of-charities.charitycommission.gov.uk/charity-details/?regId=1072376', NULL, 'https://www.linkedin.com/company/leap-confronting-conflict', v_status_id, '2026-06-16'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '004420 7561 3700', NULL);

  -- LEAP Science and Maths Schools
  select id into v_category_id from categories where lower(name) = lower('Education (science + maths for disadvantaged youth)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Education (science + maths for disadvantaged youth)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('LEAP Science and Maths Schools', v_category_id, 'South Africa', 'Operates in 6 SA provinces for disadvantaged students Gr8–12. Distributed leadership model. Apex Group CSI partner.', 'https://leapschool.org.za', NULL, NULL, NULL, 'https://www.linkedin.com/company/leap-science-and-maths-school', v_status_id, '2026-06-19'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 531 9715', NULL);

  -- Leeds Mind
  select id into v_category_id from categories where lower(name) = lower('Mental Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Leeds Mind', v_category_id, 'United Kingdom', '£2.8m income; 3 govt contracts worth £2.6m. 109 staff across employment support, peer support, social prescribing, counselling. Email format: firstname.lastname@leedsmind.org.uk', 'https://www.leedsmind.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-25'::date, 0, null)
  returning id into v_org_id;

  -- Leeds North & West Foodbank
  select id into v_category_id from categories where lower(name) = lower('Foodbank') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Foodbank', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Leeds North & West Foodbank', v_category_id, 'United Kingdom', 'Trussell Trust network foodbank in Leeds. Income likely £300k–£800k. Tel: 07872608296.', 'https://leedsnorthandwest.foodbank.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-17'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '07872608296', NULL);

  -- Literacy Pirates
  select id into v_category_id from categories where lower(name) = lower('Youth literacy') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth literacy', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Literacy Pirates', v_category_id, 'United Kingdom', 'Hackney-based youth literacy charity tracking children over time (multi-year journeys). Small team (~15–25 staff).', 'https://www.hackneypirates.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-24'::date, 0, null)
  returning id into v_org_id;

  -- London Youth
  select id into v_category_id from categories where lower(name) = lower('Youth Work / Network') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Work / Network', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('London Youth', v_category_id, 'United Kingdom', 'Network of 600 youth orgs + two outdoor residential centres. Income ~£3–4m. Has Head of Programmes and Director of Programmes roles.', 'https://londonyouth.org/', NULL, 'https://londonyouth.org/wp-content/uploads/2025/10/London-Youth_Trustees-Annual-Report-2023-24.pdf', NULL, 'https://www.linkedin.com/company/london-youth', v_status_id, '2026-06-20'::date, 0, null)
  returning id into v_org_id;

  -- loveLife
  select id into v_category_id from categories where lower(name) = lower('Youth HIV Prevention') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth HIV Prevention', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('loveLife', v_category_id, 'South Africa', 'South Africa''s largest youth HIV-prevention charity. Has a dedicated Programme Measurement & Design (PMD) unit. Operates across 967 sites nationally.', 'https://lovelife.org.za', NULL, 'https://lovelife.org.za/wp-content/uploads/2024/03/lovelife-annual-report-2024-1.pdf', NULL, 'https://za.linkedin.com/company/lovelife', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '002731 312 7288', NULL);

  -- Making The Leap
  select id into v_category_id from categories where lower(name) = lower('Youth employability') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth employability', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Making The Leap', v_category_id, 'United Kingdom', 'Youth employability London. New CEO since Sept 2024. Newly hired Data and Evaluation Officer (June 2025). 28 Hazel Road Kensal Green London NW10 5PP.', 'https://makingtheleap.org.uk', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/about-the-register-of-charities/-/charity-details/1058648', NULL, 'https://uk.linkedin.com/company/making-the-leap', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;

  -- Mamelani Projects
  select id into v_category_id from categories where lower(name) = lower('Community development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Mamelani Projects', v_category_id, 'South Africa', 'Cape Town-based (2 Forest Drive Pinelands 7405). Established 2003. Carly Tanur is Director; Leroy De Klerk is Programme Manager.', 'https://mamelani.org.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-23'::date, 0, null)
  returning id into v_org_id;

  -- Manchester Mind
  select id into v_category_id from categories where lower(name) = lower('Mental health (commissioned)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental health (commissioned)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Manchester Mind', v_category_id, 'United Kingdom', '9 government contracts totalling ~£1.9m. CYP services, counselling, peer support, social prescribing all track named service users. 81 staff. Email format: firstname.lastname@manchestermind.org.', 'https://www.manchestermind.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-10'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044161 769 5732', NULL);

  -- Mason Foundation
  select id into v_category_id from categories where lower(name) = lower('Neurodivergent young people / community') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Neurodivergent young people / community', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Mason Foundation', v_category_id, 'United Kingdom', 'Growth-phase charity. 300+ volunteers nationwide. Propel programme places neurodivergent young people into work. Charity reg 1150662; 7500 beneficiaries.', 'https://www.masonfoundation.co.uk', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/5034334', NULL, 'https://www.linkedin.com/company/the-mason-foundation', v_status_id, '2026-06-27'::date, 0, null)
  returning id into v_org_id;

  -- Maudsley Charity
  select id into v_category_id from categories where lower(name) = lower('Mental Health (Commissioned)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental Health (Commissioned)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Maudsley Charity', v_category_id, 'United Kingdom', 'Active Evaluation & Learning Manager vacancy at £45k. Funds and operates mental health projects in South London.', 'https://maudsleycharity.org/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-29'::date, 0, null)
  returning id into v_org_id;

  -- MCR Pathways
  select id into v_category_id from categories where lower(name) = lower('Youth / Mentoring') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth / Mentoring', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('MCR Pathways', v_category_id, 'United Kingdom', 'Scotland. School-based mentoring for care-experienced + disadvantaged young people. 1000+ young people. SCIO reg SC045816. Mitchell Library Berkeley St Glasgow G3 7DN.', 'https://mcrpathways.org/leadership/', NULL, 'https://www.oscr.org.uk/about-charities/search-the-register/charity-details?number=SC045816', NULL, NULL, v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0141 221 0200', NULL);

  -- Mentoring Plus Bath
  select id into v_category_id from categories where lower(name) = lower('Youth Mentoring') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Mentoring', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Mentoring Plus Bath', v_category_id, 'United Kingdom', 'Bath & NE Somerset. 1:1 mentoring + group activities for young people 5–25. ~£500k–£1m income. Good starter call — local to Makerble.', 'https://mentoringplus.net', NULL, NULL, NULL, 'https://uk.linkedin.com/company/mentoring-plus-bath-and-north-east-somerset-ltd', v_status_id, '2026-06-18'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00441225 471 592', NULL);

  -- MIET Africa
  select id into v_category_id from categories where lower(name) = lower('Education / youth health (multi-country)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Education / youth health (multi-country)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('MIET Africa', v_category_id, 'South Africa', 'Dedicated Monitoring Evaluation and Reporting (MER) service unit built into all programme design. Operates across 6 countries.', 'https://mietafrica.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-10'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 31 313 3100', NULL);

  -- Mind in Salford
  select id into v_category_id from categories where lower(name) = lower('Mental health (commissioned services)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental health (commissioned services)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Mind in Salford', v_category_id, 'United Kingdom', 'Charity 1156625. Income ~£1.25M; 54 staff; 5280 service users in 2024-25. Actively recruiting an Impact Evaluation & Compliance Manager.', 'https://www.mindinsalford.org.uk/', 'https://www.mindinsalford.org.uk/about-us/', 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/5047026/accounts-and-annual-returns', NULL, NULL, v_status_id, '2026-06-23'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0161 710 1070', NULL);

  -- Money Ready (formerly MyBNK)
  select id into v_category_id from categories where lower(name) = lower('Financial Education') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Financial Education', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Money Ready (formerly MyBNK)', v_category_id, 'United Kingdom', '50000+ young people/yr. Rebranded from MyBNK in 2025. Strong impact reporting culture.', 'https://moneyready.org/', NULL, 'https://moneyready.org/wp-content/uploads/2025/08/Impact-Report-2023-2024-V_Final-1.pdf', NULL, NULL, v_status_id, '2026-06-15'::date, 0, null)
  returning id into v_org_id;

  -- Mpilonhle
  select id into v_category_id from categories where lower(name) = lower('Youth health / social development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth health / social development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Mpilonhle', v_category_id, 'South Africa', 'KwaZulu-Natal; 34 employees; HIV / TB / sexual health. Named M&E Officer. Gugu Ngidi is an alternative first contact. 16 Poort Rd Ladysmith 3370.', 'https://mpilonhle.org', NULL, 'https://mpilonhle.org/wp-content/uploads/2025/09/2025-09-01-Mpilonhle-Annual-Report-2024-2025.pdf', NULL, NULL, v_status_id, '2026-06-16'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 36 631 0200', NULL);

  -- MYTIME Young Carers
  select id into v_category_id from categories where lower(name) = lower('Young Carers') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Young Carers', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('MYTIME Young Carers', v_category_id, 'United Kingdom', 'Rapidly growing national young carers charity. Josh Parker is Head of Programmes. CEO is Krista Sharp. Social Impact & Evaluation Officer vacancy. HQ: Avonbourne Academy Harewood Avenue Bournemouth BH7 6NY.', 'https://www.mytimeyoungcarers.org', NULL, NULL, NULL, 'https://uk.linkedin.com/company/mytime-young-carers', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00441202 710701', NULL);

  -- NACOSA
  select id into v_category_id from categories where lower(name) = lower('HIV/AIDS Networking & Grant Management') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('HIV/AIDS Networking & Grant Management', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('NACOSA', v_category_id, 'South Africa', 'Cape Town HQ. Leading HIV/AIDS/TB/GBV networking org and grant manager. 174 staff; 1500+ member orgs. Executive Director: Mohamed Motala. Mari Lotvonen is the contact for M&E. 3rd Floor East Tower Century Boulevard Cape Town.', 'https://www.nacosa.org.za', NULL, 'https://www.nacosa.org.za/annual-report-2025/', NULL, 'https://za.linkedin.com/company/nacosa', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 (0)21 552 0804', NULL);

  -- NACSA
  select id into v_category_id from categories where lower(name) = lower('Community development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('NACSA', v_category_id, 'South Africa', 'Community development support organisation; verify ICP fit on call.', 'https://nacsa.africa', NULL, NULL, NULL, NULL, v_status_id, '2026-06-16'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 86 099 4106', NULL);

  -- National Business Initiative (NBI)
  select id into v_category_id from categories where lower(name) = lower('Skills & Youth Employability (Corporate)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Skills & Youth Employability (Corporate)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('National Business Initiative (NBI)', v_category_id, 'South Africa', 'Corporate coalition. Skills & Youth Employability is a core focus area. Contracted to deliver M&E for member company CSI programmes.', 'https://www.nbi.org.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-26'::date, 0, null)
  returning id into v_org_id;

  -- National Mentorship Movement
  select id into v_category_id from categories where lower(name) = lower('Entrepreneurial mentoring') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Entrepreneurial mentoring', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('National Mentorship Movement', v_category_id, 'South Africa', 'Matches entrepreneurs with mentors across South Africa. 1400+ registered volunteer mentors. Johannesburg / Rivonia based.', 'https://mentorshipmovement.co.za', NULL, NULL, NULL, NULL, v_status_id, '2026-06-24'::date, 0, null)
  returning id into v_org_id;

  -- New Horizon Youth Centre
  select id into v_category_id from categories where lower(name) = lower('Youth Homelessness') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Homelessness', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('New Horizon Youth Centre', v_category_id, 'United Kingdom', '16–24 year olds at risk of homelessness. London. 68 Chalton St, London NW1 1JR. £4.5m income (up 14% YoY). 70 staff.', 'https://nhyouthcentre.org.uk/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-29'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '004420 7388 5560', NULL);

  -- NICRO
  select id into v_category_id from categories where lower(name) = lower('Social Crime Prevention') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Social Crime Prevention', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('NICRO', v_category_id, 'South Africa', '~200 staff. Social crime prevention and offender reintegration. Est. 1910. 4 Buitensingel St Schotsche Kloof Cape Town 8001.', 'https://www.nicro.org.za', NULL, NULL, NULL, NULL, v_status_id, '2026-06-25'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 462 0017', NULL);

  -- Nkosi's Haven
  select id into v_category_id from categories where lower(name) = lower('Health / HIV') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Health / HIV', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Nkosi''s Haven', v_category_id, 'South Africa', 'Johannesburg. Cares for HIV+ mothers and children in memory of Nkosi Johnson. Contact via main website.', 'https://www.nkosishaven.co.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;

  -- Nourish Community Foodbank
  select id into v_category_id from categories where lower(name) = lower('Food poverty') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Food poverty', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Nourish Community Foodbank', v_category_id, 'United Kingdom', 'Independent (not Trussell) community foodbank. 2024 annual report filed. 5 staff + 50 volunteers. Tunbridge Wells / South Tonbridge.', 'https://www.nourishcommunityfoodbank.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-10'::date, 0, null)
  returning id into v_org_id;

  -- Oasis Charitable Trust
  select id into v_category_id from categories where lower(name) = lower('Faith-based community / education') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Faith-based community / education', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Oasis Charitable Trust', v_category_id, 'United Kingdom', 'Runs academies + community hubs + international development; multiple service streams; faith-based community; national.', 'https://oasischarity.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-16'::date, 0, null)
  returning id into v_org_id;

  -- Oasis Community Trust
  select id into v_category_id from categories where lower(name) = lower('Poverty / Community') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Poverty / Community', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Oasis Community Trust', v_category_id, 'United Kingdom', 'Faith-based housing + community hubs (Oasis Aquila Housing arm). South and East London. Find Director of Community Development.', 'https://www.oasistrust.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-18'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '004420 7928 4548', NULL);

  -- Oasis Project
  select id into v_category_id from categories where lower(name) = lower('Substance Misuse / Women & Families') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Substance Misuse / Women & Families', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Oasis Project', v_category_id, 'United Kingdom', 'New CEO appointed April 2025. Commissioned drug & alcohol services tracking women and children''s journeys. Head of Services also on team.', 'https://www.oasisproject.org.uk/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-26'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00441273 666950', NULL);

  -- One to One Africa
  select id into v_category_id from categories where lower(name) = lower('Community Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('One to One Africa', v_category_id, 'South Africa', 'Actively hiring Head of Impact (MERL) as of Feb 2026. Founded 2015. Community health development in Eastern Cape.', 'https://www.onetooneafrica.org/our-leadership/', NULL, 'https://www.onetooneafrica.org/wp-content/uploads/2026/03/Annual-Review-2024_25.pdf', NULL, NULL, v_status_id, '2026-06-11'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 (0) 21 003 8070', NULL);

  -- One25
  select id into v_category_id from categories where lower(name) = lower('Women''s health / social care (commissioned)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Women''s health / social care (commissioned)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('One25', v_category_id, 'United Kingdom', 'Charity 1062391. Bristol-based. Street outreach and recovery services for women in sex work. Commissioned by Bristol City Council and NHS. Grosvenor Centre 138a Grosvenor Road St Pauls Bristol BS2 8YA.', 'https://one25.org.uk/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-23'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0117 909 8832', NULL);

  -- Open Road
  select id into v_category_id from categories where lower(name) = lower('Drug & Alcohol Recovery (Commissioned)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Drug & Alcohol Recovery (Commissioned)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Open Road', v_category_id, 'United Kingdom', '35-year drug & alcohol recovery charity commissioned by Essex & Medway. New Strategic Plan 2025–2030.', 'https://www.openroad.org.uk', NULL, NULL, NULL, 'https://www.linkedin.com/company/open-road-visions', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;

  -- Operation Hunger
  select id into v_category_id from categories where lower(name) = lower('Food Poverty / Nutrition') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Food Poverty / Nutrition', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Operation Hunger', v_category_id, 'South Africa', 'National org combating chronic malnutrition. Operates in all 9 provinces. Reports to government commissioners and corporate CSI funders.', 'https://operationhunger.org.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-20'::date, 0, null)
  returning id into v_org_id;

  -- Palace For Life Foundation
  select id into v_category_id from categories where lower(name) = lower('Sport / health / education') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Sport / health / education', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Palace For Life Foundation', v_category_id, 'United Kingdom', 'Crystal Palace FC official charity. 18000 young people/year across sport education health employment. 51-200 staff. Head of Operations (Duncan) oversees Impact and Systems.', 'https://www.palaceforlife.org', NULL, NULL, NULL, 'https://uk.linkedin.com/company/palaceforlife', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;

  -- PAPYRUS UK
  select id into v_category_id from categories where lower(name) = lower('Mental Health / Suicide Prevention') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental Health / Suicide Prevention', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('PAPYRUS UK', v_category_id, 'United Kingdom', 'National charity dedicated to preventing suicide among young people. Operates HOPELineUK (0800 068 4141). Income ~£3–5m. Warrington-based.', 'https://www.papyrus-uk.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-17'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0800 068 4141', NULL);

  -- Pathways to Education
  select id into v_category_id from categories where lower(name) = lower('Youth employability') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth employability', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Pathways to Education', v_category_id, 'Canada', 'Reduces school dropout in low-income communities. Academic + financial + social + 1:1 mentoring. Multiple locations across Canada.', 'https://www.pathwaystoeducation.ca', NULL, NULL, NULL, NULL, v_status_id, '2026-06-28'::date, 0, null)
  returning id into v_org_id;

  -- Penreach
  select id into v_category_id from categories where lower(name) = lower('Rural education (ECD / literacy / numeracy)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Rural education (ECD / literacy / numeracy)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Penreach', v_category_id, 'South Africa', 'Rural education NGO since 1991 across Mpumalanga Limpopo Gauteng Eastern Cape KZN. M&E coordinator role in structure. penreach@penreach.co.za general.', 'https://penreach.co.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-23'::date, 0, null)
  returning id into v_org_id;

  -- Philani
  select id into v_category_id from categories where lower(name) = lower('Maternal & Child Health') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Maternal & Child Health', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Philani', v_category_id, 'South Africa', 'Cape Town-based. Exceptionally rigorous M&E — academic partnerships with UCLA, Stanford and Stellenbosch. Home-based maternal and child health interventions.', 'https://www.philani.org.za/', NULL, 'https://www.philani.org.za/who-we-are/impact-evaluation/', NULL, NULL, v_status_id, '2026-06-29'::date, 0, null)
  returning id into v_org_id;

  -- Power2
  select id into v_category_id from categories where lower(name) = lower('Youth mentoring (schools + youth justice)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth mentoring (schools + youth justice)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Power2', v_category_id, 'United Kingdom', '1300+ named young people tracked across 24 LAs and 102 schools. Income doubled YoY (£1.2m → £2.4m). 7 govt contracts + 2 grants.', NULL, NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/4001130/charity-overview', NULL, NULL, v_status_id, '2026-06-10'::date, 0, null)
  returning id into v_org_id;

  -- Pure Innovations
  select id into v_category_id from categories where lower(name) = lower('Disability employment & inclusion') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Disability employment & inclusion', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Pure Innovations', v_category_id, 'United Kingdom', 'Stockport-based disability employment charity. Commissioned services. Amanda likely the internal champion.', 'https://www.pureinnovations.co.uk/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-14'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+44 (0)161 804 4400', NULL);

  -- Ranyaka Community Transformation
  select id into v_category_id from categories where lower(name) = lower('Community Development – Urban') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community Development – Urban', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Ranyaka Community Transformation', v_category_id, 'South Africa', '33 communities across 15 towns in 8 provinces. Youth life skills, financial training, career support.', 'https://ranyaka.co.za/about-us/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-11'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 72 515 8482', NULL);

  -- Re-engage
  select id into v_category_id from categories where lower(name) = lower('Befriending – Older People') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Befriending – Older People', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Call Attempted: Voicemail' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Re-engage', v_category_id, 'United Kingdom', '6600+ older people served annually; 7600+ volunteers. Established Theory of Change and M&E framework. Jess Doyle is Head of Impact — 15 yrs M&E expertise. Charity 1146149. CEO is Mary Rance. 7 Bell Yard, London WC2A 2JR.', 'https://reengage.org.uk/about-us/staff-trustees/', NULL, NULL, NULL, 'https://uk.linkedin.com/company/reengageuk', v_status_id, '2026-06-11'::date, 1, '2026-06-11'::timestamptz)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '004420 7240 0630', NULL);
  insert into status_history (organisation_id, status_id, changed_at) values (v_org_id, v_status_id, '2026-06-11'::timestamptz);

  -- ReachOut UK
  select id into v_category_id from categories where lower(name) = lower('Youth Mentoring') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Mentoring', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('ReachOut UK', v_category_id, 'United Kingdom', 'One-to-one mentoring charity. Individual young person journeys tracked across London boroughs. 8-10 Grosvenor Gardens London SW1W 0DH. Charity 1096492.', 'https://www.reachoutuk.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-25'::date, 0, null)
  returning id into v_org_id;

  -- Recycling Lives
  select id into v_category_id from categories where lower(name) = lower('Rehabilitation / Poverty') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Rehabilitation / Poverty', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Recycling Lives', v_category_id, 'United Kingdom', 'New CEO summer 2025. SROI: £8.44 per £1 invested. Commissioned rehabilitation programmes.', 'https://www.recyclinglives.org/', NULL, 'https://www.recyclinglives.org/our-impact/report-2024-25/', NULL, NULL, v_status_id, '2026-06-26'::date, 0, null)
  returning id into v_org_id;

  -- Resurgo (Spear)
  select id into v_category_id from categories where lower(name) = lower('Youth Employability Coaching') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Employability Coaching', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Resurgo (Spear)', v_category_id, 'United Kingdom', '18+ Spear centres; 12000+ young people helped. Runs Resurgo Consulting for impact management. Pete Bacon is the impact lead. DWP Employment Data Lab independently evaluated Spear in 2022. Faith-based.', 'https://resurgo.org.uk/', NULL, 'https://register-of-charities.charitycommission.gov.uk/charity-details/?regId=1100885', NULL, 'https://www.linkedin.com/company/resurgo', v_status_id, '2026-06-15'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '020 3327 2074', NULL);

  -- Rise Up UK
  select id into v_category_id from categories where lower(name) = lower('Youth Employment') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Employment', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Rise Up UK', v_category_id, 'United Kingdom', 'New Head of Charity. Founded 2019. Coaches young people with barriers into employment. 4 UK offices.', 'https://www.riseupuk.org', NULL, NULL, NULL, 'https://uk.linkedin.com/company/riseuporg', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;

  -- SAEP (South African Education Project)
  select id into v_category_id from categories where lower(name) = lower('Education / Youth (Cape Town)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Education / Youth (Cape Town)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('SAEP (South African Education Project)', v_category_id, 'South Africa', 'Philippi Cape Town. Dedicated Impact Centre for monitoring evaluation and research. Academic support + life skills + psycho-social support.', 'https://www.saep.org/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-26'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 47 802 7088', NULL);

  -- SchoolNet South Africa
  select id into v_category_id from categories where lower(name) = lower('Youth development / skills') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth development / skills', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('SchoolNet South Africa', v_category_id, 'South Africa', 'Ed-tech and skills NGO working with schools and youth across SA. Reports to funders including USAID and corporate CSI.', 'https://www.schoolnet.org.za', NULL, NULL, NULL, NULL, v_status_id, '2026-06-24'::date, 0, null)
  returning id into v_org_id;

  -- Second Step
  select id into v_category_id from categories where lower(name) = lower('Mental Health (Commissioned)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental Health (Commissioned)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Second Step', v_category_id, 'United Kingdom', 'Commissioned mental health services across Bristol & South West. Delivery partner on Changing Futures Bristol. Income ~£5–8m. 240 staff.', 'https://www.second-step.co.uk', NULL, 'https://www.second-step.co.uk/impact-report-2023/', NULL, NULL, v_status_id, '2026-06-17'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044117 909 6630', NULL);

  -- Shout It Now
  select id into v_category_id from categories where lower(name) = lower('HIV/health & youth') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('HIV/health & youth', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Shout It Now', v_category_id, 'South Africa', 'SA DoH partner; PEPFAR-funded HIV testing & PrEP mobilisation. Find via website or LinkedIn search.', 'https://shoutitnow.org/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-14'::date, 0, null)
  returning id into v_org_id;

  -- Sikhula Sonke
  select id into v_category_id from categories where lower(name) = lower('Early Childhood Development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Early Childhood Development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Sikhula Sonke', v_category_id, 'South Africa', 'ECD charity with Family and Community Motivator programme. Community-level data collection. Cape Town area.', 'https://www.sikhulasonke.org.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-29'::date, 0, null)
  returning id into v_org_id;

  -- Siyabonga Africa
  select id into v_category_id from categories where lower(name) = lower('Community development (all 9 provinces)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community development (all 9 provinces)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Siyabonga Africa', v_category_id, 'South Africa', '40+ years grassroots development across all 9 SA provinces. Explicitly markets robust M&E + real-time reporting to CSI funders.', 'https://www.siyabongaafrica.org.za', NULL, NULL, NULL, 'https://www.linkedin.com/company/siyabonga-africa', v_status_id, '2026-06-19'::date, 0, null)
  returning id into v_org_id;

  -- Sonke Gender Justice
  select id into v_category_id from categories where lower(name) = lower('Gender Equality NGO') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Gender Equality NGO', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Sonke Gender Justice', v_category_id, 'South Africa', 'Active Research M&E unit. Works across 20+ African countries on GBV HIV and gender equality. Cape Town & Johannesburg. 1st Floor Sir Lowry Studios 95 Sir Lowry Road Cape Town.', 'https://genderjustice.org.za', NULL, NULL, NULL, 'https://za.linkedin.com/company/sonke-gender-justice', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 423 7088', NULL);

  -- SOS Children's Villages SA
  select id into v_category_id from categories where lower(name) = lower('Youth development / ECD') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth development / ECD', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('SOS Children''s Villages SA', v_category_id, 'South Africa', 'Youth employability programmes running alongside ECD services. Track named children and young people from early childhood through to employment.', 'https://www.sossouthafrica.org.za', 'https://www.sossouthafrica.org.za/our-work/quality-care/youth-employability', NULL, NULL, NULL, v_status_id, '2026-06-27'::date, 0, null)
  returning id into v_org_id;

  -- Soul City Institute
  select id into v_category_id from categories where lower(name) = lower('Health / social justice') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Health / social justice', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Soul City Institute', v_category_id, 'South Africa', 'Health comms + social justice Johannesburg. CEO: Phinah Kodisang. Actively hiring M&E Officers. 5th Floor Sunnyside Office Park 32 Princess of Wales Terrace Parktown JHB.', 'https://www.soulcity.org.za', NULL, NULL, NULL, 'https://za.linkedin.com/company/soul-city-institute', v_status_id, '2026-06-13'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 11 341 0360', NULL);

  -- South East London Mind
  select id into v_category_id from categories where lower(name) = lower('Mental health (commissioned services)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental health (commissioned services)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('South East London Mind', v_category_id, 'United Kingdom', 'Mind affiliate delivering commissioned mental health services across South East London. Publishes impact reports.', 'https://selmind.org.uk/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-23'::date, 0, null)
  returning id into v_org_id;

  -- Sozo Foundation
  select id into v_category_id from categories where lower(name) = lower('Community Development (Youth)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Community Development (Youth)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Sozo Foundation', v_category_id, 'South Africa', 'Cape Flats Cape Town. Education + skills + enterprise for youth in poverty. Developing M&E on Salesforce. Faith-based org.', 'https://sozo.org.za/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-26'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+27 21 825 5529', NULL);

  -- Spitalfields Crypt Trust
  select id into v_category_id from categories where lower(name) = lower('Faith-based / Homelessness Recovery') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Faith-based / Homelessness Recovery', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Spitalfields Crypt Trust', v_category_id, 'United Kingdom', 'East London; substance misuse & homelessness recovery; commissioned by NHS and local authorities. Income ~£2–4m. New CEO since April 2025. Dave joined as Director of Services Aug 2025.', 'https://sct.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-17'::date, 0, null)
  returning id into v_org_id;

  -- Sport in Mind
  select id into v_category_id from categories where lower(name) = lower('Mental health / sport') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Mental health / sport', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Sport in Mind', v_category_id, 'United Kingdom', '31000+ people supported since 2010. Tracks 1000+ weekly participants. NHS commissioned. Reading-based.', 'https://www.sportinmind.org', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/5062026', NULL, NULL, v_status_id, '2026-06-24'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044300 102 1400', NULL);

  -- Sported
  select id into v_category_id from categories where lower(name) = lower('Sport for development (grassroots)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Sport for development (grassroots)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Sported', v_category_id, 'United Kingdom', 'Supports 3000+ grassroots community sport groups. Sarah Kaye = CEO. Jo Lloyd leads strategy and data insight. Laura Henshaw = Programmes Lead. 190 Great Dover Street London SE1 4YB.', 'https://sported.org.uk', NULL, NULL, NULL, 'https://www.linkedin.com/company/sported', v_status_id, '2026-06-19'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '+44 (0)20 3848 4670', NULL);

  -- Spurgeons
  select id into v_category_id from categories where lower(name) = lower('Faith-based / Children & Family') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Faith-based / Children & Family', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Spurgeons', v_category_id, 'United Kingdom', 'Faith-based children''s charity UK. Lorraine White is Director of Services & Practice. Commissioned services from local authorities. Income likely ~£5–10m.', 'https://spurgeons.org/', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/3962093', NULL, NULL, v_status_id, '2026-06-20'::date, 0, null)
  returning id into v_org_id;

  -- St Giles Trust
  select id into v_category_id from categories where lower(name) = lower('Youth employment (justice-involved)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth employment (justice-involved)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('St Giles Trust', v_category_id, 'United Kingdom', 'Helps people with experience of offending/homelessness/substance use into employment. 50+ years. London HQ. Georgian House, 64–68 Camberwell Church St, London SE5 8JB.', 'https://www.stgilestrust.org.uk/who-we-are', NULL, 'https://register-of-charities.charitycommission.gov.uk/charity-details/?regId=801355', 'https://www.stgilestrust.org.uk/app/uploads/2025/12/St-Giles-Annual-Review-2025-25-compressed-1.pdf', NULL, v_status_id, '2026-06-28'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00441473 557380', NULL);

  -- Step by Step
  select id into v_category_id from categories where lower(name) = lower('Youth homelessness prevention') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth homelessness prevention', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Step by Step', v_category_id, 'United Kingdom', 'Youth homelessness prevention across Hampshire / Surrey / Dorset / Wiltshire. Debbie Moreton = CEO. 36 Crimea Road Aldershot Hampshire GU11 1UD.', 'https://www.stepbystep.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-27'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '00441252 346100', NULL);

  -- Street League
  select id into v_category_id from categories where lower(name) = lower('Sport-Based Youth Employability') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Sport-Based Youth Employability', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Street League', v_category_id, 'United Kingdom', 'National charity using sport to get unemployed young people into work. 20+ years. CEO: Dougie Stevenson. Manchester HQ. Charity reg 1101313. £6.6m income (2024); 100+ staff.', 'https://www.streetleague.co.uk', NULL, 'https://register-of-charities.charitycommission.gov.uk/charity-details/?regId=1101313&subid=0', 'https://annualreports.streetleague.co.uk/18/', 'https://www.linkedin.com/company/street-league', v_status_id, '2026-06-12'::date, 0, null)
  returning id into v_org_id;

  -- StreetGames
  select id into v_category_id from categories where lower(name) = lower('Sport / Community') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Sport / Community', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('StreetGames', v_category_id, 'United Kingdom', 'National. 1500+ local community sport providers in deprived areas. Dedicated Research & Insight team. Vicky Weir is a good warm-up contact.', 'https://www.streetgames.org', 'https://www.streetgames.org/about-us/meet-the-team/senior-leadership-team/', 'https://www.streetgames.org/resources/finance-and-governance/', 'https://www.streetgames.org/wp-content/uploads/2026/01/StreetGames-UK-Accounts-2025.pdf', NULL, v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;
  insert into office_locations (organisation_id, location_name, phone_number, availability) values (v_org_id, 'Main office', '0044161 480 8383', NULL);

  -- Thandulwazi
  select id into v_category_id from categories where lower(name) = lower('Education') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Education', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('Thandulwazi', v_category_id, 'South Africa', 'Maths + science education from St John''s College Johannesburg. Teacher training + learner support.', 'https://www.stithian.com/thandulwazi', NULL, 'https://www.stithian.com/uploads/files/Thandulwazi/2025/Thandulwazi-AnnReport-2024-LOWRes.pdf', NULL, NULL, v_status_id, '2026-06-21'::date, 0, null)
  returning id into v_org_id;

  -- The Access Project
  select id into v_category_id from categories where lower(name) = lower('Youth Education') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth Education', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('The Access Project', v_category_id, 'United Kingdom', 'University access tutoring for disadvantaged students. 2013 students, 40 schools, 15 years old. Charity 1143011.', 'https://theaccessproject.org.uk', NULL, NULL, NULL, NULL, v_status_id, '2026-06-25'::date, 0, null)
  returning id into v_org_id;

  -- The Bread and Butter Thing
  select id into v_category_id from categories where lower(name) = lower('Food poverty') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Food poverty', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('The Bread and Butter Thing', v_category_id, 'United Kingdom', 'Membership model tracks named individuals week-on-week (100k+ member families; 145 food clubs). COO owns operations and impact infrastructure.', 'https://www.breadandbutterthing.org', NULL, NULL, NULL, NULL, v_status_id, '2026-06-10'::date, 0, null)
  returning id into v_org_id;

  -- The Clink Charity
  select id into v_category_id from categories where lower(name) = lower('Criminal justice / employment') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Criminal justice / employment', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('The Clink Charity', v_category_id, 'United Kingdom', 'Trains prisoners in hospitality skills to reduce reoffending. 400+ individuals tracked per year. New CEO in 2025. Neil Delahay is likely the operational champion.', 'https://theclinkcharity.org', NULL, 'https://register-of-charities.charitycommission.gov.uk/en/charity-search/-/charity-details/4049671/contact-information', NULL, NULL, v_status_id, '2026-06-24'::date, 0, null)
  returning id into v_org_id;

  -- The Clothing Bank
  select id into v_category_id from categories where lower(name) = lower('Women''s employability / social development') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Women''s employability / social development', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('The Clothing Bank', v_category_id, 'South Africa', 'Founded 2010. 800 mothers trading across 5 branches (Cape Town/Joburg/Durban/East London/Paarl).', 'https://www.theclothingbank.co.za', NULL, NULL, NULL, NULL, v_status_id, '2026-06-28'::date, 0, null)
  returning id into v_org_id;

  -- The Dash Charity
  select id into v_category_id from categories where lower(name) = lower('Domestic Abuse (Commissioned)') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Domestic Abuse (Commissioned)', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('The Dash Charity', v_category_id, 'United Kingdom', 'Commissioned domestic abuse service (RBWM). Monthly monitoring reports to commissioners.', 'https://www.thedashcharity.org.uk/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-26'::date, 0, null)
  returning id into v_org_id;

  -- The Girls' Network
  select id into v_category_id from categories where lower(name) = lower('Youth / Girls'' Mentoring') limit 1;
  if v_category_id is null then
    insert into categories (name, sort_order) values ('Youth / Girls'' Mentoring', (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;
  end if;
  select id into v_status_id from statuses where name = 'Not Contacted' limit 1;
  insert into organisations (name, category_id, country, angle, website, team_page, annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)
  values ('The Girls'' Network', v_category_id, 'United Kingdom', 'Girls from disadvantaged communities connected to female mentors. Active MERL Manager role. Income est. ~£1–2m.', 'https://www.thegirlsnetwork.org.uk/', NULL, NULL, NULL, NULL, v_status_id, '2026-06-20'::date, 0, null)
  returning id into v_org_id;

end $$;

alter table organisations enable trigger organisations_status_change;
