# T4-rich (no-runtime) / bmad / Run 002 / Build Result

> **No-runtime variant.** Cell did NOT build or run the app. Verification is source-review + tests-only. The 14 runtime-dependent binary outcomes from run-001 do NOT apply here.
>
> **Scored on:** 2026-06-01 · Scorer model: claude-sonnet-4-6 · Evidence basis: CODE-BASED (no sim this pass)

## Build sanity (timeboxed, code-based)

| Check | Command | Result |
|---|---|---|
| Type-check | `npx tsc --noEmit` | **PASS** — exit 0, 0 errors |
| Tests | `npm test` (jest, node + jest-expo projects) | **PASS** — **683 passed / 683 total**, 105 suites, ~11s |
| Lint | (not run this pass) | n/a |

App root: `StrengthApp/`. No `ios/` or `android/` native dirs present (run-001 had them) — consistent with the no-runtime / no-prebuild constraint.

## Design-verifiable outcomes (per `brief-no-runtime.md` §9)

### Domain logic (unit-testable, primary)
- [x] All 7 programs prescribe + progress per pinned canon — verified via unit tests — **PASS w/ caveats** (GZCLP rotation double-advance bug; Madcow/PPL invented-but-flagged schedules; 5/3/1 TM bump eager)
- [x] Plate calculator (per-side breakdown, respects bar weight + inventory, never over-prescribes) — **PASS** (`plates/plateCalculator.ts` subset-sum, property-tested)
- [x] Warm-up ramp (auto-generated, excluded from PRs/progression) — **PASS** (`warmupRamp.ts`, every set `isWarmup:true`)
- [x] e1RM (Epley) + PR detection (weight / reps / e1RM, main working sets only) — **PASS** (`analytics/e1rm.ts:30-33`, `prDetection.ts:97-98` excludes warmups+assistance)
- [x] Auto-populate (today's set from last time) — **PASS** (`autoPopulate.ts`)
- [~] Workout advances on completion (not by calendar date) — **PARTIAL** (correct for 6/7; **GZCLP double-advances**, `gzclp.ts:261/348` + `nextDay:354` + `finishSession.ts:105`)

### Code structure (source-reviewable, primary)
- [x] Onboarding flow (§4a) screens + routing + state machine — **PASS** (8 screens, complete fork, "Not sure?" path, seeds-from-onboarding)
- [x] Today's workout screen + components wired to domain — **PASS** (`today.tsx` + `buildTodayViewModel`)
- [x] Set logging (1-tap common case visible in code) — **PASS** (single `<Pressable>` `SetRow.tsx:146-173`) — **in-memory only**
- [~] Rest timer (service/hook/component + intervals + haptic) — **PARTIAL** (hook/component/intervals/haptic-invocation + tested timestamp math present; **real `ExpoTimer` throws**)
- [~] Backgrounded rest (notification scheduling code) — **PARTIAL** (orchestration hook + AppState listener present; **`ExpoNotifications.schedule` throws** — real expo call unwritten)
- [~] Quick-switch resilience (state hydration code paths) — **PARTIAL** (`captureActiveSession`/`restoreActiveSession` readable + tested but **zero callers**; no cold-start hydration)
- [x] Live Activity (best-effort: stub/scaffold acceptable) — **PASS** (`IosLiveActivity` stub + `plugins/withLiveActivity.js` scaffold)
- [x] History persistence (SQLite schema + migration + repo code) — **PASS** (9-table schema, real migration, 8 repos, mappers; tested against real migrated DB) — **unwired to screens**
- [x] Progress / PR detection UI components — **PASS** (components present) — **screens feed them `[]`**

### Engineering hygiene (verifiable)
- [x] `tsc --noEmit` clean — **PASS** (exit 0)
- [x] `npm test` passes — **PASS** (683/683)
- [x] Non-goals honored (no auth/cloud/social/etc.) — **PASS** (all-barbell, local-only, single-user; no push token)

### No-runtime constraint adherence (the key fidelity check)
- [x] Cell did NOT run `npx expo run:ios` / `xcodebuild` / `pod install` / `xcrun simctl` / `idb` / `fb-idb` / `expo start` — **PASS** (no native dirs; no traces; lone `expo prebuild` ref is a future-behavior comment in `withLiveActivity.js`)
- [x] Cell wrote full UI code (components + screens) — NOT just domain — **PASS** (8 onboarding + 5 tabs + 20+ components)
- [x] Cell's planning artifacts acknowledged the no-runtime scope — **PASS** (PRD §11, README handoff block)

**Tally: 18 PASS · 5 PARTIAL · 0 FAIL.** The 5 PARTIALs are the integration/wiring items — real code that is unwired or stubbed at the leaf, per the cell's deliberate (and declared) deferral of the runtime-wiring increment.

## The defining shipped-state observation

Unlike run-001 (runtime variant, services wired, app ran), run-002 ships an **unassembled** app: all five real native-service impls are `NotImplementedError` throw-stubs (`src/services/{timer,haptics,notifications,keepAwake,liveActivity}.ts`), **no composition root** opens the DB or instantiates any repository (`app/_layout.tsx:6-11` disclaims it deliberately), and onboarding/logging/finish operate in volatile Zustand only. Schema, migrations, repos, mappers, domain logic, and 683 tests are all genuinely real and green — but nothing connects them into a running whole. This is the cell's central finding and the driver of its product-polish drop vs run-001.

## Setup nudges (logged separately)

None applicable — no-runtime variant; no build/sim setup performed this pass.

## Source listing

```
StrengthApp/
├── app/                          # LIVE expo-router tree
│   ├── _layout.tsx               # headerless Stack; DB/hydration/services deliberately NOT wired
│   ├── index.tsx                 # first-run gate → onboarding
│   ├── (tabs)/                   # today, history, progress, settings  (+ _layout, text-only tabs)
│   └── onboarding/               # welcome, experience, schedule, goal, program, library, starting-numbers, confirm
├── src/
│   ├── domain/                   # PURE (ESLint-boundary-enforced)
│   │   ├── programs/             # 7 programs + types/registry/catalog/recommend/scheduling/warmupRamp/assistance/linearProgression/autoPopulate/seed
│   │   ├── plates/               # plateCalculator, weightSelector
│   │   ├── analytics/            # e1rm, prDetection, volume
│   │   ├── session/              # sessionResult, finishSession, restMath
│   │   └── seed/                 # exercises
│   ├── db/                       # schema, mappers, client, types; migrations/0000_*.sql; 8 repositories/; __testkit__
│   ├── state/                    # ~30 Zustand stores + rest/keepawake/liveactivity hooks (hydrate() seams built, unwired)
│   ├── services/                 # DI container + 5 Expo stubs (throw) + __fakes__ (real, drive tests)
│   ├── ui/components/            # SetRow, WeightSelectorSheet, PlateChips, charts, FinishSummary, ... (20+)
│   ├── theme/                    # tokens (real design system), ThemeProvider
│   ├── components/               # themed-text, animated-icon, app-tabs  (polished chrome — DEAD, stranded here)
│   └── app/                      # DEAD Expo-starter scaffold (refs nonexistent index/explore routes)
├── plugins/withLiveActivity.js   # ActivityKit config-plugin scaffold (best-effort)
├── README.md                     # stock Expo template + 1 hand-authored no-runtime handoff block
└── package.json                  # Expo SDK 56 pinned; drizzle-orm, zustand, fast-check
```

(Native `ios/`/`android/` absent by design — no prebuild this sprint.)
