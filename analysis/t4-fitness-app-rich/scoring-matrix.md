# T4-rich — Combined Scoring Matrix (run-001 + run-002)

**Compiled:** 2026-06-01. **Task:** Compound Strength App (Expo/RN, 7 programs, no-math mid-workout loop). **Model:** Claude Opus 4.8 / effort high (all 12 cells). **Scorer:** Sonnet 4.6 (single instrument across all scoring).

Two briefs, one task: **run-001 = runtime** (`brief.md`, dev build on iOS sim) · **run-002 = no-runtime** (`brief-no-runtime.md`, source + tests as a PR). Same product, different deliverable.

> **run-003 (automated arm) is scored separately** — see [§ run-003](#run-003-automated-arm-headless-no-operator) below. It is the headless `claude -p` arm (no operator in the loop), so it is **not** pooled into the operator-driven 001/002 master table or paired-Δ; it stands as its own comparison.

## Three measurement conditions (kept SEPARATE per rubric v0.3 — never averaged)

| Condition | What | Raters | Scale |
|---|---|---|---|
| **Blind code** | 8 code-visible dims, anonymized leak-scrubbed bundles | 2 fresh Sonnet (p1+p2) | /40 (/30 if no UI) |
| **Code-based (aware)** | all 12 dims incl. planning, from un-anonymized source | 1 Sonnet, PROVISIONAL | /55 (/45 if no UI) |
| **Runtime (Maestro)** | live sim walkthrough — vibe-001 ONLY | operator-driven | binary + dims |

> Blind ≠ aware: different conditions, reported side by side, not reconciled. The aware /55 includes planning dims (Spec/Scope/Assumptions) which are single-rater *by necessity* (they live in the planning artifacts = the methodology tell, can't be anonymized).

---

## MASTER TABLE

| Cell | Blind /40 | Aware /55 | Cost | Defects/1KLOC | Notes |
|---|:--:|:--:|:--:|:--:|---|
| **vibe-001** | 34.25 | 39.0 | $22.74 | ~2.3 | only runtime-verified cell (Maestro, 14/14 binary) |
| **vibe-002** | 34.5 | 40.5 | $20.36 | 0.74 | 124 jest tests + ASSUMPTIONS/HANDOFF docs |
| **planmode-001** | 32.5 | 44.0 | $31.94 | 1.48 | research overhead (web/sub-agents) |
| **planmode-002** | 33.75 | 44.0 | $24.09 | 0.78 | SysDes 5 |
| **openspec-001** | 33.5 | 45.5 | $20.64 | 1.21 | archive finalized; 50 tests |
| **openspec-002** | 34.25 | 45.5 | $22.91 | 0.89 | 96 tests; **aware-/55 leader both runs** |
| **ai-dlc-001** | 31.75 | 44.5 | $97.97 | 0.40 | PBT fast-check; 159 tests; lowest defect density |
| **ai-dlc-002** | 34.75 | 44.0 | $33.50 | 0.66 | **blind leader run-002** |
| **bmad-001** | 34.75 | 46.5 | $384.05 | 0.69 | **aware-/55 + blind co-leader run-001** |
| **bmad-002** | 34.5 | 42.5 | **$689.47** | 0.59 | most expensive cell in eval (~18h API / 6 sessions); 3 Major (severity regression) |
| **spec-kit-001** | 22.0 /30 | 34.0 /45 | $14.01 | 0.88 | domain-only, NO app (self-scoped, untested no-sim assumption) |
| **spec-kit-002** | 30.0 | 44.0 | $30.10 | 0.90 | shipped full app — inverts 001 |

*Blind = 2-rater p1/p2 avg, 0/192 dim-pairs >1pt apart. Aware = single-rater PROVISIONAL. All file-sourced.*

---

## Quality axis — 12 dimensions × 6 methodologies (run-001, aware single-rater)

The direct analog to T4-vague's table. Scores per `harness/scoring-rubric.md`; bold = highest in row (ties bolded together). **For the 8 code-visible dims (1, 3–9) the *authoritative* measurement is the blind ≥2-rater pass** (the "Blind /40" row below + the MASTER TABLE) — blind, these collapse to a **31.75–34.75 band** and the per-dim spread here sits inside inter-rater noise. The reproducible separation is the **planning trio (10–12) + cost**. Run-002/003 per-dim scores live in each cell's `runs/.../observations.md`.

> ⚠️ **PROVISIONAL (single-rater, unblinded)** — same caveat as T4-vague: labels visible, ±~1/cell. Kept **separate from** the blind pass, never averaged (rubric v0.3). This table's value is the planning-dim and polish-vs-rigor *shape*, not a code-quality ranking — on code, defer to Blind /40.

| # | Dimension | Vibe | Plan Mode | OpenSpec | Spec Kit† | AI-DLC | BMAD |
|---|---|:--:|:--:|:--:|:--:|:--:|:--:|
| 1 | Functionality | **4.5** | **4.5** | **4.5** | 2.0 | **4.5** | **4.5** |
| 2 | Correctness | (defects) | (defects) | (defects) | (defects) | (defects) | (defects) |
| 3 | Code quality | 4 | 4.5 | **5** | 4.5 | **5** | 4.5 |
| 4 | System design | 4 | **5** | **5** | 4.5 | **5** | **5** |
| 5 | UI design | 4 | 4 | 4 | n/a | 4 | 4 |
| 6 | UX | **4.5** | 4 | 4 | n/a | 4 | 4 |
| 7 | Robustness | **4** | 3.5 | **4** | 3.5 | **4** | **4** |
| 8 | Security | **4** | 3 | 3 | 3 | 3 | 3 |
| 9 | Documentation | **4** | 3 | 3 | 3 | 2 | 3.5 |
| 10 | Spec articulation | 1 | 4.5 | **5** | **5** | **5** | **5** |
| 11 | Scope clarity | 3 | 4 | 4 | **4.5** | 4 | 4 |
| 12 | Assumption surfacing | 2 | 3.5 | **4** | **4** | **4** | **4** |
| | **Aware sum** | **39 / 55** | **44.0 / 55** | **45.5 / 55** | **34.0 / 45** | **44.5 / 55** | **46.5 / 55** |
| | **Blind /40 (authoritative — code dims)** | 34.25 | 32.5 | 33.5 | 22.0 /30 | 31.75 | 34.75 |

† **spec-kit-001 self-scoped to domain-only (no app)** → UI/UX n/a, scored /45; its run-002 sibling shipped a full app (aware 44.0/55, blind 30.0/40). UI/UX bolds exclude it.

### Quality as a vector — Product polish vs Engineering rigor (run-001, aware)

Product polish = Functionality + UI + UX + Robustness (/20); Engineering rigor = Code + System + Security + Docs + Spec + Scope + Assumptions (/35).

| Sub-axis | Vibe | Plan Mode | OpenSpec | Spec Kit† | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Product polish /20** | **17.0 (85%)** | 16.0 (80%) | 16.5 (82.5%) | n/a (no UI) | 16.5 (82.5%) | 16.5 (82.5%) |
| **Engineering rigor /35** | 22.0 (62.9%) | 27.5 (78.6%) | **29.0 (82.9%)** | 28.5 (81.4%) | 28.0 (80.0%) | **29.0 (82.9%)** |

Same shape as T4-vague: **the control (Vibe) leads product polish; the structured cells lead rigor** — and the rigor gap is the planning dims. The T4-rich correction is that blind, even the product/code gap closes (control co-leads the blind band), so the *only* durable separation is rigor + cost. † spec-kit-001 product polish n/a (2 of 4 product dims absent).

### Final composite — persona lenses (run-001, aware)

Same formula as T4-vague: **Indie-dev** = 0.70·Product% + 0.30·Rigor%, rank by **Q/$**; **Enterprise** = 0.40·Product% + 0.60·Rigor%, cost-blind, rank by **WQ**. Cost = run-001 implied API $.

> Built on the **aware single-rater** Product/Rigor split → carries the PROVISIONAL caveat. **Blind, the Product (code) contribution is a tight band**, so the separation below is driven by the **planning dims (Rigor) and cost**, not code quality — the T4-rich headline, stated as a composite.

| Cell | Indie WQ | **Indie eff. (Q/$)** | Enterprise WQ | **Ent. rank** | Vector (P% · R% · $) |
|---|:--:|:--:|:--:|:--:|---|
| **OpenSpec** | 82.6 | **4.00 · #1** | 82.7 | **#1 (tie)** | 82.5 · 82.9 · $20.64 |
| BMAD | 82.6 | 0.22 · #5 | 82.7 | **#1 (tie)** | 82.5 · 82.9 · $384.05 |
| AI-DLC | 81.8 | 0.83 · #4 | 81.0 | #3 | 82.5 · 80.0 · $97.97 |
| Plan Mode | 79.6 | 2.49 · #3 | 79.1 | #4 | 80.0 · 78.6 · $31.94 |
| Vibe | 78.4 | 3.45 · #2‡ | 71.7 | #5 | 85.0 · 62.9 · $22.74 |
| Spec Kit† | n/a | n/a | n/a | n/a | no UI (run-001) |

**OpenSpec wins indie outright (Q/$ 4.00) and ties BMAD #1 on enterprise WQ — at ~1/19th BMAD's cost.** The same "OpenSpec is the cost-efficiency frontier" result as every other task: BMAD matches its enterprise quality only by ignoring 19× the spend (and blind, BMAD's *code* ties the control). Vibe leads raw product polish but its near-zero planning dims sink it on the rigor-weighted enterprise lens — the T1/T2 pattern, replicated.

† spec-kit-001 self-scoped domain-only → no product score → omitted; its run-002 app sibling lands mid-pack (aware 44.0/55). ‡ Vibe's high Q/$ sits right at the ~80 indie product-quality bar (below which a build isn't "shippable to users" for this lens), so OpenSpec is the clean indie pick.

### Final composite — run-002 (no-runtime; all 6 shipped full apps — the clean 6-way)

Same formula; cost = run-002 implied API $. **All six shipped a runnable app here** (spec-kit-002 included), so no n/a — this is the cleanest all-cells composite.

| Cell | Indie WQ | **Indie eff. (Q/$)** | Enterprise WQ | **Ent. rank** | Vector (P% · R% · $) |
|---|:--:|:--:|:--:|:--:|---|
| **OpenSpec** | 82.6 | **3.61 · #2** | **82.7** | **#1** | 82.5 · 82.9 · $22.91 |
| Plan Mode | 78.7 | 3.27 · #3 | 79.9 | #2 | 77.5 · 81.4 · $24.09 |
| AI-DLC | 77.4 | 2.31 · #5 | 79.7 | #3 | 75.0 · 82.9 · $33.50 |
| Spec Kit | 76.0 | 2.53 · #4 | 79.6 | #4 | 72.5 · 84.3 · $30.10 |
| BMAD | 72.1 | 0.10 · #6 | 76.7 | **#5** | 67.5 · 82.9 · $689.47 |
| Vibe | 78.3 | **3.85 · #1**‡ | 74.1 | #6 | 82.5 · 68.6 · $20.36 |

**The BMAD "enterprise tie" does not survive run-002.** Forced to ship a *source deliverable* it couldn't runtime-verify, BMAD shipped an **unwired product** → product polish cratered (16.5→13.5/20) → it falls to **enterprise #5** (and indie last at $689). OpenSpec wins enterprise **outright** and is the indie pick once Vibe's sub-80 WQ is bar-gated. ‡Vibe tops raw Q/$ but sits below the ~80 indie product bar.

### Final composite — run-003 (headless automated arm)

Same formula; cost = run-003 implied API $. Reported separately (no operator in the loop). Costs are bunched ($18–40) so Q/$ no longer swamps the rank.

| Cell | Indie WQ | **Indie eff. (Q/$)** | Enterprise WQ | **Ent. rank** | Vector (P% · R% · $) |
|---|:--:|:--:|:--:|:--:|---|
| **OpenSpec** | 85.6 | **4.72 · #1** | **88.7** | **#1** | 82.5 · 92.9 · $18.12 |
| Spec Kit | 84.3 | 3.47 · #3 | 88.6 | #2 | 80.0 · 94.3 · $24.29 |
| BMAD | 86.5 | 2.68 · #5 | 88.0 | #3 | 85.0 · 90.0 · $32.32 |
| AI-DLC | 80.0 | 2.00 · #6 | 82.4 | #4 | 77.5 · 85.7 · $39.94 |
| Plan Mode | 81.3 | 3.69 · #2 | 80.1 | #5 | 82.5 · 78.6 · $22.01 |
| Vibe | 78.8 | 2.88 · #4 | 75.0 | #6 | 82.5 · 70.0 · $27.35 |

Here the neutral-router BMAD is cost-competitive ($32, not $384), so it's a close enterprise **#3** — but OpenSpec still wins **both** lenses (cheapest *and* top enterprise WQ); OpenSpec / Spec Kit / BMAD sit within noise at the top (88.7 / 88.6 / 88.0), separated only by cost.

### Across all three runs

**OpenSpec is enterprise #1 in every run** (and indie #1 once Vibe is bar-gated). BMAD's enterprise rank swings **#1-tie (r1) → #5 (r2) → #3 (r3)** — it only "ties" in run-001, and only because that lens is **cost-blind** *and* its scored rigor there is **identical** to OpenSpec's (29/35; planning trio 13/15 each) despite 9× the documentation volume. The moment cost re-enters (any run) or BMAD ships an unwired product (r2), the tie collapses. **No run has BMAD's quality justifying its cost.**

---

## Paired Δ (run-001 → run-002, same methodology)

| Methodology | Aware /55 Δ | Blind /40 Δ | Cost Δ | Read |
|---|:--:|:--:|:--:|---|
| Vibe | 39→40.5 (+1.5) | 34.25→34.5 (≈0) | −10% | sim cycle is a ~10% footnote; tests replace it |
| Plan Mode | 44→44 (0) | 32.5→33.75 (+1.25) | −25% | research overhead was defensive, not load-bearing |
| OpenSpec | 45.5→45.5 (0) | 33.5→34.25 (+0.75) | +11% | spec authoring expands without runtime gravity |
| AI-DLC | 44.5→44 (≈0) | 31.75→34.75 (+3) | **−66%** | ceremony × rule-set re-reads collapse w/o build loop |
| BMAD | 46.5→42.5 (**−4**) | 34.75→34.5 (≈0) | **+80%** | run-002 shipped 3 Major defects; cost ballooned |
| Spec Kit | 34/45→44/55 (inverts) | 22/30→30 (inverts) | **+115%** | 001 refused to build; 002 shipped → real cost |

**The cost-Δ ordering REVERSES between runs** — who's cheap vs expensive is not stable across the brief variant. This is the single sharpest T4-rich finding.

---

## run-003: automated arm (headless, no operator)

Distinct condition: all 6 cells driven headlessly via `claude -p` (no operator in the loop), `brief-no-runtime.md`, PM persona answering clarifying questions via `pm-ask`. **Reported separately** — not summable with the operator-driven 001/002 rows above. Three measurement conditions, same as 001/002: **cost (authoritative)**, code-based pass-1 (PROVISIONAL/unblinded — superseded), and **blind 2-rater (authoritative for quality)**.

| Cell | Blind /40 | Cost | API time | LOC | tsc | tests | PM Qs | Notes |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|---|
| openspec | **34.75** | **$18.12** | 33.5m | 5,690 | clean | 98✓ | 0 | blind leader; cheapest+fastest structured |
| vibe | 34.5 | $27.35 | 56.9m | **9,255** | clean | 137✓ | 0 | control co-leads again (blind) |
| vibe-planmode | 34.25 | $22.01 | 48.0m | 6,027 | clean | 74✓ | 0 | curbed vibe sprawl (6.0K vs 9.3K LOC) |
| bmad | 34.25 | $32.32 | 56.6m | 4,322 | clean | 75✓ | 0* | neutral re-run; 17 planning artifacts; p1/p2 spread 36→32.5 |
| ai-dlc | 32.5 | **$39.94** | 58.7m | 5,424 | **325 env err†** | 111✓ | **7** | depth-first: 3 deep + 3 scaffold programs → Func dock |
| spec-kit | 31.5 | $24.29 | 37.6m | 5,164 | clean | 76✓ | **5** | lowest but in-band; Doc 3 (no README) + chart gap |

**Total cost: $164.03 · ~5.3 h API.** *BMAD asked 0 PM Qs but ran its own analyst elicitation + 7 web searches. †ai-dlc's 325 tsc errors are environmental (incomplete offline install), not logic bugs; lone cell not tsc-green as-shipped. ‡BMAD = neutral re-run via `/bmad-help` router; the voided lean `/bmad-agent-analyst` attempt ($22.38) is audit-trail only.

**Blind band 31.5–34.75 — replicates 001/002 a third time within T4-rich.** The unblinded pass-1 ranked openspec/spec-kit 49 top, vibe 41 bottom (8-pt spread); blind, that **collapses to ~3pt and the order scrambles** (openspec 34.75 → vibe 34.5 → planmode/bmad 34.25 → ai-dlc 32.5 → spec-kit 31.5). **Even the headless automated control's code is blind-indistinguishable from the structured cells.** Cross-cell pattern flagged by all 6 raters: rich tested **domain logic, under-wired UI** (charts computed-not-rendered, RPE persisted-no-entry, auto-populate available-not-wired). Cost order: openspec cheapest, ai-dlc most expensive yet shipped the fewest programs.

*Full detail: `blind-pass-audit-run003.md` (blind, authoritative) · `run-003-codebased-summary.md` (cost + pass-1) · `blind-label-map-run003.md`.*

---

## Headline findings

### 1. Blind, code quality is an indistinguishable cluster — the control co-leads BOTH runs
Run-001 blind band: 31.75–34.75 (vibe 34.25 co-leads). Run-002 blind band: 33.75–34.75 (vibe 34.5 co-leads). **The no-methodology control's code is indistinguishable from every structured cell's, blind, on both briefs.** Replicates T1/T2; does NOT reproduce T3's reversal. Report the band, not a rank.

### 2. The reproducible separation lives in the PLANNING dims + cost, not code
On the aware /55, the structured cells pull ahead of vibe (40.5) — but the gap is almost entirely the planning trio (Spec/Scope/Assumptions), where vibe scores ~1–3/5 and the structured cells score 4–5. The *engineering* sub-dims (Code/SysDes/Sec/Doc) are tight across all cells. **Structure documents intent; it doesn't reliably produce better code.**

### 3. BMAD: the output-vs-artifacts thesis, proven with teeth
- bmad-001: 46.5/55 (top) but $384. bmad-002: 42.5/55 (mid-pack, *below* openspec) at **$689** — the most expensive cell in the eval, 18–34× the cheap structured cells.
- bmad-002 had **perfect planning dims** (Spec/Scope/Assump all 5) and a canon doc that *pre-warned the exact GZCLP/nSuns traps* — **yet shipped 2 of them as Major defects** (GZCLP day-index double-advance kills B-days; 5 native services throw `NotImplementedError`), and **683 passing tests missed both**.
- Blind, bmad-002's code (34.5) ties vibe's $20 code (34.5). **The document tax bought foresight that didn't convert to shipped correctness.** Its value is (B) process-artifacts (excellent, billable) — not (A) better product.

### 4. OpenSpec is the cost-efficiency frontier — 5th task running
Aware-/55 leader on BOTH runs (45.5 / 45.5) at ~$21–23 — beats BMAD's quality on run-002 at 1/30th the cost. Corroborates the T1–T4-vague pattern: OpenSpec delivers top structured quality at the lowest structured cost. (Model-upgrade note: this now holds across the 4.7-era corpus AND the 4.8 T4-rich hexad×2.)

### 5. Spec Kit's brief-sensitivity is a finding, not a defect
Run-001 (runtime brief): self-scoped to domain-only on an *untested* "no sim" assumption (the same machine ran every other cell's full Expo build) → 34/45, FAILs most binary outcomes. Run-002 (no-runtime brief): shipped a full app → 44/55. **Same methodology, opposite shipping behavior, driven entirely by how the brief framed verification.** Kept as honest record (not re-rolled — re-running a disliked score is researcher-degrees-of-freedom, rejected per the rigor-pass precedent).

### 6. No-runtime didn't lower code quality — it redirected effort
Every cell's blind score is within ~1.5pt across runs. The constraint moved unprompted effort from sim-driving into test suites + handoff docs. The sim cycle is cheap; structured artifacts are where the no-runtime budget flowed.

---

## Provenance & caveats
- **Blind:** `blind-pass-audit.md` + `blind-label-map.md`; 24 reviews archived at `sdd-bench-t4rich-builds/blind-reviews/`. bmad-002's first blind score (21.0) was a VOID mid-flight snapshot; 34.5 is the completed-cell re-score.
- **Aware /55:** per-cell `runs/t4-fitness-app-rich/<meth>/run-<run>/observations.md`. PROVISIONAL (single-rater).
- **Runtime:** only vibe-001 (Maestro). All other cells code-based — measurement-condition asymmetry; do not head-to-head vibe-001's runtime number against the code-based scores.
- **Cost:** implied API $ (operator on Pro flat-rate); comparable across cells, not actual billing. bmad-002 cost is the /status headline ($689.47 across 6 windows); token splits not backfilled.
- **3-way bundle confound** (run-001 vs T4-vague): brief quality + scope (~5–10×) + runtime (dev-build vs Expo Go) + model (4.8 vs 4.7). Frame deltas as "realistic product-intent doc vs vague vibe brief," not isolated wording.
- **spec-kit-001** is /45 + /30 (UI/UX n/a, no app) — not directly summable with the /55 + /40 cells.

*See also: `run-002-evaluation.md` (run-002 deep-dive), `blind-pass-audit-run003.md` + `run-003-codebased-summary.md` (run-003 automated arm), `analysis/findings/output-vs-artifacts-axis.md` (the A/B thesis).*
