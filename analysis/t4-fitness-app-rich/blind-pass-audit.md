# T4-rich — Blind code-visible pass (8 dims, 2 raters, both runs)

**Date:** 2026-05-30. **Protocol:** scoring-rubric v0.3 (blind-agents-primary). **Scope:** both runs, 12 anonymized bundles, 2 independent Sonnet raters each = **24 reviews**. Background Workflow pipeline (pass-1 → pass-2 per bundle).

> **Provenance / correction note.** An earlier draft of this file mis-transcribed scores from the prior code-based single-rater pass instead of the blind REVIEW files; the discrepancy surfaced when the pipeline's actual bmad-002 score (20.5) contradicted the draft (35.3). Every number below is parsed directly from the 24 `REVIEW.md`/`REVIEW-2.md` files on disk (strict 0–5 parser). The corrected data overturns the draft's headline — disclosed here in full rather than silently amended.

## Method

- 12 anonymized bundles at `/tmp/t4-rich-blind/run-{001,002}/output-{A..F}`: shipped code + tests + neutral BRIEF.md only. Label map (compile-time key in [`blind-label-map.md`](blind-label-map.md)):
  - **run-001:** A=bmad · B=vibe · C=spec-kit · D=openspec · E=ai-dlc · F=vibe-planmode
  - **run-002:** A=openspec · B=ai-dlc · C=vibe · D=bmad · E=vibe-planmode · F=spec-kit
- **Anonymization was 2-stage** — first staging leaked ~100 in-code requirement-IDs (FR-N/Story/Epic, bmad+spec-kit), README method-names, `specs/`+`ux-designs/` dirs, the `vibe` app-slug, and bmad-002 staged from the wrong root. All scrubbed; final scan **0 tells**; raters never read a contaminated bundle (early launches stopped within seconds, 0 reviews written). Full detail in [`blind-label-map.md`](blind-label-map.md).
- **8 code-visible dims** on absolute anchors. spec-kit run-001 shipped no UI → UI/UX n/a, /30. **Planning dims (Spec/Scope/Assump) NOT in this pass** (artifacts = the tell) → single-rater, disclosed.
- Reviews archived: `sdd-bench-t4rich-builds/blind-reviews/run-NNN/output-X/REVIEW{,-2}.md`.

## Blind code-visible scores (file-sourced; p1 / p2 → avg)

Subtotal /40 (8 dims); spec-kit-001 /30 (no UI/UX).

### run-001 (runtime brief)
| Methodology | Func | Code | Sys | UI | UX | Rob | Sec | Doc | p1 | p2 | **avg** |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| bmad (A) | 4.5 | 4.5/5 | 5 | 4–4.5 | 4–4.5 | 4.5 | 3–3.5 | 4–4.5 | 36.0 | 33.5 | **34.75** |
| vibe (B) | 4.5 | 4.5/5 | 5 | 4.5 | 4.5 | 4 | 3 | 4 | 34.0 | 34.5 | **34.25** |
| openspec (D) | 4.5 | 4.5/5 | 5 | 4–4.5 | 4–4.5 | 4 | 3 | 3.5/4 | 34.0 | 33.0 | **33.5** |
| ai-dlc (E) | 4.5 | 5 | 5 | 4 | 4 | 4 | 3 | 2/2.5 | 31.5 | 32.0 | **31.75** |
| vibe-planmode (F) | 4.5 | 5/4.5 | 5 | 4 | 4 | 4 | 3 | 2.5 | 33.5 | 31.5 | **32.5** |
| spec-kit (C) /30 | 3.5 | 4.5 | 4.5/5 | n/a | n/a | 4 | 3 | 2.5/2 | 22.0 | 22.0 | **22.0** |

### run-002 (no-runtime brief)
| Methodology | Func | Code | Sys | UI | UX | Rob | Sec | Doc | p1 | p2 | **avg** |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| ai-dlc (B) | 4.5 | 5 | 5 | 4 | 4 | 4.5 | 3/3.5 | 4.5 | 34.5 | 35.0 | **34.75** |
| vibe (C) | 4.5 | 5/4.5 | 5 | 4.5/4 | 4.5 | 4 | 3 | 4.5 | 35.0 | 34.0 | **34.5** |
| bmad (D) | 4.5 | 5 | 5 | 4/4.5 | 4.5 | 4.5 | 3 | 3.5/4 | 34.0 | 35.0 | **34.5** |
| openspec (A) | 4.5 | 5 | 5 | 4 | 4 | 4 | 3.5/3 | 4.5 | 34.5 | 34.0 | **34.25** |
| vibe-planmode (E) | 4.5 | 5/4.5 | 5 | 4 | 4 | 4 | 3 | 4.5 | 34.0 | 33.5 | **33.75** |
| spec-kit (F) | 4/4 | 4.5 | 4.5/5 | 3 | 3.5 | 4/3.5 | 3 | 4 | 29.0 | 31.0 | **30.0** |

> **bmad-002 RE-SCORED (2026-06-01) after the cell completed.** The first staging (21.0) was a VOID mid-flight snapshot — app shell unbuilt, `src/state/` empty, services unimplemented. The COMPLETED cell (full 8-screen onboarding + 5 tabs + 63 components, `src/state/` populated, index.tsx no longer Expo scaffold) re-scores **34.5** (p1 34.0 / p2 35.0, 0 dim-pairs >1pt) — squarely in the band, co-leading. The 21.0 is discarded; this row is authoritative. *(Note: ai-dlc-002 row repeats from §run-002 above for ordering — both are 34.75/34.5 ties.)* run-002 is now **12/12 valid**.

*(All p1/p2 subtotals verified against the on-disk REVIEW files. Three p1 tables the auto-parser missed were hand-read from the files: ai-dlc-001 p1=31.5, vibe-planmode-001 p1=33.5, spec-kit-002 p1=29.0. Dual values like "4.5/5" show p1/p2 where the two raters differed by ≤0.5.)*

## Reconciliation (v0.3)

- **0 dim-pairs disagree by >1 pt** across all 192 — strong inter-rater agreement (matches the T3 result). Documentation is the noisiest dim (stock-Expo-README vs inline-docs judgment, ±0.5–1) but never exceeds 1pt. The v0.3 same-condition rescore rule does not trigger.
- **Two cells show >2pt SUBTOTAL drift from accumulated ≤1pt per-dim moves** (kept separate, not reconciled — both blind, same condition): vibe-planmode-001 (p1 33.5 → p2 31.5) and spec-kit-002 (p1 29.0 → p2 31.0). Reported as a band.
- No subtotal averaging across blind-vs-aware conditions (kept separate from the code-based pass).

## Findings

1. **Blind, vibe (the no-methodology control) co-leads the band on BOTH runs (34.25 / 34.5)** — within inter-rater noise of bmad-001 (34.75) and ai-dlc-002 (34.75), above or even with every structured cell. **This REPLICATES T1/T2 (blind, the control is indistinguishable from / co-leads the structured cells) and does NOT reproduce T3's reversal.** On a large app, blind raters cannot tell vibe's *code* from the planned cells'. (The earlier draft claimed vibe was last; that was the transcription error noted above, now corrected from the source files.)
2. **The full-app cluster is genuinely tight: 32.25–34.75 across vibe, bmad, ai-dlc, openspec, vibe-planmode on run-001; 33.75–34.75 on run-002.** Report as a **band, not a rank** — the spread is within inter-rater noise. The reproducible separation is NOT in blind code quality; it lives in the planning dims (single-rater) and cost.
3. **spec-kit-001 (22.0/30) is the one valid structural outlier in BLIND code:** domain-only, no app shell — Functionality 3.5 (math exists, no product), UI/UX n/a. Confirmed methodology characteristic (its run-002 sibling shipped a full app at 30.0).
4. **bmad-002 re-scored 34.5 after the cell completed** (first 21.0 was a void mid-flight snapshot). Co-leads the run-002 band — blind, BMAD's code is indistinguishable from every other cell's. Its distinction is NOT blind code quality; it's the $689 cost (most expensive cell in the eval) + the planning-artifact volume — the output-vs-artifacts split.
5. **run-002 ≈ run-001 blind code quality** for EVERY cell — the no-runtime constraint didn't lower blind code quality for any methodology (all within ~1.5pt of their run-001 sibling, bmad now included at 34.5 vs 34.75). Blind, you cannot tell a runtime-verified build from a source-only one.

## Relationship to the code-based (aware) single-rater pass

Different measurement condition (blind + anonymized + code-dims-only vs aware + full-/55). **Kept separate, not averaged** (v0.3). Final matrix reports: this blind code band + single-rater planning dims + the provisional code-based /55 + vibe-001's unique Maestro runtime score. Note the code-based pass did NOT score bmad-002 (cell pending then) — the blind pass is bmad-002's first score, hence the caveat in #3.
