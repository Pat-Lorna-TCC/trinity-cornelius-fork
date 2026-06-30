# Prebuilt Search Index (Showcase)

These files are a **prebuilt index of the sample notes** that ship with this
template, so semantic search and connection discovery work the moment you clone:

| File | What it is |
|------|------------|
| `brain.faiss` | FAISS vector index (384-dim, `all-MiniLM-L6-v2` embeddings) |
| `brain_metadata.pkl` | Per-chunk metadata (vault-relative paths — portable across machines) |
| `brain_graph.pkl` | NetworkX graph: explicit wiki-link edges + semantic-similarity edges |

Paths inside the index are stored **relative to `Brain/`**, so the index works on
any machine without leaking or breaking.

## Rebuild it with your own notes

Once you start adding your own notes, regenerate the index:

```bash
cd resources/local-brain-search
./run_index.sh --force
```

Learning/usage state (`q_values.json`, `usage_history.jsonl`) is **not** shipped —
it is machine-local and regenerates automatically as you search.
