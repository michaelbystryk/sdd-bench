# Feature Specification: Strength Training Workout App

**Feature Branch**: `001-strength-training-app`

**Created**: 2026-05-26

**Status**: Draft

**Input**: User description: "Build a strength training app I can use during workouts. Pick a program (5x5, 5x3, plus one more), configure 3 or 4 training days per week, see today's workout on open, log each set with weight and reps, and see progress over time on the four lifts (squat, bench press, overhead press, deadlift). It must feel good mid-workout (sweaty hands, glancing between sets); the weight selector must be fast. Build in Expo for iOS and Android with local storage, no sync, runnable in Expo Go."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Log today's workout mid-session (Priority: P1)

The lifter opens the app at the gym and immediately sees today's workout: each prescribed lift with its target sets, target reps, and a suggested weight already calculated. As they finish each set, they log the actual weight and reps using a fast weight selector, mark the set done, and glance at what's next. The app remembers progress if they switch away between sets.

**Why this priority**: This is the core, in-the-moment value of the product — the thing the user does every training day. Everything else exists to support this loop. Without it, there is no app.

**Independent Test**: With a default program already active (seeded on first launch), open the app, confirm today's workout appears immediately with suggested weights, log every set for the session using the weight/reps controls, and confirm the session is saved. Fully demonstrates value on its own.

**Acceptance Scenarios**:

1. **Given** an active program and a scheduled workout for today, **When** the user opens the app, **Then** today's workout is the first thing shown — listing each lift, target sets, target reps, and a suggested weight per set — with no navigation required.
2. **Given** today's workout is displayed, **When** the user logs a set's weight and reps and marks it complete, **Then** the set is recorded, visually marked as done, and the next set/lift is clearly indicated.
3. **Given** the user is adjusting weight, **When** they use the weight selector, **Then** they can reach the desired weight in standard plate increments within a couple of quick interactions, pre-centered on the suggested weight.
4. **Given** a partially logged workout, **When** the user closes and reopens the app, **Then** the logged sets are still present and the user can resume where they left off.
5. **Given** all prescribed sets are logged, **When** the user finishes the session, **Then** the workout is saved to history and the next workout becomes "today's workout."
6. **Given** the user logged a set incorrectly, **When** they edit that set within the current session, **Then** the corrected weight/reps are saved.

---

### User Story 2 - Pick and configure a program (Priority: P2)

The lifter chooses a training program from a list (5×5, 5×3, 3×5), sets how many days per week they train (3 or 4), and confirms or adjusts the starting working weight for each of the four lifts. From then on, the app schedules and prescribes workouts according to that program.

**Why this priority**: Personalizes the experience to the user's program and schedule. Story 1 works against a sensible default without this, but this story makes the prescriptions match what the user actually wants to run.

**Independent Test**: From a fresh state, open program selection, choose a program, set days per week to 3 or 4, set starting weights for the four lifts, and confirm that today's workout reflects the chosen program and schedule.

**Acceptance Scenarios**:

1. **Given** the program list, **When** the user views available programs, **Then** at least three options are shown (5×5, 5×3, 3×5), each clearly labeled.
2. **Given** a selected program, **When** the user sets training frequency, **Then** they can choose either 3 or 4 days per week and the schedule updates accordingly.
3. **Given** a selected program, **When** the user sets the starting working weight for each of the four lifts, **Then** those weights seed the first prescribed workout's suggested weights.
4. **Given** a configured program, **When** the user returns to today's workout, **Then** the prescribed lifts, sets, reps, and weights match the selected program and frequency.

---

### User Story 3 - See progress over time on the four lifts (Priority: P3)

The lifter reviews how each of the four lifts (squat, bench press, overhead press, deadlift) has progressed over time, seeing their weight trend across past sessions.

**Why this priority**: Provides motivation and confirmation that the program is working. Valuable but not required for the daily logging loop.

**Independent Test**: With workout history present, open the progress view and confirm that each of the four lifts shows its weight progression over time from past logged sessions.

**Acceptance Scenarios**:

1. **Given** logged workout history, **When** the user opens the progress view, **Then** they can see, for each of the four lifts, how the working weight has changed over time.
2. **Given** a lift with no history yet, **When** the user views progress for it, **Then** the app clearly indicates there is no data yet rather than showing an error.
3. **Given** multiple sessions of history, **When** the user views a lift's progress, **Then** the data is presented in chronological order.

---

### User Story 4 - Switch programs without losing history (Priority: P3)

The lifter decides to change programs (e.g., from 5×5 to 5×3). They switch the active program, and all of their previously logged workout history remains intact and visible in progress.

**Why this priority**: The user explicitly wants to switch programs occasionally without losing history. It builds on Stories 1–3 and protects accumulated data.

**Independent Test**: With history under one program, switch to a different program, confirm new prescriptions follow the new program, and confirm all prior history is still accessible in the progress view.

**Acceptance Scenarios**:

1. **Given** an active program with logged history, **When** the user switches to a different program, **Then** the newly active program governs future prescribed workouts.
2. **Given** a program switch has occurred, **When** the user opens the progress view, **Then** 100% of previously logged history is still present.
3. **Given** a program switch, **When** the user returns to it later by switching back, **Then** prior history continues to inform that program's progression.

---

### Edge Cases

- **First launch / no program chosen**: The app seeds a sensible default program and frequency so the user can begin immediately, and prompts (non-blocking) to confirm starting weights.
- **Rest day**: When the current day has no scheduled session, the app clearly shows it is a rest day rather than an empty workout, and indicates the next training day.
- **First time performing a lift (no prior data)**: The suggested weight falls back to the user-provided starting weight for that lift.
- **Missed/failed set (fewer reps than target)**: Progression holds or reduces the next suggested weight per the program's rules rather than always increasing it.
- **Interrupted session**: A workout logged partially is preserved across app restarts and can be resumed.
- **Editing past entries**: The user can correct a set within the active session; behavior for editing historical sessions is out of scope for v0.1.
- **Skipping a set or lift**: The user can leave a set unlogged and still complete/finish the session.
- **Awkward target weights**: The weight selector still lets the user reach non-standard values quickly (e.g., microplates or unusual loads), not only round increments.
- **Long gap between sessions**: Reopening after days/weeks still shows the next scheduled workout based on rotation, not a missed-day error.

## Requirements *(mandatory)*

### Functional Requirements

**Programs & configuration**

- **FR-001**: System MUST offer at least three selectable training programs: 5×5 (five sets of five reps), 5×3 (five sets of three reps), and 3×5 (three sets of five reps).
- **FR-002**: System MUST allow the user to select exactly one program as active.
- **FR-003**: System MUST allow the user to configure training frequency as either 3 or 4 days per week.
- **FR-004**: System MUST support the four lifts — squat, bench press, overhead press, and deadlift — as the trackable movements.
- **FR-005**: System MUST allow the user to set and confirm a starting working weight for each of the four lifts, which may be pre-filled with sensible defaults.
- **FR-006**: System MUST seed a default program and frequency on first launch so a new user can begin logging without first completing configuration.

**Today's workout**

- **FR-007**: When an active program exists, the system MUST present today's (next) workout immediately on open, showing each prescribed lift with its target sets, target reps, and a suggested weight, without requiring navigation.
- **FR-008**: System MUST automatically calculate and display a suggested weight for every prescribed set so that the user is never required to perform weight math.
- **FR-009**: System MUST clearly indicate when the current day is a rest day (no scheduled session) and identify the next training day.

**Logging sets**

- **FR-010**: Users MUST be able to log each set's actual weight and actual reps as they perform it.
- **FR-011**: System MUST provide a fast weight selector that opens centered on the suggested weight and supports rapid adjustment in standard plate increments, while still allowing the user to reach arbitrary values.
- **FR-012**: System MUST let the user mark a set complete and MUST visually distinguish completed sets from remaining sets.
- **FR-013**: Users MUST be able to edit or correct a logged set within the current (in-progress) session.
- **FR-014**: System MUST persist an in-progress workout so the user can close the app and resume the same session later without data loss.
- **FR-015**: System MUST record completed sessions to a persistent workout history.

**Progression (next weight)**

- **FR-016**: System MUST apply the active program's progression rules to determine the next suggested weight for each lift based on prior logged performance — increasing the weight after a successful session and holding or reducing it after a missed target.
- **FR-017**: For a lift with no prior history, the system MUST use the user's configured starting weight as the suggested weight.

**Progress over time**

- **FR-018**: System MUST display the user's weight progression over time for each of the four lifts, derived from logged history, in chronological order.
- **FR-019**: System MUST handle lifts with no history gracefully, indicating the absence of data rather than erroring.

**Switching programs & preserving history**

- **FR-020**: Users MUST be able to switch the active program at any time.
- **FR-021**: System MUST preserve 100% of previously logged workout history when the user switches programs.

**Storage, platform & single-user model**

- **FR-022**: System MUST store all data locally on the device and function fully without a network connection.
- **FR-023**: System MUST NOT require an account, sign-in, or cloud synchronization (single-user, on-device).
- **FR-024**: System MUST run on both iOS and Android.

**Mid-workout usability**

- **FR-025**: System MUST present today's workout and logging controls with large, high-contrast, glanceable touch targets suitable for one-handed use and imprecise (sweaty-handed) taps.
- **FR-026**: System MUST display weights in pounds (lb) by default.

### Key Entities *(include if feature involves data)*

- **Program**: A named training plan (5×5, 5×3, 3×5). Defines the set/rep scheme, the workout-day templates (which lifts are trained on each session), and the progression rules used to compute next weights.
- **Program Configuration / Settings**: The user's active program, training frequency (3 or 4 days/week), unit (lb), and starting working weight per lift.
- **Lift (Exercise)**: One of the four movements (squat, bench press, overhead press, deadlift), each with a current working weight derived from history or starting weight.
- **Workout (Session)**: A single training session belonging to a program — its scheduled position in the rotation, the prescribed lifts/sets, completion state (in-progress or completed), and timestamp.
- **Set**: A single logged set within a session for a given lift, holding the target weight/reps and the actual logged weight/reps plus a completion flag.
- **History**: The accumulated record of completed sessions and their sets across all programs, used to render progress and feed progression calculations; persists across program switches.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: With an active program, opening the app shows today's workout as the first screen with zero navigation taps required.
- **SC-002**: A user can log a completed set (weight + reps) in 3 taps or fewer and in under 5 seconds.
- **SC-003**: From the suggested weight, the user can reach any standard target weight using the weight selector in 2 interactions or fewer.
- **SC-004**: 100% of prescribed sets display an automatically suggested weight, so the user performs no manual weight calculation during a workout.
- **SC-005**: A new user can go from first launch to logging their first set in under 2 minutes.
- **SC-006**: After switching programs, 100% of previously logged workout history remains accessible in the progress view.
- **SC-007**: The user can view weight progress for each of the four lifts from a single progress screen.
- **SC-008**: An in-progress workout survives an app close/reopen with no logged sets lost (0% data loss on resume).
- **SC-009**: Primary logging controls (weight selector, reps, mark-complete) are large enough to operate one-handed and readable at arm's length while standing at a barbell.
- **SC-010**: The app installs and runs on both iOS and Android via Expo Go.

## Assumptions

- **Third program choice**: The undecided third program is **3×5** (three sets of five reps). It was chosen because it follows the same linear "next weight = previous weight + fixed increment" progression model as 5×5 and 5×3, keeping the automatic weight-suggestion behavior uniform across all programs and directly supporting the "no math mid-workout" requirement.
- **Single user**: The app is for one person on their own device; no multi-user, profiles, accounts, or sharing.
- **Units**: Pounds (lb) is the default and only required unit for v0.1, consistent with the reference numbers provided (Bench 225, Squat 315, Deadlift 405, OHP 145). A kilograms toggle is out of scope for v0.1.
- **Starting weights**: On first run the four lifts may be pre-filled with sensible defaults (optionally informed by the user's known working numbers) and are user-adjustable before or during the first session.
- **"Today's workout" semantics**: Sessions follow the program's rotation. "Today's workout" means the next uncompleted session in the rotation; the app does not enforce strict calendar-day scheduling and tolerates gaps between sessions.
- **Progression defaults**: Each program increases the working weight by a fixed per-lift increment after a successful session (commonly larger for squat/deadlift than for bench/overhead press) and holds or reduces it after a missed target. Exact increment values are program defaults defined during planning.
- **Workout-day templates**: Each program defines a small number of alternating session templates covering the four lifts; the 3-or-4-days-per-week setting controls how many sessions are scheduled per week. Exact lift groupings per day are program defaults defined during planning.
- **Default program on first launch**: The app activates a reasonable default (e.g., 5×5 at 3 days/week) so the core logging loop is usable before the user configures anything.

### Out of Scope (v0.1)

- Cloud sync, backup, multi-device, or account/sign-in.
- Custom or user-authored programs beyond the three presets.
- Accessory/assistance lifts or any movements beyond the four named lifts.
- Editing or deleting historical (already-completed) sessions.
- Rest timers, plate-loading breakdown visuals, warm-up set calculators, body-weight or nutrition tracking, and social/sharing features.
- Kilograms unit support.
