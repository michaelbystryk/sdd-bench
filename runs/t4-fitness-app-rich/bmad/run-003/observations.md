# T4-rich (PM-quality brief) / BMAD (full lifecycle) / Run 003 / Observations

**Reviewer:** scoring agent (single-rater, autonomous) · **Scored on:** 2026-06-01 · **Scorer model:** claude-opus-4-8[1m] · **Evidence basis: CODE-BASED + PLANNING-ARTIFACT (no sim this pass)**

> **⚠️ CLEAN NEUTRAL RE-RUN.** This score is on the **clean neutral re-run** of bmad-003 (`/bmad-help` router kickoff, pure-deferral driving, 0 product interventions). The earlier **46.5/55** bmad-003 score was computed on a **CONTAMINATED build** (wrong `/bmad-agent-analyst` kickoff + operator steering, $22.38) that has been **voided + deleted**. This observations file OVERWRITES the stale one. Same scoring lens / calibration anchor as the run-002 vibe cell (40.5/55).

> **Run-003 scoring lens (AUTOMATED ARM — no-runtime).** Scores from:
> (1) build sanity: `tsc --noEmit` exit 0 (clean over the verifiable pure-layer scope — `domain/ data/ __tests__/ types/`; the `app/ui/services` layers are typechecked under `tsconfig.app.json` which needs the SDK-56 install the platform team provisions — HANDOFF.md §follow-up, tsconfig.json `comment`) · `npm test` 75 passed / 18 suites;
> (2) full source review (~30 files across domain/programs, plates, prs, restTimer, data repos+migrations, services, ui stores/components, app screens, integration test);
> (3) the **richest planning trail in the arm** — 17 `_bmad-output/` artifacts: PRD (561 lines, 34 numbered FRs) + addendum + review-rubric + reconcile-brief + decision-logs; UX DESIGN.md + EXPERIENCE.md + 2 HTML mockups; architecture.md (200 lines); epics.md (361 lines, 34 stories); readiness-report.md + readiness-audit-detail.md (adversarial 34/34-FR audit); sprint-status.yaml + HANDOFF.md.
> UI/UX dims (5+6) scored on component/screen code + UX mockups per no-runtime protocol; INDETERMINATE where a sim is needed.
> Status: **PROVISIONAL** (unblinded, single rater, code-based).

---

# QUALITY AXIS

## Dimension scores (0–5)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | **4.5** | All 7 programs ship canon-correct prescribe/advance (test-verified, 18 suites): 5×5 A/B + 3-strike deload (`fiveByFive.ts:72–95`), 5/3/1 TM wave + AMRAP + per-cycle bump + deload week (`fiveThreeOne.ts:26–131`), GZCLP T1/T2/T3 cascade (`gzclp.ts:19–34`), nSuns 9-set Scheme B/A + AMRAP→TM map (`nsuns.ts:26–60`), Madcow weekly ramp 12.5%/2.5% (`madcow.ts:22–24`), PPL 6-day. Full core loop present in source: onboarding (7 screens, help-me-pick + browse `program.tsx`), Today w/ working-weight + plate breakdown (`today.tsx:79–101`), 1-tap log, rest timer, warm-up ramp, PR takeover, history, progress, settings/inventory. Gap holding off 5: the **integrated PR path is stubbed** — `sessionStore.finish` calls `detectPRs(logged, {})` with empty prior bests (`sessionStore.ts:119`, comment "prior bests loaded by a fuller impl"), so in the wired app every session reads as first-ever (PR-vs-history doesn't function end-to-end though the domain unit is correct); rotation index is computed-then-discarded in the store (`sessionStore.ts:129` `void currentWorkoutIndex(...)`). Thoughtful interpretation throughout (seed-all-7-programs, recommendation engine, barbell-substituted BBB) → strong 4.5 |
| 2 | Correctness | (see defect block) | 0 crit · 2 major · 3 minor — 0 test failures; majors found via review (PR-vs-history wiring stub; no try/catch on store async write chain) |
| 3 | Code quality | **4.5** | Strict inward-only layering enforced (architecture §4 rule 1); discriminated-union domain types named verbatim from PRD Glossary (`MainLift`, `WorkingSet`, `Prescription`, `PlateBreakdown` — architecture rule 10); pure `verbNoun` domain fns w/ injected clock/ids (no `Date.now()`/`Math.random()` in `domain/`); float-epsilon guard in plate greedy-fill (`plates.ts:38`); no `as any`; per-module JSDoc citing `FR-N`/`addendum A.x`. `noUncheckedIndexedAccess` + `noUnusedLocals` on. Small surprises of skill: pairs-aware plate inventory (`floor(count/2)`, `plates.ts:32`), injected-adapter persistence tested against real `node:sqlite`. → strong 4.5; one notch off 5 for the store-layer wiring stubs that read as unfinished |
| 4 | System design | **4.5** | Four-layer spine `domain→data→services→ui/app`, no upward imports, repos own all SQL (architecture §3.1, rule 5); `Program` strategy interface + `ProgramRegistry` makes the app program-agnostic (`programs/index.ts`); progression state serialized opaquely as `state_json` keyed `(program_id, exercise_id)` so program-switch-preserves-history is structural (FR-33 dedicated passing test, `data/repositories/history.test.ts`); timestamp-only rest timer (no stored countdown); forward-only numbered migrations w/ `user_version` pragma + documented stretch-absorb path (architecture §3.4). Design decisions documented ADR-style in architecture.md → solid 4.5, brushing 5 via the documented-decisions clause; held off 5 because the store integration layer doesn't fully realize the clean domain design |
| 5 | UI design (source-only) | **4.5** | Dark-default tokens (`base:#0E0F13`, `ink:#F5F7FA`, `accent:#FF6B2C`, `pr:#34D27B`; `tokens.ts`); `TAP.primary=56` exceeds 44pt floor + tabular-nums display numerals at 60px; PlateBreakdownView inline with WorkingWeightBlock on Today + SetRow; full-bleed PrTakeover (92px numeral, color-flip to PR green, typed PR tags) is a designed delight moment (`PrTakeover.tsx`); 2 HTML mockups (today, pr-takeover) + DESIGN.md token system + EXPERIENCE.md behavioral spine back the component code. Edges run-002 vibe's 4 on the realized PR takeover + design-system trail; held off 5 because realized polish is read from code/mockups not a running build (INDETERMINATE on jank/transitions) → 4.5 |
| 6 | UX (source-only) | **4** | 1-tap log (single `Pressable`, no modal/keyboard happy path, `SetRow.tsx:22–26`); weight seeded from prescription, reps auto-populated; rest auto-starts on log + per-exercise interval (180/90s, `restTimer.ts:11`) + haptic (`tickLog()`); keep-awake on session start; timestamp-based timer accurate on cold-start/return; local notification scheduled at rest-start, cancelled on early return (`notifications.ts`); coaching note surfaces on AMRAP weeks. Nicks vs 5: warm-up shown as a text strip not an interactive ramp (`today.tsx:70–77`); Today shows one representative `top` weight per exercise (`today.tsx:80`) — for 5/3/1's 3 percentage sets only the first working set's weight headlines; footer/tab-bar overlap on the fixed Finish button INDETERMINATE without sim → 4 (matches run-002 vibe anchor) |
| 7 | Robustness | **4** | `computePlateBreakdown` guards target≤bar, inexact→round-down-to-loadable w/ `achieved` reported (`plates.ts:19–51`); `remainingSeconds` clamps ≥0 (`restTimer.ts:23`); `cancelRestEnd` try/catches already-fired notification (`notifications.ts:30`); permission gate before scheduling; rehydration reads session+sets+timer from SQLite on cold start (`sessionStore.loadToday`); migrations forward-only. Missing for 5: **no try/catch around the store async write chain** (`logWorkingSet`/`finish`, `sessionStore.ts:68–133`) — a SQLite failure mid-chain leaves UI "logged" while data isn't persisted (silent inconsistency — same structural gap as the vibe cell); no db-open timeout → 4 |
| 8 | Security | **4** | All SQL parameterized inside repos (no user-value interpolation; SQL never leaves `data/`, architecture rule 5); local-only offline single-user; **no remote/push/auth/cloud/fetch path anywhere** (grep clean across domain/data/services/ui/app); `package-lock.json` present (toolchain pinned); no secrets; notifications local-only by construction (FR-24, non-goal honored structurally). No standalone threat-boundary doc (the no-network design is the implicit boundary) → 4 |
| 9 | Documentation | **4.5** | HANDOFF.md: precise verified-now vs deferred split, exact verify commands, platform-team follow-up checklist (install `package.app.json`, wire runtime bits, Live Activity), open product decisions w/ reversal cost; per-module JSDoc with `FR-N`/`addendum` refs throughout; architecture.md doubles as onboarding map (project structure + requirements→structure traceability); `package.json` description self-documents the dual-manifest toolchain. Short of 5: no single top-level README (role split across HANDOFF + architecture + package.json comments) and rationale lives across PRD §8/addendum rather than consolidated ADRs → 4.5 (above run-002 vibe's 4 on depth + the readiness paper trail) |
| 10 | Spec articulation | **5** | **The richest pre-build spec in the arm.** PRD (`prds/.../prd.md`, 561 lines): 34 globally-numbered FRs each with **testable "Consequences"**, a binding Glossary (terms = type names), 5 named user journeys, cross-cutting NFRs, success metrics + counter-metrics, an Assumptions Index (A-1…A-10). The **addendum pins contested canon** (nSuns 4-day vs 5-day, PPL 3-strike vs double-failure, Madcow 12.5%/2.5%) — and those picks **correctly predicted the implementation edge cases** that turn up in `nsuns.ts`/`redditPpl.ts`/`madcow.ts`. Open Questions §8 enumerates the genuinely-ambiguous calls. Meets the level-5 clause (decisions + rationale + alternatives **and** the spec foresaw the impl edge cases) → **5** |
| 11 | Scope clarity | **4.5** | PRD §5 Non-Goals (explicit: no auth/cloud/social/push/cardio/nutrition/multi-user/non-barbell) + §6 MVP In/Out w/ reasons; §6.2 lists every Stretch item as out-with-data-model-absorb-path; architecture §6 "Forbidden-command guard" + epics "'done' = code+tests, never a running app" actively defend the no-runtime scope. Scope was **revisited under new info** — the readiness pass found 1 HIGH + 4 MEDIUM gaps and **tightened scope in-place** (FR-14 assistance AC added to 6 programs; day-count/active-program conflict rule added to Story 7.3). Just short of 5 because the revisions are audit-driven corrections rather than fully conditional declarations → 4.5 |
| 12 | Assumption surfacing | **4.5** | Assumptions Index A-1…A-10 (`prd.md:513–524`): each names the choice, the section it governs, the open-question it resolves, and what it's pinned to (e.g. A-3 "Reddit PPL = Metallicadpa v3.0, 3-strike — brief said double-failure"); architecture adds A-ARCH-1 (Zustand w/ rejected alternatives + reversal note). **Mapped to code locations** — HANDOFF + architecture state each canon assumption "lives in a single program module + its test, reversing is a one-file change" (the level-5 map-to-code clause). Count: ~11 indexed + per-FR `[ASSUMPTION]` inline tags. Short of clean 5 because the category labels (canon/tech/product) are implicit rather than tagged technical/product/user-behavior → 4.5 |

**Quality sum: 48.5 / 55**
**Vector — Product polish: 17 / 20** (Func 4.5 + UI 4.5 + UX 4 + Robust 4) · **Engineering rigor: 31.5 / 35** (Code 4.5 + SysDes 4.5 + Sec 4 + Doc 4.5 + Spec 5 + Scope 4.5 + Assump 4.5)

> Sum check: Product 4.5+4.5+4+4 = 17/20. Rigor 4.5+4.5+4+4.5+5+4.5+4.5 = 31.5/35. Total **48.5/55**.

> **Profile vs the run-002 vibe anchor (40.5/55, Product 16.5 · Rigor 24).** BMAD lands at **48.5/55 (Product 17 · Rigor 31.5)** — the product-polish sub-dims sit in the same band as vibe (Func/UI/UX/Robust 4.5/4.5/4/4 vs 4.5/4/4/4: BMAD edges UI on the realized PR takeover + design-system trail, ties elsewhere), but the **+8 total separation is entirely planning trio + adjacent rigor**: Spec **5 vs 1** (+4), Scope **4.5 vs 3** (+1.5), Assump **4.5 vs 3** (+1.5), Doc **4.5 vs 4** (+0.5), UI +0.5. Textbook BMAD signature: the full PRD→UX→architecture→epics→readiness lifecycle buys the planning ceiling vibe structurally cannot reach, at the heaviest ceremony tax in the arm (cost axis below). The engineering sub-dims do NOT separate — both arms write clean, well-typed, test-backed code, and **share the identical store-async-discipline gap** (structural, not run-specific).

---

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Review (R) | Total |
|---|---|---|---|
| Critical | 0 | 0 | **0** |
| Major | 0 | 2 | **2** |
| Minor | 0 | 3 | **3** |

**LOC produced:** ~4,322 ts/tsx (token-log, excl node_modules/_bmad).
**Defects per 1KLOC: ~1.16** (5 / 4.322)

Itemized:
1. **[Major · latent · wiring]** `ui/stores/sessionStore.ts:119` (`finish`): `detectPRs(logged, {})` is called with an **empty prior-bests map** — inline comment admits "prior bests loaded by a fuller impl; empty = first session." The `detectPRs` domain fn is correct and well-tested (`domain/prs.ts`), but in the integrated completion path every session compares against nothing, so weight/rep/e1RM PR-vs-history never actually fires for a returning lifter. The integration test (`__tests__/coreLoop.integration.test.ts:46`) also passes `{}`, so the gap is untested end-to-end. `code-verified: sessionStore.ts:119, prs.ts:18–53`
2. **[Major · latent]** `ui/stores/sessionStore.ts:68–133` (`logWorkingSet`/`finish`): no try/catch around the async SQLite write chain (`logSet` → `startRest` → `saveProgression` → `insertPr` → `completeSession`). A mid-chain DB failure leaves the store/UI showing a logged/finished state while persistence is partial (silent inconsistency). Same structural async-discipline gap as the run-002 vibe cell — confirms a cross-methodology pattern, not BMAD-specific. `code-verified: sessionStore.ts:86–91, 116–131`
3. **[Minor · latent]** `ui/stores/sessionStore.ts:129` (`finish`): `void currentWorkoutIndex(await countCompletedForProgram(...), 1)` — the rotation index is computed and immediately discarded; the store never persists/consumes a workout pointer. Completion-driven rotation (FR-15) is correct in the domain + tested (`domain/rotation.ts`), but the store path doesn't wire the result through, relying on `prescribe(state)` reflecting the advanced state. Borderline major; scored minor because `advance` does carry `workoutIndex` forward. `code-verified: sessionStore.ts:129`
4. **[Minor]** `app/(tabs)/today.tsx:80` (`top = ex.sets.find(working) ?? ex.sets[0]`): the card headline shows a single representative weight per exercise; for 5/3/1 (3 sets at 65/75/85% of TM) the first working set's weight is shown as the card's WorkingWeightBlock, not the AMRAP top set. Readable as a preview but slightly misleading for percentage programs. Same display choice as the vibe cell — possibly intentional. `code-verified: today.tsx:79–101`
5. **[Minor]** `app/(tabs)/today.tsx:70–77`: warm-up is rendered as a static text strip (`weight×reps` joined), not the interactive/skippable ramp PRD FR-27 describes; `generateWarmupRamp` is correct and tested but the screen doesn't surface it as loggable warm-up sets. `code-verified: today.tsx:70–77`

---

# BINARY OUTCOMES (design-verifiable per brief-no-runtime.md §9)

### Domain logic (unit-testable)
- [x] **All 7 programs prescribe + progress per pinned canon** — dedicated per-program test files; addendum-pinned values; 18 suites / 75 tests pass. `code-verified: domain/programs/*.test.ts`
- [x] **Plate calculator (per-side, respects bar + inventory, round-down-to-loadable)** — `computePlateBreakdown` greedy pairs-aware fill, `plates.test.ts`. `code-verified: plates.ts:14–52`
- [x] **Warm-up ramp (auto-generated, excluded from PRs/progression)** — `generateWarmupRamp` + `warmup.test.ts`; warmup `kind` filtered from PR detection (`prs.ts:28`). `code-verified: warmup.ts, prs.ts:27–29`
- [x] **e1RM (Epley + RIR) + PR detection** — `e1rm.ts` (`w*(1+(reps+rir)/30)`), `detectPRs` weight/reps/e1RM; `e1rm.test.ts`, `prs.test.ts`. *(Domain correct; integrated wiring stubbed — defect #1.)* `code-verified: e1rm.ts, prs.ts`
- [x] **Auto-populate (today's set from prescription/last)** — set seeded from prescription weight/reps in `today.tsx:48–54` + `SetRow`. `code-verified: today.tsx:48–55, SetRow.tsx`
- [x] **Workout advances on completion (not calendar date)** — `currentWorkoutIndex` + `advance` carry `workoutIndex`; `rotation.test.ts`. *(Store discard caveat — defect #3.)* `code-verified: rotation.ts, fiveByFive.ts:94`

### Code structure (source-reviewable)
- [x] **Onboarding flow (§4a)** — 7 screens welcome→experience→schedule→goal→program(help-me-pick + browse)→starting-numbers→confirm; root gate redirects on `onboarded_at`. `code-verified: app/onboarding/*, app/_layout.tsx`
- [x] **Today's workout wired to domain** — `today.tsx` renders prescription w/ WorkingWeightBlock + PlateBreakdownView from domain. `code-verified: today.tsx:79–101`
- [x] **Set logging (1-tap common case visible)** — single `Pressable` Log, no modal/keyboard. `code-verified: SetRow.tsx:22–26`
- [x] **Rest timer (service/hook/component + intervals + haptic)** — `services/timer.ts`, `useRestTimer`, `RestTimerBar`, `restTimer.ts` interval table, `tickLog()` haptic. `code-verified: restTimer.ts:11–18, sessionStore.ts:89`
- [x] **Backgrounded rest (local notification scheduling)** — `scheduleRestEnd`/`cancelRestEnd` both platforms, local-only. `code-verified: notifications.ts`
- [x] **Quick-switch resilience (state hydration)** — `loadToday` resumes in-progress session from SQLite; timestamp-derived timer. `code-verified: sessionStore.ts:45–66`
- [x] **Live Activity (best-effort: scaffold)** — `services/liveActivity.ts` interface + no-op default; `plugins/withLiveActivity.js` config-plugin scaffold. `code-verified: services/liveActivity.ts, plugins/withLiveActivity.js`
- [x] **History persistence (SQLite schema + migration + repo)** — `data/migrations/001_init.ts`, repos; program-switch-preserves-history dedicated test. `code-verified: data/migrations/001_init.ts, history.test.ts`
- [x] **Progress / PR detection UI** — `app/(tabs)/progress.tsx`, `PrTakeover.tsx`, `workout/complete.tsx`. `code-verified: progress.tsx, PrTakeover.tsx`

### Engineering hygiene (verifiable)
- [x] **`tsc --noEmit` is clean** — exit 0 over the verifiable pure-layer scope (`tsconfig.json` include = domain/data/__tests__/types; app/ui/services under `tsconfig.app.json` need the SDK-56 install, deferred to platform team per HANDOFF). `code-verified: tsc run, tsconfig.json, HANDOFF.md:32–34`
- [x] **`npm test` passes** — 75 tests / 18 suites pass (incl. real `node:sqlite` persistence + cross-layer integration). `code-verified: jest run`
- [x] **Non-goals honored** — no auth/accounts/cloud/social/sharing/push/cardio/nutrition/multi-user/non-barbell; grep for remote/fetch/firebase/auth clean; exercise catalog barbell-only w/ explicit comment. `code-verified: domain/types.ts:19, grep clean`

### No-runtime constraint adherence
- [x] **Cell did NOT run forbidden native/sim commands** — token-log + session-log confirm `tsc`/`jest`/`npm install` only; verification = tsc + npm test (architecture §6 forbidden-command guard restated across PRD/architecture/epics). `code-verified: token-log.md, architecture.md:196`
- [x] **Cell wrote full UI code (components + screens)** — 9 components + 7 onboarding + tab/workout screens + stores + hook. `code-verified: ui/*, app/*`
- [x] **Planning artifacts acknowledged no-runtime scope** — every downstream doc restates source+tests-only + forbidden list; readiness audit §6 verifies sprint-context fitness. `code-verified: prd.md:15, architecture.md:196, readiness-audit-detail.md:128–146`

---

# COST AXIS

(from token-log.md)

| Metric | Value |
|---|---|
| Total tokens (Opus primary) | ~43.9M (36.1k in + 264.9k out + 43.0M cache-read + 603.2k cache-write) |
| Aux (Haiku — BMAD elicitation/research) | 152.3k in + 5.4k out + **7 web searches** |
| Implied API cost | **$32.32** (Opus $32.07 + Haiku $0.25) |
| API compute time (scored) | **0 h 56 m 38 s** (3,398,009 ms) |
| Internal agent turns | 217 |
| Headless drive turns | 3 (incl. 1 transient socket-error resume) |
| Clarifying questions to PM | **0** (BMAD own elicitation + 7 web searches) |
| Planning artifacts | **17** (richest in the arm) |
| LOC produced (ts/tsx) | **~4,322** |
| Source files (ts/tsx) | 85 |

## Derived ratios

| Ratio | Value | Note |
|---|---|---|
| Quality per 1K tokens | ~0.0011 | 48.5 / 43,900 — cache-dominated (43.0M cache-read = a real accumulating full-lifecycle session); compare like-for-like only |
| Quality per API hour | **~51.4** | 48.5 / 0.944 h — lower than vibe run-002's ~59.0; ceremony buys planning-dim quality but costs model-hours |
| Defects per 1KLOC | **~1.16** | 5 / 4.322 — higher density than vibe run-002 (~0.74) on a leaner code base, driven by the store-wiring stubs (defects #1/#3); absolute count (5) comparable |
| Methodology overhead ratio | **highest of the arm** | full 4-gate lifecycle (PRD→UX→architecture→epics→readiness→sprint) before/around the build; planning ceremony dominates the 199-turn turn-003 |
| Cost per binary outcome | **~$1.54** | $32.32 / 21 design-verifiable outcomes |
| Quality per dollar | **~1.50** | 48.5 / 32.32 — below vibe run-002's ~1.99; the +8 quality points cost +59% dollars vs vibe |

---

# PAIRED COMPARISON (BMAD vs run-002 vibe anchor)

| Metric | vibe run-002 | **BMAD run-003 (clean)** | Δ | Interpretation |
|---|---|---|---|---|
| Quality /55 | 40.5 | **48.5** | +8.0 | Entirely planning trio + Doc/UI: Spec +4, Scope +1.5, Assump +1.5, Doc +0.5, UI +0.5; engineering sub-dims tie |
| Product polish /20 | 16.5 | **17** | +0.5 | Same band — realized product surfaces comparable (BMAD edges UI on PR takeover) |
| Engineering rigor /35 | 24 | **31.5** | +7.5 | The full lifecycle's entire advantage lives here, dominated by Spec 5-vs-1 |
| Cost | $20.36 | **$32.32** | +$11.96 (+59%) | The ceremony tax: 17 planning artifacts + 7 web searches + 217 internal turns |
| API compute | 41m 13s | **56m 38s** | +15m 25s (+37%) | Planning-heavy model-hours |
| Defects/1KLOC | ~0.74 | **~1.16** | +0.42 | Higher density (leaner LOC + store-wiring stubs); absolute count 6 vs 5 comparable |
| LOC | 8,097 | **4,322** | −3,775 | BMAD spent effort on PRD/UX/architecture/readiness; code leaner per the planning-vs-shipping split |
| PM questions | 0 | 0 | — | BMAD self-elicited (own templates + 7 web searches) rather than asking the PM |

---

# HEADLINE FINDING

```
Quality: 48.5 / 55  (Product 17/20 · Rigor 31.5/35)  ·  Cost: $32.32 / 0h 57m API  ·  Binary: 21/21 design-verifiable pass
Defects: crit 0 · major 2 · minor 3 = 5 total  ·  ~1.16 / 1KLOC
```

BMAD's full PRD→UX→architecture→epics→readiness lifecycle — 17 planning artifacts, an adversarial 34/34-FR readiness audit that found and fixed 1 HIGH + 4 MEDIUM gaps in-place, and a 561-line PRD whose pinned contested-canon picks correctly predicted the implementation edge cases — produced **the richest pre-build trail in the arm and the top planning-dim scores (Spec 5, Scope/Assump/Doc 4.5)**, lifting it +8 over the vibe anchor (40.5→48.5). But the **entire separation is the planning trio + adjacent rigor**: the realized product surfaces (Func/UI/UX/Robust) sit in the same band as vibe, and the engineering sub-dims tie — both arms write clean, well-typed, test-backed code and **share the identical store-async-discipline gap**. The ceremony costs +59% dollars and +37% model-hours for that planning ceiling. BMAD's characteristic failure mode surfaces here too: a **specification-vs-integration gap** — the domain engine is immaculate and test-verified (all 7 programs, plate calc, e1RM, PR detection), but the thin store layer wiring domain→UI carries the unfinished seams (PR-vs-history stubbed to `{}`, rotation index discarded, no async error handling), because the lifecycle's effort concentrated upstream of the glue code.

---

## Failure mode characterization

- **Where BMAD broke down:** the **integration seam**, not the domain. The PRD/architecture/epics specified everything correctly and the pure domain is test-verified, but the `sessionStore` glue carries the unfinished work: `detectPRs(logged, {})` permanently stubbed to empty prior-bests (PR-vs-history never fires in-app), `void currentWorkoutIndex(...)` (rotation pointer computed-then-dropped), and no try/catch on the async write chain. The lifecycle front-loaded effort into specification; the last-mile wiring got the least attention.
- **Categories of mistake:** (1) spec-to-integration gap — perfect domain units, stubbed wiring; (2) async discipline — silent-failure risk on the store write chain (shared with vibe, so structural); (3) UI simplification — warm-up shown as static text not interactive ramp; representative-weight display for percentage programs.
- **Surprisingly well:** the **adversarial readiness audit** (`readiness-audit-detail.md`) is a genuine independent quality gate — severity-graded findings (1 HIGH FR-14 phantom coverage, 4 MEDIUM canon/conflict gaps), each resolved in-place before sign-off, with 34/34 FR traceability + cross-artifact consistency checks. The **PRD's contested-canon foresight** (pinning nSuns 4-day, PPL 3-strike, Madcow 12.5%/2.5% *before* coding, then those exact picks appearing in the program modules) is real level-5 spec articulation. The **dual-manifest split** (`package.json` = pure-layer verification toolchain, `package.app.json` = deferred SDK-56 app stack) is a clean, honest engineering response to the no-runtime constraint — and the persistence layer tested against **real `node:sqlite`** rather than a fake is a step above the vibe cell's in-memory adapter.
- **Notable artifacts:** the PRD (561 lines, 34 FRs w/ testable consequences + Glossary-bound types + Assumptions Index) and the readiness audit are the strongest planning artifacts produced by any cell in the arm — the load-bearing evidence for Spec 5 / Scope 4.5 / Assump 4.5. architecture.md doubles as an implementation contract + onboarding map with full requirements→structure traceability.
- **Operator-tempted-but-didn't:** 0 product interventions (neutral re-run — pure-deferral driving); the 1 socket-error resume is infrastructure noise. Strong leave-it-running signal despite the heaviest ceremony.
- **Delight north-star (brief §8/§2):** the full-bleed PrTakeover (color-flip to PR green, 92px tabular numeral, typed PR tags, "Nice. Finish workout →"), `celebratePR` haptic intent, coaching notes on AMRAP weeks, and the design-system trail (2 HTML mockups + DESIGN.md) are unprompted delight from intent. Binary: **YES** — though the PR moment is undercut by the wiring stub (defect #1), so the delight is designed-but-not-fully-wired.
- **Rich-brief engagement (success-criteria.md §2):** Non-goals honored ✓ · Open assumptions engaged ✓ (Assumptions Index A-1…A-10 + addendum pins; several push back on the brief — PPL 3-strike vs "double-failure", nSuns 4-day) · Stretch stayed out ✓ (enumerated out-of-scope w/ data-model-absorb path, not built) · Delight north-star ✓ (designed) · No-runtime constraint honored ✓ · Equipment scope honored ✓ (barbell-only catalog; 5/3/1 BBB delivered as barbell volume; PPL accessories substituted).
