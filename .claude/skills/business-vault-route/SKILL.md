# Skill: /business-vault-route

## When to activate

Activate when Chief asks to move a file between `Business/` locations — for
example `Business/00-INBOX/` → `Business/01-PLANNING/requests/`. Also
activate on "route this", "move {file} to {folder}", or "file this under
{folder}" when the destination resolves inside `Business/`. This skill
**executes** a routing decision Chief already made — it does not decide
where things go.

## What this skill does

Moves a file from one `Business/` location to another, applying a
date-stamped filename and the tracking metadata every routed item must
carry. This skill never invents the routing target or the metadata —
routing classification is Chief's judgment, and missing metadata is asked
for, not guessed. It renders a dry preview of the move first and only
executes after confirmation, mirroring Chief's own dispatch-payload-then-confirm
pattern.

## Gate 0 — Containment (checked first, before every other check)

Resolve the destination path. If it does not resolve inside `Business/`,
refuse immediately — no override, no "unless approved" clause.

```
### Refused — Out of Scope
Target: {destination path}
Reason: business-vault write/route authority is scoped to Business/ only.
Instead: {redirect}
```

Only once Gate 0 passes do metadata completeness and the rule checks below
apply.

## Required Tracking Metadata (Rule 8 — No Orphan Routes)

Every item moved out of `Business/00-INBOX/` must carry all three. The move
does not complete without them:

| Field | Required value |
|-------|----------------|
| `owner` | Named owner — a person or agent. Never blank. |
| `due date` | A date, **or** the explicit string `no due date`. Absence is not the same as "no due date". |
| `task required` | `yes` or `no` — whether a task must be created downstream. |

If any field is missing from the request, ask for it. Do not infer an owner,
default a due date, or assume `task required`. Archive-immutability (Rule 5)
also applies to the **destination** — refuse a route into
`Business/07-ARCHIVE/promoted/`, citing the rule.

## Workflow

### Step 1 — Read the route request

Identify the source path, the destination folder Chief chose, and the three
metadata fields. Confirm the source file exists; if not, say so plainly and
stop. Check the destination against Gate 0 — if it falls outside
`Business/`, refuse now, before checking metadata.

### Step 2 — Check metadata completeness

Verify `owner`, `due date`, and `task required` are all present. If any is
missing, ask for exactly what's missing — nothing more:

```
### Missing metadata — cannot route yet
Source: {path}
Missing: {owner | due date | task required}
Provide these and I'll render the move.
```

Never fill a gap with an invented value.

### Step 3 — Render the dry preview

With all metadata present and the destination validated, render the move
without executing it:

```
## Route Preview — {YYYY-MM-DD HH:MM}

**Source:** {current path}
**Destination:** {destination folder}
**New filename:** {YYYY-MM-DD}-{slug}.md
**Owner:** {owner}
**Due date:** {date or "no due date"}
**Task required:** {yes | no}

**Status:** Pending confirmation — not moved
```

End with: "Confirm and I'll execute the move, or tell me what to change." Do
not move the file yet.

### Step 4 — On confirmation, execute and report

Move the file to the destination under its date-stamped name, writing the
three metadata fields into its frontmatter. Then report:

```
### Routed — {new path}
**From:** {source path}
**Owner:** {owner} | **Due:** {date or "no due date"} | **Task required:** {yes | no}
```

Report the real resulting path. If the move did not complete, say so — never
claim a route that didn't happen.

## Output style

- Lead with the preview, the missing-metadata prompt, or the routed block —
  no preamble
- Always render the dry preview before executing — no silent moves
- Refuse to complete a move that's missing any of the three tracking fields
- Ask for missing metadata; never invent an owner, due date, or task flag
- Cite the rule number when refusing a destination (Gate 0 or Rule 5)
