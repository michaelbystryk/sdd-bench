# Phase 0 Research: Strength Training Workout App

**Date**: 2026-05-26 | **Feature**: 001-strength-training-app

This document resolves the open technical and domain decisions implied by the spec. The spec's Assumptions section already locked product-level defaults; the items below resolve *how* to build them within the Expo Go constraint.

---

## 1. Platform & framework baseline

**Decision**: Expo SDK 56, React Native, TypeScript, with Expo Router for navigation.

**Rationale**: The brief mandates Expo, iOS + Android, and "builds and runs in Expo Go." SDK 56 is the current stable release and its bundled modules (`expo-sqlite`, `expo-router`, `react-native-svg`) all run in Expo Go without a custom dev client. Expo Router gives file-based routing and a first-class bottom-tab layout, matching the three top-level destinations (Today / Progress / Settings) with minimal boilerplate.

**Alternatives considered**:
- *Bare React Native CLI* — rejected; loses Expo Go one-command run, contradicts the brief.
- *React Navigation without Expo Router* — viable, but Expo Router is the Expo-default and reduces navigation wiring; tabs are declarative.

## 2. Storage: SQLite vs AsyncStorage

**Decision**: `expo-sqlite` (the async API), single database file, schema versioned via `PRAGMA user_version` migrations inside `SQLiteProvider`'s `onInit`.

**Rationale**: The data is inherently relational and query-heavy: sessions → logged sets → per-lift progress series over time. SQLite gives indexed queries ("max working weight per session for lift X, chronological") that would be awkward and slow to hand-roll over a serialized AsyncStorage blob. `expo-sqlite` runs in Expo Go and its modern async API (`getAllAsync`, `runAsync`, `getFirstAsync`, `execAsync`) is ergonomic with `async/await`. History preservation across program switches (FR-021) is automatic because logged data is independent of the active-program setting.

**API shape confirmed (SDK 52–56)**:
- `<SQLiteProvider databaseName="strength.db" onInit={migrateDbIfNeeded}>` at the app root.
- `const db = useSQLiteContext()` inside components/hooks.
- Migrations: read `PRAGMA user_version`, branch by version, `execAsync` DDL, then `PRAGMA user_version = N`.

**Alternatives considered**:
- *AsyncStorage* — allowed by the brief and simpler for flat settings, but progress queries and integrity across many sessions are clumsy. Rejected as the primary store.

## 3. Program catalog: code constants vs DB-seeded data

**Decision**: Define the three programs, their day templates, per-lift set/rep schemes, and increments as **TypeScript constants** (`src/domain/programs.ts`). Persist only **user state** (settings, per-lift weights, failure streaks) and **logged history** (sessions, sets) in SQLite.

**Rationale**: Programs are static, app-defined, and never edited by the user in v0.1 (custom programs are explicitly out of scope). Keeping them as typed constants removes seeding/migration complexity, makes them trivially unit-testable, and keeps the DB schema focused on user data.

**Alternatives considered**:
- *Seed programs into DB tables* — adds migration/seed code and a source-of-truth split for zero v0.1 benefit. Rejected.

## 4. Workout structure & rotation model

**Decision**: An **A/B alternating rotation**, the same two day-templates for all three programs (programs differ only in the set/rep scheme applied):

- **Day A**: Squat, Bench Press
- **Day B**: Squat, Overhead Press, Deadlift

Squat is trained every session; bench alternates with OHP+deadlift. This mirrors the proven StrongLifts-5×5 structure (minus the barbell row, which isn't one of the four lifts).

"Today's workout" = the template **opposite the last completed session** (first ever session = Day A). The app shows the next uncompleted session in this rotation. Rotation does not depend on calendar days, so gaps between sessions are tolerated (spec Assumption + Edge Case).

**Days-per-week (3 or 4)** is stored and shown as the user's weekly plan / informs the rest-day messaging, but does **not** change the A/B rotation logic. This keeps scheduling deterministic and simple while still honoring FR-003.

**Rationale**: A single A/B cycle is the simplest model that (a) covers all four lifts, (b) keeps each session short — good for the mid-workout experience — and (c) makes "today's workout" a pure function of completed-session count. Decoupling frequency from rotation avoids four different schedule shapes for no functional gain.

**Alternatives considered**:
- *Distinct 3-day full-body vs 4-day upper/lower template sets* — more realistic but multiplies templates and edge cases; deferred beyond v0.1.

## 5. Set/rep schemes and deadlift volume

**Decision**:
- Working-set scheme per program: **5×5** = 5 sets × 5 reps, **5×3** = 5 sets × 3 reps, **3×5** = 3 sets × 5 reps.
- **Deadlift uses 1 working set** of the program's rep count (e.g., 1×5 for 5×5), regardless of program — the conventional approach because heavy deadlift volume is highly fatiguing.

**Rationale**: Matches established practice and keeps sessions sane. Modeling sets at the day-template entry level (rather than purely at the program level) lets deadlift override the set count cleanly.

## 6. Progression rules (the "next weight" engine)

**Decision**: Per-lift **linear progression** computed by `src/domain/progression.ts`:

- **Success** (all prescribed working sets completed with actual reps ≥ target at the prescribed weight) → next weight = current + increment.
- **Failure** (any working set short of target reps) → hold weight (repeat next time); increment a per-lift `consecutive_failures` counter.
- **Deload**: after **3 consecutive failures**, next weight = round(current × 0.9) and reset the counter.

**Default increments (lb)**: Squat +5, Bench Press +5, Overhead Press +5, Deadlift +10. Rounded to the nearest 5 lb on deload.

**No-history fallback**: if a lift has never been logged, suggested weight = the user's configured starting weight (FR-017).

**Rationale**: Deterministic, explainable, and exactly satisfies "show me the next weight, I don't want to do math." Increments follow common novice/intermediate linear-progression conventions; deadlift jumps faster. All rules are pure functions of (current weight, last session result, failure streak) → fully unit-testable.

**Alternatives considered**:
- *Percentage/AMRAP programs (5/3/1, Texas Method)* — more complex (training maxes, waves, AMRAP math) and conflict with the "no math / uniform behavior" goal. Rejected for v0.1 (consistent with the spec's 3×5 third-program choice).

## 7. Working weight across program switches

**Decision**: A lift's current working weight is stored **per lift, shared across programs**. Switching programs changes only the set/rep scheme; the lift keeps its weight and full history.

**Rationale**: Directly satisfies "switch programs occasionally without losing history" (FR-020/FR-021) with the least state. Carrying the weight over is the least-surprising behavior for the user.

## 8. The fast weight selector (headline UX)

**Decision**: A large stepper centered on the suggested weight, with:
- Big **−/＋ buttons** stepping by the plate-pair increment (default **5 lb**; a long-press or secondary control allows finer/coarser steps for awkward weights).
- The current value shown large and high-contrast.
- Optional tap-to-type for arbitrary values (covers microplates / unusual loads — spec Edge Case).
- Opens pre-set to the suggested weight so the common case is **zero adjustments**.

**Rationale**: Steppers beat sliders and small wheels for sweaty, imprecise, glance-based input. Centering on the suggestion means most sets need 0–2 taps (SC-002/SC-003). Built with plain RN `Pressable` + large hit targets — no extra dependency, 60fps.

**Alternatives considered**:
- *Slider* — poor precision with sweaty hands. *Numeric keyboard only* — slow between sets. Both rejected as the primary control; keypad retained as a fallback.

## 9. Progress visualization

**Decision**: A simple line chart per lift built on **`react-native-svg`** (bundled, Expo Go compatible), plotting top working weight per session over time, plus an empty-state for lifts with no history (FR-019).

**Rationale**: `react-native-svg` runs in Expo Go and is enough for a clean line/point chart without a heavy charting dependency. Avoids `victory-native` XL (Skia → requires a custom dev build, breaks Expo Go).

**Alternatives considered**:
- *`react-native-chart-kit`* — works in Expo Go but adds a dependency for what a small custom SVG chart covers. Acceptable fallback if custom charting proves fiddly.
- *`victory-native` (Skia)* — rejected, not Expo Go compatible.

## 10. Units

**Decision**: Pounds (lb) only, stored as integers. No kg toggle in v0.1 (spec Out of Scope).

**Rationale**: Matches the reference numbers (225/315/405/145) and keeps the weight selector and increments simple.

## 11. In-progress session persistence

**Decision**: A session row is created with `status = 'in_progress'` when the user starts logging; each logged set is written immediately to `logged_sets`. On reopen, `useTodayWorkout` resumes the existing in-progress session (FR-014, SC-008). Finishing sets `status = 'completed'` and triggers progression updates to `lift_state`.

**Rationale**: Writing each set as it happens means an app kill mid-workout loses nothing; resume is just "find the in-progress session."

## 12. Testing strategy

**Decision**: `jest-expo` unit tests for the `domain/` layer (programs, progression, schedule) — the highest-risk logic and pure functions. Targeted `@testing-library/react-native` tests for the weight selector and set-row interactions. No e2e in v0.1.

**Rationale**: The correctness risk concentrates in next-weight and rotation math; pure functions make those cheap and reliable to test. UI smoke tests cover the headline interaction.

---

## Resolved unknowns summary

| Topic | Resolution |
|-------|-----------|
| Framework / SDK | Expo SDK 56 + Expo Router + TypeScript |
| Storage | `expo-sqlite` async API, `PRAGMA user_version` migrations |
| Programs source | Code constants (catalog), not DB-seeded |
| Rotation | A/B alternating, frequency-independent |
| Schemes | 5×5 / 5×3 / 3×5; deadlift 1 working set |
| Progression | Linear: success +inc / fail hold / 3 fails → −10% |
| Increments | Squat +5, Bench +5, OHP +5, Deadlift +10 (lb) |
| Weight across programs | Per-lift, shared, history preserved |
| Weight selector | Large stepper centered on suggestion + keypad fallback |
| Charts | `react-native-svg` custom line chart |
| Units | lb only |
| Testing | jest-expo (domain) + RN Testing Library (key components) |

No outstanding `NEEDS CLARIFICATION` items remain.
