@AGENTS.md

# CallFlow — Project Memory

Internal CRM-style sales tool for Makerble (nonprofit M&E/beneficiary-tracking platform). Used by Matt Kepple to run outbound business development against charities/NGOs in the UK, South Africa, and other English-speaking geographies. See `README.md` for the full page-by-page feature overview and data model; see `docs/ingest-api.md` for the rules/conventions behind the ingest API used by the prospecting and backfill agents. This file covers infra, conventions, and gotchas that aren't obvious from the code.

**Maintenance:** update `README.md` (features), this file (infra/conventions), and/or `docs/ingest-api.md` (ingest API rules) in the same push whenever you change what they describe — see the note at the top of the README.

## Infrastructure
- **Supabase project ID:** `woioapeixdklqnkvpdih`
- **Vercel project ID:** `prj_o6d8F2an6gbA4lv9HeWymPAvxT60`
- **Vercel team ID:** `team_fLGqS60NafLSnM5AicLN4Py9` ("Makerble Impact") — when using the Vercel MCP, always pass this `teamId`, or CallFlow won't appear in results.
- **Production URL:** https://call-flow-delta.vercel.app
- **Ingest API key:** stored as `CALLFLOW_INGEST_API_KEY` in Vercel environment variables. Read from environment only — never hardcode it or paste it into a commit, config file, or chat message.

## Gotchas
- If a push reaches GitHub but Vercel doesn't deploy, an empty commit (`git commit --allow-empty`) reliably retriggers the webhook.
- Matt has multiple Supabase accounts. Before running Supabase MCP operations, confirm the connected account owns `woioapeixdklqnkvpdih`.
- Multi-statement SQL must be run as separate `execute_sql` calls — the Supabase MCP doesn't support multi-statement single calls.
- `security_invoker = true` on a view can silently return zero rows for the querying role. Prefer definer-style views.
- There is deliberately **no delete endpoint** on the ingest API (mass-deletion risk). Don't add one without Matt's explicit sign-off.

## Conventions
- Stretch-fit judgement calls from the prospecting/backfill agents can be written directly into records, with rationale captured in `background_notes` — no need to hold them for manual review.
- Ingest API endpoints only update fields explicitly included in a request; omitted fields are left untouched. Never write placeholder text (`"TBC"`, `"find on website"`, `"unknown"`, etc.) into a data field — leave it blank/omitted instead.
- Agent instruction docs (kept outside this repo, in Google Docs) must be updated whenever ingest API behaviour changes here.
- When diagnosing an agent's reported outcome, verify against actual database state rather than trusting the agent's self-report.
- Prefer separate, dedicated agent routines over adding complexity/branches to an existing one.

## Credentials
- GitHub PATs are provided per-session by Matt and rotated afterward. Never store one in code, config, `.env` files, or commit history.

## Working style
- Matt provides requirements and raw materials (transcripts, notes, spreadsheets) and expects end-to-end implementation: schema migrations, code, and deployment.
- He engages architecture and pricing-style questions as genuine strategic choices — lay out explicit pros/cons before recommending.
