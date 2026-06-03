# T4 — Success Criteria (v0.1)

T4-specific scoring. Applied after a cell completes; used identically across methodologies.

Universal rubric (anchors, defect-count protocol, blinding) lives at [`harness/scoring-rubric.md`](../../harness/scoring-rubric.md). This file declares the T4-specific binary outcomes, which dimensions apply, and task-specific scoring detail.

---

## 1. Binary outcomes (pass/fail, reported as a list)

| Outcome | Pass condition |
|---|---|
| **Builds in Expo Go** | `npx expo start` succeeds and the app loads on at least one of {iOS Expo Go, Android Expo Go} without crash within 60s of launch. |
| **Four lifts present** | Squat, bench press, overhead press, deadlift all selectable / loggable. |
| **Today's workout view** | App shows the user's next/today's workout on open or within one tap of open. |
| **Set logging works** | User can record at least weight + reps for each set and the value persists across app reload. |
| **History persists** | Logged sets are retrievable after closing and reopening the app (SQLite or AsyncStorage acceptable). |
| **Program selection works** | User can pick at least one of {5x5, 5x3, third-program-of-methodology's-choice}. |
| **Days/week selectable** | App lets the user pick 3 or 4 day/week schedule (or commits to one with a documented reason). |

A cell that fails "Builds in Expo Go" still scores all other dimensions where evidence exists (code, plans, etc.) — failure is data.

---

## 2. Dimensions applied (per applicability matrix)

All twelve dimensions apply to T4. UX and UI design are particularly load-bearing — T4 explicitly tests product-scoping discipline under physical-use constraints.

Score each per anchors in `harness/scoring-rubric.md`. Equal-weight sum across all twelve.

---

## 3. T4-specific scoring detail

These supplement (not replace) the universal anchors with task-specific observables.

### Functionality — 5x5 progression specifics

To score 4+ on Functionality, the implementation must encode canonical 5x5 progression:
- +5 lb per session on upper-body lifts (bench, OHP) after successful completion
- +10 lb per session on lower-body lifts (squat, deadlift) after successful completion
- Deload to 90% (10% drop) after 3 consecutive failed sessions on a given lift

If the methodology selected a non-5x5 program for the "pick one" slot, score the canonical progression for that program (5/3/1, Madcow, Texas Method, etc.).

### UX — mid-workout affordances

To score 4+ on UX, the implementation must demonstrate at least three of:
- Large tap targets (44×44pt minimum) for set-logging actions
- Dark mode (default or selectable)
- "Next weight" shown without requiring user math
- Screen-stay-awake during active workout
- Single-tap weight increments (no keyboard required for common weights)
- One-handed reachability for common actions

### UI design — sweaty-hands signal

Score 5 only if the UI shows evidence the methodology thought about the actual use context — not just claimed it. E.g., oversized log buttons, anti-mis-tap spacing, low-glance information density, set-logging that doesn't require a modal.

---

## 4. Scope-handling notes (qualitative, for observations.md)

T4 has four deliberate vague spots. Don't just count clarifying questions — characterize what the methodology *did with the ambiguity*:

| Vague spot | What to capture |
|---|---|
| "plus one I haven't decided yet — pick one" | Was it raised? What was picked? Was the choice defensible? |
| "feel good to use mid-workout" | Engaged with as a UX brief or treated as flavor text? |
| "see my progress over time" | What representation was chosen (chart / table / both) and why? |
| Auth / account / sync / sharing — never mentioned | Surfaced as a scoping call or silently in/out-scoped? |

These feed into the Scope Clarity and Assumption Surfacing scores plus the failure-mode characterization.

---

*v0.1 locked. Edits in v0.2+ must be backwards-compatible with v0.1 scoring or note the migration explicitly.*
