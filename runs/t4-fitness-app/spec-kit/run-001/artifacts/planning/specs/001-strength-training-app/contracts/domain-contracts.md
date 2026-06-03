# Domain & Persistence Contracts

**Feature**: 001-strength-training-app

This app has no external/network API. Its "contracts" are (1) the pure-TypeScript domain functions that encode programs/progression/scheduling and (2) the repository interfaces over SQLite. These signatures are the stable seams the screens and tests build against.

All weights are integers (lb).

---

## Shared types (`src/domain/types.ts`)

```ts
export type LiftId = 'squat' | 'bench' | 'ohp' | 'deadlift';
export type ProgramId = '5x5' | '5x3' | '3x5';
export type DayKey = 'A' | 'B';

export interface Lift {
  id: LiftId;
  name: string;
  increment: number;            // lb added per successful session
  defaultStartingWeight: number;
}

export interface Program {
  id: ProgramId;
  name: string;                 // "5×5"
  sets: number;                 // working sets for non-deadlift lifts
  reps: number;                 // target reps per set
}

export interface DayEntry {
  liftId: LiftId;
  setsOverride?: number;        // deadlift = 1
}

export interface DayTemplate {
  key: DayKey;
  entries: DayEntry[];
}

/** A single prescribed set within today's workout. */
export interface PrescribedSet {
  liftId: LiftId;
  setIndex: number;             // 0-based within the lift
  targetWeight: number;
  targetReps: number;
}

/** Today's workout assembled for the UI. */
export interface PrescribedWorkout {
  dayKey: DayKey;
  programId: ProgramId;
  lifts: Array<{
    liftId: LiftId;
    name: string;
    sets: PrescribedSet[];
  }>;
}

/** Result for one lift used by the progression engine. */
export interface LiftSessionResult {
  liftId: LiftId;
  prescribedSets: number;
  setsHitTarget: number;        // count with actualReps >= targetReps at target weight
}
```

---

## Catalog (`src/domain/lifts.ts`, `src/domain/programs.ts`)

```ts
export const LIFTS: Record<LiftId, Lift>;        // the four lifts + increments
export const LIFT_ORDER: LiftId[];               // canonical display order
export const PROGRAMS: Record<ProgramId, Program>;
export const PROGRAM_LIST: Program[];            // for the selection screen (>= 3, FR-001)
export const DAY_TEMPLATES: Record<DayKey, DayTemplate>;
//   A: [squat, bench]
//   B: [squat, ohp, deadlift(setsOverride:1)]

export function getProgram(id: ProgramId): Program;
export function getLift(id: LiftId): Lift;
```

**Contract**: `PROGRAM_LIST.length >= 3` and contains `5x5`, `5x3`, `3x5` (FR-001). `LIFT_ORDER` lists exactly the four lifts (FR-004).

---

## Scheduling (`src/domain/schedule.ts`)

```ts
/** Next day in the A/B rotation. First session (count 0) → 'A'. */
export function nextDayKey(completedSessionCount: number): DayKey;
// completedSessionCount % 2 === 0 ? 'A' : 'B'
```

**Contract**: deterministic, frequency-independent (research §4). `nextDayKey(0) === 'A'`, `nextDayKey(1) === 'B'`, alternating thereafter.

---

## Workout assembly (`src/domain/workout.ts`)

```ts
/** Build today's prescribed workout from catalog + current per-lift weights. */
export function buildWorkout(
  dayKey: DayKey,
  programId: ProgramId,
  currentWeights: Record<LiftId, number>,
): PrescribedWorkout;
```

**Contract**: For each entry in the day template, emit `entry.setsOverride ?? program.sets` prescribed sets, each at `currentWeights[liftId]` and `program.reps`. Order follows the template. Every prescribed set has a `targetWeight` (FR-008).

---

## Progression engine (`src/domain/progression.ts`)

```ts
export const DELOAD_FAILURE_THRESHOLD = 3;
export const DELOAD_FACTOR = 0.9;

export function isSuccess(r: LiftSessionResult): boolean;
// r.setsHitTarget >= r.prescribedSets

/** Pure next-weight calculation. Returns the new working state for a lift. */
export function nextWeight(input: {
  currentWeight: number;
  increment: number;
  consecutiveFailures: number;
  result: LiftSessionResult;
}): { weight: number; consecutiveFailures: number };
```

**Contract** (research §6):
- success → `{ weight: currentWeight + increment, consecutiveFailures: 0 }`
- failure & `consecutiveFailures + 1 < 3` → `{ weight: currentWeight, consecutiveFailures: +1 }`
- failure & `consecutiveFailures + 1 >= 3` → `{ weight: round5(currentWeight * 0.9), consecutiveFailures: 0 }`
- `round5(x)` = `Math.round(x / 5) * 5`.

---

## Repositories (`src/db/*.ts`) — thin async wrappers over `expo-sqlite`

Each takes the `SQLiteDatabase` from `useSQLiteContext()`.

```ts
// settingsRepo.ts
getSettings(db): Promise<Settings>;                 // creates defaults if missing (FR-006)
updateSettings(db, patch: Partial<Settings>): Promise<void>;
setActiveProgram(db, id: ProgramId): Promise<void>; // never touches sessions/sets (FR-021)
setOnboarded(db): Promise<void>;

// liftStateRepo.ts
getAllLiftState(db): Promise<Record<LiftId, LiftState>>;
setStartingWeight(db, liftId, weight): Promise<void>; // also resets current_weight if no history
applyProgression(db, liftId, weight, consecutiveFailures): Promise<void>;

// sessionRepo.ts
getInProgressSession(db): Promise<Session | null>;  // resume (FR-014)
countCompletedSessions(db): Promise<number>;        // feeds nextDayKey
startSession(db, programId, dayKey, prescribed: PrescribedWorkout): Promise<Session>;
                                                    // inserts session + prescribed logged_sets rows
completeSession(db, sessionId): Promise<void>;      // status→completed, sets completed_at
listCompletedSessions(db, limit?): Promise<Session[]>;

// setRepo.ts
getSetsForSession(db, sessionId): Promise<LoggedSet[]>;
logSet(db, sessionId, liftId, setIndex, actualWeight, actualReps): Promise<void>; // upsert + completed=1 (FR-010/FR-012/FR-013)
getProgressSeries(db, liftId): Promise<Array<{ date: string; weight: number }>>;  // FR-018; [] when empty (FR-019)
```

**Contracts**:
- `getSettings` returns valid defaults on first call (`5x5`, 3 days/week) — the logging loop never blocks on configuration.
- `startSession` fails (or no-ops to the existing one) if an in-progress session exists — at most one (data-model invariant).
- `setActiveProgram` performs no destructive history operations.
- `getProgressSeries` returns chronological ascending rows; empty array signals the empty state.
