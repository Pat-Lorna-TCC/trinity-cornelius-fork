# Brain - Master Changelog

**Purpose**: Quick reference index of all discovery sessions and major changes.

This is a **summary index**. For detailed session logs, see `05-Meta/Changelogs/CHANGELOG - [Session Type] YYYY-MM-DD.md`.

---

## 2026-05

### 2026-05-04 (Chapter 8 - Fault Tolerance)
**Document Analysis Session** - [Details](Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04 Chapter 8.md)

See details: [[Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04 Chapter 8]]

**Quick Summary**:
- 1 chapter analyzed: Van Steen & Tanenbaum (2023), Chapter 8 - Fault Tolerance (84 pages, pp. 477-560)
- 8 insights extracted (0 duplicates - entirely new territory)
- 6 connections to existing vault notes identified
- Session: 2026-05-04 Distributed Systems Van Steen Tanenbaum

**Key Insights Created**:
- Failure taxonomy: crash → omission → timing → response → Byzantine; synchrony assumption determines detectability
- Byzantine fault tolerance requires 3k+1 processes (hard lower bound); crash tolerance only needs 2k+1
- Paxos guarantees safety unconditionally, liveness only conditionally - deliberate FLP-response design
- FLP impossibility (Fischer, Lynch, Paterson 1985): consensus impossible in async systems with even one silent failure; CAP is its engineering corollary
- Two-phase commit is a blocking protocol - coordinator crash in READY state cannot be resolved without recovery or Paxos-replicated coordinators
- Exactly-once RPC semantics is provably impossible for non-idempotent operations after server crashes
- Virtual synchrony: atomic multicast scoped to view epochs as the correct abstraction for active replication
- The domino effect: uncoordinated checkpoints can force full system rollback; some physical side effects are irreversible

---

### 2026-05-04 (Chapter 6 - Naming)
**Document Analysis Session** - [Details](Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04.md)

See details: [[Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04]]

**Quick Summary**:
- 1 document analyzed: Van Steen & Tanenbaum (2023), Chapter 6 - Naming (66 pages)
- 8 insights extracted (0 duplicates - naming systems entirely absent from vault)
- 12+ connections to existing notes (Identity, MOC - AI and Agents, Uncertainty-Dopamine-Belief Loop, Safety as Velocity)
- Session: 2026-05-04 Distributed Systems Van Steen Tanenbaum

**Key Insights Created**:
- Names/identifiers/addresses are three orthogonal concepts that systems routinely conflate at their peril
- DHT Chord finger tables achieve O(log N) lookup via exponential shortcuts; network proximity is a critical unresolved flaw
- DNS scales by matching consistency requirements to update frequency per layer - not through a single clever algorithm
- Named-Data Networking dissolves the name-to-address resolution step; every router becomes a content cache; immutability is required
- Self-certifying names (id = hash(content) or id = public_key) enable verification without trusting the resolution path
- Home-based vs DHT location approaches have fundamentally different triangle-routing and scalability tradeoffs
- Attribute-based naming hits a scalability wall; space-filling curves map N-dim attribute space to 1D for DHTs
- Name resolution is formally graph traversal; closure mechanisms (where resolution starts) are often implicit and critical

---

### 2026-05-04 (Chapter 1 - Introduction)
**Document Analysis Session** - [Details](Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04.md)

See details: [[Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04]]

**Quick Summary**:
- 1 chapter analyzed: Van Steen & Tanenbaum (2023), Chapter 1 - Introduction (54 pages)
- 8 insights extracted (no prior distributed systems intro content in vault)
- Session: 2026-05-04 Distributed Systems Van Steen Tanenbaum

**Key Insights Created**:
- Decentralization is Necessity Not Virtue - sufficiency vs. necessity reframes decentralization as constraint, not virtue
- Full Distribution Transparency is Impossible and Possibly Undesirable - seven ISO transparency types; copy-before-use alternative
- The Eight Fallacies of Distributed Computing - Deutsch's eight false assumptions as diagnostic checklist
- Replication Buys Scalability but Sells Consistency - strong consistency may be incompatible with high availability
- Administrative Scalability is the Hardest Scalability Dimension - human/political problem, not technical
- Separating Policy from Mechanism in Distributed System Design - openness paradox: strict separation explodes configuration complexity
- Availability vs Reliability - A Subtle but Critical Distinction - independent properties that can vary in opposite directions
- Pervasive Systems Invert the Human-Computer Interface Assumption - ubiquitous computing, MEC, in-network sensor processing

---

### 2026-05-04 (Chapter 7 - Consistency and Replication)
**Document Analysis Session** - [Details](Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04.md)

See details: [[Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04]]

**Quick Summary**:
- 1 document analyzed: Van Steen & Tanenbaum (2023), Chapter 7 - Consistency and Replication (~70 pages)
- 8 insights extracted (no prior consistency/replication notes in vault)
- 12 connections to existing notes (Safety as Velocity, Orchestration Efficiency, Uncertainty-Dopamine-Belief Loop, Folder Paradigm, Decision Making, Cross-Domain Consilience)
- Session: 2026-05-04 Distributed Systems Van Steen Tanenbaum

**Key Insights Created**:
- Replication is a scalability tool that creates a consistency tax - the cure can be worse than the disease
- Consistency spectrum: linearizability > sequential > causal > eventual (each step trades guarantees for performance)
- Sequential consistency is non-compositional - a hidden correctness trap (Herlihy et al., 2021)
- Client-centric consistency (monotonic reads/writes, read-your-writes, writes-follow-reads) targets the most common UX failures cheaply
- Continuous consistency (Yu & Vahdat, 2002): quantify exactly how wrong replicas can be via three deviation axes
- CRDTs (Shapiro et al., 2011): coordination-free strong eventual consistency via mathematical data type design
- Quorum replication: consistency as a tunable budget - spend on reads or writes but not both
- Push vs pull propagation: read-to-write ratio determines which wins; leases provide an adaptive hybrid

---

### 2026-05-04 (Chapter 2 - Architectures)
**Document Analysis Session** - [Details](Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04.md)

See details: [[Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04]]

**Quick Summary**:
- 1 document analyzed: Van Steen & Tanenbaum (2023), Chapter 2 - Architectures (56 pages, entirely new domain)
- 9 insights extracted (0 duplicates - distributed systems was absent from vault)
- 10+ connections to existing notes identified
- Session: 2026-05-04 Distributed Systems Van Steen Tanenbaum

**Key Insights Created**:
- Middleware is structurally identical to an OS: same resource-management role, networked scope
- Coordination has two independent dimensions: referential and temporal coupling (2x2 matrix)
- REST vs SOAP: generic interfaces relocate complexity into parameter space, not eliminate it
- Vertical distribution (tiered) vs horizontal distribution (P2P) are fundamentally different scaling axes
- Fat/thin client debate is really about systems management complexity, not UX
- Edge computing's latency argument is strong; reliability and security arguments are weak or circular
- Blockchain's trust elimination requirement cascades into every architectural decision; permissionless systems paradoxically re-centralize
- BitTorrent enforces reciprocity via tit-for-tat rate throttling; progressive decentralization via DHT replaces tracker bottleneck
- Structured P2P (DHT, O(log N) lookup) vs unstructured P2P (search, flooding/random walks) solve different problems

---

### 2026-05-04 (Chapter 5 - Coordination)
**Document Analysis Session** - [Details](Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04.md)

See details: [[Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04]]

**Quick Summary**:
- 1 document analyzed: Van Steen & Tanenbaum (2023), Chapter 5 - Coordination (~78 pages)
- 8 insights extracted (entirely new domain - no prior distributed systems content in vault)
- 8 cross-domain connections to existing notes identified
- Session: 2026-05-04 Distributed Systems Van Steen Tanenbaum

**Key Insights Created**:
- Global time is impossible in distributed systems - clocks drift; ordering matters more than timestamps
- Lamport clocks reframe synchronization as event ordering (happens-before), not wall-clock alignment
- Vector clocks make causality bidirectional: C(a) < C(b) iff a causally precedes b
- The centralization paradox: centralized mutual exclusion is simpler, faster, AND has fewer failure points than distributed
- Election algorithms face the timeout dilemma: ZooKeeper uses data recency (voteTX) not node ID to pick leaders
- Gossip as coordination primitive: aggregation, peer-sampling, overlay construction all from one mechanism
- Google TrueTime: expose uncertainty bounds explicitly rather than lying with a point timestamp
- Gossip hub attack: 30 attackers can capture 100k-node network in 300 rounds; indegree distribution as detector

---

### 2026-05-04 (Chapter 3 - Processes)
**Document Analysis Session** - [Details](Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04.md)

See details: [[Document Insights/2026-05-04 Distributed Systems Van Steen Tanenbaum/CHANGELOG - Document Analysis 2026-05-04]]

**Quick Summary**:
- 1 document analyzed: Van Steen & Tanenbaum (2023), Chapter 3 - Processes (~70 pages)
- 8 insights extracted (entirely new domain - no prior distributed systems content in vault)
- 10+ connections to existing notes identified (AI agents, decision-making, orchestration frameworks)
- Session: 2026-05-04 Distributed Systems Van Steen Tanenbaum

**Key Insights Created**:
- Threads vs. processes: hardware-enforced safety/performance tradeoff; cache perturbation is 80% of context switch cost
- Virtualization as interface mimicry: Popek-Goldberg theorem, x86 problem, four VMM types
- Containers = namespaces + union filesystems + cgroups (three Linux primitives)
- Stateless/stateful/soft-state server design tradeoffs
- Code migration inverts data-computation locality (federated learning as modern instance)
- Dispatcher-worker pattern as AI agent orchestration analogue
- Client-side (not server-side) is where distribution transparency belongs
- DNS redirection locality flaw in CDNs

---

## 2025-01

### 2025-01-15
**Connection Discovery Session** - [Details](05-Meta/Changelogs/CHANGELOG - Connection Discovery Session 2025-01-15.md)
- Explored connections around [Topic]
- Found 8 non-obvious relationships
- Identified 2 bridge notes
- Recommended synthesis: [Article idea]

### 2025-01-10
**Auto-Discovery Session** - [Details](05-Meta/Changelogs/CHANGELOG - Auto-Discovery Sessions 2025-01-10.md)
- Cross-domain exploration
- Sampled 47 notes across 5 domains
- Discovered unexpected connection: [Topic A] ↔ [Topic B]
- Emerging pattern: [Pattern name]

### 2025-01-05
**Vault Management Session** - [Details](05-Meta/Changelogs/CHANGELOG - Vault Management Session 2025-01-05.md)
- Created 15 permanent notes from [Source]
- Updated MOC - [Topic Name]
- Reorganized [folder/section]

---

## Template for New Entries

### YYYY-MM-DD
**Session Type** - [Link to detailed changelog]
- Brief summary point 1
- Brief summary point 2
- Key discovery or action
- Synthesis opportunity identified

---

## Quick Stats

- **Total Permanent Notes**: XX (update monthly)
- **Total MOCs**: X
- **Total Source Notes**: XX
- **Last Auto-Discovery**: YYYY-MM-DD
- **Last Connection Finding**: YYYY-MM-DD
- **Last Analysis**: YYYY-MM-DD

---

## Session Types

- **Auto-Discovery**: Random cross-domain exploration for serendipity
- **Connection Discovery**: Targeted exploration around specific notes/topics
- **Vault Management**: CRUD operations, organization, batch updates
- **Insight Extraction**: Processing content to create permanent notes
- **Analysis**: Structural analysis of knowledge base

---

**Tip**: Run `/analyze-kb` monthly to update comprehensive statistics.
**Tip**: Detailed changelogs in `05-Meta/Changelogs/` contain full analysis and recommendations.
