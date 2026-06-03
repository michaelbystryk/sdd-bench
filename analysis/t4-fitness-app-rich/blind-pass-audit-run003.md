# T4-rich run-003 (AUTOMATED ARM) — Blind code-visible pass (8 dims, 2 raters)

**Date:** 2026-06-01. **Protocol:** scoring-rubric v0.3 (blind-agents-primary). **Scope:** run-003 automated-arm (headless `claude -p`, no operator; no-runtime brief), 6 anonymized bundles, 2 Sonnet raters each = 12 reviews. Workflow `wqcypqy6g`. Brings run-003 to the same standard as run-001/002 (its prior pass-1 was unblinded/single-rater PROVISIONAL — see `run-003-codebased-summary.md`).

Label map: [`blind-label-map-run003.md`](blind-label-map-run003.md) (A=spec-kit B=bmad C=vibe D=ai-dlc E=openspec F=vibe-planmode). **Bundles verified 0 tells BEFORE raters launched** (lesson applied from run-002).

## Blind code-visible /40 (p1 / p2 → avg)

| Methodology | Func | Code | Sys | UI | UX | Rob | Sec | Doc | p1 | p2 | **avg** |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| openspec (E) | 4.5 | 5 | 5 | 4 | 4 | 4 | 3 | 5 | 35.0 | 34.5 | **34.75** |
| vibe (C) | 4.5 | 5 | 5 | 4.5 | 4.5 | 4 | 3.5/3 | 4.5 | 33.5 | 35.5 | **34.5** |
| vibe-planmode (F) | 4.5 | 5 | 5 | 4 | 4 | 4.5 | 3 | 4.5 | 34.0 | 34.5 | **34.25** |
| bmad (B) | 4.5 | 4.5 | 5 | 4 | 4 | 4 | 3 | 3.5 | 36.0 | 32.5 | **34.25** |
| ai-dlc (D) | 4 | 4.5 | 5 | 4 | 4 | 4 | 3 | 4 | 32.5 | 32.5 | **32.5** |
| spec-kit (A) | 4.5 | 4.5 | 5 | 4 | 4 | 4 | 3 | 3 | 31.0 | 32.0 | **31.5** |

*(p1 subtotals for bmad/vibe/openspec hand-read from REVIEW.md — auto-parser missed their table format; p2 from workflow JSON. Dual values = p1/p2 differ ≤0.5.)*

## Reconciliation (v0.3)
- **bmad (B) p1 36.0 → p2 32.5 = 3.5pt subtotal drift** — the largest in the pass. Driven by accumulated ≤1pt per-dim moves (no single dim >1pt). Kept separate, not reconciled (both blind, same condition); reported as the 34.25 midpoint with the spread disclosed.
- All other cells: p1/p2 within ~2pt, per-dim within 1pt. No same-condition rescore triggered.

## Findings

1. **Blind, the band is 31.5–34.75 — same tight cluster as run-001/002, and the spread is NOT the pass-1 ranking.** The unblinded pass-1 (`run-003-codebased-summary.md`) had openspec 49 / spec-kit 49 ranked top and vibe 41 bottom, a 8-pt spread. **Blind, that collapses to a ~3pt band and the order scrambles** — openspec 34.75, vibe 34.5, planmode/bmad 34.25, ai-dlc 32.5, spec-kit 31.5. Exactly as the summary predicted: pass-1's spread was mostly the planning trio (Spec/Scope/Assump) that the blind pass excludes. **Confirms the eval-wide pattern a third time within T4-rich: blind code is a band, not a rank.**
2. **vibe (control) co-leads again (34.5)** — 2nd in the blind band, indistinguishable from openspec/planmode/bmad. Even the headless automated control's code is blind-indistinguishable from the structured cells. Replicates run-001 (34.25) + run-002 (34.5).
3. **spec-kit lowest (31.5) but still in-band** — its blind weak spots are Documentation (3, no README) and a UI-feature gap (Progress charts as plain text), not core code quality (Code 4.5, Sys 5).
4. **ai-dlc 32.5** — docked on Functionality (4): 3 of 7 programs (Madcow/nSuns/PPL) shipped as non-runnable scaffolds (43% of the library), + the rest-timer "+30s" wired to tick not extend. Its deep-3-scaffold-3 strategy shows up as a real blind functionality hit.
5. **Recurring cross-cell pattern (all 6 noted by raters): domain > UI wiring gap.** Every cell has rich tested domain logic with UI features the domain supports but doesn't surface — charts computed-but-not-rendered (spec-kit, planmode, ai-dlc), RPE persisted-but-no-entry (spec-kit, ai-dlc), auto-populate available-but-not-wired (openspec), plate inventory read-only (planmode), PR detection broken at the wiring layer (bmad: empty priorBests → false PRs every session). The headless automated arm consistently nailed the domain and under-wired the UI.

## Status vs other runs
Run-003 blind now matches run-001/002 rigor. Three measurement conditions exist for run-003: cost (authoritative), code-based pass-1 (PROVISIONAL, unblinded — superseded by this), and **blind 2-rater (this — authoritative for quality)**. Reviews archived to `sdd-bench-t4rich-builds/blind-reviews/run-003/`.
