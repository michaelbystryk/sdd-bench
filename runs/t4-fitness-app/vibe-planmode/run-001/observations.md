# T4-vibe-planmode / Run 001 / Observations

Filled in during scoring. Uses [`harness/scoring-rubric.md`](../../../../harness/scoring-rubric.md) and [`tasks/t4-fitness-app/success-criteria.md`](../../../../tasks/t4-fitness-app/success-criteria.md).

**Reviewer:** Operator
**Scored on:** 2026-05-25
**Methodology revealed at:** n/a (unblinded — scored as a deliberate matched pair against T4-Vibe-pure run-001, methodology known)

> **This is the matched pair to T4-Vibe-pure run-001** (Quality 29/55, Cost $5.84 / 0h 20m, 7/7 binary, 0 questions asked). Same task, same vague brief, same operator, same model (claude-opus-4-7) — the **only** independent variable is Plan Mode toggled on. Per-dimension deltas (Δ) versus Vibe-pure are shown throughout.

---

# QUALITY AXIS

## Dimension scores (0–5 per harness/scoring-rubric.md; 0.5 increments permitted per v0.1.2 changelog)

| # | Dimension | Score | Δ vs Vibe | One-line evidence |
|---|---|---|---|---|
| 1 | Functionality | 3.5 | +0.5 | All required behaviors work and all three programs are runnable (the 5/3/1-unrunnable + missing-rest-timer/edit blockers that held Vibe-pure at 3 are gone); held to 3.5 by the Major progression-feedback defect found live (defect 1). |
| 2 | Correctness | (see defect block) | — | 0 crit / 1 major / 2 minor |
| 3 | Code quality | 4.5 | +0.5 | Strong TS; `buildRotations` factory kills Vibe-pure's per-program copy-paste; uniform `useDbData`/`useFocusEffect` hook fixes its inconsistent-subscription; held off 5 by thin effect-dependency arrays + a couple long screen files. |
| 4 | System design | 4.5 | +1.0 | **Normalized 4-table SQLite model** (vs Vibe-pure's single blob) + versioned WAL migration + data-driven programs; resolves both of Vibe-pure's 3.5-blockers; held off 5 by no in-repo ADR (the design doc lives in `~/.claude/plans/`) and a single migration version. |
| 5 | UI design | 4.5 | 0.0 | Real design-token system, dark sweaty-hands theme, huge weight readout, big steppers, green/✓ completed state, **real tab icons** (vs Vibe-pure's placeholder glyphs); still held off 5 by a bare chart (single dot/line, no axes/labels). |
| 6 | UX | 4.5 | +1.0 | Zero-tap primary loop (pre-filled weight, big steppers, haptics, carry-over weight, auto-advance) **+ live rest timer** (the must-have Vibe-pure lacked) + no broken-program friction; held off 5 only by missing screen-keep-awake. |
| 7 | Robustness | 4.5 | +0.5 | Adds **versioned migration + ErrorBoundary + Suspense** (Vibe-pure's two 5-blockers), plus clamps/NaN guards, chart empty/single/flat handling, confirm dialogs; held off 5 by non-transactional delete-then-insert in `logSet` and errors only console-logged. |
| 8 | Security | 3 | 0.0 | Clean by construction — local SQLite, no network/secrets, fully parameterized queries, pinned deps + lockfile. Low-signal dimension for a local single-user app (same as Vibe-pure). |
| 9 | Documentation | 3.5 | +1.0 | **Real README** (features, run steps, annotated structure tree, data model) — the one Vibe-pure said it would write and didn't; good why-comments; held off 4 by no in-repo decision records (the plan is external) and no contributor-deep docs. |
| 10 | Spec articulation | **4.5** | **+4.5** | **The headline.** Plan Mode produced a genuine spec artifact (`build-me-a-strength-splendid-blum.md`) before coding: testable 9-step E2E acceptance criteria + decisions-with-rationale + alternatives considered, and real foresight (predicted the %-program logging-UI complexity that actually broke Vibe-pure). Held off 5 by some emergent edge behaviors it didn't pre-specify. Vibe-pure had no spec → 0. |
| 11 | Scope clarity | 3.5 | +2.5 | Explicit "Out of scope / assumptions" section names auth/sync/accounts as cut **with reasons** (vs Vibe-pure's silent cut); half-step to 4 for actively steering away from model/UI complexity in the third-program choice + framing the 4-day split as a conditional, revisitable decision. |
| 12 | Assumption surfacing | count: ~5 / quality: 3 | +3.0 | ~5 documented decisions/assumptions (3 "confirmed with user" + 3 out-of-scope), several stating what depends on them / what changes if revisited (4-day split → "a one-table change"); held off 4 by no technical/product/user-behavior categorization. Vibe-pure: 0/0. |

**Quality sum (11 scored dimensions, max 55):** **43.5**  ·  (Vibe-pure: 29  ·  **Δ = +14.5**)

### Where the +14.5 came from
- **SDD cluster (Spec + Scope + Assumptions): 1 → 11.5 (+10.5).** This is the bulk of the gain, and it is unambiguously the treatment effect — Plan Mode *literally produces* the spec artifact, names scope, and surfaces assumptions that Vibe-pure left silent.
- **Execution cluster (Func/Code/SysD/UX/Robust/Docs): +4.0.** Real, measurable improvements — normalized data model, rest timer, README, migration, error boundary — several traceable to the plan (rest timer and README were named in it; the 3×8 program choice avoided the defect that capped Vibe-pure's Functionality). **Caveat:** these +0.5/+1.0 execution deltas blend the planning treatment effect with ordinary run-to-run variance (two Vibe-pure runs would also differ); they should not be attributed *entirely* to Plan Mode. The SDD-cluster gain is the clean signal.
- **UI + Security: +0.0.** No differential — Vibe already nails UI and there's no real security surface. Planning didn't move dimensions that pure-Vibe already maxes.

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | 0 |
| Major | 0 | 1 | 1 | 1 |
| Minor | 0 | 0 | 2 | 2 |

(No automated tests in the project — all defects from live idb walkthrough (M) and code review (R). The major was found live and confirmed in review.)

LOC: ~2,579 net (2,705 added − 126 removed; source wc ≈ 2,570)  |  **Defects per 1KLOC: 3 / 2.579 = 1.16**  (Vibe-pure: 2.97)

Itemized:

1. **Major / M+R** — **Progression ignores manually-adjusted logged weight.** `finishSession` computes the next weight as `nextWeight(lift_state.working_weight, increment, …)` — i.e., it increments the *stored* working weight and never reads what you actually logged. Confirmed live: logged squat at **105 lb** (bumped from the 95 suggestion) for all 5 sets at target → after finishing, Today suggested squat **100 lb** (= stored 95 + 5), not 110. This directly contradicts the on-screen claim "weights are suggested from your last session" and the persona's stated need ("show me the next weight"). The UI explicitly invites adjustment ("Adjust any of them while you lift"), so a real user — especially the intermediate in `reference/me.md` — hits this. Mitigated for the *unmodified* path (pure suggested-weight progression is correct, including deload) and by onboarding letting you set starting weights; that's why it's Major, not Critical. *(This is the defect the live walkthrough earned its keep on — code-reading saw the line but didn't connect that it discards the logged weight.)*
2. **Minor / R** — `finishSession` treats a *partially*-logged-but-on-target lift as a full success → unearned increment when finishing early (e.g., 2 of 5 squat sets at target then "Finish early" → +5). Edge case; defensible under an explicit-logging model.
3. **Minor / R** — "Finish early" with zero logged sets still advances `rotation_index` and writes a completed session, so an empty finish silently skips you forward in the rotation. Edge case.

**Net vs Vibe-pure (1 major / 5 minor):** fewer defects and lower density. Vibe-pure's major (the %-based 5/3/1 single-weight UI) is *structurally absent* here because the asked-for program choice (3×8, flat-weight) removed the %-ramp entirely — a defect prevented by discovery. Vibe-PM introduces a *different* major (progression-feedback) that pure-Vibe did not have.

## Binary outcomes (pass/fail per tasks/t4-fitness-app/success-criteria.md)

- [x] **Builds in Expo Go** — loaded + ran in Expo Go on iOS 26.5 sim (live, idb-driven); `expo export` reproduced clean during scoring
- [x] **Four lifts present** — squat/bench/OHP/deadlift in onboarding starting-weights + program rotations
- [x] **Today's workout view** — lands directly on Today showing the day's workout on open
- [x] **Set logging works** — logged 5 squat sets w/ weight+reps; ✓ state, persisted
- [x] **History persists** — survived a full Expo Go terminate + relaunch (Day B / "1 of 3" / progressed weights intact)
- [x] **Program selection works** — switched 5×5 → 3×8 live; Today re-rendered to 3×8; squat history preserved
- [x] **Days/week selectable** — 3/4 toggle in onboarding + settings; functional for **all three** programs (no per-program no-op, unlike Vibe-pure)

**Pass count: 7 / 7** — all confirmed live via idb-driven simulator walkthrough on 2026-05-25 (screenshots `artifacts/01`–`15`). Matched-rigor with Vibe-pure's verification.

---

# COST AXIS

## Raw metrics

| Metric | Value | Vibe-pure |
|---|---|---|
| Total tokens | ≈7,696,000 (7.4M of it cache-read) | 7,007,280 |
| Implied API cost | **$7.78** | $5.84 |
| Active wall-clock | ~0h 27m (transcript span; `/status` wall 28m 55s, API 22m 43s) | 0h 19m 45s |
| Plan Mode phase | ~6m 23s | n/a |
| Implementation phase | ~20m 41s | ~19m 45s (whole session) |
| Plan revision count | 0 | n/a |
| Operator-touch time | ~2 min (plan-mode gates) | 0 min |
| Operator-touch (excl. plan approvals) | ~1 min | 0 min |
| Operator intervention count (unplanned) | **0** | 0 |
| Time to first working build | ~19.5m | ~18m |

## Derived ratios

| Ratio | Value | Vibe-pure | Winner |
|---|---|---|---|
| Quality per 1K tokens | 0.00565 (≈5.65/1M) | 0.0041 | **Vibe-PM** |
| Quality per API hour | 114.9 | 99.7 | **Vibe-PM** |
| Defects per 1KLOC | 1.16 | 2.97 | **Vibe-PM** |
| **Methodology overhead ratio (planning / impl)** | **0.31** (≈1:3.2) | n/a | — (the key Vibe-vs-Vibe-PM-vs-Spec-Kit number) |
| Cost per binary outcome | $1.11 | $0.83 | Vibe-pure |
| Quality per dollar | 5.59 | 4.97 | **Vibe-PM** |

**Reading:** Plan Mode cost ~33% more in dollars and ~37% more wall-time, spending ~24% of active time planning (overhead 0.31). But quality rose more than cost, so every *quality-adjusted* ratio improved. Vibe-pure only wins the raw-cost ratios (absolute $, $/binary), because both hit 7/7 and pure-Vibe got there cheaper.

---

# HEADLINE FINDING

```
Quality: 43.5 / 55  ·  Cost: $7.78 / 0h 27m  ·  Binary: 7 / 7 pass
```

**One-line verdict** (covering BOTH axes):

> Vibe Plan Mode scored **43.5/55 at $7.78 / 27m, 7/7 binary** vs Vibe-pure (**29/55, $5.84 / 20m, 0 questions**): a **+14.5 quality gain for ~33% more cost**, with the **spec-articulation jump 0 → 4.5** as the largest single driver and the SDD cluster (spec + scope + assumptions) supplying +10.5 of the +14.5 — bought at a **methodology overhead ratio of 0.31 (planning ≈ 24% of time)** and a single clarifying-question round that, by surfacing the "pick a program" fork, steered to a flat-weight program and **prevented the very defect that capped Vibe-pure**.

**Matched-pair takeaway:** for this task, just *toggling Plan Mode* — no slash commands, no EARS, no multi-agent — closed essentially the entire discovery gap that defined the Vibe-pure finding, while keeping operator interventions at zero. The cost is real but modest (one-third more, ~one extra clarifying round, a 6-minute plan phase). This is the data point that lets v0.4 ask whether Spec Kit / AI-DLC / BMAD buy anything *beyond* what one built-in planning toggle already delivers.

---

## Vibe Plan Mode-specific scope-handling

T4's four vague spots — **directly compared to Vibe-pure run-001 (which asked zero questions and decided all four silently):**

| Vague spot | Vibe-pure (silent) | Vibe Plan Mode |
|---|---|---|
| **"plus one I haven't decided yet — pick one"** | Picked Wendler 5/3/1 silently; then built a flat-weight UI that couldn't run it (its major defect). | **ASKED** (AskUserQuestion), recommended **3×8** over 5/3/1, explicitly noting 5/3/1 "adds real complexity to the model and the logging UI." The flat-weight choice **structurally prevented** Vibe-pure's defect. Cleanest instance of discovery → defect-avoidance. |
| **"feel good to use mid-workout"** | Engaged as real UX (stepper, dark theme) but missed rest-timer + keep-awake. | **ASKED** about the weight-selector interaction (plate-stepper vs scroll-wheel vs number-pad, with ASCII previews) **+** a dedicated "Design principles for mid-workout feel" plan section. Built the stepper **and** a live rest timer (closing one of Vibe-pure's two gaps); keep-awake still missing. |
| **"see my progress over time"** | Per-lift SVG line chart; reasoning undocumented. | Per-lift color-coded charts (verified live: empty/single-point states handled). **Decided in-plan, not asked** — the one vague spot Plan Mode resolved silently (though it's named in the plan). |
| **Auth / account / sync / sharing (never mentioned)** | Silently out-scoped; no flag. | **Explicitly named out-of-scope** in the plan ("No cloud sync, no accounts (local SQLite only, per the request)") + repeated in the README. Direct differential on the exact spot. |

Net: Plan Mode converted **3 of 4** vague spots from silent decisions into surfaced, rationale-backed ones; the 4th (progress representation) it still decided silently but at least documented.

## Methodology fitness signals

- **Did the plan reveal real foresight or just restate the brief?** Real foresight. It correctly predicted the load-bearing fork (a %-based third program would complicate the data model *and* the logging UI) — the exact failure that capped Vibe-pure — and steered around it. It also foresaw Expo Go constraints (on-screen rest timer instead of background notifications; all deps Expo Go-compatible). The 9-step verification section is genuine testable acceptance criteria.
- **Plan revisions before approval: 0.** Converged on the first plan; approved as-is. Not a struggle-to-converge signal.
- **Did execution deviate from the plan?** Minimally. The shipped app matches the plan's data model, screens, programs, and progression rules. Emergent details not in the plan: carry-over-weight UX, partial-completion semantics, chart empty-states. No contradiction with the plan.
- **Did plan-first unlock different decisions, or land in the same place via a different path?** **Different decisions.** The third-program fork is the proof: Vibe-pure chose 5/3/1 and broke on it; Vibe-PM asked, chose 3×8, and shipped a runnable trio. The planning step changed the outcome, not just the route.

## Failure mode characterization

- **Where Vibe Plan Mode broke down:** Not in discovery (its strength here) — in one execution detail the plan didn't pin down: the **progression-feedback loop**. The spec said "linear progression applied per lift when a workout finishes" but didn't specify *from what baseline*; the implementation incremented the stored working weight and discarded manually-logged weights. A spec that named this edge ("next weight = max(logged, suggested) + increment") would likely have prevented it — so even a strong plan left a gap exactly where it was under-specified. The two minor defects (partial-finish success, empty-finish rotation advance) are similar unspecified-edge cases.
- **What it did surprisingly well that Vibe-pure didn't:** Surfaced the ambiguity instead of swallowing it; produced a normalized data model + versioned migration + error boundary + README; and — most tellingly — its discovery step *prevented a defect* (the %-program trap) rather than just documenting intent.
- **Notable artifact — was the plan useful, or planning theater?** Genuinely useful, not theater. The plan is a real spec (data model DDL, program tables, progression rules, 9-step E2E acceptance criteria, explicit out-of-scope). It drove the build (rest timer + README were named in it and shipped) and its one clarifying round changed a product decision that mattered. Its limit: it lives in `~/.claude/plans/`, outside the repo, so it doesn't count as in-repo documentation (capping Docs at 3.5 and System-design at 4.5).
- **Operator-tempted-but-didn't-intervene moments:** None — 0 unplanned interventions (verified by transcript). The only operator touches were the two methodology-prescribed gates (answer the clarifying question, approve the plan).

### Fidelity caveats (see session-log.md for detail)
1. **Clarifying questions not routed to PM persona** — the 3 product forks were answered directly in the AskUserQuestion UI (all recommended options), so the calibrated PM persona was never exercised. Doesn't change the key finding (Plan Mode *surfaced* the questions) but understates the back-and-forth a strict run would incur. Fix for future Plan Mode runs.
2. **Concurrent CC session** — a dev server on port 8081 forced the in-session `expo start` to 8090; the runbook says Vibe Plan Mode should run with no concurrent sessions. Per-session metrics are uncontaminated and interventions were 0, so impact is limited.

### Live verification note (2026-05-25)
All 7 binary outcomes and the major defect were confirmed by driving the running app in the iOS 26.5 simulator via `idb` (companion 1.1.8 + fb-idb 1.1.7) in Expo Go 56.0.2 — **matched to Vibe-pure's verification rigor**. Checkpoints: onboarding (3 programs + 3/4 toggle + 4 lifts) → Today → log 5 squat sets (stepper 95→105, ✓ state, live rest timer) → Finish (rotation A→B, week counter) → Progress (per-lift charts, single-point handled) → full terminate + relaunch (history survived) → Settings program switch 5×5 → 3×8 (Today updated, history preserved). The progression-feedback major defect was discovered in this walkthrough. Screenshots in `artifacts/01`–`15`.
