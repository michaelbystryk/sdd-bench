# Analysis

Cross-cell analytical artifacts. Per-cell logbooks live in `runs/<task>/<methodology>/run-NNN/` (session-log + token-log + observations + artifacts); this directory holds the *across-cell, across-task, across-version* analyses that span individual runs.

## Layout

```
analysis/
├── README.md                     ← this file
├── handoff.md                    ← project-state (living): versioning, locked decisions, decisions log, headline TL;DR
├── harness-sessions/             ← durable copies of the harness CC session JSONLs (this conversation's transcripts)
│
├── t1-postal-validator/          ← ✅ SCORED: scoring-matrix.md + feature-matrix.md + blind-pass-audit.md
├── t2-library-loans/             ← ✅ SCORED: scoring-matrix.md + feature-matrix.md + blind-pass-audit.md + blind-label-map.md + blind-rater-prompt.md
├── t3-csv-openapi/               ← ✅ SCORED: scoring-matrix.md + feature-matrix.md + blind-pass-audit.md + blind-label-map.md + blind-rater-prompt.md
├── t4-fitness-app/               ← ✅ SCORED
│   ├── scoring-matrix.md         ← cross-cell SCORES matrix (dims × methodologies + cost + persona lenses + verdicts)
│   ├── feature-matrix.md         ← cross-cell FEATURE parity audit (built / cut / missed per feature × methodology)
│   └── rigor-pass-tie-audit.md   ← the 49.5 four-way-tie de-bias audit
├── t4-fitness-app-rich/          ← ✅ SCORED: T4-rich hexad×3 (runtime / no-runtime / headless)
├── t5-actual-feature/
├── t6-bug-fix/
│
├── party-findings/               ← P-TRACK (party mode vs plain Claude on advisory tasks)
│   └── 00-detection-saturation.md  ← pre-run finding: plain Opus pass saturates detection; objective axis re-roled
│
└── (future) v0.4.md, v1.0.md     ← frozen version writeups when each version ships
```

## File-type guide

| File | Purpose | Lifecycle |
|---|---|---|
| `handoff.md` | Project-state snapshot: versioning roadmap, locked artifacts, decisions log, latest headline. Always reflects current state. | Living — updated after each cell scoring per the runbook. |
| `t<n>-<task>/scoring-matrix.md` | Cross-cell SCORES matrix for one task: 12 quality dims × N methodologies, plus defects, binary outcomes, cost axis, derived ratios, and per-cell headline verdicts. Single source of truth for scores — cells' own observations.md keep the rationale, matrix keeps the numbers. | Living — extended each time a new methodology cell scores on that task. |
| `t<n>-<task>/feature-matrix.md` | Cross-cell FEATURE parity audit for one task (separate from scores): which features each methodology built / cut / missed; what the per-task distribution analysis tells us. | Living — extended each time a new methodology cell scores on that task. |
| `t<n>-<task>/<other>.md` | Task-specific writeups, headline-finding drafts, cross-methodology distillation. | Created as tasks complete enough cells to warrant deeper analysis. |
| `v0.4.md`, `v1.0.md`, etc. | Frozen-at-ship-time version writeups. Each one's scope spans the cells included in that version. | Created when a version ships; immutable after that. |
| `harness-sessions/` | Operational records of the harness CC sessions (the conversation that built and scored the eval). Not findings — provenance. | Updated via the same `cp + parse-cell-transcript.py` flow whenever the operator wants a checkpoint. |

## When to update what

After scoring a cell (per `harness/operator-runbook.md` § Scoring step 12-15):

1. **`runs/<task>/<methodology>/run-NNN/observations.md`** — the cell's own scores + rationale + defect detail
2. **`analysis/t<n>-<task>/scoring-matrix.md`** — extend this methodology's column for ALL sections (12 dims + defects + binary + cost + derived ratios + headline verdict)
3. **`analysis/t<n>-<task>/feature-matrix.md`** — extend this methodology's column with built / cut / missed per feature
4. **`analysis/handoff.md`** — append to decisions log + update TL;DR if a sharp finding emerged
5. Commit all four together with message `Score <cell>: Q <N>/55, $<cost>, <verdict>`

## Findings so far (cross-task exec summary)

*Living summary — updated as tasks complete. **Four task-hexads + the T4-rich brief variant scored:** **T4** (Expo fitness app — medium complexity, high ambiguity), **T1** (postal CLI — greenfield floor, low/low), **T2** (library API extension — brownfield-additive-small, low/low), **T3** (CSV import endpoint to OpenAPI spec — spec-bound greenfield, medium/low — *the workhorse*), plus **T4-rich** (PM-quality brief variant, hexad×3). Single-run (n=1) per cell except T4-rich (×3); exploratory framing.*

### The throughline (T4 + T1 + T2 + T3)

1. **The ceremony tax is real on every task.** Structured methodologies cost multiples more than the no-methodology control (T4: 13×, $5.84→$75.85; T1: 7.7×, $0.59→$4.57; T2: 4.7×, $1.01→$4.75; T3: 6.2×, $0.93→$5.72), and the light options (Plan Mode, OpenSpec) reach competitive quality on every one.
2. **What ceremony buys is mostly planning rigor — but T3 is where shipped code starts to discriminate too.** T1+T2: blind code-only convergence (Vibe at the top of both blind panels on T2; co-leader on T1). **T3 reverses this** — across two independent blind panels (0/36 >1pt disagreements — strongest agreement so far), the code-visible cluster sits at **17.0–21.5/30**, and **Vibe is at the BOTTOM (17.5, tied with AI-DLC 17.25)**. The silent Pydantic v2 trap discriminated under blind review: Vibe sidestepped the framework entirely (no models, hand-rolled regex), AI-DLC engaged it but shipped a 223-LOC single-file `main.py`. **The framework matters once it actually matters.** Multi-file structured cells (Vibe Plan Mode 21.25, OpenSpec 20.75, BMAD 20.75) cluster ahead. The planning-rigor finding still holds (Vibe planning 1/15 → Spec Kit 13.5/15) — but T3 adds: **on spec-bound greenfield work where the framework discriminates, methodology buys structurally better code, not just better artifacts.**
3. **The C-axis (deliberate spec ambiguity) discriminates differently than the v2 trap.** T3 introduced a retention/lifecycle question the spec leaves silent; Spec Kit + OpenSpec + AI-DLC all named retention as an explicit assumption in their planning artifacts (Row 2). Vibe Plan Mode caught the v2/async/streaming traps via its plan but **silently picked retention** the same way Vibe-pure did (Row 4) — *Plan Mode surfaces what the spec says; it doesn't surface what the spec OMITS unless the cell happens to notice.* BMAD's adversarial-review subagent caught the unbounded-dict issue mid-build but **discarded the finding** before shipped artifacts — caught-and-lost (Row 3), sharpest T3-specific process miss. **Zero cells forwarded a clarifying question to pm-ask across the hexad.**
4. **OpenSpec is the cost-efficiency frontier across all FOUR tasks** — won both persona lenses on T4; all-rounder on T1; best Q/$ on T2 ($1.89, Q/$ 19.3); **best Q/$ above the 30-quality bar on T3 ($2.91, Q/$ 11.6)**. **Strongest single methodology-level finding of the eval.** Corroborates ranthebuilder.cloud's April-2026 #1 across four domains under anchored rigor.
5. **Methodology sets cost + balance, not the quality ceiling — but T3 inflects the curve.** T4: four structured cells cluster high-40s. T1: all six clear the floor (planning spread). T2: structured cluster 35–38, Vibe + Plan Mode trail. **T3: structured cluster 28–34, Vibe (18.5) clearly alone at the bottom** — first task where the no-methodology control is decisively last (not just trailing). The framework-engagement requirement was the cliff.
6. **Adaptive right-sizing replicates as a methodology trait — 3-for-3 on code tasks.** BMAD self-routed to quick-dev on T1 ($4.00), T2 ($4.33), **and T3 ($4.67)** vs full multi-agent ceremony on T4 ($75.85); AI-DLC ran its full lifecycle on all four tasks (T3 was its cheapest at $2.73 — explicit spec collapsed construction iterations).
7. **The control's standing is task-shape dependent.** Vibe is **top-tier on small fully-specified work where the codebase is the reference** (T1 indie lens win; T2 blind code co-leader) but **falls behind when the spec implies framework + structural requirements** (T3 bottom of blind code) **and when ambiguity rises** (T4: 29/55, no documented scope). The "Vibe is indistinguishable on shipped code" finding is *task-shape conditional*, not universal.

### Per-task headlines

- **T4** ([`t4-fitness-app/`](t4-fitness-app/scoring-matrix.md)): four structured methods cluster in the high-40s/55 (provisional 49.5 — single-rater scoring noise; see [tie-audit](t4-fitness-app/rigor-pass-tie-audit.md)); cost spans 13×. OpenSpec wins both persona lenses; AI-DLC its quality-twin at ~2.7× cost; BMAD the expensive rigor corner; Vibe the prototype floor.
- **T1** ([`t1-postal-validator/`](t1-postal-validator/scoring-matrix.md)): all six clear the floor (46/46 tests, stdlib-only, 0 crit/0 major). Quality /40: Spec Kit 36 > AI-DLC 35 > OpenSpec 32.5 > BMAD 31 > Plan Mode 26.5 > Vibe 21 — but the spread is entirely planning rigor (code dims indistinguishable under [blind re-rate](t1-postal-validator/blind-pass-audit.md)). Persona lenses **split**: Vibe wins indie, Spec Kit wins enterprise.
- **T2** ([`t2-library-loans/`](t2-library-loans/scoring-matrix.md)): all six pass 4/4 binary (21/21 tests, no new deps, convention cut passed). Quality /45 (after pass-2 reconciliation): Spec Kit 38 > OpenSpec 36.5 > BMAD 36 > AI-DLC 35 >> Plan Mode 31 > Vibe 28 — **but across two independent blind panels** ([blind-pass-audit](t2-library-loans/blind-pass-audit.md)) the code-visible cluster sits at **23.5–26/30, with Vibe the only cell at the top of *both* passes (26 + 26)** — the T1 finding replicates on brownfield, *more strongly with the second panel*. Persona split again: Vibe wins indie (Q/$ 27.7), Spec Kit wins enterprise; OpenSpec the cost-efficiency frontier.
- **T3** ([`t3-csv-openapi/`](t3-csv-openapi/scoring-matrix.md)): all six pass 5/5 binary (14/14 tests + no-new-deps + v2 idiom + async + 413). Quality /45: **OpenSpec 33.75 > Spec Kit 33 > BMAD 29.75 > AI-DLC 28.25 > Plan Mode 25.25 >> Vibe 18.5**. **The T1/T2 blind-code finding REVERSES** ([blind-pass-audit](t3-csv-openapi/blind-pass-audit.md)) — 0/36 >1pt disagreements across both panels; Vibe (17.5) tied with AI-DLC (17.25) at the BOTTOM of the blind code band (17.0–21.5/30). **The silent Pydantic v2 trap discriminated** — Vibe shipped zero Pydantic models (hand-rolled regex); AI-DLC's full Inception+Construction lifecycle produced a 223-LOC single-file `main.py` (same god-file shape as Vibe). C-axis retention ambiguity: 3 cells named it as assumption (Spec Kit / OpenSpec / AI-DLC), BMAD caught + lost it via internal QA, 2 cells silent (Vibe + Plan Mode). **OpenSpec wins indie lens AND clears quality bar at $2.91 (Q/$ 11.6); Spec Kit + OpenSpec tie on enterprise rigor (33 + 33.75) with Spec Kit at ~2× cost.**

### Scored cells

- **T4 hexad** (all 7/7 binary): Vibe 29/$5.84 · Plan Mode 43.5/$7.78 · OpenSpec 49.5/$7.16 · Spec Kit 49.5/$13.21 · AI-DLC 49.5/$19.15 · BMAD 49.5/$75.85.
- **T1 hexad** (all 3/3 binary): Vibe 21/$0.59 · Plan Mode 26.5/$1.07 · OpenSpec 32.5/$1.32 · BMAD 31/$4.00 · Spec Kit 36/$4.20 · AI-DLC 35/$4.57.
- **T2 hexad** (all 4/4 binary; code dims ≥2-rater blind): Vibe 28/$1.01 · Plan Mode 31/$1.35 · OpenSpec 36.5/$1.89 · BMAD 36/$4.33 · Spec Kit 38/$3.90 · AI-DLC 35/$4.75 *(AI-DLC 36.5→35 after pass-2 corrected pass-1's factual error on README content)*.
- **T3 hexad** (all 5/5 binary; code dims ≥2-rater blind, 0 disagreements): Vibe 18.5/$0.93 · Plan Mode 25.25/$1.41 · AI-DLC 28.25/$2.73 · OpenSpec 33.75/$2.91 · BMAD 29.75/$4.67 · Spec Kit 33/$5.72.

**Pending:** T5, T6, T7.

### Rigor posture

Scores are provisional + single-rater (the rubric's blinding + double-rating not yet run uniformly). T1 added a blind code-only second-rater pass; a blinded ≥2-rater protocol is locked for T2+ (see `handoff.md`). Report quality as the (Usability/Product, Rigor, Cost) vector + persona composite — never a bare scalar or "tie."

See `handoff.md` for operational state + decisions log; each task's `scoring-matrix.md` for the numbers.
