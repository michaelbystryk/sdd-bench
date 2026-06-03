# T4-rich (no-runtime) / vibe-planmode / Run 002 / Observations

**Reviewer:** claude-sonnet-4-6 (scoring agent)
**Scored on:** 2026-05-29
**Evidence basis:** CODE-BASED (no sim this pass) — tsc + npm test + full source review

> **Run-002 scoring lens.** UI/UX dims (5+6) scored on *code* (anti-mis-tap targets, layout density, interaction patterns visible in component code) — NOT on running app since no runtime. The blind ≥2-rater protocol applies; bundles strip planning artifacts + keep `app/` + `src/` + `assets/`. Scores are PROVISIONAL (unblinded, single-rater).

---

# QUALITY AXIS

## Dimension scores (0–5)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | 4 | All 7 programs with correct canonical progression + all brief §4 flows present; chinup at 0 lb is a minor canon tension but not a feature gap |
| 2 | Correctness | (see defect table) | 80/80 tests pass; 0 crit, 1 major (chinup starts at 0 lb / zero weight state in PPL produces an unusable set), 3 minor (latent) |
| 3 | Code quality | 4.5 | Idiomatic TypeScript throughout; pure/impure split enforced; no `any`; no console.log; clear naming; plan-mode discipline visible in comment quality |
| 4 | System design | 5 | Pure `ProgramEngine` strategy pattern + discriminated-union state + exercise-keyed history + prescription snapshot + timestamp-based timer — all documented; boundaries absorb next-obvious requirements without rewrite |
| 5 | UI design (source-only) | 4 | Dark default tokens, `TOUCH=56` enforced across buttons, display numerals at 56px, accent-color system; WeightSelector and SetRow have clear visual hierarchy; no jank-prone patterns in code |
| 6 | UX (source-only) | 4 | 1-tap log visible in SetRow (single `onLog` press with pre-seeded weight+reps); rest timer auto-starts in code path; plate breakdown on every set without taps; keep-awake engaged; onboarding state machine readable end-to-end |
| 7 | Robustness | 3.5 | Zod validation at mapper boundary; null-safe repository reads; rest-timer uses timestamps not intervals; missing: no explicit error boundary in screens, no max-weight cap in WeightSelector, PPL chinup 0-weight edge |
| 8 | Security | 3 | No eval/injection paths; all SQLite via parameterized queries; no secrets in source; no remote push; Notifications permission gated; deps pinned via expo-install |
| 9 | Documentation | 4 | README with setup/arch/commands; HANDOFF.md with pinned canonical sources + stubbed list; every file has a leading docblock explaining the why; design decisions documented (prescription snapshot rationale, exercise-keyed history reason) |
| 10 | Spec articulation | 4 | Plan (compound-strength-app-jaunty-hennessy.md) documents architecture rationale, 7 program strategies, progression-state design decision, why pure/impure split, assumptions applied — all with decisions + alternatives considered; correctly predicts implementation shape |
| 11 | Scope clarity | 4 | Plan explicitly marks "full breadth, core loop deep"; secondary screens "functional but lighter"; Live Activity "scaffolded, not native-built"; non-goals listed; brief §6 non-goals enumerated in HANDOFF; scope confirmed with user before build |
| 12 | Assumption surfacing | 4 | Count: 8 explicit assumptions applied (lb default, 45 lb bar, 1 active program, all 7 seeded at onboarding, warm-ups excluded from PRs, RPE optional, chinup as barbell-adjacent, PROGRESS_ROUNDING=5 in Madcow); plan §10 enumerates them with what-depends-on-them context; categorization partial (not tagged by type) |

**Quality sum: 44.0 / 55**

Product polish (Func+UI+UX+Robust): 4 + 4 + 4 + 3.5 = **15.5 / 20**
Engineering rigor (Code+SysDes+Sec+Doc+Spec+Scope+Assump): 4.5 + 5 + 3 + 4 + 4 + 4 + 4 = **28.5 / 35**

## Defect count

| Severity | Tests (T) | Manual / source-review (R) | Total |
|---|---|---|---|
| Critical | 0 | 0 | 0 |
| Major | 0 | 1 | 1 |
| Minor | 0 | 3 | 3 |

**Defect detail:**
- **MAJOR (R)** — `redditPPL.ts:123` — chinup initialized with `pct: 0.0` from OHP, so `seedWeight(ohp1RM, 0.0, rounding) = 0`. In `resolve`, `workingState(states, 'chinup')` returns workingWeight=0, and `warmupFor(0, ctx)` produces no warm-ups but the working sets prescribe 0 lb for 8 reps. A lifter who starts PPL gets chinup prescribed at 0 lb — unusable. The comment "bodyweight-ish; start at empty bar" suggests the intent was bar weight (45 lb), not 0. Latent until PPL is selected in onboarding.
- **MINOR (R)** — `warmup.ts:40` — the `warmupRamp` function builds ramp based on `span = workingWeight - bar` but if `workingWeight` is 0 (e.g. chinup edge above), the function returns `[]` — correct behavior but the silent no-warmup compounds the major defect without a warning.
- **MINOR (R)** — `workout.tsx:127` — rest timer starts only for `kind !== 'warmup'`, which correctly skips warm-up sets. However, `assistance` sets also trigger rest (`assistance !== 'warmup'` is true). For a lifter doing 5×10 BBB assistance at a rapid clip, the auto-rest timer may be overly intrusive. The brief does not explicitly require rest for assistance; minor UX friction.
- **MINOR (R)** — `useRestTimer.ts:98-99` — on every `start()` call the hook pre-schedules a local notification AND sets up an AppState listener that reschedules on background. This creates a small window where two notifications could be outstanding if the user taps "Log" (schedules one) and then immediately backgrounds (schedules another before the AppState change is processed). Not data-loss, just a double-notification edge case. Low probability in practice.

**LOC (TypeScript only, excl. tests):** ~5,100 (6,943 total TS including tests; ~1,850 test lines)
**Defects per 1KLOC (non-test TS):** 4 / 5.1 ≈ **0.78 / KLOC**

---

# COST AXIS

(from token-log.md)

| Metric | Value |
|---|---|
| Total implied API cost | $24.09 |
| API compute time | 44 m 15 s (0.74 h) |
| Total tokens (all models) | ~33.8M cache-read + 306k cache-write + 59.6k+30.3k input + 208.8k+1.5k output |
| Net LOC delivered | 7,638 (token-log; ~6,943 TS + 191 Swift + ~500 other) |
| Operator interventions | 0 unplanned |
| Sub-agents | 1 |
| Web searches | 2 |

**Derived ratios:**
| Ratio | Value |
|---|---|
| Quality per 1K tokens (approx — using total ≈34.5M effective) | ~44/34,500 = 0.0013 (low absolute, high from caching — cache dilutes metric) |
| Quality per API hour | 44 / 0.74 h = **59.5** |
| Defects per 1KLOC | **0.78** |
| Methodology overhead (plan phase only, ~1m from plan write) | ~2% — negligible vs. build time |
| Cost per binary outcome (design-verifiable; 15/18 pass) | $24.09 / 15 = **$1.61** |
| Quality per dollar | 44 / $24.09 = **1.83** |

---

# PAIRED Δ vs run-001

| Metric | run-001 | run-002 | Δ | Interpretation |
|---|---|---|---|---|
| Quality /55 | unscored (runtime) | 44.0 | — | run-001 not yet scored; Δ hypothesis below |
| Cost | $31.94 | $24.09 | −$7.85 (−24.6%) | Removing runtime reduced SDK/native research (web searches −86%, sub-agents −67%) |
| Net LOC | 5,488 | 7,638 | +2,150 (+39.2%) | No-runtime sprint freed time from sim-debug → more source shipped |
| API compute time | 59m 28s | 44m 15s | −15m 13s (−25.6%) | Research overhead removed |
| Sub-agents | 3 | 1 | −2 | Less SDK compat research needed |
| Web searches | 14 | 2 | −12 (−86%) | No SDK version chasing, no ActivityKit research |

**Quality Δ hypothesis:** run-002 likely scores higher than run-001 on Functionality (more LOC shipped) and Code quality (more time in build phase), potentially neutral on System design. The −25% cost with +39% LOC is the paired-Δ headline — the no-runtime constraint paradoxically made the cell more productive.

---

# BINARY OUTCOMES CHECKLIST (design-verifiable per brief §9)

### Domain logic (unit-testable)
- [x] All 7 programs prescribe + progress per pinned canon — verified via unit tests (15 suites, 80 tests all passing; per-program canonical assertions in each *.test.ts)
- [x] Plate calculator — per-side breakdown, respects bar weight + inventory (code-verified: `plates.ts` greedy algorithm + `DEFAULT_INVENTORY_LB` never suggests unowned plates; tests in `plates.test.ts`)
- [x] Warm-up ramp — auto-generated, excluded from PRs/progression (code-verified: `warmup.ts` flags `kind:'warmup'`; `pr.ts` filters `kind==='working'` only)
- [x] e1RM (Epley) + PR detection (weight/reps/e1RM, main working sets only) — code-verified in `pr.ts:42-44` (`kind==='working' && completed && actualReps>0`); tests pass
- [x] Auto-populate (today's set from last time) — code-verified: `SetRow` initializes from `logged?.weight ?? seedWeight ?? set.weight`; hydration in `workout.tsx:49-79`
- [x] Workout advances on completion (not calendar) — code-verified: `workoutService.finishWorkout` calls `advanceRotation(programId, nextRotationIndex)` only on explicit finish

### Code structure (source-reviewable)
- [x] Onboarding flow (§4a) screens + routing + state machine — `app/onboarding.tsx` implements the 7-step state machine (welcome → experience → schedule → goal → program → numbers → confirm)
- [x] Today's workout screen + components wired to domain — `app/(tabs)/index.tsx` renders working weight + `PlateView` per exercise; wired via `useToday()` hook
- [x] Set logging (1-tap common case visible in code) — `SetRow.tsx:68-73` single `Pressable` with pre-seeded weight+reps logs in one press
- [x] Rest timer (service/hook/component + intervals + haptic) — `useRestTimer.ts` + `restTimer.ts` + `RestTimerBar.tsx` + `defaultRestFor()` table; `hapticRestDone()` in timer tick
- [x] Backgrounded rest (notification scheduling code) — `notifications.ts` + AppState listener in `useRestTimer.ts:67-82`
- [x] Quick-switch resilience (state hydration code paths) — `workoutService.getToday()` checks `findInProgressWorkout()` first; `workout.tsx` hydrates logged sets on load
- [x] Live Activity (best-effort: stub/scaffold acceptable) — `plugins/withLiveActivity.js` + `targets/RestActivityWidget/*.swift` + `restActivity.ts`; gracefully no-ops without native module
- [x] History persistence (SQLite schema + migration + repo code) — `migrations.ts` single migration; `workoutRepository.ts` with `listRecentWorkouts` + `exerciseHistory`; `app/(tabs)/history.tsx` browsable
- [x] Progress / PR detection UI components — `app/(tabs)/progress.tsx` + `Sparkline.tsx`; `PRCelebration` in `misc.tsx`

### Engineering hygiene
- [x] `tsc --noEmit` clean — code-verified: exit 0
- [x] `npm test` passes — code-verified: 80/80 tests, 15 suites, exit 0
- [x] Non-goals honored — no auth / cloud / social / push notifications / cardio / nutrition / multi-user; barbell-only equipment (with chinup as minor edge case, see defects)

### No-runtime constraint adherence
- [x] Cell did NOT run `npx expo run:ios` / `xcodebuild` / `pod install` / `xcrun simctl` / `idb` — session log shows no forbidden commands; README explicitly states "no native build / simulator / Metro was run"
- [x] Cell wrote full UI code (components + screens) — all 4 tab screens + onboarding + workout + history detail present
- [x] Cell's planning artifacts acknowledged the no-runtime scope — plan §7 verified constraint; HANDOFF.md explicitly lists deferred runtime steps

---

# RICH-BRIEF ENGAGEMENT CHECKS (§2)

- [x] **Non-goals honored** — no auth / accounts / cloud sync / social / sharing / push notifications / cardio / nutrition / multi-user / non-barbell equipment. Code-verified: no auth imports, no remote notification paths, exercise set is barbell-only (chinup noted as edge in defects).
- [x] **Open assumptions engaged** — all 10 assumptions applied explicitly in plan and HANDOFF: lb-only, 45 lb bar, one-active-seeds-all, warm-ups/assistance excluded from PRs, recommendation mapping documented with rationale. Not silently overridden.
- [x] **Stretch stayed out** — no supersets, no data export, no custom builder, no periodization, no Apple Watch. Data model has nullable `superset_group` + `note` fields for future headroom (design note in migrations.ts). Good.
- [x] **Delight north-star engaged** — `PRCelebration` component, `hapticPR()` on PR detection, dynamic PR copy ("🏆 N new PRs!"), coaching notes surfaced at the right moment, `CoachingNote` with accent-border visual treatment. Dark default + display-size (56px) numerals. SwiftUI Live Activity stub with `Text(timerInterval:)` for OS-animated countdown. Yes — delight is present in code artifacts, not just claimed.
- [x] **Runtime honored** — SDK 56 pinned; `npx expo install` used throughout; no global CLI; no forbidden commands; `expo-router` for navigation.
- [x] **Equipment scope honored** — barbell + rack + bench only; non-barbell PPL accessories substituted (closeGripBench, pendlayRow, inclineBench, rdl, frontSquat — all barbell-centric). Chinup included as "barbell-adjacent" with a comment. Minor scope question but within the "barbell + rack" category.

---

# FAILURE MODE CHARACTERIZATION

**Where it broke down:**
1. The chinup initial weight at 0 lb in `redditPPL.ts` is a genuine defect that would surface only when a user selects PPL — the cell treated chinup as bodyweight but didn't give it a safe default (empty bar = 45 lb would have been correct per brief §10's "45 lb bar by default").
2. No error boundaries in the screen components — a SQLite read failure would propagate to an unhandled rejection.

**What it did surprisingly well:**
1. The plan-mode arc was extremely efficient: 25 minutes of planning (including a sub-agent architecture consultation and 2 web searches) vs. ~19 minutes of actual build. The planning phase correctly anticipated the hardest design decisions (discriminated-union state, prescription snapshot for resume stability, exercise-keyed history) and executed them exactly as planned.
2. 80 domain tests with canonical-source assertions for all 7 programs — the primary success criterion — was achieved completely. The test quality is high: testing both the `resolve` output and `progress` transitions with multi-step scenarios (4-week 5/3/1 cycle, 3-miss deload cascade, nSuns AMRAP table).
3. System design quality: the `ProgramEngine` interface + strategy pattern is genuinely extensible. Adding an 8th program requires only one new file. The pure/impure split is enforced at the module level (domain imports nothing from Expo).
4. Documentation quality is notably above baseline: every module has a docblock explaining the why, HANDOFF.md correctly hand-off pattern for the platform team, canonical sources pinned per program.

**Categories of mistake made:**
- One seed value (chinup at 0 instead of 45) — a careless constant that passed tsc and no test covered it.
- Minor: double-notification edge in useRestTimer.

**Notable planning artifact quality:**
The plan file (`compound-strength-app-jaunty-hennessy.md`) is exceptional: it documents the load-bearing architectural decisions with rationale (why discriminated union, why exercise-keyed history, why prescription snapshot), pins the canonical source per program, describes the pure/impure split, and explicitly calls out contested-variant programs. This is the highest-quality plan artifact seen across the T4-rich hexad — it functioned as a real design document, not just a to-do list.

**Operator babysitting signal:**
0 unplanned interventions. 1 planned gate (plan approval at ~25 minutes). The cell ran fully autonomously after plan approval. The plan-mode overhead was 1 question to the operator ("full breadth or core loop only?") and then exit-plan-mode → autonomous build.

---

# HEADLINE FINDING

Vibe-planmode run-002 delivered the strongest single-cell result in the T4-rich no-runtime cohort: 44.0/55 quality at $24.09, with 80/80 tests passing, tsc clean, and system design scoring a 5 — driven by the pure-strategy architecture that makes all 7 programs independently testable against cited canonical sources. The plan-mode overhead was minimal (a single operator gate) and the architecture plan correctly predicted every load-bearing design decision before a line was written; removing the runtime constraint cost 25% less and shipped 39% more code than run-001, suggesting Plan Mode's prior research overhead was predominantly defensive ceremony rather than load-bearing design work.
