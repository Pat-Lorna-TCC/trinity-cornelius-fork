# Business Vault — Hard Boundaries

> Enforceable rules for Cornelius's business-vault mediation facet. These are
> not preferences — they are gates. Violating a rule requires explicit Pat
> approval AND the corresponding gate. Ported from `trinity-obsidian-vault`'s
> `.agent/RULES.md` (that agent, retired 2026-07-11, was the original
> single-writer mediator for this content) — same rule numbers, same
> semantics, path scope moved from `Trinity-SCS-Vault/` to `Business/`.

---

## Rule 0 — Two-Way Containment (NEW, not in the original)

`Business/` and Cornelius's knowledge base (`Brain/`, `AI Extracted Notes/`,
`Document Insights/`, etc.) are fully segregated, enforced from both sides:

- The `business-vault-*` skills refuse any target that does not resolve
  inside `Business/` — see Rule 1 / Gate 0 below.
- KB-facing skills and sub-agents (`vault-manager`, `insight-extractor`,
  `document-insight-extractor`, `graduate-insights`, `git-commit-push`, etc.)
  never target `Business/`. Business-process hygiene rules (SLA, expiry,
  archive immutability) do not make sense applied to permanent Zettelkasten
  notes, and KB rules (Zettelkasten atomicity, provenance tagging) do not
  apply to routed business items.

**No gate — this is a structural invariant, not a policy.**

---

## Rule 1 — Single Writer, Scoped to `Business/`

Cornelius is the **only** agent with write access to this content, and that
write access is **hard-scoped to `Business/` only** — no override, not even an
explicit one-off request (unlike Rule 7's read-only-root exception, which does
allow an explicit approval). Reads are unrestricted; this scoping applies to
write and route only.

- Chief requests business-vault operations through Cornelius via
  `mcp__trinity__chat_with_agent` — never touches vault files directly.
- `business-vault-write` and `business-vault-route` enforce this as **Gate
  0** — the first check, before any other gate in this file — refusing any
  target that does not resolve inside `Business/`.
- Delete capability does not exist in any business-vault skill and is out of
  scope for this round.

**No gate — this is a structural invariant, not a policy.**

---

## Rule 2 — Inbox SLA

Nothing stays unrouted in `Business/00-INBOX/` more than 48 hours without
flagging it.

- `/business-vault-health-check` scans for this on every run.
- Flag, don't auto-route — routing is Chief's decision, not Cornelius's.

**No gate — enforced on every health-check run.**

---

## Rule 3 — Draft Expiry

`Business/02-DRAFTS/` items older than 14 days get flagged.

**No gate — enforced on every health-check run.**

---

## Rule 4 — Review Expiry

`Business/03-REVIEW/` items older than 7 days get flagged.

**No gate — enforced on every health-check run.**

---

## Rule 5 — Archive Immutability

`Business/07-ARCHIVE/promoted/` is never edited. Changes go back through the
draft flow.

- If a `business-vault-write` or `business-vault-route` request targets this
  path, refuse and say so — direct the requester to the draft flow instead.

**Gate to lift:** none. This is a structural invariant.

---

## Rule 6 — Governance-Folder Purity

No outputs, logs, or history get written into `resources/business-vault/`
(this rules doc's own home) via any business-vault skill.

**No gate — this rule has no override.**

---

## Rule 7 — Read-Only Roots

None declared yet for `Business/` — added here for numbering parity with the
original rule set. If a read-only root is needed later (e.g. a `STANDARDS/`
folder), it follows the same shape: never edited, moved, or generated into
without Pat's explicit one-off approval.

**Gate to lift:** Pat's explicit one-off approval, per request — not a
standing gate.

---

## Rule 8 — No Orphan Routes

Every item moved out of `Business/00-INBOX/` gets a date-stamped filename and
tracking metadata: owner, due date (or explicit "no due date"), and whether a
task is required downstream.

- `business-vault-route` refuses to complete a move without this metadata
  present.

**No gate — enforced on every route operation.**

---

## Rule 9 — Destructive Ops Are Gated

No deletion without explicit confirmation in the request.

- "Delete X" is not sufficient on its own if X wasn't named explicitly by Pat
  or Chief in the same request — ask before deleting anything not named.

**Gate to lift:** explicit confirmation in the request itself, every time —
never a standing exemption.

---

## Rule 10 — Dry-Run Before Real

Prove one capability against a test fixture in `Business/` before any real
business-vault write is attempted against content Chief actually cares about.

**Gate to lift:** Pat/Chief approval for the first real write to a given new
capability or target.

---

## Provenance

These rules were originally authored for `trinity-obsidian-vault` (in turn
ported from `John/CHIEF-OF-STAFF.md`'s vault hygiene rules). That agent is
retired as of 2026-07-11 — see its `ARCHITECTURE.md`. This doc is the living
copy going forward; the original is kept in that repo's history for
provenance only.
