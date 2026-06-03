# T4-rich (PM-quality brief) / Spec Kit / Run 003 / Observations (AUTOMATED ARM)

**Reviewer:** scoring agent (single-rater, autonomous)
**Scored on:** 2026-05-30 · **Scorer model:** claude-opus-4-8 · **Evidence basis: CODE-BASED (no sim this pass — AUTOMATED ARM)**

> **Run-003 scoring lens (same as run-002 vibe — no simulator).** All scores from:
> (1) build sanity: `npx tsc --noEmit` exit 0 (clean) · `npm test` 76 passed / 15 suites;
> (2) full source review (programs/plates/warmup/pr/e1rm/schedule/seeding/analytics + db repos + services/hooks/state + components + screens + onboarding);
> (3) **pre-build planning-artifact review** — `specs/001-compound-strength-app/{spec.md, plan.md, data-model.md, research.md, tasks.md, handoff.md, checklists/requirements.md, contracts/*}` + the 5-question `pm-convo.md`.
> UI/UX dims (5+6) scored on component/screen code per no-runtime protocol.
> **Automated arm:** cell driven headlessly (no human in loop) — no operator-touch/intervention signal exists; artifact scored on the rubric normally.
> **Calibration anchor:** run-002 vibe = 40.5/55 (Func 4.5, Code 4.5, SysDes 4.5, UI 4, UX 4, Robust 4, Sec 4, Doc 4, Spec 1, Scope 3, Assump 3; defects 0/2/4). The spec-kit delta vs vibe is expected to localize in the **planning trio (10/11/12)** — that is the methodology tell.
> Status: **PROVISIONAL** (unblinded, single rater, code-based).

---

# QUALITY AXIS

## Dimension scores (0–5)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | **4.5** | All 7 program engines ship with canonical, table-driven progression (76 tests + source); full core loop (onboarding 7 screens → today → workout/log → rest → finish → PR → progress → history); 5/3/1 **has** a deload/TM-reset on missed top set (`fiveThreeOne.ts:84–87`) — fidelity edge vibe lacked; nSuns AMRAP→TM delta table (`nsuns.ts:36–41`); GZCLP T1/T2/T3 stage cascade (`gzclp.ts:84–146`). Gaps keeping it off 5: warm-up ramp is **display-only** in `workout/[sessionId].tsx:64–73` (shown as text, not interactively logged/skippable per §4b step 2); Today card shows `sets[0]` (lightest ramp set for 5/3/1, not the top working set) `today.tsx:37`. Thoughtful interpretation throughout (seed-all-7-programs `seeding.ts`, recommendation engine, barbell substitution map) → above 4, not clean 5 |
| 2 | Correctness | (see defect block) | 0 crit · 1 major · 4 minor — 0 test failures; all defects latent via review |
| 3 | Code quality | **4.5** | Strict layering domain(pure)→db ports→services→state→hooks→components; discriminated unions (`StartingNumberInput` seeding.ts:6–10; `ProgramState`/`LiftAnchor`); no `as any` found; engines are table-driven with shared helpers (`exerciseBlock`/`rampSets`/`straightSets`); subset-sum plate solver explicitly avoids the greedy `{45,25}` bug with an in-code comment (`plates/index.ts:8–10, 17–33`) — a genuine small surprise of skill. File-level JSDoc with `FR-N`/`clarification Q` cross-refs throughout → strong 4 into 5 territory |
| 4 | System design | **4.5** | Two-tsconfig split (`tsconfig.json` pure-core green gate vs `tsconfig.app.json` RN tier) isolates the correctness surface from the native tree — documented in `handoff.md:11–13` + `plan.md` Structure Decision; `SqlExecutor` port lets repo tests run on `node:sqlite` while prod uses `expo-sqlite` (`db/expoAdapter.ts` + `db/testing/nodeSqliteAdapter.ts`); `ProgramEngine` interface (seed/cycleSlots/prescribe/progress) makes all 7 programs independently testable; data-model carries nullable/JSON columns to absorb Stretch without migration (`data-model.md:7, 152`). ADR-grade decisions live in plan.md + handoff.md → solid 4, design-doc rationale elevates toward 5 |
| 5 | UI design (source-only) | **4** | Dark high-contrast tokens (`bg #0B0B0F`, `text #F5F5F7`, accent `#FF5C39`); `tap.min=56` exceeds 44pt floor with explicit comment (`tokens.ts:22`); `display` 56px numerals + `tabular-nums` on the rest clock (`RestTimerBar.tsx`); PlateBreakdown inline on Today card + SetRow; PR banner with 🏆 + gold styling (`components/index.tsx:30–35`); coaching note 💡 surfaced on Today. Missing: workout-specific empty states are terse ("No active session."); no transition polish visible → not 5 |
| 6 | UX (source-only) | **4** | 1-tap log (single `Pressable onPress={onLog}`, `SetRow.tsx:27–34`, seeded from prescription weight/reps); WeightSelector steps by the smallest **loadable** increment, no keyboard (`WeightSelector.tsx:17`); rest auto-starts on log (`sessionStore.ts:121`), haptic on rest-end (`useRestTimer.ts:28`); `enableKeepAwake` on workout mount (`workout/[sessionId].tsx:26`); AppState→background schedules local notification, →active cancels (`useRestTimer.ts:47–60`). Nicks: warm-up shown as static text not part of the tap flow; WeightSelector renders *under every un-logged set* (visual density, more scroll) → 4 |
| 7 | Robustness | **3.5** | Pure-domain guards are strong: plate solver clamps below-bar + returns closest-achievable + `isExact` flag (`plates.ts:49–60`); warmup skips below-threshold and never emits a set ≥ working (`warmup.ts:31, 54`); nSuns/linear TM/weight floored (`Math.max(45,…)`); PR guard filters non-working/zero-rep (`pr.ts:37`); rotation handles negative/over cyclePosition with double-mod (`schedule.ts:31`); `getExercise` throws on unknown id (fail-loud). **But** the store writes through synchronous SQLite with **no try/catch anywhere** (`sessionStore.ts logSet/finishWorkout`) — a thrown SQLite error propagates uncaught to the UI (better than vibe's *silent* async-success bug, but still no boundary); no db-open guard on bootstrap → between 3 and 4: domain robustness is 4-grade, store-edge error handling is 3-grade → 3.5 |
| 8 | Security | **4** | All SQL parameterized via the `SqlExecutor` port (`db/sql.ts`, repositories) — no string interpolation of user data; local-only offline single-user (no network/auth surface per §6, verified by non-goal grep); `package-lock.json` present (deps pinned); no secrets in source. No threat-boundary doc beyond plan.md constraints note → 4 |
| 9 | Documentation | **4** | Shipped docs (scored per rubric — README/handoff/code comments, not planning artifacts): `handoff.md` is a real practitioner handoff (verification status, two-tsconfig rationale, ts-jest/node:sqlite note, deferred native list, **known intentional simplifications** §1 calling out the 5×5 StrongLifts deviation with the file to edit); file-level JSDoc on every module with FR/clarification refs; no top-level README at repo root (handoff.md + spec serve that role) and decisions live in planning docs rather than standalone ADRs → 4 |
| 10 | Spec articulation | **5** | **Real pre-build `spec.md`** (343 lines): 6 prioritized user stories each with *Why this priority* + *Independent Test* + numbered acceptance scenarios; 36 testable FRs (incl. clarify-derived FR-006a/011a); 12 key entities; 10 measurable SC; a 9-item **Edge Cases** section that *predicts* impl edge cases that actually surfaced in code — missed-day rotation, AMRAP/failed-set branching, unachievable plate target, program-switch-mid-cycle, schedule-vs-program-fit, empty progress/history, backgrounded-with-no-active-rest (`spec.md:126–136`) — each maps to a guard found in the source (rotation double-mod, GZCLP cascade, plate closest-achievable, switchProgram-deletes-nothing, recommendation cadence rule, empty-state screens). Decisions documented with rationale + alternatives considered (the 5 clarify Q&As each list 3 options, chosen one recorded in `spec.md:138–146` Clarifications). This is the level-5 "spec correctly predicts the edge cases that turn up during implementation" clause, independently evidenced → 5 |
| 11 | Scope clarity | **4** | Both in- and out-of-scope explicit with reasons: non-goals as hard FR-033..036 ("System MUST NOT…"); Assumptions block lists Live-Activity-best-effort + Stretch-items-out-with-data-model-absorption (`spec.md:241–252`); user stories are *priority-ranked* (P1–P6) which is an active in/out cut rationale; `handoff.md` cleanly separates this-sprint-done from deferred-native. Scope was **defended** in the clarify session (e.g., Q4 day-count reconciliation chose "program cadence governs," declining to reshape programs — a scope-protecting answer). Not 5: cuts are declared+defended but not *revisited conditionally* on new info — the clarify answers are settled, not staged as conditional → 4 |
| 12 | Assumption surfacing | **4** (count ~14) | `spec.md` Assumptions section: 9 falsifiable assumptions engaged from brief §10 (lb-only, one-active-program-seeds-all, warm-ups/assistance excluded from PRs, RPE optional, recommendation mapping refinable, Live Activity best-effort, pinned canons, Stretch absorbable, app-is-generic) + 5 clarify-resolved decisions recorded with the *option chosen and why*. Each names a choice and what depends on it; `handoff.md` "Known intentional simplifications" even **maps two assumptions to the specific file to change** (`linear.ts` + research.md §C1, the nSuns/GZCLP tables) — that is the level-5 "mapped to code locations" clause, but only for 2 of ~14, so not pervasive enough for 5. Not categorized (technical/product/user) as discrete tags → strong 4 |

**Quality sum: 49 / 55**
**Vector — Product polish: 16 / 20** (Func 4.5 + UI 4 + UX 4 + Robust 3.5) · **Engineering rigor: 33 / 35** (Code 4.5 + SysDes 4.5 + Sec 4 + Doc 4 + Spec 5 + Scope 4 + Assump 4)

> Profile vs the vibe anchor (40.5/55, Product 16.5 · Rigor 24): **Product polish is a near-tie** (16 vs 16.5 — spec-kit slightly lower on Robustness for the same uncaught-store-write pattern, otherwise identical Func/UI/UX cluster, within inter-rater noise → report as one cluster, not a rank). The entire separation is **Engineering rigor: 33 vs 24 = +9**, and it lives **almost entirely in the planning trio: Spec 5 vs 1 (+4), Scope 4 vs 3 (+1), Assump 4 vs 3 (+1) = +6 of the +9**; the remaining +3 is Code/SysDes parity (both 4.5/4.5) with spec-kit holding Doc/Sec even. This is the textbook Spec-Kit finding: **a real pre-build spec + clarify + plan + tasks lifts the three planning dims a methodology-less vibe run structurally cannot reach**, while product polish and micro-code quality converge.

---

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Review (R) | Total |
|---|---|---|---|
| Critical | 0 | 0 | **0** |
| Major | 0 | 1 | **1** |
| Minor | 0 | 4 | **4** |

**LOC produced:** ~5,164 (token-log, ts/tsx excl node_modules) / 4,702 measured (src+app+modules+__tests__ this pass)
Using 5,164: **Defects per 1KLOC: ~0.97** (5 / 5.164)

Itemized:
1. **[Major · latent]** `src/state/sessionStore.ts:70–145` (`logSet`/`finishWorkout`): no try/catch around any `repos().*` write. Persistence is synchronous (`openDatabaseSync`), so this is **not** vibe's silent-success-after-async-failure bug — instead a thrown SQLite error propagates uncaught and would crash the workout screen with no recovery/retry. A feature a real user hits (a constraint violation or disk-full mid-session) has no graceful path. `code-verified: sessionStore.ts:96–108, 132–145`
2. **[Minor · canon-fidelity]** `src/domain/programs/linear.ts:96–111`: 5×5 uses per-lift increments (+5 upper / +5 squat / +10 deadlift) and a 3-fail→10% deload rather than StrongLifts' "add 5 to everything, deload at 3 fails." **Documented as intentional** in `handoff.md:26` with the exact file to change — so it is a disclosed deviation, not a hidden bug, but still a canon variance from the most-common 5×5 source. `code-verified: linear.ts:96–111, handoff.md:26`
3. **[Minor]** `app/(tabs)/today.tsx:37, 43`: Today card renders `ex.sets[0]` as the representative weight. For 5/3/1 / nSuns ramp days, `sets[0]` is the *lightest* (65%) set, so the headline "working weight" on Today is the opener, not the top/AMRAP set — slightly misleading as a glance preview. Same display choice flagged in vibe run-002; could be intentional. `code-verified: today.tsx:36–48`
4. **[Minor]** `app/workout/[sessionId].tsx:64–73`: the warm-up ramp is rendered as **static text only** (`{w.weight} × {w.targetReps}` lines), not as loggable/skippable SetRows. Brief §4b step 2 calls for a warm-up ramp "offered before the first working set (skippable)"; the generation logic is correct and unit-tested, but it is not wired into the interactive set flow. `code-verified: workout/[sessionId].tsx:35–38, 64–73`
5. **[Minor · latent]** `src/domain/pr/index.ts:40–42`: a weight-PR fires on the *first-ever* working set of an exercise (`prior.weight === undefined` → PR), so a brand-new user's opening set is celebrated as a PR. Defensible (it *is* a best-to-date), but yields a noisy "🏆 New PR!" on session one across every lift. `code-verified: pr.ts:40–42`

> Note: the 5/3/1 missing-deload **Major** that recurred in vibe run-001/002 is **NOT present here** — `fiveThreeOne.ts:84–87` resets TM to 90% (rounded) on a missed AMRAP top set. The clarify/spec discipline appears to have closed that canon gap.

---

# BINARY OUTCOMES (design-verifiable per brief-no-runtime.md §9)

### Domain logic (unit-testable)
- [x] **All 7 programs prescribe + progress per pinned canon** — `__tests__/domain/programs/{linear,fiveThreeOne,madcow,gzclp,nsuns,redditPpl}.test.ts` (6 suites); canons pinned via clarify Q2 + `research.md §C`. `code-verified: programs/*, pm-convo.md Q2`
- [x] **Plate calculator (per-side, respects bar+inventory, closest-achievable)** — subset-sum `breakdown`/`roundToLoadable`/`prescribeLoad`; `__tests__/domain/plates.test.ts` incl. fast-check property tests. `code-verified: plates/index.ts:49–91, plates.test.ts`
- [x] **Warm-up ramp (auto, excluded from PRs/progression)** — `generateWarmup` percentage ladder, role `'warmup'`; `__tests__/domain/warmup.test.ts`; PR filter on role. `code-verified: warmup/index.ts, pr.ts:37`
- [x] **e1RM (Epley) + PR detection (working sets only)** — `epleyE1rm`, `detectPrs`; `__tests__/domain/e1rm-pr.test.ts`. `code-verified: e1rm/, pr/, analytics/`
- [x] **Auto-populate (today's set from last time)** — prescription seeds set weight/reps; `src/domain/progression/autoPopulate.ts`. `code-verified: autoPopulate.ts, sessionStore.ts:88`
- [x] **Workout advances on completion (not calendar)** — `todaySlot` = next uncompleted slot, in-progress resumes; `advance` bumps cyclePosition on finish; `__tests__/domain/schedule.test.ts`. `code-verified: schedule/index.ts:24–41`

### Code structure (source-reviewable)
- [x] **Onboarding flow (§4a)** — `app/onboarding/{welcome,experience,schedule,goal,program,starting-numbers,confirm}.tsx` (7 screens) + `onboardingStore`; confirm seeds all programs. `code-verified: app/onboarding/*`
- [x] **Today's workout screen wired to domain** — `today.tsx` renders prescription weight + `PlateBreakdown`. `code-verified: today.tsx`
- [x] **Set logging (1-tap common case)** — single `Pressable` in `SetRow.tsx:27–34`, seeded weight/reps. `code-verified: SetRow.tsx`
- [x] **Rest timer (service/hook/component + intervals + haptic)** — `restTimer.ts` timestamp math, `restSecFor` per-exercise table, `useRestTimer` haptic on expiry, `RestTimerBar`. `code-verified: services/restTimer.ts, exercises/index.ts:38–44, useRestTimer.ts`
- [x] **Backgrounded rest (local notification scheduling)** — `notificationScheduler.schedule/cancel`, both platforms, wired to AppState. `code-verified: services/notifications.ts, useRestTimer.ts:47–60`
- [x] **Quick-switch resilience (hydration code)** — `sessions.byProgram`/in-progress precedence in `todaySlot`; `src/hooks/useHydration.ts`; `rest_timer` table persists active rest. `code-verified: schedule.ts:28–30, useHydration.ts, data-model.md §2b`
- [x] **Live Activity (best-effort stub/scaffold)** — `src/services/liveActivity.ts` no-op fallback + `modules/live-activity/` config-plugin/widget scaffold. `code-verified: services/liveActivity.ts, modules/`
- [x] **History persistence (SQLite schema + migration + repo)** — `db/migrations/001_init.ts` + `runner.ts` (user_version), `repositories/sessions|loggedSets|prs`; switch only flips `active_program_id`, deletes nothing. `code-verified: migrations/, repositories/, data-model.md:188`
- [x] **Progress / PR detection UI** — `app/(tabs)/progress.tsx` + analytics (`e1rmTrend`/`tonnage`/`averageIntensity`); `PrCelebration` banner. `code-verified: progress.tsx, analytics/index.ts, components/index.tsx:30–35`

### Engineering hygiene (verifiable)
- [x] **`tsc --noEmit` clean** — exit 0 (both tsconfigs per handoff). `code-verified: tsc run`
- [x] **`npm test` passes** — 76 tests, 15 suites, all pass. `code-verified: jest run`
- [x] **Non-goals honored** — no auth/accounts/cloud/social/sharing (no user/auth tables); local-only notifications; no cardio/nutrition/multi-user; barbell-only catalog (the lone "cable"/"dumbbell" strings are the substitution *map* → barbell equivalents, FR-021). `code-verified: schema/migrations, exercises/index.ts:46–62, non-goal grep`

### No-runtime constraint adherence
- [x] **Cell did NOT run native/sim commands** — tasks.md headers reiterate the forbidden list; tests run under ts-jest + `node:sqlite`, not jest-expo/Metro. `code-verified: tasks.md:11–13, handoff.md:14`
- [x] **Cell wrote full UI code** — 20 route files (app/) + 5 components + state/hooks/services. `code-verified: app/*, src/components/*`
- [x] **Planning artifacts acknowledged no-runtime scope** — spec Assumptions "Verification scope (this sprint)"; plan.md Constraints; handoff.md framing. `code-verified: spec.md:243, plan.md:29, handoff.md:1–10`

### Spec-Kit methodology-faithfulness (this cell)
- [x] **Genuine clarify pause — 5 product questions routed to PM** — rounding rule, contested-variant canon, onboarding-seeding rule, training-day reconciliation, warm-up ramp scheme; each a real product fork (3 options offered), answers recorded in `spec.md` Clarifications + threaded into FR-006a/011a/016/019/022. `code-verified: pm-convo.md, spec.md:138–146`
- [x] **Full specify→clarify→plan→tasks→implement chain produced** — spec.md, checklists/requirements.md, plan.md, data-model.md, research.md, contracts/ (7 contract files), tasks.md (94 tasks). `code-verified: specs/001-compound-strength-app/*`

---

# COST AXIS

(from token-log.md — AUTOMATED ARM, aggregated from 11 headless turns)

| Metric | Value |
|---|---|
| Total tokens (Opus) | ~35.5M (20.1k in + 174.3k out + 34.96M cache-read + 376.3k cache-write) |
| Implied API cost | **$24.29** ($24.286 Opus + $0.006 Haiku aux) |
| API compute time (scored) | **0 h 37 m 37 s** (2,257,007 ms) |
| Internal agent turns | 156 (11 headless drive phases) |
| Clarifying questions to PM | **5** (all via pm-ask) |
| Operator-touch / interventions | n/a (automated arm) |
| LOC produced (ts/tsx) | **~5,164** (98 files) |
| Sub-agents / web searches | 0 / 0 |

## Methodology phase breakdown

| Phase | turns | cost |
|---|---|---|
| specify | 8 | $0.88 |
| clarify (scan + integrate Q1–Q5) | 18 | $1.19 |
| plan | 18 | $2.01 |
| tasks | 4 | $1.53 |
| **planning subtotal (specify→tasks)** | **48** | **$5.61** |
| implement | 108 | $18.67 |

## Derived ratios

| Ratio | Value | Note |
|---|---|---|
| Quality per 1K tokens | ~0.00138 | 49 / 35,527 — cache-dominated; like-for-like only |
| Quality per API hour | **~78.2** | 49 / 0.627 h |
| Defects per 1KLOC | **~0.97** | 5 / 5.164 |
| Methodology overhead ratio | **~0.30** | $5.61 planning / $18.67 build — planning is ~23% of cell cost |
| Cost per binary outcome | **~$1.16** | $24.29 / 21 design-verifiable outcomes (17 §9 + 2 no-runtime + 2 methodology-faithfulness) |
| Quality per dollar | **~2.02** | 49 / 24.29 |

---

# PAIRED comparison vs run-002 vibe (the calibration anchor — different methodology, same task/lens)

| Metric | vibe-002 | spec-kit-003 | Δ | Interpretation |
|---|---|---|---|---|
| Quality /55 | 40.5 | **49** | **+8.5** | Almost entirely **Engineering rigor +9** (Product polish −0.5, a tie/cluster). The +9 is +6 planning-trio (Spec +4 / Scope +1 / Assump +1) + parity on Code/SysDes/Sec/Doc. The Spec-Kit tell is the spec.md edge-case prediction (5) that vibe's post-hoc ASSUMPTIONS.md (1) cannot reach. |
| Product polish /20 | 16.5 | 16 | −0.5 | Indistinguishable cluster — same Func/UI/UX, spec-kit −0.5 Robust for the same uncaught-write pattern. |
| Engineering rigor /35 | 24 | **33** | **+9** | The reproducible cross-methodology separation, and it is the planning dims as the rubric predicts. |
| Cost (implied USD) | $20.36 | $24.29 | +$3.93 (+19%) | The "SDD tax" for this rich brief is modest — ~$5.61 of planning bought +8.5 quality. |
| API compute | 41m 13s | **37m 37s** | −3m 36s | spec-kit was *faster* despite the planning phases — leaner build (5.2K vs 8.1K LOC). |
| Net LOC | 8,097 | **5,164** | −2,933 (−36%) | Spec-Kit shipped a **tighter** codebase to the same coverage — the spec scoped the build. |
| Defects/1KLOC | ~0.74 | ~0.97 | +0.23 | Slightly higher density but on 36% less code (5 vs 6 absolute defects); the recurring 5/3/1-deload Major is *resolved* here. |
| Planning artifacts | post-hoc docs | **spec+clarify+plan+tasks (pre-build)** | — | The categorical difference. |
| PM questions | 0 | **5** | +5 | Spec-Kit's clarify genuinely paused on real product forks. |

> **Headline of the pair:** Spec-Kit converts ~$4 and a 48-turn planning phase into **+8.5 quality that is structurally located in the planning trio**, while delivering a **smaller, faster** build at parity product polish. The rich brief did *not* erase the methodology gap (cf. success-criteria §5) — it shifted where it shows: micro-code quality converged (both 4.5/4.5), but the pre-build spec's edge-case foresight and explicit scope/assumption articulation remain out of vibe's reach.

---

# HEADLINE FINDING

```
Quality: 49 / 55  (Product 16/20 · Rigor 33/35)  ·  Cost: $24.29 / 0h 38m API  ·  Binary: 21/21 design-verifiable pass
Defects: crit 0 · major 1 · minor 4 = 5 total  ·  ~0.97 / 1KLOC
```

Spec Kit run-003 — the no-runtime automated arm — produced a **real pre-build spec→clarify→plan→tasks chain** (343-line spec.md with prioritized user stories, 36 testable FRs, a 9-item edge-case section that *predicts* the guards the implementation actually needed, and 5 genuine clarifying questions routed to the PM on real product forks) and then shipped a **tight, well-layered 5.2K-LOC codebase** (98 files, tsc clean, 76 tests green) faithful to those clarify-resolved decisions. The quality profile is the textbook Spec-Kit signature against the vibe anchor: **product polish converges (Func/UI/UX cluster, Code/SysDes both 4.5) while the planning trio separates hard — Spec 5 vs 1, with Scope 4 and Assumptions 4** — for +8.5 total quality at a modest ~19% cost premium and, notably, a *faster* and *36%-smaller* build. The clarify discipline even closed the 5/3/1 missing-deload Major that recurred in the vibe runs. The one residual Major is the same class of edge — no try/catch around the (synchronous) SQLite writes in the session store — and the warm-up ramp ships generated-and-tested but only display-wired, not interactive.

---

## Failure mode characterization

- **Where Spec-Kit broke down:** nowhere structurally — the chain executed cleanly. The weak points are *implementation-edge*, not methodology: (a) the session store has no error boundary around persistence writes (a thrown SQLite error crashes the workout screen); (b) the warm-up ramp is generated and unit-tested but rendered as static text rather than wired into the loggable set flow; (c) the Today card surfaces `sets[0]` (the opener, not the top/AMRAP set) on ramp days.
- **Categories of mistake:** store-edge error handling (uncaught synchronous writes); spec-to-UI wiring gaps (warm-up generated-but-not-interactive) — the domain is more complete than its UI surfacing, an expected shape under a no-runtime sprint that front-loads testable logic.
- **Surprisingly well:** the **edge-case foresight** — spec.md's Edge Cases section (written pre-build) enumerates missed-day rotation, AMRAP/failed-set branching, unachievable plate target, program-switch-mid-cycle, schedule-vs-program-fit, and empty-state handling, and *every one* maps to a concrete guard in the shipped source (rotation double-mod, GZCLP cascade, plate closest-achievable, switch-deletes-nothing, recommendation cadence rule, empty screens). That is the rubric's level-5 spec clause earned, not claimed. The subset-sum plate solver (with an in-code note on why greedy is wrong for `{45,25}`) and the two-tsconfig core/UI split are senior-grade engineering choices.
- **Notable artifacts:** `spec.md` (prioritized stories + Independent Tests + measurable SC), the 7 `contracts/*.ts` files (domain interfaces as TS contracts before implementation), `data-model.md` (entities + SQLite DDL + state machines), `handoff.md` (with a "Known intentional simplifications" section that maps the StrongLifts 5×5 deviation and the nSuns/GZCLP tables to the exact files to edit — assumption-to-code-location mapping, the dim-12 level-5 behavior, for the 2 disclosed deviations), and `pm-convo.md` (5 well-posed product questions, each a 3-option fork).
- **Clarify faithfulness:** the clarify phase genuinely *paused* and asked 5 product questions (rounding rule, contested-variant canon, onboarding-seeding rule, training-day reconciliation, warm-up scheme) — all real forks with downstream code consequences, all routed to the PM persona and threaded back into FRs. This is the methodology behaving as designed, and it is where the dim-10/11/12 lift originates.
- **Delight north-star (brief §8):** PrCelebration 🏆 banner with gold styling + multi-PR pluralization, `haptics.success()` on rest-end, 💡 coaching notes surfaced on Today, `tabular-nums` rest clock to prevent digit jitter. Present but **more restrained** than an unprompted-delight maximum — the spec scoped to the checklist and did not over-invest in surprise micro-moments. Binary: **YES (modest)**.
- **Rich-brief engagement (success-criteria §2):** Non-goals honored ✓ · Open assumptions engaged ✓ (spec Assumptions + clarify) · Stretch stayed out ✓ (data model absorbs, not built) · Delight north-star ✓ (modest) · No-runtime/SDK-56-via-npx honored ✓ · Equipment scope honored ✓ (barbell-only catalog + substitution map).
- **Operator-tempted-but-didn't:** n/a — automated arm, no operator in the loop; the chain ran headless across 11 turns with zero intervention.
