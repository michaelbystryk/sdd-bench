# T1-postal-validator — Cross-cell scoring matrix

> **TL;DR.** All six clear the floor — 46/46 tests, stdlib-only, 0 critical/0 major, 3/3 binary. Quality /40: **Spec Kit 36 > AI-DLC 35 > OpenSpec 32.5 > BMAD 31 > Plan Mode 26.5 > Vibe 21** — but the spread is *entirely planning rigor* (the 5 code-visible dims are indistinguishable under blind re-rate, control at the top). Cost 7.7× ($0.59→$4.57). Persona lenses **split: Vibe wins indie (cost), Spec Kit wins enterprise (rigor).** OpenSpec the all-rounder; BMAD self-routed to quick-dev. *Provisional, single-rater on the planning dims.*

Single source of truth for T1 cell scores (postal-code validator + CLI; greenfield floor, low/low). One row per dimension/metric, one column per methodology. Each cell owns its `runs/.../observations.md`; this is the cross-cell snapshot.

**Status (2026-05-27):** ✅ **HEXAD COMPLETE — all 6 methodologies scored** (Vibe, Vibe Plan Mode, OpenSpec, Spec Kit, AI-DLC, BMAD). Scored independently per-cell in isolated sessions (no cross-cell anchoring), then compiled here. Rubric: [`harness/scoring-rubric.md`](../../harness/scoring-rubric.md) v0.2; T1 overlay: [`tasks/t1-postal-validator/success-criteria.md`](../../tasks/t1-postal-validator/success-criteria.md).

> **Provisional, two-rater.** The 5 code-visible dims (1/3/4/7/9) carry an independent **blind** second rating ([`blind-pass-audit.md`](blind-pass-audit.md)); the 3 planning dims (10/11/12) are single-rater by necessity (artifacts = the methodology tell). The two ratings are **kept separate and NOT reconciled** (no post-hoc adjustment — T4 tie-audit precedent). Per the inter-rater result, **the code-visible dims are reported as an indistinguishable cluster, not point scores** (see § Second rater).

T1 applies **8 scored dimensions** (UI 5, UX 6, Security 8 are `n/a` for a local CLI over a pure validator); Correctness scored separately as defects. Max numeric = **/40**.

---

## Quality axis — 8 dimensions × 6 methodologies

Bold = highest in row (ties bolded together).

| # | Dimension | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|:--:|:--:|:--:|:--:|:--:|:--:|
| 1 | Functionality | 4 | 4.5 | 4.5 | **5** | 4.5 | 4.5 |
| 3 | Code quality | 4.5 | 4.5 | 4.5 | **5** | 4.5 | **5** |
| 4 | System design | 4 | 4 | **4.5** | **4.5** | 4 | **4.5** |
| 7 | Robustness | 4 | 4 | 4 | **4.5** | **4.5** | 4 |
| 9 | Documentation | 3.5 | 3 | 3.5 | **4.5** | **4.5** | 3 |
| 10 | Spec articulation | 0 | 3.5 | 4.5 | **5** | 4.5 | 4 |
| 11 | Scope clarity | 1 | 2 | 4 | 4 | **4.5** | 3.5 |
| 12 | Assumption surfacing | 0 | 1 | 3 | 3.5 | **4** | 2.5 |
| | **Quality sum / 40** | **21** | **26.5** | **32.5** | **36** | **35** | **31** |

**Rank by quality:** Spec Kit 36 > AI-DLC 35 > OpenSpec 32.5 > BMAD 31 > Plan Mode 26.5 > Vibe 21. **No tie** (contrast T4's 4-way 49.5) — the CLI broadening gave the quality axis room to separate, as intended.

### Quality as a vector — Usability vs Rigor

Split the 8 dims into **CLI usability** (Functionality + Robustness + Documentation, /15 — the user-facing surface) and **Engineering rigor** (Code + System + Spec articulation + Scope + Assumptions, /25):

| Sub-axis | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **CLI usability /15** | 11.5 | 11.5 | 12.0 | **14.0** | 13.5 | 11.5 |
| **Engineering rigor /25** | 9.5 | 15.0 | 20.5 | **22.0** | 21.5 | 19.5 |

**This is the T1 headline in one table.** Usability is *tight* (11.5–14) — everyone builds a decent, correct CLI for a trivial spec. Rigor spreads **2.3×** (9.5–22). Almost the entire quality gap is the planning/articulation cluster (Spec + Scope + Assumptions): Vibe scores **1/15** there, the structured cells 10.5–14/15. **Ceremony on a trivial task buys planning-artifact rigor, not a better or more functional CLI.**

### Second rater (blind, code-only) — inter-rater reliability

The 5 code-visible dims carry an independent **blind** rating (6 anonymized code-only bundles, fresh reviewers — [`blind-pass-audit.md`](blind-pass-audit.md)). Code-visible 5-dim subtotal (Functionality + Code + System + Robustness + Documentation, /25):

| /25 | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| First-pass (methodology-aware) | 20 | 20 | 21 | 23.5 | 22 | 21 |
| Blind (code-only, 2nd rater) | **23** | 21 | 21 | 21 | **23** | 22 |

**Reading — this is the scientifically load-bearing part.** Both raters land the code dims in a tight **20–23.5 band**; blind compresses it to **21–23 with the control (Vibe) at the top.** The first-pass spread is **within inter-rater noise → on the 5 code-visible dimensions the six methodologies are statistically indistinguishable.** The disagreements are not error to "fix" — they *localize* the bias: Vibe under-credited when labeled "control," Spec Kit's Documentation inflated by planning artifacts the dimension shouldn't count (only AI-DLC shipped a README). **Treat the code axis as a cluster, not point scores.** The real, reproducible separation is the 3 planning dims (single-rater by necessity), where Vibe = 1/15 and the structured cells 10.5–14/15. Neither rating is overwritten or merged — both stand as separate measurements.

### Final composite — persona lenses (headline + vector)

Per the locked scoring architecture (same as T4): persona-weighted quality (0–100) = wU·Usability% + wR·Rigor% (T1's Usability sub-axis replaces T4's Product-polish); cost enters as an efficiency ratio (÷$) for the cost-sensitive lens. Two primary lenses:
- **Indie-dev** (ships it, pays the bill): **0.70 Usability / 0.30 Rigor**; rank by **Q/$**.
- **Enterprise** (maintains for years, cost ≈ rounding error): **0.40 Usability / 0.60 Rigor**; rank by **weighted quality**; no cost bar.

| Cell | Indie WQ | **Indie eff. (Q/$)** | Enterprise WQ | **Ent. rank** | Vector (U% · R% · $) |
|---|:--:|:--:|:--:|:--:|---|
| **Spec Kit** | 91.7 | 21.8 · #4 | **90.1** | **#1** | 93.3 · 88 · $4.20 |
| AI-DLC | 88.8 | 19.4 · #5 | 87.6 | #2 | 90.0 · 86 · $4.57 |
| **OpenSpec** | 80.6 | 61.1 · #3 | 81.2 | #3 | 80.0 · 82 · $1.32 |
| BMAD | 77.1 | 19.3 · #6 | 77.5 | #4 | 76.7 · 78 · $4.00 |
| Plan Mode | 71.7 | 67.0 · #2 | 66.7 | #5 | 76.7 · 60 · $1.07 |
| **Vibe** | 65.1 | **110.3 · #1** | 53.5 | #6 | 76.7 · 38 · $0.59 |

**The lenses SPLIT on T1** — unlike T4, where OpenSpec won both.
- **Indie (cost-weighted) → Vibe wins outright** (Q/$ 110): a correct, stdlib-only CLI for $0.59. Crucially, **unlike T4's consumer app there is no high usability bar to stop it** — a working CLI with `--help` and specific errors *is* shippable, and all six clear that low threshold. So on the floor the cheapest correct build genuinely wins the cost-sensitive lens.
- **Enterprise (rigor-weighted, cost-blind) → Spec Kit wins** (top rigor 88%), AI-DLC a close #2.
- **OpenSpec is the all-rounder again** — #3 on *both* lenses, best cost×rigor blend ($1.32, rigor 82%). If you want one pick across buyers, it's OpenSpec (mirrors its T4 result).
- **BMAD** is the weakest blend — quick-dev's thinner rigor (78%) at $4.00 → worst Q/$ of the field and 4th on enterprise.

> **Caveat (blind pass — load-bearing):** Usability% is a *statistically indistinguishable cluster* (76.7–93.3, within inter-rater noise — see § Second rater), so treat the Usability component as ≈equal across cells. **The lens separation is driven by Rigor + Cost, not usability.** No hard usability bar is applied (T4 used an ~80/100 product bar for a consumer app; a CLI's "shippable" threshold is far lower and all six clear it). Composites are provisional, same as the underlying scores.

### Defect counts (correctness, scored separately)

| Severity × Source | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Critical | 0 | 0 | 0 | 0 | 0 | 0 |
| Major | 0 | 0 | 0 | 0 | 0 | 0 |
| Minor | 3 | 3 | 3 | 3 | 3 | 2 |

Uniformly clean — **0 critical / 0 major across all six.** The recurring minors are nearly identical regardless of methodology: (a) empty/whitespace-only stdin exits 0 silently (5 of 6); (b) `BrokenPipeError` on a large batch piped to a closing reader (4 of 6). Defect density is noisy at ~200–300 implementation LOC; not bolded.

### Binary outcomes (per [`success-criteria.md`](../../tasks/t1-postal-validator/success-criteria.md))

| Binary outcome | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Core tests (test_core.py) | 38/38 | 38/38 | 38/38 | 38/38 | 38/38 | 38/38 |
| CLI tests (test_cli.py) | 8/8 | 8/8 | 8/8 | 8/8 | 8/8 | 8/8 |
| Stdlib only | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Pass count** | **3/3** | **3/3** | **3/3** | **3/3** | **3/3** | **3/3** |

**46/46 tests pass, stdlib-only, for all six.** The binary axis does not discriminate at the floor — exactly the T1 design. (AI-DLC added 10 of its own property-based tests on top → 56 passing.)

---

## Cost axis

| Metric | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Implied cost** | **$0.59** | $1.07 | $1.32 | $4.20 | **$4.57** | $4.00 |
| API compute time | 2m24s | 3m57s | 4m25s | 13m56s | 12m52s | 13m48s |
| Total tokens | 372.9K | 850.9K | 1.07M | 3.69M | 4.59M | 2.74M |
| Code changes (/status) | 220 | 298 | 486 | 971/−169 | 1269/−27 | 394/−24 |
| Routing / depth | none (1 pass) | 1 plan | full propose→apply | full pipeline | full (self-pruned 5 stages) | **quick-dev (self-routed)** |

### Derived ratios

| Ratio | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Quality / $** | **35.6** | 24.8 | 24.6 | 8.6 | 7.7 | 7.75 |
| Cost per binary (÷3) | $0.20 | $0.36 | $0.44 | $1.40 | $1.52 | $1.33 |

**Cost spread 7.7×** ($0.59 → $4.57). Quality/$ tiers cleanly: **Vibe (35.6) >> Plan Mode (24.8) ≈ OpenSpec (24.6) >> Spec Kit (8.6) ≈ BMAD (7.75) ≈ AI-DLC (7.7).** The lightweight structured pair (Plan Mode, OpenSpec) get most of the rigor gain at <$1.40; the heavy three cost 3–4× for the top ~4 quality points.

---

## Headline finding per cell

| Cell | Quality | Cost | API time | Binary | One-line verdict |
|---|:--:|:--:|:--:|:--:|---|
| **Vibe** | 21/40 | $0.59 | 2m24s | 3/3 | Correct, idiomatic, dirt-cheap; near-zero on planning dims (spec 0/scope 1/assum 0). Quality/$ champion and **wins the indie lens** — no usability bar to stop it on the floor. |
| **Plan Mode** | 26.5/40 | $1.07 | 3m57s | 3/3 | One right-sized plan → +5.5 over Vibe (mostly spec articulation 0→3.5) for +$0.48. Highest-ROI single step. |
| **OpenSpec** | 32.5/40 | $1.32 | 4m25s | 3/3 | Full propose→apply; genuine design.md, EARS specs restate the brief. **All-rounder + cost-efficiency frontier** (#3 on both lenses; within 3.5 of Spec Kit at <⅓ cost) — corroborates its T4 result. |
| **Spec Kit** | 36/40 | $4.20 | 13m56s | 3/3 | **T1 quality leader + enterprise-lens winner**; the ceremony-tax exemplar (~10 artifacts, ~70% planning, same green bar a vibe run reaches). |
| **AI-DLC** | 35/40 | $4.57 | 12m52s | 3/3 (+10 PBT) | Full lifecycle self-pruned; top rigor + only cell with property-based tests **and a shipped README** — but the **weakest error messages** (names country, not rule) and priciest. Enterprise #2. |
| **BMAD** | 31/40 | $4.00 | 13m48s | 3/3 | **Self-routed to quick-dev** (neutral kickoff) — right-sized vs its $75.85 T4 blowout. But quick-dev's thin docs/assumptions (Doc 3, Assum 2.5) score *below* OpenSpec at 3× the cost — weakest blend. |

---

## Cross-cell findings (HEXAD COMPLETE — all 6 scored on T1)

1. **Every methodology clears the floor; the binary axis doesn't discriminate.** All six ship a correct, stdlib-only validator + CLI — 46/46 tests, 0 critical/0 major defects, 3/3 binary. By design for the greenfield floor.

2. **The quality spread (21→36) is *entirely* planning rigor, not the program.** Split the dims: **CLI usability is tight (11.5–14/15)** — methodology barely affects whether you get a good, robust, documented CLI; **engineering rigor spreads 2.3× (9.5–22/25)**, almost all of it in spec articulation + scope + assumptions. **Ceremony on a trivial task buys documentation of intent, not a better program.**

3. **The persona lenses SPLIT — unlike T4 (where OpenSpec won both).** Indie (cost-weighted) → **Vibe wins outright** (Q/$ 110); on the floor a correct CLI with `--help` is shippable, so there's no usability bar to stop the cheapest build. Enterprise (rigor-weighted) → **Spec Kit wins** (top rigor), AI-DLC #2. The cost-sensitive and rigor-maximalist buyers want opposite cells.

4. **OpenSpec is the cost-efficiency frontier + all-rounder again** — #3 on both lenses, best cost×rigor blend ($1.32, rigor 82%); within 3.5 quality of Spec Kit at <⅓ the cost. Corroborates its T4 result on a different task type.

5. **Adaptive routing, opposite instincts.** Given a neutral kickoff, **BMAD self-routed to quick-dev** (right-sizing its $75.85 T4 machinery to $4.00) while **AI-DLC ran its full lifecycle** ($4.57) on the very same trivial task. Yet BMAD's quick-dev scored *below* OpenSpec's lightweight flow at 3× the cost — it right-sized the cost without matching the rigor.

6. **Blind second-rater cross-check confirms the convergence.** An independent code-only re-rate of the 5 code-visible dims compresses the six to a **21–23/25 cluster with the no-methodology control (Vibe) at the top** — methodology-blind, the control's code is indistinguishable from the structured cells'. The code-axis point spread is within inter-rater noise; the reproducible separation is the planning dims (single-rater). It also caught real first-pass bias: Vibe under-credited as "the control," Spec Kit's Documentation inflated by planning artifacts the dimension shouldn't count.

7. **Feature convergence (see [`feature-matrix.md`](feature-matrix.md)):** the shipped CLI is near-identical across all six (same contract, same idioms, same two unpinned gaps — empty-stdin + BrokenPipe — missed by all). Only AI-DLC shipped extras (README + property-based tests). Error-message quality does NOT track ceremony — the heaviest planner (AI-DLC) has the weakest messages.

**Bottom line:** T1 validates the apparatus and sharpens the T4 ceremony-tax finding — on simple, fully-specified work the code converges, the control is competitive, and only the paperwork (and the bill) separate the methodologies.

---

## How to extend this matrix

Per-cell scoring → this matrix is a post-scoring compile step (see operator-runbook § Scoring). Each cell's `observations.md` is the source; re-bold rows where a newly-scored cell ties/beats the prior best; keep defect/binary/cost rows in sync; update the headline if a cell changes the story.

*v0.1 — HEXAD COMPLETE (all 6 on T1). Scored independently per-cell (isolated sessions), compiled 2026-05-27.*
