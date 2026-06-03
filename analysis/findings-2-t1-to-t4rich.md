# sdd-bench Findings #2 — Cross-task (T1–T4, with the T4-rich hexad×3)

*Draft writeup. Four task domains scored across six SDD methodologies. T1 (postal CLI), T2 (library API extension), T3 (CSV import endpoint), T4 (Expo fitness app) — the last run in two brief variants (vague + PM-quality) and, for the rich brief, three independent runs including a fully-automated arm. ~42 scored cells. Exploratory framing; n=1 per cell except T4-rich (n=3).*

**Supersedes:** Findings #1 (`findings-1-t1-to-t4vague.md`) (T1–T4-vague). The substantive change in v0.8: the T4-rich hexad×3 puts the "ambiguous brief differentiates methodology" claim under a blind ≥2-rater microscope it never had in v0.7 — and it does not survive. The core thesis is stronger for it.

---

## TL;DR

We tested six methodologies — Vibe (no methodology, the control), Vibe Plan Mode, OpenSpec, Spec Kit, AI-DLC, BMAD — on four controlled tasks. Same operator, same locked PM persona, vendor-recommended model + effort per task era (Opus 4.7 for T1–T4-vague; Opus 4.8 for T4-rich). Code dims scored **blind** by ≥2 independent raters on anonymized bundles; planning dims single-rater (they *are* the methodology tell); plus a cost axis. All transcripts, configs, and bundles retained.

**One finding above all others — now tested five ways and holding:** what these methodologies reliably sell is **planning artifacts, not better programs.** On every task except one, shipped-code quality converges to a tight blind band; the reproducible separation is the planning artifacts produced along the way, and the cost of producing them. The one exception (T3) is the exception that proves the rule — it had a framework trap that shows up *in the code*.

The sharpest single data point: on T4-rich, **a $689 BMAD cell and a $20 control cell scored the same blind code quality** (34.5 each). The $669 difference bought documents.

Four findings worth keeping:

1. **The control (vanilla Claude Code) co-leads the blind code band on 3 of 4 tasks** — T1, T2, and all three T4-rich runs. It loses blind only on T3, where a Pydantic-v2 idiom trap discriminated in the code itself. Structure buys blind-detectable code quality only when the task has a discriminating technical trap.
2. **OpenSpec is the cost-efficiency frontier on all five task-runs** — same-or-better quality than heavier methodologies at the lowest structured cost. The single strongest methodology-level signal in the eval.
3. **More planning ≠ better code.** AI-DLC's full lifecycle (T3) shipped a god-file structurally identical to the no-planning control. BMAD's perfect spec (T4-rich) *predicted two edge cases it then shipped as Major defects*. The relationship between planning volume and code quality is non-monotonic past a small floor.
4. **Adaptive routing is a measured trait, not a confound.** BMAD self-routed to quick-dev on all three small tasks ($4.00–4.67) and full multi-agent lifecycle on the big consumer-app brief ($384–689) — a 172× internal cost range. Compare it; don't control it out.

---

## How we report scores

Three independent axes, reported as a **vector, not a sum** — adding code-quality to planning-quality treats them as commensurate, and they aren't.

| Axis | Measures | Method |
|---|---|---|
| **Shipped-code quality** | What ships in the repo: functionality, code idiom, system design, robustness, security, shipped docs | ≥2 blind raters on an anonymized bundle (planning artifacts + tool tells stripped) |
| **Planning-artifact quality** | What enterprise pays for: spec articulation, scope clarity, assumption surfacing | Single-rater from the un-anonymized cell dir (the artifacts are the tell — can't be blinded) |
| **Cost** | Implied API $, API compute time, tokens | Captured via Claude Code `/status` per session |

Blind and aware ratings are **different measurement conditions and are never averaged** (rubric v0.3). Where the blind spread sits inside inter-rater noise, we report the band, not a rank.

---

## The four-task throughline

| Task | Type | Blind code result | What discriminated |
|---|---|---|---|
| **T1** postal CLI | greenfield, low/low | Six compress to a **21–23/25 band; control at the top** | planning dims only (Vibe 1/15 vs structured 10.5–14/15); cost spread 7.7× |
| **T2** library API | brownfield, low/low | **23.5–26/30 band; control alone at the top of both passes (26+26)** | planning dims (Vibe 2/15 vs 11.5–13.5/15); cost spread 4.7× |
| **T3** CSV→OpenAPI | greenfield, med/low | **17–21.5/30 band; control at the BOTTOM (17.5, tied AI-DLC 17.25)** | the **Pydantic-v2 idiom trap** — visible in code; cost spread 6.2× |
| **T4-rich** Expo app | greenfield, med/high (PM brief) | **31.5–34.75/40 band; control co-leads all 3 runs (34.25/34.5/34.5)** | planning dims + **cost** (172× BMAD range); not code |

*(T4-vague — the same app on a deliberately vague brief — was scored single-rater/unblinded only; its provisional 4-way 49.5/55 tie is "false precision" and is not used for blind claims. T4-rich is the same task done right: blind, ≥2-rater, ×3 runs.)*

**The pattern across four tasks:**

- **Spec complete, codebase is the reference** (T1, T2): the control is competitive-to-leading on shipped code. Structured cells' planning adds documentation hygiene without changing the program. The 4–8× cost premium buys artifacts-as-artifacts.
- **Spec implies a framework with a right idiom** (T3): the framework discriminates in the code. The control's failure mode is "sidestep the framework" (Vibe shipped zero Pydantic models, hand-rolled regex); AI-DLC's is "engage the framework, ship a god-file" (223 LOC, one file). Both land at the bottom of the blind band. Multi-file structured cells lead.
- **Brief is ambiguous and the build is large** (T4-rich): planning shapes *what gets documented and what gets cut*, and costs wildly different amounts — but blind, the **code** the methodologies ship is indistinguishable from the control's. This is the headline correction to v0.7.

---

## The headline correction: T4-rich

v0.7 said ambiguous, large briefs are where "methodology starts to differentiate end-user outcomes, not just artifacts." That was read off T4-vague's **single-rater, unblinded** scores (a 49.5 four-way tie we ourselves flagged as false precision). T4-rich re-ran the same task properly: PM-quality brief, **blind ≥2-rater, three independent runs** (manual runtime, manual no-runtime, fully-automated headless).

**Blind, the control co-leads every run:**

| Blind code /40 | run-001 (runtime) | run-002 (no-runtime) | run-003 (automated) |
|---|---|---|---|
| leaders | bmad 34.75 | ai-dlc 34.75 | openspec 34.75 |
| **Vibe (control)** | **34.25** | **34.5** | **34.5** |
| band | 31.75–34.75 | 33.75–34.75 | 31.5–34.75 |

Three rater panels, three label permutations, two brief variants and a headless arm — the control sits at the top of the band each time. **On a 5,000-LOC consumer app, blind raters cannot tell the no-methodology code from the planned code.** The differentiation v0.7 credited to methodology was, under blind conditions, the planning dims again.

**Two T4-rich findings make the thesis concrete:**

### The $689 vs $20 datapoint (output-vs-artifacts, proven)
BMAD-002 (no-runtime brief) cost **$689.47 — the most expensive cell in the entire eval, 172× the cheapest BMAD cell** — and **~18h of API compute across 6 sessions spanning 3 days** (the full multi-agent lifecycle: 40 story files, a 606M-token cache-read trail — not idle time), against the control's single **41-minute** session. Its blind code: **34.5 — tied with the control's $20.36 cell (34.5).** The $669 premium bought a full PRD/epics/stories/canon-doc trail, not better code. For a *source deliverable*, that is the cleanest possible statement of the split: the document tax has no code-quality return; its value is process-artifacts for buyers who pay for documents (consultancy, compliance), not for buyers who want a working product.

### Perfect spec, shipped the bugs it predicted
BMAD-002 scored the cohort's **best planning dims** (Spec 5 / Scope 5 / Assumptions 5). Its canon doc *explicitly pre-warned the exact GZCLP and nSuns implementation traps.* The shipped code then **committed two of them as Major defects** — a GZCLP day-index double-advance that silently kills half the program's training days, and five native services that all throw `NotImplementedError`. **683 passing tests sailed past both.** Foresight that the spec captured and the implementation discarded. More planning did not produce more correct code.

### Cost ordering is not stable across the brief variant
run-001 → run-002 (removing the runtime requirement), the cost ordering *reverses*: AI-DLC −66%, Plan Mode −25%, Vibe −10%, OpenSpec +11%, BMAD +80%, Spec Kit +115%. What each methodology spends its budget *on* is structurally different — Spec Kit's run-001 cheapness was a refuse-to-build scope-cut; remove the trigger and it ships at proportional cost. There is no stable "cheap methodology"; there's a methodology × task-shape interaction.

---

## What the documents actually look like (the six-way artifact comparison)

The thesis says methodologies sell *documents, not programs*. Here's the documentation they sell, same task, same model — a **40× volume spread for code that scores within a 3-point blind band**:

| Methodology | Planning lines | Form of the spec | Blind code /40 | Cost |
|---|--:|---|:--:|--:|
| Vibe (control) | **0** | none (README post-hoc) | 34.25 | $22.74 |
| Plan Mode | 196 | one prose plan | 32.5 | $31.94 |
| OpenSpec | 909 | EARS requirements + scenarios | 33.5 | $20.64 |
| Spec Kit | 1,266 | TypeScript API contracts | 30.0† | $14.01 |
| AI-DLC | 3,891 | full Inception→Construction SDLC | 31.75 | $97.97 |
| BMAD | 8,154 | PRD + 40 per-story BDD specs | 34.75 | $384.05 |

The **same feature (the rest timer)** documented six ways shows it's a difference in *kind*, not just volume:
- **Plan Mode** — *"in-app timer + local notification on both platforms is solid"* (prose)
- **OpenSpec** — *"The rest timer SHALL auto-start when a set is logged… WHEN the user logs a set THEN the timer starts"* (verifiable behavior)
- **Spec Kit** — `interface RestTimerState { startedAt: number | null; … }` + `startRest()` method contract (buildable engineering doc)
- **BMAD** — a dedicated story file: *"As a lifter, I want my rest timer to start itself… AC2 — Timestamp-derived, never tick accumulation (FR-24, NFR-Resilience)"* + accessibility clauses (audit-grade)

**Crucially, the docs get genuinely better up the ladder — and the code doesn't follow.** BMAD's canon doc *pre-warned the exact GZCLP/nSuns traps* the implementation then shipped as Major defects. OpenSpec wrote 1/9th the documentation and shipped higher-aware-scoring code at 1/30th the cost. The document and the program are separable products; you pay for each on its own. Full excerpts + per-feature breakdown: `t4-fitness-app-rich/methodology-docs-comparison.md`.

†spec-kit blind is its run-002 number (30.0/40, full app); run-001 self-scoped domain-only and scored 22.0/30, not /40-comparable. Its 1,266 planning lines hold either way. (Same figure shown in `methodology-docs-comparison.md`.)

---

## Two findings carried from v0.7 (T3 — still the sharpest small-task results)

### The Pydantic v2 trap fired via blind review, not the binary check
T3's spec omits "Pydantic v2" but lists `pydantic[email]>=2.6`. The binary check grepped for v1 surface. **Vibe never imported Pydantic at all** — hand-rolled regex validation, deps file unused — so the grep passed *vacuously*. But 12 blind raters read the code, saw the absence, and docked Code + System design consistently (*"`UserRow` declared `BaseModel`, used as a dumb container"*; *"122-line if/elif tower for 5 fields"*). Vibe: 17.5/30, bottom. AI-DLC engaged v2 in its planning but shipped 223 LOC in one file — *"no separation of parse/validate/store/shape"* — 17.25/30, tied bottom. **Two cells at the same floor via opposite mechanisms: no framework, and unstructured framework use. The most-planned methodology produced the same blind code shape as the no-planning control.**

### The clarifying-question probe measured templates, not dialogue
T3 left data-retention silent, expecting cells to ask the PM persona. **Zero cells forwarded a question across the whole hexad** — the PM channel was dead. Discrimination happened anyway, through planning *templates*: Spec Kit's research.md, OpenSpec's design.md, AI-DLC's requirements.md each have a structural slot that forced the assumption to be written down. BMAD's adversarial-review subagent **caught the unbounded-dict issue mid-build and then discarded it** before shipped artifacts — caught-and-lost, the failure mode unique to internal review that doesn't propagate to deliverables. **The SDD pitch is "methodology forces you to ask the right questions." What T3 shows: methodology forces you to write down the right answers — whether or not anyone asks.**

---

## What this means for buyers (persona lenses)

| Lens | Weighting | Winner across T1–T4 |
|---|---|---|
| **Indie / cost-sensitive** | cost-heavy; product floor; rigor optional | **OpenSpec** on the floor-clearing tasks (T3/T4); **Vibe** on T1+T2 + as the blind-code co-leader generally — where there's no quality bar, the control ships competitive code cheapest |
| **Enterprise / rigor-weighted** | product + rigor equal; cost-blind | **Spec Kit** edges on richest artifacts; **OpenSpec** the cost-efficient close second |
| **Quality maximalist** | absolute quality, cost-blind | **Spec Kit** on small tasks; **BMAD** only on a high-ambiguity brief *if* you also value the document trail — its code alone doesn't justify the cost |

**OpenSpec wins indie + enterprise on the 3 floor-clearing task-runs** (spec-bound greenfield T3, vague mobile brief T4-vague, rich mobile brief T4-rich — aware /55 leader at ~1/30th BMAD's T4-rich cost) and is the cost-efficiency frontier / all-rounder on all five. On the two floor tasks (T1/T2), where there's no quality bar to clear, Vibe takes the indie corner and Spec Kit the enterprise corner. The strongest methodology-level claim in the eval; ranthebuilder.cloud's independent #1 corroborates under higher rigor.

---

## What we are careful NOT to claim

- **Not "ceremony is worthless."** Planning artifacts are real deliverables; the eval prices them, it doesn't dismiss them. Their value is reader-dependent.
- **Not "methodology never helps the product."** T3 shows a task shape where it does (the framework trap). The relationship is task-shape-conditional, not absent.
- **Not "more planning = more quality."** T3 (AI-DLC god-file) and T4-rich (BMAD shipping its own predicted bugs) both show the opposite past a small floor.
- **Not "the control is best."** The control co-leads blind *code*; it is near-zero on planning dims every task (1–2/15). If you value the artifacts, you are not buying the control.
- **Not "n=1 settles it."** Cells are single runs except T4-rich (n=3, which held). Defense is radical transparency + replication across four tasks. Community runs invited at v1.0.
- **Not "OpenSpec is the best methodology."** It is the most cost-efficient *under these conditions* (this model era, operator, task shapes). The cross-task corroboration is the claim; the superlative isn't.

---

## What's next

| Version | Scope | Why it matters |
|---|---|---|
| **v1.0 — T6** | OSS bug-fix on tldraw (surgical/diagnostic) | Hypothesis: the control may *win* — diving into code beats planning a fix. Tests the thesis on brownfield-surgical. |
| **v1.0 — T5** | Actual Budget feature (large brownfield, ~80K LOC) | Can a methodology produce a maintainer-acceptable PR in a big unfamiliar codebase? The axis none of T1–T4 covers. |

T4-rich also opens a clean follow-up the eval can run cheaply: a brief-quality isolation (same scope + runtime, only prose varies) to separate "PM hygiene" from the 3-way bundle (brief × scope × runtime) currently confounded in the vague-vs-rich delta.

---

*Operating snapshot: `analysis/handoff.md`. Per-task matrices: `analysis/t<N>-*/`. T4-rich: `scoring-matrix.md`, `run-002-evaluation.md`, `blind-pass-audit{,-run003}.md`. Per-cell logbooks: `runs/<task>/<methodology>/run-NNN/`. Evidence repos (private): `sdd-bench-t<N>-builds`, `sdd-bench-t4rich-builds` (code/screens/blind-reviews), `sdd-bench-logs` (transcripts). Model era: T1–T4-vague Opus 4.7/xhigh; T4-rich Opus 4.8/high.*
