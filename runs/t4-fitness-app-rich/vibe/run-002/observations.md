# T4-rich (PM-quality brief) / Vibe Claude Code / Run 002 / Observations

**Reviewer:** scoring agent (single-rater, autonomous)
**Scored on:** 2026-05-29 · **Scorer model:** claude-sonnet-4-6 · **Evidence basis: CODE-BASED (no sim this pass)**

> **Run-002 scoring lens.** This is a parallel scoring pass — no simulator used. All scores from:
> (1) build sanity: `tsc --noEmit` exit code 0 (clean) · `npm test` 124/124 pass;
> (2) full source review (25 files read across domain/services/db/state/components/screens/docs);
> (3) planning-artifact review (README.md, docs/ASSUMPTIONS.md, docs/HANDOFF.md).
> UI/UX dims (5+6) scored on component/screen code per no-runtime protocol.
> Status: **PROVISIONAL** (unblinded, single rater, code-based).

---

# QUALITY AXIS

## Dimension scores (0–5)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | **4.5** | All 7 programs ship with canonical progression (code-verified via 124 tests + source); full core loop (onboarding → today → log → rest → finish → PRs → history → progress); only gap: 5-day schedule has no exact-fit program (documented assumption), and 5/3/1 stall-reset is only hold (no deload) when week-3 is missed — code-verified at `fiveThreeOne.ts:115–120`. Thoughtful interpretation throughout (seeds-all-programs, recommendation engine, barbell substitution) → above 4, not clean 5 |
| 2 | Correctness | (see defect block) | 0 crit · 2 major · 4 minor — 0 test failures; major defects found via code review (async race on rest-timer persist, 5/3/1 missing deload path); minor defects in warmup boundary + Settings plate-toggle edge case |
| 3 | Code quality | **4.5** | Layered domain→db→services→state→hooks→components strictly enforced; discriminated-union types throughout; intentional naming (`isPRCandidate`, `draftsToArray`, `replaceForSession`); no `as any` casts found; port pattern for repositories is a small surprise of skill (eliminates device dep from tests) → strong 4, pushing into 5 territory via the port abstraction and code-comment discipline |
| 4 | System design | **4.5** | domain→programs→db ports→services→state→hooks→components is clean and enforced; `previewToday` vs `resolveToday` split (no empty sessions on preview) is a good design decision; `applyResults(state, log)` pure function makes all 7 programs testable independently; repository port pattern (`types.ts` ports + dual adapters) enables pure-Node service tests → solid 4; deliberate ADR-style comments in ASSUMPTIONS.md elevate toward 5 |
| 5 | UI design (source-only) | **4** | Dark high-contrast tokens (`bg: #0B0B0F`, `text: #F5F5F7`); TAP_TARGET=56 exceeds 44pt floor; `display` numerals at 56px/48px for weights/timers; PlateLoad shown inline with weight on Today and SetRow; PR celebration modal with gold color (#FFCB45) and trophy emoji; RestTimerBar with progress fill. Missing: no workout-specific empty state beyond generic loading text → not quite 5 |
| 6 | UX (source-only) | **4** | 1-tap log (single Pressable on the log button, seeded from prescription); weight/reps auto-populated via `autoPopulateWorkout`; rest auto-starts on log (non-warmup path); `keepScreenAwake` called on workout load; `useRestTimerTick` re-triggers on AppState 'active' (accurate on return); notification scheduled at rest start, cancelled on return. Nicks: "Finish workout" button in a `<View style={styles.footer}>` with fixed padding — same footer-overlap risk as run-001 if the tab bar isn't accounted for (code-visible; INDETERMINATE without sim); warm-up strip hidden by default toggle → slightly more taps than needed → 4 |
| 7 | Robustness | **4** | `computePlateLoad` handles below-bar weights + inexact achievableWeight; `generateWarmup` guards on minWorking weight; `previewToday` has a live/cleanup pattern (`alive` flag); `configureNotifications` idempotent (`configured` flag); `adjustRestTimer` clamps to `>= now`; PR candidate guards (`isPRCandidate` filters warmup/incomplete/zero). Missing: no try/catch around `logSet`/`finish`/`completeWorkout` async paths — DB write failure would leave UI in "logged" state silently; no db-open timeout on bootstrap → not 5 |
| 8 | Security | **4** | All SQLite queries use parameterized `runAsync(sql, [params])` throughout `sqlite.ts`; no user-supplied strings interpolated in SQL; local-only offline single-user design per brief §6; package-lock.json present (deps pinned); no secrets in source. No threat-boundary doc. `PRAGMA user_version = ${SCHEMA_VERSION}` is at `schema.ts` — actually this isn't interpolated into the SQL string, MIGRATIONS array uses string templates but the version check is done separately. Clean SQL discipline → 4 |
| 9 | Documentation | **4** | README: setup + verify commands + architecture tree + 7-program table + headline behaviors. `docs/ASSUMPTIONS.md`: brief §10 assumptions engaged point-by-point with falsifiable reasoning. `docs/HANDOFF.md`: follow-up-sprint checklist covering first build + all deferred runtime behaviors + Live Activity wiring steps. File-level JSDoc on every module with `brief §N` references. No ADRs (decisions embedded in ASSUMPTIONS.md inline prose, not as standalone decision records) → 4 |
| 10 | Spec articulation | **1** | Vibe — no pre-build spec artifact (rubric baseline = 0). `+1` for the brief §10 assumption engagement in ASSUMPTIONS.md (written post-build but shows methodical decision mapping; it's doc, not pre-spec) |
| 11 | Scope clarity | **3** | HANDOFF.md explicitly lists "deferred to platform-team follow-up" behaviors with binary pass conditions; ASSUMPTIONS.md lists "Known limitations (this sprint)"; README "Verify (what reviewers run)" section defines the sprint's scope. Scope declared post-hoc (no pre-build scope document). Stretch §11 items not explicitly enumerated as out-of-scope (data model accommodates them by design, not by explicit call-out) → 3 |
| 12 | Assumption surfacing | **3** | ASSUMPTIONS.md: 8 brief §10 assumptions engaged explicitly with consequences ("Unit is threaded everywhere so kg is absorbable, but the app defaults to lb"; "warm-ups & assistance don't count toward PRs/e1RM — enforced structurally"). Plus 5 "Non-obvious decisions" with trade-off rationale. Count: ~13 assumption/decision entries. Quality: names each choice + what would change. Missing: not categorized (technical/product/user-behavior), not mapped to specific file:line. Run-002 significantly outperforms run-001's dim 12 (which had ~2 informal assumptions) |

**Quality sum: 40.5 / 55**
**Vector — Product polish: 16.5 / 20** (Func 4.5 + UI 4 + UX 4 + Robust 4) · **Engineering rigor: 24 / 35** (Code 4.5 + SysDes 4.5 + Sec 4 + Doc 4 + Spec 1 + Scope 3 + Assump 3)

> Profile: same Vibe signature as run-001 but with a stronger rigor score. Product polish = 16.5/20 vs run-001's 17/20 (run-001 had Maestro-validated live evidence pushing scores; run-002 code-only). Engineering rigor = 24/35 vs run-001's 22/35 — the repository port pattern and 124-test suite earn Code/SysDes both 4.5. The planning trio (Spec 1 / Scope 3 / Assump 3 = 7/15) is structurally identical to Vibe's pattern; run-002 outperforms run-001 on Assumptions (3 vs 2) due to the explicit ASSUMPTIONS.md. The no-runtime constraint trades the live-verification polish catch (run-001 Maestro found the completion-overlay Major defect) for a much deeper test suite (124 vs 0 jest tests).

---

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Review (R) | Total |
|---|---|---|---|
| Critical | 0 | 0 | **0** |
| Major | 0 | 2 | **2** |
| Minor | 0 | 4 | **4** |

**LOC produced:** ~8,097 net (session-log.md) / ~7,384 measured (src+app+tests) / ~6,273 (src+app only)
Using 8,097 (token-log figure, includes all shipped TS/TSX + docs): **Defects per 1KLOC: ~0.74** (6 / 8.097)

Itemized:
1. **[Major · latent]** `useWorkoutStore.ts:90–105` (`logSet`): no try/catch around `workout.saveProgress` — a SQLite write failure after `set({drafts...})` leaves UI showing "logged" while data is not persisted (silent state inconsistency). Same issue as run-001. `code-verified: useWorkoutStore.ts:90–105`
2. **[Major · canon]** `fiveThreeOne.ts:115–120` (`applyResults`, week===2 branch): when the AMRAP single is missed (`reps < 1`), the TM is held and `failures` is incremented — but there is no deload path (e.g. reduce TM by a % after N consecutive misses). Wendler's published protocol includes a TM reduction if you repeatedly miss; the code has a `failures` counter that is set but never acted on. The missing deload path is a fidelity gap. `code-verified: fiveThreeOne.ts:115–120`
3. **[Minor · latent]** `useWorkoutStore.ts:140–149` (`finish`): no try/catch around `workout.completeWorkout` — a failure in PR detection or progression advance would leave the session stuck as `in_progress`. `code-verified: useWorkoutStore.ts:140–149`
4. **[Minor]** `warmup.ts:40` (`generateWarmup`): `workingWeight <= minWorking` returns `[]` silently — for working weights only slightly above the bar, the first ramp step (40% of working weight) can produce a weight below the bar weight, which is then filtered out, potentially leaving a very short warm-up or a single empty-bar set. This is handled correctly by the `ascending + below-working` filter, but the edge case where working weight = bar + 5 lb (e.g., 50 lb) produces only the empty-bar set. Not a crash, just a sparse warm-up. `code-verified: warmup.ts:40–56`
5. **[Minor]** `Settings.tsx:21–24` (`togglePlate`): `STANDARD_LB.filter(...)` replaces the inventory plates with exactly 8 of each owned denomination — it discards the actual `count` from the existing inventory (always sets count to 8 even if the user had fewer). Minor data fidelity issue. `code-verified: settings.tsx:21–24`
6. **[Minor]** `today.tsx:67–69`: `ex.sets[0]` displayed as the representative weight for all sets in the card — for 5/3/1 which has 3 sets at different percentages, only the first set's weight shows (the lightest set, not the working top set). This is readable as a preview but is slightly misleading since the "working weight" shown is 65% TM not the AMRAP set. INDETERMINATE severity (could be intentional design for Today's preview). `code-verified: today.tsx:67–69`

---

# BINARY OUTCOMES (design-verifiable per brief-no-runtime.md §9)

### Domain logic (unit-testable)
- [x] **All 7 programs prescribe + progress per pinned canon** — `tests/domain/programs.test.ts` covers all 7 with shared invariants + per-program canon tests; 5×5 deload, GZCLP T1/T2/T3 cascade, nSuns TM table, Madcow weekly bump, PPL 6-day linear all verified. `code-verified: programs.test.ts:1–323`
- [x] **Plate calculator (per-side breakdown, respects bar + inventory)** — `computePlateLoad` in `plates.ts`; `tests/domain/plates.test.ts` covers inventory constraints, exact vs. approximate. `code-verified: plates.ts:63–92, plates.test.ts`
- [x] **Warm-up ramp (auto-generated, excluded from PRs/progression)** — `generateWarmup` typed `warmup` as const; `isPRCandidate` filters `isWarmup`. `code-verified: warmup.ts:65–73, pr.ts:37–45`
- [x] **e1RM (Epley) + PR detection** — `epley`, `estimatedOneRepMax`, `detectPRs` / `detectWorkoutPRs`; `tests/domain/e1rm.test.ts`, `tests/domain/pr.test.ts`. `code-verified: e1rm.ts, pr.ts`
- [x] **Auto-populate (today's set from last time)** — `autoPopulateWorkout` seeds from prescription + `lastByKey`; `tests/domain/autopopulate.test.ts`. `code-verified: autopopulate.ts`
- [x] **Workout advances on completion (not by calendar date)** — `applyResults` advances `dayIndex`; session marked complete only in `completeWorkout`; `tests/domain/rotation.test.ts` + `tests/services/workoutFlow.test.ts`. `code-verified: workoutService.ts:144–184`

### Code structure (source-reviewable)
- [x] **Onboarding flow (§4a)** — 7 onboarding screens: `index.tsx`, `experience.tsx`, `schedule.tsx`, `goal.tsx`, `program.tsx` (help-me-pick + browse), `numbers.tsx` (1RM / 5RM with WeightSelector), `confirm.tsx`. `code-verified: app/onboarding/*`
- [x] **Today's workout screen + components wired to domain** — `today.tsx` shows `display.prescription.label` + per-exercise weight via `PlateLoad`. `code-verified: today.tsx:66–88`
- [x] **Set logging (1-tap common case visible)** — single Pressable `onPress={draft.completed ? onUnlog : onLog}` in `SetRow.tsx:65`; seeded from prescription. `code-verified: SetRow.tsx:63–66`
- [x] **Rest timer (service/hook/component + intervals + haptic)** — `restTimer.ts` timestamp math; `notifications.ts` scheduling; `useRestTimerTick.ts` ticks + AppState handler; `RestTimerBar.tsx` UI; haptics called via `haptics.tapLogged()` on log and `haptics.restComplete()` on completion. `code-verified: restTimer.ts, useWorkoutStore.ts:116–125`
- [x] **Backgrounded rest (local notification scheduling code)** — `scheduleRestEndNotification` called in `startRest`; `cancelRestEndNotification` called in `onRestComplete`/`stopRest`; both iOS and Android configured in `configureNotifications`. `code-verified: notifications.ts, useWorkoutStore.ts:116–133`
- [x] **Quick-switch resilience (state hydration code)** — `resolveToday` checks `getInProgress()` first; `saveProgress` called on every log; cold-start tested in `workoutFlow.test.ts:69–79`. `code-verified: workoutService.ts:67–113`
- [x] **Live Activity (best-effort: stub/scaffold)** — `src/services/liveActivity.ts` shim + `targets/RestTimerWidget/` Swift files + `plugins/withRestTimerLiveActivity.js`. `code-verified: services/liveActivity.ts, targets/*`
- [x] **History persistence (SQLite schema + migration + repo)** — `schema.ts` defines sessions/logged_sets tables; `SqliteSessionRepository.listCompleted`; switching program via `switchProgram` only flips `activeProgramId`, no deletes. `code-verified: schema.ts, sqlite.ts:114–151, workoutService.ts:188–197`
- [x] **Progress / PR detection UI components** — `progress.tsx` with `summarizeExercise` + `TrendBars` + `StatCard`; `PRCelebration.tsx` modal. `code-verified: progress.tsx, PRCelebration.tsx`

### Engineering hygiene (verifiable)
- [x] **`tsc --noEmit` is clean** — exit code 0, no output. `code-verified: tsc run`
- [x] **`npm test` passes** — 124 tests, 13 suites, all pass. `code-verified: jest run`
- [x] **Non-goals honored** — no auth/accounts/cloud sync/social/sharing (no user table in schema); no push notifications (local only); no cardio/nutrition/multi-user code found; no non-barbell equipment in exercise catalog. `code-verified: schema.ts, exercises.ts, notifications.ts`

### No-runtime constraint adherence
- [x] **Cell did NOT run native build commands** — session-log.md confirms: forbidden commands not used; `npm install` + `npx tsc` + `npx jest` + `npx eslint` only (all allowed per brief §7). `code-verified: session-log.md`
- [x] **Cell wrote full UI code (components + screens)** — 9 screens + 9 components + 5 state files. `code-verified: app/*, src/components/*, src/state/*`
- [x] **Planning artifacts acknowledged no-runtime scope** — README opening callout "This sprint is source + tests only"; HANDOFF.md §2 explicitly calls out deferred runtime behaviors. `code-verified: README.md:1–7, HANDOFF.md:1–5`

---

# COST AXIS

(from token-log.md)

| Metric | Value |
|---|---|
| Total tokens (Opus) | ~27.5M (11.9k in + 202.4k out + 27.2M cache-read + 261.7k cache-write) |
| Implied API cost | **$20.36** |
| API compute time (scored) | **0 h 41 m 13 s** |
| Active wall-clock | ~1 h 7 m |
| Operator-touch | minimal — 2 socket-error resumes only |
| Operator interventions | **0 product interventions** |
| LOC produced (token-log) | **8,097 net** |
| Sub-agents | 0 |
| Web searches | 0 |

## Derived ratios

| Ratio | Value | Note |
|---|---|---|
| Quality per 1K tokens | ~0.00147 | 40.5 / 27,475 — cache-dominated; compare like-for-like only |
| Quality per API hour | **~59.0** | 40.5 / 0.687 h |
| Defects per 1KLOC | **~0.74** | 6 / 8.097 — notably lower than run-001 (~2.34); the test suite catches latent defects earlier |
| Methodology overhead ratio | **n/a** | Vibe — no planning phases |
| Cost per binary outcome | **~$1.09** | $20.36 / (18 binary outcomes, design-verifiable set) |
| Quality per dollar | **~1.99** | 40.5 / 20.36 |

---

# PAIRED Δ vs run-001 (this cell)

| Metric | run-001 | run-002 | Δ | Interpretation |
|---|---|---|---|---|
| Quality /55 | 39 | **40.5** | +1.5 | run-002 higher on Code/SysDes (4.5/4.5 vs 4/4) and Assumptions (3 vs 2); run-001 had Maestro-verified live evidence. Measurement-condition difference (live sim vs code-only) accounts for much of this; treat as a cluster, not a clean rank. |
| Cost | $22.74 | **$20.36** | −$2.38 (−10.5%) | Run-002 spent 10% less; 0 web searches vs 7 |
| API compute | 45m 39s | **41m 13s** | −4m 26s (−9.7%) | Faster despite 58% more LOC — no sub-agent / no web searches |
| Defects/1KLOC | ~2.34 | **~0.74** | −1.60 | Dramatic density drop; 124-test suite catches latent issues rather than leaving them for a Maestro pass; run-001's higher count partly from live-sim discovery |
| Net LOC | 5,116 | **8,097** | +2,981 (+58%) | Run-002 adds: services layer, in-memory adapter, 124 jest tests, ESLint config, ASSUMPTIONS.md, HANDOFF.md, Live Activity scaffold |
| Tests shipped | `sim.ts` harness only | **124 jest (13 suites)** | — | Significant upside for code-quality fidelity and developer confidence |
| Sub-agents | 1 | **0** | −1 | Run-002 self-directed without a sub-agent exploration pass |

**Quality comparison note:** the +1.5-point advantage for run-002 reflects both genuine improvements (repository port pattern, 124-test suite, ASSUMPTIONS.md engagement) and measurement-condition differences (code-only scoring vs live-sim). Both cells demonstrate the identical Vibe profile: high product polish + strong engineering sub-dims; planning trio drag is the constant.

---

# HEADLINE FINDING

```
Quality: 40.5 / 55  (Product 16.5/20 · Rigor 24/35)  ·  Cost: $20.36 / 0h 41m API  ·  Binary: 18/18 design-verifiable pass
Defects: crit 0 · major 2 · minor 4 = 6 total  ·  ~0.74 / 1KLOC
```

Vibe run-002 — the no-runtime replication — shipped a substantially larger codebase (8.1K LOC vs run-001's 5.1K), a real Jest suite (124 tests vs none), and formal assumption + handoff documentation, all for 10% less cost ($20.36 vs $22.74) and with zero product interventions. The quality profile is the textbook Vibe signature: **strong product polish and engineering sub-dims (Code/SysDes 4.5/4.5, Sec/Doc 4/4) consistently undercut by the planning trio (Spec 1 / Scope 3 / Assump 3 = 7/15)** — the rich brief engaged the assumptions and scope explicitly in ASSUMPTIONS.md (outperforming run-001 on both dims), but without a pre-build spec document Vibe can never reach the planning-dim ceiling. The no-runtime constraint eliminated the completion-overlay defect that Maestro found in run-001 (not discoverable from code alone), but the same `logSet`/`finish` async discipline gap and 5/3/1 missing-deload-path persist — confirming they are structural Vibe patterns, not run-specific accidents.

---

## Failure mode characterization

- **Where Vibe broke down:** the planning trio — ASSUMPTIONS.md (written post-build) partially redeems Scope and Assumptions but cannot substitute for a pre-build spec. The brief's falsifiable §10 assumptions were engaged in prose rather than as tagged, machine-readable decisions.
- **Categories of mistake:** async discipline (no try/catch on store `logSet`/`finish` → silent DB failure risk); incomplete canon fidelity (5/3/1 `failures` counter tracked but deload not triggered); the "Today shows first set's weight not the top-set weight" display choice is borderline (may be intentional preview simplification).
- **Surprisingly well:** the repository port pattern (`src/db/types.ts` interfaces + dual SQLite/memory adapters) is a genuine design sophistication — it makes the full workout flow (log → complete → PR → program-switch-preserves-history) testable in pure Node with no device. This is not a pattern the brief asked for; it was inferred from the "unit-testable" requirement. The HANDOFF.md is a well-structured practitioner document, not boilerplate.
- **Notable artifacts:** ASSUMPTIONS.md is the best planning artifact this cell could produce without a methodology layer — brief §10 engaged point-by-point, non-obvious decisions documented with trade-offs. HANDOFF.md covers the follow-up sprint in enough detail to hand off to a different team.
- **Operator-tempted-but-didn't:** zero product interventions; 2 socket-error resumes are infrastructure noise. Strong leave-it-running signal.
- **Delight north-star (brief §8, §2):** PRCelebration modal (gold border `colors.pr`, trophy emoji, multi-PR list); `haptics.celebratePR()` on finish; RestTimerBar progress fill animates visually; +30s/−15s controls on rest timer. These were unprompted from the brief's "delight is the north star" language. Binary: **YES**.
- **Rich-brief engagement check (success-criteria.md §2):** Non-goals honored ✓ · Open assumptions engaged ✓ (ASSUMPTIONS.md) · Stretch stayed out ✓ · Delight north-star ✓ · No-runtime constraint honored ✓ · Equipment scope honored ✓ (barbell-only exercise catalog; PPL accessories substituted to barbell equivalents).
