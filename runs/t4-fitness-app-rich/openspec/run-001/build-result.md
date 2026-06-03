# T4-rich (PM-quality brief) / OpenSpec / Run 001 / Build Result

> **Dev-build runtime (NOT Expo Go)** per brief §7. "Builds + runs" is verified by
> installing the built `.app` into the iOS Simulator and launching by bundle id —
> not by opening `exp://` in Expo Go. First `npx expo run:ios` build takes MINUTES
> (Xcode + CocoaPods); a slow first build is not a failure.

**Scored on:** 2026-05-29 · **Scorer model:** claude-sonnet-4-6 · **Evidence basis:** CODE-BASED (no sim this pass — parallel scoring agents share one booted sim; sim-verified outcomes from original session transcript only)

## Dev-build attempt

| Field | Value |
|---|---|
| Build command run | `npx expo run:ios --device "iPhone 17 Pro"` (via `xcodebuild -workspace Ironclad.xcworkspace` + `xcrun simctl install/launch`; see session-log 11:49–12:00) |
| Expo SDK + npx pinning honored? | SDK 56 (`expo: ~56.0.6`, `expo-sqlite: ~56.0.4`, `expo-notifications: ~56.0.14`) / `npx` (YES — confirmed from package.json + session-log toolchain check) |
| Build succeeded? | YES — `xcodebuild ... BUILD SUCCEEDED` (session-log line 461); app bundle installed (pid 55901 confirmed by `launchctl list`) |
| Time from session start to first successful dev build | ~36 min (11:13:23 session start → ~11:49 BUILD SUCCEEDED; includes `pod install` ~1 min, `xcodebuild` ~3–4 min from transcript) |
| Bundle id (`app.json` → `ios.bundleIdentifier`) | `dev.ironclad.app` |
| Launch command | `xcrun simctl install BAEA0CBF-04A1-423F-80C3-3C5A337A65AD ios/build/Build/Products/...` then `xcrun simctl launch ...` |
| Time from launch to usable UI | INDETERMINATE — dev client launched (pid confirmed); JS bundle loaded (notification permission prompt rendered by `configureNotifications()`); SpringBoard "Open in Ironclad?" dialog blocked idb HID taps — onboarding UI reached but not screenshot-captured (sandbox limitation per session-log 12:01–12:06) |
| Platform tested | iOS Simulator (dev build) — iPhone 17 Pro / iOS 26.5; Android: NOT compiled this session (scope-cut declared by cell: "toolchain is symmetric, but I didn't run it") |
| Device or simulator | iPhone 17 Pro / iOS 26.5 (sim UDID: `BAEA0CBF-04A1-423F-80C3-3C5A337A65AD`) — Dynamic Island device |
| Persistence test (terminate + relaunch bundle id) | NOT EXERCISED THIS SCORING PASS (code-verified: SQLite hydration + `getActiveSession()` resume path present; see schema.ts + store.tsx:hydrate()) |
| Live Activity (best-effort bonus) | SEAM ONLY — `liveActivity.ts` wrapper implemented as no-ops; `NSSupportsLiveActivities: true` in Info.plist; native ActivityKit widget extension not bundled; `isLiveActivitySupported()` returns false at runtime (nativeModule null); consistent with brief §5C "best-effort bonus, not a core requirement" |

## Build sanity (code-based scoring pass: 2026-05-29)

| Check | Result | Details |
|---|---|---|
| `npx tsc --noEmit` | EXIT 0 | Ran from `~/dev/strength-app-archive/openspec/mobile`; zero errors |
| `npx jest` | EXIT 0 | 50/50 tests pass, 7 test suites; 5.083s |

## Binary outcomes (per tasks/t4-fitness-app-rich/success-criteria.md §1, 14 outcomes)

- [x] **1. Core app builds + runs as a dev build (iOS + Android)** — iOS: BUILD SUCCEEDED (session-log, xcodebuild); app launched, JS executed (notification permission prompt rendered). Android: scope-cut (not compiled). **PARTIAL — Android unverified; iOS confirmed.**
- [x] **2. Onboarding works** — code-verified: `onboarding.tsx` 7-step flow; `recommendPrograms()` returns 1–2 sensible programs; WeightSelector used for starting numbers; "Not sure" path resets to `DEFAULT_1RM[experience]`; `router.replace('/(tabs)')` on confirm.
- [x] **3. Four lifts present** — code-verified: `exercises.ts` HEADLINE_LIFTS=['squat','bench','deadlift','ohp'] all with `headline:true`; all 7 programs track these four lifts.
- [x] **4. Today's workout on open** — code-verified: `store.tsx:hydrate()` calls `todaysWorkout(ps, equipment)` on every launch; `index.tsx` renders each set's weight + `PlateBreakdown` without user input.
- [x] **5. Set logging works (1-tap common case)** — code-verified: `index.tsx:doLog()` pre-populates from `edits[key] ?? {weight: set.weight, reps: set.reps}`; "Log set" is a single Pressable; `repo.addLoggedSet()` persists immediately.
- [x] **6. Plate calculator** — code-verified: `plates.ts:computePlateLoad()` greedy over owned `equipment.plates`; `PlateBreakdown.tsx` displays per-side list; `WeightSelector.tsx` steps by `smallestIncrement(equipment)` (2× smallest plate); Settings > Plate inventory honors `countPerSide` per plate denomination.
- [x] **7. Rest timer** — code-verified: auto-starts at `getExercise(set.exerciseId).defaultRestSec` after each non-warmup set (`store.tsx:220`); `RestTimerBar.tsx` fires `Haptics.notificationAsync(Success)` at rest=0; per-exercise intervals from `exercises.ts`.
- [x] **8. Backgrounded rest alert (local notification fires on rest-end, BOTH iOS and Android; LA is bonus)** — code-verified (runtime not exercised this pass): `store.tsx:AppState.addEventListener` schedules `scheduleRestEnd(remaining)` on `background`; `notifications.ts` uses `TIME_INTERVAL` trigger; Android channel configured; Platform.OS used for channelId.
- [x] **9. Quick-switch survives (background → return restores exact set + accurate timer; survives full app close)** — code-verified (runtime not exercised this pass): session persists to SQLite on every `logSet`; `hydrate()` restores in-progress session + rest state; `remainingSec()` derived from `rest_started_at` + `rest_duration_sec` timestamps (accurate regardless of elapsed time).
- [x] **10. Warm-up ramp** — code-verified: `warmup.ts:generateWarmup()` bar→40/60/80% ramp; rendered in `index.tsx` before exercises; `warmup:true` flag excludes from PRs/progression (`isPREligible` check in `prs.ts`).
- [x] **11. 7 programs (5×5, 5×3, 5/3/1, Madcow, GZCLP, nSuns, Reddit PPL — canonical progression per pinned source)** — code-verified: all 7 implemented in `src/domain/programs/`; unit tests cover per-program progression scenarios; 5/3/1 WEEK_SCHEME percentages match Wendler 2nd ed; GZCLP T1/T2/T3 stage-drops match Lefever LP. **NOTE:** Madcow advance() does not implement stall/deload on failure (see defect #1 in observations.md) — logged as major defect but program is present and partially correct.
- [x] **12. Flexible scheduling (3-, 4-, 5-, or 6-day; PPL = 6-day; not hardcoded)** — code-verified: `onboarding.tsx` shows [3,4,5,6] day chips; `ProgramState.daysPerWeek` stored; `def.dayCount(state.daysPerWeek)` called in `rotation.ts`; PPL always 6 days; `programs.test.ts` line 43 verifies PPL clamps from 3→6.
- [x] **13. History persists + dedicated History screen** — code-verified: `history.tsx` dedicated screen with session list + expandable set detail; `logged_sets` table keyed to `exercise_id` (not `program_id`) → program switch preserves history; `getSessionHistory()` returns all completed sessions.
- [x] **14. Progress + PRs** — code-verified: `progress.tsx` per-lift e1RM trend + volume bars for all HEADLINE_LIFTS; `prs.ts:detectPRs()` checks weight/reps/e1RM PR; `PRCelebration.tsx` animated overlay; `pr_history` table persists PR events.

**Pass count: 13.5 / 14** (outcome #1: iOS confirmed / Android scope-cut → counted as 0.5)

## Rich-brief-specific checks (per success-criteria.md §2)

- [x] **Non-goals honored** — No auth/accounts/cloud/social/sharing/push notifications/cardio/nutrition/multi-user; `proposal.md` non-goals section matches brief §6 verbatim; Live Activity isolated as best-effort
- [x] **Open assumptions engaged** — `design.md` D1-D9 each engage a brief §10 assumption; program-recommendation mapping in `recommendation.ts` follows brief's table (beginner→linear, intermediate→5/3/1/Madcow, advanced→nSuns/PPL); lb default with kg switch; warm-ups/assistance excluded from PRs (`isPREligible`)
- [x] **Stretch stayed out** — No supersets, export, custom builder, periodization, importable templates, Apple Watch; schema reserves columns (`notes`, `superset_group`, `bodyweight`) but does not implement the features
- [x] **Delight north-star (§8) — YES** — `PRCelebration.tsx` spring-animated pop with gold (#FFD23F) border + 🔥 emoji; iron-hot accent (#E8513A) threading through all CTAs and active states; 56px display numerals on WeightSelector; coaching notes timed to AMRAP sets; animated rest timer progress bar fills. Inferred from "designed for sweaty hands" intent rather than from a specific feature list.
- [x] **Runtime honored** — `expo: ~56.0.6`, all modules via `npx expo install`; `expo-dev-client` plugin in `app.json`; built as dev build (not Expo Go); `AGENTS.md` warns about SDK 56 version drift
- [x] **Equipment scope honored** — All `ExerciseId` values in `exercises.ts` are barbell/rack/bench; `substituteAccessory()` maps machine/cable/dumbbell to barbell equivalents; `programs.test.ts` "barbell-centric guarantee" sweeps all 7 programs × 16 days

## OpenSpec phase-completion outcomes

- [x] `/opsx:propose` completed — `proposal.md` (9 capabilities, non-goals, impact), `design.md` (9 ADRs), 9 capability spec files (`onboarding`, `training-programs`, `rest-timer`, etc.), `tasks.md` (60 tasks)
- [x] `/opsx:apply` completed — 52/60 tasks checked; 8 unchecked = on-device integration tests / final manual criteria pass; all underlying logic implemented and unit-tested; iOS dev build compiles + launches
- [x] `/opsx:archive` completed — **BREAKS T4-vague miss** — operator confirmed "Archive anyway" at 8/60-unchecked-tasks prompt; 9 delta specs merged to canonical `openspec/specs/` (43 requirements total); validated by CLI

**Note:** T4-vague OpenSpec skipped archive entirely (canonical `openspec/specs/` empty). T4-rich run-001 completes archive with an honest disclosure of the 8 incomplete on-device tasks. This is the stronger process posture.

## Errors encountered

- `babel-preset-expo` not installed on initial export attempt; cell self-corrected with `npx expo install babel-preset-expo` (session-log 11:44).
- `ts-jest` glob conflict with Expo base tsconfig; cell self-corrected by adding separate `tsconfig.jest.json` (session-log 11:34).
- idb HID tap injection failed in sandbox (osascript + idb both couldn't tap through the SpringBoard "Open in Ironclad?" modal) — only impacted sim walkthrough, not the build itself (session-log 12:01–12:06).

## Setup nudges (logged separately from product interventions, per cost-axis caveat)

- 1 `kcontinue` at 11:13:36 (tool-use interrupt on session start — not a product correction)
- 1 archive confirmation ("Archive anyway") at 12:11 — methodology-internal procedure, not a product redirection
- Total product interventions: 0

## Screenshots / video

`artifacts/98cfa2fa-8339-493a-a472-c9202888d891/` — original session transcript artifacts (screenshots from idb walkthrough during the original session; not re-exercised during this scoring pass)
