import re

INPUT = "raw_staff.tsv"
OUTPUT = "004_import_staff.sql"

HEAD_WORDS = ["ceo", "chief", "director", "founder", "chair", "coo", "co-founder", "executive director", "managing director"]
MANAGER_WORDS = ["manager", "officer", "coordinator", "lead", "analyst", "specialist"]


ALIASES = {
    "church urban fund (cuf)": "Church Urban Fund",
    "leap science & maths schools": "LEAP Science and Maths Schools",
    "resurgo trust / spear": "Resurgo (Spear)",
    "resurgo – spear programme": "Resurgo (Spear)",
    "sported foundation": "Sported",
    "the mason foundation": "Mason Foundation",
    "the sozo foundation": "Sozo Foundation",
}


def esc(s):
    if s is None:
        return "NULL"
    s = s.strip()
    if s == "":
        return "NULL"
    return "'" + s.replace("'", "''") + "'"


def guess_seniority(job_title):
    if not job_title:
        return None
    t = job_title.lower()
    if any(w in t for w in HEAD_WORDS):
        return "Head / Director"
    if any(w in t for w in MANAGER_WORDS):
        return "Manager"
    return None


def split_multi(name_field, title_field):
    """If both name and title contain the same number of ';' or ' / ' separated
    segments, split into separate (name, title) pairs. Otherwise return as one."""
    for sep in (";", " / "):
        if sep in name_field and sep in title_field:
            names = [n.strip() for n in name_field.split(sep)]
            titles = [t.strip() for t in title_field.split(sep)]
            if len(names) == len(titles) and len(names) > 1:
                return list(zip(names, titles))
    return [(name_field.strip(), title_field.strip())]


rows = []
with open(INPUT, encoding="utf-8") as f:
    lines = f.readlines()

for line in lines[1:]:
    line = line.rstrip("\n")
    if not line.strip():
        continue
    cells = line.split("\t")
    cells += [""] * (7 - len(cells))
    org, full_name, job_title, department, email, linkedin, notes = [c.strip() for c in cells[:7]]
    if not org or not full_name:
        continue
    org = ALIASES.get(org.lower(), org)
    rows.append((org, full_name, job_title, department, email, linkedin, notes))

people = []
for org, full_name, job_title, department, email, linkedin, notes in rows:
    for name, title in split_multi(full_name, job_title):
        # strip a trailing parenthetical from the name onto the title if title is empty
        m = re.match(r"^(.*?)\s*\(([^)]+)\)\s*$", name)
        if m and not title:
            name, title = m.group(1).strip(), m.group(2).strip()
        people.append({
            "org": org,
            "name": name,
            "title": title,
            "department": department,
            "email": email,
            "linkedin": linkedin,
            "notes": notes,
        })

# Dedupe exact (org, name) pairs, merging any extra info from later duplicates
merged = {}
order = []
for p in people:
    key = (p["org"].lower(), p["name"].lower())
    if key not in merged:
        merged[key] = p
        order.append(key)
    else:
        existing = merged[key]
        for field in ("title", "department", "email", "linkedin", "notes"):
            if not existing[field] and p[field]:
                existing[field] = p[field]

final_people = [merged[k] for k in order]

with open(OUTPUT, "w", encoding="utf-8") as out:
    out.write("-- One-time bulk import of the consolidated Staff tab.\n")
    out.write("-- Run in the Supabase SQL Editor AFTER migrations 001-003.\n")
    out.write("-- Matches each person to an existing Organisation by exact (case-insensitive)\n")
    out.write("-- name. If no match is found, a bare new Organisation is created (name only,\n")
    out.write("-- status 'Not Contacted') so the person isn't orphaned -- these are listed at\n")
    out.write("-- the end of this file's output for your attention.\n\n")
    out.write("do $$\n")
    out.write("declare\n")
    out.write("  v_department_id uuid;\n")
    out.write("  v_seniority_id uuid;\n")
    out.write("  v_org_id uuid;\n")
    out.write("  v_status_id uuid;\n")
    out.write("begin\n")

    for p in final_people:
        seniority = guess_seniority(p["title"])
        out.write(f"  -- {p['org']} :: {p['name']}\n")

        out.write(f"  select id into v_org_id from organisations where lower(name) = lower({esc(p['org'])}) limit 1;\n")
        out.write("  if v_org_id is null then\n")
        out.write("    select id into v_status_id from statuses where name = 'Not Contacted' limit 1;\n")
        out.write(
            f"    insert into organisations (name, status_id, date_spotted) values ({esc(p['org'])}, v_status_id, current_date) returning id into v_org_id;\n"
        )
        out.write("  end if;\n")

        if p["department"]:
            out.write(
                f"  select id into v_department_id from departments where lower(name) = lower({esc(p['department'])}) limit 1;\n"
            )
            out.write("  if v_department_id is null then\n")
            out.write(
                f"    insert into departments (name, sort_order) values ({esc(p['department'])}, (select coalesce(max(sort_order),0)+1 from departments)) returning id into v_department_id;\n"
            )
            out.write("  end if;\n")
        else:
            out.write("  v_department_id := null;\n")

        if seniority:
            out.write(f"  select id into v_seniority_id from seniority_levels where name = {esc(seniority)} limit 1;\n")
        else:
            out.write("  v_seniority_id := null;\n")

        out.write(
            "  insert into staff (organisation_id, department_id, seniority_id, full_name, job_title, email, linkedin, conversation_notes)\n"
        )
        out.write(
            f"  values (v_org_id, v_department_id, v_seniority_id, {esc(p['name'])}, {esc(p['title'])}, {esc(p['email'])}, {esc(p['linkedin'])}, {esc(p['notes'])});\n\n"
        )

    out.write("end $$;\n")

print(f"Parsed {len(rows)} rows -> {len(people)} people -> {len(final_people)} after dedup")
