# T4-rich (no-runtime) / vibe-planmode / Run 002 / Build Result

**Scored on:** 2026-05-29 · **Scorer model:** claude-sonnet-4-6 · **Evidence basis:** CODE-BASED (no sim this pass)

> **No-runtime variant.** Cell did NOT build or run the app. Verification is source-review + tests-only. The 14 runtime-dependent binary outcomes from run-001 do NOT apply here.

## Design-verifiable outcomes (per `brief-no-runtime.md` §9)

### Domain logic (unit-testable, primary)
- [x] All 7 programs prescribe + progress per pinned canon — verified via unit tests
  - code-verified: 15 test suites, 80 tests, all pass. Per-program test files: `sl5x5.test.ts`, `linear5x3` (covered in registry.test), `wendler531.test.ts`, `madcow5x5.test.ts`, `gzclp.test.ts`, `nsuns531.test.ts`, `redditPPL.test.ts`. Each asserts canonical weights, rep schemes, progression events, and failure cascades against cited sources.
- [x] Plate calculator (per-side breakdown, respects bar weight + inventory)
  - code-verified: `src/domain/calc/plates.ts` — greedy largest-first fill, strict `count` enforcement, never exceeds target. Tests in `plates.test.ts` cover standard loads, edge inventory, and shortfall reporting.
- [x] Warm-up ramp (auto-generated, excluded from PRs/progression)
  - code-verified: `src/domain/calc/warmup.ts` — sets flagged `kind:'warmup'`; `pr.ts:42` filters to `kind==='working'` only. Tests in `warmup.test.ts`.
- [x] e1RM (Epley) + PR detection (weight / reps / e1RM, main working sets only)
  - code-verified: `src/domain/calc/pr.ts:42-44` — filters `kind==='working' && completed && actualReps>0`. Tests in `pr.test.ts` verify all three PR categories and history update.
- [x] Auto-populate (today's set from last time)
  - code-verified: `src/app/components/SetRow.tsx:41` — `useState(logged?.weight ?? seedWeight ?? set.weight)`. Workout screen hydrates `logged` map from persisted sets on resume (`workout.tsx:49-79`).
- [x] Workout advances on completion (not by calendar date)
  - code-verified: `src/app/services/workoutService.ts:123-126` — `advanceRotation(programId, nextRotationIndex)` called only inside `finishWorkout`, never on a timer or date check.

### Code structure (source-reviewable, primary)
- [x] Onboarding flow (§4a) screens + routing + state machine
  - code-verified: `app/onboarding.tsx` — 7-step `useReducer` state machine (welcome → experience → schedule → goal → program → numbers → confirm). "Help me pick" surfaces `recommendPrograms()` with one-line why; "I'll choose" browses all 7. WeightSelector used for starting numbers. "Not sure" path fills conservative defaults. `completeOnboarding()` seeds all 7 programs.
- [x] Today's workout screen + components wired to domain
  - code-verified: `app/(tabs)/index.tsx` — renders working weight + `PlateView(plateBreakdown(...))` per exercise; wired via `useToday()` which calls `workoutService.getToday()`. In-progress resume shows "IN PROGRESS" badge.
- [x] Set logging (1-tap common case visible in code)
  - code-verified: `src/app/components/SetRow.tsx:68-73` — single `Pressable` button labeled "Log" with pre-initialized weight + reps calls `onLog({weight, reps, rpe})` in one press. Expand for adjustment is optional.
- [x] Rest timer (service/hook/component + intervals + haptic)
  - code-verified: `src/app/hooks/useRestTimer.ts` wraps `restTimer.ts` (timestamp-based math); `src/domain/timer/restTimer.ts` has `defaultRestFor()` per-exercise table; `hapticRestDone()` fires on completion; `RestTimerBar.tsx` renders remaining/total.
- [x] Backgrounded rest (notification scheduling code)
  - code-verified: `src/app/services/notifications.ts` — `scheduleNotificationAsync` with `TIME_INTERVAL` trigger; `useRestTimer.ts:67-82` — AppState listener schedules on background, cancels on foreground.
- [x] Quick-switch resilience (state hydration code paths)
  - code-verified: `workoutService.getToday()` checks `findInProgressWorkout()` first (returns prescription snapshot + logged sets); `workout.tsx:49-79` hydrates `logged` map from persisted sets, so returning to an in-progress workout restores exact state.
- [x] Live Activity (best-effort: stub/scaffold acceptable)
  - code-verified: `plugins/withLiveActivity.js` (config plugin), `targets/RestActivityWidget/*.swift` (3 Swift files — Attributes, Widget, Module), `src/app/services/restActivity.ts` (TS bridge that gracefully no-ops if native module absent). Stub is reviewable and wired.
- [x] History persistence (SQLite schema + migration + repo code)
  - code-verified: `src/data/migrations.ts` — `workouts` + `logged_sets` tables never scoped by active program; `workoutRepository.ts:177-197` `listRecentWorkouts` + `exerciseHistory`; `app/(tabs)/history.tsx` browsable list; `app/history/[id].tsx` session detail.
- [x] Progress / PR detection UI components
  - code-verified: `app/(tabs)/progress.tsx` — e1RM Sparkline + volume Sparkline + PR history list. `src/app/components/misc.tsx` — `PRCelebration` component displayed in `workout.tsx` finish state.

### Engineering hygiene (verifiable)
- [x] `tsc --noEmit` clean — code-verified: exit code 0 (run 2026-05-29)
- [x] `npm test` passes — code-verified: 80 tests / 15 suites pass, exit code 0 (run 2026-05-29)
- [x] Non-goals honored (no auth/cloud/social/etc.) — code-verified: no auth imports, no remote push paths, no cardio/nutrition screens; barbell-only exercise catalog with chinup as edge case (noted in defects)

### No-runtime constraint adherence (the key fidelity check)
- [x] Cell did NOT run `npx expo run:ios` / `xcodebuild` / `pod install` / `xcrun simctl` / `idb` / `fb-idb` / `expo start` — session log shows no forbidden commands; README explicitly states "no native build / simulator / Metro was run (see HANDOFF.md)"
- [x] Cell wrote full UI code (components + screens) — all 4 tab screens (Today, Progress, History, Settings) + onboarding.tsx + workout.tsx + history/[id].tsx present; 1,903 lines of TSX in app/ directory
- [x] Cell's planning artifacts acknowledged the no-runtime scope — plan file § "Phase 0" and § "Verification" explicitly list forbidden steps; HANDOFF.md section "Native build / sim / device: deliberately not run"

## Setup nudges (logged separately)

None (no unplanned interventions). One planned operator gate: plan approval at ~25 minutes into session.

## Source listing

`tree -L 3 -I 'node_modules|.expo|.git'` output:

```
├── app.config.ts
├── app.json
├── babel.config.js
├── eslint.config.js
├── expo-env.d.ts
├── HANDOFF.md
├── jest.config.js
├── package.json
├── README.md
├── tsconfig.json
├── app/
│   ├── _layout.tsx
│   ├── index.tsx              (onboarding gate / redirect)
│   ├── onboarding.tsx         (7-step state machine)
│   ├── workout.tsx            (active logging + rest timer)
│   ├── (tabs)/
│   │   ├── _layout.tsx
│   │   ├── index.tsx          (Today view)
│   │   ├── progress.tsx
│   │   ├── history.tsx
│   │   └── settings.tsx
│   └── history/
│       └── [id].tsx           (session detail)
├── plugins/
│   └── withLiveActivity.js
├── targets/
│   └── RestActivityWidget/
│       ├── Info.plist
│       ├── RestActivityAttributes.swift
│       ├── RestActivityModule.swift
│       └── RestActivityWidget.swift
└── src/
    ├── domain/
    │   ├── types.ts
    │   ├── index.ts
    │   ├── onboarding.ts
    │   ├── calc/
    │   │   ├── e1rm.ts + e1rm.test.ts
    │   │   ├── plates.ts + plates.test.ts
    │   │   ├── pr.ts + pr.test.ts
    │   │   ├── rounding.ts
    │   │   └── warmup.ts + warmup.test.ts
    │   ├── engine/
    │   │   ├── registry.ts + registry.test.ts
    │   │   ├── support.ts
    │   │   ├── testkit.ts
    │   │   └── programs/
    │   │       ├── sl5x5.ts + sl5x5.test.ts
    │   │       ├── linear5x3.ts
    │   │       ├── wendler531.ts + wendler531.test.ts
    │   │       ├── madcow5x5.ts + madcow5x5.test.ts
    │   │       ├── gzclp.ts + gzclp.test.ts
    │   │       ├── nsuns531.ts + nsuns531.test.ts
    │   │       └── redditPPL.ts + redditPPL.test.ts
    │   └── timer/
    │       └── restTimer.ts + restTimer.test.ts
    ├── data/
    │   ├── db.ts
    │   ├── id.ts
    │   ├── index.ts
    │   ├── mappers.ts + mappers.test.ts
    │   ├── migrations.ts
    │   ├── schema.ts
    │   ├── seed.ts
    │   └── repositories/
    │       ├── programRepository.ts
    │       ├── prRepository.ts
    │       ├── settingsRepository.ts
    │       └── workoutRepository.ts
    └── app/
        ├── labels.ts
        ├── theme.ts
        ├── components/
        │   ├── misc.tsx
        │   ├── PlateView.tsx + PlateView.test.tsx
        │   ├── RestTimerBar.tsx
        │   ├── SetRow.tsx
        │   ├── Sparkline.tsx
        │   ├── ui.tsx
        │   └── WeightSelector.tsx
        ├── hooks/
        │   ├── useAsync.ts
        │   ├── useProgress.ts
        │   ├── useRestTimer.ts
        │   ├── useSettings.ts
        │   └── useToday.ts
        └── services/
            ├── haptics.ts
            ├── notifications.ts
            ├── onboardingService.ts
            ├── progressService.ts + progressService.test.ts
            ├── restActivity.ts
            └── workoutService.ts
```

**LOC summary:**
- TypeScript (.ts + .tsx), excl. tests: ~5,100 lines
- TypeScript (.ts + .tsx), incl. tests: 6,943 lines
- Swift stubs: ~191 lines
- Config/other JS: ~133 lines
- **Total (all source):** ~7,267 lines (token-log: 7,638 net added)
