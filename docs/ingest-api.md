# Ingest API — conventions and rules

This doc covers the *why* and the *rules* behind `/api/ingest/*`. For exact, current field names and query params, always fetch `GET /api/ingest/openapi.json` first — that's generated from the route code and won't go stale the way this doc could.

This file is a mirror of the schema/API-relevant parts of two external reference docs that the prospecting and backfill agents work from. The external docs remain the source of truth for anything about *sales strategy* — the Ideal Customer Profile, segment definitions, discovery questions, disqualifiers, etc. Only the parts that affect how code should behave are duplicated here, so a Claude Code cloud session (which can't read Google Drive) still has them.

- Makerble Prospect Research Routine (daily net-new prospecting, target: 20 orgs/day)
- Makerble CallFlow Backfill Routine (fills gaps in existing organisations, target: 10–15 orgs/run)

Both docs live in Google Drive and are the authoritative source for agent *behaviour*. If you change ingest API behaviour in this repo, update those docs too (and say so in your PR/commit message) — see the maintenance note in the main README.

## Who calls this API
Claude Code routines (or other agents) doing either:
1. **Prospecting** — finding brand-new organisations that fit the ICP and writing them in.
2. **Backfill** — picking up existing organisations with gaps (no staff, no Segment, missing website/phone) and filling them in.

Both are expected to identify themselves via a required `created_by` field, e.g. `"agent:callflow-prospecting-routine"` or `"agent:callflow-backfill-routine"` — distinct values per routine so Matt can tell them apart in CallFlow's "Added by" field.

## Hard rules

**Never write placeholder text.** If a field genuinely can't be found (email, phone, LinkedIn, anything), leave the database column `null`/omitted. Never write `"find on website"`, `"TBC"`, `"unknown"`, `"n/a"`, or a hedge like `"Ali (surname TBC)"`. A record with real gaps is more useful than one padded with fake-looking data — and it's especially important in backfill work, where a sloppy placeholder is more likely to get mistaken for something someone actually verified.

**No delete endpoint, by design.** This was deliberately not built, because of mass-deletion risk. Don't add one without explicit sign-off, however convenient it would be for a cleanup task.

**Only touch what you're actually changing.** The ingest API only updates fields explicitly included in a request — it will not clear a field you leave out. Don't resend fields you're confident are already correct; only include a field when you have new/better information for it. This also means requests can be minimal (e.g. just a phone number) rather than reconstructing the whole record.

**Always check the `warnings` array.** Unrecognised fields are ignored, not rejected — but they show up in `warnings`, so a silently-wrong field name won't get silently dropped without a trace.

**Segments are a fixed list — don't invent new ones.** Query `select name from segments order by sort_order` for the current list. If nothing genuinely fits, leave `segment_id` null rather than forcing a loose match. A recurring need for a segment that doesn't exist should be flagged for Matt to decide on, not added unilaterally.

## De-duplication (organisations)

Before adding any organisation:
1. Check its name against the exclusion list (current/former Makerble customers — case-insensitive, ignoring punctuation/whitespace) — never add a match.
2. Query the `organisations` table for an existing row (`GET /api/ingest/organisations?q=...`, or a direct `ilike` query for near-duplicates) — never create a duplicate row. If new information exists for an org that's already there, add that instead.

## De-duplication (staff) — backfill-specific risk

Backfill work edits organisations that may already have staff on file, which creates a specific risk that fresh prospecting doesn't have: accidentally adding a second row for someone already there under a slightly different name. This has actually happened (`"Garth Japhet"` vs `"Dr Garth Japhet"`). Watch for:
- Titles/honorifics added or dropped
- Initials vs full first name (`"J Smith"` vs `"Jane Smith"`)
- Minor spelling/formatting differences
- Same role/title, different name spelling

Before adding a staff member during backfill, check the existing `staff` array (included in the `GET /api/ingest/organisations` response) for a likely match. If found, **update the existing row by including its `id`** rather than adding a new one — err toward treating an ambiguous case as the same person, since a merged record is easy to split later if wrong, but a duplicate is a mess to clean up.

## Backfill targeting modes

`GET /api/ingest/organisations` supports mutually-exclusive query params for finding what needs work, each with its own "longest since last checked" ordering so agents naturally work through a backlog rather than circling the same few unfindable orgs:

| Param | Finds |
|---|---|
| `gaps_only=true` | No Segment set, or zero linked staff |
| `missing_department=<name>` | No staff member in that Department (e.g. `Impact / MERL`), even if other staff/a Segment exist |
| `missing_phone=true` | No phone number on any `office_locations` row |
| `missing_segment=true` | No Segment assigned, even if staff/phone already exist |

Always submit *something* for every organisation picked up from a backfill batch — even a minimal `POST` with just the org name marks it as checked and moves it to the back of the relevant queue via `mark_checked`. Silently skipping an org that couldn't be progressed leaves it permanently at the front of the backlog.

## Staff-finding checklist

Before concluding no one can be found for an organisation, work through this in order — don't stop after one generic search query:

1. Visit the org's actual website directly: `/about`, `/about-us`, `/who-we-are`, `/team`, `/our-team`, `/meet-the-team`, `/staff`, `/leadership`, `/management-team`, `/governance`, `/contact`, `/contact-us`.
2. Check the site's main navigation/footer for a Team or About link if none of the above resolve.
3. Check the org's LinkedIn company page → "People" tab, especially for M&E/Programmes/Operations/CEO roles.
4. Check the Charity Commission register (or equivalent regulator) for trustee/senior staff names.

Prioritise finding whoever holds (or is closest to) an Impact/M&E/Data/Programmes role — that's the buyer per the ICP.

## Credentials

`CALLFLOW_INGEST_API_KEY` is read from environment configuration — never paste it into a prompt, commit, or chat message. If it's missing or a request 401s, stop and flag it; don't fall back to a raw database write path.
