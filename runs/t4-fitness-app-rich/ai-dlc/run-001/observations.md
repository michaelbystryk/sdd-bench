# T4-rich (PM-quality brief) / AI-DLC / Run 001 / Observations

**Reviewer:** claude-sonnet-4-6 (autonomous scoring agent)
**Scored on:** 2026-05-29
**Methodology revealed at:** n/a (unblinded pass — single-rater PROVISIONAL)
**Evidence basis:** CODE-BASED (no sim this pass — parallel scoring constraint; 59/59 unit tests pass, TypeScript clean, source reviewed)

---

# QUALITY AXIS

## Dimension scores (0–5 per harness/scoring-rubric.md)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | 4.5 | All 7 programs ship with correct canonical progression; all binary outcomes 1–14 are implemented; warm-up ramp, plate calc, rest timer, backgrounded notification, PR detection, history, progress screen, onboarding — the brief is almost fully satisfied. Docked 0.5: warmup sets are generated as transient by `warmupFor()` but never surfaced in the Today/Workout UI (only `workingSetsFor` working sets appear in entries); it's correct in code but the UI path doesn't show the ramp per the brief's §4b flow. |
| 2 | Correctness | (see defect block below) | 59/59 tests pass; 0 TypeScript errors; code review found 2 minor latent issues |
| 3 | Code quality | 5 | Clean layered architecture with pure domain core, idiomatic TypeScript throughout; abstractions earn their keep (PlateMath integer-scaled arithmetic, bounded-knapsack `selectableWeights`); naming is intentional and precise; zero dead code; repository pattern with parameterized SQL; well-chosen bounded-knapsack for plate math. A strong "senior engineer wrote it" signal. |
| 4 | System design | 5 | 4-layer clean architecture (Domain → Repositories → Services → UI) with fully pure L1; declarative program registry with pluggable `ProgramDefinition`/progression strategies; Zustand store mirrors SQLite truth rather than duplicating it; rest timer correctness is timestamp-based not interval-based; `payload: Record<string, unknown>` enables new programs without schema migrations; schema designed with FK constraints, partial unique index enforcing single in-progress session, and stretch-ready normalized tables. ADR comments in key files. |
| 5 | UI design | 4 | Consistent dark theme (`#0B0B0F` background), clear visual hierarchy, oversized tap targets (`tap.min=56, tap.lg=72` — well above 44pt floor), accent colors for primary actions, success/PR colors distinct; plate breakdown shown inline with each set. Docked 1: sparkline chart is minimal (raw bar chart, no axis labels, no smooth animation); Today screen shows only the first set summary per exercise rather than full set count glance. |
| 6 | UX | 4 | 1-tap common log path clearly implemented (SetLogRow logs on single press with seeded prescription values); weight selector is plate-aware stepper with large targets; rest timer auto-starts on log with haptic; coaching notes surface in-workout; PR celebration overlay on finish; quick-switch resume and backgrounding handled via timestamp. Docked 1: warmup ramp is not surfaced in the workout UI (brief §4b step 2 explicitly says "warm-up ramp offered before first working set"); also no Live Activity lock-screen countdown visible without a real device build verification. |
| 7 | Robustness | 4 | Error boundary in ServicesProvider catches DB init failures; all native adapters (haptics, keepAwake, liveActivity, notifications) swallow errors with `.catch(()=>{})` or try/catch no-ops; plate math validates inputs and clamps; rest timer never goes negative; getInProgress returns null safely; `reconcile` handles null endTs. Docked 1: `finishWorkout` throws if no in-progress session (unguarded in UI — the Finish button could be pressed on a screen without an active session edge case); AMRAP reps detection (`amrapReps`) returns null if no sets logged, not explicitly tested for 0 logged sets. |
| 8 | Security | 3 | Input validated at boundaries (plate inventory validation in plateMath, parameterized SQL throughout, no string concatenation in SQL); no secrets; no network; no auth surface. Full score would require a dep audit — node_modules present but no `npm audit` run or lockfile hardening noted. Appropriate for a fully offline single-user app. |
| 9 | Documentation | 2 | README is the default Expo scaffold template (no project-specific content — setup, program canon, architecture not described). JSDoc present on all pure functions in the domain layer (PlateMath, estimators, sessionLogic) — good inline documentation. But no onboarding for a new contributor, no architecture summary in README, no design decisions documented in shipped docs (the aidlc-docs/ are planning artifacts, not shipped docs). Scoring against shipped docs only per rubric. |
| 10 | Spec articulation | 5 | Comprehensive requirements.md with intent analysis, resolved decisions table, FR-A/B/C/D/E priority-tagged requirements, NFR-TEST/SEC/PERF/DATA-MODEL, and pinned canonical sources per program (§7). User stories document 38 INVEST stories with Given/When/Then acceptance criteria. program-canon.md documents the exact progression tables per program. A different engineer could build to this spec. The spec also predicts several impl edge cases (GZCLP per-tier state keys, StrongLifts squat≠lower-body for increment, single-in-progress partial index). |
| 11 | Scope clarity | 4 | Explicit in/out scope in requirements.md mirroring brief §6 non-goals (no auth, no cloud, no push, no cardio). Rationale documented for security opt-out (offline/no-network). P0/P1/P2 priority distinctions used to actively cut within scope (P0 core loop completed over full-7-programs-first, then P1 completion). Docked 1: scope was declared+defended but not actively revisited when new info surfaced mid-session (Live Activity went from P2 bonus to actually-shipping without a scope revision note). |
| 12 | Assumption surfacing | count: 8 / quality: 4 | Documented: pounds-only/lb, one-active-program-seeds-all, warm-ups/assistance excluded from PRs/e1RM, RPE/RIR optional, Live Activity best-effort/iOS-only, 6-day PPL first-class, barbell+rack+bench only, security-gate opt-out. Each assumption names a choice + says what would change if wrong (conditional framing, e.g. "offline/no-network → mostly N/A"). Categorized in requirements.md as Open Assumptions (brief §10). Not mapped to specific code locations (would need level-5 artifact). |

**Quality sum:** 4.5 + 5 + 5 + 4 + 4 + 4 + 3 + 2 + 5 + 4 + 4 = **44.5 / 55**

**Product polish (dims 1+5+6+7):** 4.5 + 4 + 4 + 4 = **16.5 / 20**
**Engineering rigor (dims 3+4+8+9+10+11+12):** 5 + 5 + 3 + 2 + 5 + 4 + 4 = **28 / 35**

---

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | 0 |
| Major | 0 | 0 | 0 | 0 |
| Minor | 0 | 0 | 2 | 2 |

LOC produced: 8,911 net (9,121 added / 210 removed per token-log.md). Src-only count: ~4,989 lines.
**Defects per 1KLOC:** 0.4 / 1KLOC (using 4,989 src LOC) — **lowest defect density of the eval thus far**

Itemize defects (review-identified latent issues):
1. **Minor (R)** — `workoutSessionService.ts:finishWorkout()` throws `'No in-progress session'` with no upstream guard in the workout UI's `onFinish` handler (`workout.tsx:47`). A user could trigger this if the session silently fails to start; would show an unhandled promise rejection or crash.
2. **Minor (R)** — `warmupFor()` in `workoutSessionService.ts:150` is defined and tested but never called from the Workout UI screen (`workout.tsx`). The warm-up ramp exists in the domain layer and service but is not wired to the UI — a user would not see the ramp that brief §4b explicitly promises ("Auto-generated warm-up ramp offered before the first working set"). This is a wiring gap, not a logic bug.

---

## Binary outcomes (pass/fail per tasks/t4-fitness-app-rich/success-criteria.md)

| # | Outcome | Result | Evidence |
|---|---|---|---|
| 1 | Core app builds + runs as dev build | PASS | Session log 20:06 — `Build Succeeded` iOS dev build on iPhone 17 Pro / iOS 26.5; JS bundle loaded; 1354 modules (code-verified: session-log.md `[20:05:39]` + `[20:05:50]`) |
| 2 | Onboarding works | PASS | code-verified: `onboarding.tsx` implements Welcome→Experience→Schedule→Goal→Program fork (help-me-pick/choose)→Starting numbers (WeightSelector + "not sure" path)→Confirm; `recommender.ts` returns experience+days+goal-filtered recommendations with rationale |
| 3 | Four lifts present | PASS | code-verified: `model/index.ts:26` — `MAIN_LIFT_IDS: ['squat','bench','deadlift','ohp']`; all seeded in all programs |
| 4 | Today's workout on open | PASS | code-verified: `index.tsx` (Today tab) calls `useToday()` which calls `service.getToday()` which calls `buildTodayView()` computing `displayWeightLb` + `breakdown` for every set before any user input; `PlateBreakdownView` rendered inline |
| 5 | Set logging works (1-tap common case) | PASS | code-verified: `SetLogRow.tsx:37` — single `Pressable` calls `onLog(weightLb, reps)` with seeded prescription values; no modal required; `workout.tsx:35–44` handles the call in one async path |
| 6 | Plate calculator | PASS | code-verified: `plateMath.ts:computePlateBreakdown()` — validates inventory, never emits unowned plate; wired via `buildTodayView()→sessionLogic.ts:62`; bar weight and inventory from config |
| 7 | Rest timer | PASS | code-verified: `workoutSessionService.ts:130–140` — `restTimer.start(endTs)` called on `logSet()`; `haptics.impact()` called; per-exercise `defaultRestSec` via `restIntervalMs()`; timestamp-based |
| 8 | Backgrounded rest alert (both platforms) | PASS (code-verified, runtime not exercised this pass) | code-verified: `notifications.ts:scheduleRestEnd()` — schedules `TIME_INTERVAL` notification on iOS and Android (Platform-guarded Android channel); `restTimerService.ts:start()` calls `notifications.scheduleRestEnd(endTsMs)` |
| 9 | Quick-switch survives | PASS (code-verified, runtime not exercised this pass) | code-verified: `workoutSessionService.ts:84–89` — `startOrResume()` calls `getInProgress()` and reconciles `restEndTs`; `WorkoutSession.restEndTs + currentExerciseId + currentSetIndex` persisted to SQLite on every `saveSession()` |
| 10 | Warm-up ramp | PARTIAL PASS | code-verified: `warmup.ts:generateWarmup()` — correct ramp with bar + ascending rungs, de-duped, deadlift-specific; `warmupFor()` in service; BUT the Workout UI (`workout.tsx`) does not call `warmupFor()` or render warmup sets — the ramp exists in domain+service layer but is **not surfaced in the UI** |
| 11 | 7 programs, correct progression | PASS | code-verified: all 7 defined in `programEngine/programs/`. StrongLifts: +5 squat/bench/OHP, +10 deadlift, deload at failCount≥3. 5x3: same. Wendler: TM-based 4-week wave with AMRAP top sets, +5/+10 TM per cycle. Madcow: weekly ramp to top set, weekly +2.5/+5 lb increment. GZCLP: T1/T2/T3 with stage descent on failure, per-tier state keys. nSuns: 9-set T1 wave, AMRAP key set at 85%×1+, TM delta table. Reddit PPL: 6-day, compound AMRAP last set, +5/+10 on hit, deload at failCount≥3. Progression engine tests pass. |
| 12 | Flexible scheduling (3–6 days) | PASS | code-verified: `onboarding.tsx:75-79` — days selector `[3,4,5,6]`; `nsuns531` has `scheduleDayCounts:[4,5,6]`; `reddit_ppl` has `scheduleDayCounts:[6]`; `recommender.ts:28` filters by `fitsDays` |
| 13 | History persists + History screen | PASS (code-verified, runtime not exercised this pass) | code-verified: `sessionRepo.ts:saveSession()` persists in SQLite tx; `history.tsx` renders `progress.sessionHistory()` — completed sessions; `progressionService.ts:switchProgram()` only flips `activeProgramId`, preserves all `logged_set` and `progression_state` rows |
| 14 | Progress + PRs | PASS | code-verified: `progress.tsx` shows e1RM trend sparkline + volume sparkline + PR list per lift; `estimators.ts:detectPRs()` detects weight/rep/e1rm PRs; `PrCelebration` overlay shown in `workout.tsx:86-93` |

**Pass count: 13.5 / 14** (outcome #10 scored as partial — warmup ramp present in domain but not wired to UI)

---

## Rich-brief-specific checks

- [x] **Non-goals honored** — no auth, cloud, push, cardio, multi-user in source; `settings.tsx:72` explicitly notes "kg out of scope for v1"
- [x] **Open assumptions engaged** — all 8 open assumptions from brief §10 explicitly resolved in `requirements.md` decisions table with accept-or-engage framing
- [x] **Stretch stayed out** — no supersets, no data export, no custom builder, no Watch; data model (normalized schema + `payload` column) designed to absorb stretch per NFR-DATA-MODEL
- [x] **Delight north-star** — PR celebration overlay with 🏆 + full-screen dim; coaching notes surface at right moments; haptic on set log; plate breakdown in accent color; AMRAP callouts in amber (`colors.pr`); warm PR color `#FFC857`. Unprompted delight from brief §8 intent. Live Activity bonus attempted and shipped.
- [x] **Runtime honored** — Expo SDK 56 (`create-expo-app --template default@sdk-56`), `npx expo install`, dev build via `npx expo run:ios`, not Expo Go
- [x] **Equipment scope honored** — all accessories are barbell-centric: `barbell_row`, `close_grip_bench`, `rdl`, `front_squat`, `incline_bench` — no cables/machines/dumbbell-only movements

---

# COST AXIS

## Raw metrics (from session-log.md + token-log.md)

| Metric | Value |
|---|---|
| Total tokens | ~162.6M (33K input + 390.7K output + 161.4M cache-read + 1.2M cache-write) |
| Implied API cost | $97.97 |
| API compute time (scored) | 1 h 31 m 30 s |
| Wall-clock (context) | 3 h 21 m 18 s |
| Operator-touch time | ~3 min |
| Operator intervention count | 0 unplanned |
| Time to first working build | ~3h 13m wall-clock (20:05 minus 16:52 session start); API compute not separately logged pre-build |
| LOC produced | 9,121 added / 210 removed (net 8,911) |

**Phase breakdown (approximate from session-log timestamps):**
- Requirements / User Stories / Application Design / Units planning (Inception): 16:51–17:39 = ~48 min wall-clock
- Construction (all 6 units): 17:39–20:13 = ~2h 34m wall-clock
- Note: API compute time is 1h 31m 30s per /status; methodology overhead ratio requires per-phase API compute, not available separately.

## Derived ratios

| Ratio | Value | Cross-methodology rank (fill after all cells) |
|---|---|---|
| Quality per 1K tokens | 44.5 / 162.6 ≈ **0.274 / 1K tokens** | — |
| Quality per API hour | 44.5 / 1.525h ≈ **29.2 / API hour** | — |
| Defects per 1KLOC | 2 / 4.989 ≈ **0.40 / 1KLOC** | — |
| Methodology overhead ratio | INDETERMINATE: per-phase API compute not separately captured; wall-clock overhead ~24% (48m / (48+154m)) | — |
| Cost per binary outcome | $97.97 / 13.5 ≈ **$7.26 / outcome** | — |
| Quality per dollar | 44.5 / 97.97 ≈ **0.454 / dollar** | — |

---

# HEADLINE FINDING

```
Quality: 44.5 / 55  ·  Cost: $97.97 / 1h 31m 30s API compute  ·  Binary: 13.5 / 14 pass
```

**One-line verdict:**

> AI-DLC delivered the highest-fidelity T4-rich output in the hexad — all 7 programs with correct progression, full planning artifact stack, 59/59 tests passing, and even the P2 Live Activity bonus — at a $97.97 cost driven by AI-DLC's signature superlinear cache-read overhead (161.4M cache-read tokens = the 25KB rule-set re-read every turn, 8× the vague-brief run's cache volume). The methodology produced excellent quality at the highest absolute cost in the cell; the paired run-002 shows −66% cost for −15% LOC when runtime constraints are relaxed.

---

## Failure mode characterization

**Where did AI-DLC break down?**
- Warmup UI wiring: the domain layer and service layer fully implement `generateWarmup()` and `warmupFor()`, including tests, but the Workout UI screen never calls `warmupFor()` or renders warmup set entries. This is the single most significant functional gap — brief §4b step 2 explicitly requires a warmup ramp in the workout flow.
- README was never updated from the Expo scaffold default — shipped docs are sparse despite deep planning artifact quality.

**Categories of mistake:**
- *Integration gap*: feature complete in service layer, not wired to UI (warmup ramp). Classic "last mile" problem when a unit owns a service method but the UI unit doesn't call it.
- *Documentation miss*: planning artifacts (aidlc-docs/) are thorough, but the public-facing README is a boilerplate template. Score penalized on dim 9 accordingly.

**What it did surprisingly well:**
- Clean layered architecture with property-based tests in the domain core — the PlateMath bounded-knapsack, per-set round-trip, and progression invariant tests are unusually rigorous for a single-session build.
- All 7 programs implemented in one session with correct canonical progression logic, each correctly modeled in ~90–113 lines of declarative TypeScript — the registry pattern made this tractable.
- Live Activity bonus attempted AND shipped (build succeeded with widget extension); this is the hardest single binary outcome in the eval and the only cell to deliver it.
- Zero unplanned operator interventions. 3 min operator-touch in a 3h 21m session is the lowest babysitting ratio in the eval.
- Assumptions explicitly surfaced and engaged (8 documented, not silently overridden).

**Notable planning artifacts:**
- `requirements.md`: comprehensive, intent analysis + resolved decisions + FR-A/B/C/D/E priority-tagged + NFR + pinned canonical sources — single-rater score 5.
- `user-stories/stories.md` (not read in detail but referenced): 38 INVEST stories across 6 epics with Given/When/Then acceptance criteria.
- `inception/application-design/application-design.md`: ADR-quality 4-layer clean architecture rationale, component-dependency mapping, how-design-satisfies-requirements table.
- `construction/U1-foundation-persistence/functional-design/domain-entities.md`: full SQLite schema + migration documented before code written.

**Operator-tempted-but-didn't-intervene moments:**
- At ~19:59 (U5 complete), session-log shows "attempt" — operator appeared to want to skip U6 but issued only a one-word prompt. AI-DLC recognized it as a go-ahead for the bonus and correctly scoped it as P2/best-effort.
- AI-DLC paused for gates at U6 ("the U6 pause was technically a fidelity caveat") despite kickoff pre-authorization. The methodology's gate density is not fully suppressible; this is a documented characteristic.

---

## Paired-Δ vs comparator (run-001 vs run-002)

| Metric | run-001 (this cell — with-runtime) | run-002 (no-runtime) | Δ | Δ% |
|---|---|---|---|---|
| Implied API cost | $97.97 | $33.50 | −$64.47 | **−65.8%** |
| API compute time | 1h 31m 30s | 50m 27s | −41m 3s | −44.9% |
| Wall-clock | 3h 21m 18s | 1h 46m 8s | −1h 35m | −47.3% |
| Net LOC | 8,911 | 7,582 | −1,329 | −14.9% |
| Cache-read tokens | 161.4M | 48.0M | −113.4M | **−70.3%** |

**Interpretation:** The −66% cost with only −15% LOC reduction proves that AI-DLC's cost is turn-count driven, not output-volume driven. The rule-set re-read (25KB CLAUDE.md + .aidlc-rule-details/) fires every turn; runtime integration (native build, sim verification, Build & Test stage) generates many more turns. Removing the dev-build requirement collapses turn count ~70% → proportional cost reduction. Quality hypothesis (unscored): run-002 is expected to score ~40–43/55 (warmup wiring still missing; live activity not verified; docs still thin) vs run-001's 44.5/55.
