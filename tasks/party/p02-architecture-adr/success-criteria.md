# P2 — Success Criteria (pv0.1)

P2 (architecture ADR, **rubric-scored, no answer key**). Profile: Architecture.
The deliverable is `adr-001.md`. Applied after a cell completes; used identically
across all four arms (A1 solo / A2 matched-thinking / A3 persona-prompt / A4
party mode). Raters score the **scrubbed** deliverable only.

Universal P-track rubric (5 dims, anchors, scrub protocol, unblinding measurement):
[`harness/party/scoring-rubric.md`](../../../harness/party/scoring-rubric.md). This
file declares the P2 coverage checklist, which of the 5 dimensions are load-bearing,
and task-specific scoring detail.

**This is a rubric task: there is no objective-recall axis.** The quality signal is
*how well the solver surfaces and weighs the trade-offs that genuinely conflict*, not
which option it picks. A clean, well-reasoned argument for any of the three main
option families can score 5; a hand-wavy argument for the "best" option does not.

---

## 1. Coverage checklist

The context plants a set of *tensions and facts that a competent architect should
engage*. These are NOT a planted answer key (the solver is not scored found/missed
mechanically), but each rater uses this list to judge Coverage and Insight depth.
A deliverable that silently ignores an item from the "must engage" tier is capped on
Coverage; one that engages the "senior-tells" tier earns the top Coverage/Insight
anchors.

### Must engage (Coverage floor — ignoring these caps Coverage at 2)

- **C1 — The hard deadline is the EU residency clause (4 months), not the latency
  SLA (7 months) or the split (no deadline).** The decision must be sequenced around
  the constraint that doesn't move. A deliverable that treats all three forces as
  co-equal, or leads with the monolith split, has mis-read the problem.
- **C2 — EU residency is satisfiable without splitting the monolith.** Standing up a
  second regional deployment + EU Postgres on the existing PaaS (which offers EU
  regions, per context) is a legitimate, lower-risk path. The split is a *separable*
  question the solver must not conflate with compliance.
- **C3 — The team cannot safely run microservices right now.** 6 engineers, no SRE/
  DBA, hiring frozen, nobody has run multi-service prod, a prior extraction was
  abandoned half-done, on-call already leans on one person. Any option that adds
  operational surface must reckon with this explicitly.
- **C4 — The latency problem is largely a data-locality / round-trip problem and is
  partly addressable without a re-architecture** (edge caching of the slot-availability
  reads, regional read replica, collapsing the sequential booking-page API calls).
  The booking page makes *several sequential* calls — that compounding is named in
  context and is a concrete, cheap-ish lever.
- **C5 — Residency scope is fuzzy and that fuzziness is load-bearing.** Legal hasn't
  drawn a crisp line; "treat as in-scope when in doubt" inflates the data-tagging
  effort. A strong deliverable narrows scope to end-customer PII vs. business config
  and names the data-classification work as unscoped (it's called out as nontrivial,
  nobody has scoped it).

### Should engage (engaging these earns Coverage 4)

- **C6 — Routing / "which region owns this customer's data" is the real new
  complexity** introduced by going multi-region, independent of monolith-vs-services:
  request routing, where the booking write lands, how a business with mixed-region
  customers is handled.
- **C7 — Reversibility / sequencing.** The cheap, reversible moves (EU deployment,
  latency mitigations) can ship inside the deadline; the expensive irreversible move
  (decompose the monolith) can be deferred and decided later with more information.
  A senior reads the option set as "do the forced thing now, keep the optional thing
  optional."
- **C8 — The deal is not a one-off** (15% of new signups are EU and trending up) — so
  the EU work is a strategic investment, not a throwaway to save one contract. This
  shifts the build-it-properly-vs-hack-it calculus.

### Senior tells (engaging ≥2 earns Coverage 5 / strong Insight)

- **S1 — Cross-region data sync is on us** (PaaS offers no managed multi-region single
  DB). Whatever option is chosen, the solver should notice that a second regional DB
  means *some* data (e.g. business config that's global, or aggregate analytics) needs
  a sync/replication story, and that this is genuinely hard — not free.
- **S2 — Payments are already de-risked** (tokens stored processor-side, processor is
  global). A solver that notices payment data is *not* the residency problem (and so
  doesn't over-engineer a payments split) shows it read the constraints.
- **S3 — The abandoned `notify-svc` is evidence, not trivia.** A team that couldn't
  finish extracting *notifications* (the easiest, most async-tolerant seam) is strong
  signal that a booking/payments split would also stall. Citing this against an
  aggressive-split option is a senior move.
- **S4 — Calendar-sync/reminders tolerate delay; booking/deposit do not.** If any
  decomposition or cross-region call is proposed, the latency-sensitive hot path
  (booking write: availability → hold → charge → write) must stay tight; async-tolerant
  work is where extraction is cheap if ever attempted.
- **S5 — Naming a concrete success measure / cost** for the chosen path (e.g. "EU
  Postgres + regional deploy lands in ~6 weeks, infra ~doubles to ~$22k/mo, within
  budget per context") rather than an open-ended program.

---

## 2. Load-bearing dimensions for P2 and why

All five dims are scored. Three are **load-bearing** — they're where this task
separates a strong architect from a competent-but-shallow one:

- **Insight depth (dim 3)** — THE primary signal. The task is engineered so the
  *obvious* read (three problems, the split is the big one, let's plan a microservices
  migration) is the *wrong altitude*. Depth here means: separating the forced
  constraint (residency, deadline) from the optional one (the split), noticing the
  latency problem is mostly locality not architecture, and weighing the team's
  operational ceiling honestly. Second-order effects (S1 sync, S3 prior-failure
  evidence, S4 hot-path latency) are the difference between a 3 and a 5.

- **Actionability / decision quality (dim 4)** — it's an ADR; it must *decide*, not
  survey. A 4+ states what the chosen path costs and what NOT choosing the other
  options forgoes, names sequencing inside the 4-month window, and includes the
  Revisit-triggers section as genuine decision points (not boilerplate). The brief
  explicitly asks for "a decision we can take to the CEO this week and start
  executing" — wishy-washy "it depends" survey memos fail this dim hard.

- **Correctness (dim 1)** — the contested points must be handled soundly. The big
  correctness traps (see § Failure modes): claiming you *must* split to satisfy
  residency (false — C2), claiming microservices will *fix* the latency (false — it's
  locality, and intra-service calls can make latency worse), treating payment data as
  the residency blocker (false — S2), or proposing an 8-month migration to hit a
  4-month deadline (infeasible). A deliverable with any of these has a significant
  domain error → Correctness ≤ 2.

**Coverage (dim 2)** is scored against § 1 and is meaningfully load-bearing too, but
secondary to the three above: a deliverable can cover every checklist item and still
be a shallow survey (low Insight, low Actionability). **Communication (dim 5)** is the
standard ADR-format / length-band / readability check; the length-band rule applies
(a 6-page "ADR" that buries the decision loses Communication points, and the bloat
does not buy Coverage).

---

## 3. Task-specific scoring detail (what 4 vs 5 looks like here)

### Insight depth

- **3:** Correctly identifies that residency can be solved without the split, OR
  that latency is mostly a locality problem — at least one genuinely non-obvious
  reframing specific to this context.
- **4:** Several non-obvious moves: separates forced-vs-optional cleanly, engages the
  routing/data-ownership complexity (C6), AND surfaces at least one senior tell
  (S1–S5). Second-order interactions are visible (e.g. "a second region adds a sync
  burden *and* a routing burden the team has no SRE to operate").
- **5:** Above + a reframing that would plausibly change the CEO's decision — e.g.
  explicitly arguing the EU build is a strategic regional-platform investment (C8) not
  a compliance hack, and using that to justify building the EU deployment *properly*
  while *deferring* the decomposition as a separate, later, evidence-gated decision;
  or using the abandoned `notify-svc` (S3) as decisive evidence against the split.

### Actionability / decision quality

- **3:** Picks an option, gives reasons, scopes it to the context; a team could start.
- **4:** Above + honestly states the cost/risk of the chosen path and what the rejected
  options would have bought; sequences the work inside the 4-month window; Revisit
  triggers are specific (e.g. "if EU signups exceed X% / if a second EU enterprise
  deal needs sub-region isolation / if booking-write p95 in EU regresses past Y").
- **5:** Above + explicit success measures and "what would change our mind" conditions;
  the deferred decisions (the split) carry a named trigger and owner-ish next step, so
  deferral reads as a *decision*, not avoidance.

### Correctness

- **4:** Sound and precise throughout; claims about PaaS capabilities, sync burden,
  latency mechanics, and team capacity are accurate to the context and appropriately
  qualified.
- **5:** Above + correctly handles the contested points where a competent architect
  could plausibly slip — names that microservices can *worsen* booking-write latency
  via added network hops on the hot path (S4), that residency scope is legal-fuzzy and
  shouldn't be guessed (C5), and that payments are already out of residency scope (S2).

---

## 4. Failure-mode characterization (observable ways a solver underperforms)

1. **"Split the monolith" as the headline.** Leads with a microservices migration as
   the answer, treating the EU deadline as the *occasion* to do the rearchitecture the
   team has wanted. Mis-prioritizes the only hard deadline against the team's actual
   operational ceiling. The dominant high-effort failure.
2. **Conflating residency with decomposition.** Asserts or implies you must break the
   system into services to store EU data in the EU. False per context (PaaS offers EU
   regions); a single regional deployment + EU Postgres satisfies it. Correctness hit.
3. **"Microservices will fix the latency."** Treats the APAC SLA as an architecture
   problem decomposition solves, when it's a data-locality/round-trip problem; worse,
   ignores that splitting can *add* hops to the booking hot path. Correctness hit (S4).
4. **Survey, not decision.** Lays out three options evenhandedly and never commits, or
   commits in a hedged "it depends" way. Fails the ADR's core purpose and the brief's
   explicit "a decision, not a maybe." Actionability hit.
5. **Ignoring the team-capacity constraint.** Recommends Kubernetes / a service mesh /
   an event bus with no acknowledgment that 6 engineers with no SRE and a hiring freeze
   have to run it. Treats org constraints as out of scope for an architecture decision.
6. **No sequencing against the 4-month clock.** Picks a path but doesn't show it lands
   inside the contractual window, or proposes work that plainly can't (an 8-month
   migration). Actionability + Correctness.
7. **Over-engineering payments / mis-scoping the data.** Builds a payments-residency
   story when payment tokens are already processor-side and out of scope (S2); or
   confidently asserts a crisp PII boundary the context says legal hasn't drawn (C5).
8. **Missing the cross-region sync/routing cost.** Recommends a second region as if it
   were free, never engaging that the PaaS gives no managed multi-region DB so sync is
   on the team (S1), and that "which region owns this customer" is new routing
   complexity (C6). Reads as not having thought past "stand up an EU app."
9. **No Revisit triggers, or boilerplate ones.** Section present but generic ("revisit
   in 6 months", "if requirements change") rather than the specific signals this
   decision actually hinges on. Actionability ceiling.
10. **Bloat.** A 6+ page "ADR" that restates the context at length and buries the
    decision. Communication hit; per the length-band rule the volume does not buy
    Coverage.

## 5. Headline finding this task is designed to reveal

P2 is the **altitude / restraint** test of the architecture profile. The context is
built so the *exciting* engineering move (decompose the monolith) is the wrong one for
this team at this moment, and the *boring-but-correct* move (satisfy residency with a
regional deployment, mitigate latency at the data layer, explicitly defer the split as
an evidence-gated decision) requires the discipline to separate a forced constraint
from a tempting-but-optional one and to respect a team's operational ceiling.

The arm contrast we expect to surface: does multi-persona deliberation (A4 / A3) help
or *hurt* here? A roundtable with an "architect" persona keen to design systems, and a
"dev" persona who'd enjoy the rebuild, could amplify the split-the-monolith failure
mode (failure 1) — deliberation talking itself into ambition. Conversely, a panel that
includes a skeptical/ops lens could catch the team-capacity trap (C3, S3) a solo pass
might gloss. If party mode produces a *more* ambitious, less-restrained ADR than solo
Claude, that's a clean finding: on a decision whose correct answer is restraint,
multi-persona deliberation adds ceremony and ambition, not judgment. If it produces a
*more* grounded one (the ops/skeptic persona earning its seat), that's the opposite
finding — and equally publishable. The restraint anchors (C1/C2/C3 + S1/S3/S4) are
where this divergence will be visible.

## calibration

Cold-pass recall: TBD — filled during calibration.
(For this rubric task, "calibration" = one cold Opus 4.8 solo pass scored against the
§ 1 checklist + 5 dims by two raters, to confirm the checklist is hittable and the
load-bearing dims spread. Target: a competent solo pass lands ~Coverage 3, Insight 3,
Actionability 3 — leaving clear headroom for the senior-tells tier so the arms can
separate. If a cold solo pass already nails every senior tell, the context is too
leading; if it can't clear Coverage 3, the tensions are under-specified.)
