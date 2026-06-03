# T4-rich (PM-quality brief) / AI-DLC / Run 001 / Build Result

**Scored on:** 2026-05-29 · **Scorer model:** claude-sonnet-4-6 · **Evidence basis:** CODE-BASED (no sim this pass — parallel scoring constraint); build result sourced from session-log.md transcript.

## Expo build attempt

| Field | Value |
|---|---|
| Command run | `npx expo run:ios --device "iPhone 17 Pro"` (dev build, not Expo Go) |
| Build succeeded? | **Yes** — `Build Succeeded` (0 errors) including the U6 Live Activity widget extension |
| Time from session start to first successful build | ~3h 13m wall-clock (session start 16:51 PDT; build success confirmed 20:05–20:06 PDT) |
| Time from `expo start` to usable UI | Not separately measured; app launched with JS bundle loaded (1354 modules, no errors) per session-log `[20:05:50]` |
| Platform tested | iOS dev build via `npx expo run:ios` (primary); Android supported (`npx expo run:android` declared but not exercised in session) |
| Device or simulator | iPhone 17 Pro / iOS 26.5 simulator |

## Errors encountered

- **TypeScript errors** — two minor type issues found during U1 (`@types/jest` not auto-included under bundler resolution; scaffold CSS module imports). Both resolved before U2 began. Typecheck clean by session end.
- **Test failure (1)** — repository PR round-trip test failed initially (FK violation: generated sessionId not in DB). Fixed in same turn by using `sessionId: null` in PBT generator.
- **Test failure (2)** — onboarding service test asserted `states['squat']` but GZCLP keys state as `squat:T1`. Fixed in same turn by checking per-program state existence rather than exact key.
- **Prebuild warning** — optional missing images dir for Live Activity widget (non-blocking).
- **Scaffold orphaned files** — removed `app-tabs.web.tsx` and other unused scaffold demo components that referenced deleted routes. No impact on core functionality.

## TypeScript check (this scoring pass)

Run: `cd ~/dev/strength-app-archive/ai-dlc && npx tsc --noEmit`
Exit code: 0 (clean — no output)

## Test suite (this scoring pass)

Run: `cd ~/dev/strength-app-archive/ai-dlc && npm test`
Exit code: 0

```
Test Suites: 10 passed, 10 total
Tests:       59 passed, 59 total
Snapshots:   0 total
Time:        1.222 s
```

Test files passing:
- `src/domain/plateMath/plateMath.test.ts` — PlateMath property tests (fast-check) + examples
- `src/domain/estimators/estimators.test.ts` — Epley e1RM, PR detection
- `src/domain/warmup/warmup.test.ts` — Warmup ramp generation
- `src/domain/programEngine/programEngine.test.ts` — All 7 programs: canonical progression, seed, prescribe
- `src/domain/recommender/recommender.test.ts` — Recommendation mapping
- `src/data/repositories/repositories.test.ts` — SQLite round-trip (using better-sqlite3 test adapter)
- `src/services/sessionLogic.test.ts` — Session logic pure functions
- `src/services/workoutSessionService.test.ts` — Full session lifecycle (mock deps)
- `src/services/onboardingService.test.ts` — Onboarding + all-program seeding
- `src/services/progress.test.ts` — ProgressService e1RM trend, volume, PR history

## Screenshots / video

`artifacts/` — no screenshots captured this scoring pass (code-based scoring only; parallel agents cannot share the one booted sim). Live screenshots were captured during the original cell session by the methodology agent (referenced in session-log.md `[20:06:18]` — "sim-u6.png" taken of the Today screen post-build).
