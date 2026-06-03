# Phase 1 Data Model: Strength Training Workout App

**Date**: 2026-05-26 | **Feature**: 001-strength-training-app

Two kinds of data:

- **Catalog (code constants, not persisted)** — the four lifts, the three programs, day templates, increments. Defined in `src/domain/`.
- **Persisted state (SQLite)** — user settings, per-lift working state, sessions, and logged sets.

All weights are integers in **pounds (lb)**. Timestamps are ISO-8601 strings (or Unix ms) in UTC.

---

## Catalog entities (constants)

### Lift

The four trackable movements. Identified by a stable string id.

| Field | Type | Notes |
|-------|------|-------|
| `id` | `'squat' \| 'bench' \| 'ohp' \| 'deadlift'` | Stable key used everywhere |
| `name` | string | Display name (e.g., "Bench Press") |
| `increment` | int (lb) | Per-success linear increment: squat 5, bench 5, ohp 5, deadlift 10 |
| `defaultStartingWeight` | int (lb) | First-run placeholder (user-editable): e.g. squat 135, bench 95, ohp 65, deadlift 135 |

### Program

A named scheme. Programs differ **only** by working-set count and reps.

| Field | Type | Notes |
|-------|------|-------|
| `id` | `'5x5' \| '5x3' \| '3x5'` | Stable key; stored as `settings.active_program_id` |
| `name` | string | "5×5", "5×3", "3×5" |
| `sets` | int | Working sets for non-deadlift lifts (5, 5, 3) |
| `reps` | int | Target reps per set (5, 3, 5) |

### DayTemplate

The A/B rotation (shared across all programs). Each entry lists the lifts trained and how many working sets each uses.

| Field | Type | Notes |
|-------|------|-------|
| `key` | `'A' \| 'B'` | Rotation slot |
| `entries` | `DayEntry[]` | Ordered lifts for the session |

**DayEntry**: `{ liftId, setsOverride? }` — `setsOverride` lets deadlift use **1** working set regardless of program; otherwise `program.sets` applies.

- **Day A**: Squat, Bench Press
- **Day B**: Squat, Overhead Press, Deadlift (`setsOverride = 1`)

---

## Persisted entities (SQLite)

### settings (single row, `id = 1`)

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | INTEGER | PK, always 1 | Enforces single row |
| `active_program_id` | TEXT | NOT NULL | One of the program ids |
| `days_per_week` | INTEGER | NOT NULL, CHECK in (3,4) | FR-003 |
| `unit` | TEXT | NOT NULL DEFAULT 'lb' | lb only in v0.1 |
| `onboarded` | INTEGER | NOT NULL DEFAULT 0 | 0/1; gates onboarding flow |
| `created_at` | TEXT | NOT NULL | |
| `updated_at` | TEXT | NOT NULL | |

**Defaults on first launch (FR-006)**: `active_program_id='5x5'`, `days_per_week=3`, `onboarded=0`. The core logging loop works immediately against these defaults even before onboarding is completed.

### lift_state (one row per lift, 4 rows)

Per-lift working weight, starting weight, and failure streak — shared across programs (research §7).

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `lift_id` | TEXT | PK | squat / bench / ohp / deadlift |
| `starting_weight` | INTEGER | NOT NULL | User-set/confirmed (FR-005); seeds first suggestion |
| `current_weight` | INTEGER | NOT NULL | Next prescribed weight (FR-008/FR-016) |
| `consecutive_failures` | INTEGER | NOT NULL DEFAULT 0 | Drives deload after 3 (research §6) |
| `updated_at` | TEXT | NOT NULL | |

Seeded with `current_weight = starting_weight = defaultStartingWeight` on first launch; user can edit starting weights in onboarding/settings, which also resets `current_weight` for any lift with no logged history.

### sessions

One training session in the rotation.

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | INTEGER | PK AUTOINCREMENT | |
| `program_id` | TEXT | NOT NULL | Program active when the session ran (history keeps its own program) |
| `day_key` | TEXT | NOT NULL, CHECK in ('A','B') | Which template |
| `status` | TEXT | NOT NULL, CHECK in ('in_progress','completed') | FR-014/FR-015 |
| `started_at` | TEXT | NOT NULL | |
| `completed_at` | TEXT | NULL | Set when status → completed |

**Invariant**: at most one `status='in_progress'` session at a time (the resumable session).

**Index**: `idx_sessions_status` on (`status`), `idx_sessions_completed_at` on (`completed_at`).

### logged_sets

One row per set within a session (target + actual).

| Column | Type | Constraints | Notes |
|--------|------|-------------|-------|
| `id` | INTEGER | PK AUTOINCREMENT | |
| `session_id` | INTEGER | NOT NULL, FK → sessions(id) ON DELETE CASCADE | |
| `lift_id` | TEXT | NOT NULL | |
| `set_index` | INTEGER | NOT NULL | 0-based order within the lift |
| `target_weight` | INTEGER | NOT NULL | Prescribed suggested weight |
| `target_reps` | INTEGER | NOT NULL | Program rep target |
| `actual_weight` | INTEGER | NULL | Logged by user (FR-010) |
| `actual_reps` | INTEGER | NULL | Logged by user |
| `completed` | INTEGER | NOT NULL DEFAULT 0 | 0/1 mark-complete (FR-012) |
| `logged_at` | TEXT | NULL | Set when user logs the set |

**Unique**: (`session_id`, `lift_id`, `set_index`) — one row per prescribed set; logging/editing upserts (FR-013).

**Index**: `idx_logged_sets_session` on (`session_id`), `idx_logged_sets_lift` on (`lift_id`, `logged_at`) for progress queries.

---

## Relationships

```text
settings (1 row) ── active_program_id ──▶ Program (catalog)
lift_state (4 rows) ── lift_id ──▶ Lift (catalog)

sessions (1..n)
   └──< logged_sets (n)            [session_id FK, cascade delete]
          └── lift_id ─▶ Lift (catalog)

DayTemplate (catalog) ── entries ─▶ Lift (catalog)   # shapes a session's prescribed sets
```

---

## Derived values (computed, not stored)

- **Today's workout** = `schedule.nextDayKey(completedSessionCount)` → DayTemplate → for each entry, build prescribed sets from `program.sets`/`reps` (or `setsOverride`) at `lift_state.current_weight`. Assembled by `useTodayWorkout`.
- **Suggested weight** for a set = `lift_state.current_weight` (FR-008); falls back to `starting_weight` when no history (FR-017) — already reflected because `current_weight` seeds from `starting_weight`.
- **Progress series** for a lift = top `actual_weight` (or `target_weight`) per completed session for that lift, ordered by `completed_at` (FR-018). Empty array → empty state (FR-019).

---

## State transitions

### Session lifecycle

```text
(none) ──user logs first set of today's workout──▶ in_progress
in_progress ──reopen app──▶ in_progress (resumed; FR-014/SC-008)
in_progress ──user finishes session──▶ completed
   └─ on completion: for each lift in the session, run progression →
      update lift_state.current_weight + consecutive_failures (FR-016)
```

### Lift progression (on session completion, per lift)

```text
all working sets hit target reps?
 ├─ yes (success) → current_weight += increment; consecutive_failures = 0
 └─ no  (failure) → consecutive_failures += 1
        └─ if consecutive_failures >= 3 → current_weight = round5(current_weight * 0.9);
                                          consecutive_failures = 0
```

`round5(x)` = nearest multiple of 5 lb.

---

## Validation rules (from requirements)

- `days_per_week ∈ {3,4}` (FR-003) — DB CHECK + UI control.
- `unit = 'lb'` (FR-026) — fixed in v0.1.
- `active_program_id ∈ {5x5,5x3,3x5}` (FR-001/FR-002) — validated against catalog.
- Weights and reps are non-negative integers; `target_weight`/`target_reps` always present for prescribed sets.
- At most one in-progress session (enforced in `sessionRepo` before creating a new one).
- Switching program updates only `settings.active_program_id`; never deletes `sessions`/`logged_sets` (FR-021).
