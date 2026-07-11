# Skill: /business-vault-health-check

## When to activate

Activate when Chief asks for a hygiene scan of the business vault, when the
scheduled cron fires via `/scheduled-run business-vault-health-check`, or on
"business vault health check", "scan the business vault", "any hygiene
violations", or "what's overdue in Business". This report feeds Chief's
daily briefing. Not to be confused with Cornelius's own KB tools
(`/self-diagnostic`, `/coherence-sweep`) — those scan `Brain/`, this scans
`Business/` only.

## What this skill does

Scans `Business/` for violations of the enforceable hygiene rules in
`resources/business-vault/RULES.md` and produces a structured violations
report. This skill is **read-only** — it flags, it never routes or fixes.
Routing and remediation are Chief's decisions; this report is what Chief
consumes to make them.

If the scan finds nothing, still deliver the report with explicit
empty-state language ("None") for each section — a clean vault is a valid,
reportable result.

## Rules Scanned

| Check | Rule | Threshold |
|-------|------|-----------|
| Inbox SLA | Rule 2 | `Business/00-INBOX/` items unrouted more than 48h |
| Draft expiry | Rule 3 | `Business/02-DRAFTS/` items older than 14 days |
| Review expiry | Rule 4 | `Business/03-REVIEW/` items older than 7 days |
| Orphan files | Rule 8 | Files with no clear routing/owner metadata sitting outside `Business/00-INBOX/` |
| Governance-folder purity | Rule 6 | Any outputs, logs, or history written into `resources/business-vault/` |

## Workflow

### Step 1 — Scan the inbox (Rule 2)

List `Business/00-INBOX/`. For each item, compute its age. Flag every item
older than 48 hours as an inbox SLA violation. Flag — do not route. Routing
is Chief's call.

### Step 2 — Scan drafts and review (Rules 3 & 4)

List `Business/02-DRAFTS/` and flag items older than 14 days. List
`Business/03-REVIEW/` and flag items older than 7 days. Record each flagged
item's name and age.

### Step 3 — Scan for orphans (Rule 8)

Look for files that lack the required tracking metadata (owner, due date,
task-required) yet sit outside `Business/00-INBOX/` — i.e. items that were
moved without being properly routed. Each is an orphan violation.

### Step 4 — Check governance-folder purity (Rule 6)

Inspect `resources/business-vault/`. Any outputs, logs, or history there is a
purity violation — that directory must stay clean (rules doc only).

### Step 5 — Deliver the report

Output the report in this exact format:

```
## Business Vault Health Check — {YYYY-MM-DD}

### Inbox SLA (Rule 2 — >48h)
{list flagged items with age, or "None"}

### Draft Expiry (Rule 3 — >14d)
{list flagged items with age, or "None"}

### Review Expiry (Rule 4 — >7d)
{list flagged items with age, or "None"}

### Orphan Files (Rule 8)
{list files missing routing/owner metadata, or "None"}

### Governance-Folder Purity (Rule 6)
{list polluting paths, or "None"}

---
Total violations: {N} | Scanned: {YYYY-MM-DD HH:MM}
```

Do not add sections. Do not recommend actions — Chief decides what to do
about each violation.

## Output style

- Lead with the report header — no preamble
- One section per rule, always present, "None" when clean
- Flag, never fix — this skill has no write path
- Every flagged item carries its age or the specific reason it violates
- Close with the total count and scan timestamp — nothing more
