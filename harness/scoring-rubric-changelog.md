# Scoring Rubric Changelog

Tracks structural and substantive changes to [`scoring-rubric.md`](scoring-rubric.md). Each entry notes whether the change affects score comparability with prior versions.

Format: `vX.Y — YYYY-MM-DD — one-line summary`. Body documents what changed and why, plus any migration notes.

---

## v0.1 — 2026-05-22 — Initial locked rubric (parallel-axis structure)

**Structure:**
- **Quality axis** — 12 anchored 0–5 dimensions:
  Functionality, Correctness (defect counts, reported separately), Code quality,
  System design, UI design, UX, Robustness, Security, Documentation,
  Spec articulation, Scope clarity, Assumption surfacing.
- **Cost axis** — raw token / time / intervention metrics + 6 derived ratios:
  Quality per 1K tokens, Quality per hour, Defects per 1KLOC,
  Methodology overhead ratio, Cost per binary outcome, Quality per dollar.
- **Headline finding** — (Quality sum, Cost) pair, plus binary-outcomes count.
- Applicability matrix per task.
- Equal-weight aggregation across applicable quality dimensions.
- Blinded review protocol; double-rate where a second reviewer is available.

**Pre-lock revisions** (all within 2026-05-22, before any cell was scored):
- Initial draft: 12 quality dimensions, cost metrics as sub-section labeled "Instrumented metrics (reported, not scored)."
- Cost promotion: cost metrics elevated to first-class with 6 derived ratios; "(quality, cost) pair" introduced as headline finding.
- Parallel-axis restructure: cost section moved out from under quality and made a peer top-level section. Quality axis and Cost axis read as two equal halves; reader feedback was that the previous structure made cost feel like a sidebar.

**Score comparability:** N/A — initial version.

---

## v0.1.1 — 2026-05-25 — Applicability matrix extended for T6; T4-rich note

**Changed:**
- Applicability matrix gains a T6 (bug-fix) column. All 12 dimensions apply, with two notes: System design dim 4 marked as "limited — small fixes"; Scope clarity dim 11 noted as "load-bearing — diff minimality" for T6 specifically (a methodology's diff scope is a major signal on bug-fix tasks).
- Added explanatory note that T4-rich inherits T4's applicability column (same task; only the brief differs; pair's differential is the finding).
- T6 task-specific binary outcomes (existing tests pass, regression test added, diff minimal) noted as living in `tasks/t6-bug-fix/success-criteria.md` — captured in binary-outcomes checklist, not 0–5 scoring.

**Reason:** PROJECT-BRIEF.md scope expanded post-v0.1 to add T6 bug-fix task (v0.8) and T4-rich brief-quality variant (v0.4-rich). Applicability matrix needs to reflect these.

**Score comparability with v0.1:** non-substantive (additive only). Prior T1–T5 cells' scores remain valid; no re-score needed. T6 introduces a new task scoring schema but doesn't change how existing tasks are scored.

---

## v0.1.2 — 2026-05-25 — Half-point granularity permitted on 0–5 dimensions

**Changed:**
- The 12 anchored quality dimensions may be scored in 0.5 increments (e.g., 3.5) when evidence places a dimension genuinely between two adjacent anchors. Default remains whole-integer; a half-point is used only for true between-anchor cases and must carry a one-line rationale naming which higher-anchor criteria are only partially met. Per-dimension max stays 5; the quality sum stays out of 55 but may be non-integer.

**Reason:**
- First cell scored (T4-Vibe run-001). System design (dim 4) landed genuinely between the "3" anchor (clean boundaries, survives the brief's stated needs) and the "4" anchor (absorbs the next two obvious requirements): the `ProgramMeta` registry is 4-grade, but a non-future-proof single-blob data model and a UI/data per-set-weight divergence are two distinct 4-blockers. Forcing an integer discarded real signal.

**Score comparability with v0.1.1:** backwards-compatible — no cell had been scored under integer-only granularity yet (T4-Vibe run-001 is the first), so no re-score needed. All cells, across all four methodologies, use 0.5 granularity from this point for comparability.

---

## v0.2 — 2026-05-27 — Scoring discipline after the T4 tie audit

**Changed (additive process rules in "How a cell is scored"; no anchor text altered):**
- **Vector reporting mandatory.** Every quality sum must be published with its (Product polish /20, Engineering rigor /35) decomposition; a bare total or bare "tie" is disallowed.
- **Absolute-not-relative rule.** Each score must cite the anchor clause it meets; "ties X / below Y" justifications are banned.
- **No-ceiling-inflation rule.** A 5 requires the level-5 clause independently evidenced (esp. Scope = scope *revisited*, Spec = edge cases *predicted*).
- **Saturation guard** (≥3 identical scores on a dim → justify or spread).
- **Score-the-artifact-not-coverage** rule (don't dock for incomplete review).
- **No double-counting** one root-cause defect across multiple dimensions.
- **Provisional flag** for unblinded/single-rater scores; report band/cluster (not half-point ranks) when cells are within ~1.5 points.

**Reason:**
- The T4 hexad produced a 4-way 49.5 "tie" (OpenSpec/Spec Kit/AI-DLC/BMAD). An audit (`analysis/t4-fitness-app/rigor-pass-tie-audit.md`) found the tie was an artifact of (a) unblinded single-rater scoring with relative anchoring, (b) ceiling saturation (Scope/Spec scored 5 for anchor-4 behavior), and (c) equal-weight summing hiding anti-correlated Product-vs-Rigor profiles. De-biased against absolute anchors the four spread to a ~48–50 cluster. These rules close those gaps.

**Score comparability with v0.1.2:** backwards-compatible — **no anchor definitions changed, so no numeric re-score is forced.** Existing T4 scores stand as committed *provisional* history; the new rules govern reporting (vector + provisional labels) and future scoring discipline. A full blind re-rate, if run later, may revise numbers and would be noted as its own migration.

---

## v0.2.1 — 2026-05-27 — T2 retasked (better-search → library API extension); applicability matrix updated

**Changed:**
- Applicability matrix column header `T2 search` → `T2 library`.
- T2 dims **UI (5)** and **UX (6)** changed `✓ → —`. The former T2 ("better search") assumed a search UI surface; the new T2 is a pure HTTP API with no end-user UI. Security (dim 8) remains `✓` (untrusted request bodies + path/query params).
- Added a "T2 library specifics" note (alongside the T4-rich and T6 notes): dims 3 + 4 load-bearing for convention adherence; T2 binary outcomes live in `tasks/t2-library-loans/success-criteria.md`.

**Reason:**
- T2 ("better search") was retired before any cell ran. It required authoring a believable docs corpus (a content-creation project, not a spec), had no clean objective scorer, and was redundant with the T4 vague/rich pair as a discovery instrument (which measures ambiguity as a *differential* on a fixed task — a cleaner instrument than an isolated, unscoreable high-ambiguity cell). Replaced with a small brownfield FastAPI extension ("add 3 loan endpoints to an existing library service"): objectively scored by a provided test suite, legible as a recognizable archetype, and the small/clean entry point of the brownfield gradient (T2 small extension → T5 large feature → T6 large bug). See PROJECT-BRIEF.md § Task Set.

**Score comparability with v0.2:** non-substantive — **no T2 cell had been scored** (no anchor definitions changed; only T2's applicable-dimension set changed). No re-score needed. T1, T3–T6 unaffected.

---

## v0.2.2 — 2026-05-27 — Cost-axis time metric: API compute time replaces active session time as the scored number

**Changed (Cost axis only; no quality anchor altered):**
- **Scored time metric is now API compute time** (raw model-inference time), not "active session time." Rationale: wall-clock and active-session numbers are dominated by operator-in-the-loop latency (reading, gating, idle) and tool-execution round-trips, so they aren't comparable across methodologies. API compute time isolates the model's actual work.
- **Wall-clock + active session time retained as disclosed context, not scored.** Operator-touch time and operator intervention count are unchanged (kept as babysitting signals — orthogonal to the wall-vs-API question).
- Derived ratio **"Quality per hour" → "Quality per API hour"** (denominator: API compute hours).
- **Methodology overhead ratio** rebased to API compute time (planning-phase API time / implementation API time).
- **Time to first working build** and **phase-level breakdown** rebased to API compute time; wall-clock equivalents disclosed alongside.
- Headline finding's Cost time is now labeled "API compute."

**Reason:**
- The first scored cells already captured API compute time "for transparency" beside active session time (e.g., T4-Vibe: API compute 17m 27s vs. active 19m 45s vs. wall-clock 24h idle). Designating which of the three is authoritative is what was missing; this entry makes API compute the headline because it's the only one comparable across methodologies and unaffected by operator pace or rate-limit pauses.

**Score comparability with v0.2.1:** backwards-compatible on quality (no anchor definitions changed — no quality re-score). **Cost-axis migration for the scored cells:** the full T4-fitness-app hexad (6 cells) already carries cost data. Four record a clean API-compute figure — Vibe 17m 27s, Plan-Mode 22m 43s, BMAD 1h 32m 19s, Spec-Kit 30m 4s — so their Quality-per-API-hour + overhead ratios recompute directly. OpenSpec records an API-duration figure (25m 42s) under a non-standard label ("Active wall-clock (API duration)") → relabel, then recompute. AI-DLC's token-log conflates "API / active time (per /status), 38m 30s" → disambiguate to a true API-compute figure before recomputing. These six cells stand as committed provisional history (per v0.2); the recompute is a deliberate scoring action, not part of this changelog edit. Any ratio previously computed on active-session hours is superseded.

---

## v0.3 — 2026-05-27 — Blinded ≥2-rater protocol formalized (T2 kickoff; in force T2-onward)

**Changed (additive process section; no anchor text altered):**
- New **"Blinded ≥2-rater protocol"** section in "How a cell is scored", locked as the standing scoring procedure for **T2 and every task after it**. Codifies what the v0.1/v0.2 "Blinding" bullet only gestured at:
  - **Dimension split.** Code-visible dims (1 Functionality, 3 Code quality, 4 System design, 7 Robustness, 8 Security where applicable, 9 Documentation — *shipped* docs only) take a **blind primary rating**; planning dims (10 Spec, 11 Scope, 12 Assumptions) are **single-rater by necessity** (the artifacts are the methodology tell). On brownfield tasks (T2/T5/T6) the blind set is larger because Code quality + System design are diff-visible convention signals.
  - **Blind-agents-primary mechanism.** Stage one anonymized code+tests+manifest bundle per cell (strip all methodology dirs/docs/identifying strings), randomized A–F label map, ≥2 independent fresh-agent raters score code-visible dims on absolute anchors, operator runs a methodology-aware functional + convention adjudication and single-rates planning dims.
  - **Reconciliation rule** resolves the v0.2 tension: same-condition raters >1 apart rescore together; a blind rating vs a methodology-aware rating are *different conditions* → kept separate, never averaged (T4 tie-audit / T1 precedent).
  - **Reporting:** code-visible dims within inter-rater noise → report as a cluster, not point scores; all blind/single scores stay PROVISIONAL until confirmed within 1 point.
- Updated the short "Blinding" bullet ("Output A through D" → "A through F"; dropped the now-superseded inline double-rate clause, which moved into the protocol section) and the footer (v0.1 → v0.3).

**Reason:**
- T1's HEXAD finding rested on a blind code-only second-rater pass (`analysis/t1-postal-validator/blind-pass-audit.md`) that was run *after* unblinded single-rater scoring — a retrofit. The prospective decision logged at T1 close was to **lock a blinded ≥2-rater protocol for T2–T6 and not retrofit T1.** This entry executes that. T2 is scored blind from the start so its convention-adherence finding (dims 3+4, diff-visible) carries a real second rating rather than a post-hoc one.

**Score comparability with v0.2.2:** non-substantive (process/procedure only — **no anchor definitions changed, no re-score forced**). T1's two ratings stand as separate disclosed measurements (not reconciled). T3–T6 unaffected. T2 will be the first task scored under the protocol as a first-class step.

---

<!--
## vN.M — YYYY-MM-DD — Summary

**Changed:**
-

**Reason:**

**Score comparability with prior version:**
- Backwards-compatible: scores in vN-1 cells remain valid under vN, OR
- Migration needed: previously-scored cells must be re-scored on dimensions X / Y, OR
- Non-substantive (structural / wording only): no re-score needed.
-->
