# T4-openspec / Run 001 / Build Result

## Expo build attempt

| Field | Value |
|---|---|
| Command run | `npx tsc --noEmit` (clean) · `npx jest` (24/24 pass) · `npx expo start --port 8081` + `xcrun simctl openurl booted "exp://localhost:8081"` |
| Build succeeded? | **yes** |
| Time from session start to first successful build | not separately stopwatched (iOS Metro bundle builds clean per tasks.md 10.1) |
| Time from `expo start` to usable UI | iOS bundle 4.35s (1,496 modules) on cold start; usable within ~12s of openurl |
| Platform tested | iOS Simulator (Expo Go) on iOS 26.5 |
| Device or simulator | iPhone 17 Pro simulator (UDID `BAEA0CBF-04A1-423F-80C3-3C5A337A65AD`) |

Verified at scoring time (2026-05-26 ~13:10–13:26 PT), code at `~/dev/sdd-bench-cells/t4-openspec-run/`:
- `npx tsc --noEmit` → exit 0 (no type errors).
- `npx jest` → 4 suites, **24/24 tests pass** (progression 9, schedule 5, programs 6, WeightSelector 4) in 0.65s.
- Expo Go cold launch → onboarding → all 7 binary outcomes verified (see observations.md).

## Errors encountered

None. Zero redbox/yellowbox in the Metro log across the full walkthrough (onboarding → set logging → kill+reopen persistence → program switch → 5/3/1 → finish → progress).

## Screenshots / video

`artifacts/screenshots/` — 19 idb-captured states (01-fresh-launch → 18-progress-populated):
onboarding w/ me.md-prefilled 1RMs, Today (5×5), weight selector, set logged, kill+reopen persistence, Settings program switch, Today (5/3/1, correct TM math), all-sets-logged green-ready, post-finish silent rotation to Bench Press, populated Progress (Squat 280 lb e1RM).
