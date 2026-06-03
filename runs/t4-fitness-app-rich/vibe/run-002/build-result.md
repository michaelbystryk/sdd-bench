# T4-rich (PM-quality brief) / Vibe Claude Code / Run 002 / Build Result

**Scored on:** 2026-05-29 · **Scorer model:** claude-sonnet-4-6 · **Evidence basis: CODE-BASED (no sim this pass)**

> **No-runtime variant.** Cell did NOT build or run the app (brief §7 constraint honored per session-log.md). Verification is source-review + tests-only. The 14 runtime-dependent binary outcomes from the original T4-rich success-criteria.md do NOT apply here; the design-verifiable set (brief-no-runtime.md §9) is used instead.

## Build sanity (timeboxed, best-effort)

| Check | Result | Evidence |
|---|---|---|
| `npx tsc --noEmit` | **PASS (exit 0, no output)** | code-verified: run against `~/dev/strength-app-vibe-002-builds/vibe-run-002` |
| `npm test` | **PASS — 124 tests, 13 suites** | code-verified: all tests pass in 0.985s |
| `node_modules` present | Yes | installed |

## Design-verifiable outcomes (per `brief-no-runtime.md` §9)

### Domain logic (unit-testable, primary)
- [x] **All 7 programs prescribe + progress per pinned canon** — `tests/domain/programs.test.ts` covers shared invariants (all 7) + per-program canon assertions for 5×5, 5/3/1 (TM bump / hold / deload), GZCLP (T1/T2/T3 cascade), nSuns (reps→TM-increase table), Madcow (weekly bump distribution), PPL (6-day rotation + no double-progress on Legs B). 5/3/1 holds TM on miss but has no deload trigger (failures counter tracked but not acted on — see Major defect #2 in observations.md)
- [x] **Plate calculator (per-side breakdown, respects bar weight + inventory)** — `computePlateLoad` in `plates.ts`; `tests/domain/plates.test.ts` verifies inventory constraint ("never suggest a plate not owned"), achievedWeight when exact is false
- [x] **Warm-up ramp (auto-generated, excluded from PRs/progression)** — `generateWarmup` (warmup.ts) produces sets typed `warmup`; `isPRCandidate` (pr.ts:37) explicitly excludes `isWarmup` sets; `tests/domain/warmup.test.ts` passes
- [x] **e1RM (Epley) + PR detection (weight / reps / e1RM, main working sets only)** — `epley`/`estimatedOneRepMax` (e1rm.ts); `detectPRs`/`detectWorkoutPRs` (pr.ts); `tests/domain/e1rm.test.ts`, `tests/domain/pr.test.ts` pass
- [x] **Auto-populate (today's set from last time)** — `autoPopulateWorkout` (autopopulate.ts) seeds from `prescription.weight` + `lastByKey[setKey]`; `tests/domain/autopopulate.test.ts` passes
- [x] **Workout advances on completion (not by calendar date)** — `dayIndex` advances only in `applyResults` (called from `completeWorkout`); `getInProgress()` resumes instead of advancing; `tests/domain/rotation.test.ts` + `tests/services/workoutFlow.test.ts:46–53` pass

### Code structure (source-reviewable, primary)
- [x] **Onboarding flow (§4a)** — 7 screens: `app/onboarding/index.tsx` (welcome) · `experience.tsx` · `schedule.tsx` · `goal.tsx` · `program.tsx` ("Help me pick" returns scored recommendations with one-line why; "I'll choose" shows all 7) · `numbers.tsx` (WeightSelector + 1RM/5RM mode + "not sure — use defaults") · `confirm.tsx`. State wired via `useOnboardingStore`; routing via `expo-router`
- [x] **Today's workout screen + components wired to domain** — `today.tsx` calls `previewToday()` (no write on preview); shows `display.prescription.label`, per-exercise weight (40px display numeral), and `PlateLoad` inline without user input
- [x] **Set logging (1-tap common case visible in code)** — `SetRow.tsx:63–66` single Pressable: `onPress={draft.completed ? onUnlog : onLog}`; draft seeded from prescription weight/reps by `autoPopulateWorkout`; confirming is one tap on the log button
- [x] **Rest timer (service/hook/component + per-exercise intervals + haptic)** — `restTimer.ts` (timestamp-based pure math); `useRestTimerTick.ts` (AppState 'active' handler + 500ms interval); `RestTimerBar.tsx` (progress fill + +30/−15 controls); haptics called at `useWorkoutStore.ts:95` (`tapLogged`) and `restComplete()` in `onRestComplete`
- [x] **Backgrounded rest (notification scheduling + cancellation)** — `notifications.ts:51–68` (`scheduleRestEndNotification` → `TIME_INTERVAL` trigger); called from `useWorkoutStore.startRest:121`; `cancelRestEndNotification` called in `onRestComplete` and `stopRest`. Both iOS channel config and Android channel config present
- [x] **Quick-switch resilience (state hydration / persistence paths)** — `workoutService.resolveToday:67–113` checks `getInProgress()` first; `saveProgress` called on every `logSet`; cold-start test (`workoutFlow.test.ts:69–79`) verifies set survival across service restart
- [x] **Live Activity (best-effort: stub/scaffold)** — `src/services/liveActivity.ts` (JS shim with no-op `startRestActivity`/`endRestActivity`); `targets/RestTimerWidget/RestTimerAttributes.swift` + `RestTimerLiveActivity.swift` (Swift scaffold); `plugins/withRestTimerLiveActivity.js` (config plugin sets `NSSupportsLiveActivities`). Not wired to the rest-timer flow (deliberate best-effort)
- [x] **History persistence (SQLite schema + migration + repo code)** — `schema.ts` defines `sessions` / `logged_sets` / `pr_records` / `pr_snapshots` tables with indexes; `sqlite.ts:114–151` (`SqliteSessionRepository`) + `SqliteSetRepository`; `switchProgram` only updates `activeProgramId` (no deletes); `tests/services/workoutFlow.test.ts:104–124` verifies "switching programs preserves all logged history"
- [x] **Progress / PR detection UI components** — `progress.tsx` with `summarizeExercise` + `TrendBars` + `StatCard` for 4 main lifts; `PRCelebration.tsx` modal with gold PR border + trophy; `components/charts.tsx`

### Engineering hygiene (verifiable)
- [x] **`tsc --noEmit` is clean** — PASS (exit 0, no errors)
- [x] **`npm test` passes** — PASS: 124 tests, 13 suites, 0 failures
- [x] **Non-goals honored** — no `user` table in schema; no push-notification code (only local); no cardio/nutrition domain types; exercise catalog has no machine/cable/dumbbell IDs; no multi-user surface. `code-verified: schema.ts, exercises.ts, notifications.ts`

### No-runtime constraint adherence (the key fidelity check)
- [x] **Cell did NOT run forbidden commands** — session-log.md confirms: no `expo run:ios` / `expo run:android` / `expo prebuild` / `xcodebuild` / `pod install` / `expo start` / `xcrun simctl` / `idb`. Only `npm install` + `npx tsc --noEmit` + `npx jest` + `npx eslint` used (all allowed)
- [x] **Cell wrote full UI code (components + screens)** — 9 screens (`app/**`) + 9 components (`src/components/**`) + 4 state files. NOT narrowed to domain-only like Spec Kit run-001
- [x] **Cell's planning artifacts acknowledged no-runtime scope** — README top-level callout: "This sprint is source + tests only — no runtime." HANDOFF.md clearly delineates deferred behaviors with pass conditions

## Source listing

`tree -L 3` summary (post-cell, excludes node_modules/.expo/.git):

```
vibe-run-002/
├── app/
│   ├── _layout.tsx         # Root layout (boot, navigation, notification config)
│   ├── index.tsx           # Route gate (onboarding vs today)
│   ├── (tabs)/             # history.tsx, progress.tsx, settings.tsx, today.tsx, _layout.tsx
│   └── onboarding/         # index, experience, schedule, goal, program, numbers, confirm, _layout
├── app/workout/[sessionId].tsx  # Active workout screen
├── src/
│   ├── domain/             # types, plates, e1rm, pr, warmup, autopopulate, rotation, progress, recommendation, workout, exercises, units, index
│   │   └── programs/       # fiveByFive, fiveByThree, fiveThreeOne, madcow, gzclp, nsuns, redditPPL, linear (shared), helpers, seeding, types, registry
│   ├── db/                 # types (ports), schema, migrations, sqlite (adapters), memory (in-memory), client
│   ├── services/           # workoutService, restTimer, notifications, haptics, keepAwake, liveActivity (shim), onboarding
│   ├── state/              # services, useSettingsStore, useWorkoutStore, useOnboardingStore
│   ├── hooks/              # useRestTimerTick
│   ├── components/         # WeightSelector, PlateLoad, SetRow, RestTimerBar, PRCelebration, CoachingNote, OnboardingStep, charts, ui
│   └── theme/              # theme.ts (colors, spacing, radii, TAP_TARGET=56, typography)
├── tests/
│   ├── domain/             # 11 test files (plates, e1rm, pr, warmup, autopopulate, rotation, units, programs, recommendation, workout, progress)
│   └── services/           # workoutFlow.test.ts, restTimer.test.ts
├── targets/RestTimerWidget/ # Swift Live Activity scaffold
├── plugins/                # withRestTimerLiveActivity.js (config plugin)
├── docs/
│   ├── ASSUMPTIONS.md      # Brief §10 assumptions engaged + non-obvious decisions
│   └── HANDOFF.md          # Platform-team follow-up sprint checklist
├── README.md               # Setup + verify + architecture + 7-program table
├── app.json                # Expo SDK 56 pinned
├── package.json            # Dependencies pinned
├── tsconfig.json
├── babel.config.js
├── jest.setup.ts
└── eslint.config.js

Total: 66 TS/TSX source files + 13 test files (per session-log.md)
Measured LOC: ~7,384 (src + app + tests), ~6,273 (src + app only)
Net LOC per token-log: 8,097
```

## Setup nudges
None — cell ran without any operator product interventions (2 socket-error resumes only, which are infrastructure noise).
