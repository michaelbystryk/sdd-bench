# Quickstart: Strength Training Workout App

**Feature**: 001-strength-training-app | Stack: Expo SDK 56 + TypeScript + Expo Router + expo-sqlite

This is the developer setup + run guide. The app is greenfield (no scaffolding exists yet); these are the steps the implementation will follow.

## Prerequisites

- Node.js 20+ and npm
- The **Expo Go** app on a physical iOS or Android device (or a simulator/emulator)
- macOS/Linux/Windows for development

## 1. Scaffold the Expo app

```bash
# From the repo root (001-strength-training-app branch)
npx create-expo-app@latest . --template default   # TypeScript + Expo Router preconfigured
```

This sets up `app/`, `app.json`, `package.json`, `tsconfig.json`, and the Expo Router config plugin.

## 2. Add dependencies (Expo Go compatible)

```bash
npx expo install expo-sqlite react-native-svg @expo/vector-icons
npm install -D jest-expo jest @testing-library/react-native @types/jest
```

> Use `npx expo install` (not plain `npm install`) for native-backed packages so versions match the SDK and stay Expo Go compatible. Do **not** add Skia-based charting (`victory-native` XL) — it breaks Expo Go.

## 3. Configure plugins

`app.json` → `expo.plugins` should include `"expo-router"` and `"expo-sqlite"`.

## 4. Wire the database provider

Wrap the root layout (`app/_layout.tsx`) in `<SQLiteProvider databaseName="strength.db" onInit={migrateDbIfNeeded}>`. `migrateDbIfNeeded` lives in `src/db/schema.ts` and applies `contracts/db-schema.sql` via `PRAGMA user_version` (version 1). Seed `settings` (5×5, 3 days) and `lift_state` (default starting weights) on first init.

## 5. Run in Expo Go

```bash
npx expo start
# press i (iOS simulator) / a (Android emulator), or scan the QR code with Expo Go
```

**Acceptance smoke test (maps to user stories):**

1. **US1 / SC-001**: App opens on the **Today** tab showing the next workout with suggested weights — no navigation needed.
2. **US1 / SC-002–003**: Tap a set, adjust weight with the stepper (opens on the suggestion), set reps, mark complete — in ≤3 taps.
3. **US1 / SC-008**: Force-quit mid-workout, reopen — logged sets are still there; resume.
4. **US2**: Settings → switch program / days-per-week / starting weights; Today reflects the new scheme.
5. **US3 / SC-007**: Complete a session, open **Progress** — each lift shows its trend; untouched lifts show an empty state.
6. **US4 / SC-006**: Switch programs in Settings; Progress still shows all prior history.

## 6. Run unit tests

```bash
npm test          # jest-expo
```

Domain tests cover the highest-risk logic:

- `__tests__/domain/progression.test.ts` — success increments, failure holds, deload after 3 fails, `round5`.
- `__tests__/domain/schedule.test.ts` — `nextDayKey` alternation, first session = A.
- `__tests__/domain/programs.test.ts` — catalog has 5×5/5×3/3×5; day templates cover the four lifts; deadlift = 1 set.

## Build order (suggested)

1. `src/domain/*` (lifts, programs, schedule, progression, workout) **+ their tests** — pure, no device needed.
2. `src/db/schema.ts` + repositories.
3. `app/_layout.tsx` (SQLiteProvider + onboarding redirect) and `(tabs)/_layout.tsx`.
4. `components/WeightSelector` + `SetRow` + `LiftCard`, then the **Today** screen (US1 — the MVP).
5. **Settings** (US2/US4), then **Progress** + `ProgressChart` (US3).
6. Onboarding flow.

> The MVP is the Today screen logging loop running against seeded defaults; everything else layers on top.
