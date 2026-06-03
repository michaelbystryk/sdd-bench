# T4-vibe / Run 001 / Observations

Filled in during scoring (typically next-day, separate session from the run). Uses [`harness/scoring-rubric.md`](../../../../harness/scoring-rubric.md) and [`tasks/t4-fitness-app/success-criteria.md`](../../../../tasks/t4-fitness-app/success-criteria.md).

**Reviewer:** Operator
**Scored on:** 2026-05-25
**Methodology revealed at:** n/a (unblinded — Vibe is the control; scored with methodology known)

---

# QUALITY AXIS

## Dimension scores (0–5 per harness/scoring-rubric.md)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | 3 | All behaviors work on the happy path (5×5 solid); held down by 5/3/1 being unrunnable in the UI + missing rest-timer/edit. |
| 2 | Correctness | (see defect block below) | 0 crit / 1 major / 5 minor |
| 3 | Code quality | 4 | Strong TS discipline + `ProgramMeta` registry abstraction; held off 5 by sl5x5/gp5x3 copy-paste + dead ternary + inconsistent store subscription. |
| 4 | System design | 3.5 | Clean layering + program-registry absorbs "add a program"; but single-blob data model isn't future-proof and the UI/data per-set-weight model diverges. (Half-point per v0.1.2.) |
| 5 | UI design | 4.5 | Real design-token system, sweaty-hands affordances visible (oversized targets, modal-free logging, gold completed-state); just shy of 5 (placeholder tab glyphs, basic chart). |
| 6 | UX | 3.5 | Frictionless 1-tap linear logging + 5/6 mid-workout affordances, but the two missing ones are must-haves (keep-awake, rest timer) and there's real non-checklist friction (no set guidance, broken Wendler logging). (Half-point per v0.1.2.) |
| 7 | Robustness | 4 | Bad input designed out (steppers + clamps), thoughtful edge-case handling (empty/single/flat chart, divide-by-zero, hydration gate, confirm dialogs); held off 5 by no storage migration/error boundary. |
| 8 | Security | 3 | Clean by construction (no vulns, no secrets, pinned deps + lockfile); low-signal dimension for a local single-user app. |
| 9 | Documentation | 2.5 | Genuinely good inline why-comments (3-grade), but no README at all (Vibe said it would add one and didn't) and no decision records. |
| 10 | Spec articulation | 0 | No spec artifact — no PRD/acceptance criteria; only an in-chat brief-reading + ephemeral TaskCreate todos. Per Vibe note, 0 = the data. |
| 11 | Scope clarity | 1 | A build-plan was stated (implicit in-scoping) but zero out-of-scope statement; auth/sync/sharing/backup all silently cut with no reasons. |
| 12 | Assumption surfacing | count: 0 / quality: 0 | No `[ASSUMPTION]` tags / ADRs / decision log anywhere; implicit assumptions (intermediate-4-day, default 1RMs, imperial plates) baked into code unflagged. |

**Quality sum (11 scored dimensions, max 55):** **29**

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | 0 |
| Major | 0 | 1 | 1 | 1 |
| Minor | 0 | 3 | 5 | 5 |

(No automated tests exist in the project — all defects from manual/live exercise (M) and code review (R). M/R columns count where each defect was *confirmed*; several were found in review and confirmed live, listed once.)

LOC produced: ~2,017 net (2,070 added − 53 removed)
Files touched/produced: 18 TS/TSX files
**Defects per 1KLOC:** 6 / 2.017 = **2.97**

Itemize each defect inline below (severity / source / one-line description):

1. **Major / R+M** — `finishActiveWorkout` per-set weight handling for %-based programs: the workout UI shows a single working-weight stepper with no per-set targets and flattens the prescribed 75/85/100 ramp; touching the stepper overwrites all sets. 5/3/1 cannot be executed/logged correctly. Data is correct only if the stepper is left untouched. Confirmed live on the OHP day.
2. **Minor / R+M** — `finishActiveWorkout` does not auto-complete untouched sets despite its comment claiming it does. Untouched sets resolve to `completed:false, actualReps:0`, which `applyCompletion` reads as a failed session (fail-count++ → eventual unearned deload). Behavior is defensible under an explicit-logging model (incomplete session ≠ progression), so downgraded from the initial Critical call; residual issue is the misleading comment + no "unlogged sets" guard. Confirmed live (Bench → 0 sessions after finishing without tapping Bench sets).
3. **Minor / R+M** — Finishing a workout auto-spawns the next workout as `active` (effect race in `workout.tsx` as `activeWorkout` goes null during `router.back()`), so Today shows "Resume workout" right after finishing. Confirmed live.
4. **Minor / R+M** — Today screen headlines `sets[0]` weight; for %-based programs that's the *lightest* set (OHP showed 75, not the ~100 top set). Fine for flat-weight 5×5/5×3. Confirmed live.
5. **Minor / R+M** — `daysPerWeek` is a no-op for Wendler (`buildNextWorkout` ignores it; only 5×5/5×3 switch THREE_DAY/FOUR_DAY templates). Confirmed live.
6. **Minor / R** — History row renders `weight × total-reps` ("SQ 250×25"), which misreads as 25 reps.

## Binary outcomes (pass/fail per tasks/t4-fitness-app/success-criteria.md)

- [x] Builds in Expo Go — verified running in the Expo Go runtime on iOS 26.5 sim (upgraded from prior bundle-only evidence; physical-device still untested)
- [x] Four lifts present — all four in setup + generated workouts
- [x] Today's workout view — lands directly on Today showing the day's workout
- [x] Set logging works — logged 2/10, gold ✓ state, counter updated; persisted
- [x] History persists — survived full terminate + relaunch (Squat 1 session @ 250)
- [x] Program selection works — switched 5×3 → 5/3/1, Today updated, history preserved
- [x] Days/week selectable — 3/4 toggle in Setup and Settings (functional for 5×5/5×3; no-op for Wendler, see defect 5)

**Pass count: 7 / 7**

(All seven confirmed live via idb-driven simulator walkthrough on 2026-05-25, not code-inference.)

---

# COST AXIS

## Raw metrics (from session-log.md and token-log.md)

| Metric | Value |
|---|---|
| Total tokens | 7,007,280 (~7.0M; 6.8M of it cache-read) |
| Implied API cost | $5.84 |
| Active wall-clock (excl. rate-limit pauses) | 0h 19m 45s |
| Operator-touch time | 0 min |
| Operator intervention count | 0 |
| Time to first working build | ~18m (first clean iOS bundle per transcript at ~21:26; not separately stopwatched) |

**Phase breakdown** (feeds methodology overhead ratio):
- Planning phases total: n/a (no explicit pre-implementation phases — Vibe is the control)
- Implementation phase total: ~19m 45s (whole session)

## Derived ratios

| Ratio | Value | Cross-methodology rank (fill after all 4 runs) |
|---|---|---|
| Quality per 1K tokens | 0.0041 (≈4.1 per 1M tok) | _ |
| Quality per API hour | 99.7 | _ (29 / 0.2908 h = 17m27s API compute) |
| Defects per 1KLOC | 2.97 | _ |
| Methodology overhead ratio | n/a | _ |
| Cost per binary outcome | $0.83 | _ |
| Quality per dollar | 4.97 | _ |

---

# HEADLINE FINDING

```
Quality: 29 / 55  ·  Cost: $5.84 / 0h 20m  ·  Binary: 7 / 7 pass
```

**One-line verdict** (for the writeup — single sentence covering BOTH axes):

> Vibe shipped a polished, fully-working app — 7/7 binaries, in 20 minutes for $5.84 with zero interventions — but scored 29/55, with nearly the entire deficit concentrated in the SDD dimensions it has no layer to address (spec 0, scope 1, assumptions 0/0, docs 2.5): maximal execution velocity, zero discovery discipline.

---

## Scope-handling notes

How did the methodology engage with T4's four deliberate vague spots?

- **"plus one I haven't decided yet — pick one":** Picked Wendler 5/3/1, with a one-line in-chat rationale ("fits the user's intermediate-4-day pattern"). Defensible choice. But it then built a set-logging UI that only works for flat-weight programs, so the program it chose can't actually be run correctly (defect 1). Choice good; execution of the choice incomplete.
- **"feel good to use mid-workout":** Engaged as a real UX brief, not flavor — dedicated fast `Stepper` (tap ±5 / long-press ±25 repeat, no keyboard), oversized targets, dark "gym lighting / sweaty thumbs" theme, modal-free inline logging. But missed the two most use-context-specific affordances: **rest timer** and **screen-keep-awake** — both implied by "between sets… glancing at it."
- **"see my progress over time":** Chose a per-lift SVG line chart (top set × date) plus a recent-sessions list. Representation reasonable; reasoning not documented anywhere. Chart handles 0/1/flat-series gracefully.
- **Auth / account / sync / sharing (never mentioned in brief):** Silently out-scoped — never surfaced as a scoping call or assumption. Same for cloud backup/export (data is on-device only; loss on uninstall or schema-change). This is the cleanest instance of the discovery gap.

## Failure mode characterization

- **Where Vibe broke down:** Not in execution — in *discovery*. It made every ambiguous decision silently and correctly-enough, but surfaced none of them, produced no spec, stated no scope, flagged no assumptions, and wrote no README. The SDD-cluster dimensions (spec 0, scope 1, assumptions 0/0) account for almost the entire 26-point gap to 55.
- **Categories of mistake:** (a) UI/data model divergence — modeled per-set weights correctly in data but built a single-weight UI, breaking the %-based program it chose; (b) self-contradicting code (the `finishActiveWorkout` comment vs behavior); (c) feature omission of mature-app table stakes (rest timer, keep-awake, set guidance, edit, backup) because nothing prompted it.
- **What it did surprisingly well:** Canonical progression math across all three programs; a genuinely good `ProgramMeta` strategy abstraction; real sweaty-hands UI polish; thoughtful robustness (chart edge cases, divide-by-zero guards, hydration gate, confirm dialogs); correct per-program structural fidelity (1 main lift/day for Wendler vs paired lifts for linear). All in 19m 45s with zero operator interventions.
- **Notable planning artifacts (Vibe-specific):** None persisted. An in-chat "here's how I'm reading the ask" message (with the Wendler decision) + ~7 ephemeral TaskCreate todos. No PRD / ADR / EARS / stories.
- **Operator-tempted-but-didn't-intervene moments:** None — the operator let it run fully autonomously (consistent with Vibe's design; 0 interventions verified by transcript). The discovery gaps above are exactly the moments where a methodology with a question-channel or spec phase *would* have forced surfacing — captured as the v0.1 finding, not as operator error.

### Live verification note (2026-05-25)
Binary outcomes and several defects were confirmed by driving the running app in the iOS 26.5 simulator via `idb` (companion 1.1.8 + fb-idb 1.1.7), not by code inference. Checkpoints exercised: finish setup → Today view; log sets → Finish → persisted; full Expo Go terminate + relaunch → history survived; Settings program switch 5×3 → 5/3/1 → Today updated + history preserved; opened the 5/3/1 OHP workout screen to confirm the single-weight / no-per-set-target defect. Screenshots available in /tmp (not yet copied to artifacts/).
