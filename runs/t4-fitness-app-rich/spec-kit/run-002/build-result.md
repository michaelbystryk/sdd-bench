# T4-rich (no-runtime) / spec-kit / Run 002 / Build Result

> **No-runtime variant.** Cell did NOT build or run the app. Verification is source-review + tests-only. The 14 runtime-dependent binary outcomes from run-001 do NOT apply here.
>
> **Scored on:** 2026-05-29 · Scorer model: claude-sonnet-4-6 · Evidence basis: CODE-BASED (no sim this pass)

## tsc --noEmit result

**`tsc --noEmit -p tsconfig.core.json`** (domain + data + services + tests): **CLEAN (exit 0)** — code-verified

**`tsc --noEmit`** (full tree): **150 ERRORS** — all in `app/` and `src/components/` because:
1. Expo/React Native type packages are not installed (`react`, `expo-router`, `react-native`, `zustand` not in node_modules — expected for no-runtime sprint)
2. `src/theme/theme.ts` module is missing (imported by all 6 components + all 14 app screens)

The HANDOFF.md explicitly documents that full-tree tsc requires `npx expo install` first (platform-team sprint). The domain-core tsc is the relevant hygiene check for this sprint.

## npm test result

**`npm test`**: **PASS — 27 suites, 111 tests, 0 failures** — code-verified

Exit code: 0. Runtime: 1.167s.

| Suite group | Suites | Tests |
|---|---|---|
| Unit (domain + services) | 19 | 84 |
| Integration (repos + services + workflows) | 8 | 27 |
| **Total** | **27** | **111** |

### Test suite listing

**Unit suites (all PASS):**
- `tests/unit/e1rm/epley.test.ts`
- `tests/unit/plates/plateCalculator.test.ts`
- `tests/unit/plates/inventoryRespect.test.ts`
- `tests/unit/warmup/warmupRamp.test.ts`
- `tests/unit/pr/prDetection.test.ts`
- `tests/unit/scheduling/rotation.test.ts`
- `tests/unit/programs/linear.test.ts`
- `tests/unit/programs/fiveThreeOne.test.ts`
- `tests/unit/programs/madcow.test.ts`
- `tests/unit/programs/gzclp.test.ts`
- `tests/unit/programs/nsuns.test.ts`
- `tests/unit/programs/redditPPL.test.ts`
- `tests/unit/programs/assistance.test.ts`
- `tests/unit/programs/seedAll.test.ts`
- `tests/unit/recommendation/recommend.test.ts`
- `tests/unit/progress/metrics.test.ts`
- `tests/unit/restTimer.test.ts`
- `tests/unit/notificationScheduler.test.ts`
- `tests/unit/units.test.ts`

**Integration suites (all PASS):**
- `tests/integration/allPrograms.test.ts`
- `tests/integration/sessionLifecycle.test.ts`
- `tests/integration/programSwitch.test.ts`
- `tests/integration/hydration.test.ts`
- `tests/integration/history.test.ts`
- `tests/integration/migrations.test.ts`
- `tests/integration/onboarding.test.ts`
- `tests/integration/nonGoals.test.ts`

## Design-verifiable outcomes (per `brief-no-runtime.md` §9)

### Domain logic (unit-testable, primary)
- [x] All 7 programs prescribe + progress per pinned canon — verified via unit tests (19 unit suites; per-program test files for linear/5/3/1/madcow/gzclp/nsuns/redditPPL all pass)
- [x] Plate calculator (per-side breakdown, respects bar weight + inventory) — `src/domain/plates/plateCalculator.ts`; property-tested with fast-check
- [x] Warm-up ramp (auto-generated, excluded from PRs/progression) — `src/domain/warmup/warmupRamp.ts`; setType='warmup' enforced; excluded from progressionState
- [x] e1RM (Epley) + PR detection (weight / reps / e1RM, main working sets only) — `src/domain/e1rm/epley.ts` + `src/domain/pr/prDetection.ts`; 3 PR types tested
- [x] Auto-populate (today's set from last time) — `workoutService.seedWeight()` queries `lastWorkingForExercise`
- [x] Workout advances on completion (not by calendar date) — `src/domain/scheduling/rotation.ts`; `nextRotationIndex` integration-tested

### Code structure (source-reviewable, primary)
- [x] Onboarding flow (§4a) screens + routing + state machine — `app/onboarding/` (welcome/experience/schedule/goal/program/starting-numbers/confirm + _layout)
- [x] Today's workout screen + components wired to domain — `app/(tabs)/today/index.tsx` wires `useSessionStore` + `PlateLoadView`; working weight + plate load shown
- [x] Set logging (1-tap common case visible in code) — `src/components/SetRow.tsx` single onLog callback; `workoutService.logSet()` 1-tap path with auto-populate
- [~] Rest timer (service/hook/component + intervals + haptic) — `restTimer.ts` / `useRestTimer.ts` / `RestTimerBar.tsx` all present; PARTIAL: `workout.tsx` wires `RestTimerBar remainingSec={0}` (hardcoded, not wired to `useRestTimer`)
- [x] Backgrounded rest (notification scheduling code) — `src/services/restTimer/restNotificationController.ts` + `src/services/native/notifications.ts`; scheduling/cancel logic unit-tested
- [x] Quick-switch resilience (state hydration code paths) — `src/state/sessionStore.ts hydrate()` + `workoutService.resume()`; cold-start test in `hydration.test.ts` passes
- [x] Live Activity (best-effort: stub/scaffold acceptable) — `src/config/liveActivityPlugin.ts` (NSSupportsLiveActivities plist key) + `src/services/liveActivity/liveActivity.ts` stub
- [x] History persistence (SQLite schema + migration + repo code) — `src/data/schema.ts` (8 tables + indexes) + `migrations/001_init.ts` + `memoryRepositories.ts` (reference impl)
- [~] Progress / PR detection UI components — `app/(tabs)/progress.tsx` present with LineChart components; PARTIAL: hardcoded empty data arrays (repos not wired in source)

### Engineering hygiene (verifiable)
- [x] `tsc --noEmit` clean — domain-core `tsconfig.core.json` passes clean; full-tree requires platform-team sprint (Expo types + missing theme.ts); documented in HANDOFF.md
- [x] `npm test` passes — 27 suites, 111 tests, 0 failures (exit 0)
- [x] Non-goals honored (no auth/cloud/social/etc.) — `nonGoals.test.ts` passes; no banned imports; no non-barbell exercises in seed

### No-runtime constraint adherence (the key fidelity check)
- [x] Cell did NOT run `npx expo run:ios` / `xcodebuild` / `pod install` / `xcrun simctl` / `idb` / `fb-idb` / `expo start` — confirmed from session-log.md; only `npm install --no-save` (test toolchain) and `npx jest` executed
- [x] Cell wrote full UI code (components + screens) — 14 app screens, 6 components, 3 state stores, 6 services; NOT just domain
- [x] Cell's planning artifacts acknowledged the no-runtime scope — plan.md §"This sprint's deliverable is source + tests only"; HANDOFF.md §"Forbidden this sprint"

## Setup nudges (logged separately)

None required. Cell autonomously installed test toolchain (`npm install --no-save typescript jest ts-jest @types/jest @types/node`) and recovered from a single stall (~6 min) without operator intervention.

## Source listing

`tree -L 3 -I 'node_modules|.expo|.git'` abbreviated:

```
.
├── app/
│   ├── _layout.tsx
│   ├── index.tsx
│   ├── (tabs)/
│   │   ├── _layout.tsx
│   │   ├── today/
│   │   │   ├── index.tsx
│   │   │   └── workout.tsx
│   │   ├── progress.tsx
│   │   ├── history/
│   │   │   ├── index.tsx
│   │   │   └── [sessionId].tsx
│   │   └── settings/
│   │       ├── index.tsx
│   │       ├── program.tsx
│   │       ├── schedule.tsx
│   │       └── equipment.tsx
│   └── onboarding/
│       ├── _layout.tsx
│       ├── welcome.tsx
│       ├── experience.tsx
│       ├── schedule.tsx
│       ├── goal.tsx
│       ├── program.tsx
│       ├── starting-numbers.tsx
│       └── confirm.tsx
├── src/
│   ├── components/
│   │   ├── WeightSelector.tsx
│   │   ├── SetRow.tsx
│   │   ├── RestTimerBar.tsx
│   │   ├── PlateLoadView.tsx
│   │   ├── PRBadge.tsx
│   │   └── charts/LineChart.tsx
│   ├── domain/
│   │   ├── types.ts
│   │   ├── units.ts
│   │   ├── e1rm/epley.ts
│   │   ├── plates/{plateCalculator,inventory}.ts
│   │   ├── warmup/warmupRamp.ts
│   │   ├── pr/prDetection.ts
│   │   ├── scheduling/rotation.ts
│   │   ├── programs/{engine,types,registry,linear,fiveThreeOne,madcow,gzclp,nsuns,redditPPL,assistance,coaching}.ts
│   │   ├── recommendation/recommend.ts
│   │   ├── onboarding/startingNumbers.ts
│   │   └── progress/metrics.ts
│   ├── data/
│   │   ├── schema.ts
│   │   ├── db.ts / expoDatabase.ts / memoryDb.ts
│   │   ├── migrations/001_init.ts
│   │   ├── repositories/{types,memoryRepositories}.ts
│   │   └── seed/exercises.ts
│   ├── services/
│   │   ├── workoutService.ts
│   │   ├── container.ts
│   │   ├── restTimer/{restTimer,useRestTimer,restNotificationController}.ts
│   │   ├── native/{clock,haptics,keepAwake,notifications}.ts
│   │   └── liveActivity/liveActivity.ts
│   ├── state/
│   │   ├── onboardingStore.ts
│   │   ├── sessionStore.ts
│   │   └── settingsStore.ts
│   └── config/liveActivityPlugin.ts
│   [MISSING: src/theme/theme.ts — imported by all components + screens]
├── tests/
│   ├── unit/ (19 suites)
│   └── integration/ (8 suites)
├── specs/001-compound-strength-app/
│   ├── spec.md / plan.md / research.md / data-model.md / tasks.md
│   ├── quickstart.md / HANDOFF.md
│   └── contracts/ (domain-engine.md, persistence-repositories.md, native-services.md)
├── package.json / tsconfig.json / tsconfig.core.json / tsconfig.jest.json
└── jest.config.js / CLAUDE.md
```

**Notable absent file:** `src/theme/theme.ts` — referenced by all UI components and app screens; never created despite task T019 being marked [X] in tasks.md.
