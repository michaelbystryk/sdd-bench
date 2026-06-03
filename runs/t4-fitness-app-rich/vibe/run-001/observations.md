# T4-rich (PM-quality brief) / Vibe Claude Code / Run 001 / Observations

Filled in during scoring. Uses [`harness/scoring-rubric.md`](../../../../harness/scoring-rubric.md) and [`tasks/t4-fitness-app-rich/success-criteria.md`](../../../../tasks/t4-fitness-app-rich/success-criteria.md).

**Reviewer:** scoring agent (single-rater)
**Scored on:** 2026-05-29 · **Scorer model:** claude-sonnet-4-6
**Methodology revealed at:** n/a (unblinded — code-visible dims primarily from 2 independent Explore reader agents on absolute anchors; planning dims single-rater)
**Status:** ⚠️ **PROVISIONAL** (unblinded, single human-equivalent rater; confirm within 1 pt on a blind/2nd pass)

> Evidence basis: my build reproduction (npm/prebuild/xcodebuild green) + 2 independent code-reader
> agents (file:line anchored) covering domain/engine/db (code quality, system design, correctness,
> security) and UI/screens (UI, UX, robustness, delight) + my own reads of `plates.ts`, `e1rm.ts`,
> `haptics.ts`, `fiveThreeOne.ts`, `app.json`, `README.md` + the run-001 live sim walkthrough
> documented in `session-log.md` + **Maestro 2.6.0 full walkthrough (2026-05-29, iPhone 17 / iOS 26.5)**
> driving fresh-install onboarding → full workout → PR detection → History → Progress → Settings →
> kill+relaunch (see `build-result.md` Maestro section + screenshots in `/tmp/t4rich-vibe-001-screens/`).

---

# QUALITY AXIS

## Dimension scores (0–5 per harness/scoring-rubric.md)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | **4.5** | Whole core loop + all 7 programs + Progress/History/Settings shipped & live-verified; only-partial: 5/3/1 progression gating, LA bonus deferred. Thoughtful interpretation (recommendation rationale, barbell substitution, seeds-all-programs) → above 4, short of clean 5 |
| 2 | Correctness | (see defect block) | crit 0 · major 5 · minor 7 = 12 total — 1 new Major found via Maestro (completion overlay wrong label), 1 Major via idb (CTA/tab-bar overlap), 3 Major latent/review; 0 test failures (no jest suite in run-001; `sim.ts` harness only) |
| 3 | Code quality | **4** | Clean layering, intentional domain naming, strong TS discriminated unions; minor copy-paste across 7 program files + 1–2 `as any` casts keep it from 5 |
| 4 | System design | **4** | domain→programs→db→state→hooks; opaque per-program JSON state; warm-up injection decoupled (`plan.ts:materializePlan`); seeds-all-programs solves switch-without-resetup. No program-state versioning → not 5 |
| 5 | UI design | **4** | Dark high-contrast tokens, 52/80px tap targets, display numerals, real plate colors, PR trophy overlay. Restrained — little animation/micro-interaction beyond haptics → not 5 |
| 6 | UX | **4.5** | 1-tap log, **no keyboard anywhere in the workout loop**, weight auto-seed + auto-populate, auto-rest, keep-awake, timestamp resume. Nicks: Start-workout button sat behind tab bar (needed scroll, session-log 14:15–14:16) → 4.5 not 5 |
| 7 | Robustness | **4** | Weight/rep clamping, null guards, empty states, graceful haptics/notify fallbacks. Missing: try/catch on `logSet`/`finish`, db-open timeout, malformed-route guard → not 5 |
| 8 | Security | **4** | Parameterized queries throughout `repo.ts`; only non-exploitable `PRAGMA user_version=${const}` interpolation; local single-user offline, minimal surface; deps pinned (lockfile). No threat-boundary doc → not 5 |
| 9 | Documentation | **4** | README: setup + architecture diagram + program-source table + honest "status against brief" (Android unverified, LA deferred + why). Purposeful file-header comments. No ADRs / next-question anticipation → not 5 |
| 10 | Spec articulation | **1** | **No pre-build spec artifact** (pure Vibe). Lightweight `TaskCreate` decomposition (8 phases) + `sim.ts` validation harness are the only pre-impl structuring. Rubric default for vibe-with-no-spec is 0; +1 for the todo decomposition |
| 11 | Scope clarity | **3** | README "Status against the brief" lists in/out with reasons (LA + Android deferrals w/ rationale, barbell substitution). Post-hoc, not pre-build; Stretch §11 not enumerated as explicitly-out → 3 |
| 12 | Assumption surfacing | **2** | count: ~2 informal / quality: 2 — no `[ASSUMPTION]` tags; brief defaults silently adopted (lb, 45 bar, seeds-all, warm-ups excluded from PRs); README names choices+consequences (LA-deferral, pinned canon, barbell sub) but not as falsifiable assumptions |

**Quality sum: 39 / 55**
**Vector — Product polish: 17 / 20** (Func 4.5 + UI 4 + UX 4.5 + Robust 4) · **Engineering rigor: 22 / 35** (Code 4 + SysDes 4 + Sec 4 + Doc 4 + Spec 1 + Scope 3 + Assump 2)

> Profile is the textbook Vibe signature: **high product polish, rigor dragged down by the planning
> trio** (Spec 1 / Scope 3 / Assump 2 = 6/15). The *engineering* sub-dims (Code/SysDes/Sec/Doc =
> 16/20) are strong — what Vibe lacks is articulated intent, not implementation quality.

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | **0** |
| Major | 0 | 2 | 3 | **5** |
| Minor | 0 | 0 | 7 | **7** |

LOC produced: **~5,116 net** (src ~5,108 lines / 4,662 non-blank across 42 TS/TSX files)
**Defects per 1KLOC: ~2.34** (12 / 5.116) — low–moderate density; Maestro pass added 1 new Major

Itemized:
1. **[Major · canon]** `programs/fiveThreeOne.ts` `advance(_logged, …)` ignores logged sets — TM increments every cycle with **no AMRAP-failure reset/deload path**. (Downgraded from the reader agent's "Critical": base Wendler *does* bump TM each cycle, so prescriptions stay correct; the gap is the missing stall-reset, a real fidelity loss not a crash/data-loss.)
2. **[Major]** `hooks/useWorkout.ts` `logSet()` / `finish()` have **no try/catch** — a SQLite write failure leaves UI showing "logged" while data isn't persisted (silent inconsistency).
3. **[Major]** `hooks/useRestTimer.ts` `start()` calls `setState(p)` **before** `repo.kvSet` resolves — app killed in that window → ghost/lost timer on resume.
4. **[Minor]** `db/schema.ts` `PRAGMA user_version=${DATABASE_VERSION}` string-interpolated (non-exploitable — constant — but breaks the parameterized pattern; PRAGMA can't bind params anyway).
5. **[Minor]** `state/app.tsx` `program.seed(blMap as any, …)` loose cast silences a real type mismatch (`Record<string,…>` vs `Record<LiftId,…>`).
6. **[Minor]** `programs/progression.ts` float tolerance `weight - 1e-6` too tight for 100–500 lb plate-rounding slop (practically masked by picker-exact values).
7. **[Minor]** `domain/warmup.ts` ramp can be empty/skip for near-bar working weights (`w >= workingWeight` guard).
8. **[Minor]** `app/session/[id].tsx` `Number(id)` with no NaN/not-found guard → silent "Session · 0 lb" on a stale/bad id.
9. **[Minor]** `app.tsx` db-open await has no timeout → indefinite splash if SQLite hangs.
10. **[Minor]** `components/Sparkbars.tsx` renders empty container (no "no data yet" caption) — inconsistent with other empty states.
11. **[Major · found via Maestro this pass]** **Completion overlay shows next workout's label**, not the completed one. `workout.tsx:91` passes `plan.label` to `<CompleteOverlay>` AFTER `finish()` calls `reloadApp()`, which re-derives `plan` from the advanced program state. Result: "New PR!" screen displays "Deadlift · 5s · 0 working sets logged" after an OHP session — confusing and factually wrong. Fix: capture label/workingDone before calling `finish()`. (Observed live via Maestro; confirmed at `workout.tsx:81–91` + `useWorkout.ts:118–154`.)
12. **[Major · found via idb exercise, prior pass]** Today's primary **"Start/Resume workout" CTA overlaps the tab bar** (button frame y 755–835 vs tab-bar y 791–874) — its lower ~45px is occluded, so a center tap registers on the tab row (reproducibly landed on History, w2-01/w3-01). The #1-per-session action requires a scroll-then-tap to hit reliably. Independently reproduces run-001's session-log note ("Start-workout button sits just above the tab bar"). Borderline Major↔Minor: reachable via scroll, so the loop is not *broken*, but it's friction on the core action every session. (Primary dimension: UX — already reflected in UX 4.5; counted once here in the defect tally.)

## Binary outcomes (pass/fail per task success-criteria.md)

**14 / 14 core PASS** — full table + evidence basis in `build-result.md`.

**Maestro walkthrough (2026-05-29, iPhone 17 / iOS 26.5, fresh-install container):** Drove the complete user journey end-to-end with real `tapOn`/`assertVisible`/`takeScreenshot`. Confirmed outcomes 01 (app launched), 02 (full onboarding: welcome → experience → goal → program rec + "I'll choose" all 7 → starting numbers → review → Today), 03 (Squat/Bench/Deadlift/OHP/Row in Progress), 04 (Today with weight + plate load), 05 (single-tap log for every set), 06 (plate calculator accurate at all working weights), 07 (rest timer 0:44 auto-started), 09 (terminate + relaunch → Deadlift next workout, state intact), 10 (auto warm-ups 45×8 and 55×5 before 65 working weight), 11 (all 7 in Settings + I'll choose), 12 (3/4/5/6 day pills in Settings), 13 (History showed "Overhead Press · 5s · Today · 8 sets · 3,625 lb" immediately), 14 (Progress OHP: e1RM 99, 1 session, 3 PRs: 99.2 e1RM + rep 5@65 + heaviest 85×5). Outcome 08 remains code-verified only (notification permission requested; actual background-and-wait not tested). New defect discovered: completion overlay shows next workout label (see defect #11 above).

**idb walkthrough (prior pass, iPhone 17 Pro):** confirmed Today/Settings/Progress-screen/History-screen/persist. Workout screen NOT reached (CTA occlusion on iPhone 17 Pro — button y 755–835 overlapped tab bar y 791–874; this did NOT reproduce on iPhone 17 in Maestro pass, where button y 658–738 is above tab bar y 794). ⚠️ Two earlier drafts fabricated idb details — corrected in build-result.md.
- ⚠️ **Build-reproduction caveat (triaged):** the cell built + ran **live** on the sim in run-001 (authoritative; `compound.app` in DerivedData), but a clean-room `prebuild --clean` + `xcodebuild` failed this pass — **solely** at `PhaseScriptExecution [CP-User] Build ExpoModulesJSI xcframework` in the **third-party `Pods`/`ExpoModulesJSI` target** (not the cell's `Compound` target; no compile errors in cell source). Known Expo-SDK-56 clean-rebuild script-phase flakiness — **not a cell defect.** Outcome-01 PASS stands; scores unchanged.
- Live Activity = best-effort delight bonus, **not shipped** (deliberate, documented) → does NOT fail any outcome.
- Outcomes 08/09/13 are code-confirmed + partially live; not independently re-exercised by background-and-wait / full kill-reopen this pass (flagged).
- Rich-brief engagement (success-criteria §2): non-goals honored ✓ (no auth/cloud/social/push/cardio/multi-user); stretch stayed out ✓; runtime honored ✓ (dev build, npx, SDK 56); equipment scope honored ✓ (barbell-centric, accessories substituted); **delight north-star ✓ YES** (PR triple-haptic + trophy overlay, custom plate colors, invisible warm-up + auto-progression — unprompted from intent); open assumptions mostly **silently accepted, not explicitly engaged** (the one weak spot — see dim 12).

---

# COST AXIS

## Raw metrics (from session-log.md + token-log.md)

| Metric | Value |
|---|---|
| Total tokens | ~32.0M (197.1k in + 197.1k out + 31.3M cache-read + 310.9k cache-write; incl. 7 Haiku web searches) |
| Implied API cost | **$22.74** (Opus $22.49 + Haiku $0.25) |
| API compute time (scored) | **0 h 45 m 39 s** |
| Active wall-clock (context) | ~1 h 15 m |
| Operator-touch time | minimal — 1 "is it done?" check (session-log 14:00); no product redirect |
| Operator intervention count | **0 product interventions** (1 benign status check; cell self-resolved the sim "Open?" dialog) |
| Time to first working build | ~30 min wall (session start 13:15 → BUILD SUCCEEDED 14:00; Xcode compile ran in background while coding) |

**Phase breakdown:** n/a — Vibe is the control, no explicit planning phases.

## Derived ratios

| Ratio | Value | Note |
|---|---|---|
| Quality per 1K tokens | ~0.0012 | (39 / 32,000) — cache-read-dominated; compare like-for-like only |
| Quality per API hour | **~51.3** | 39 / 0.761 h |
| Defects per 1KLOC | **~2.34** | 12 / 5.116 (updated after Maestro pass) |
| Methodology overhead ratio | **n/a** | no planning phases (control) |
| Cost per binary outcome | **$1.62** | 22.74 / 14 |
| Quality per dollar | **1.72** | 39 / 22.74 |

---

# HEADLINE FINDING

```
Quality: 39 / 55  (Product 17/20 · Rigor 22/35)  ·  Cost: $22.74 / 0h 46m API  ·  Binary: 14/14 core pass
Defects: crit 0 · major 5 · minor 7 = 12 total  ·  ~2.34 / 1KLOC
```

**One-line verdict:** Vibe-with-a-rich-brief shipped a genuinely impressive, live-on-device barbell
app — all 7 programs, the full no-math core loop, and Progress/History/Settings — for ~$23 and 46
min of model time with zero product interventions, scoring high on product polish (17/20) while the
classic Vibe weakness shows up exactly where expected: articulated intent (Spec 1 / Scope 3 /
Assumptions 2) rather than implementation quality (Code/SysDes/Sec/Doc 16/20). Maestro walkthrough
added 1 new Major defect (completion overlay shows next workout's label post-advance) but did not
change dimension scores.

---

# PAIRED Δ vs run-002

Run-002 is a second independent replication of the same methodology (vibe) and same brief (T4-rich),
run in a fresh empty directory on the same day. Run-002 quality is **not yet scored**; cost/LOC Δ
are hard data. Quality-Δ to be computed after run-002 is scored.

| Metric | run-001 | run-002 | Δ |
|---|---|---|---|
| Implied API cost | $22.74 | $20.36 | −$2.38 (−10.5%) |
| API compute time | 45m 39s | 41m 13s | −4m 26s (−9.7%) |
| Net LOC | 5,116 | 8,097 | +2,981 (+58%) |
| Tests shipped | `sim.ts` harness only | 124 jest tests, 13 suites | — |
| Sub-agents | 1 | 0 | −1 |
| Web searches | 7 | 0 | −7 |
| Quality sum | 39 | _(pending)_ | _(pending)_ |
| Binary pass | 14/14 | _(pending)_ | _(pending)_ |

**Notable cost-axis observation:** run-002 produced 58% more LOC and a full test suite while spending
only ~$20 vs run-001's ~$23. The extra LOC includes the `services/` layer, in-memory db adapter,
zustand stores, 124 jest tests, ESLint flat config, `docs/ASSUMPTIONS.md` + `HANDOFF.md`, and a Live
Activity scaffold — suggesting run-002 traded sim-verification time for upfront testing and docs.

**For the T4-vague vs T4-rich headline:** Vibe T4-vague = 29; **Vibe T4-rich run-001 = 39 (Δ +10)**
— the largest expected Quality-Δ of any methodology, confirming *brief quality substitutes for
methodology structure* for low-structure cells.

---

## Failure mode characterization

- **Where Vibe broke down:** the planning trio (Spec/Scope/Assumptions) — no pre-build spec, brief's
  falsifiable open-assumptions §10 silently adopted rather than explicitly engaged/pushed-back-on.
  This is *the* reproducible Vibe gap, unchanged by a better brief.
- **Categories of mistake:** async discipline lapses (no try/catch around DB writes; setState-before-
  persist race; plan.label read after state advance in completion overlay), one canon-fidelity miss
  (5/3/1 stall-reset). No architectural or crash defects.
- **Surprisingly well:** end-to-end live verification — the agent built, installed, launched, and
  *drove the app itself* on the sim (synthetic taps + screenshots), catching its own UI offsets;
  shipped a `sim.ts` harness validating all 7 programs; delivered unprompted delight (PR triple-haptic
  + trophy) purely from the brief's "delight is the north star" clue.
- **Notable artifacts:** README is genuinely good (architecture diagram + pinned-canon source table +
  honest status-vs-brief). No PRD/ADR — the `TaskCreate` todo list is the closest thing to a plan.
- **Operator-tempted-but-didn't-intervene:** the dev-client "Open?" dialog + repeated tap-offset
  misses during the walkthrough were self-resolved by the agent (installed `cliclick`, recalibrated);
  the operator's lone touch was a passive "is it done?" — strong leave-it-running signal.
