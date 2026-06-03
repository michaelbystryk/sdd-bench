# Screen & Navigation Contract

**Feature**: 001-strength-training-app | Navigation: Expo Router (file-based)

Three bottom tabs plus a first-run onboarding route. The default tab is **Today**, so opening the app lands directly on today's workout (SC-001).

```text
app/
├── _layout.tsx          Root: <SQLiteProvider> + theme; redirects to /onboarding when settings.onboarded = 0
├── onboarding.tsx       First-run program config (US2) — skippable; logging works on defaults (FR-006)
└── (tabs)/
    ├── _layout.tsx      <Tabs> Today | Progress | Settings; initial route = index (Today)
    ├── index.tsx        TODAY  (US1)
    ├── progress.tsx     PROGRESS (US3)
    └── settings.tsx     SETTINGS (US2 / US4)
```

---

## Today (`(tabs)/index.tsx`) — US1, the in-gym loop

**Shows**: the prescribed workout for the next session in the A/B rotation — each lift as a `LiftCard` with its prescribed sets (`SetRow`), each row showing target weight × target reps and the suggested weight pre-filled (FR-007/FR-008). Resumes an in-progress session if one exists (FR-014).

**Contract**:
- On mount: `getInProgressSession`; if none, compute `nextDayKey(countCompletedSessions)`, `buildWorkout(...)`, and create the session lazily on first set log.
- Each `SetRow` opens the `WeightSelector` centered on the suggested weight and a `RepStepper` pre-set to target reps; "mark complete" calls `logSet` (≤3 taps, <5s — SC-002).
- Completed sets are visually distinct from remaining (FR-012).
- "Finish workout" → `completeSession` → runs progression per lift (FR-016) → returns to a fresh Today.
- **Rest-day / all-done state**: when appropriate, shows a clear rest-day message and the next training day (FR-009), not an empty screen.
- **First-run state**: renders today's workout against default settings even before onboarding (FR-006).

**Key components**: `LiftCard`, `SetRow`, `WeightSelector`, `RepStepper`.

## Progress (`(tabs)/progress.tsx`) — US3

**Shows**: per-lift weight-over-time, one `ProgressChart` per lift (all four reachable on a single screen — SC-007), chronological (FR-018).

**Contract**:
- Calls `getProgressSeries(liftId)` for each lift.
- Empty series → explicit "No data yet" empty state, never an error (FR-019).

## Settings (`(tabs)/settings.tsx`) — US2 & US4

**Shows**: active program (selectable from `PROGRAM_LIST`, ≥3 options — FR-001/FR-002), days-per-week toggle (3 or 4 — FR-003), and starting weight per lift (FR-005).

**Contract**:
- Selecting a program → `setActiveProgram`; **no history is deleted** (FR-020/FR-021). Today's prescriptions reflect the new scheme on next visit.
- Days-per-week → `updateSettings({ days_per_week })`.
- Editing a starting weight → `setStartingWeight`; resets `current_weight` only for lifts with no logged history.
- Unit displayed as lb (read-only in v0.1 — FR-026).

## Onboarding (`onboarding.tsx`) — US2 first-run

**Shows**: pick a program, choose 3/4 days, confirm starting weights (pre-filled with defaults). "Done" → `setOnboarded` → redirect to Today.

**Contract**: Fully skippable — defaults already let the user log immediately (FR-006); reachable later via Settings.

---

## Cross-cutting UI contract (mid-workout usability — FR-025, SC-009)

- Primary controls (weight ±, reps ±, mark-complete) use large touch targets (≥ ~56dp) and high-contrast colors, operable one-handed and readable at arm's length.
- The weight selector opens on the suggested value; reaching a standard target takes ≤2 interactions (SC-003), with a tap-to-type fallback for arbitrary weights.
- No modal blocks the next set; logging is inline and immediate (each set persists on log — SC-008).
