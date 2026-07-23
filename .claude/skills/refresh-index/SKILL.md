---
name: refresh-index
description: Rebuild the Local Brain Search FAISS index to reflect vault changes
automation: autonomous
schedule: "0 5 * * *"
allowed-tools: Bash
---

# Refresh Index

Rebuild the Local Brain Search vector index to ensure semantic search reflects current vault state.

## Purpose

The FAISS index is not auto-updated. This playbook refreshes it so semantic
search (and the BDG enrichment layer the Brain Orb reads) reflect the current
vault. The indexer is incremental — it re-embeds only changed/new notes — so a
daily refresh is a matter of seconds and never a long-running job.

## State Dependencies

| Source | Location | Read | Write | Description |
|--------|----------|------|-------|-------------|
| Brain notes | `Brain/**/*.md` | ✓ | | Source content to index |
| Index script | `resources/local-brain-search/run_index.sh` | ✓ | | Indexer |
| FAISS index | `resources/local-brain-search/brain_index/` | | ✓ | Output index |

## Prerequisites

- Local Brain Search installed at `resources/local-brain-search/`
- Python environment with FAISS dependencies

## Process

### Step 1: Verify Prerequisites

Check indexer exists:
```bash
test -f resources/local-brain-search/run_index.sh && echo "OK" || echo "MISSING"
```

If missing, abort.

### Step 2: Run the Indexer (incremental, short, resumable)

The indexer is **incremental**: it reuses the embedding of every note whose
content is unchanged and re-embeds only the delta. A normal daily run touches a
handful of notes and finishes in **seconds** — there is no long-running job here
anymore. Run it, then read the LAST line of its output:

```bash
resources/local-brain-search/run_index.sh
```

The final line is machine-readable:

```
RESULT reused=<N> embedded=<N> remaining=<N>
```

- **`remaining=0`** → the index is complete; go to Step 3.
- **`remaining>0`** → a large (cold/forced) rebuild was split into short,
  Trinity-safe batches (default cap: 500 notes/run). **Run the exact same command
  again** — each call reuses what's already indexed and embeds the next batch.
  Repeat until `remaining=0`. Daily runs are always a single pass.

**Execution rules — each call is short (seconds to ~2 min) and must STREAM:**

- **Run it in the foreground and let its heartbeat lines stream.** Do NOT pipe it
  through `tail`/`head`/`grep` — they buffer to EOF, so the call looks silent and
  the **300s stall watchdog can SIGKILL it**. And do NOT background it and end the
  turn to "await a completion notification" — a scheduled turn ending kills the
  child, so the job never finishes (this is exactly what made this skill silently
  skip for days). Loop short foreground calls instead; that is the sanctioned
  Trinity pattern for work that would otherwise be long.
- **Do not stop after the indexer** — Steps 3 and 4 MUST run in the same turn,
  once `remaining=0`.

The indexer writes the FAISS index, the connection graph, and a build manifest
(`data/manifest.json`, stamping the `cosine_ip` edge formula + `builder_version`)
— the manifest is written only on the final pass (`remaining=0`).

**Full rebuild after an indexing/edge-logic change** (e.g. the semantic-edge
formula): bump `BUILDER_VERSION` in `memory_config.py`, then force every note to
re-embed by removing the stale index and running the normal resumable loop, so
every call stays short:

```bash
rm -f resources/local-brain-search/data/brain.faiss resources/local-brain-search/data/brain_metadata.pkl
# then loop Step 2 until remaining=0
```

(`run_index.sh --force` also re-embeds everything, but in ONE unbounded pass —
use it only for an attended manual rebuild, never on a Trinity schedule.)

### Step 3: Verify Index

Confirm index works:
```bash
resources/local-brain-search/run_connections.sh --stats --json
```

Should return valid JSON with note count > 0.

### Step 4: Re-bootstrap Brain Dependency Graph (MANDATORY — do not defer)

**This is the step the whole pipeline exists for.** It writes
`resources/brain-graph/data/graph_enrichments.json` — the enrichment layer that
the Brain Orb and every coherence/lifecycle skill read. If the run ends before
this step (backgrounded indexer, watchdog kill, "I'll finish later"), the index
may be fresh but the enrichment layer stays stale and the orb graph stops
updating. Run it in the SAME turn as Steps 2-3, as a foreground call:

```bash
resources/brain-graph/run_brain_graph.sh bootstrap --force
```

Verify:
```bash
resources/brain-graph/run_brain_graph.sh status
```

Should show enriched nodes matching the new index count. The run is only
complete once this reports a node count close to the indexer's — a fresh FAISS
index with a stale `graph_enrichments.json` is a FAILED run, not a partial
success, even though the index step "succeeded."

## Outputs

- Rebuilt FAISS index at `resources/local-brain-search/data/`
- Refreshed BDG enrichments at `resources/brain-graph/data/graph_enrichments.json`
- Stats output confirming note count

## Error Handling

| Error | Recovery |
|-------|----------|
| Script missing | Abort - check Local Brain Search installation |
| Index fails | Check Python env, disk space |
| Stats return 0 notes | Re-run indexer, check Brain path |
| `remaining>0` after a run | Expected for a cold/forced rebuild - just run Step 2 again; repeat until `remaining=0`. If `remaining` is not decreasing across runs, the partial index isn't persisting (check disk space / write perms on `data/`) |
| Indexer killed ~300s with no output | The stall watchdog fired - you piped/buffered or backgrounded it. Re-run per Step 2's execution rules: a foreground call, output streaming, no `tail`/pipe, no backgrounding |
| BDG bootstrap fails | Retry once. If it still fails, the LBS index is fresh but the orb/coherence enrichment layer is stale - report it; this is NOT a clean run |

## Completion Checklist

- [ ] Indexer script exists
- [ ] Index rebuilt without errors
- [ ] Stats query returns valid JSON
- [ ] Note count > 0
- [ ] BDG re-bootstrapped
