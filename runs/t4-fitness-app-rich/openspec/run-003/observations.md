# T4-rich (PM-quality brief) / OpenSpec / Run 003 / Observations (AUTOMATED ARM)

**Reviewer:** scoring agent (single-rater, autonomous)
**Scored on:** 2026-05-30 · **Scorer model:** claude-opus-4-8 · **Evidence basis: CODE-BASED (no sim — automated arm)**

> **Run-003 scoring lens.** AUTOMATED ARM — headless OpenSpec (propose→apply→archive) replication.
> No simulator used (same no-runtime lens run-002 vibe used). All scores from:
> (1) build sanity: `tsc --noEmit` exit 0 (clean) · `npm test` 98/98 pass / 16 suites;
> (2) full source review (~30 files across domain/data/services/state/components/screens);
> (3) **pre-build planning-artifact review** (proposal.md + design.md + 13 capability specs + 63-task plan in `openspec/changes/archive/`), README.md, HANDOFF.md.
> UI/UX dims (5+6) scored on component/screen code per no-runtime protocol.
> Status: **PROVISIONAL** (unblinded, single rater, code-based, automated-arm).
> Calibration anchor: run-002 vibe (40.5/55, code-only, no-sim) — same lens.

---

# QUALITY AXIS

## Dimension scores (0–5)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | **4.5** | All 7 programs ship with canonical prescription + progression (98 tests, 16 suites; per-program canon pinned with source URLs); full core loop (onboarding → today → workout → log → rest → finish → PRs → progress/history); flexible 3–6 day scheduling via `supportedDays`; barbell-substituted assistance. Thoughtful interpretation throughout (seed-all-programs at onboarding, subset-sum plate math, AMRAP-driven nSuns/GZCLP). Gaps keeping it off a clean 5: **5/3/1 `progress` ignores the session entirely** (`fivethreeone.ts:124` — `_session` unused; wave advances on a fixed schedule with no AMRAP-driven TM check or stall/deload), and the "not sure" onboarding path is a flat conservative default (`numbers.tsx:13`) rather than the brief's "~X for 5 reps" estimation. `code-verified: registry.test.ts, fivethreeone.ts:124–141` |
| 2 | Correctness | (see defect block) | 0 crit · 2 major · 4 minor — 0 test failures; majors found via code review (no error handling on any async store/controller mutation → silent DB-failure risk; 5/3/1 missing AMRAP/deload path). |
| 3 | Code quality | **4.5** | Strict layering domain→data→services→state→components, enforced "no-RN-imports in `src/domain/`" rule (documented + real); discriminated-union progression state per program family (`states.ts`); intentional naming; dense file-level JSDoc with canon citations + `§N` brief refs. **Small surprise of skill:** `computePlates` is a bounded subset-sum over reachable loads in integer tenths-of-a-pound (`plateMath.ts:64–124`) — not a naive greedy fill that would miss the nearest load with non-canonical plate sets; documented tie-break-to-lower. Narrow `SqlDatabase` interface decouples domain/data tests from the device. → strong 4 pushing into 5 on the plate-math + port abstraction |
| 4 | System design | **4.5** | domain (pure) → data (`SqlDatabase` port + migrations/repos) → services (timer math pure, native effects behind `RestTimerService` seam) → state (testable controllers + thin zustand wrappers) → screens is clean and enforced; `Program` interface + registry localizes each contested canon to one module; rotation lives in the program's progression cursor (completion-driven, no calendar coupling); history keyed by `exercise_id` so program-switch preserves+unifies history (`migrations.ts:72`); stretch fields absorbed additively (nullable `sets.note`, `sessions.bodyweight_lb`). Design decisions documented as a real pre-build design.md (D1–D10 with rationale + alternatives). → solid 4, the documented ADR-style decisions + enforced purity boundary elevate toward 5 |
| 5 | UI design (source-only) | **4** | Dark high-contrast tokens (`theme.ts`: bg `#0B0B0F`, text `#F5F7FA`); `TAP_TARGET=56`/`BIG_TAP_TARGET=72` exceed the 44pt floor; `display:64` numerals for working weight; plate load shown inline on Today (`PlateBadge`) and in the selector; PR celebration component with `prGold #FFC400`; coaching notes surfaced with emoji affordance; tabular-nums on rep values. Missing for a 5: no considered workout-specific empty states beyond generic `<Screen title>` loading, and the warm-up strip defaults open then collapses (minor density choice). INDETERMINATE (no sim) on transitions/jank. → 4 |
| 6 | UX (source-only) | **4** | 1-tap log (single `Log` Pressable seeded from prescription, reps pre-filled to `targetReps`; `SetRow.tsx:54–61`); rest auto-starts on log with per-exercise interval table (`restTimer.ts:10`, heavy 180/compound 150/accessory 90); haptic on log; keep-awake activated for the whole workout (`workout.tsx:43–48`); timestamp-based timer accurate on return; local notification scheduled from `startedAt+duration`; **Today shows the TOP working set weight** (`index.tsx:66`, `working[working.length-1]`) — better than run-002 vibe which showed the lightest set; resume restores exact `activeExerciseIndex/activeSetIndex`. Nicks: RPE chips only render on the active row; warm-up is display-only, not loggable. → 4 |
| 7 | Robustness | **4** | `computePlates` handles below-bar targets (empty bar), inexact loads (nearest-reachable), inventory exhaustion (never exceeds owned pairs); migrations idempotent + versioned; `restRemainingSec` clamps at 0; warm-up ramp guards; repository getters throw explicit "not initialised (run seed)" errors. **Ceiling-capping gap:** **zero try/catch and zero ErrorBoundary anywhere in `src/`+`app/`** (grep-verified) — every async mutation (`logSet`/`finish`/`hydrate`/`switchProgram`) is fire-and-forget at the store edge; a SQLite write failure surfaces as an unhandled rejection with no UI recovery and can leave state inconsistent (set shows logged, not persisted). Brief-stated bad inputs handled; failure-path resilience is not. → 4 |
| 8 | Security | **4** | All SQL parameterized via `?` placeholders + bound arrays throughout `repositories.ts`/`migrations.ts`/`seed.ts` (no user-string interpolation; `schema_meta` version bound, not templated); local-only offline single-user per brief §6 (no auth/cloud/push/multi-user tables); notifications are `TIME_INTERVAL` local triggers, nothing leaves the device (`expoRestTimerService.ts:36`); `package-lock.json` present (deps pinned); no secrets in source. No threat-boundary doc; no dep-audit artifact. Clean SQL discipline, no defense-in-depth narrative → 4 |
| 9 | Documentation | **4** | README: value framing + SDK-56 stack + no-runtime callout + commands + architecture tree + 7-program table. HANDOFF.md: pinned-source audit table (per-program canon + variant notes), 5-step platform-team follow-up, assumptions-made list, "known thin spots" honest disclosure. `src/domain/README.md` documents the purity rule. File-level JSDoc on every module with brief `§N` refs + canon citations. Onboarding-for-a-contributor is implicit (commands + arch tree) but no explicit 10-min walkthrough; decisions live in the pre-build design.md (D1–D10) rather than standalone ADR files → 4 |
| 10 | Spec articulation | **4** | **Real pre-build artifacts** (propose phase, 0 PM questions): `proposal.md` (Why / What Changes / 13 named capabilities / Impact), `design.md` (Context + Goals/Non-Goals + **D1–D10 decisions each with rationale AND explicit alternative-considered-and-rejected** + Risks/Trade-offs + Migration Plan + Open Questions), and **13 capability specs in EARS-style `SHALL` requirements with `WHEN/THEN` scenarios** (e.g. `strength-programs/spec.md` pins per-program canon as testable scenarios; `plate-calculator/spec.md` encodes "never suggests unowned plates" as a scenario). A different engineer could build to this and produce something very similar. Held off 5: the Open Questions are flagged but mostly self-answered inline rather than the spec *predicting* impl edge cases that later surfaced (the 5/3/1 progression gap was NOT caught by the spec despite the spec asserting AMRAP-driven progression). → strong 4 |
| 11 | Scope clarity | **4** | In/out scope explicit pre-build: design.md Non-Goals enumerates accounts/cloud/sync/social/push/cardio/nutrition/multi-user/non-barbell AND names stretch items (body-weight/notes/supersets/export/custom-builder) as "schema must absorb, not build"; proposal scopes the 13 capabilities; Live Activity explicitly scoped as scaffold-only best-effort. Scope was **actively reasoned** under the "intentionally larger than one sprint" constraint (design.md Risks: "prioritize the core loop … UI breadth can be thinner, gaps noted in handoff") and the cut surface is disclosed in HANDOFF "known thin spots." Held off 5: cuts are declared+defended but not *revisited when new info surfaced* (no conditional re-scoping during build). → strong 4 |
| 12 | Assumption surfacing | **4** | Count: ~13 explicit assumption/decision entries across design.md (D1–D10 decisions + 4 Open Questions), HANDOFF "Assumptions made (push back if wrong)" (5), and brief §10 items engaged inline (lb-only default, one-active-program-seeds-all, warm-ups/assistance excluded from PRs — enforced structurally by not logging warm-ups, TM≈90% of Epley-1RM derivation). **Quality:** each names a choice + what depends on it (D2: "alternative one giant switch rejected — unreviewable"; nSuns/GZCLP "contested → variant pinned, confirm if product wants another"); assumptions are loosely **categorized** (decisions vs open-questions vs assumptions vs known-thin-spots). Held off 5: not mapped to specific code file:line that would change if revisited (HANDOFF gestures at modules but not precise locations), and the self-resolved 5/3/1 progression assumption was wrong yet untagged as a risk. → 4 |

**Quality sum: 49.0 / 55**
**Vector — Product polish: 16.5 / 20** (Func 4.5 + UI 4 + UX 4 + Robust 4) · **Engineering rigor: 32.5 / 35** (Code 4.5 + SysDes 4.5 + Sec 4 + Doc 4 + Spec 4 + Scope 4 + Assump 4)

> Profile vs the run-002 vibe anchor (40.5/55; Product 16.5/20, Rigor 24/35): **identical product-polish vector (16.5/20)** — same code-only ceiling on Func/UI/UX/Robust, same structural async-discipline robustness cap — but a **+8.5 rigor delta (32.5 vs 24)** driven by the **planning trio**: Spec 4 / Scope 4 / Assump 4 = 12/15 vs vibe's 1/3/3 = 7/15 (a +5 planning-trio gain), with Code/SysDes/Sec/Doc flat-equal to vibe (4.5/4.5/4/4). That +5 planning-trio gain is the OpenSpec methodology tell: a genuine pre-build proposal + design (D1–D10 with alternatives) + 13 EARS capability specs is exactly what dims 10–12 reward, and vibe (post-hoc ASSUMPTIONS.md) structurally cannot reach. Net: **structure buys the planning dims, not the product polish.**

---

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Review (R) | Total |
|---|---|---|---|
| Critical | 0 | 0 | **0** |
| Major | 0 | 2 | **2** |
| Minor | 0 | 4 | **4** |

**LOC produced:** ~5,690 (token-log, ts/tsx excl node_modules) / 5,687 measured (`src`+`app`).
Using 5,690: **Defects per 1KLOC: ~1.05** (6 / 5.690)

Itemized:
1. **[Major · latent]** Async error discipline — **no try/catch on any store/controller mutation**. `stores.ts:51–67` (`logSet`/`finish`), `controllers.ts:112–151` (`logSet`/`finish`/`complete`): a SQLite write failure after the in-memory `set({session})` leaves the UI showing "logged" while data is not persisted, or rejects the promise unhandled with no recovery path. Same root pattern as run-002 vibe. `code-verified: stores.ts:51–67, controllers.ts:112–151` (grep: 0 `try {`, 0 ErrorBoundary in src+app)
2. **[Major · canon]** `fivethreeone.ts:124–141` (`progress`): the parameter is `_session` (unused) — 5/3/1 progression advances the wave/cursor on a **fixed schedule regardless of performance**. No AMRAP-rep read, no TM adjustment from the top-set result, no stall/deload path. The capability spec (`strength-programs/spec.md`) and the module header both assert AMRAP-driven progression; the impl does not deliver it. (Contrast: `nsuns.ts:117–125` and `gzclp.ts` DO read the session and apply canon-correct AMRAP/stage logic — so this is a 5/3/1-specific fidelity gap, not a framework gap.) `code-verified: fivethreeone.ts:124–141, fivethreeone.test.ts:11 (emptySession sets:[])`
3. **[Minor]** `numbers.tsx:13,31` — the "Not sure?" path fills a flat `CONSERVATIVE` default rather than the brief §4a "I can do ~X for 5 reps" light estimation path. Functional but a simplification of the specified flow. `code-verified: numbers.tsx:13–33`
4. **[Minor]** `stores.ts:55–67` — `switchProgram` → `hydrate` and `finish()` re-instantiate `new WorkoutController(repos)` per call and call `loadHome()` twice in `finish` — harmless redundancy, minor inefficiency on a hot path. `code-verified: stores.ts:59–67`
5. **[Minor · canon]** `restTimer.ts:10–18` interval table is a 3-bucket category default; the brief's "longer for heavy compounds, shorter for accessories" is honored, but there is no per-exercise override surface (Settings doesn't expose interval editing) — acceptable v1 cut, slightly under the "per-exercise intervals" wording. `code-verified: restTimer.ts:10–18`
6. **[Minor]** HANDOFF "known thin spots" discloses nSuns uses a 4-lift rotation cycled for 4–6 day frequency rather than 6 fully distinct days — a documented canon-coverage simplification (PPL is the first-class 6-day program). Disclosed, not hidden, hence minor. `code-verified: nsuns.ts:44–49, HANDOFF.md:77–79`

---

# BINARY OUTCOMES (design-verifiable per brief-no-runtime.md §9)

### Domain logic (unit-testable)
- [x] **All 7 programs prescribe + progress per pinned canon** — `registry.test.ts` + per-program suites (`linear`/`fivethreeone`/`madcow`/`gzclp`/`nsuns`/`ppl`.test.ts); each module pins a `source` URL + variant notes. **Caveat:** 5/3/1 progression is wave-only (defect #2) — prescription correct, progression not performance-driven. `code-verified: 16 suites pass`
- [x] **Plate calculator (per-side, respects bar + inventory)** — `computePlates` bounded subset-sum, never exceeds owned pairs; `plateMath.test.ts` covers exact/nearest/custom-bar/inventory-limit. `code-verified: plateMath.ts:90–132`
- [x] **Warm-up ramp (auto-generated, excluded from PRs/progression)** — `generateWarmupRamp`; warm-ups are display-only (never logged) → structurally excluded from PR/e1RM/progression. `code-verified: warmupRamp.ts, workout.tsx:62`
- [x] **e1RM (Epley) + PR detection** — `e1rm.ts` + `prDetection.ts` (weight/reps/e1RM, main working sets only); `metrics.test.ts`. `code-verified: metrics.test.ts`
- [x] **Auto-populate (today's set from last time)** — set seeded from prescription (`SetRow` reps pre-filled to `targetReps`; weight from `prescribed.weightLb`). `code-verified: SetRow.tsx:25, workout.tsx:69–76`
- [x] **Workout advances on completion (not calendar)** — rotation cursor in progression state; `finishSession`/`progress` advance only on explicit completion; `engine.test.ts`. `code-verified: engine.ts:79–112`

### Code structure (source-reviewable)
- [x] **Onboarding flow (§4a)** — 7 routes: `welcome → experience → schedule → goal → program → numbers → confirm`; seeds ALL programs at confirm (`controllers.ts:50–71`). `code-verified: app/onboarding/*`
- [x] **Today's workout screen wired to domain** — `index.tsx` renders top-working-set weight + `PlateBadge` per lift. `code-verified: index.tsx:42–82`
- [x] **Set logging (1-tap common case)** — single `Log` Pressable, seeded; `SetRow.tsx:54–61`. `code-verified`
- [x] **Rest timer (service/hook/component + intervals + haptic)** — pure `restRemainingSec` math + `RestTimerService` seam + `expoRestTimerService` (haptic/notification/keep-awake) + `RestTimerBar` UI; `restTimer.test.ts`. `code-verified`
- [x] **Backgrounded rest (local notification scheduling)** — `scheduleRestEndNotification` computes fire time from `startedAt+duration`, `TIME_INTERVAL` local trigger, iOS+Android; cancel on stop. `code-verified: expoRestTimerService.ts:27–41`
- [x] **Quick-switch resilience (state hydration)** — every mutation persists `in_progress_json`; `begin()` resumes existing in-progress; cold-start path in `controllers.test.ts`. `code-verified: controllers.ts:100–116`
- [x] **Live Activity (best-effort: stub/scaffold)** — `services/liveActivity.ts` iOS-guarded no-op seam + `plugins/withRestTimerLiveActivity.js` + `ios/RestTimerWidget/*.swift`. `code-verified`
- [x] **History persistence (SQLite schema + migration + repo)** — `migrations.ts` v1 (sessions/sets/prs, exercise_id-keyed); `switchProgram` only flips active id, no deletes. `code-verified: migrations.ts:63–98, controllers.ts:154–156`
- [x] **Progress / PR detection UI** — `progress.tsx` + `MiniBars` (dependency-free charts) + `history.tsx` + `PRCelebration.tsx`. `code-verified`

### Engineering hygiene (verifiable)
- [x] **`tsc --noEmit` clean** — exit 0, no output. `code-verified: tsc run`
- [x] **`npm test` passes** — 98 tests, 16 suites, all pass (2.7s). `code-verified: jest run`
- [x] **Non-goals honored** — no auth/accounts/cloud/social/sharing (no user/account tables); no push (local `TIME_INTERVAL` only); no cardio/nutrition/multi-user; catalog barbell-only with a test asserting it. `code-verified: migrations.ts, catalog.test.ts:4`

### No-runtime constraint adherence
- [x] **Cell did NOT run native build commands** — forbidden commands (`expo run:*`/`prebuild`/`simctl`/`xcodebuild`/`expo start`) appear ONLY in HANDOFF as platform-team follow-up; tasks.md verification = `tsc --noEmit` + `npm test` only. `code-verified: HANDOFF.md:49, tasks.md:110–111`
- [x] **Cell wrote full UI code** — 15 screens/route files + 9 components + 3 stores + controllers. `code-verified: app/*, src/components/*, src/state/*`
- [x] **Planning artifacts acknowledged no-runtime scope** — proposal Impact + design.md Context both state "source + tests only, no native build/Metro/sim"; README callout; HANDOFF hands runtime to platform team. `code-verified: proposal.md:5, design.md:3`

### Rich-brief engagement (success-criteria.md §2)
- [x] **Non-goals honored** ✓ · [x] **Open assumptions engaged** ✓ (design.md D-series + Open Questions + HANDOFF assumptions; lb-only / seed-all / PR-exclusion all engaged) · [x] **Stretch stayed out** ✓ (named as schema-absorb-only, not built) · [x] **Delight north-star** ✓ (see failure-mode) · [x] **Runtime honored** ✓ (npx + SDK 56, no Expo Go) · [x] **Equipment scope honored** ✓ (barbell-only catalog + test; GZCLP/nSuns accessories substituted to rows/curls/extensions/front-squat).

---

# COST AXIS

(from token-log.md — automated arm, `claude -p` JSON, NOT `/status`)

| Metric | Value |
|---|---|
| Total tokens (Opus) | ~24.32M (19.2k in + 160.8k out + 23.81M cache-read + 334.7k cache-write) |
| Implied API cost | **$18.12** (Opus $18.11 + Haiku aux $0.006) — cheapest run-003 cell |
| API compute time (scored) | **0 h 33 m 30 s** (2,010,184 ms) |
| Internal agent turns | 132 (propose 28 / apply 99 / archive 5) |
| Clarifying questions to PM | **0** — propose self-resolved with documented assumptions |
| Operator-touch / interventions | n/a (automated arm) |
| LOC produced (ts/tsx) | ~5,690 · 77 files |
| Tasks completed | 63 / 63 · 13 capability specs archived |

## Derived ratios

| Ratio | Value | Note |
|---|---|---|
| Quality per 1K tokens | ~0.00202 | 49.0 / 24,323 — cache-dominated; compare like-for-like only |
| Quality per API hour | **~87.8** | 49.0 / 0.558 h |
| Defects per 1KLOC | **~1.05** | 6 / 5.690 |
| Methodology overhead ratio | **~0.19** | (propose+archive $2.84) / (apply $15.27) — lowest ceremony of the structured cells |
| Cost per binary outcome | **~$0.79** | $18.12 / 23 design-verifiable outcomes passed |
| Quality per dollar | **~2.70** | 49.0 / 18.12 |

---

# HEADLINE FINDING

```
Quality: 49.0 / 55  (Product 16.5/20 · Rigor 32.5/35)  ·  Cost: $18.12 / 0h 33m API  ·  Binary: 23/23 design-verifiable pass
Defects: crit 0 · major 2 · minor 4 = 6 total  ·  ~1.05 / 1KLOC
```

OpenSpec run-003 (automated arm) self-resolved at propose with **0 PM questions**, produced a genuine pre-build baseline (proposal + design.md D1–D10-with-alternatives + 13 EARS-style `SHALL`/`WHEN-THEN` capability specs + 63-task plan), then shipped ~5,690 LOC / 77 files / 98 green tests / clean tsc as the **cheapest and fastest structured cell ($18.12, 33.5 min, 0.19 ceremony ratio)**. Against the run-002 vibe anchor (40.5/55) it lands **49.0/55 with an identical product-polish vector (16.5/20)** and a **+8.5 rigor delta** that is almost entirely the planning trio (Spec/Scope/Assump 4/4/4 = 12/15 vs vibe's 7/15) — the textbook OpenSpec signal: **structure buys the planning dimensions, not the product polish, and at the lowest ceremony tax of the structured methodologies.** The two majors are the same structural patterns the no-runtime lens surfaces everywhere — zero async-error handling (silent DB-failure risk) — plus one canon gap (5/3/1 progression is wave-only and ignores the AMRAP result, despite the spec asserting AMRAP-driven progression: a case where the spec was *correct* but the build under-delivered against it).

---

## Failure-mode characterization

- **Where OpenSpec broke down:** the spec→impl fidelity seam on one program. The `strength-programs` capability spec correctly specifies 5/3/1 AMRAP-driven TM adjustment, but `fivethreeone.ts` implements wave advancement only (`_session` unused) — the spec didn't prevent the gap, and the per-program test was written against the under-spec'd behavior (`emptySession` with `sets:[]`), so green tests masked it. OpenSpec's spec quality didn't propagate to uniform canon fidelity across all 7 programs (nSuns + GZCLP DID get it right).
- **Categories of mistake:** (1) async discipline — same zero-try/catch / no-ErrorBoundary pattern as vibe, methodology-independent; (2) one-program canon under-delivery against its own spec; (3) minor flow simplifications (flat "not sure" default; no per-exercise interval editing) — all reasonable v1 cuts but below the literal brief.
- **What it did surprisingly well:** the **pre-build design.md is the standout artifact** — 10 numbered decisions each with rationale AND an explicit rejected-alternative, plus Risks/Trade-offs and Open Questions, written *before* code. The **plate-math subset-sum** (integer tenths, reachable-load enumeration, documented tie-break) is genuine engineering skill inferred from "never suggest a plate you don't own." The **enforced `src/domain` purity boundary** (documented no-RN-imports rule) is what makes 98 pure-Node tests possible with no device — directly serving the no-runtime brief. And it did all this at the **lowest cost/ceremony of any structured cell**.
- **Notable artifacts:** 13 capability specs in EARS `SHALL` + `WHEN/THEN` scenario form (genuinely buildable-to); HANDOFF.md with a per-program pinned-source audit table + honest "known thin spots" disclosure; `src/domain/README.md` documenting the purity contract. These are the methodology tell that lifts dims 10–12 a full +5 over vibe.
- **Operator-tempted-but-didn't:** n/a (automated arm — 0 interventions by construction).
- **Delight north-star (brief §8, §2):** PRCelebration component (`prGold #FFC400`); coaching notes surfaced inline with affordance ("💡 top set is AMRAP — leave 1 in the tank"); Today shows the *top* working set (the number the lifter cares about) not the lightest; `BIG_TAP_TARGET=72` for the primary log action; tabular-nums so weights don't jitter. Unprompted from the brief's "delight" language. Binary: **YES** (modest — no Live Activity wiring, no haptic-celebration flourish beyond the success haptic; delight is competent, not exceptional).
