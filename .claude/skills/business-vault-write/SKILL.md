# Skill: /business-vault-write

## When to activate

Activate when Chief (or, pre-deploy, Pat directly) asks to create or update a
note at a path inside `Business/`. Also activate on "write this to
Business/{path}", "create a note at Business/{path}", "update {path}" (when
the path resolves inside `Business/`), or "save this content into the
business vault".

**Do not confuse this with Cornelius's own KB-writing skills/agents**
(`vault-manager`, `insight-extractor`, `graduate-insights`, etc.) — those
target `Brain/` and friends and follow Zettelkasten rules. This skill only
ever touches `Business/` and follows `resources/business-vault/RULES.md`.

## What this skill does

Creates or updates a note at a given `Business/` path with given content and
frontmatter. Before **any** write, this skill validates the target against
the hard boundaries in `resources/business-vault/RULES.md`. If the write
would violate a rule, it refuses, cites the specific rule, and asks — it
never silently complies and never silently deviates. Moving files between
folders is not this skill's job — that is `/business-vault-route`.

## Pre-Write Validation Gates

**Gate 0 — Containment (checked first, before every other gate):** resolve
the target path. If it does not resolve inside `Business/`, refuse
immediately — no override, no "unless approved" clause.

```
### Refused — Out of Scope
Target: {path}
Reason: business-vault write/route authority is scoped to Business/ only.
Instead: {redirect — e.g. "ask Pat directly" / "use a KB skill instead if this belongs in Brain/"}
```

Only once Gate 0 passes do the remaining gates below apply.

Run every gate before writing. Any failure stops the write and returns the
rule.

| Target | Rule | Action |
|--------|------|--------|
| `Business/07-ARCHIVE/promoted/` | Rule 5 — Archive Immutability | Refuse. Direct the requester to the draft flow. |
| `resources/business-vault/` | Rule 6 — Governance-Folder Purity | Refuse. This path never receives outputs, logs, or history. |
| Existing file, no "overwrite"/"update" in request | Guardrail | Confirm before clobbering — show what exists first. |

## Workflow

### Step 1 — Parse the write request

Identify the target path, the content, and the frontmatter to write.
Determine whether the request explicitly says "overwrite" or "update"
(permission to replace an existing file) or is a create-only request.

### Step 2 — Run the validation gates

Check the target against Gate 0 first, then every gate in the table above. If
any gate fails, stop and respond in this form:

```
### Refused — {Gate 0 | Rule N}
Target: {path}
Reason: {one-sentence statement of the rule}
Instead: {the correct path forward}
```

Do not write anything when a gate fails. Ask, don't guess.

### Step 3 — Confirm overwrites

If the target already exists and the request did not say "overwrite"/"update",
show what is currently there and ask before replacing it:

```
### File exists — confirm overwrite
Target: {path}
Currently: {one-line summary or first lines of existing content}
Reply "overwrite" to replace, or tell me to write to a different path.
```

For a brand-new path, or when overwrite was explicitly authorized, skip
straight to Step 4.

### Step 4 — Write and report

Perform the write. Then report exactly what happened:

```
### Written — {path}
**Action:** {created | updated}
**Frontmatter:** {keys written, or "none"}
**Bytes/lines:** {size written}
```

Report the real, resulting state — never claim a write that did not
complete.

## Output style

- Lead with the result — the refusal block, the confirm prompt, or the
  written block — no preamble
- Always cite the specific rule number when refusing
- Never overwrite an existing file without explicit permission or
  confirmation
- State exactly what was written and where — path, action, frontmatter
- One clarifying question maximum when the target or content is ambiguous
