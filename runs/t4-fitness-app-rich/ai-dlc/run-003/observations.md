# T4-rich (PM-quality brief) / AI-DLC / Run 003 / Observations (AUTOMATED ARM)

**Reviewer:** scoring agent (single-rater, autonomous)
**Scored on:** 2026-05-30 · **Scorer model:** claude-opus-4-8 · **Evidence basis: CODE-BASED, NO-RUNTIME (same lens as run-002)**
**Arm:** AUTOMATED (headless `claude -p`, gated Inception→Construction, PM persona answered via `pm-ask`)

> ⚠ **Automated arm.** Cell driven headlessly (no human in loop). Artifact scored on the same rubric; cost-axis compared with the automated-arm caveat (no operator-touch/intervention signal exists).

> **Run-003 scoring lens.** No simulator. All scores from:
> (1) build sanity — `npm test` 111/111 pass across 17 ts-jest suites; `tsc -p tsconfig.verify.json` (pure layers) **exit 0 clean**; **full-app `tsc --noEmit` = 325 errors, ENVIRONMENTAL** (see gate note below);
> (2) full source review (domain engines, plates/warmup/PR/recommender, services + platform-port layer, persistence, state stores, theme, Today screen + SetRow, scaffolds);
> (3) planning-trail review — the heaviest of any cell: `aidlc-docs/inception/{requirements,user-stories,application-design,plans}/` + `construction/.../{code-summary,handoff-note}` + `audit.md` (timestamped decision log).
> UI/UX dims (5+6) scored on component/screen code per no-runtime protocol.
> **Calibration anchor:** run-002 vibe = 40.5/55 (Func 4.5 · Code 4.5 · SysDes 4.5 · UI 4 · UX 4 · Robust 4 · Sec 4 · Doc 4 · Spec 1 · Scope 3 · Assump 3; defects 0/2/4).
> Status: **PROVISIONAL** (unblinded, single rater, code-based).

---

## ⚠️ Objective-gate notes (read before the dimension scores)

**1. `tsc --noEmit` (full app): 325 errors — ENVIRONMENTAL, not logic bugs.**
Root cause is a single missing dependency: `tsconfig.json(2): error TS6053: File 'expo/tsconfig.base' not found`. The cell's `node_modules` is an incomplete offline install missing `expo`/`react`/`react-native` (the brief forbids the build/install cycle that would pull the full SDK 56 tree). That one missing base config + missing type packages cascade into the entire count:
- **172× TS17004** "Cannot use JSX unless the '--jsx' flag is provided" — `jsx` is set by `expo/tsconfig.base`, which is absent → every `.tsx` JSX expression errors.
- **73× TS2307** "Cannot find module 'expo'/'react'/'react-native'/'expo-router'/…" — the RN/Expo type packages aren't installed.
- **24× TS7006 / 13× TS2741 / 9× TS2322 / 7× TS7031** — downstream: e.g. `createStore<SettingsStore>((set) => …)` in `stores.ts` *is* generically typed, but with `zustand` unresolved (TS2307) the generic loses its binding and `set` collapses to implicit-any. These are artifacts of the missing modules, **not** authored implicit-anys (verified by spot-reading 10 errors).

The cell **explicitly designed around this**: `tsconfig.verify.json` typechecks the pure layers (domain/persistence/services/state/theme, ex-native) and **passes clean (exit 0)**, and `handoff-note.md §1` defers `npx expo install --check → full tsc` to the platform team, naming exactly which files need RN/Expo types. **Scored as a real engineering-hygiene gap** — the brief §9 says "`npx tsc --noEmit` is clean," and the other 5 run-003 cells are tsc-green as-shipped; this one is not. But it is a **dependency/finish gap, NOT 325 defects** — the authored code is type-correct under the carved-out config and the deferral is documented. Treated as a one-notch hit on hygiene (Doc) and itemized once as a Minor.

**2. `npm test`: 111 passed / 17 suites** — the domain + persistence + services + state logic compiles and passes under ts-jest pure-Node (the §9 primary deliverable).

**3. DEPTH-FIRST scope (PM-steered, Q3=A / Q6=C).** Fully built + tested: **5×5, 5/3/1, GZCLP** (linear / TM-wave / cascade archetypes) **+ 5×3** via the shared linear engine = **4 available programs**. **Scaffolded** (`available:false`, `prescribe` throws `ProgramNotImplementedError`): **Madcow, nSuns, Reddit-PPL**. This is **fewer features than the all-7 cells** — Functionality (dim 1) is scored honestly against the brief's all-7 expectation, while crediting the deliberate, documented, PM-chosen depth-first tradeoff. ~5,424 LOC, 91 files, 7 gated clarifying questions (most of any cell).

---

# QUALITY AXIS

## Dimension scores (0–5)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | **3.5** | Core loop is complete + correct for what's built (onboarding state machine → Today w/ plate load → 1-tap log → rest timer → PR detect → progression → history → progress charts), and the **4 shipped programs are canon-correct** (5×5 linear +5/+10 & 3-fail deload `linear.ts:110–121`; 5/3/1 TM-wave + AMRAP + BBB + cycle bump `fiveThreeOne.ts:73–125`; GZCLP T1/T2/T3 cascade + reset `gzclp.ts:118–164`). But **3 of 7 programs are scaffolded stubs that throw** (`scaffolds.ts:37–39`) — a real coverage gap against the brief's all-7 ask. Depth-first was PM-chosen + documented; the engine interface provably absorbs all 7 archetypes (NFR-9). Below the all-7 cells on breadth → **3.5**, not the 4.5 a complete-and-correct all-7 build would earn |
| 2 | Correctness | (see defect block) | 0 crit · 1 major · 4 minor — 0 test failures; defects via code review (async DB-write race; warmup sparse edge; recommender day-mismatch copy; 5/3/1 fixed-bump fidelity) + the env-tsc hygiene gap |
| 3 | Code quality | **4.5** | Discriminated-union domain types; engine-private `ProgramState.data` (each archetype stores only what it needs); intentional naming (`isMainWorkingSet`, `nearestLoadable`, `notificationDelaySeconds`); file-level JSDoc with `FR-/AC-` back-references on every module; **no authored `as any`** (the tsc-anys are env cascade, not source). The **platform-port pattern** (`HapticsPort`/`NotifierPort`/`LiveActivityPort` injected into `RestTimerCoordinator`) is a genuine small surprise of skill → strong 4 pushing into 5 via the port abstraction + comment discipline |
| 4 | System design | **4.5** | Strict inward-only layering domain→persistence→services→state→UI, **domain imports zero RN/Expo** (enforced + documented `application-design.md:19–20`); one `ProgramEngine` interface unifies all 7 archetypes so Tier-2 slots in without refactor; **engine state serialized as opaque JSON** keeps the SQLite schema stable as engines evolve (explicitly to absorb §11 stretch); versioned transactional migrations (`migrations.ts:24`). Design decisions documented with rationale in `application-design.md §"Design decisions & rationale"` → solid 4, the documented-ADR-style rationale + archetype-generalizing interface push toward 5 |
| 5 | UI design (source-only) | **4** | Dark high-contrast tokens (`bg:#0B0D10`, `text:#F5F7FA`), display numerals (48/64px), tap targets `touchTarget={min:48,comfortable:64,large:80}` all > 44pt floor; plate chips color-coded by denomination (`plateColor()`); PlateLoadView inline on every SetRow; PRCelebration component; coaching notes surfaced; docked RestTimerBar. Considered, sweaty-hands-aware. Missing: no per-screen empty-state care beyond "Loading today…" text; delight present but checklist-level not surprising → not quite 5 |
| 6 | UX (source-only) | **4** | 1-tap log (single `Pressable` `set-log`, weight+reps pre-seeded via `seedSetValue` `today.tsx:89`); rest auto-starts on log w/ haptic (`restTimerCoordinator.startRest` haptic+notif+LiveActivity); timestamp-based timer ticks drift-free + re-syncs on foreground (`onForeground`); keep-awake on `beginWorkout`; backgrounded local-notification scheduled+cancelled-on-return — **all of it test-exercisable in Node via the ports**. Nick: warmup ramp shown as a strip (extra glance), and the docked timer + "Finish" button share bottom space (footer-overlap risk, INDETERMINATE without sim) → 4 |
| 7 | Robustness | **4** | `computeLoad` handles below-bar + inexact targets (leftover/exact flags); `generateWarmup` guards `workingWeight<=bar`; rest math clamps; recommender soft-penalizes day-mismatch rather than excluding (always yields a runnable program); migrations transactional w/ rollback; scaffolds advance the rotation pointer so the interface contract holds even while unimplemented. Missing: **no try/catch around async DB writes** in `logSet`/`completeWorkout`/stores — a SQLite failure leaves UI state ahead of persistence (same class as vibe) → not 5 |
| 8 | Security | **4** | Parameterized SQL throughout the repositories; offline single-user no-network no-auth design per brief §6 (no user/credential surface); `package-lock.json` present (deps pinned); no secrets in source; non-goals honored (no auth/cloud/social/sharing/push). Q1 security-baseline extension explicitly opted OUT with justification (offline/single-user/no-PII) — a reasoned scope decision, logged in `audit.md`. No threat-boundary doc → 4 |
| 9 | Documentation | **4** | README: headline value + architecture tree + no-runtime callout + per-program depth table + verify commands. `handoff-note.md`: precise follow-up-sprint checklist (dependency reconcile → full tsc → prebuild → device verify → Live Activity wiring), naming exact files needing RN/Expo types. `code-summary.md` per unit. File-level JSDoc with FR/AC refs everywhere. The full Inception trail is itself onboarding-grade. Slight ding: ships **not** tsc-green so a fresh contributor hits 325 errors before reading the handoff → 4 |
| 10 | Spec articulation | **5** | **The heaviest, most rigorous pre-build spec of any cell.** `requirements.md`: intent analysis, 30+ `FR-<area>-n` traced to brief §§, 12 NFRs, **pinned canonical source table per program** (the adjudication basis for "correct progression"), 8 binding assumptions, **18 acceptance criteria each traced to a brief §9 line**. Decisions documented with rationale + alternatives (depth-first vs breadth, archetype-first ordering) at the requirements gate. And it **correctly predicted impl edge cases** that turn up in code — engine-private serialized state for schema stability, the archetype-generalization requirement, warm-up/assistance PR-exclusion enforced structurally, day-mismatch handling. Meets the level-5 "spec predicts the edge cases that turn up during implementation" clause, independently evidenced → **5** |
| 11 | Scope clarity | **4.5** | In-scope (FR areas A–E), out-of-scope (§5.3 non-goals enumerated), AND **deferred-to-stretch (§5.4) explicitly listed with the design commitment to absorb them without refactor**; depth-first Tier-1/Tier-2 split stated with reasons. Scope was **actively negotiated** — the 7-question gate surfaced the prioritization tension to the PM and the answer (Q3=A) was woven back into FR-PR-6 + §5.2. Just shy of 5: the cut was *declared+defended+gated* but not *revisited when new info surfaced mid-build* (no new info surfaced to force a revisit) → **4.5** |
| 12 | Assumption surfacing | **5** | `requirements.md §7` accepts all 8 brief §10 assumptions **as binding requirements** (Q5=A), each named; assumptions are **categorized** (the requirement-verification gate splits security/testing/prioritization/canon/product-assumption/native), and several are **mapped to specific code locations** that would change if revisited — canonical sources → per-engine `canonicalSource` field; lb-only → NFR-11 + `weight.ts`; warmup/assistance-excluded → `prs.ts:38,61` structural guard. Count ~20+ across requirement-verification answers + binding-assumptions + design-decisions + handoff "assumptions to confirm." Meets the level-5 "mapped to specific code locations" clause → **5** |

**Quality sum: 45.5 / 55**
**Vector — Product polish: 15.5 / 20** (Func 3.5 + UI 4 + UX 4 + Robust 4) · **Engineering rigor: 30 / 35** (Code 4.5 + SysDes 4.5 + Sec 4 + Doc 4 + Spec 5 + Scope 4.5 + Assump 5)

> **Profile vs the vibe anchor (40.5).** AI-DLC inverts vibe's signature. Vibe's drag was the planning trio (Spec 1 / Scope 3 / Assump 3 = **7/15**); AI-DLC's planning trio is **14.5/15** — a +7.5 swing that is the entire methodology story. The code-visible dims sit in the *same cluster* as vibe (Code 4.5 / SysDes 4.5 / Sec 4 / Doc 4 / UI 4 / UX 4 / Robust 4 — within inter-rater noise of vibe's identical numbers). The **one place AI-DLC scores lower is Functionality (3.5 vs vibe's 4.5)** — the depth-first cut shipped 4 programs vs 7. So the net +5 over vibe is bought entirely on the rigor axis (30/35 vs 24/35) and paid for partly in product breadth (15.5/20 vs 16.5/20). This is the cleanest separation-on-planning-dims result the rubric is designed to surface.

---

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Review (R) | Total |
|---|---|---|---|
| Critical | 0 | 0 | **0** |
| Major | 0 | 1 | **1** |
| Minor | 0 | 4 | **4** |

**LOC produced:** ~5,424 (token-log, ts/tsx excl node_modules); measured src+app+modules = 4,199; tests = 1,232.
Using 5,424: **Defects per 1KLOC: ~0.92** (5 / 5.424). *(The 325 tsc errors are NOT counted as defects — environmental dependency gap, itemized once as Minor #5.)*

Itemized:
1. **[Major · latent]** `services/workoutService.ts:104–122` (`logSet`) + `stores.ts` (0 try/catch blocks): no error handling around the `await repos.sessions.appendSet` / `repos.prs.record` async chain. A SQLite write failure after the store optimistically marks the set logged leaves the UI showing "✓" while data is unpersisted (silent state/persistence divergence). Same structural class as vibe run-002's Major #1. `code-verified: workoutService.ts:104–122, stores.ts (grep try{ = 0)`
2. **[Minor]** `domain/warmup.ts:44–51` (`generateWarmup`): for a working weight just above the bar (e.g. 50 lb), the percentage ramp steps (40/60/80%) all round below the bar or above-working and are filtered out, leaving only the empty-bar primer — a near-empty warmup. Not a crash; sparse-ramp edge. `code-verified: warmup.ts:44–51`
3. **[Minor]** `domain/recommender.ts:33`: when a program's day-range doesn't fit, it's still *recommended* (soft penalty, not exclusion) with rationale "runs N–M days/week (you picked X)" — so a 3-day user can be shown a program described as not fitting their days. Borderline UX-copy issue. `code-verified: recommender.ts:20–33`
4. **[Minor]** `domain/programs/fiveThreeOne.ts:113–125` (`progress`): TM is bumped a fixed +5/+10 every cycle regardless of AMRAP rep count — this is Wendler's *base* protocol (canon-correct per the pinned source, NOT a tracked-but-unused-failures bug), but the richer AMRAP-driven variant isn't implemented. Logged as Minor fidelity-vs-richer-variant only; the simpler interpretation is pinned + documented. `code-verified: fiveThreeOne.ts:118–123, requirements.md §6`
5. **[Minor · hygiene]** Ships **not tsc-green**: full-app `tsc --noEmit` = 325 errors, all environmental (missing `expo`/`react`/`react-native`; root `TS6053 expo/tsconfig.base not found`). Pure-layer `tsconfig.verify.json` is clean; deferral documented in `handoff-note.md §1`. Counted once as a single hygiene Minor (the other 5 cells ship clean). `verified: npx tsc --noEmit (325) vs npx tsc -p tsconfig.verify.json (exit 0)`

---

# BINARY OUTCOMES (design-verifiable per brief-no-runtime.md §9)

### Domain logic (unit-testable)
- [~] **All 7 programs prescribe + progress per pinned canon** — **PARTIAL (4 of 7).** Fully built + canon-tested: 5×5, 5×3, 5/3/1, GZCLP (`__tests__/domain/{linear,fiveThreeOne,gzclp}.test.ts`). **Scaffolded / NOT implemented:** Madcow, nSuns, Reddit-PPL (`scaffolds.ts:37–39` throw `ProgramNotImplementedError`, `available:false`). Honestly marked. `code-verified: scaffolds.ts, catalog.test.ts`
- [x] **Plate calculator (per-side, respects bar + inventory, never un-owned plate)** — `computeLoad` greedy owned-only fill, leftover/exact flags; `nearestLoadable`. `code-verified: plates.ts:52–98, plates.test.ts`
- [x] **Warm-up ramp (auto-generated, excluded from PRs/progression)** — `generateWarmup` typed `counts:false`; `detectPRs` filters non-main-working. `code-verified: warmup.ts:9–54, prs.ts:38`
- [x] **e1RM (Epley) + PR detection (weight/rep/e1rm, main working sets only)** — `epley`, `detectPRs`/`applySet`; `__tests__/domain/prs.test.ts`. `code-verified: prs.ts, e1rm.ts`
- [x] **Auto-populate (today's set from last time)** — `seedSetValue` / `sessionViewModel`; seed wired into SetRow. `code-verified: sessionViewModel.ts, today.tsx:50–56`
- [x] **Workout advances on completion (not calendar date)** — `engine.progress` advances `workoutIndex`; `WorkoutService.completeWorkout` upserts next state + closes session; in-progress resumed via `getInProgress`. `code-verified: workoutService.ts:88–143, rotation.test.ts`

### Code structure (source-reviewable)
- [x] **Onboarding flow (§4a)** — pure `onboardingMachine` state machine + 7 screens `app/onboarding/{welcome,experience,schedule,goal,program,numbers,confirm}.tsx`; `OnboardingService.seed` seeds **all** programs (FR-ON-7). `code-verified: app/onboarding/*, onboardingService.ts`
- [x] **Today's workout screen wired to domain** — `today.tsx` renders `view.workout.label` + per-set `PlateLoadView` from `buildWorkoutView`. `code-verified: today.tsx:69–101`
- [x] **Set logging (1-tap common case visible)** — single `Pressable` `set-log` in `SetRow.tsx:41`, pre-seeded weight+reps. `code-verified: SetRow.tsx:18–47`
- [x] **Rest timer (service/hook/component + intervals + haptic)** — `restTimer.ts` timestamp math; `RestTimerCoordinator` orchestrates haptic+notif+keep-awake+LiveActivity via ports; `defaultRestSeconds` per-exercise. `code-verified: restTimer.ts, restTimerCoordinator.ts:40–48`
- [x] **Backgrounded rest (local notification scheduling code, both platforms)** — `notifier.scheduleIn` on `startRest`, `cancel` on `onForeground`; NotifierPort wraps `expo-notifications` (platform-agnostic). `code-verified: restTimerCoordinator.ts:40–82`
- [x] **Quick-switch resilience (state hydration code)** — `startOrResumeSession` resumes `getInProgress` first; SQLite-persisted session + timestamp timer rehydrate. `code-verified: workoutService.ts:80–101`
- [x] **Live Activity (best-effort: stub/scaffold)** — `modules/live-activity/{RestTimerAttributes,RestTimerLiveActivity}.swift` + `plugins/withLiveActivity.js` + `LiveActivityPort` no-op shim + README. `code-verified: modules/live-activity/*, plugins/withLiveActivity.js`
- [x] **History persistence (SQLite schema + migration + repo)** — `schema.ts` sessions/sets tables; `sessionRepository`; `switchProgram` flips `activeProgramId` only (no deletes → history preserved). `code-verified: persistence/repositories/*, stores.ts:62–64`
- [x] **Progress / PR detection UI components** — `app/progress/index.tsx` (per-lift e1RM + bests via `ProgressService`); `PRCelebration.tsx`. `code-verified: app/progress/index.tsx, PRCelebration.tsx`

### Engineering hygiene (verifiable)
- [~] **`tsc --noEmit` is clean** — **PARTIAL.** Pure layers `tsconfig.verify.json` clean (exit 0); **full-app tsc = 325 errors, all environmental** (missing RN/Expo install), deferred per `handoff-note.md`. Not green as-shipped. `verified: tsc -p tsconfig.verify.json exit 0; tsc --noEmit = 325`
- [x] **`npm test` passes** — 111 tests, 17 suites, all pass. `verified: npx jest`
- [x] **Non-goals honored** — no auth/accounts/cloud/social/sharing (no user/credential surface); local-only (no push); no cardio/nutrition/multi-user; barbell-only exercise catalog (no machine/cable/dumbbell). `code-verified: grep clean across src/ app/`

### No-runtime constraint adherence
- [x] **Cell did NOT run native build commands** — `audit.md` + build instructions confirm only `tsc`/`jest`; forbidden commands not invoked. `code-verified: audit.md, build-instructions.md`
- [x] **Cell wrote full UI code** — 14 app screens/routes + 11 components + theme. `code-verified: app/*, src/components/*`
- [x] **Planning artifacts acknowledged no-runtime scope** — README callout + `requirements.md §1 deliverable bound` + `handoff-note.md`. `code-verified: README.md:7, requirements.md:19`

**Binary tally:** 18 strict pass + 2 partial (all-7-programs → 4/7; full-tsc-clean → pure-layers-only). Counting strict passes only: **18 pass**.

---

# COST AXIS

(from token-log.md)

| Metric | Value |
|---|---|
| Total tokens (Opus + Haiku aux) | ~56.5M (19.5k in + 271.5k out + 55.4M cache-read + 856.8k cache-write; Haiku aux negligible) |
| Implied API cost | **$39.94** (most expensive run-003 cell) |
| API compute time (scored) | **0 h 58 m 43 s** (3,523,248 ms) |
| Internal agent turns | 242 |
| Clarifying questions to PM | **7 at the requirements gate** (5 product → PM; 2 extension opt-ins declined) |
| Approval gates cleared | requirements review + standing "proceed" authorization through Construction |
| LOC produced (ts/tsx, excl node_modules) | ~5,424 |
| Source files | 91 |
| Sub-agents | 0 (sequential inline build) |
| Operator-touch / interventions | n/a (automated arm; gates cleared = baseline) |

## Derived ratios

| Ratio | Value | Note |
|---|---|---|
| Quality per 1K tokens | ~0.00081 | 45.5 / 56,500 — cache-dominated; compare like-for-like only |
| Quality per API hour | **~46.5** | 45.5 / 0.979 h — *below* vibe's ~59 (the ceremony tax: heaviest Inception before any code) |
| Defects per 1KLOC | **~0.92** | 5 / 5.424 |
| Methodology overhead ratio | **high** | full Inception (requirements→stories→design→plans) before any Construction code; the heaviest planning-vs-shipping ratio of the structured cells |
| Cost per binary outcome | **~$2.22** | $39.94 / 18 strict-pass binary outcomes |
| Quality per dollar | **~1.14** | 45.5 / 39.94 — *well below* vibe's ~1.99: +5 quality points cost ~2× the dollars |

---

# HEADLINE FINDING

```
Quality: 45.5 / 55  (Product 15.5/20 · Rigor 30/35)  ·  Cost: $39.94 / 0h 59m API  ·  Binary: 18/18 strict pass (+2 partial)
Defects: crit 0 · major 1 · minor 4 = 5 total  ·  ~0.92 / 1KLOC
```

AI-DLC's gated Inception→Construction produced the **highest-rigor planning trail of any cell** — a fully-traced requirements doc (FRs → NFRs → pinned canon table → 18 §9-mapped acceptance criteria), categorized binding assumptions, and a timestamped audit log — which lifts the planning trio to a near-perfect **14.5/15 (Spec 5 / Scope 4.5 / Assump 5)**, the exact inverse of vibe's 7/15 and the entire source of its +5 over the vibe anchor (45.5 vs 40.5). The code-visible dims land in the **same cluster as vibe** (Code/SysDes 4.5, Sec/Doc/UI/UX/Robust 4) with a genuine design sophistication — a platform-port abstraction that makes the timer/notification/Live-Activity flow Node-testable under the no-runtime constraint. But it bought that rigor at two real costs: **Functionality drops to 3.5** because the PM-steered depth-first cut shipped **4 of 7 programs** (3 honestly scaffolded as throwing stubs), and it is the **only cell that ships not-tsc-green** — 325 environmental errors from an incomplete offline RN/Expo install, carved around by a `tsconfig.verify.json` that passes clean and deferred in the handoff note (a finish-hygiene gap, not 325 defects). On cost it is the most expensive run-003 cell ($39.94, ~59m API) with the lowest quality-per-dollar (~1.14 vs vibe's ~1.99) — the clearest "ceremony tax buys planning-dim rigor and PM-mediated scope discipline, not raw shipped breadth" result in the suite.

---

## Failure-mode characterization

- **Where AI-DLC broke down:** engineering-hygiene finish — it left the deliverable not-tsc-green because the offline environment couldn't complete the SDK 56 install, and it (correctly, per the no-runtime brief) declined to run the install/build cycle that would have resolved it. The verify-config carve-out + handoff note are the right *engineering* response, but the brief §9 bar ("tsc clean") is literally unmet as-shipped — the one place its rigor didn't translate to a passing objective gate.
- **Categories of mistake:** (1) **scope-breadth under self-imposed depth-first** — 3 programs are stubs, a real coverage gap the gating chose deliberately; (2) **async error-discipline** — no try/catch around DB-write paths (`logSet`/stores), the same latent class seen in vibe, so it's a model/stack pattern not a methodology artifact; (3) minor canon-richness (5/3/1 fixed-bump vs AMRAP-driven) — canon-correct but the simpler pinned variant.
- **What it did surprisingly well:** the **planning trail is best-in-suite** — `requirements.md` traces every FR/NFR/AC to the brief and *pins a canonical source per program* (making "correct progression" adjudicable, exactly what the rubric's §3 detail asks for); `audit.md` is a timestamped, decision-by-decision log including an explicit **Extension Skip Log** for the two opted-out extensions. The **platform-port pattern** in the service layer is a senior move that directly serves the no-runtime constraint. And the **scaffolds are honest** — `available:false` + throwing stubs + a documented "engine interface proves the model absorbs all 7 archetypes," rather than silently dropping the missing programs or faking them.
- **Notable artifacts:** the full `aidlc-docs/inception/` tree (requirements / personas+stories / application-design / unit-of-work plans) + `construction/.../handoff-note.md`. These are genuinely useful hand-off documents, not ceremony boilerplate — the handoff names the exact files needing RN/Expo types and the exact commands to finish the build.
- **PM mediation (the automated-arm finding):** AI-DLC **gated hardest** — it would not proceed past the requirements gate without a filled answer file, asked **7 questions** (most of any cell; 5 routed to the PM persona via `pm-ask`), and the PM's **Q3=A depth-first / Q6=C archetype-first** answers *directly changed scope* — that steer is what produced the 4-deep-vs-7-shallow split. This is the clearest case in the suite of PM mediation altering the deliverable's shape.
- **Rich-brief engagement check (success-criteria.md §2):** Non-goals honored ✓ · Open assumptions engaged ✓ (accepted-with-acknowledgement at the Q5 gate, mapped to code) · Stretch stayed out ✓ (and explicitly §5.4-listed for without-refactor absorption) · Delight north-star ✓ (PR celebration, haptic moments, dark display-numeral theme — present, checklist-level) · No-runtime constraint honored ✓ · Equipment scope honored ✓ (barbell-only catalog; PPL accessories noted as barbell-substituted in the scaffold meta).
