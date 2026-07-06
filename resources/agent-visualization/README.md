# The Self-Rendering Mind

A self-contained visualization of the Cornelius agent's internals: the orb *is* the Brain
Dependency Graph, rendered in real time, with a find-and-jump search, an embedded voice
(Cornelius via Gemini Live) that can drive the orb, and a live briefing of the agent's state.
`SPEC.md` is the original design brief; **this README is the current source of truth.**

## Run it

The canonical way is the **`/brain-orb`** skill (`.claude/skills/brain-orb/`) — it refreshes the
data, serves this folder, starts the voice tool backend, and opens the browser:

```
/brain-orb              # refresh + serve + open      (also: no-refresh · <port> · stop)
```

It runs `scripts/run.sh`, which serves the static server on **8767** by default (8765/8766 are often
left occupied - by Docker or by stale orb instances - so the default skips them) and auto-advances to
the next free port if 8767 is busy too. It also runs the **voice tool backend on `:8770`**. Stop
everything with `/brain-orb stop`.

By hand: `python3 serve.py 8767` from this folder (a no-cache static server, so edits to
`index.html`/`styles.css`/`voice/orb.html`/`data.js` show up on a plain reload), then open
`http://localhost:8767/index.html`.
The page also opens on `file://` (it loads `data.js` via a plain `<script>` and `styles.css` via a
plain `<link>` — both file://-safe), but the **voice tile needs the servers** (mic + the `:8770`
backend), so use the skill for the full experience. Needs WebGL (Three.js r160 via CDN) and fonts +
`marked` (markdown) via CDN — otherwise offline-capable.

The front-end is two files: `index.html` (markup + one inline Three.js module) and `styles.css`
(all the styling). Everything else (`data.*`, `voice/`) is generated or vendored.

## Controls

| Key | Action |
|---|---|
| `/` | **find a note** and jump to it (type, ↑/↓, Enter) |
| `V` | **voice tile** (Cornelius) on / off — see below |
| `1`–`7` | states: idle · hungry · ingesting · listening · thinking · speaking · converged |
| `W` | trigger a staleness **wave** (grey contagion from a framework note) |
| `S` | **scope panel** — mount / unmount vault scopes live (also drives voice search) |
| `E` | **endorse** one `ai-inferred` cell — opens the membrane, admits it to the core |
| `R` | cycle node colour: **provenance** → **recency** → **domains** (or click a chip) |
| `B` | show / hide the briefing rail |
| `P` | toggle the auto-demo timeline |
| `A` | **actions** panel — capture a thought, run a skill (see below) |

**Hover** a node to highlight it + its direct connections and show their names. **Click** a node to
focus it (the orb flies there and holds still) and open the inspector with the note's **rendered
markdown + clickable wikilinks** (and clickable connections to keep walking the graph).

## Voice (press `V`)

A draggable tile embeds the Cornelius **voice orb** (`voice/orb.html`, copied from the `voice-mode`
skill — Gemini Live). Pick a voice, press Start, and talk. Cornelius can:

- **drive the orb** via tools that bridge to this page over `postMessage`:
  `highlight_related_notes` (lights up a whole topic's cluster + draws the connections — its
  reflex first move whenever a topic comes up), `navigate_to_note` (opens a single note — any
  vault note, flying to it if visible or fetching its content if not), `search_graph`,
  `surface_tensions`, `list_hubs`, `list_converged_topics` (the full authoritative set of converged
  conclusions, lit up on the orb — also injected into the voice prompt so it names them instead of
  guessing), `set_colour_mode` (provenance / recency / domains),
  `read_current_note`. So "let's talk about dopamine" lights up the dopamine cluster, then drilling
  in opens individual notes. A voice-driven highlight **stays pinned** through mouse movement (it
  won't be wiped by hover) until you take over — click the orb, press `Esc`, or close the tile.
- **query the knowledge base** (`search_knowledge_base`, `recall_insights`, `get_perspective_on`)
  and the web, via the **voice tool backend** — `voice/proxy_server.py` on `:8770`, which calls
  `local-brain-search/search.py`. The brain-orb launcher starts/stops it automatically.

The voice orb is served same-origin (`./voice/orb.html`) so the iframe gets mic access and a clean
message channel; only the KB `/tool` calls cross to `:8770` (the proxy sends `Access-Control-Allow-Origin: *`).

**Pointer / trackpad:** drag the orb to rotate · **two-finger scroll or pinch to zoom** in/out (fly
inside) · hover a node = highlight + names · click a node = focus + inspector · click an inspector
connection = traverse. **Drag any HUD panel to move it** (positions persist); **double-click the
title to reset the layout**. Zooming briefly **freezes the orb's drift**, which slowly resumes after
~20s of no zoom, so you can inspect a still frame.

## Take actions (press `A`) — write back to the KB

The orb isn't read-only. With the brain-orb servers running, it can change the knowledge base. All
write/exec goes through the **voice backend** (`voice/proxy_server.py` on `:8770`) — the static file
server can't touch anything. Three actions:

- **Capture a thought** — type in the actions panel (`A`), `⌘/Ctrl+Enter` (or *capture → inbox*).
  Writes a properly-front-mattered note to `Brain/00-Inbox/` (`provenance: originated`). The orb plays
  its *ingesting* animation; the note **joins the graph at the next reindex** (see caveat below).
- **Connect two notes** — open a note, click **＋ connect to…** in the inspector, then pick a target
  in the search box. Appends a `[[wikilink]]` to the source note and draws the new thread immediately.
- **Run a skill** — buttons in the actions panel launch an **allow-listed** skill headlessly
  (`find-connections`, `incubation-loop`, `synthesize-insights`, `integrate-recent-notes`,
  `detect-tensions`, `refresh-index`) via `claude -p`. The orb enters its real *thinking* / *ingesting*
  state while the job runs; on completion it **re-exports and reloads** so registry/metric/body changes
  show up. (This path is the newest — verify it on your machine before leaning on it.)

**Security.** Action endpoints are gated by a per-start token (`X-Orb-Token`, fetched from `/session`)
and CORS is **restricted to localhost origins**, so a random web page open in your browser can't drive
your KB. The backend is bound to localhost. Only the six skills above can be launched; no arbitrary
skill strings. If the backend isn't reachable (e.g. `file://`), actions are simply disabled and the orb
behaves exactly as before.

**Reindex caveat.** `export_data.py` reads the thinking registry, metrics, note *bodies* and git
**live**, but it samples *nodes and edges* from the prebuilt brain-graph enrichments. So a re-export
surfaces skill results that touch the registry/bodies, but a brand-new note or wikilink only becomes a
real graph node/edge after the heavy `refresh-index` (FAISS) + brain-graph bootstrap. That's why
capture shows the *ingesting* animation rather than a fake node, and connect draws a provisional
client-side thread that the next reindex makes permanent.

## The briefing (three stacked panels, left)

A **live read of the agent's state**, all from real data. Drag any panel to move it; the third
scrolls.

- **Pulse** — the agent's most recent real activity (scheduled `incubation-loop` / `domain-watch` /
  `ai-crystallize` runs, parsed from git) plus a short feed. On load the orb briefly *mirrors* the
  last real activity's state, then settles to idle.
- **Health** — note counts, the lifecycle bar (reflective → crystallizing → generative) with phase
  %s, and a callout naming what matters: the **crystallizing bottleneck** (awaiting synthesis) and
  **notes learned in the last 7 days**.
- **What matters** (scrolls) — three **collapsible** lists (click a section header to fold it; the
  collapsed state persists):
  - **converged thinking** — the incubation topics that converged; click one to read the agent's
    actual conclusion text (in a **draggable, position-persisted** popup) and fly to its quarantined
    `ai-inferred` cell (the membrane note reminds you only `E` promotes it into the endorsed core);
  - **tensions** — click to highlight a red contradiction seam and read what the two notes disagree on;
  - **hubs** — the most-connected notes; click to fly the camera there.

Every HUD panel — including the inspector and the converged/tension popups — is draggable and **remembers
its position** across reloads. Each tile also has a **close ✕** (hover the panel) and can be re-opened from
the **dock** (the always-visible row of tile chips near the top); **which tiles are open is saved** too.
`B` still toggles all three briefing tiles at once. Double-click the title to reset the whole layout
(positions, collapsed sections, and hidden tiles).

(An earlier "recently learned" list and "domains" bars were dropped to keep the panels scroll-light;
recency still lives in the node colouring via `R`.)

**Recency colouring** (`R`): freshly-touched notes glow bright (≤2d white → week green → month blue
→ older steel), and the newest notes *twinkle* in any colour mode — so a glance shows where recent
thinking has been concentrated.

**Domains mode** (`R` again, or the `domains` chip): colours every node by its KB area —
AI / Agents · Neuro / Dopamine · Buddhism / Mind · Decision-Making · Identity / Belief · Business / GTM ·
Other (assigned by keyword-matching each note's title + content). The legend lists the areas with live
counts; **click a domain to isolate it** — its nodes light up and the connections between them are drawn,
showing that whole area of the brain as one region.

The motion is deliberately slow and organic (waxing/waning spin with a faint tumble, multi-wave
breathing) — alive, not a metronome.

## What maps to what (per `SPEC.md` §6)

- **Node** = atomic note · point of light. Radius by **layer** (signal at surface → index at core).
- **Color** = `provenance`: originated (ice) · endorsed (portal-blue) · encountered (dim steel) ·
  **ai-inferred (amber, quarantined *outside* the core)**.
- **Glow / warmth** = `heat`, driven by **in-degree** (how many notes point *to* this one - its
  structural authority / "load-bearing"-ness) on a compressed scale, blended with lifecycle. So the
  *foundations* of the mind glow brightest, while pure indexes/MOCs stay dim. A real usage Q-value
  still wins when one exists (currently ~none, so brightness reads as structural authority).
- **Size** = lifecycle phase (reflective → crystallizing → generative), enlarged by **total** degree
  (hub nodes). Because size uses total degree and brightness uses in-degree, an index/MOC is *big but
  dim* (points outward, little points back) while a foundational note is *big and bright*.
- **Edges** = typed threads; **tension** edges pulse red and are immune to the staleness wave.
- **Incubation topics** = amber thought-cells hovering outside the membrane; converged ones pulse.
- **The membrane** is the ethical spine: nothing crosses `encountered → endorsed` without the
  human pressing `E`. That is the one moment the interface dramatizes.

## Data

`data.json` / `data.js` are a **real export** of the live graph (sampled for legibility to ~520
nodes / ~1600 edges — **configurable in `viz_config.json`, see below**), produced by:

```bash
python3 resources/agent-visualization/export_data.py
```

### What's on the canvas — and how to control it (`viz_config.json`)

The export is **sampled for legibility, not arbitrarily truncated** — and the sampling is fully
configurable. Edit **`viz_config.json`** (sibling to `export_data.py`) and re-run `/brain-orb`; any
key may be omitted (missing keys fall back to `DEFAULT_CONFIG` in the exporter):

- **`layer_caps`** — nodes kept per BDG layer (1 signal → 7 index). The giant `insight` layer is
  down-sampled; the small/structural layers are kept ~whole. Total on canvas ≈ sum of caps + the
  bounded always-include extras. Bump `insight` (e.g. 240 → 500) for a denser orb; raise `max_edges`
  with it.
- **`max_edges`** / **`node_content_cap`** — edge budget, and the per-node embedded-body cap. (That
  body cap is *why the whole vault isn't shipped*: each node carries its markdown so the inspector
  renders offline — ~3 MB at 520 nodes, ~25 MB if all 4,461 were embedded.)
- **`selection.weights`** — how salience is scored: `lifecycle` (maturity) · `in_degree` (inbound
  authority — the foundations) · `degree` (total connectivity) · `recency` (current thinking).
- **`selection.always_include`** — guarantees that survive the cap: top `hubs` by in-degree, both
  ends of every real tension (red seams), notes touched within `recent_days` (up to `recent_max`),
  a `min_ai_inferred` floor (the membrane — inert until `ai-inferred` notes enter the graph), every
  **converged thinking-topic** node (the agent's finished conclusions), and every node of a mounted
  **book / reference** scope (so a mounted cluster renders whole, not sampled).

**Selection policy** (`export_data.py` → `main()`): score every node → admit the always-include sets
→ fill each layer to its cap by score. Then **edges are chosen connectivity-first** — every node is
given its strongest edge before the remaining budget is spent on density, so the canvas stays *woven*
rather than stranding high-salience dots (a handful with no on-canvas neighbour remain isolated by
design). The full graph is always reachable regardless: the voice's `navigate_to_note` fetches
off-canvas notes on demand.

The exporter reads (read-only): `brain-graph/data/graph_enrichments.json` (layers, lifecycle,
staleness, typed edges, tensions), `local-brain-search/data/q_values.json` (heat),
`Brain/05-Meta/Thinking/THINKING-REGISTRY.md` (incubation topics **and real converged
conclusions**), `dashboard.yaml` (domain distribution), the `brain-graph status` command
(authoritative lifecycle phase counts), **git history** (per-note recency + the live activity
feed), and each sampled note's `.md` body. It writes both `data.json` (for fetch-based loaders)
and `data.js` (for `file://`).

Top-level keys (extends the original `SPEC.md` §7 contract): `meta`, `nodes`, `edges`, `tensions`,
`incubation`, `converged`, `metrics`, `activity`, `recent`. Each node carries `id, title, layer,
lifecycle, provenance, scope, core, kind, heat, stale, degree, in_degree, age_days, converged, content`
(`in_degree` = inbound links, which drives brightness; `degree` = total, which drives size;
`converged: true` marks a finished thinking-conclusion node, highlightable as a group).

> The voice's `navigate_to_note` can open **any** vault note (not just the ~520 sampled): notes that
> aren't loaded are fetched on demand by the voice backend's `GET /note?title=…` endpoint and shown
> in the inspector (labelled "in vault · not on canvas").

> Tensions are **real productive contradictions** from the BDG detector (`note_a/note_b/similarity`),
> ranked by similarity × stance-divergence, with near-duplicates (sim ≥ 0.95) and changelog noise
> dropped, capped to the strongest ~40. `/brain-orb` refreshes them on a from-scratch start when
> they're stale vs the last graph bootstrap. If the graph genuinely has none, the exporter falls back
> to a few `demo:true` seams (flagged) purely so the red-pulse feature stays demonstrable.

## Status vs. the spec phases

- **Phase 1 (static identity)** ✓ — gradient void, JetBrains Mono, rotating sphere from real data, heat glow, red tension seams.
- **Phase 2 (metabolism)** ✓ — idle breathing + rotation, staleness diffusion wave, hungry contract + outward particles.
- **Phase 3 (states)** ✓ — all seven states (scripted/keyboard); thinking shows a spreading-activation wavefront with lateral inhibition.
- **Phase 4 (fly-inside + membrane)** ✓ — zoom reveals an interior labeled world; node inspector; `ai-inferred` quarantined outside the core with a human-gated endorse-the-pore action.

Beyond the original spec, this build adds: find-and-jump **search** (`/`), **hover** highlighting +
connection names, **rendered markdown + wikilinks** in the inspector, **clickable tensions** with a
description box, **recency** colouring, a three-panel **briefing** fed by real metrics/activity, the
**freeze-on-zoom** motion, and the embedded **voice** (Cornelius) with orb-control + KB tools
including topic-cluster highlighting.

Rendering is Three.js `Points` with a custom additive bioluminescent shader; waves, breathing,
heat, hover, and topic-cluster highlight run off per-vertex attributes + a clock against the data.
