import re
from datetime import datetime

INPUT = "raw_orgs.md"
OUTPUT = "003_import_organisations.sql"

COUNTRY_MAP = {
    "uk": "United Kingdom",
    "uk (scotland)": "United Kingdom",
    "uk (northern ireland)": "United Kingdom",
    "scotland": "United Kingdom",
    "za": "South Africa",
    "sa": "South Africa",
    "south africa": "South Africa",
    "za south africa": "South Africa",
    "australia": "Australia",
    "ireland": "Ireland",
    "kenya": "Kenya",
    "canada": "Canada",
    "africa (ghana)": "Ghana",
    "africa (nigeria)": "Nigeria",
}


def esc(s):
    if s is None:
        return "NULL"
    s = s.strip()
    if s == "":
        return "NULL"
    return "'" + s.replace("'", "''") + "'"


def parse_date(raw):
    raw = raw.strip()
    try:
        dt = datetime.strptime(raw, "%d %B %Y")
        return dt.strftime("%Y-%m-%d")
    except ValueError:
        return None


def split_phone(raw):
    raw = raw.strip()
    if not raw:
        return None, None
    m = re.search(r"\(([^)]+)\)\s*$", raw)
    if m:
        avail = m.group(1).strip()
        phone = raw[: m.start()].strip()
        return phone or None, avail or None
    return raw, None


def normalize_country(raw):
    raw = raw.strip()
    key = raw.lower()
    return COUNTRY_MAP.get(key, raw)


rows = []
with open(INPUT, encoding="utf-8") as f:
    lines = [l.rstrip("\n") for l in f if l.strip().startswith("|")]

# first line is header
for line in lines[1:]:
    cells = [c.strip() for c in line.strip().strip("|").split("|")]
    if len(cells) < 13:
        cells += [""] * (13 - len(cells))
    rows.append(cells)

seen_names = {}
statements = []

for cells in rows:
    date_spotted_raw, country_raw, category, name, angle, status, call_attempts_raw, \
        website, team_page, annual_report, impact_report, phone_raw, linkedin = cells[:13]

    if not name:
        continue

    key = name.strip().lower()
    if key in seen_names:
        # merge angle text into the first-seen row, skip creating a duplicate org
        seen_names[key]["angle"] += " | " + angle.strip()
        continue

    date_spotted = parse_date(date_spotted_raw) or "2026-06-01"
    country = normalize_country(country_raw)
    call_attempts = int(call_attempts_raw) if call_attempts_raw.strip().isdigit() else 0
    phone, availability = split_phone(phone_raw)
    has_interaction = status.strip() not in ("", "Not Contacted")

    record = {
        "name": name.strip(),
        "category": category.strip(),
        "angle": angle.strip(),
        "status": status.strip() or "Not Contacted",
        "call_attempts": call_attempts,
        "website": website.strip(),
        "team_page": team_page.strip(),
        "annual_report": annual_report.strip(),
        "impact_report": impact_report.strip(),
        "linkedin": linkedin.strip(),
        "phone": phone,
        "availability": availability,
        "country": country,
        "date_spotted": date_spotted,
        "has_interaction": has_interaction,
    }
    seen_names[key] = record

with open(OUTPUT, "w", encoding="utf-8") as out:
    out.write("-- One-time bulk import of consolidated prospect research.\n")
    out.write("-- Run in the Supabase SQL Editor AFTER migrations 001 and 002.\n")
    out.write("-- Disables the status-change trigger during import so historical\n")
    out.write("-- Date spotted / Call Attempts aren't double-counted or overwritten,\n")
    out.write("-- then re-enables it and manually inserts matching status_history rows.\n\n")
    out.write("alter table organisations disable trigger organisations_status_change;\n\n")
    out.write("do $$\n")
    out.write("declare\n")
    out.write("  v_category_id uuid;\n")
    out.write("  v_status_id uuid;\n")
    out.write("  v_org_id uuid;\n")
    out.write("begin\n")

    for r in seen_names.values():
        out.write("  -- " + r["name"].replace("--", "-") + "\n")
        if r["category"]:
            out.write(
                f"  select id into v_category_id from categories where lower(name) = lower({esc(r['category'])}) limit 1;\n"
            )
            out.write("  if v_category_id is null then\n")
            out.write(
                f"    insert into categories (name, sort_order) values ({esc(r['category'])}, (select coalesce(max(sort_order),0)+1 from categories)) returning id into v_category_id;\n"
            )
            out.write("  end if;\n")
        else:
            out.write("  v_category_id := null;\n")

        out.write(
            f"  select id into v_status_id from statuses where name = {esc(r['status'])} limit 1;\n"
        )

        out.write("  insert into organisations (name, category_id, country, angle, website, team_page, "
                   "annual_report, impact_report, linkedin, status_id, date_spotted, call_attempts, last_interaction_at)\n")
        last_interaction = f"'{r['date_spotted']}'::timestamptz" if r["has_interaction"] else "null"
        out.write(
            f"  values ({esc(r['name'])}, v_category_id, {esc(r['country'])}, {esc(r['angle'])}, "
            f"{esc(r['website'])}, {esc(r['team_page'])}, {esc(r['annual_report'])}, {esc(r['impact_report'])}, "
            f"{esc(r['linkedin'])}, v_status_id, {esc(r['date_spotted'])}::date, {r['call_attempts']}, {last_interaction})\n"
        )
        out.write("  returning id into v_org_id;\n")

        if r["phone"] or r["availability"]:
            out.write(
                f"  insert into office_locations (organisation_id, location_name, phone_number, availability) "
                f"values (v_org_id, 'Main office', {esc(r['phone'])}, {esc(r['availability'])});\n"
            )

        if r["status"] != "Not Contacted":
            out.write(
                f"  insert into status_history (organisation_id, status_id, changed_at) "
                f"values (v_org_id, v_status_id, {esc(r['date_spotted'])}::timestamptz);\n"
            )

        out.write("\n")

    out.write("end $$;\n\n")
    out.write("alter table organisations enable trigger organisations_status_change;\n")

print(f"Wrote {len(seen_names)} organisations to {OUTPUT}")
