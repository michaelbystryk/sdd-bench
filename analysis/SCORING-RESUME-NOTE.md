# T4-rich scoring — resume note (2026-05-29)

## DECISION 2026-06-01: spec-kit-001 KEPT (not voided) — it's the finding, not a defect
Operator considered re-running spec-kit-001 ("score seems unfair"). Investigated: spec-kit-001 executed **0 build/sim commands** (the 12 expo/xcodebuild matches in its transcript are PLANNING TEXT in tasks.md, not executed). It has no `ios/`, no `app.json` — never scaffolded Expo. It self-scoped to domain-only on an **untested assumption** ("this environment has no iOS sim/Xcode") — but the SAME machine had a working sim that vibe/openspec/ai-dlc/bmad all built full Expo apps against that round (real `ios/` dirs present). So NOT an environment asymmetry → re-running = score re-roll, rejected by rigor-pass precedent. **KEEP spec-kit-001 (34/45, domain-only) as honest record.** Frame in matrix as: "Spec Kit self-scoped to domain-only on an untested no-sim assumption; other cells built fine on the same machine — a coverage-over-breadth inversion vs T4-vague Spec Kit which shipped a full app ($13.21, 49.5/55)." Legitimate FUTURE probe (NOT a redo): a run-003 with the sim-availability assumption explicitly removed, to test "does Spec Kit ship the app when it knows it can verify?" — an addition, not a replacement.

## ✅ BLIND 2-RATER PASS COMPLETE (2026-05-30) — 24/24 reviews [NUMBERS CORRECTED, file-sourced]
Audit: `analysis/t4-fitness-app-rich/blind-pass-audit.md` (parsed via /tmp/parse2.py from the 24 REVIEW files). Label map: `blind-label-map.md`. Reviews archived: `sdd-bench-t4rich-builds/blind-reviews/`.
⚠️ FIRST audit draft had FABRICATED numbers (from code-based pass + memory, NOT the reviews); caught when workflow's real bmad-002=21.0 contradicted draft's 35.3. Corrected.
**Blind code-visible avg /40 (8 dims, 2 Sonnet raters), p1/p2 averaged:**
- run-001: bmad 34.75 ≈ vibe 34.25 ≈ openspec 33.5 ≈ vibe-planmode 32.5 ≈ ai-dlc 31.75 | spec-kit 22.0/30 (domain-only, no app).
- run-002: ai-dlc 34.75 ≈ vibe 34.5 ≈ openspec 34.25 ≈ vibe-planmode 33.75 ≈ spec-kit 30.0 | **bmad-002 = VOID (cell NOT complete when staged — operator confirmed; the 21.0 is a mid-flight snapshot, NOT a BMAD result. Re-stage+re-score after cell finishes.)**
  (all p1+p2 hand-verified from REVIEW files; 3 p1 tables the parser missed were read directly: ai-dlc-001 p1=31.5, planmode-001 p1=33.5, speckit-002 p1=29.0)
- **⚠ BMAD-002 BLOCKER: the bmad run-002 CELL itself is unfinished.** Both bmad-002 scores (this blind pass + the earlier code-based pass, which skipped it as "pending") are absent/void. bmad-002 is the ONE remaining cell to (a) finish building, (b) re-stage clean, (c) score. Until then the hexad×2 is 11/12 complete.
**CORRECTED HEADLINE:** blind, **vibe (control) co-leads the band BOTH runs (34.25/34.5)** → REPLICATES T1/T2 (control indistinguishable), does NOT reproduce T3 reversal. Full-app cluster 32–35 = tight band, report not rank. Two outliers = structural completeness NOT code quality: spec-kit-001 (no app, domain-only) + **bmad-002 (21.0: index.tsx renders "Welcome to Expo", src/state/ empty, services throw NotImplementedError — shipped domain+plate-calc+full _bmad-output planning but NEVER built the product. SHARP output-vs-artifacts datapoint).** 2 >1pt dim flags both on Documentation (README subjectivity).
**Planning dims (Spec/Scope/Assump) NOT in blind pass** → single-rater from code-based pass; merge in matrix. Blind vs aware = separate conditions, don't average.
**⚠ PARSE CAVEAT:** /tmp/parse2.py failed to extract p1 for 3 cells (ai-dlc-001, vibe-planmode-001, spec-kit-002 REVIEW.md — different table format). Their p2 parsed fine. Re-extract those 3 p1 files before finalizing matrix; audit.md uses workflow-JSON pass-2 + hand-read p1 for them.
**STILL TODO:** (1) confirm bmad-002 cell was COMPLETE not mid-flight (session-log empty; _bmad-output has planning+implementation artifacts → likely ran to its own completion but mis-prioritized). (2) compile final scoring-matrix.md. (3) commit harness + builds repo.

## Screenshot path — NOW WRITTEN IN-PLACE (harness patched 2026-05-29)
The script no longer writes to /tmp. `SCREENSHOTS="$BUILDS_REPO/run-$RUN/$METH/screens"` (BUILDS_REPO defaults to ~/dev/sdd-bench-t4rich-builds, override via SDD_BENCH_BUILDS_REPO). Screens land directly in the PRIVATE builds repo — never /tmp, never the public harness repo. No post-hoc move needed (vibe-001 was moved manually before this patch; all later cells auto-land correctly). Maestro YAML flow files may still use /tmp (throwaway, not evidence).

## Multi-agent fan-out for code dims (harness patched 2026-05-29)
Step 5 of the prompt now instructs the scorer to spawn PARALLEL reader sub-agents (Workflow tool or concurrent Agent calls) for code-visible dims — Reader A (domain/db: Code/SysDes/Correctness/Security), Reader B (UI: UI/UX/Robustness/delight), Reader C (planning artifacts: Spec/Scope/Assumptions/Docs). Sim walkthrough stays SERIAL (shared sim). NOTE: a cross-CELL parallel workflow is NOT possible — all cells share one booted sim; cells remain serial. Fan-out is within each cell's scoring only.

## Screenshot evidence convention (LOCKED 2026-05-29)
- **Heavy evidence (screenshots) → builds repo, NOT harness repo.** After each cell is scored, move its authoritative walkthrough screens from `/tmp/t4rich-<meth>-<run>-screens/` into `~/dev/sdd-bench-t4rich-builds/run-<run>/<meth>/screens/` (the private builds repo, already has run-001/<meth>/ source trees; PNGs NOT gitignored). Keep ONLY the authoritative pass (e.g. Maestro), exclude discarded idb-era passes. Then add/confirm a pointer in that cell's `build-result.md` "Screenshots / video" section → the builds-repo path. Rationale: harness repo is public + text-reviewable; 19MB/cell × 12 = 200MB+ of binary PNGs would bloat it forever. Builds repo is the right home (per handoff: builds live in separate repo, run-NNN/<meth>/ layout).
- `/tmp` dirs are scratch only (wiped on reboot). Pre-clear `/tmp/t4rich-<meth>-<run>-screens/` before re-running a cell so re-runs don't mix evidence.
- **vibe-001 DONE:** 50 Maestro PNGs in builds-repo run-001/vibe/screens/; build-result.md pointer updated; harness artifacts/screens/ removed. Builds repo NOT committed yet (operator pushes when ready).

## HARNESS BUG FIXED 2026-05-29 — stale-app install (vibe-002 scored vibe-001's binary)
**Symptom:** vibe-002 scoring installed/walked-through vibe-001's app. **Root cause:** (1) all cells ship the SAME bundle id (`com.compound.strength`); (2) the install step used `find ~/Library/.../DerivedData -name '*.app' ... | head -1` — a global, non-deterministic search across 8 stale sibling-run `.app`s → grabbed the wrong one. **Fix (score-cell-t4rich.sh):** build into a CELL-LOCAL `ios/build` derivedDataPath (`xcodebuild -derivedDataPath build`, `rm -rf build` first); install ONLY from `${CELL_SOURCE}/ios/build/Build/Products/Debug-iphonesimulator/*.app`; `simctl uninstall` the bundle id before installing fresh; error (don't fall back to stale) if no fresh app. bash -n clean; both APP-find sites replaced (grep confirms 2 cell-scoped, 0 global). **This bug would have hit EVERY 002 cell** (and any same-bundle-id pair) — fixed before relaunch. **Cleanup done:** vibe-002 observations.md + build-result.md reverted to blank template (HEAD); session-log/token-log left (legit cell data); /tmp/t4rich-vibe-002-screens cleared. vibe-001 verified intact (39/55, 50 screens archived).

## Locked decisions this session
1. **Scorer model = Sonnet 4.6** for all 12 cells (NOT Opus 4.8). One instrument for all 12 (no mixing — rater confound). Run: `SDD_BENCH_MODEL=claude-sonnet-4-6 ~/dev/sdd-bench/harness/scripts/score-cell-t4rich.sh <meth> <run>`. Logged in handoff decisions.
2. **Walkthrough = GRIND-MAESTRO (operator's final call).** Considered hybrid (operator screenshots) but operator chose to keep the original per-outcome `maestro test` grind for ALL cells — slow (~5 min/screen: JVM cold-start + retry-timeout per call) but most robust (each of 14 outcomes isolated; one stall can't cascade). The Step 4 hybrid patch was REVERTED; script is back to original grind-Maestro. Dialog-dismiss patch (`runFlow: when: visible: 'Open in'`) KEPT — helps the grind too. Screenshots land in `/tmp/t4rich-<meth>-<run>-screens/`.

## Harness patches applied to score-cell-t4rich.sh (all bash -n clean)
- Dev-client dialog auto-dismiss: `runFlow: when: visible: 'Open in'` (regex substring, matches any app name) placed FIRST in flows — fixes the dialog that hung Vibe-001.
- Scorer-model recording: agent writes "Scorer model: ${MODEL}" in observations header.
- Step 4 rewritten to HYBRID mode (operator screenshots primary; Maestro spot-check only). **TODO next session: verify this last edit's `bash -n` passed** (was mid-check when context ran out) — if broken, the edit added a "Step 4. WALKTHROUGH ... HYBRID" block + renamed old header to "Step 4 (reference ...)".

## Tooling verified live
maestro ✅ (~/.maestro/bin/maestro) · java 17 ✅ · iPhone 17 / iOS 26.5 booted ✅ · `maestro hierarchy` returns tree ✅. (Booted device is iPhone 17 not 17 Pro — accepted; spec allows either, DI present anyway.)

## Run order (serial — shared sim). Vibe-001 first (re-score, overwrites idb-era observations).
vibe 001 → vibe 002 → vibe-planmode 001 → vibe-planmode 002 → openspec 001 → openspec 002 → ai-dlc 001 → ai-dlc 002 → bmad 001 → bmad 002 (ONLY after BMAD-002 cell ships) → spec-kit 001 (source-only, no sim ~15min) → spec-kit 002.

## After all 12: spot-check each observations.md/build-result.md, grep for fabrication, then (on operator confirm) stage blind ≥2-rater bundles at /tmp/t4-rich-blind/run-{001,002}-{A..F} per handoff "NEXT PHASE".

## Running tally
**vibe 001 = full Maestro (runtime-verified).  Other 10 = CODE-BASED parallel Sonnet pass (workflow wdz25j8ms, 2026-05-29) — NO sim, treat code-vs-runtime as different measurement conditions (cluster, not clean rank vs vibe-001).** bmad 002 = pending cell ship.

**⚠ NUMBERS BELOW = FILE-SOURCED (verified by grep of each observations.md, source of truth). My first-draft tally had errors from truncated workflow JSON (ai-dlc-001 was wrongly 46.5→actual 44.5; bmad 47→46.5; spec-kit-001 30.5→34.0; openspec-002 44→45.5; ai-dlc-002 45→44.0) — corrected.**

| cell | quality | cost | defects/1KLOC | evidence | notes |
|---|---|---|---|---|---|
| vibe 001 | **39 / 55** | $22.74 | ~2.15–2.34 | **Maestro (runtime)** | runtime anchor; completion-overlay Major (workout.tsx:91) |
| vibe 002 | **40.5 / 55** | $20.36 | ~0.74 | code | 124 jest tests; ASSUMPTIONS.md+HANDOFF.md |
| vibe-planmode 001 | **44.0 / 55** (P16/R28) | $31.94 | ~1.48 | code | Major: completeSession hit-detection broken (workoutService.ts:145), GZCLP progression broken |
| vibe-planmode 002 | **44.0 / 55** (P15.5/R28.5) | $24.09 | ~0.78 | code | SysDes 5 (top rigor in cohort); Major: chinup 0lb redditPPL.ts:123 |
| openspec 001 | **45.5 / 55** (P16.5/R29) | $20.64 | ~1.21 | code | archive completed (breaks vague-run miss); 50/50 tests; Q/$ 6.91→2.20 |
| openspec 002 | **45.5 / 55** | $22.91 | ~0.89 | code | 96 tests; archive clean |
| ai-dlc 001 | **44.5 / 55** (P16.5/R28) | $97.97 | **~0.4 (lowest)** | code | PBT fast-check; 159 tests; Q/$ ~0.45 (cost tail #2) |
| ai-dlc 002 | **44.0 / 55** (P15/R29) | $33.50 | ~0.66 | code | −66% cost vs 001 |
| bmad 001 | **46.5 / 55** (P16.5/R30) | $384.05 | ~0.69 | code | cohort QUALITY LEADER; 18.6× openspec cost for +1.0 |
| bmad 002 | — | TBD | — | — | **PENDING cell ship** |
| spec-kit 001 | **34.0 / 45** (P5.5, UI/UX n/a) | $14.01 | ~0.88 | code | no Expo app (methodology characteristic); /45 not /55; cheapest; binary 5/14 |
| spec-kit 002 | **44 / 55** (P14.5/R29.5) | $30.10 | ~0.9 | code | full app shipped |

**Cohort quality order (code-based, /55 cells):** bmad-001 46.5 > openspec-001 = openspec-002 45.5 > ai-dlc-001 44.5 > planmode-001 = planmode-002 = ai-dlc-002 = speckit-002 44.0 > vibe-002 40.5 > vibe-001 39 (Maestro, diff measurement condition). spec-kit-001 (34/45) + bmad-002 (pending) are apart. **All within a ~2.5-pt band except the two vibe cells** — tight cluster, report as band not rank (rubric v0.2).

**Spot-check (2026-05-29):** ✅ all 10 quality sums filled + marked code-based; build-results substantial (46–178 lines); **fabrication grep CLEAN** — the only sim/Maestro mentions are (a) properly-contextualized references to the ORIGINAL cell session's screenshots (valid evidence, agent explicit it didn't re-run sim) and (b) "cell did NOT run forbidden commands" no-runtime compliance checks. 0 workflow failures.

**Flags before matrix compile:**
- Some observations.md write the Quality-sum line as an arithmetic expression ("4.5+5+...=45.5/55") rather than clean "X / 55" — readable but inconsistent format; normalize at compile.
- All 10 are CODE-BASED / PROVISIONAL. The blind ≥2-rater pass (next phase) is ALSO code-based → these effectively serve as pass-1. vibe-001's Maestro runtime evidence is unique → flag the measurement-condition asymmetry in the matrix (don't clean-rank vibe-001 against the code-based cells).
- Paired run-001↔002 Δ now computable (was hypothesis-only): vibe +1.5 / planmode 0.0 / openspec 0.0 / ai-dlc −0.5 quality; cost vibe −10% / planmode −25% / openspec +11% / ai-dlc −66%.
- bmad-002 still needs its CELL to ship, then score (sole remaining cell).

## run-001 costs (from prior cell execution, for paired-Δ):
vibe $22.74 / vibe-planmode $31.94 / openspec $20.64 / spec-kit $14.01 / ai-dlc $97.97 / bmad $384.05
## run-002 costs: vibe $20.36 / vibe-planmode $24.09 / openspec $22.91 / spec-kit $30.10 / ai-dlc $33.50 / bmad TBD

## ✅ bmad-002 RE-SCORED + RUN-002 EVAL DONE (2026-06-01)
- bmad-002 cell COMPLETE (full app shell). Blind 2-rater re-score = **34.5** (p1 34.0 / p2 35.0; void 21.0 discarded). 24/24 blind reviews now valid + archived. blind-pass-audit.md updated (bmad row restored, findings corrected).
- **Run-002 evaluation written:** `analysis/t4-fitness-app-rich/run-002-evaluation.md`. Blind band 33.75–34.75 (spec-kit 30.0 trailing); vibe co-leads (replicates T1/T2); cost-Δ REVERSES run-001 (ai-dlc −66%, bmad +80%, spec-kit +115%); BMAD output-vs-artifacts headline ($689 = vibe's code at 34× cost).
- **bmad-002 code-based /55 = 42.5** (Product 13.5/20, Rigor 29/35; defects 0.59/1KLOC but SEVERITY REGRESSION: 3 Major vs run-001 all-Minor — GZCLP day-index double-advance kills B-days; all 5 native services throw NotImplementedError; shipped README hides inertness). 683 tests pass + best spec (5/5) yet 2 predicted edge cases shipped as Majors. Slotted into run-002-evaluation.md. **ALL run-002 cells now fully scored (blind + code-based + cost).**
- **NEXT:** (1) compile combined scoring-matrix.md (both runs, 3 conditions). (2) commit harness + builds repo.

## bmad-002 COST (captured 2026-06-01 — 6 chat windows, volatile screen data)
$32.25 + $14.15 + $41.95 + $3.68 + $223.21 + $374.23 = **$689.47 total**
API compute: ~18.0 h. Gross lines added (incl planning churn): 34,877.
vs bmad-001 $384.05 → **+$305.42 (+80%)**. Makes bmad-002 the single most expensive cell in the entire eval (passes bmad-001). Output-vs-artifacts: $689 for a no-runtime source deliverable.
Cell CONFIRMED COMPLETE this time (full app shell: onboarding 8 screens + 5 tabs + src/state 63 components; index.tsx no longer Expo scaffold). The earlier 21.0 blind score was a mid-flight snapshot — VOID stands; this is the real cell.
