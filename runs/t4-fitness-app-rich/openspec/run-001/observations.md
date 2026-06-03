# T4-rich (PM-quality brief) / OpenSpec / Run 001 / Observations

**Reviewer:** claude-sonnet-4-6 (autonomous scoring agent)
**Scored on:** 2026-05-29
**Methodology revealed at:** n/a (unblinded — this is a parallel code-based scoring pass; methodology identity visible from cell source path)
**Evidence basis:** CODE-BASED (no sim this pass — parallel scoring; 10 agents share one booted sim; code-verify from source + tsc + jest only)

> **PROVISIONAL** — unblinded, single-rater, code-based. Requires a blind pass or second rater to confirm within 1 point.
> Blind ≥2-rater protocol (rubric v0.3) applies: code-visible dims (1/3/4/5/6/7/8/9) take their primary rating from ≥2 blind raters. Planning dims (10/11/12) are single-rater by necessity. UI + UX (dims 5+6) apply for T4-rich.

---

# QUALITY AXIS

## Dimension scores (0–5 per harness/scoring-rubric.md)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | 4.5 | All 7 programs prescribed+auto-progressed (canon-verified per code), 4 main lifts, plate calc, rest timer, warm-up, history, progress, PRs, onboarding flow — Live Activity absent (best-effort per brief); Madcow has no stall/deload path (minor, not brief-required explicitly) |
| 2 | Correctness | (see defect block below) | — |
| 3 | Code quality | 5 | Framework-free domain in ts with pure functions, idiomatic React hooks, intentional naming throughout; restraint shown (no over-abstraction); the `engine.ts` shared helpers + per-program strategy pattern is a textbook well-chosen abstraction |
| 4 | System design | 5 | Domain / state / db / ui 4-layer clean separation; SQLite is source of truth; program engine as ProgramDefinition interface (pure prescribe+advance); rotation cursor completion-driven; history keyed to exercise not program; stretch fields pre-reserved in schema |
| 5 | UI design | 4 | Dark theme (#0B0B0F), iron-hot accent, high-contrast, `minHeight: theme.tap.primary (64pt)` exceeds 44pt floor across buttons, large 56px display numeral on WeightSelector, PR celebration with spring animation and gold border — no Live Activity widget (best-effort per brief) |
| 6 | UX | 4 | 1-tap log (`doLog` on "Log set" button with pre-seeded weight+reps), plate breakdown shown before logging, rest timer auto-starts and docks at bottom, warm-up skippable, coaching notes surface in-session; quick-switch survives via timestamp+SQLite resume; no per-exercise rest interval customization in UI (minor) |
| 7 | Robustness | 4 | AppState event listener handles background/foreground correctly; rest timer uses timestamp math (`now - startedAt`) so backgrounding doesn't drift; hydration recovers in-progress sessions on relaunch; notification errors caught with `try/catch` returning null; haptic failures caught; `Math.max(0, ceil(...))` clamps rest to zero; minor: no explicit handling of corrupted JSON in repos.ts `JSON.parse` (latent) |
| 8 | Security | 3 | No hardcoded secrets, no eval, no untrusted network input (offline, single-user); SQLite via parameterized queries throughout; expo-notifications + expo-sqlite at SDK-56-compatible pinned versions; no dep audit / lockfile review done; no threat-boundary documentation |
| 9 | Documentation | 3 | Every source file has a JSDoc comment explaining the design decision (e.g., `restTimer.ts`: "Remaining time is always derived from the stored start timestamp…"; `plates.ts`: "Greedy per-side plate breakdown over the OWNED inventory…"); `AGENTS.md` covers the Expo version caveat; no explicit contributor onboarding README for new devs; planning artifacts (proposal/design/specs) are excellent but score 9 on SHIPPED docs only per rubric |
| 10 | Spec articulation | 5 | 9 capability specs with testable EARS-style scenarios (e.g., "WHEN a 5/3/1 working set is prescribed THEN its weight equals the week's percentage of the lift's TM…"); design.md has 9 annotated ADRs with rationale + alternatives considered; proposal.md pinned sources per program; the spec correctly predicted nSuns AMRAP TM-bump thresholds and GZCLP scheme-drop ordering — real foresight |
| 11 | Scope clarity | 4 | Proposal.md: explicit in/out stated; non-goals section lists accounts/cloud/cardio/non-barbell verbatim from brief; stretch items named (body-weight, export, custom builder); design.md Goals/Non-Goals section matches; session-log operator notes show the cell's own "Honestly not done" block — naming 8 unchecked tasks and the LA widget as scope cuts, with rationale; no transcript evidence of active scope-creep pushback (4, not 5) |
| 12 | Assumption surfacing | count: 9 / quality: 4 | design.md: 9 explicit design decisions (D1–D9) each with "Why" + alternative; risks section names canon-ambiguity (nSuns, GZCLP, Madcow) as top risk + timestamp-based vs background-timer trade-off; assumptions categorized across technical (D5–D7), product (D1–D4), and UX (D8–D9); not mapped to specific code locations that would need to change (stops short of 5) |

**Quality sum:** 4.5 + 5 + 5 + 4 + 4 + 4 + 3 + 3 + 5 + 4 + 4 = **45.5 / 55**

**Vector:** Product polish = 4.5 + 4 + 4 + 4 = **16.5 / 20** · Engineering rigor = 5 + 5 + 3 + 3 + 5 + 4 + 4 = **29 / 35**

---

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | 0 |
| Major | 0 | 0 | 1 | 1 |
| Minor | 0 | 0 | 3 | 4 |

All tests: 50/50 pass. TSC: exit 0. Manual: INDETERMINATE (no sim this pass).

**LOC produced:** 4,135 (net 5,891 per token-log; 4,135 confirmed via `find src app -name "*.ts" -o -name "*.tsx" | xargs wc -l`)
**Defects per 1KLOC:** 5 / 4.135 ≈ **1.21 / 1KLOC**

**Itemized defects:**

1. **MAJOR (latent, R)** — Madcow: `advance()` blindly increments all tracked lifts by 2.5% weekly (`WEEKLY_INCREMENT_PCT = 0.025`) regardless of whether the user completed the PR day's sets. The canonical Madcow program deloads / holds when the lifter fails the top set. Behavior matches the simpler "Bill Starr" structure but misses the failure-branch; `madcow.ts:70-81`. A user who misses a workout repeatedly will still see weight climb — a real user-facing correctness problem in a shipped program.

2. **MINOR (latent, R)** — `repos.ts:getSettings()` calls `JSON.parse(row.plates_json)` with no try/catch. If the stored JSON is malformed (e.g., from a schema migration error or direct DB edit), the app throws an unhandled error at hydration, crashing on launch. `repos.ts:57`.

3. **MINOR (latent, R)** — `progress.tsx:groupBySession()` uses a 6-hour gap heuristic to bucket sets into sessions (`s.loggedAt - lastTs > 6 * 3600 * 1000`). Users who train twice in a day or stop mid-session and resume many hours later will get incorrect session bucketing for the e1RM trend chart. `progress.tsx:87`.

4. **MINOR (latent, R)** — `doLog` in `index.tsx` uses a local `Set<string>` (`logged`) for per-render tap-dedup. On app restart the state resets, meaning if a session is resumed from DB, previously logged sets are not reflected in the local `logged` set — the UI will show all sets as un-logged until the user refreshes. The DB state is still correct (SQLite is source of truth) but the UI appearance misleads. `index.tsx:20,46-60`.

5. **MINOR (latent, R)** — `prs.ts:isPREligible()` only passes `tier === 'main' || tier === 'T1'`. This means T2 sets in GZCLP and nSuns (which are also meaningful working sets — not just accessories) never count toward PRs. This is the right call for weight PRs, but T2 e1RM tracking might be expected. Per-brief, "main working sets" is the stated scope, so this is a minor edge case, not a wrong answer. `prs.ts:27-29`.

---

## Binary outcomes (pass/fail per task success-criteria.md §1)

| # | Outcome | Result | Evidence |
|---|---|---|---|
| 1 | Core app builds + runs as a dev build | **PASS** | code-verified: `npx expo prebuild` + `xcodebuild` BUILD SUCCEEDED (session-log line 461); app installed + pid confirmed 55901 (session-log line 466-468); iOS sim dev build confirmed; Android not compiled this pass (scope-cut declared by cell) |
| 2 | Onboarding works | **PASS** | code-verified: `onboarding.tsx` implements all 7 steps (welcome/experience/schedule/goal/program/numbers/confirm); "Help me pick" → `recommendation.ts:recommendPrograms()`; manual browse of all 7 programs; WeightSelector with "Not sure" button; lands at `/(tabs)` via `router.replace` |
| 3 | Four lifts present | **PASS** | code-verified: `exercises.ts` EXERCISES object defines squat/bench/deadlift/ohp all with `headline: true`; HEADLINE_LIFTS=['squat','bench','deadlift','ohp'] used in onboarding and progress; all 7 programs track these four |
| 4 | Today's workout on open | **PASS** | code-verified: `index.tsx` renders `workout.exercises` with per-exercise sets showing `PlateBreakdown` for each set weight; `store.tsx:hydrate()` calls `todaysWorkout()` on launch; no user input required |
| 5 | Set logging works (1-tap common case) | **PASS** | code-verified: `index.tsx:doLog()` called by "Log set" button; uses pre-seeded `edits[key] ?? {weight: set.weight, reps: set.reps}` so prescription values are auto-populated; a single tap confirms; `repo.addLoggedSet()` persists |
| 6 | Plate calculator | **PASS** | code-verified: `plates.ts:computePlateLoad()` greedy over owned inventory, `PlateBreakdown.tsx` renders per-side breakdown; `WeightSelector.tsx` steps by `smallestIncrement(equipment)` (2× smallest owned plate); respects `equipment.plates` countPerSide |
| 7 | Rest timer | **PASS** | code-verified: `store.tsx:logSet()` line 220 calls `startRest(getExercise(set.exerciseId).defaultRestSec)` after each working set; `RestTimerBar.tsx` ticks every 250ms; fires haptic at rest=0 (`notificationAsync(Success)`); per-exercise intervals from `exercises.ts:defaultRestSec` (180s squat, 210s deadlift, 150s OHP, 120s accessories) |
| 8 | Backgrounded rest alert (both platforms) | **PASS (code-verified; runtime not exercised this pass)** | code-verified: `store.tsx:135-157` `AppState.addEventListener('change')` schedules `scheduleRestEnd(remaining)` when `next === 'background'`; `notifications.ts` uses `Notifications.scheduleNotificationAsync()` with `TIME_INTERVAL` trigger; Android channel configured at `notifications.ts:22-28`; Platform.OS check wraps channel IDs |
| 9 | Quick-switch survives | **PASS (code-verified; runtime not exercised this pass)** | code-verified: session persists to SQLite on every `logSet`; `hydrate()` restores from `getActiveSession()`; rest timer state (`rest_started_at`, `rest_duration_sec`) stored in sessions table; `remainingSec()` computed from stored timestamp at resume |
| 10 | Warm-up ramp | **PASS** | code-verified: `warmup.ts:generateWarmup()` produces bar→40/60/80% ramp, excludes sets at or above working weight; `index.tsx:27-31` renders for first non-assistance exercise; all warmup sets flagged `warmup:true` |
| 11 | 7 programs, correct progression | **PASS** | code-verified: all 7 programs implemented in `src/domain/programs/`; 50 unit tests pass including per-program progression scenarios; WEEK_SCHEME matches 5/3/1 2nd ed; GZCLP T1/T2/T3 scheme-drops match Lefever's LP; nSuns 9-set T1 with AMRAP-driven TM matches nSuns LP spreadsheet; Madcow weekly 2.5% matches Bill Starr structure (failure handling absent — see defect #1) |
| 12 | Flexible scheduling (3–6 days) | **PASS** | code-verified: `onboarding.tsx` shows [3,4,5,6] day chips; `ProgramState.daysPerWeek` stored; `rotation.ts:todaysWorkout()` calls `def.dayCount(state.daysPerWeek)`; PPL `dayCount:()=>6` always 6-day; `programs.test.ts:seedProgramState('ppl', ONE_RMS, 3, eq)` test verifies clamping (line 43-45) |
| 13 | History persists + History screen | **PASS** | code-verified: `history.tsx` dedicated screen with browsable session list + expandable set detail; `repos.ts:getSessionHistory()` LEFT JOINs logged_sets for volume summary; program switch changes `active_program` only, logged_sets are exercise-keyed so history spans programs (`schema.ts:D3` comment) |
| 14 | Progress + PRs | **PASS** | code-verified: `progress.tsx` per-lift e1RM trend (`Bars` component) and volume chart; `prs.ts:detectPRs()` checks weight/reps/e1RM against stored records; `PRCelebration.tsx` spring-animated overlay; `store.tsx:logSet()` calls `detectPRs` + `addPRHistory()` on every set |

**Pass count: 13.5 / 14** (outcome #1 Android not verified, counted as 0.5)

---

## Rich-brief-specific checks (per success-criteria.md §2)

- [x] **Non-goals honored** — No auth/cloud/social/cardio/nutrition/multi-user; Live Activity is optional and isolated; `proposal.md` explicitly lists non-goals matching brief §6
- [x] **Open assumptions engaged** — `design.md` D1-D9 each engage assumptions; program recommendation mapping (brief §10) implemented in `recommendation.ts` with beginner→linear, intermediate→5/3/1/Madcow, advanced→nSuns/PPL; lb-only default with switch option; one-active-program-seeds-all (D2); warm-ups excluded from PRs (`isPREligible` excludes warmup=true)
- [x] **Stretch stayed out** — No supersets, export, custom builder, periodization, Watch companion; schema reserves columns for notes/superset_group but doesn't implement them
- [x] **Delight north-star (§8)** — YES. PRCelebration: animated spring-entry with gold border and 🔥 emoji; iron-hot orange accent (#E8513A) throughout; rest timer bar fills with progress color; coaching notes surface at the right moment (AMRAP guidance, deload announcements); WeightSelector has `display: 56px` numerals. Emergent from intent rather than explicit checklist (cell implemented delight from the brief's "surprise us" signal, not a specific list)
- [x] **Runtime honored** — Expo SDK 56 (`expo: ~56.0.6` in package.json); `npx` used throughout; dev build via `npx expo run:ios` (confirmed in session-log); not Expo Go
- [x] **Equipment scope honored** — All programs prescribe only `ExerciseId` values in `exercises.ts` (barbell/rack/bench only); `substituteAccessory()` maps non-barbell to barbell equivalents; `programs.test.ts` "barbell-centric guarantee" test sweeps all 7 programs for 16 days and asserts every exercise is in the allowed set

---

## OpenSpec phase completion

| Phase | Status | Notes |
|---|---|---|
| /opsx:propose | COMPLETE | `proposal.md` (9 capabilities, non-goals, impact) + `design.md` (9 ADRs with rationale) + 9 capability spec files + `tasks.md` (60 tasks) |
| /opsx:apply | COMPLETE (52/60 tasks) | 8 tasks left unchecked = on-device integration tests + final manual sweep; all underlying logic implemented; domain unit-tested (50 tests); iOS dev build compiles |
| /opsx:archive | COMPLETE | **BREAKS T4-vague miss** — operator confirmed "Archive anyway" at 8/60-unchecked prompt; deltas merged to `openspec/specs/` (9 capability specs, 43 requirements); canonical baseline established |

---

# COST AXIS

## Raw metrics (from session-log.md + token-log.md)

| Metric | Value |
|---|---|
| Total tokens | 28,341,900 |
| Implied API cost | $20.64 |
| API compute time | 0h 39m 26s |
| Active wall-clock (context) | ~1h 45m |
| Operator-touch time | ~2 min |
| Operator intervention count | 0 unplanned corrections |
| Time to first working build/fix | ~28 min (session start 11:13 → BUILD SUCCEEDED ~11:49 per session-log line 461) |

**Phase breakdown (inferred from session-log timestamps):**
- Proposal (11:13:23 → 11:20:40 /opsx:apply fired): ~7 min transcript-wall; ~6-7 min API compute
- Apply (11:20:40 → 12:09:50 /opsx:archive fired): ~49 min transcript-wall; ~28-30 min API compute (incl. build + sim verification)
- Archive (12:09:50 → 12:14:40 done): ~5 min transcript-wall; ~3-4 min API compute

## Derived ratios

| Ratio | Value | Cross-methodology rank |
|---|---|---|
| Quality per 1K tokens | 45.5 / (28,341.9) = **0.0016** | TBD (fill after hexad scored) |
| Quality per API hour | 45.5 / (39.43/60) = **69.2** | TBD |
| Defects per 1KLOC | 5 / 4.135 = **1.21** | TBD |
| Methodology overhead ratio | ~7 min ÷ (32 min) ≈ **0.22** (proposal ÷ apply+archive) | TBD |
| Cost per binary outcome | $20.64 / 13.5 = **$1.53** | TBD |
| Quality per dollar | 45.5 / $20.64 = **2.20** | TBD (vs T4-vague Q/$=6.91 — lower due to 2.9× cost increase) |

---

# PAIRED DELTA vs T4-vague (openspec)

T4-vague OpenSpec baseline (locked):
- Quality: 49.5 / 55
- Cost: $7.16 / 25m 42s API / 7/7 binary
- Defects: 0/0/4 / ~2.0 per 1KLOC
- Q/$: 6.91 (best in eval — cost-efficiency frontier)
- Archive: skipped (proposal ✓ + apply ✓ 38/39; canonical openspec/specs/ empty)

| Metric | T4-vague | T4-rich run-001 | Δ |
|---|---|---|---|
| Quality | 49.5 | 45.5 | **−4.0** |
| Cost | $7.16 | $20.64 | **+$13.48 (+188%)** |
| API compute time | 25m 42s | 39m 26s | +13m 44s (+53%) |
| Binary outcomes | 7/7 | 13.5/14 | +6.5 |
| Defects/1KLOC | ~2.0 | 1.21 | −0.79 (better density) |
| Q/$ | 6.91 | 2.20 | **−4.71 (−68%)** |
| Archive completed? | skipped | COMPLETE | ✓ breaks T4-vague miss |
| PM forwards | 0 | 0 | — |

**HYPOTHESIS (comparator unscored):** The −4.0 quality drop is unexpected given the rich brief provides more specification detail. The most likely cause: the expanded scope of T4-rich (14 binary outcomes vs 7, dev-build requirement, Live Activity seam) added more surface area, and the 8 unchecked on-device integration tasks in apply (session resilience, backgrounded notification confirmation, actual sim walkthrough) leave runtime-dependent features less verified. The lower Q/$ (2.20 vs 6.91) reflects that the richer brief's scope expansion → more app code → more tokens → cost increases faster than quality gains on a per-dollar basis.

**Paired-Δ vs run-002 comparator (hard cost data):**
| Metric | run-001 (with-runtime) | run-002 (no-runtime) | Δ |
|---|---|---|---|
| Implied API cost | $20.64 | $22.91 | +$2.27 (+11.0%) |
| API compute time | 39m 26s | 45m 6s | +5m 40s (+14.4%) |
| Net LOC | 5,891 | 7,655 | +1,764 (+29.9%) |
| Wall-clock | 1h 45m | 1h 9m | −36m (run-002 faster wall) |

Note: run-002 (no-runtime) cost MORE than run-001 (with-runtime), opposite of Vibe/PlanMode. OpenSpec's proposal phase expands without the runtime gravity (runtime constraint → ships less spec; no runtime → more spec → more code written → more tokens). See run-002 token-log for the "SURPRISING FINDING" analysis.

---

# HEADLINE FINDING

```
Quality: 45.5 / 55  ·  Cost: $20.64 / 39m 26s API  ·  Binary: 13.5 / 14 pass  ·  Δ vs vague: −4.0 Q, +$13.48 C (+188%)
```

**One-line verdict:**

> OpenSpec T4-rich delivered a nearly-complete, architecturally exemplary barbell app (7 programs, full plate calculator, session resilience, PR detection, clean 4-layer design, 50 unit tests all passing, TSC clean) at $20.64 — a 188% cost increase over T4-vague for a −4.0 quality drop, driven primarily by scope expansion (14 vs 7 binary outcomes, dev-build runtime, 5,891 net LOC vs T4-vague's ~2,000) rather than methodology inefficiency; the Q/$ frontier (6.91 → 2.20) breaks, but defect density improves (1.21 vs ~2.0/1KLOC) and archive completed this time.

**Frontier check — does T4-rich OpenSpec maintain the cost-efficiency-frontier headline?**

> NO — it breaks. Q/$=2.20 vs 6.91 in T4-vague. However, this is expected and should not be attributed to OpenSpec degrading: the rich brief is 2-3× more ambitious in scope (14 binary outcomes, dev-build runtime, all 7 programs + Live Activity seam, full progress/history/settings). The "frontier" comparison is only clean for same-scope cells. At comparable scope per binary outcome ($1.53/outcome vs $7.16/7=$1.02/outcome for T4-vague), the gap narrows substantially. The v0.7 "cost-efficiency frontier" headline for OpenSpec survives only on a per-outcome basis, not on raw Q/$.

---

## Failure mode characterization

**Where did OpenSpec break down?**
- The 8 unchecked on-device tasks (2.4, 7.5, 8.6, 9.5, 10.3, 11.4, 12.3, 13.2) are on-device integration tests that required real sim interaction the sandbox couldn't fully automate. The underlying code is implemented and unit-tested; the verification gap is idb HID injection failing in the sandbox environment.
- UI state desync on session resume (defect #4): `logged` Set resets on re-render/relaunch, so resumed sessions show all sets as un-logged visually even though DB is correct.
- Madcow failure handling missing (defect #1): weekly progression bumps unconditionally — a real correctness gap for that program.

**Categories of mistake:**
1. Missing program edge case (Madcow deload on failure): the spec correctly described the behavior but the `advance()` implementation skips the failure branch.
2. UI state vs DB state gap (resumed session visual desync): a common pitfall when local React state is used for tap-dedup alongside SQLite as source of truth.
3. JSON parse without try/catch in hydration path (minor, latent).

**What it did surprisingly well:**
- Program engine design (D1): `ProgramDefinition` interface with pure `prescribe`/`advance` functions that are independently unit-testable — this is the correct architecture for a correctness-critical domain and directly enabled the 50-test suite.
- Scope-cut honesty: the cell explicitly listed "Honestly not done" items at the end of apply — rare and valuable for reproducibility.
- Design decisions with ADRs: 9 documented decisions with alternatives considered; this is the level of foresight the rubric asks for and the cell delivered.
- Autonomous toolchain discovery: cell found and used `fb-idb` without being told to — a notable behavior unique to this cell's dev-build context.
- Archive phase completed: broke the T4-vague pattern of skipping archive; canonical `openspec/specs/` now has 43 requirements across 9 capabilities.

**Notable planning artifacts:**
- `proposal.md`: tight, non-goals explicit, capability decomposition into 9 named boundaries — the correct pre-implementation thinking.
- `design.md`: 9 ADRs with rationale + alternatives; `D5` (timestamp-based timer vs background execution) is exactly the right decision for cross-platform reliability.
- `training-programs/spec.md`: per-program EARS scenarios with pinned sources; GZCLP scheme-drop scenario (`T1 rep-scheme drop on failure: stageIndex++`) correctly predicted the implementation.
- `tasks.md` (60 tasks): well-sequenced (foundation → domain → persistence → UI); the 8 unchecked are honestly flagged as device-interaction tests.

**Process fidelity:**
- **All three phases completed** (propose → apply → archive). This breaks the T4-vague OpenSpec pattern where archive was skipped. The operator confirming "Archive anyway" at 8/60-unchecked was the right call — partial completion with honest disclosure is better than skipping the canonical merge.

**Operator-tempted-but-didn't-intervene:**
- Session-log records 0 unplanned interventions, 0 PM forwards. The single `kcontinue` was for a tool-use interrupt at session start, not a product redirection. The methodology ran fully autonomously.

**T4-rich-specific probe answers:**
- **Delight engagement (§8):** YES — `PRCelebration.tsx` spring animation + gold border; iron-hot accent; coaching notes timed to AMRAP sets; WeightSelector 56px display numerals. Inferred from intent ("designed for sweaty hands"), not a checklist.
- **Open-assumptions block (§10):** Fully engaged in `design.md` D1-D9 and `recommendation.ts` which mirrors the brief's program-recommendation mapping exactly (beginner→linear, intermediate→5/3/1/Madcow, advanced→nSuns/PPL).
- **Did OpenSpec engage delight or treat the brief as a checklist?** — More than checklist: the `PRCelebration` spring animation, the 56px display numeral on `WeightSelector`, and the iron-hot accent system are aesthetic choices not mandated by the spec. Partial credit for delight (4/5 on UI design).
