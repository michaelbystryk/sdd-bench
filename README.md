# sdd-bench

**Spec-Driven Development Methodology Evaluation**

*Status: T1, T2, T3, T4 (vague + rich) all scored — ~42 cells. T4-rich run as a hexad×3 (manual runtime, manual no-runtime, automated headless). First cross-task findings drafted at [`analysis/findings-2-t1-to-t4rich.md`](analysis/findings-2-t1-to-t4rich.md).*

---

## TL;DR — what we've found so far

Six methodologies — **Vibe** (no methodology, the control), **Vibe Plan Mode**, **OpenSpec**, **Spec Kit**, **AI-DLC**, **BMAD** — on four task domains. Code dims scored **blind** by ≥2 independent raters; planning dims single-rater; plus a cost axis.

**The headline: these methodologies reliably sell *planning artifacts*, not *better programs*.** On every task but one, shipped-code quality converges to a tight blind band; the reproducible separation is the documentation produced along the way — and its cost.

- **The control co-leads the blind code band on 3 of 4 tasks** (T1, T2, and all three T4-rich runs). It loses blind only on **T3**, where a Pydantic-v2 idiom trap discriminated *in the code itself*. Structure buys blind-detectable code quality only when the task has a discriminating technical trap.
- **The sharpest single datapoint:** on T4-rich, a **$689 BMAD cell and a $20 control cell scored the same blind code** (34.5 each). The $669 difference bought documents — and across the cohort the documentation spans a 40× spread (0 → 8,154 planning lines) for code that stays inside a 3-point blind band.
- **More planning ≠ better code.** BMAD's spec *predicted two edge cases it then shipped as Major defects* (683 tests missed both). AI-DLC's full lifecycle shipped a god-file identical to the no-planning control's.
- **OpenSpec is the cost-efficiency frontier on all five task-runs** — same-or-better quality at the lowest structured cost. The strongest methodology-level signal in the eval.
- **Adaptive routing is a measured trait, not a confound** — BMAD self-routed to quick-dev on small tasks ($4.00) and full lifecycle on the big brief ($384–689) — a 172× spread between its cheapest and most expensive cell.

Full writeup: [`analysis/findings-2-t1-to-t4rich.md`](analysis/findings-2-t1-to-t4rich.md) · doc comparison: [`analysis/t4-fitness-app-rich/methodology-docs-comparison.md`](analysis/t4-fitness-app-rich/methodology-docs-comparison.md) · per-task matrices: `analysis/t<N>-*/`.

*Exploratory framing; n=1 per cell except T4-rich (n=3). Defense is radical transparency + cross-task replication, not statistical power. Community runs invited at v1.0.*

---

First cross-methodology controlled evaluation of Spec-Driven Development (SDD) methodologies on tasks varying in complexity and ambiguity. Compares **six methodologies** against the same brief, same PM persona, same operator:

- **BMAD v6.8.0** — multi-agent lifecycle methodology
- **AI-DLC** — AWS's AI-Driven Development Lifecycle; a methodology (markdown rule files), not a tool — three-phase Inception → Construction → Operations with dense human approval gates; run on Claude Code, so model + token measurement are identical to the other five
- **OpenSpec** — lightweight proposal → apply → archive state machine; ranked #1 in April 2026 ranthebuilder.cloud independent eval
- **GitHub Spec Kit** — slash-command linear flow; 93K+ stars
- **Vibe Plan Mode** — vanilla Claude Code with Plan Mode toggled on; tests whether the planning step alone is "minimum effective methodology"
- **Vibe** — vanilla Claude Code with no methodology layer (the **control**); throughout this repo "Vibe" always means stock Claude Code, not a separate tool

See [`PROJECT-BRIEF.md`](PROJECT-BRIEF.md) for full design — thesis, methodologies under test, task set, scoring rubric, instrumentation, versioning roadmap, and locked decisions.

---

## Quick map

- **`PROJECT-BRIEF.md`** — source of truth for the eval design
- **`tasks/`** — locked briefs + reference materials per task (t1–t6, plus t4-rich)
- **`harness/`** — PM persona + methodology config files
- **`runs/`** — per-cell session logs, token captures, and artifacts
- **`analysis/`** — version-by-version writeups

## Coverage, cost & rankings

### What's here

| Task | Domain | Methodologies | Runs | Blind ≥2-rater | Status |
|---|---|:--:|:--:|:--:|---|
| **T1** | Postal-code CLI — greenfield, fully-specified | 6 | 1 | ✅ | Scored |
| **T2** | Library-loans API — brownfield extension | 6 | 1 | ✅ | Scored |
| **T3** | CSV→OpenAPI service — spec-bound greenfield | 6 | 1 | ✅ | Scored |
| **T4-vague** | Expo fitness app — vague brief | 6 | 1 | ✅ | Scored |
| **T4-rich** | Expo fitness app — PM-quality brief | 6 | **3** | ✅ | Scored (hexad×3) |
| **T5** | Brownfield feature — Actual Budget (additive on the real codebase) | — | — | — | Not started |
| **T6** | OSS bug-fix — brownfield-surgical | — | — | — | Not started |
| **T7** | Greenfield + external SDK — Actual Budget web client (open stack) | — | — | — | Not started |

**42 cells scored** (6×4 single-run tasks + 6×3 T4-rich). T4-rich runs: **r1** = manual, runtime brief (dev build on iOS sim) · **r2** = manual, no-runtime brief (source + tests as a PR) · **r3** = fully-automated headless arm (`claude -p`, no operator). All three blind ≥2-rater scored.

### Cost per cell (implied USD)

Pro flat-rate, so these are *implied* API spend (comparable across cells, not actual billing). **Cheapest per row in bold.**

| Task / run | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD | Spread |
|---|--:|--:|--:|--:|--:|--:|:--:|
| T1 postal CLI | **$0.59** | $1.07 | $1.32 | $4.20 | $4.57 | $4.00 | 7.7× |
| T2 library API | **$1.01** | $1.35 | $1.89 | $3.90 | $4.75 | $4.33 | 4.7× |
| T3 CSV→OpenAPI | **$0.93** | $1.41 | $2.91 | $5.72 | $2.73 | $4.67 | 6.2× |
| T4-vague fitness | **$5.84** | $7.78 | $7.16 | $13.21 | $19.15 | $75.85 | 13× |
| T4-rich r1 (runtime) | $22.74 | $31.94 | $20.64 | **$14.01** | $97.97 | $384.05 | 27× |
| T4-rich r2 (no-runtime) | **$20.36** | $24.09 | $22.91 | $30.10 | $33.50 | $689.47 | 34× |
| T4-rich r3 (headless) | $27.35 | $22.01 | **$18.12** | $24.29 | $39.94 | $32.32 | 2.2× |

**The cost ordering is not stable** — who's cheap vs. expensive flips across tasks and even across the three T4-rich briefs. BMAD's adaptive routing alone spans 172× ($4.00 quick-dev on T1 → $689 full lifecycle on T4-rich r2).

### Time per cell (single-run tasks)

API-compute time per `/status` (model working time, not wall-clock — see the BMAD note under the T4-rich block).

| Task | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|--:|--:|--:|--:|--:|--:|
| T1 | 2m24s | 3m57s | 4m25s | 13m56s | 12m52s | 13m48s |
| T2 | 3m27s | 3m45s | 5m19s | 10m30s | 12m38s | 14m11s |
| T3 | 3m36s | 4m10s | 8m46s | 15m09s | 7m29s | 12m01s |
| T4-vague | 17m27s | 22m43s | 25m42s | 30m04s | ~34m53s* | 1h32m |

*T4-vague AI-DLC = active time (`/status`); clean API figure n/a. The control (Vibe) is fastest on every task; ceremony-heavy cells (Spec Kit / AI-DLC / BMAD) run 3–6× longer for code that lands in the same blind band.

### Time per cell — T4-rich (hexad × 3 runs)

API compute time. The three runs are different conditions (r1 manual+runtime · r2 manual+no-runtime · r3 headless/automated), so compare *within* a row, not a single T4-rich number per methodology.

| Run | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|--:|--:|--:|--:|--:|--:|
| r1 (manual, runtime) | 45m39s | 59m28s | 39m26s | 37m50s | 1h31m30s | ~6h37m* |
| r2 (manual, no-runtime) | 41m13s | 44m15s | 45m06s | 1h10m26s | 50m27s | ~18h† |
| r3 (headless, automated) | 56.9m | 48.0m | 33.5m | 37.6m | 58.7m | 56.6m |

\*BMAD r1 ran the full multi-agent lifecycle across **7 sessions, day-and-night** — **~6h37m API compute / ~26h50m wall-clock**, one Epic-development phase alone at **17h18m wall-clock** (not single-session-comparable). †BMAD r2 (the $689.47 cell) ran across **6 sessions over ~3 days** — **17h59m49s API compute** (sum), the most expensive cell in the eval on both clocks. **Adaptive routing shows up in time the way it does in cost:** BMAD's neutral-router r3 run is **56.6m / $32**, vs **6h37m / $384 (r1)** and **~18h / $689 (r2)** for the manual full-lifecycle runs. *(r3 = decimal minutes from `duration_api_ms`; r1/r2 = MmSs from `/status`.)*

### Persona-lens winners

Which methodology a buyer should pick depends on what they weight. (Full composites in [`analysis/findings-2-t1-to-t4rich.md`](analysis/findings-2-t1-to-t4rich.md) and per-task matrices.)

| Task | Indie / cost-sensitive | Enterprise / rigor-weighted | Quality-maximalist |
|---|---|---|---|
| T1 | **Vibe**† | Spec Kit | Spec Kit |
| T2 | **Vibe**† | Spec Kit | Spec Kit |
| T3 | **OpenSpec** | Spec Kit ≈ OpenSpec | OpenSpec ≈ Spec Kit |
| T4-vague | **OpenSpec** | **OpenSpec** | 4-way ~49.5 (BMAD = rigor corner) |
| T4-rich | **OpenSpec** | OpenSpec / Spec Kit | BMAD *if* you also value the doc trail |

†On the **floor tasks (T1/T2) there is no quality bar to clear**, so the cheapest correct build (Vibe) wins the pure-cost indie lens. Once a quality floor matters (T3/T4), **OpenSpec wins indie** — it clears the bar at the lowest structured cost. **OpenSpec is the cost-efficiency frontier on all five task-runs** and wins both buyer lenses on the 3 floor-clearing task-runs (T3, T4-vague, T4-rich) — the strongest methodology-level signal in the eval. On the floor tasks (T1/T2) it's the all-rounder while Vibe takes the pure-cost corner and Spec Kit the rigor corner.

### Overall enterprise standing across tasks (cost-blind quality)

Enterprise WQ per task (0–100; = 0.40·Product% + 0.60·Rigor%, **cost-blind**). Shown as actual numbers, not ranks — the spreads are often inside noise, so read **clusters, not crisp places**.

| Cell | T1 | T2 | T3 | T4-vague | T4-rich* | Standing (cost-blind) |
|---|:--:|:--:|:--:|:--:|:--:|---|
| **Spec Kit** | **90.1** | **85.7** | 72.6 | 89.7 | 84.1 | **enterprise co-leader** — but never cost-efficient |
| **OpenSpec** | 81.2 | 80.9 | **75.0** | 89.9 | 82.7 | **co-leader at the lowest structured cost** |
| AI-DLC | 87.6 | 78.3 | 65.6 | 89.9 | 81.0 | strong but variable (tops T1/T4-vague, mid on T2/T3) |
| BMAD | 77.5 | 80.0 | 68.7 | 89.3 | 82.7 | top-cluster quality — at **the highest cost every task** |
| Plan Mode | 66.7 | 71.4 | 60.4 | 80.4 | 79.9 | lower-mid |
| Vibe (control) | 53.5 | 68.6 | 48.9 | 54.0 | 74.1 | **last every task** (rigor-weighted) — yet co-leads the blind *code* band |

\*T4-rich = median across its 3 runs. On T4-vague the top four (OpenSpec / AI-DLC / Spec Kit / BMAD) sit in a **0.6-point band (89.3–89.9) — a genuine 4-way tie**, not a ranking.

**The honest read:** on enterprise quality alone, **Spec Kit, OpenSpec, and BMAD are one cluster — they're separated by *cost*, not quality.** OpenSpec is the pick because it delivers that top-cluster quality at the **lowest** structured cost; Spec Kit matches the quality at 2–5×; BMAD matches it at up to 30×. Vibe is last on this lens everywhere *precisely because it sells no planning artifacts* — while co-leading the blind code band. So the cross-task story isn't "one methodology wins enterprise"; it's **"enterprise quality converges and cost is the entire differentiator."**

> Caveats: **ranks/clusters, not averaged scores** — task scores aren't cross-task-commensurable (T2/T3 have no UI dims; rubric scales differ /40·/45·/55; planning dims single-rater; n=1 except T4-rich). T1 + T4 WQ are published; T2/T3 recomputed from each task's Product/Rigor sub-scores; T4-rich is the 3-run median. Directional, not a leaderboard.

### Enterprise-lens rank across the three T4-rich runs (all cells)

T4-rich is the only task scored ×3, so it's the one place the full persona composite replicates. Enterprise lens = 0.40·Product% + 0.60·Rigor%, **cost-blind** (rank by weighted quality). Full Indie + Enterprise composites for every cell, every run: [`scoring-matrix.md`](analysis/t4-fitness-app-rich/scoring-matrix.md).

| Ent. rank | r1 (runtime) | r2 (no-runtime) | r3 (headless) |
|:--:|---|---|---|
| **#1** | **OpenSpec** (tie) | **OpenSpec** | **OpenSpec** |
| #2 | BMAD (tie) | Plan Mode | Spec Kit |
| #3 | AI-DLC | AI-DLC | BMAD |
| #4 | Plan Mode | Spec Kit | AI-DLC |
| #5 | Vibe | **BMAD** | Plan Mode |
| #6 | *(spec-kit n/a — no app)* | Vibe | Vibe |

**OpenSpec is enterprise #1 in all three runs.** BMAD's rank swings **#1-tie → #5 → #3** — it only "ties" in r1, and only because the lens is cost-blind *and* its scored rigor there is **identical** to OpenSpec's (29/35; planning trio 13/15 each) despite 9× the documentation. In r2, forced to ship a source deliverable it couldn't runtime-verify, **BMAD shipped an unwired product** (product polish 16.5→13.5) and fell to **#5**. **No run has BMAD's quality justifying its cost** ($384–689 vs OpenSpec's ~$20).

### How BMAD's documentation scales (adaptive routing)

BMAD is the one methodology that **self-sizes** to the brief — its router picks a quick-dev path or the full multi-agent lifecycle. The documentation it emits (and the cost + time to emit it) scales with **brief richness/ambiguity, not with the program**:

| Task | Brief | BMAD route | Planning output | Cost | Blind code |
|---|---|---|---|--:|:--:|
| T1 / T2 / T3 | tight, well-specified | quick-dev | thin (Doc ~3) | **$4.00–4.67** | in-band |
| T4-vague | vague, medium | full lifecycle | heavy | $75.85 | in-band |
| T4-rich r1 | rich PM brief | full lifecycle | **8,154 planning lines** | $384.05 | 34.75 (co-leads) |
| T4-rich r2 | rich, no-runtime | full lifecycle | PRD + 40 BDD stories | **$689.47** | 34.5 (ties $20 control) |

A **172× internal cost range** ($4 → $689) — from a thin quick-dev spec to an 8,154-line PRD + epics + 40 per-story BDD + canon-doc trail — driven entirely by how much the brief invites elaboration. The scaling is **superlinear in brief richness and flat in code quality**: every BMAD cell lands inside its task's blind code band, so the docs scale with the *brief*, not the *program*. (The route is also kickoff-sensitive — a neutral `/bmad-help` kickoff routed r3 to a light path at **$32 / 57m**, vs full-lifecycle r1/r2 at $384–689 / 6.6–18h.)

### Bottom line (preliminary — 4 of 6 tasks scored, n=1 except T4-rich)

So far, and treating this as a first read rather than a verdict:

- **OpenSpec is the default structured pick** — cheapest structured cost and competitive-or-best quality on all five task-runs; wins both buyer lenses on every task with a quality floor.
- **Spec Kit** earns its premium only when you specifically want the broadest, most build-ready artifacts (typed API contracts, research / data-model / quickstart) and cost is secondary — it's the rigor-pole / enterprise-lens winner on the well-specified tasks, but OpenSpec reaches ~90% of its rigor at roughly a third of the cost.
- **BMAD** is justified only when an audit-grade document trail is itself the deliverable — its shipped code is blind-indistinguishable from a $20 control cell.
- **On shipped code alone, the no-methodology control is competitive-to-leading on most tasks** — so the structured methodologies are bought for their *artifacts*, not their programs.

**Not yet testable:** a greenfield-vs-brownfield split — only one (easy, low-complexity) brownfield cell is scored, and T5/T6 (the real brownfield tests) are pending. The variable that actually moved blind *code* quality was the presence of a code-visible technical trap (T3's Pydantic-v2 idiom), not the field or the brief's ambiguity.

Live status, the decisions log, and the current next action live in [`analysis/handoff.md`](analysis/handoff.md).

## Limitations & threats to validity

This is **exploratory** work — its defense is radical transparency and cross-task replication, not statistical power. Read the rankings as directional clusters, and weigh them against these known threats:

- **n=1 per cell.** Every cell is a single run except T4-rich, which is **3 different conditions (runtime / no-runtime / headless), n=1 each** — pattern-replication, not variance. A single run can't separate methodology effect from model nondeterminism.
- **Single designer, single instrument.** One person authored the task briefs, the scoring rubric, *and* the PM persona. That's an unmeasured author-bias surface — the tasks and anchors may unconsciously favor some methodologies' shapes over others.
- **LLM-rater circularity.** The cell agent, the blind raters, and the PM persona are all Claude. The "tight blind code band" could therefore be partly a shared-prior artifact — Claude scoring Claude — rather than a pure quality signal. A non-Claude (or human) rater on a subset is the obvious next mitigation.
- **The separation lives in the single-rater dimensions.** Code dims are blind ≥2-rater, but the **planning dims that actually drive the cross-methodology spread are single-rater and unblinded.** The objective axes — binary outcomes and cost — carry the most weight.
- **Scores aren't cross-task-commensurable.** Rubric scales differ per task (/40 · /45 · /55), T2/T3 have no UI dims, and the cross-task tables are directional clusters, not an averaged leaderboard.
- **One methodology got an opt-in the others didn't.** AI-DLC is the only methodology that recommends property-based testing, so under the "take each methodology's recommendations" policy it received a PBT scaffold and a corresponding robustness lift; read its rigor edge with that in mind. (When the T4-rich PM persona declined the opt-in, AI-DLC's robustness flattened — the cleanest illustration of the effect.)
- **External corroboration isn't independent replication.** Where ranthebuilder.cloud's ranking is cited as agreeing, note it's a separate single-reviewer study on a different task — supporting context, not a replication of this harness.

## Harness invariants (locked v0.1)

| Component | File | Hash (sha256) |
|---|---|---|
| PM persona system prompt | `harness/pm-persona-v1.md` | `6da5328b90574c80a20081a0363b05e5736beaf7dc1ae5df6ff684874b53f35e` |

Calibrate the persona via a separate adversarial play session on claude.ai before running any cell. If the prompt is edited during calibration, re-hash and update this table.

## Instrumentation

Pro subscription only — no LiteLLM/Langfuse. Per-cell logbook protocol (`session-log.md`, `token-log.md`, `artifacts/`). See `PROJECT-BRIEF.md` § Instrumentation.

## Versioning

| Version | Scope |
|---|---|
| v0.1 | T4-Vibe (done 2026-05-25) |
| v0.2 | + Spec Kit on T4 |
| v0.3 | + AI-DLC on T4 |
| v0.4 | T4 **six-way** (first headline finding — vague brief; adds OpenSpec) |
| v0.5 | T1 six-way (postal CLI) |
| v0.6 | T2 six-way (library API) |
| v0.7 | T3 six-way (CSV→OpenAPI) |
| v0.8 | T4-rich six-way (PM-quality brief variant; brief-quality × methodology axis; hexad×3) |
| v0.9 | T6 six-way (OSS bug-fix; brownfield-surgical) |
| v1.0 | + T5 six-way (brownfield-feature) + full writeup |
| v1.2 | + T7 six-way (Actual Budget web client — greenfield + external SDK, open stack) |

Each version is shippable on its own. Task set is seven tasks (T1–T7) plus the T4-rich brief variant — see `PROJECT-BRIEF.md` § Task Set.

> **Two number tracks, don't conflate them.** The `vN.M` column above tracks **task milestones** (what's been *run*). Cross-task **writeups** live on a separate `findings-N` track in `analysis/` (what's been *concluded*): `findings-1` (T1–T4-vague), `findings-2` (adds T4-rich hexad×3, current). A findings doc can summarize several roadmap versions at once.
