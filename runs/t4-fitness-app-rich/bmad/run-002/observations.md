# T4-rich (no-runtime) / bmad / Run 002 / Observations

Filled in during scoring. Uses [`harness/scoring-rubric.md`](../../../../harness/scoring-rubric.md) and [`tasks/t4-fitness-app-rich/brief-no-runtime.md`](../../../../tasks/t4-fitness-app-rich/brief-no-runtime.md) §9.

**Reviewer:** claude-sonnet-4-6 (autonomous scoring agent)
**Scored on:** 2026-06-01 · Scorer model: claude-sonnet-4-6 · Evidence basis: CODE-BASED (no sim this pass)
**Methodology revealed at:** n/a (unblinded scoring pass)

> **Run-002 scoring lens.** Source + tests only — the cell was forbidden from running the app (brief §7). UI/UX dims (5+6) scored from component/screen source (tap targets, layout density, interaction patterns visible in code) — NOT a running app. Binary outcomes are design-verifiable per success-criteria §9 no-runtime variant. Defects found are HONEST DISCOVERIES contextualized against the no-runtime constraint, not penalized as "didn't try."
>
> **The central finding (read first).** This cell is an *architecturally excellent, exhaustively-tested collection of unwired parts.* Domain logic (7 programs, plate calc, e1RM/PR, scheduling), persistence (real SQLite schema + migration + 8 repositories + mappers), the service-DI seam, and 683 passing tests are all genuinely built and green. But **the entire "Epic 4 / runtime-wiring story" was scoped as a later increment and never reached**: all five real native-service impls are `NotImplementedError` throw-stubs, no composition root opens the DB or instantiates any repository, and onboarding/logging/finish all run in volatile Zustand only. The app has **no place where the pieces connect**. The no-runtime brief partially *licenses* this (it asks the reviewer to *read* code paths, and the deferral is cleanly *declared* in the planning artifacts — see Scope), which is why the cell still scores respectably — but as a code-review PR it ships layers, not a working whole.

---

# QUALITY AXIS

## Dimension scores (0–5 per harness/scoring-rubric.md)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | 3.5 | All 7 programs prescribe+progress (canon-correct modulo GZCLP rotation bug + Madcow/PPL stand-in schedules), plate calc, e1RM, PR detect, warm-up ramp, full 8-screen onboarding, today's-workout w/ weight+plate, 1-tap log — all present, tested, **but in-memory only**: DB never opened, History/Progress hardwired empty, native rest-timer/haptics/keep-awake/notification impls are throw-stubs, session lost on kill. Large correct domain; whole integration layer unwired. (`src/services/*.ts` stubs; `app/_layout.tsx:6-11`; `history.tsx:17`; `progress.tsx:21-22`) |
| 2 | Correctness | (see defect block) | 683/683 tests pass across 105 suites; tsc --noEmit clean; defects are code-review latent (3 major / 4 minor) |
| 3 | Code quality | 4.5 | `DeepReadonly<T>` enforces the no-mutation contract at the type level on every program method (`programs/types.ts:34-40`); pure domain (ESLint-boundary-enforced, no React/clock/random); idiomatic discriminated-union results; clean naming; strict mapper isolation (`db/mappers.ts:1-6`); zero hardcoded color literals (token-driven). Minor smells: `cloneState` duplicated ×5; dead `src/app/` Expo-starter scaffold |
| 4 | System design | 4.5 | Programs-as-data + strategy interface + pluggable registry (`programs/registry.ts`); repository pattern over an injected `AppDatabase` seam that runs on better-sqlite3 (tests) AND expo-sqlite (prod); 5 Zustand stores with built `hydrate()` seams; service-DI container w/ fakes; data model encodes invariants (set-log keyed to *exercise* not program → history survives program switch, proven in tests; CHECK constraints; composite unique). Senior-level seams — docked half because **the system never assembles**: no composition root composes any of it |
| 5 | UI design (source-only) | 3.5 | Real design-token system: semantic color roles, dark+light parity w/ documented WCAG-AA fixes, 7-step spacing scale, `tabular-nums` on display/numeral so a counting timer never jitters, plate-denomination color codes (`theme/tokens.ts`); dark default (`ThemeProvider.tsx:50-59`); 72pt display numerals. Below 4: live tabs are text-only (no `tabBarIcon`, `app/(tabs)/_layout.tsx:11-16`), no real motion in the live tree (FinishSummary doc admits "no animation"), and the polished animated splash + custom tab bar are **dead code stranded in `src/app/`** |
| 6 | UX (source-only) | 3.5 | 1-tap log is a single `<Pressable>` no modal (`SetRow.tsx:146-173`); tap targets ≥44pt everywhere (steppers 56pt, rows 48pt); keyboardless plate-aware weight selector reused in onboarding + workout (no `TextInput` in app); "Not sure?" rep-estimate path present (`starting-numbers.tsx:71-131`); rest auto-start wired (`today.tsx:113-119`); accessibility is a genuine strength (unit-bearing SR labels, non-color selected cues). Below 4: plate load shown only on the exercise headline, **not on each set row** (brief's literal "every set"); the native affordances it's wired to (haptic, keep-awake, rest tick) are throw-stubs |
| 7 | Robustness | 3 | Logic-level robustness strong: timestamp-based rest math (no drift, tested), mapper JSON-parse guards degrade corrupt JSON to null/[] (`mappers.ts:42-68`), completeness-gate blocks partial-session false progression (`finishSession.ts:27-43`), negative/non-integer dayIndex guarded, calm empty states throughout, forward-only migration w/ pre-added `notes` column. Below 4: `useRestTimer` calls `timer.setInterval` with **no try/catch** around a throwing stub; **zero** DB-open/migration-failure handling (doesn't exist — unwired); a force-quit loses the entire session |
| 8 | Security | 3 | Offline, no network, no secrets, no push token (test asserts none requested); all repo queries are Drizzle parameterized builders (no SQL-injection surface); DB-level CHECK constraints + enum guard; SDK-56-pinned reputable deps + lockfile. Below 4: no in-source dep audit, no threat-boundary comment |
| 9 | Documentation | 2 | **Shipped docs only.** `README.md` is the stock `create-expo-app` template ("Welcome to your Expo app 👋") with ONE hand-authored handoff block (no-runtime gate commands, pinned stack, source map, thin deferral line); `CLAUDE.md` one line; `AGENTS.md` self-referential. Critically, the shipped README does **not** disclose that all native services are stubbed / nothing persists / history dead-ends — the excellent itemized handoff (`deferred-work.md`) was written to `_bmad-output`, NOT shipped, so a platform-team reviewer reading only the repo would badly underestimate what's inert. Also mis-states routes live under `src/app` (they live under `app/`) |
| 10 | Spec articulation | 5 | PRD (`status: final`) enumerates 38 FRs each with a testable "Consequences" block (FR-18 even pins "Squat 3×5·275·45+25+5/side"); a dedicated 12-page `program-canon-nsuns-gzclp.md` resolves the two contested programs with concrete tables and pre-warns the highest-risk impl error ("Do NOT code achieved==target ⇒ hold"); architecture documents rejected alternatives; the spec **predicted edge cases that actually bit implementation** (AMRAP-vs-auto-populate corruption, RPE/RIR must-not-alter-e1RM, nSuns target-vs-achieved, Madcow-is-not-flat-5×5 caught as CRITICAL pre-build) — real foresight |
| 11 | Scope clarity | 5 | Explicit §5 Non-Goals + §6.2 Out-of-Scope with reasons; actively defended via in-PRD `[NOTE FOR PM]` guards + counter-metrics (SM-C1/2/3 name "breadth over core loop" and "Live Activity gold-plating" as things NOT to optimize); scope **revisited on new info** (day-count recommender floor revised mid-impl from "3–6" to per-program clamp; Madcow corrected post-review). The Epic-4 native + DB-hydration deferral is a **deliberate, declared scope boundary** (PRD §11 + itemized `deferred-work.md`), not an unplanned shortfall. (Cut-*quality* is contestable — see headline — but scope *clarity/articulation* is genuinely top-tier) |
| 12 | Assumption surfacing | count: 15+ / quality: 5 | 15 indexed `[ASSUMPTION]`s (A1–A15) + 7 Open Questions + 8 `[CANON DECISION]`s; each names the choice + what-flips-if-wrong (nSuns "repointable to drive off set 9; the increment table would then key off set 9") + categorized (technical/product/`[Platform team]`/`[REQUIRED in runtime-wiring story]`) + **mapped to specific code locations** (`deferred-work.md` cites `src/domain/programs/trainingDays.ts`, `linearProgression`, `types.ts↔db/types.ts`) — the level-5 code-mapping clause |

**Quality sum:** **42.5 / 55**

**Product polish vector (dims 1+5+6+7):** 3.5 + 3.5 + 3.5 + 3 = **13.5 / 20**
**Engineering rigor vector (dims 3+4+8+9+10+11+12):** 4.5 + 4.5 + 3 + 2 + 5 + 5 + 5 = **29 / 35**

> **Profile note (why the vector matters here).** Run-002 and run-001 sit at nearly identical *rigor* totals (29/35 each) but run-002's rigor is redistributed — *deeper* planning (Spec 5, Scope 5, Assumptions 5 vs run-001's 5/4/4) bought at the cost of *thinner shipped docs* (2 vs 3.5) and a system that doesn't assemble (System design 4.5 vs 5). The whole quality drop vs run-001 lives in the **product-polish vector** (13.5 vs 16.5, −3.0): the no-runtime cell left the product unwired.

---

## Defect count (correctness, reported separately)

No tests failed (683/683 pass) and no manual exercise (no-runtime). All defects are code-review (R) latent findings.

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | — | 0 | 0 |
| Major | 0 | — | 3 | 3 |
| Minor | 0 | — | 4 | 4 |

LOC produced: **~11,909** non-test source lines (`app/` + `src/`, excl. tests/fakes/testkit); ~10,367 test lines; ~22,276 total TS.
**Defects per 1KLOC:** 7 / 11.909 ≈ **0.59 / 1KLOC** (similar *density* to run-001's 0.69, but a severity regression: run-001's were all Minor; run-002 carries 3 Major).

Itemized defects:

1. **Major (R):** **GZCLP rotation double-advances `dayIndex`.** GZCLP is the only program whose `progress()` advances the clock itself — non-skip path returns `dayIndex: state.dayIndex + 1` (`gzclp.ts:261, 348`) — *and* `nextDay()` also returns `dayIndex + 1` (`gzclp.ts:354`). `finishSession` composes them (`finishSession.ts:88 prescribe → recomputeSession(progress) → :105 nextDay`), so a completed GZCLP session nets **+2** while every other program nets +1 (their `progress` keeps `dayIndex` flat via `cloneState`). The 4-day A1/B1/A2/B2 rotation becomes 0→2→4→6 = A1, A2, A1, A2 — **B-days never run**. No test catches it (the GZCLP suite asserts `dayIndex` only on the *skip* path and on standalone `nextDay`, never the non-skip `progress`→`nextDay` composition). Manifests in-memory the moment a GZCLP session is finished.
2. **Major (R):** **Native service layer is non-functional — all five real impls throw `NotImplementedError`.** `ExpoTimer` (`timer.ts:29-35`), `ExpoHaptics` (`haptics.ts:30-46`), `ExpoNotifications` (`notifications.ts:40-56`), `ExpoKeepAwake` (`keepAwake.ts:21-31`), `IosLiveActivity` (`liveActivity.ts:53-69`) are all stubs marked "wired in Story 4.x". The view layer wires them (`today.tsx:67-91`), so at runtime the rest timer would throw on first tick (`useRestTimer` calls `timer.setInterval` with no guard), haptics/keep-awake/notification are inert. The *logic* that drives them (intervals, timestamp math, schedule orchestration) is real and tested against fakes; only the leaf SDK wrappers are unwritten. Declared deferral, but a real "claimed-wired feature throws" gap.
3. **Major (R):** **No composition root — persistence entirely disconnected; nothing durable.** No repository factory is instantiated outside tests; `drizzle()`/`openDatabaseSync`/`useMigrations` appear in zero app paths (`app/_layout.tsx:6-11` disclaims it). Onboarding-confirm hydrates only in-memory stores (`confirm.tsx:44-45`), set-logging writes only `sessionStore` (`today.tsx:102`), finish writes only `programStateStore` (`finishWorkout.ts:17`). History/Progress hardcode `[]` (`history.tsx:17`, `progress.tsx:21-22`); PR detection always runs against `priorPRs: []` (`today.tsx:138`) so the same lift re-fires as a "new PR" every finish and no PR is ever stored; the session-resilience module (`activeSession.ts`) has zero non-test callers, so a force-quit loses everything. Schema/migration/repos/mappers are all real and unit-tested against a real migrated DB — but no wire runs to them.
4. **Minor (R):** Plate breakdown is rendered only on the exercise headline (`TodayExerciseBlock.tsx:84`), not on each `SetRow` (it's in the SR a11y label only, `SetRow.tsx:67-76`) — warm-up/variant-weight sets show no visible per-side load, a partial miss of the brief's "plate load on every set."
5. **Minor (R):** Program-canon fidelity gaps (grouped): 5/3/1 TM bumps on a bare-minimum AMRAP (`fiveThreeOne.ts:204`, canonical 5/3/1 holds on minimum); Madcow (`madcow.ts:11-13`) and Reddit-PPL (`redditPpl.ts:21-24`) ship **invented barbell-centric day/lift layouts** (explicitly flagged in-code) rather than the canonical structures — progression *math* is correct, schedule *shape* is a documented stand-in.
6. **Minor (R):** PR-celebration over-fires (consequence of defect 3's `priorPRs: []`) — distinct enough to log: the gold PR moment (`FinishSummary.tsx:59-99`) is wired and correct, but with no baseline it can never reflect real history and would mark every working set a PR once persistence is wired naively.
7. **Minor (R):** Shipped-doc/housekeeping cluster: `README.md` is the stock Expo template and mis-states routes live under `src/app` (they live under `app/`); the dead `src/app/` scaffold references nonexistent `index`/`explore` routes; many shipped file headers point to a `deferred-work.md` that does not exist in the repo (it's in `_bmad-output`).

---

## Binary / design-verifiable outcomes (per brief-no-runtime §9)

Scored from source + tests. Runtime-only behaviors marked `code-verified (runtime not exercised)`.

**Domain logic (unit-testable, primary)**

| Outcome | Status | Evidence |
|---|---|---|
| All 7 programs prescribe + progress per canon | **PASS w/ caveats** | All 7 present + tested (`allPrograms.test.ts` + per-program suites). Caveats: GZCLP rotation double-advance (defect 1); Madcow/PPL schedule stand-ins; 5/3/1 TM bump eager |
| Plate calculator (per-side, respects bar+inventory, never over-prescribes) | **PASS** | `plates/plateCalculator.ts` bounded subset-sum in half-lb; ⌊count/2⌋ pairs; ties resolve to lower weight; property-tested |
| Warm-up ramp (auto, excluded from PRs/progression) | **PASS** | `warmupRamp.ts` 40/60/80%+bar, every set `isWarmup:true`; `warmupRamp.test.ts` |
| e1RM (Epley) + PR detect (weight/reps/e1RM, main working sets only) | **PASS** | `analytics/e1rm.ts:30-33`; `prDetection.ts:97-98` gates `!isWarmup && isMainLift && reps>0` on both new + baseline |
| Auto-populate today's set from last time | **PASS** | `autoPopulate.ts`; weight from prescription, AMRAP→open reps |
| Workout advances on completion (not calendar) | **PARTIAL** | Completion-gated + clock-free for 6/7 programs (`scheduling.ts`, `finishSession.ts:27-43`); **GZCLP double-advances** (defect 1) |

**Code structure (source-reviewable, primary)**

| Outcome | Status | Evidence |
|---|---|---|
| Onboarding flow (screens + routing + state machine + seeded state) | **PASS** | 8 screens welcome→experience→schedule→goal(skippable)→program fork (help-me-pick recommends 1-2 w/ rationale OR library)→starting-numbers(weight selector + "Not sure?")→confirm→seeds→`/today`; readable end-to-end |
| Today's workout screen wired to domain | **PASS** | `today.tsx` + `buildTodayViewModel` join prescription + plate calc |
| Set logging (1-tap common case visible in code) | **PASS** (in-memory) | `SetRow` single `<Pressable onLog>`; writes `sessionStore` only |
| Rest timer (service/hook/component + intervals + haptic) | **PARTIAL** | Hook/component/interval-table/haptic-invocation present + timestamp math tested; **real `ExpoTimer` is a throw-stub** |
| Backgrounded rest (notification scheduling code) | **PARTIAL** | `useRestNotification` orchestration + AppState listener present; **`ExpoNotifications.schedule` is a throw-stub** — the actual expo-notifications call was not written |
| Quick-switch resilience (state hydration paths) | **PARTIAL** | `captureActiveSession`/`restoreActiveSession` readable + tested but **zero callers**; survives in-memory bounce, NOT a process kill |
| Live Activity (best-effort: stub/scaffold acceptable) | **PASS** | `IosLiveActivity` stub + `plugins/withLiveActivity.js` config-plugin scaffold — explicitly best-effort per brief |
| History persistence (schema + migration + repo code) | **PASS** (unwired) | `db/schema.ts` 9 tables, `migrations/0000_*.sql`, 8 real repos, mappers; program-switch-preserves-history proven in tests — but no app caller |
| Progress / PR detection UI components | **PASS** (empty-wired) | `E1rmTrend`/`VolumeChart`/`PrHistoryView`/`FinishSummary` present; screens feed them `[]` |

**Engineering hygiene (verifiable, primary)**

| Outcome | Status | Evidence |
|---|---|---|
| `tsc --noEmit` clean | **PASS** | exit 0, 0 errors |
| `npm test` passes | **PASS** | 683/683 tests, 105 suites, ~11s |
| Non-goals honored | **PASS** | No auth/cloud/social/push/cardio/nutrition/multi-user; all exercises resolve to `equipment:'barbell'`; local-only confirmed |

**No-runtime constraint adherence (the key fidelity check)**

| Outcome | Status | Evidence |
|---|---|---|
| Did NOT run forbidden tooling (`expo run`/`prebuild`/`simctl`/`idb`/Metro) | **PASS** | No `ios/` or `android/` dirs (run-001 had them); no traces in committed files; the lone `expo prebuild` mention is a comment in `withLiveActivity.js` describing future behavior |
| Wrote full UI code (components + screens), not just domain | **PASS** | 8 onboarding + 5 tab screens + 20+ components |
| Planning artifacts acknowledged no-runtime scope | **PASS** | PRD §11 declares the no-runtime verification scope + platform-team handoff; README handoff block |

**Design-verifiable pass count: 18 / 23 PASS, 5 PARTIAL, 0 FAIL** (the 5 PARTIALs are the unwired/throw-stub integration items — real-but-not-composed per the no-runtime license).

---

## Rich-brief-specific checks

- [x] **Non-goals honored** — no auth/accounts/cloud/push/cardio/nutrition/multi-user; all-barbell domain verified (`seed/exercises.ts`); local-only (no push token, test-asserted)
- [x] **Open assumptions engaged** — PRD §12 explicitly addresses recommendation mapping, lb-only (A11), one-active-program-seeds-all (FR-5), warm-ups/assistance excluded from PRs (FR-22/33) — retained as decisions, not silently inherited
- [x] **Stretch stayed out** — supersets/export/custom-builder/Apple-Watch not built; data model has nullable seams to absorb them
- [x] **Delight north-star (real in code, mostly inert at runtime)** — PR celebration component, coaching notes at trigger set, collapsible warm-up, calm empty states, strong accessibility — all *designed* and readable, but haptics/rest-tick/keep-awake are throw-stubs and PR-moment can't fire (priorPRs:[]). Delight is **designed, not delivered**
- [x] **Runtime honored** — SDK 56 pinned; `npx`-only installer rule in README; no Expo Go; no-runtime constraint respected
- [x] **Equipment scope honored** — barbell+rack+bench only; non-barbell accessories substituted/dropped (`assistance.ts` substitution map; Madcow/PPL flagged all-barbell)

---

# COST AXIS

## Raw metrics

> Detailed token capture (`token-log.md`) was not backfilled at scoring time — raw input/output/cache splits are not available this pass. The implied API cost below is the operator-recorded headline figure for the cell.

| Metric | Value |
|---|---|
| Implied API cost | **~$689.47** (operator-recorded; most expensive cell in the eval) |
| API compute time | ~18 h (across ~6 BMAD multi-windows; per-window /status not backfilled) |
| Operator intervention count | (pending session-log backfill; expected ~0 unplanned per BMAD pattern) |
| LOC produced | ~11,909 non-test source + ~10,367 test = ~22,276 total TS |

## Derived ratios

| Ratio | Value |
|---|---|
| Quality per dollar | 42.5 / 689.47 = **0.062** (vs run-001 0.121 — half the quality-per-dollar) |
| Defects per 1KLOC | 7 / 11.909 = **0.59** |
| Quality per 1K tokens | _not computable — token-log not backfilled_ |
| Cost per design-verifiable PASS | $689.47 / 18 = **$38.30** |

---

# PAIRED Δ vs run-001 (this cell)

> run-001 was the **runtime variant** (it actually wired the services + ran the app, ios/android dirs present, scored 14/14 binary). run-002 is the **no-runtime variant** and deferred all integration. run-001's logbook published **46.5** though its listed dims sum to **45.5** (a 1.0 arithmetic slip in that file); Δ below uses the published 46.5 with that noted.

| Metric | run-001 (runtime) | run-002 (no-runtime) | Δ | Interpretation |
|---|---|---|---|---|
| Quality /55 | 46.5 (publ.) | **42.5** | **−4.0** | Entire drop is product-polish (16.5→13.5); rigor flat at 29 |
| Product polish /20 | 16.5 | 13.5 | −3.0 | no-runtime cell shipped an **unwired** product |
| Engineering rigor /35 | 29 | 29 | 0 | redistributed: deeper planning (10/11/12: 5/4/4→5/5/5), thinner shipped docs (9: 3.5→2), unassembled system (4: 5→4.5) |
| Implied API cost | $384.05 | ~$689.47 | **+$305 / +80%** | paid **80% more** to deliver a **less-wired** app |
| Net source LOC | ~5,785 src | ~11,909 src | +106% | extra spend went into 683 tests (vs 159) + more planning, not integration |
| Defects/1KLOC | 0.69 (all Minor) | 0.59 (3 Major) | density ↓, severity ↑ | |

---

# HEADLINE FINDING

```
Quality: 42.5 / 55  (Product 13.5/20 · Rigor 29/35)  ·  Cost: ~$689.47 / ~18h API compute  ·  Design-verifiable: 18/23 PASS, 5 PARTIAL
```

**One-line verdict:**

> Given a no-runtime brief, BMAD's full ceremony produced the eval's deepest planning (Spec/Scope/Assumptions all 5/5, a 12-page program-canon doc, edge cases predicted before they bit) and an architecturally pristine, 683-test, tsc-clean domain+persistence layer — but **deferred every integration concern to an "Epic 4" it never reached**, shipping five throw-stub native services, no composition root, and an app that runs entirely in volatile memory (History/Progress hardwired empty, nothing durable, a force-quit loses everything). The result is the eval's sharpest cost-paradox: **+80% cost ($384→$689) for −4.0 quality vs its own runtime run**, with the extra $305 buying test breadth and planning artifacts rather than a working whole — the clearest evidence yet that BMAD's ceremony tax scales with brief richness while a no-runtime license lets it optimize *artifact volume* over *vertical-slice completeness*.

---

## Failure-mode characterization

**Where BMAD broke down.** Not on rigor — on *prioritization under a no-runtime license*. The brief is deliberately over-scoped and says "the platform team handles native + verification next sprint." BMAD read that as license to defer ALL runtime wiring (native leaf impls + DB composition root + store hydration) into a single late "runtime-wiring story," then spent its (very large) budget on broad *horizontal* layers — every program, every repository, 683 tests, five planning documents — and never reached the *vertical* wiring that would make any of it cohere. Under deliberate over-scope, the highest-value cut is usually "ship a thin wired slice"; BMAD shipped wide unwired layers instead. The cut was cleanly **declared** (excellent scope clarity) but its **quality is contestable**.

**Categories of mistake.**
- *Integration-as-afterthought:* the composition root (DB open/migrate/seed → store hydrate → service inject) is the one thing never built; it's pure TS that needs no runtime to *write*, yet it was bundled with the genuinely-runtime-only native verification and deferred wholesale.
- *Honest-state disclosure landed in the wrong file:* the superb `deferred-work.md` handoff went to `_bmad-output` (a planning artifact), not into the shipped repo — so the README a platform team would actually read hides how much is inert (Documentation = 2).
- *One real latent bug slipped the 683-test net:* GZCLP's double-advance, because no test exercised the non-skip `progress`→`nextDay` composition.

**What it did surprisingly well.**
- *Spec foresight:* the PRD predicted AMRAP-vs-auto-populate corruption, RPE-must-not-alter-e1RM, and nSuns target-vs-achieved — and the canon doc pre-warned the single most likely implementation error, all of which genuinely turned up.
- *Type-level invariants:* `DeepReadonly<T>` on every program method makes the immutable-state contract un-violable at compile time — a small surprise of skill.
- *Test architecture:* repos tested against a real migrated in-memory SQLite (FK/CHECK/unique actually enforced), property-based plate/weight tests — 683 green tests is real coverage of the logic that exists.
- *Persistence design:* set-log-keyed-to-exercise (not program) makes "program switch preserves history" fall out of the data model; proven in tests even though never wired.

**Notable planning artifacts.** `prd.md` (38 FRs, testable consequences, assumptions index, counter-metrics); `program-canon-nsuns-gzclp.md` (the standout — resolves the two contested programs with tables + repointable decisions + the target-vs-achieved warning); `architecture.md` (rejected alternatives, enforced boundaries); `deferred-work.md` (an exemplary engineering handoff — undermined only by not being shipped); `.decision-log.md` (a real adversarial review→triage→fix loop: Madcow CRITICAL and the plate-invariant HIGH caught and corrected pre-build).

**Operator-tempted-but-didn't-intervene.** n/a this pass (scoring is code-based; session-log not backfilled). The cost figure alone ($689, most expensive cell) is the standing temptation the eval documents rather than acts on.
