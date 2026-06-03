# T4-rich (no-runtime) / openspec / Run 002 / Build Result

**Scored on:** 2026-05-29 · **Scorer model:** claude-sonnet-4-6 · **Evidence basis:** CODE-BASED (no sim this pass)

> **No-runtime variant.** Cell did NOT build or run the app. Verification is source-review + tests-only. The 14 runtime-dependent binary outcomes from run-001 do NOT apply here; the design-verifiable outcomes from `brief-no-runtime.md` §9 are used instead.

## Build sanity (timeboxed, code-based)

| Check | Result | Detail |
|---|---|---|
| `npx tsc --noEmit` | **PASS** (exit 0) | Clean across domain, data, services, state, components, all Expo Router screens |
| `npm test` | **PASS** (exit 0) | 100/100 tests, 8 suites, 0.552s |
| ESLint | 0 errors (from session-log) | 12 warnings (acceptable; all from react-hooks perf-advisory rules, appropriately suppressed in eslint.config.js) |

## Design-verifiable outcomes (per `brief-no-runtime.md` §9)

### Domain logic (unit-testable, primary)
- [x] All 7 programs prescribe + progress per pinned canon — verified via unit tests — `tests/programs.test.ts` covers 5×5, 5×3, 5/3/1, Madcow, GZCLP, nSuns, PPL with set/rep/percentage/progression assertions; 100/100 PASS
- [x] Plate calculator (per-side breakdown, respects bar weight + inventory) — `tests/plates.test.ts` PASS; greedy-heaviest-first algorithm with achievable-sum enumeration; closest-loadable-at-or-below fallback
- [x] Warm-up ramp (auto-generated, excluded from PRs/progression) — `src/domain/metrics/warmup.ts`; kind='warmup' flows through `countsTowardMetrics()` exclusion in `e1rm.ts:15`
- [x] e1RM (Epley) + PR detection (weight / reps / e1RM, main working sets only) — `tests/metrics.test.ts` PASS; `detectPRs()` in `src/domain/metrics/pr.ts` guards on `countsTowardMetrics()`
- [x] Auto-populate (today's set from last time) — `src/domain/session/logging.ts::seedDraft()` uses `last` from `store.lastWorkingSet()`; `src/state/workoutEngine.ts::autoPopulate()`
- [x] Workout advances on completion (not by calendar date) — cursor advanced only in `advance()` called from `finishWorkout()`; `prescribe()` is a pure function with no `Date.now()` in domain

### Code structure (source-reviewable, primary)
- [x] Onboarding flow (§4a) screens + routing + state machine — `app/onboarding.tsx` (7-step wizard), `src/state/onboarding/machine.ts` (pure reducer, `canProceed()`, `buildSeedInput()`)
- [x] Today's workout screen + components wired to domain — `app/(tabs)/today.tsx`; `PlateBreakdown` component receives precomputed `topWeight`; working weight shown without user input
- [x] Set logging (1-tap common case visible in code) — `src/components/SetRow.tsx`; single `Pressable` → `onLog()`; no modal, no confirmation
- [x] Rest timer (service/hook/component + intervals + haptic) — `src/services/restTimer.ts` (timestamp math), `restTimerController.ts` (lifecycle), `src/components/RestTimerBar.tsx`, `restIntervalSec()` table
- [x] Backgrounded rest (notification scheduling code) — `restTimerController.ts::onBackground()` schedules via `notifications.schedule({fireAt: endsAt(timer)})`; `onForeground()` cancels; `AppProvider.tsx` wires AppState listener
- [x] Quick-switch resilience (state hydration code paths) — `useToday` reads from SQLite on cold render; in-progress session persisted via `createInProgressSession()`; `AppProvider` AppState listener drives timer lifecycle
- [x] Live Activity (best-effort: stub/scaffold acceptable) — `plugins/withRestTimerLiveActivity.js` (sets `NSSupportsLiveActivities`, documents handoff); `plugins/RestTimerWidget/RestTimerLiveActivity.swift` (ActivityKit shape); explicitly labeled scaffold-only
- [x] History persistence (SQLite schema + migration + repo code) — `src/data/migrations.ts` (2 versioned migrations); `store.setActiveProgram()` switches without deleting history; `session_sets.exercise_id` is program-independent
- [x] Progress / PR detection UI components — `src/components/PRCelebration.tsx`; `app/(tabs)/progress.tsx` (e1RM sparklines, volume/tonnage, PR history); `app/(tabs)/history.tsx` (browsable session list)

### Engineering hygiene (verifiable)
- [x] `tsc --noEmit` clean — exit 0 (code-verified by running `npx tsc --noEmit` in cell directory)
- [x] `npm test` passes — 100/100 tests, exit 0 (code-verified)
- [x] Non-goals honored — no auth/cloud/sync/social/push/cardio/nutrition/multi-user found in `src/` or `app/`; grep confirmed clean

### No-runtime constraint adherence (the key fidelity check)
- [x] Cell did NOT run `npx expo run:ios` / `xcodebuild` / `pod install` / `xcrun simctl` / `idb` / `fb-idb` / `expo start` — confirmed from session-log.md transcript (no such tool invocations)
- [x] Cell wrote full UI code (components + screens) — 7 screens (index, onboarding, _layout, (tabs)/_layout, today, progress, history, settings, workout) + 7 components + hooks/state all present
- [x] Cell's planning artifacts acknowledged the no-runtime scope — design.md §Context: "Critical constraint — verification scope: this sprint delivers source + tests only"; proposal.md notes "no runtime" explicitly

## Setup nudges

None — 0 unplanned operator interventions per token-log.md. The `opsx:archive` step asked one clarifying question about spec sync (methodology-internal, not a product intervention).

## Source listing

```
openspec-run-002/
├── app/
│   ├── _layout.tsx           Root layout (AppProvider + Stack)
│   ├── index.tsx             Onboarded gate (redirects)
│   ├── onboarding.tsx        7-step onboarding wizard
│   ├── workout.tsx           In-workout log screen
│   └── (tabs)/
│       ├── _layout.tsx       Bottom tab bar
│       ├── today.tsx         Today's prescription screen
│       ├── progress.tsx      e1RM trend + PR history
│       ├── history.tsx       Browsable session history
│       └── settings.tsx      Program switch, inventory, bar weight
├── src/
│   ├── domain/
│   │   ├── types.ts          Core domain types (pure TS)
│   │   ├── units.ts          Weight rounding utilities
│   │   ├── index.ts          Barrel export
│   │   ├── equipment/
│   │   │   ├── types.ts      BarConfig, PlateInventory
│   │   │   └── plates.ts     Plate calculator + WeightSelector math
│   │   ├── exercises/
│   │   │   └── catalog.ts    Barbell exercise catalog + substitution map
│   │   ├── metrics/
│   │   │   ├── e1rm.ts       Epley formula + countsTowardMetrics
│   │   │   ├── pr.ts         PR detection (3 types, working-only)
│   │   │   ├── volume.ts     Volume/tonnage/intensity summary
│   │   │   └── warmup.ts     Warm-up ramp generator
│   │   ├── programs/
│   │   │   ├── types.ts      ProgramDefinition + ProgressionStrategy interface
│   │   │   ├── builders.ts   Set builder helpers
│   │   │   ├── common.ts     Shared utilities (roundWeight, linearIncrement, etc.)
│   │   │   ├── fiveByFive.ts StrongLifts 5×5
│   │   │   ├── fiveByThree.ts 5×3 linear variant
│   │   │   ├── fiveThreeOne.ts Wendler 5/3/1 + BBB
│   │   │   ├── madcow.ts     Madcow 5×5 weekly ramp
│   │   │   ├── gzclp.ts      GZCLP T1/T2/T3 cascade
│   │   │   ├── nsuns.ts      nSuns 9-set + AMRAP→TM
│   │   │   ├── ppl.ts        Reddit PPL 6-day
│   │   │   ├── registry.ts   Program registry + getStrategy()
│   │   │   ├── recommend.ts  Program recommendation engine
│   │   │   └── seed.ts       Seed all programs at onboarding
│   │   └── session/
│   │       ├── logging.ts    LogDraft, seedDraft, commitDraft
│   │       └── rotation.ts   Rotation utilities
│   ├── data/
│   │   ├── db.ts             Database interface (get/all/run/exec/transaction)
│   │   ├── migrations.ts     2 versioned migrations (PRAGMA user_version)
│   │   ├── store.ts          Repository layer (all SQL here)
│   │   └── adapters/
│   │       ├── expoSqlite.ts Expo-backed Database implementation
│   │       └── nodeSqlite.ts node:sqlite-backed Database (tests)
│   ├── services/
│   │   ├── interfaces.ts     Clock/Haptics/Notifications/KeepAwake interfaces
│   │   ├── fakes.ts          Test fakes for all service interfaces
│   │   ├── restTimer.ts      Timestamp-based rest math + interval table
│   │   ├── restTimerController.ts Lifecycle orchestration (bg/fg/haptic/notification)
│   │   └── expo/
│   │       └── index.ts      Expo-backed service implementations
│   ├── state/
│   │   ├── AppProvider.tsx   React context + AppState resilience wiring
│   │   ├── hooks.ts          useOnboarding, useToday, useLogging, useRestCountdown
│   │   ├── workoutEngine.ts  Orchestration (resolveToday/startToday/logDraft/finish)
│   │   └── onboarding/
│   │       └── machine.ts    Pure onboarding reducer + canProceed + buildSeedInput
│   └── components/
│       ├── theme.ts          Design tokens (colors, spacing, radius, typography, TAP_TARGET)
│       ├── ui.tsx            Screen, Card, PrimaryButton, OptionTile primitives
│       ├── WeightSelector.tsx Plate-aware ± stepper (TAP_TARGET+24 buttons)
│       ├── PlateBreakdown.tsx Per-side plate display
│       ├── SetRow.tsx        One-tap set logger
│       ├── RestTimerBar.tsx  Rest countdown progress bar
│       └── PRCelebration.tsx PR display with gold border
├── plugins/
│   ├── withRestTimerLiveActivity.js  Config plugin scaffold (NSSupportsLiveActivities)
│   └── RestTimerWidget/
│       └── RestTimerLiveActivity.swift  ActivityKit widget scaffold
├── tests/
│   ├── catalog.test.ts       Exercise catalog + substitution tests
│   ├── plates.test.ts        Plate calculator correctness
│   ├── metrics.test.ts       e1RM, PR detection, volume, warm-up
│   ├── programs.test.ts      All 7 programs prescription + progression
│   ├── onboarding-logic.test.ts Onboarding machine, recommendations, seeding
│   ├── persistence.test.ts   SQLite integration (node:sqlite adapter)
│   ├── restTimer.test.ts     Timestamp math + controller lifecycle
│   └── state.test.ts         Workout engine + full session flow
├── docs/
│   └── FOLLOWUP-SPRINT-HANDOFF.md  Architecture map + pinned sources + assumptions
├── openspec/
│   ├── changes/archive/2026-05-29-compound-strength-app/
│   │   ├── proposal.md       Why + what changes + 11 capabilities
│   │   ├── design.md         8 decisions with rationale + alternatives
│   │   ├── tasks.md          78/78 tasks (all [x])
│   │   └── specs/            11 capability delta specs (54 requirements, 87 scenarios)
│   └── specs/                11 main specs (synced from delta at archive)
├── README.md
├── app.json                  Expo SDK 56, typedRoutes disabled (no runtime to gen)
├── package.json              SDK-56-pinned deps
├── tsconfig.json
├── jest.config.js            ts-jest + node:sqlite env
├── babel.config.js
└── eslint.config.js
```

**Net LOC:** 7,655 added / 50 removed (from token-log.md)
**Test coverage:** 100 tests across 8 suites; all domain logic (programs, plate calc, e1RM/PR, rest timer, persistence, onboarding machine, workout engine) covered
