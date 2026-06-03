---
description: "Task list for Strength Training Workout App implementation"
---

# Tasks: Strength Training Workout App

**Input**: Design documents from `/specs/001-strength-training-app/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Included. `plan.md` and `research.md` §12 specify a testing strategy — `jest-expo` unit tests for the pure `domain/` layer (the highest-risk progression/scheduling logic) plus a targeted component test for the weight selector. Test tasks below are limited to that scope, not exhaustive coverage.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US4)
- All paths are repo-relative (single Expo project; see plan.md Structure Decision)

## Path Conventions

- Routes: `app/` (Expo Router, file-based)
- Logic: `src/domain/` (pure TS), `src/db/` (repositories), `src/hooks/`, `src/components/`, `src/theme/`
- Tests: `__tests__/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Scaffold the Expo app at repo root with `npx create-expo-app@latest . --template default` (TypeScript + Expo Router); confirm `app/`, `app.json`, `tsconfig.json`, `package.json` exist and `npx expo start` boots in Expo Go
- [X] T002 Install runtime deps with `npx expo install expo-sqlite react-native-svg @expo/vector-icons`, and dev deps `npm install -D jest-expo jest @testing-library/react-native @types/jest` (per quickstart.md §2)
- [X] T003 [P] Configure `app.json` → `expo.plugins` to include `"expo-router"` and `"expo-sqlite"`
- [X] T004 [P] Configure the test runner in `package.json`: add `"test": "jest"` script and `"jest": { "preset": "jest-expo" }` (plus transformIgnorePatterns for RN); verify `npm test` runs with zero tests
- [X] T005 [P] Create the high-contrast, large-target theme in `src/theme/colors.ts` and `src/theme/typography.ts` (FR-025/SC-009 — readable at arm's length, big type scale)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Catalog, types, persistence, and app shell that EVERY user story depends on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T006 [P] Define shared domain types in `src/domain/types.ts` (`LiftId`, `ProgramId`, `DayKey`, `Lift`, `Program`, `DayEntry`, `DayTemplate`, `PrescribedSet`, `PrescribedWorkout`, `LiftSessionResult`) per contracts/domain-contracts.md
- [X] T007 [P] Implement the lifts catalog in `src/domain/lifts.ts` (`LIFTS`, `LIFT_ORDER`, `getLift`) — four lifts with increments squat/bench/ohp +5, deadlift +10, and default starting weights (FR-004, data-model.md)
- [X] T008 [P] Implement the programs catalog + day templates in `src/domain/programs.ts` (`PROGRAMS`/`PROGRAM_LIST` for 5×5/5×3/3×5, `getProgram`, `DAY_TEMPLATES` A=[squat,bench] B=[squat,ohp,deadlift setsOverride:1]) (FR-001, research §4–5)
- [X] T009 Implement `src/db/schema.ts` — `migrateDbIfNeeded(db)` applying contracts/db-schema.sql at `PRAGMA user_version = 1`, and seed defaults on first init (settings: 5×5 / 3 days / onboarded=0; lift_state: 4 lifts at default starting weights) (FR-006, data-model.md)
- [X] T010 [P] Implement `src/db/settingsRepo.ts` (`getSettings` returning seeded defaults, `updateSettings`, `setActiveProgram` (settings-only, non-destructive), `setOnboarded`) per contracts/domain-contracts.md
- [X] T011 [P] Implement `src/db/liftStateRepo.ts` (`getAllLiftState`, `setStartingWeight` resetting current_weight when no history, `applyProgression`) per contracts/domain-contracts.md
- [X] T012 Implement the root layout `app/_layout.tsx` wrapping the app in `<SQLiteProvider databaseName="strength.db" onInit={migrateDbIfNeeded}>` with the theme; render the tab navigator (onboarding redirect added later in T033)
- [X] T013 Implement the tab navigator `app/(tabs)/_layout.tsx` with `<Tabs>` for Today / Progress / Settings, initial route = `index` (Today) so the app opens on today's workout (SC-001)

**Checkpoint**: App boots in Expo Go with an empty DB, seeded settings/lift_state, and three (empty) tabs. User story work can now begin.

---

## Phase 3: User Story 1 - Log today's workout mid-session (Priority: P1) 🎯 MVP

**Goal**: Open the app → see today's prescribed workout with auto-suggested weights → log each set with the fast weight selector → finish, advancing the rotation and progressing weights.

**Independent Test**: With seeded defaults, open the app: today's workout appears on the Today tab with suggested weights; log every set in ≤3 taps each; force-quit and reopen to confirm resume; finish to save to history and bump next weights.

### Tests for User Story 1 (domain logic) ⚠️

> Write these FIRST and ensure they FAIL before implementing T017–T019.

- [X] T014 [P] [US1] Catalog test in `__tests__/domain/programs.test.ts` — PROGRAM_LIST contains 5×5/5×3/3×5; templates cover all four lifts; deadlift has setsOverride=1
- [X] T015 [P] [US1] Schedule test in `__tests__/domain/schedule.test.ts` — `nextDayKey(0)==='A'`, `nextDayKey(1)==='B'`, alternates thereafter
- [X] T016 [P] [US1] Progression test in `__tests__/domain/progression.test.ts` — success increments, failure holds + counts, 3rd failure deloads `round5(w*0.9)` and resets, `round5` rounding

### Implementation for User Story 1

- [X] T017 [P] [US1] Implement `src/domain/schedule.ts` (`nextDayKey(completedSessionCount)`) per contracts/domain-contracts.md
- [X] T018 [P] [US1] Implement `src/domain/progression.ts` (`isSuccess`, `nextWeight`, `round5`, `DELOAD_FAILURE_THRESHOLD`, `DELOAD_FACTOR`) per contracts/domain-contracts.md
- [X] T019 [US1] Implement `src/domain/workout.ts` (`buildWorkout(dayKey, programId, currentWeights)` → PrescribedWorkout; every set gets a targetWeight) — depends on T006–T008
- [X] T020 [P] [US1] Implement `src/db/sessionRepo.ts` (`getInProgressSession`, `countCompletedSessions`, `startSession` inserting session + prescribed logged_sets, `completeSession`, `listCompletedSessions`; enforce ≤1 in-progress) — depends on T009
- [X] T021 [P] [US1] Implement `src/db/setRepo.ts` (`getSetsForSession`, `logSet` upsert with completed=1) per contracts/domain-contracts.md — depends on T009
- [X] T022 [US1] Implement `src/hooks/useTodayWorkout.ts` — resume in-progress session or compute next via `countCompletedSessions`→`nextDayKey`→`buildWorkout` from active program + lift_state; lazily `startSession` on first set log — depends on T010, T011, T017, T019, T020, T021
- [X] T023 [P] [US1] Implement the fast weight selector `src/components/WeightSelector.tsx` — large −/＋ stepper (5 lb), big high-contrast value, opens on suggested weight, tap-to-type fallback for arbitrary values (FR-011, SC-002/SC-003)
- [X] T024 [P] [US1] Implement `src/components/RepStepper.tsx` — large −/＋ reps control, pre-set to target reps
- [X] T025 [US1] Implement `src/components/SetRow.tsx` — one prescribed set: target w×reps, WeightSelector + RepStepper, mark-complete, completed vs remaining styling (FR-010/FR-012) — depends on T023, T024
- [X] T026 [US1] Implement `src/components/LiftCard.tsx` — a lift with its ordered SetRows — depends on T025
- [X] T027 [US1] Implement the Today screen `app/(tabs)/index.tsx` — render today's workout via useTodayWorkout + LiftCards, log sets inline, no navigation to reach it (FR-007, SC-001) — depends on T022, T026
- [X] T028 [US1] Wire "Finish workout" in `app/(tabs)/index.tsx` → `completeSession`, then for each lift run `progression.nextWeight` and `liftStateRepo.applyProgression` (FR-016) — depends on T018, T020, T011
- [X] T029 [US1] Add the rest-day / all-complete state to `app/(tabs)/index.tsx` — clear message + next training day when no session is pending (FR-009)

**Checkpoint**: MVP — the full in-gym logging loop works against seeded defaults, persists across restarts (SC-008), and advances weights on finish.

---

## Phase 4: User Story 2 - Pick and configure a program (Priority: P2)

**Goal**: Choose a program (5×5/5×3/3×5), set 3 or 4 days/week, and set/confirm starting weights; today's workout reflects the choices.

**Independent Test**: From Settings (or first-run onboarding), pick a program, set days/week, set starting weights; return to Today and confirm prescriptions match.

### Implementation for User Story 2

- [X] T030 [P] [US2] Implement `src/hooks/useSettings.ts` — reactive read/update of settings + onboarding state over settingsRepo — depends on T010
- [X] T031 [US2] Implement the Settings screen `app/(tabs)/settings.tsx` — program selector from `PROGRAM_LIST` (FR-001/FR-002), 3/4 days toggle (FR-003), per-lift starting-weight editors (FR-005), unit shown as lb read-only (FR-026) — depends on T030, T011, T008
- [X] T032 [US2] Implement the onboarding flow `app/onboarding.tsx` — pick program, days/week, confirm pre-filled starting weights, then `setOnboarded` → redirect to Today; fully skippable (FR-006) — depends on T030, T011
- [X] T033 [US2] Add the onboarding redirect gate to `app/_layout.tsx` — when `settings.onboarded === 0`, redirect to `/onboarding` (but defaults still allow logging) — depends on T012, T032

**Checkpoint**: User can fully configure the program/schedule/starting weights; Today honors them. US1 still works on defaults.

---

## Phase 5: User Story 3 - See progress over time on the four lifts (Priority: P3)

**Goal**: A Progress tab showing each lift's weight trend over time from logged history, with graceful empty states.

**Independent Test**: With history present, open Progress and confirm all four lifts show chronological trends; an untouched lift shows "No data yet".

### Implementation for User Story 3

- [X] T034 [US3] Add `getProgressSeries(db, liftId)` to `src/db/setRepo.ts` — top working weight per completed session for the lift, chronological ascending; `[]` when empty (FR-018/FR-019) — depends on T021, T020
- [X] T035 [P] [US3] Implement `src/hooks/useProgress.ts` — load a per-lift series for each of the four lifts — depends on T034
- [X] T036 [P] [US3] Implement `src/components/ProgressChart.tsx` — simple `react-native-svg` line chart of weight over time, with an empty-state view (FR-019)
- [X] T037 [US3] Implement the Progress screen `app/(tabs)/progress.tsx` — one ProgressChart per lift on a single screen (SC-007) — depends on T035, T036

**Checkpoint**: Progress tab visualizes all four lifts; empty lifts handled cleanly.

---

## Phase 6: User Story 4 - Switch programs without losing history (Priority: P3)

**Goal**: Switching the active program changes future prescriptions but preserves 100% of logged history.

**Independent Test**: With history under one program, switch programs in Settings; Today reflects the new scheme and Progress still shows all prior history.

### Implementation for User Story 4

- [X] T038 [US4] Audit/guarantee `setActiveProgram` in `src/db/settingsRepo.ts` mutates only the `settings` row — never deletes/alters `sessions` or `logged_sets` (FR-021); add a clarifying comment/assertion — depends on T010
- [X] T039 [US4] Ensure `app/(tabs)/index.tsx` + `useTodayWorkout` recompute prescriptions from the active program on focus so a switch takes effect on next Today view (FR-020) — depends on T022, T027
- [X] T040 [US4] In `app/(tabs)/settings.tsx`, highlight the active program and make switching one tap with a "history is preserved" affordance; carry per-lift working weights across the switch — depends on T031

**Checkpoint**: Program switching is non-destructive and immediately reflected; all stories independently functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Quality, the headline UX, and acceptance validation across stories

- [X] T041 [P] Component test `__tests__/components/WeightSelector.test.tsx` — opens on suggested weight; ±5 lb steps; reaches a target in ≤2 interactions; tap-to-type fallback (SC-003)
- [X] T042 [P] Accessibility/touch-target + contrast audit across all screens — primary controls ≥ ~56dp, high contrast, one-handed reachability (FR-025, SC-009)
- [X] T043 [P] Write `README.md` with setup/run/test instructions (mirror quickstart.md)
- [X] T044 Performance pass — verify cold-start-to-Today < 2s and 60fps weight-selector interaction (plan Performance Goals); defer non-essential work off the first render
- [ ] T045 Run the quickstart.md acceptance smoke test end-to-end in Expo Go on iOS and Android (SC-001–SC-010, SC-010 = runs in Expo Go on both platforms)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **User Stories (Phase 3–6)**: All depend on Foundational
  - US1 (P1) has no dependency on other stories (the MVP)
  - US2 (P2) is independent; uses foundational repos
  - US3 (P3) reuses sessionRepo/setRepo from US1 (extends setRepo); easiest after US1 has produced history, but testable with any seeded data
  - US4 (P3) reuses settingsRepo (foundational) + Settings screen (US2); thin but independently testable
- **Polish (Phase 7)**: After the desired user stories are complete

### User Story Dependencies

- **US1 (P1)**: Foundational only → MVP
- **US2 (P2)**: Foundational only
- **US3 (P3)**: Foundational + setRepo/sessionRepo (created in US1). If built before US1, move T020/T021 ahead into Foundational.
- **US4 (P3)**: Foundational + Settings screen from US2 (T031)

### Within Each User Story

- Domain tests (US1) written first and failing before T017–T019
- Domain/pure logic → repositories → hooks → components → screen → wiring
- Story complete and demoable before moving to the next priority

### Parallel Opportunities

- Setup: T003, T004, T005 in parallel
- Foundational: T006, T007, T008 in parallel; then T010, T011 in parallel (after T009)
- US1 tests: T014, T015, T016 in parallel; logic T017, T018 in parallel; repos T020, T021 in parallel; components T023, T024 in parallel
- Across stories: once Foundational is done, US1 and US2 can be built by different developers in parallel

---

## Parallel Example: User Story 1

```bash
# Domain tests first (must fail):
Task: "Catalog test in __tests__/domain/programs.test.ts"
Task: "Schedule test in __tests__/domain/schedule.test.ts"
Task: "Progression test in __tests__/domain/progression.test.ts"

# Then pure logic + repos in parallel:
Task: "Implement src/domain/schedule.ts"
Task: "Implement src/domain/progression.ts"
Task: "Implement src/db/sessionRepo.ts"
Task: "Implement src/db/setRepo.ts"

# Then leaf components in parallel:
Task: "Implement src/components/WeightSelector.tsx"
Task: "Implement src/components/RepStepper.tsx"
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1: Setup
2. Phase 2: Foundational (CRITICAL — blocks all stories)
3. Phase 3: User Story 1 — the in-gym logging loop
4. **STOP and VALIDATE**: open in Expo Go, log a full session against defaults, force-quit/resume, finish and confirm weights advance
5. This is a shippable, demoable MVP on its own

### Incremental Delivery

1. Setup + Foundational → app shell boots in Expo Go
2. + US1 → log workouts (MVP) → demo
3. + US2 → choose program / days / starting weights → demo
4. + US3 → progress charts → demo
5. + US4 → switch programs safely → demo
6. Polish → accessibility, perf, full acceptance run

### Parallel Team Strategy

After Foundational: Dev A → US1 (MVP, priority), Dev B → US2; then US3/US4 layer on once US1's repos and US2's Settings screen exist.

---

## Notes

- [P] = different files, no incomplete dependencies
- [Story] label maps each task to a user story for traceability
- Each user story is independently completable and testable
- Domain tests must fail before implementing the corresponding logic
- Commit after each task or logical group
- Keep all dependencies Expo Go compatible (no Skia/custom native) per plan
- Total tasks: 45 (Setup 5, Foundational 8, US1 16, US2 4, US3 4, US4 3, Polish 5)
