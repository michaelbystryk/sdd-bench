# T4-rich (no-runtime) / openspec / Run 002 / Observations

**Reviewer:** claude-sonnet-4-6 (autonomous scoring agent)
**Scored on:** 2026-05-29
**Evidence basis:** CODE-BASED (no sim this pass)
**Header:** Scored on: 2026-05-29 · Scorer model: claude-sonnet-4-6 · Evidence basis: CODE-BASED (no sim this pass)

> **Run-002 scoring lens.** UI/UX dims (5+6) scored on *code* (anti-mis-tap targets, layout density, interaction patterns visible in component code) — NOT on running app since no runtime. The blind ≥2-rater protocol applies; bundles strip planning artifacts + keep `app/` + `src/` + `assets/`.

---

# QUALITY AXIS

## Dimension scores (0–5)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | 4.5 | All 7 programs correct + tested; all core flows (onboarding → today → log → advance → history/progress) fully implemented; Live Activity scaffold present (best-effort); minor: useToday initializer throws if called pre-onboarding (latent only, gated by index.tsx) |
| 2 | Correctness | — | see defect count below |
| 3 | Code quality | 4.5 | Domain is exemplary — pure TS, rich JSDoc, small well-named functions, no dead code; components clean; minor: WeakMap cache on PlateInventory objects that are re-created each call to getInventory() (perf-only miss, not correctness) |
| 4 | System design | 5 | Textbook layered architecture (domain ← data ← services ← state ← UI); design.md documents 8 explicit decisions with rationale + alternatives; data model encodes cross-program history, additive migration pattern, and all stretch items; prescribe() is a pure function — no clock in domain |
| 5 | UI design (source-only) | 4 | Dark-default (#0B0B0F bg), 64px display numerals for working weight, TAP_TARGET=56 (above 44pt floor), consistent spacing/radius tokens, PR celebration with gold border; lacks a scroll fallback for very long workouts and has no empty-state illustration for History/Progress first use |
| 6 | UX (source-only) | 4 | One-tap set log (SetRow), auto-populate from last session, rest timer auto-starts on log, warm-up ramp dismissable with Skip, plate load always visible without calculation, large ± buttons in WeightSelector; minor: no explicit RPE entry UI in the workout screen (field is on the model/persistence but not surfaced in the log UI) |
| 7 | Robustness | 4 | Timestamp-based rest timer is correct-by-construction; plate calc handles unsatisfiable weights via closest-loadable-at-or-below; migrations are idempotent; baseline excludes current session for PR detection; latent: resolveToday() throws if no active program and is called in useState initializer (gated but unguarded) |
| 8 | Security | 3 | No auth/cloud/remote push; all data is local SQLite; no hardcoded secrets; no eval; expo-sqlite + expo-notifications pinned at SDK 56; dep audit not explicitly visible; no threat boundary documentation |
| 9 | Documentation | 4 | README covers setup, verify, what's here; FOLLOWUP-SPRINT-HANDOFF.md gives architecture map + pinned sources + assumptions table; every source file has a meaningful JSDoc block explaining "why"; onboarding a contributor is 10min from clone; lacks "next contributor questions" preemptive answers |
| 10 | Spec articulation | 4.5 | 11 capability specs with EARS-style scenarios (54 requirements, 87 scenarios per archive summary); design.md has 8 explicit decisions with rationale + alternatives; proposal.md scopes to source+tests and names non-goals; correctly predicted the key implementation edge cases (AMRAP→TM table, closest-loadable rounding, baseline-excludes-current-session, T3 rep threshold) |
| 11 | Scope clarity | 4 | proposal.md explicitly lists non-goals (auth/push/nutrition/non-barbell/multi-user); design.md has non-goals section; tasks.md has 78 tasks with the Live Activity task explicitly labeled best-effort; scope was defended during implementation (comment in plugin explicitly says scaffold-only, not building native code); no evidence of scope revision in the transcript (no new information surfaced) |
| 12 | Assumption surfacing | 4 | FOLLOWUP-SPRINT-HANDOFF.md documents 9 explicit assumptions (lb/bar weight/warm-up exclusion/RPE-optional/rest intervals/closest-loadable/5×3-canonical/Madcow basis); design.md has 4 open questions; assumptions are categorized (technical/product) in the handoff; not fully mapped to file:line of impact |

**Quality sum:** 45.5 / 55

**Vector:**
- Product polish (Func + UI + UX + Robust): 4.5 + 4 + 4 + 4 = **16.5 / 20**
- Engineering rigor (Code + SysDes + Sec + Doc + Spec + Scope + Assump): 4.5 + 5 + 3 + 4 + 4.5 + 4 + 4 = **29 / 35**

---

## Defect count

| Severity | Tests (T) | Source-review (R) | Total |
|---|---|---|---|
| Critical | 0 | 0 | 0 |
| Major | 0 | 1 | 1 |
| Minor | 0 | 3 | 4 |

**Defect itemization:**

**Major:**
- M1 (R): `useToday` hook in `src/state/hooks.ts:64` initializes via `useState(() => resolveToday(store))` which **throws** `'No active program'` if the store has no active program. While `app/index.tsx` gates routing to `/onboarding` for non-onboarded users, Expo Router may mount tab screens eagerly before the redirect settles (RN concurrent rendering), producing an unhandled throw that crashes the app. The correct pattern is `() => { try { return resolveToday(store); } catch { return null; } }`. Under the no-runtime constraint the cell could not observe this crash — contextualized accordingly.

**Minor:**
- m1 (R): `achievableCache` WeakMap in `src/domain/equipment/plates.ts:43` is keyed on `PlateInventory` objects, but `store.getInventory()` constructs a new object on every call (`src/data/store.ts:110-115`), so the cache never hits. Perf issue, not correctness. (`plates.ts:43`, `store.ts:110`)
- m2 (R): RPE/RIR is persisted in `session_sets.rpe` and accepted by `logDraft` but the workout UI (`app/workout.tsx`) has no RPE entry UI — the brief calls RPE "optional; never blocks the fast path" and says it "feeds a better e1RM", but it is not enterable at all. Missing feature, minor because brief frames it as non-blocking optional. (`workout.tsx`, `SetRow.tsx`)
- m3 (R): `app/(tabs)/progress.tsx:88` defines `styles_sparkRow` as a plain object literal (not via `StyleSheet.create`), bypassing RN style registration. Cosmetic issue; no visual consequence but inconsistent with the rest of the codebase and marginally less performant. (`progress.tsx:88`)
- m4 (R): History screen (`app/(tabs)/history.tsx`) fetches all sessions and calls `store.getSessionSets(s.id)` inside the render loop only for the expanded card, which is correct; but `store.listCompletedSessions()` is called on every focus event without memoisation — N sessions means N SQLite queries on each focus. Minor perf issue, no correctness concern at small scale.

**LOC:** ~5,621 (all `.ts`/`.tsx` under `src/`, `app/`, `tests/`)
**Defects per 1KLOC:** 5 / 5.621 = **~0.89 / 1KLOC**

---

## Binary outcomes (design-verifiable from source + tests)

### Domain logic (unit-testable, primary)
- [x] All 7 programs prescribe + progress per pinned canon — code-verified: `tests/programs.test.ts` passes 100 tests, covers all 7 programs with correct set/rep/percentage assertions
- [x] Plate calculator (per-side breakdown, respects bar weight + inventory) — code-verified: `src/domain/equipment/plates.ts`, `tests/plates.test.ts` PASS
- [x] Warm-up ramp (auto-generated, excluded from PRs/progression) — code-verified: `src/domain/metrics/warmup.ts`, kind='warmup' excluded via `countsTowardMetrics()` in `e1rm.ts:15`
- [x] e1RM (Epley) + PR detection (weight / reps / e1RM, main working sets only) — code-verified: `tests/metrics.test.ts` PASS; `detectPRs` skips non-working sets via `countsTowardMetrics()`
- [x] Auto-populate (today's set from last time) — code-verified: `src/domain/session/logging.ts::seedDraft()`, `src/state/workoutEngine.ts::autoPopulate()`
- [x] Workout advances on completion (not by calendar date) — code-verified: cursor advanced only in `advance()` calls triggered by `finishWorkout()`; no Date.now() in domain prescribe()

### Code structure (source-reviewable, primary)
- [x] Onboarding flow (§4a) screens + routing + state machine — code-verified: `app/onboarding.tsx`, `src/state/onboarding/machine.ts`, 7-step reducer, `canProceed()` guards
- [x] Today's workout screen + components wired to domain — code-verified: `app/(tabs)/today.tsx`, `PlateBreakdown` receives `topWeight` computed from prescription; working weight visible without user input
- [x] Set logging (1-tap common case visible in code) — code-verified: `src/components/SetRow.tsx` — single `Pressable` → `onLog()`, no modal, no confirmation step
- [x] Rest timer (service/hook/component + intervals + haptic) — code-verified: `src/services/restTimer.ts`, `restTimerController.ts`, `src/components/RestTimerBar.tsx`, interval table in `restIntervalSec()`
- [x] Backgrounded rest (notification scheduling code) — code-verified: `restTimerController.ts::onBackground()` schedules via `notifications.schedule()`, `onForeground()` cancels
- [x] Quick-switch resilience (state hydration code paths) — code-verified: `src/state/AppProvider.tsx` AppState listener wires onBackground/onForeground; `useToday` reads from SQLite cold on first render
- [x] Live Activity (best-effort: stub/scaffold acceptable) — code-verified: `plugins/withRestTimerLiveActivity.js` + `plugins/RestTimerWidget/RestTimerLiveActivity.swift` present; explicitly labeled scaffold-only
- [x] History persistence (SQLite schema + migration + repo code) — code-verified: `src/data/migrations.ts` (versioned), `src/data/store.ts::setActiveProgram()` does not delete sets
- [x] Progress / PR detection UI components — code-verified: `src/components/PRCelebration.tsx`, `app/(tabs)/progress.tsx` (e1RM sparklines, volume, PR history)

### Engineering hygiene (verifiable)
- [x] `tsc --noEmit` clean — code-verified: `exit 0` confirmed by running `npx tsc --noEmit`
- [x] `npm test` passes — code-verified: 100/100 tests pass, 8 suites, `exit 0`
- [x] Non-goals honored — code-verified: no fetch/auth/firebase/social/cardio/nutrition in src/ or app/; non-barbell accessories substituted (exercise catalog has substitution map)

### No-runtime constraint adherence
- [x] Cell did NOT run `npx expo run:ios` / `xcodebuild` / `pod install` / `xcrun simctl` / `idb` / `expo start` — confirmed from session-log.md transcript
- [x] Cell wrote full UI code (components + screens) — confirmed: 7 screens + 7 components + hooks/state all present
- [x] Cell's planning artifacts acknowledged the no-runtime scope — confirmed: design.md + proposal.md both explicitly state "source + tests only; no runtime this sprint"

### Rich-brief-specific checks
- [x] Non-goals honored — auth/cloud/sync/social/sharing/push/cardio/nutrition/multi-user all absent from source
- [x] Open assumptions engaged — FOLLOWUP-SPRINT-HANDOFF.md explicitly acknowledges all brief §10 assumptions with notes; lb-only, one-active-program-seeds-all, warm-ups/assistance excluded from PRs all confirmed in code
- [x] Stretch stayed out — no supersets, export, custom builder, periodization, importable templates, Apple Watch in source
- [x] Delight north-star — PRCelebration component with gold (#FFD60A) border and trophy emoji; coaching notes surfaced at right moment; sparkline charts; empty-state copy in History/Progress; plate load shown on Today without any tap
- [x] Runtime honored — SDK 56 pinned; `npx` for all commands; no global CLI
- [x] Equipment scope honored — barbell-only catalog; substitution map converts non-barbell accessories

---

# COST AXIS

(from token-log.md)

| Metric | Value |
|---|---|
| Implied API cost | $22.91 |
| API compute time | 45m 6s |
| LOC produced | 7,655 net |
| Quality per 1K tokens | 45.5 / (~30.6M+0.5M total tok / 1000) ≈ **0.0015** (dominated by cache-read volume) |
| Quality per API hour | 45.5 / (45.1/60) = **60.5** |
| Defects per 1KLOC | 5 / 5.621 = **0.89** |
| Methodology overhead ratio | ~15 min proposal phase / ~30 min apply phase ≈ **0.5** (from transcript timestamps) |
| Cost per binary outcome | $22.91 / 27 passing outcomes ≈ **$0.85** |
| Quality per dollar | 45.5 / $22.91 = **1.99** |

---

# PAIRED Δ vs run-001 (this cell)

| Metric | run-001 (with-runtime) | run-002 (no-runtime) | Δ | Interpretation |
|---|---|---|---|---|
| Quality / 55 | 49.5 (from success-criteria.md comparator table) | 45.5 | −4.0 | run-002 scored slightly lower despite +30% LOC — the quality deficit maps mostly to the useToday crash risk (major defect) and missing RPE UI (minor), which the cell's source-only session couldn't self-correct against runtime feedback |
| Cost | $20.64 | $22.91 | +$2.27 (+11%) | Confirmed finding from token-log: OpenSpec spent MORE without a runtime, expanding the spec layer; opposite of Vibe/PlanMode which saved costs |
| LOC | 5,891 | 7,655 | +1,764 (+30%) | No-runtime constraint → spec expansion without trimming; OpenSpec wrote more code, not less |
| Defects/1KLOC | unknown (run-001 not yet scored) | 0.89 | — | |

**Finding:** OpenSpec's no-runtime response is expansion, not contraction. The +30% LOC and +11% cost with a −3pt quality Δ suggests that without runtime feedback to trim scope, the methodology over-specced (adding more programs, more tests, more components) at the cost of integration-level correctness (the useToday crash path). The planning artifact quality (dims 10–12) is at or above run-001 levels; the gap is in runtime-invisible robustness.

---

# HEADLINE FINDING

OpenSpec run-002 (no-runtime variant) delivered a **comprehensive, well-architected Expo SDK 56 app** with all 7 programs correctly implemented and 100 unit tests passing — the highest LOC output in the hexad at 7,655 net lines — at a cost of **$22.91** and a quality score of **45.5 / 55**. The methodology's characteristic response to the no-runtime constraint was *expansion*: more spec, more code, not scope reduction, resulting in the counterintuitive finding that removing the runtime *increased* cost by 11% vs. run-001. The primary quality gap from run-001 (−3 pts) is a latent crash path in `useToday`'s `useState` initializer that is only observable at runtime — exactly the category of defect that the no-runtime constraint makes invisible and impossible to self-correct. Engineering rigor (29/35) is strong; the product polish vector (16.5/20) reflects genuinely considered UX affordances (TAP_TARGET=56, 64px display numerals, dark-default, plate load pre-computed) that are readable as design intent even without running the app.

---

# FAILURE MODES AND NOTABLE ARTIFACTS

## Where the methodology succeeded

- **Domain correctness under source-only conditions:** The 8-decision design doc was written *before* implementation and correctly predicted edge cases that appeared during coding: the baseline-excludes-current-session fix, the JSDoc comment closing the block early in ppl.ts, and the rep-PR rule refinement. This is genuine foresight (rubric dim 10 anchor: "spec correctly predicts edge cases that turn up during implementation").
- **Architecture discipline:** The layered architecture (pure domain / data / services / state / UI) is not a token gesture — every file boundary enforces it. The `Database` interface is a real seam; the service fakes are real fakes. A reviewer can trace a set-log event from `SetRow → useLogging → logDraft → Store → SQLite` without guessing.
- **Planning artifact quality:** The 11 capability specs with 87 scenarios and the design.md's 8 decisions + open questions represent the methodology doing what it's designed to do — creating a written record of decisions that would otherwise be in the developer's head.

## Where the methodology broke down

- **No runtime means no integration feedback.** The useToday crash risk (major defect) is exactly the category OpenSpec is blind to: a correct individual function (`resolveToday`) that fails at the composition boundary (React concurrent rendering + Expo Router mount ordering). With no runtime to catch this, the methodology had no feedback loop.
- **Expansion without gravity.** Without "does this build and run?" as a check, the methodology wrote more (30% more LOC, 10% more tokens) without proportional quality gain. The spec authoring phase expanded; capability specs became more thorough; tests proliferated. None of that is wrong, but it reflects the absence of the implicit cost discipline that "I have to verify this" provides.
- **RPE UI omitted.** The model layer supports RPE; the persistence layer stores it; the spec documents it. But the workout screen never surfaces an RPE entry control. The spec said "optional; never blocks the fast path" and the implementation interpreted that as "don't build it." A runtime pass would have caught "the RPE number never appears."

## Delight north-star engagement

**Yes** — the PRCelebration component (gold border, trophy, per-type labels), the 64px working-weight numeral, the plate-load pre-computed on the Today screen before the user starts a workout, and the coaching notes per program week all show that the methodology read the brief's "figure it out" intent and responded. This is genuine delight from inference, not from a checklist.
