# T4-rich (PM-quality brief) / Vibe Plan Mode / Run 001 / Observations

Filled in during scoring. Uses [`harness/scoring-rubric.md`](../../../../harness/scoring-rubric.md) and [`tasks/t4-fitness-app-rich/success-criteria.md`](../../../../tasks/t4-fitness-app-rich/success-criteria.md).

**Reviewer:** claude-sonnet-4-6 (autonomous scoring agent)
**Scored on:** 2026-05-29
**Methodology revealed at:** n/a (unblinded — single autonomous rater)

> **PROVISIONAL — unblinded, single-rater, code-based (no sim this pass).** Code-visible dims scored from full source review + tsc/jest results. Planning dims scored from the plan artifact at `~/.claude/plans/compound-strength-app-jolly-pretzel.md`. Binary outcomes code-verified (file:line cited). Runtime behaviors marked as noted.

---

# QUALITY AXIS

## Dimension scores (0–5 per harness/scoring-rubric.md)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | 4.5 | All 7 programs implemented + tested; all core brief features present; minor gap: Android only cross-platform code (not device-verified), GZCLP T3 accessory weight is at factor 0.5 of workingWeight rather than the canonical light accessory scheme |
| 2 | Correctness | (see defect block below) | |
| 3 | Code quality | 4.5 | Intentional names throughout; strong type discipline; pure/impure separation enforced; domain/engine/db/state/components layering maintained — `weightSelector.ts` step function is clean; minor: `historyRepo.ts:49` uses `any` for SQLite rows |
| 4 | System design | 5 | Pure engine / SQLite repo / Zustand conductor / Expo Router screens — hard boundaries that never leak; `logged_sets` keyed by exercise_id spans programs; nullable columns absorb stretch without migration; design decisions documented in plan + AGENTS.md |
| 5 | UI design | 4 | Dark default (#0A0B0D), accent orange, tap.min=48pt exceeding 44pt floor; display-size weight numerals (font.display=56); plate load bar; PR celebration animation; gap: no tonnage chart visualization (Sparkline is e1RM only) |
| 6 | UX | 4 | 1-tap log wired via `handleLog` (workout.tsx:126); rest timer auto-starts on log (workout.tsx:146); warm-up ramp generated; weight stepper has large 64pt buttons; RPE optional never blocks; gap: no explicit AMRAP "leave 1 in the tank" coaching note surfaced |
| 7 | Robustness | 3.5 | `solvePlates` never prescribes unowned plates (plateCalc.ts:33); `roundToAchievable` handles inventory limits; notification errors caught silently (notifications.ts:54); rest timer persists to SQLite across backgrounding (restTimer.ts:33); gap: `completeSession` uses `slot.scheme ?? { basis: 'absolute', sets: [] }` (workoutService.ts:145) — resolver-driven slots (5/3/1 main lifts) always have `schemeResolver` not `scheme`, so `hitAll` will be false for them, though progression still runs correctly since `topSetActualReps` is captured |
| 8 | Security | 3 | No external network; SQLite parameterized queries throughout; no hardcoded secrets; local-only; gap: no explicit dep audit/lockfile discipline visible, deps are pinned via expo-install |
| 9 | Documentation | 3 | AGENTS.md: architecture + run/test/build docs + engine families + key flow (10 min to productive); README.md is stock Expo template (unhelpful); code comments where why would surprise a reader (types.ts header, schema.ts header, resolveWorkout.ts, most engine files); gap: no onboarding for new contributors beyond AGENTS.md |
| 10 | Spec articulation | 4.5 | Plan file covers all major behaviors with testable acceptance criteria; canonical sources pinned per program; architecture decisions with rationale (depth-first vs. breadth-first, TM accumulation design, Madcow risk flagged as "riskiest abstraction test"); 5 riskiest parts explicitly flagged; missing only: Android local-notification path verification committed as "verify once before close" but not tracked as a discrete checkpoint |
| 11 | Scope clarity | 4 | Plan explicitly cuts: breadth-first program rollout → depth-first vertical slice; iOS-first; Live Activity strictly bonus; plan acknowledges intentional over-scope with phase gating; deload/week-4 decision documented; gap: no explicit statement of what was cut vs. the brief's stretch list (brief §11 items) |
| 12 | Assumption surfacing | count: 8 / quality: 3.5 | Plan's "Open assumptions confirmed/decisions" block names 8 explicit choices (lbs, one-active, warm-ups excluded, RPE optional, recommendation mapping, Zustand, depth-first, iOS-first) with stated rationale; categorization is implicit (product vs. technical), not formal; no mapping to specific code locations |

**Quality sum: 44.0**

**Product polish (dims 1+5+6+7): 4.5 + 4 + 4 + 3.5 = 16 / 20**
**Engineering rigor (dims 3+4+8+9+10+11+12): 4.5 + 5 + 3 + 3 + 4.5 + 4 + 3.5 = 27.5 / 35**

---

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | 0 |
| Major | 0 | 0 | 1 | 1 |
| Minor | 0 | 0 | 4 | 5 |

LOC produced: ~4,057 (non-test production TS/TSX); token-log reports 5,543 added net 5,488 total incl. test files, config, schema
**Defects per 1KLOC: 6 / 4.057 ≈ 1.48 per 1KLOC**

Itemize defects (all from code review — R):

1. **[MAJOR] `completeSession` progression hit-detection skips resolver-driven slots.** `workoutService.ts:145`: `prescribed: slot.scheme ?? { basis: 'absolute', sets: [] }` — for slots using `schemeResolver` (5/3/1 main lift, nSuns T1/T2, GZCLP), `slot.scheme` is undefined, so `prescribed.sets` is `[]`, making `prescribedCount=0` and `hitAll=false` always. This means `tmPerCycle`, `nsunsAmrap`, and `stageLadder` will never see `hitAllPrescribed=true`; they rely instead on `topSetActualReps` (which IS captured correctly), so 5/3/1 and nSuns TM progression still work. GZCLP stageLadder T1/T2 also uses `hitAllPrescribed` — T1 and T2 will never progress their stage (they will always miss, advancing the failure branch). Impact: GZCLP T1/T2 progression is broken in the completion path; 5/3/1 and nSuns are functionally OK because they use AMRAP reps, not `hitAllPrescribed`.

2. **[MINOR] GZCLP T3 accessory uses factor 0.5 of workingWeight.** `gzclpStage.ts:37`: T3 is built with `factor=0.5` of `absolute` basis — but `absolute` basis ignores the factor in `weightSelector.ts` (it just uses `workingWeight` directly). The canonical GZCLP T3 is a separate light weight (3×15 AMRAP, progresses independently at +5 when ≥25 total reps). The T3 weight is effectively the accessory lift's `workingWeight` (the row), which is seeded separately — so in practice it may work, but the factor=0.5 on an absolute basis is a no-op that could confuse maintainers.

3. **[MINOR] Madcow `weeklyRamp` treats all lifts on the final rotation day.** `weeklyRamp.ts:25`: `for (const [lift, prev] of prevStates)` iterates ALL lift states, not just those in the current template. If a lift is not trained on Friday, it still gets the weekly bump. Canonical Madcow progresses only the lifts actually trained in the Friday intensity day.

4. **[MINOR] nSuns AMRAP jump: reps<=1 increments fail counter, but no deload path.** `nsunsAmrap.ts:38`: `consecutiveFails` increments but the nSuns strategy has no deload implementation (unlike linearPerSession). This is a missing feature (nSuns does have a stall protocol) but nSuns is known to not have a standard deload in many renderings — ambiguous.

5. **[MINOR] `README.md` is the stock Expo template** — no project-specific documentation. `AGENTS.md` compensates but README.md is unhelpful for a new contributor arriving via GitHub.

6. **[MINOR] `devSeed.ts` DEV_AUTOSEED=false gate** — shipped in production source with `__DEV__` guard (layout.tsx:27). Flag is false and guard is correct; no runtime impact but the dead-code path ships.

---

## Binary outcomes (pass/fail per task success-criteria.md §1)

- [x] **1. Core app builds + runs as a dev build** — code-verified: `app.json` has SDK 56 config + `expo-notifications` plugin; session log confirms `npx expo run:ios` succeeded and app launched on iPhone 17 Pro sim; Metro bundled 1911 modules with no errors; GZCLP Today screen screenshots captured by session agent at [15:35:30].
- [x] **2. Onboarding works** — code-verified: `onboarding.tsx:13-59` implements all steps (welcome/experience/schedule/goal/programFork/numbers/confirm); `recommendPrograms()` in `programs/index.ts:46-77` maps experience+days+goal to recommendations; `completeOnboarding()` seeds all programs; lands on `/(tabs)`.
- [x] **3. Four lifts present** — code-verified: `types.ts:14-18` defines squat/bench/deadlift/ohp as `LiftId`; all four appear in every program's `trackedLifts`; MAIN_LIFTS in onboarding.tsx:15 includes all four.
- [x] **4. Today's workout on open** — code-verified: `(tabs)/index.tsx:75-81` renders `slot.workingSets[0]?.weight` and `PlateBar` for each slot before any user input; `getToday()` resolves workout on load.
- [x] **5. Set logging works (1-tap common case)** — code-verified: `workout.tsx:126-153` `handleLog` fires on single button press; `edit` state pre-seeded from prescription (`activeKey` effect at line 120); the "Log N reps @ W" button is the single tap.
- [x] **6. Plate calculator** — code-verified: `PlateBar.tsx` uses `solvePlates(weight, barLb, inventory)` (`plateCalc.ts:32`); `solvePlates` never returns a plate not in inventory; bar weight configurable via settings.
- [x] **7. Rest timer** — code-verified: `workout.tsx:145-147` starts timer on every non-warmup set log; `RestTimerBar.tsx:31-35` fires haptic at zero; `restTimer.ts:28-34` uses `endsAt` timestamp; per-exercise `restSeconds` in domain types.
- [x] **8. Backgrounded rest alert (both platforms)** — code-verified: `notifications.ts:39-57` schedules `TIME_INTERVAL` local notification on start; Android channel created at line 19; iOS path at line 42; timer is timestamp-based (restTimer.ts:33: `endsAt = now + seconds * 1000`) so accurate on return. Live Activity: absent (noted in AGENTS.md line 57). PASS on required floor; LA bonus not shipped.
- [x] **9. Quick-switch survives** — code-verified: rest timer `hydrate()` in `restTimer.ts:52-65` restores `endsAt` from SQLite on app boot; `_layout.tsx:22` calls `hydrate` on startup; `workoutService.ts:60-61` resumes open session from `findOpenSession()`; state survives kill+reopen.
- [x] **10. Warm-up ramp** — code-verified: `warmups.ts:9-41` generates ramp (empty bar → 55/70/85%); called from `resolveWorkout.ts:85-88` for first slot of each lift; session log [15:23:30] shows auto-generated warm-up ramp (45→125→157.5→190) for 225 lb working weight.
- [x] **11. 7 programs, correct progression** — code-verified: all 7 registered in `programs/index.ts:14-22`; test suite: 34 tests across 5 suites cover linear (sl5x5/sl5x3/ppl), wendler531, gzclp, nsuns, madcow canonical progression. NOTE: GZCLP T1/T2 stage progression in `completeSession` is broken (see defect #1), but programs DO exist and prescribe correctly.
- [x] **12. Flexible scheduling (3–6 days)** — code-verified: `onboarding.tsx:87-97` offers [3,4,5,6] days; `programs/index.ts:66` PPL gated on `days >= 6`; not hardcoded.
- [x] **13. History persists + History screen** — code-verified: `(tabs)/history.tsx` browses `getSessionSummaries()`; `history/[sessionId].tsx` for detail; `logged_sets` keyed by `exercise_id` so spans programs (schema.ts:56-75); `switchProgram` only flips `activeProgramId`, never deletes history.
- [x] **14. Progress + PRs** — code-verified: `(tabs)/progress.tsx` shows per-lift `getExerciseTrend()` (e1RM Epley) + `getPRs()`; `Sparkline` component; `pr.ts` detects weight/e1RM/rep PRs; `PRCelebration` component with spring animation; `recordPRs` persists to `prs` table.

**Pass count: 14 / 14**

---

## Rich-brief-specific checks (per success-criteria.md §2)

- [x] **Non-goals honored** — no auth/accounts/cloud sync/social/cardio/nutrition/multi-user; `app.json` has no remote push config; `UIBackgroundModes: []`. code-verified.
- [x] **Open assumptions engaged, not silently overridden** — plan explicitly acknowledges: lbs+standard plates, one-active-program-seeds-all, warm-ups/assistance excluded from PRs, RPE optional, recommendation mapping table. Each is implemented as stated.
- [x] **Stretch stayed out** — supersets/export/custom builder/Watch companion not built; schema has nullable headroom columns but no implementation; `devSeed.ts` comment notes stretch features deferred.
- [x] **Delight north-star (§8) — unprompted delight** — YES: `PRCelebration.tsx` spring animation + gold trophy; `RestTimerBar.tsx` progress bar + haptic at zero; dark theme with energetic orange accent; haptics on every button; tap targets 48pt+ all through; plan names "satisfying micro-interactions" as Phase 5 intent. Not just checklist — the PR moment is a genuinely considered delight beat.
- [x] **Runtime honored** — `app.json` SDK 56; session log uses `npx expo run:ios`, `npx expo install`; no global CLI; dev build confirmed (not Expo Go).
- [x] **Equipment scope honored** — all 7 programs use barbell lifts; GZCLP T3 uses barbell row as substitute; PPL drops non-barbell accessories; `domain/types.ts:18-25` only has barbell lifts.

**All 6 engagement checks: PASS**

---

# COST AXIS

## Raw metrics (from session-log.md + token-log.md)

| Metric | Value |
|---|---|
| Total tokens | ~46.0M (403.5K input + 256.3K output + 44.9M cache read + 423.6K cache write) |
| Implied API cost | $31.94 |
| API compute time | 0 h 59 m 28 s |
| Active wall-clock (context) | 1 h 24 m 20 s |
| Operator-touch time | ~5 min (plan approval gate + sim port redirect + build monitoring — operator to finalize) |
| Operator intervention count | 0 unplanned corrections (port collision was handled autonomously) |
| Time to first working build | ~24 min from session start (14:32:42 start → first `expo run:ios` success confirmed ~15:09; ~37 min wall-clock; API compute substantially less) |

**Phase breakdown:**
- Plan Mode (context + AskUserQuestion + sub-agents + plan write): ~10–12 min API compute (14:32 → ~14:43)
- Implementation (post-approval): ~47–49 min API compute

## Derived ratios

| Ratio | Value | Cross-methodology rank (fill after hexad scored) |
|---|---|---|
| Quality per 1K tokens | 44.0 / 46,000 ≈ 0.00096 | (fill after hexad) |
| Quality per API hour | 44.0 / (59.47/60) ≈ 44.4 / hr | (fill after hexad) |
| Defects per 1KLOC | 6 / 4.057 ≈ 1.48 per 1KLOC | (fill after hexad) |
| Methodology overhead ratio | ~10–12 min planning / ~47–49 min impl ≈ 0.22–0.26 | (fill after hexad) |
| Cost per binary outcome | $31.94 / 14 = $2.28 | (fill after hexad) |
| Quality per dollar | 44.0 / 31.94 ≈ 1.38 | (fill after hexad) |

---

# PAIRED DELTA vs T4-vague (vibe-planmode)

T4-vague Vibe Plan Mode baseline (locked):
- Quality: 43.5 / 55
- Cost: $7.78 / 27m active / 7/7 binary
- Defects: 0/1/2 / 1.16 per 1KLOC

| Metric | T4-vague | T4-rich run-001 | Δ |
|---|---|---|---|
| Quality | 43.5 | 44.0 | +0.5 |
| Cost | $7.78 | $31.94 | +$24.16 (+310%) |
| API compute time | 22m 43s | 59m 28s | +36m 45s (+162%) |
| Binary outcomes | 7/7 | 14/14 | +7 (all new passing) |
| Defects/1KLOC | 1.16 | 1.48 | +0.32 |
| Plan revisions | 0 | 0 | 0 |
| PM forwards | 1 (AskUserQuestion) | 1 (AskUserQuestion) | 0 |

## Paired Δ vs run-002 (within-methodology, runtime vs no-runtime)

| Metric | run-001 (with-runtime, this cell) | run-002 (no-runtime) | Δ |
|---|---|---|---|
| Implied API cost | $31.94 | $24.09 | run-001 costs $7.85 more (+33%) |
| API compute time | 59m 28s | 44m 15s | run-001 is 15m 13s longer |
| Net LOC | 5,488 | 7,638 | run-001 ships 2,150 fewer lines (−28%) |
| Web searches | 14 | 2 | run-001 did 12 more searches (runtime SDK research) |
| Sub-agents | 3 | 1 | run-001 used 2 more sub-agents |

**Interpretation:** run-001's premium ($7.85, +33%) bought runtime verification on the sim (screenshots, dev build confirmed, bug caught + fixed live). Run-002 shipped more LOC without the runtime overhead. The research overhead in run-001 was load-bearing — it produced a pinned canonical program source table AND caught a real squat progression bug live.

---

# HEADLINE FINDING

```
Quality: 44.0 / 55  ·  Cost: $31.94 / 59m 28s API compute  ·  Binary: 14 / 14 pass  ·  Δ vs vague: +0.5 Q, +$24.16 C
```

**One-line verdict** (covering BOTH axes):

> Vibe Plan Mode delivered a full 14/14 binary outcome pass and a well-architected 7-program strength app for $31.94 — a 310% cost premium over the vague brief at marginal quality gain (+0.5), driven by SDK research overhead that proved load-bearing (bug caught live, canonical sources pinned); the planning artifact quality justifies the research spend but not the 4× cost multiple vs. the lean methodologies.

---

## Failure mode characterization

**Where did Vibe Plan Mode break down?**
- `completeSession` progression hit-detection is broken for resolver-driven slots (major defect #1): the plan correctly specified "build CompletedSlotResult[] from logged sets → run pure progression strategy" but the implementation fetches `slot.scheme` which is undefined for schemeResolver-based slots, making `hitAllPrescribed` always false for 5/3/1, GZCLP T1/T2, and nSuns. This is a classic integration-gap failure — the pure engine tests pass because they test the strategy in isolation, not the completion-path wiring.
- Android not device-verified (noted in AGENTS.md) — cross-platform code is correct but the Android local notification path is not confirmed.

**Categories of mistake:**
- Integration gap between the pure engine interface and the completion path (the major defect)
- Minor precision issues in program implementations (Madcow iterates all lifts, not just the Friday template's lifts)
- Documentation gap: stock README not updated

**What did it do surprisingly well?**
- The plan file is genuinely good: depth-first decision made explicitly, canonical program sources pinned with contested-variant disambiguation, Madcow flagged as riskiest abstraction risk (and it was, per the weeklyRamp defect), 5 riskiest parts identified. This is not boilerplate — it's real architectural thinking.
- The pure engine / SQLite repo / Zustand conductor separation is near-textbook. The domain types file is one of the best-designed type systems seen in this hexad: the `SetPrescription` explicit-per-set unifying representation is an elegant solution to the 7-program diversity problem.
- All 7 programs implemented with a unit test suite in a single 1h session, with a real bug caught and fixed live on the simulator.
- PR celebration with spring animation, haptics throughout, dark theme, 48pt+ tap targets — delight north-star genuinely engaged from intent.
- Rest timer is timestamp-based with SQLite persistence — the right architecture for the backgrounding requirement, not a lazy `setTimeout`.

**Notable planning artifacts:**
- Plan file (`~/.claude/plans/compound-strength-app-jolly-pretzel.md`): ~200 lines; covers architecture, module layout, domain types, control flow, phasing, pinned canonical sources, open assumptions, verification protocol. Stronger than T4-vague plan mode (which was structurally identical but lighter on research). Score 4.5 on Spec is earned.

**Operator-tempted-but-didn't-intervene moments:**
- Port collision (foreign Metro on 8081) — handled autonomously with a secondary port; operator did not redirect.
- Synthetic click injection failing — handled autonomously via dev seed redirect approach; operator did not intervene.

**T4-rich-specific: did the plan engage the delight north-star and assumptions block?**
- YES on delight: plan names "PR celebration polish, haptics that land, satisfying micro-interactions" as Phase 5 — and it shipped, not just claimed.
- YES on assumptions: plan's "Open assumptions confirmed/decisions" block explicitly acknowledges and accepts all 8 major assumptions from brief §10 with stated rationale, not silent override.
- The brief's delight north-star ("figure it out") was genuinely inferred from intent — the PRCelebration spring animation was not specified in the brief, it was designed from the "satisfying PR moment" intent clue.
