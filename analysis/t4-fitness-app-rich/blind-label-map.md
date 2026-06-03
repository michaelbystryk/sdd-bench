# T4-rich — Blind Scoring Label Map

**⚠️ SPOILER. Do not read before blind scoring is complete.**

**Seed:** `20260529` · **Generated:** 2026-05-29 · **Scope:** both runs (run-001 runtime + run-002 no-runtime), 12 bundles, A–F per run.

Two independent permutations (run-001 ≠ run-002 mapping, to block cross-run inference).

## run-001 (runtime brief)
| Blind label | Methodology | Source | Bundle |
|---|---|---|---|
| Output A | bmad | strength-app-builds/bmad/compound-app | /tmp/t4-rich-blind/run-001/output-A/ |
| Output B | vibe | strength-app-archive/vibe | /tmp/t4-rich-blind/run-001/output-B/ |
| Output C | spec-kit | strength-app-archive/spec-kit (domain-only, no UI) | /tmp/t4-rich-blind/run-001/output-C/ |
| Output D | openspec | strength-app-archive/openspec/mobile | /tmp/t4-rich-blind/run-001/output-D/ |
| Output E | ai-dlc | strength-app-archive/ai-dlc | /tmp/t4-rich-blind/run-001/output-E/ |
| Output F | vibe-planmode | strength-app-archive/vibe-planmode | /tmp/t4-rich-blind/run-001/output-F/ |

## run-002 (no-runtime brief)
| Blind label | Methodology | Source | Bundle |
|---|---|---|---|
| Output A | openspec | strength-app-openspec-002-builds/openspec-run-002 | /tmp/t4-rich-blind/run-002/output-A/ |
| Output B | ai-dlc | strength-app-aidlc-002-builds/ai-dlc-run-002 | /tmp/t4-rich-blind/run-002/output-B/ |
| Output C | vibe | strength-app-vibe-002-builds/vibe-run-002 | /tmp/t4-rich-blind/run-002/output-C/ |
| Output D | bmad | strength-app-bmad-002-builds/bmad/compound-app | /tmp/t4-rich-blind/run-002/output-D/ |
| Output E | vibe-planmode | strength-app-planmode-002-builds/vibe-planmode-run-002 | /tmp/t4-rich-blind/run-002/output-E/ |
| Output F | spec-kit | strength-app-speckit-002-builds/spec-kit-run-002 | /tmp/t4-rich-blind/run-002/output-F/ |

**Anonymization (2-stage — first pass MISSED leaks, caught by scan before raters read):**
- Stripped tell dirs: openspec/, .specify/, **specs/** (spec-kit's plan.md/checklists/ — missed in pass 1), aidlc-docs/, .aidlc-rule-details/, _bmad-output/, _bmad/, **ux-designs/**, docs/, specstory/, memory/, .claude/; config tells (CLAUDE.md, AGENTS.md); build/dep/vcs noise (node_modules/, ios/, android/, .expo/, .git/, eas.json).
- **Scrubbed in-code requirement-ID tells:** bmad-001 had `FR-N`/`Story N.N`/`Epic N`/`AR-N`/`NFR-X`/`UX-DRN` in comments across 85 files (total de-anonymizer); spec-kit had FR-N in 14. Removed via perl (parenthetical + bare-token strip), descriptive comments preserved.
- **Scrubbed README method-names:** "OpenSpec", "AI-DLC/aidlc-docs", "BMAD", "Spec Kit", "/speckit-*", "quick-dev", ".specify/" → neutral terms.
- **bmad-002 re-staged:** first staged from wrong path (bmad/compound-app → empty); correct app is `bmad-run-002/StrengthApp/` (81 ts files).
- Final scan: **0 methodology tells** across all 12 bundles (code/comments/README/tsconfig). Each bundle = neutral BRIEF.md + code + tests.
- ⚠️ **PROCESS NOTE:** raters were briefly launched on the *un-scrubbed* bundles, then stopped within seconds (TaskStop) before any REVIEW.md was written. No contaminated ratings exist. The clean relaunch is authoritative.

**Method:** blind code-visible dims (Functionality, Code quality, System design, UI, UX, Robustness, Security, Documentation) rated by ≥2 fresh Sonnet raters per bundle (pass-1 REVIEW.md + pass-2 REVIEW-2.md, pass-2 blind to pass-1). Planning dims (Spec/Scope/Assumptions, 10–12) single-rater from un-anonymized artifacts (the methodology tell — cannot be blinded). Labels revealed only after both passes complete.
