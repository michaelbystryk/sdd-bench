# Implementation Plan: Strength Training Workout App

**Branch**: `001-strength-training-app` | **Date**: 2026-05-26 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-strength-training-app/spec.md`

## Summary

A single-user, offline strength-training app for use mid-workout. On open it shows today's workout (the next session in an A/B rotation) with each lift's prescribed sets/reps and an auto-calculated suggested weight, so the user never does math. The user logs each set's actual weight and reps with a fast, large-target weight selector, and reviews per-lift progress over time. Three linear-progression programs (5×5, 5×3, 3×5) are selectable at 3 or 4 days/week; switching programs preserves all history.

**Technical approach**: Expo (SDK 56) + React Native + TypeScript, file-based navigation via Expo Router (bottom tabs: Today / Progress / Settings). All data persists locally in SQLite via `expo-sqlite` (async API + `SQLiteProvider`/`useSQLiteContext`, schema migrations via `PRAGMA user_version`). Program definitions, progression rules, and the workout rotation are pure-TypeScript domain logic (unit-testable, no native deps). Progress charts render with `react-native-svg`. Everything runs in Expo Go on iOS and Android — no custom native modules, no account, no network.

## Technical Context

**Language/Version**: TypeScript 6.x on React Native (Expo SDK 56, React 19.2 / RN 0.85)

**Primary Dependencies**: Expo SDK 56, `expo-router` (file-based navigation + bottom tabs), `expo-sqlite` (local storage, async API), `react-native-svg` (progress charts), `@expo/vector-icons` (icons)

**Storage**: On-device SQLite via `expo-sqlite`. Single database file; schema versioned with `PRAGMA user_version` migrations run in `SQLiteProvider onInit`. No network/sync.

**Testing**: `jest-expo` + Jest for domain logic unit tests (progression, rotation/schedule, program catalog — pure functions). `@testing-library/react-native` for key component behavior (weight selector, set logging) where valuable.

**Target Platform**: iOS and Android via Expo Go (Expo SDK 56 runtime). No custom dev client required.

**Project Type**: Mobile app (single Expo project, no separate backend).

**Performance Goals**: Cold start to today's workout visible < 2s; weight-selector adjustments respond at 60fps (< ~16ms/frame, no perceptible lag); a set log persists to SQLite without blocking the UI.

**Constraints**: Fully offline-capable; must run unmodified in Expo Go (no native modules outside the Expo SDK); single user, no auth; pounds (lb) only; large high-contrast touch targets for sweaty-handed, one-handed, glance-based use.

**Scale/Scope**: One user; data on the order of hundreds of sessions / low thousands of logged sets over years (trivial for SQLite). ~3 tab screens + 1 onboarding/config flow + a focused set-logging surface. 4 lifts, 3 programs.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution (`.specify/memory/constitution.md`) is an **unedited template** — it contains only placeholder principles and no ratified rules. There are therefore **no binding constitutional gates** to evaluate.

Self-imposed guardrails adopted in lieu of a ratified constitution (kept lightweight, YAGNI):

- **Expo Go compatibility is non-negotiable**: no dependency that requires a custom native build (rules out Skia-based `victory-native` XL, etc.).
- **Domain logic is pure and unit-tested**: progression and scheduling live in framework-free TypeScript modules with tests; UI stays thin.
- **Offline & single-user**: no network calls, no auth, no analytics.
- **Simplicity**: program definitions are code constants (a catalog), not user-authored data; only user state and logged history are persisted.

**Result**: PASS (no violations; Complexity Tracking section left empty).

## Project Structure

### Documentation (this feature)

```text
specs/001-strength-training-app/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── db-schema.sql        # SQLite storage contract
│   ├── domain-contracts.md  # Pure-TS domain function signatures
│   └── screens.md           # Navigation / screen UI contracts
├── checklists/
│   └── requirements.md  # Created by /speckit-specify
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
app/                          # Expo Router routes (file-based)
├── _layout.tsx               # Root layout: SQLiteProvider + theme + onboarding gate
├── onboarding.tsx            # First-run / program-config flow (US2)
└── (tabs)/
    ├── _layout.tsx           # Bottom tab navigator: Today | Progress | Settings
    ├── index.tsx             # Today's workout + set logging (US1)
    ├── progress.tsx          # Per-lift progress charts (US3)
    └── settings.tsx          # Program selection, days/week, starting weights, switch (US2/US4)

src/
├── domain/                   # Pure TypeScript — framework-free, unit-tested
│   ├── lifts.ts              # The four lifts + metadata
│   ├── programs.ts           # Program catalog (5×5, 5×3, 3×5), day templates, increments
│   ├── progression.ts        # next-weight + success/hold/deload rules
│   └── schedule.ts           # A/B rotation → "today's workout" selection
├── db/
│   ├── schema.ts             # CREATE TABLE statements + migrateDbIfNeeded (PRAGMA user_version)
│   ├── settingsRepo.ts       # active program, days/week, unit
│   ├── liftStateRepo.ts      # per-lift current/starting weight, failure streak
│   ├── sessionRepo.ts        # sessions: create, resume in-progress, complete, list history
│   └── setRepo.ts            # logged sets: upsert, list by session, progress queries
├── hooks/
│   ├── useSettings.ts        # read/write settings + onboarding state
│   ├── useTodayWorkout.ts    # assemble today's prescribed workout from domain + db
│   └── useProgress.ts        # per-lift history series for charts
├── components/
│   ├── WeightSelector.tsx    # fast large-target weight stepper (the headline UX)
│   ├── RepStepper.tsx        # reps +/- control
│   ├── SetRow.tsx            # one set: target, actual, mark-complete
│   ├── LiftCard.tsx          # a lift's sets within today's workout
│   └── ProgressChart.tsx     # react-native-svg line chart
└── theme/
    ├── colors.ts             # high-contrast palette
    └── typography.ts         # large glanceable type scale

__tests__/
├── domain/
│   ├── progression.test.ts
│   ├── schedule.test.ts
│   └── programs.test.ts
└── components/
    └── WeightSelector.test.tsx

app.json                      # Expo config (plugins: expo-router, expo-sqlite)
package.json
tsconfig.json
babel.config.js
```

**Structure Decision**: Single Expo project (Project Type = mobile app, no backend). Routes live under `app/` per Expo Router file-based conventions; all non-UI logic lives under `src/` split into a **framework-free `domain/` layer** (the testable core: programs, progression, scheduling), a **`db/` persistence layer** (thin repositories over `expo-sqlite`), **`hooks/`** that compose domain + db for screens, and presentational **`components/`**. This keeps the in-gym screens thin and the progression/rotation rules independently testable without a device.

## Complexity Tracking

> No constitutional violations. Section intentionally empty.
