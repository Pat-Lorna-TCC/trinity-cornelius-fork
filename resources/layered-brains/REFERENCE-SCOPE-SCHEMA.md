# Reference-Scope Schema Convention

**What this is:** the **generic, kind-level** frontmatter + linking contract for **reference-kind scopes** — non-core Brain/ folders that hold *external facts/records* rather than the user's claims. It defines what makes *any* folder a reference scope: `provenance: reference`, the epistemic opt-out, mutability/overwrite-in-place, `as_of:` freshness, wiki-link relations, and the privacy posture. This is a **convention, not engine code**: the index is text + edges and type-agnostic; a reference scope is enforced by discipline (this doc + the `manage-reference-data` skill), not by a new node type in the retrieval engine.

**What this is NOT:** the *entity taxonomy* (`type:`/`relationship:` enums) or *structure* of any one reference scope. Those are declared **per scope** in that scope's own schema doc — do not hardcode one scope's entity types here.

**Doc hierarchy (read top-down — this is the map that keeps these docs from conflicting):**
- `TARGET-ARCHITECTURE.md` → Direction B → "Scope kinds" — design of record for the reference *kind* capability.
- **This doc** — the generic reference-kind contract (applies to every reference scope).
- **Per-scope schema docs** — one scope's structure + taxonomy. Worked example: **`COMPANY-BRAIN-SCHEMA.md`** (the `Company` reference *family*: its typed sub-scopes, entity/relationship model, temporal SLA, and playbook suite). The cognitive-family precedent (same *family* mechanism, different kind) is `BOOK-SCOPE-SCHEMA.md`.
- `SCOPE-IMPLEMENTATION-PLAN.md` → Phase 6 — the execution ledger (what shipped, when).

**Status:** convention live; the registry capability shipped 2026-06-26 (Phase 6). The first reference scope is `Company` — restructured from a flat folder into a *family* (structural slice 9a-9c **and the seven `ref-*` playbooks 9d shipped 2026-07-08**; only autonomy 9e pending — see `COMPANY-BRAIN-SCHEMA.md`). Adding another is one `ScopeDef` (or one `register_scope()` call) — see "Adding a new reference scope" below.

---

## Why a "kind", not just another folder

Every scope before this one is **cognitive**: claims with provenance, additive/append-mostly, lifecycle-governed (`reflective → crystallizing → generative`), crystallizable, fingerprint-shaping (when core). A corporate-data layer is **none of those**. It is a **reference** kind — a different object that opts *out* of the epistemic machinery:

| Axis | cognitive (core + non-core today) | reference (new) |
|------|-----------------------------------|-----------------|
| Content | claims / insights | external facts / records |
| Mutation | additive, append-mostly | **mutable, overwrite-in-place** |
| Provenance | originated / endorsed / encountered / ai-inferred | **`reference`** (records, never `originated`) |
| Lifecycle / BDG | governed | **opted out** (no lifecycle, no synthesis pulse) |
| Crystallization | eligible | **never** (a record is not a converged belief) |
| Learning (q-values) | trains when pure-core | never (non-core by construction) |
| Fingerprint (hubs) | shapes it (core) | excluded |
| Recency | irrelevant (claims persist) | **newer beats older** (`as_of:`; later C-7 bi-temporal) |

**The scope primitive already delivers most of this for free.** A reference scope is a non-core folder, so it is read-isolated, learn-gated, and fingerprint-excluded the moment it exists (`scope.enforce=True`; `is_pure_core` is false whenever it is mounted). The reference *kind* adds only three light things, **none of which touch the retrieval engine**:

1. **The entity-schema contract below** (frontmatter convention).
2. **Relations via `[[wiki-links]]`**, not new BDG edge types (deferred).
3. **The epistemic opt-out**, signalled by `is_reference_scope()` and the `provenance: reference` stamp — consumed by the BDG and the crystallize/graduate skills, which skip reference notes.

**Distinct from operational memory (Direction A).** A reference scope stores *the world's external facts* (no confidence, no derivation from the incubation loop). Direction A's belief store holds *the agent's own confidence-scored beliefs*. Different objects — do not route corporate data through the belief store, and do not route beliefs here.

---

## The entity-schema contract

Every note in a reference scope is **one entity**. Filename = the entity's display name (kebab-case is fine, but the human-readable title in frontmatter is what links resolve against). Required frontmatter splits into **kind-generic** fields (every reference scope, defined here) and **per-scope** fields (`type:`/`relationship:`, defined in that scope's schema doc):

```yaml
---
# --- KIND-GENERIC (every reference scope — this doc) ---
provenance: reference            # ALWAYS reference - never originated/endorsed
scope: <Folder>                  # the reference scope this note belongs to (top folder)
status: active | superseded      # superseded rows kept for history; default active
as_of: YYYY-MM-DD                # when this fact was last known-true (freshness)
updated: YYYY-MM-DD              # when this file was last written
created: YYYY-MM-DD
created_by: [model-name]         # agent provenance (same axis as everywhere)
updated_by: [model-name]
agent_version: 01.25
# --- PER-SCOPE (declared in the scope's OWN schema doc) ---
type: <entity kind>              # the scope's entity enum — e.g. Company's is in COMPANY-BRAIN-SCHEMA.md
relationship: <optional>         # how the entity relates to us, when the scope needs the axis
---
```

Notes:

- **`type:` / `relationship:`** are **per-scope**, documented in that scope's own schema doc, not here (a single global enum was the original conflict). They are conventions, not engine types — the index does not care. `Company`'s taxonomy (`person|organization|product|agent|engagement|interaction` × a `relationship:` axis) lives in `COMPANY-BRAIN-SCHEMA.md`.
- **`provenance: reference`** is mandatory and load-bearing. It is what keeps a record from ever being mistaken for the user's `originated` thinking, and what the crystallize/graduate skills key off to refuse promotion. `scope_default_provenance("Company/…")` returns `reference` to make this the default.
- **`as_of:`** is the freshness stamp. Until C-Phase 7 (bi-temporal edges) lands, recency is enforced at the playbook level — overwrite-in-place means the latest content *is* the index, and `as_of:` lets a reader discount a stale record.
- **No `epistemic-classification` truth-status tags** (`hypothesis`/`validated`/etc.) and **no lifecycle layer** — those are for claims. A record is just current or superseded.

### Relations: wiki-links, not new edge types

Model relationships with `[[wiki-links]]` to other entity notes. A `[[Acme Corp]]` link is already an `explicit` edge (weight 1.0) that connection-finder and spreading traverse — no BDG change needed. (The `type:` values below are the Company scope's, shown for illustration; each scope declares its own — see `COMPANY-BRAIN-SCHEMA.md`.)

```markdown
# Jane Smith
type: person → links: [[Ability AI]] (employer), [[Project Atlas]] (owns)

# Acme Engagement 2026
type: engagement → joins: [[Acme Corp]] (client) × [[Product X]] × [[Jane Smith]] (owner)
value: $120k · term: 2026-01 → 2026-12 · status: active
```

**`Contract`/`engagement` is the join node** — Client × Product × owner × dates × value. This is how a many-to-many relation (clients ↔ products) is represented with one-node-per-fact and wiki-links, no relational schema.

**Typed relational edges** (`employed-by`, `contract-for`) are **deferred** — the BDG staleness math keys off *epistemic* edge semantics, so adding relational types there is a real extension, taken only if untyped links prove insufficient.

### History

Reference data is overwrite-in-place by default (the latest fact replaces the old). Where history matters (contract renewals), keep the prior note with `status: superseded` and a `supersedes:` link from the new one:

```yaml
status: superseded
superseded_by: "[[Acme Engagement 2027]]"
```

---

## The privacy gate (settled: this is a private agent)

Cornelius is a **fully private agent on a private remote**, so PII/corporate data in a reference scope is an accepted home: reference data is **committed and synced by default**, treated like any other note (`scheduled-run` `git pull`/`push` carries it). There is no per-scope gate to clear before populating.

The mechanism is still available if a *future* scope must be host-local (e.g. a third-party's data you've agreed not to sync): add `Brain/<Scope>/` to `.gitignore` and it behaves like the FAISS/pkl stores — local to one host, rebuilt per host, never pushed. That is the opt-in exception, not the default.

---

## Adding a new reference scope (the general capability)

Two ways — both make the new scope read-isolated, learn-gated, and fingerprint-excluded automatically:

**A. Built-in (travels with the repo).** Add one `ScopeDef` to `SCOPE_REGISTRY` in `resources/local-brain-search/memory_config.py`:

```python
ScopeDef("Clients", SCOPE_KIND_REFERENCE, False, ("clients",)),
```

**B. Runtime (a layer/deployment registers its own).** One call, no file edit:

```python
from memory_config import register_scope
register_scope("Clients", kind="reference", slugs=("clients",))
```

`register_scope` is **fail-closed**: it refuses `core=True` at runtime (the published fingerprint can't be widened live) and rejects unknown kinds. A reference scope is non-core by construction.

Then: write a **per-scope schema doc** declaring its `type:`/`relationship:` enum and structure (do NOT add it to this generic doc — `COMPANY-BRAIN-SCHEMA.md` is the template), and mount it for discovery with `BRAIN_READ_SCOPE=core,<Scope>`. (Reference data is committed by default — see "The privacy gate" above; only gitignore a scope if it must be host-local.)

### Flat scope vs. scope family

A reference scope can be **flat** (one folder of entity notes) or a **family** (`family=True` on the `ScopeDef` — each child folder becomes its own pluggable sub-scope, mountable alone or all together). The family mechanism is identical to the cognitive `Books/` family (`BOOK-SCOPE-SCHEMA.md`); `scope_of()` still resolves the top folder, so the reference kind + epistemic opt-out apply to every child, while `scope_id()` gives each child its own mount. **`Company` is a reference family** — its sub-scope partition + migration is specified in `COMPANY-BRAIN-SCHEMA.md`. Note: a family's notes must live in a child folder (`Company/people/x.md`), never loose at the family root (a loose file degrades to its own singleton scope).

---

## What a reference scope must NEVER do

- **Never be crystallized** (`/manage-thinking-topics crystallize`, `/synthesize-insights`) — a record is not a converged belief. `is_reference_scope()` is the guard (skill/convention level).
- **Never be lifecycle-classified** or used as a **synthesis-pulse source** (Direction D) — it has no reflective→generative arc. *Enforced:* the BDG `classify.bootstrap` skips `is_reference_scope()` nodes, so reference records get no layer/lifecycle and never enter lifecycle/coherence/tension.
- **Never train q-values** — it is non-core, so the learn-gate already blocks this; do not "fix" that.
- **Never acquire `provenance: originated`/`endorsed`** — records are `reference`, full stop. Promotion of an *insight the user draws from* a record is a separate, human, cognitive-scope act.
- **Never be the default read scope** — unmounted by default; surfaced only via an explicit `BRAIN_READ_SCOPE=core,<Scope>` mount.

---

## References

- `TARGET-ARCHITECTURE.md` → Direction B → "Scope kinds: cognitive vs reference" (design of record for the kind capability).
- **`COMPANY-BRAIN-SCHEMA.md`** — the worked per-scope example: the `Company` reference *family* (entity/relationship taxonomy, temporal model, playbook suite).
- `BOOK-SCOPE-SCHEMA.md` — the cognitive-family precedent (same family mechanism, different kind).
- `SCOPE-IMPLEMENTATION-PLAN.md` → Phase 6 (execution checklist).
- `.claude/skills/manage-reference-data/SKILL.md` (the ingest/update playbook; extends to the `ref-*` suite per `COMPANY-BRAIN-SCHEMA.md`).
- `resources/local-brain-search/memory_config.py` → `SCOPE_REGISTRY`, `ScopeDef`, `register_scope`, `is_reference_scope`, `scope_default_provenance`.
