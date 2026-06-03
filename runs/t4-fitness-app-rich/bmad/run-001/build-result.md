# T4-rich (PM-quality brief) / BMAD v6.7.1 / Run 001 / Build Result

**Scored on:** 2026-05-29 · **Scorer model:** claude-sonnet-4-6 · **Evidence basis:** CODE-BASED (no sim this pass)

## Expo build attempt

| Field | Value |
|---|---|
| Command run | `npx tsc --noEmit` + `npm test` (in `~/dev/strength-app-builds/bmad/compound-app/`) |
| tsc exit code | 0 (clean — no type errors) |
| npm test exit code | 0 (159/159 tests pass, 41 test suites) |
| Build (npx expo run:ios) | NOT RUN this pass (parallel scoring — sim unavailable) |
| Platform tested | Code-based only; ios/ and android/ native dirs present; expo-dev-client in deps |
| SDK | Expo SDK 56 (pinned in package.json and README) |
| Node modules | Present (build sanity runs from existing node_modules) |

## Test results

```
Test Suites: 41 passed, 41 total
Tests:       159 passed, 159 total
Snapshots:   0 total
Time:        8.261 s
```

Test suites cover: engine (programs, progression, no-math), hooks (useRestTimer), components (WeightSelector, SetRow, RestTimer, FinishPrMoment, ProgramCard, CoachingNote, PrescribedWorkout), services (notifications, haptics, keepAwake, restIntervals), screens (adjust-set, history-empty, progress-empty, onboarding-profile, onboarding-starting-numbers), and lib (restMath, format, validation).

## TypeScript

`npx tsc --noEmit` exits 0 — no type errors across 146 TypeScript files (app/ + src/).

## Errors encountered

None during code-based checks. Note: `app.json` splash `backgroundColor: "#208AEF"` is inconsistent with the dark-only theme but does not prevent a build.

## App root

The Expo app is at `~/dev/strength-app-builds/bmad/compound-app/` (not in a subdir). `app.json` present at that root.

## Key implementation evidence (binary outcomes)

- **REST TIMER:** `src/hooks/useRestTimer.ts` — timestamp-based reconstruction from persisted `rest_end_at`; `AppState.addEventListener` for foreground snap
- **LOCAL NOTIFICATION:** `src/services/notifications.ts` — `scheduleNotificationAsync` with `SchedulableTriggerInputTypes.DATE` trigger; test confirms no push token
- **PLATE CALCULATOR:** `src/engine/no-math/plates.ts` — subset-sum DP `reachablePerSide()` + `computePlateBreakdown()`, rounds down, never over-prescribes
- **WARM-UP RAMP:** `src/engine/no-math/warmup.ts` — `generateWarmupRamp()`, ascending loadable steps, excludes duplicates and weights ≥ working weight
- **PR DETECTION:** `src/engine/pr.ts` — `detectPRs()` + `buildPrHistory()`, weight/reps/e1RM PRs
- **7 PROGRAMS:** `src/engine/programs/definitions/` — stronglifts5x5, linear5x3, wendler531, madcow5x5, gzclp, nsuns531lp, redditPpl

## Live Activity

Not implemented. app.json has no ActivityKit plugin. Brief marked it "best-effort bonus / COULD" — absence does not fail binary outcome #1.

## Time to first working build

Per session-log.md / token-log.md: first xcodebuild success occurred during session 5 (the long implementation session, $338.84, 4h 16m API compute). Exact timestamp not available from log; estimated at 3–6 h of API compute from session start.

## Screenshots / video

No screenshots (code-based pass — no sim). Previous live run screenshots may exist in `artifacts/` from the original cell session.
