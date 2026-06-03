# T4-rich (no-runtime) / ai-dlc / Run 002 / Observations

**Reviewer:** claude-sonnet-4-6 (PROVISIONAL — unblinded, single-rater, code-based)
**Scored on:** 2026-05-29
**Scorer model:** claude-sonnet-4-6
**Evidence basis:** CODE-BASED (no sim this pass — parallel scoring agent)

> **Run-002 scoring lens.** UI/UX dims (5+6) scored on *code* (anti-mis-tap targets, layout density, interaction patterns visible in component code) — NOT on running app since no runtime. The blind ≥2-rater protocol applies; bundles strip planning artifacts + keep `app/` + `src/` + `assets/`.

---

# QUALITY AXIS

## Dimension scores (0–5)

### 1. Functionality — 4.0

All required behavior is present and works on the happy path; edge cases from the brief are addressed. The cell shipped:
- All 7 programs with correct canonical progression (5×5/5×3 linear deload on 3 consecutive failures at 90%; 5/3/1 TM-wave + AMRAP + BBB + TM bump per cycle; Madcow weekly ramp Mon/Wed/Fri; GZCLP T1/T2/T3 cascade; nSuns 9-set + AMRAP-driven TM delta; Reddit PPL 6-day linear). code-verified: `src/domain/programs/*.ts`
- Plate calculator with configurable inventory + bar weight; warm-up ramp generator; e1RM (Epley); PR detection on working sets only; auto-populate from last time; completion-based rotation.
- Onboarding 7-step flow; today's workout screen with working weight + per-side plate load; 1-tap set log; rest timer (timestamp-based); backgrounded notification scheduling; history/progress screens; program switch preserves history.
- Coaching notes wired to program/set templates (5/3/1 AMRAP note: "Top set is AMRAP — leave 1 in the tank"; nSuns: "AMRAP top set — reps here set your next TM"; GZCLP: "T1 last set is AMRAP").

Withheld from 4.5/5: Progress screen lacks volume/tonnage chart UI (text placeholders, no chart lib — the `tonnage()` method exists in `ProgressService` but the UI doesn't wire it). Settings screen shows plate inventory read-only ("editing UI is wired to SettingsService.updateInventory" — deferred). These are honest no-runtime simplifications, not omissions, but they leave the brief's §5E charts and §4c plate-inventory edit partially incomplete in the UI layer. The spirit-of-brief is engaged thoroughly (recommendation mapping, "delight north star" clues, mid-workout affordances). Meets level-4 anchor: "All required behavior works including edge cases mentioned in the brief. Spirit-of-brief addressed."

### 3. Code quality — 4.5

Readable, intentional naming, full TypeScript types, idiomatic for a pure-domain / service / gateway architecture. Every function is short, single-purpose, and documented with JSDoc referencing its FR-* requirement. The satisfies operator used to enforce state shape at construction time (e.g., `satisfies LinearState`); generic greedy-match helper used across programs without copy-paste; Clock interface injected for testability; barrel exports per subdomain. Small surprises of skill: `pct()` helper centralizes rounding once; `liftSucceeded()` is a reusable greedy matcher shared by linear, madcow, gzclp; the PBT (fast-check) test coverage for domain invariants is genuinely excellent — not just example tests. The app tier is readable React Native with Zustand stores and is idiomatic. Half-point below 5: the `fivethreeone.ts:applyResult` discards the actual AMRAP result for TM progression (uses a fixed `tmBump`, ignoring whether the lifter got extra reps on the AMRAP set) — strictly speaking the correct Wendler progression does bump TM regardless, but it misses the nuance of *not* bumping when AMRAP is failed. This is a known simplification. Also `ppl.ts:applyResult` only progresses the main lift per day, not the secondary — consistent with the code's comment but slightly under-spec on PPL's documented behavior.
code-verified: `src/domain/**/*.ts`, `src/services/*.ts`, `src/ui/components/*.tsx`

### 4. System design — 5.0

Exceptional clean-layer architecture: domain layer has zero React Native / Expo imports (enforced by separate tsconfig); repository pattern over expo-sqlite with in-memory test double; gateway interfaces for all native side-effects with `.native.ts` implementations; Zustand stores hydrated on cold start; composition root in `container.native.ts`. Design decisions are explicitly documented in `aidlc-docs/inception/application-design/application-design.md` (D1–D8 decision table with rationale). Data model encodes invariants (parameterized SQL, REFERENCES constraint, versioned migrations). Boundaries will absorb next obvious requirements: the schema has `notes TEXT` column seam, bodyweight table comment, generic program-state JSON, future migration slots. Reads like a senior engineer wrote it. Meets level-5 anchor: clean boundaries, absorbs next two requirements, design decisions documented with rationale.
code-verified: `src/domain/`, `src/data/repositories/`, `src/services/gateways.ts`, `aidlc-docs/inception/application-design/application-design.md`

### 5. UI design — 3.5

Strong theme foundation: dark default `#0B0B0F` bg, `#37E2A0` high-contrast green accent, 56pt display-size weight numerals, 72×72 stepper buttons (well above 44pt floor), 56pt touch targets. SetRow shows lift name, weight in 24pt bold, plate breakdown badge, and log button at 84pt width — clear visual hierarchy, primary action obvious. RestTimerBar component exists. Warm-up sets displayed in a distinct surfaceAlt card.

Not at 4+: Progress screen is text-only (no chart; "wire a chart lib in native sprint" note). History screen has minimal visual polish (no session date formatting, no distinct iconography). The SetRow plate breakdown is shown via a badge but the interaction model for weight adjustment mid-workout isn't fully surfaced (WeightSelector isn't wired to individual set rows for in-workout weight overrides — only used in onboarding and potentially can be invoked, but the TodayScreen `onLog` function uses the prescription weight directly without presenting a weight-override UI). This is a genuine functional gap for the weight-adjust use case. Between level 3 and 4.
code-verified: `src/ui/theme/theme.ts`, `src/ui/components/SetRow.tsx`, `app/(tabs)/index.tsx`, `app/(tabs)/progress.tsx`

### 6. UX (source-only) — 3.5

Strong on the fundamentals from code review: 1-tap log path visible in code (no modal); rest timer auto-starts after log (`container.restTimer.start()`); keep-awake invoked; notification scheduled; timestamp-based math survives backgrounding; warm-up ramp offered before first set; plate load displayed without math. Weight selector uses 72×72 stepper buttons — "large targets, no keyboard" brief requirement met. Onboarding flow is a scrollable state machine with consistent Choice components (56pt minimum height).

Not at 4+: the in-workout weight adjustment path is missing (a user who wants to log at a different weight from the prescription has no UI path — they'd have to accept the prescription weight, which is a UX friction point for a real workout). Rest timer remaining time is displayed via `RestTimerBar` component but the `useRestTimer` hook polls every 1s — adequate but no lock-screen / Dynamic Island (best-effort, not required). RPE/RIR field is in the data model and type definitions but the `onLog()` in `TodayScreen` doesn't expose an RPE input (the fast path works but the optional path isn't wired in UI). These are code-visible gaps.
code-verified: `app/(tabs)/index.tsx`, `src/hooks/useRestTimer.ts`, `src/ui/components/WeightSelector.tsx`

### 7. Robustness — 4.0

All bad inputs from the brief/tests are handled clearly. Notification failures are caught and degraded gracefully (`try/catch` in `restTimer.start()` with fail-closed: `notificationId = null`). SQLite errors wrapped in services. Top-level `ErrorBoundary` in `app/_layout.tsx`. Timer math guards clock skew (`if (remaining > intervalMs) return intervalMs`). Cold-start container singleton pattern safe. Recovery from missing in-progress session in `finish()` returns `{prs: [], completed: false}`. Onboarding finish guards for missing container/experience/daysPerWeek/programId.

Thoughtful edge cases not explicitly in the brief: greedy plate matcher uses epsilon (`1e-9`) to avoid float comparison bugs; PR detection uses epsilon; `computePlates` handles requested ≤ barWeight gracefully; `generateWarmup` collapses duplicate snapped weights. Not quite at 5 (no offline/low-memory degradation strategy documented; plate inventory misconfiguration silently falls back to closest achievable rather than user-visible error).
code-verified: `src/services/resttimer.ts:28-37`, `src/domain/plates/plates.ts:43-46`, `src/domain/timer/timer.ts:37-40`, `app/_layout.tsx:41`

### 8. Security — 3.0

Input validated at boundaries: onboarding schedule constrained to 3–6 via Math.max/min in nsuns.ts; expo-sqlite wrapper uses parameterized queries via `db.runAsync(sql, params)` throughout (no string-concatenated SQL visible). No secrets in source (no hardcoded credentials, no API keys). Deps are from official registry; lockfile committed. Fail-safe error handling: notification gateway fails closed, timer service degrades on notification failure. 

Not at 4: no dep audit evidence (no `npm audit` output, no documented CVE check); no sensitivity logging; no explicit boundary documentation on trust assumptions. The local SQLite is single-user but there's no guard against malformed program state JSON round-trips — `state.data as LinearState` is an unchecked cast throughout all program implementations.
code-verified: `src/data/sqlite.native.ts:43-48`, `src/services/resttimer.ts:32-37`

### 9. Documentation — 4.0

README explains setup, usage, architecture, the 7 programs, and verified vs. deferred split clearly. `aidlc-docs/construction/build-and-test/platform-team-handoff.md` is a genuine onboarding doc for the platform team: step-by-step native sprint instructions, architecture notes, known simplifications. JSDoc on every source file references FR-* requirement IDs. Comments explain the *why* where non-obvious (e.g., epsilon use in comparisons, greedy plate allocation strategy, why the domain is kept Expo-free). 

Not at 5: no anticipation of "we considered X, chose Y because Z" in the README itself (that lives in application-design.md, not directly surfaced to a new contributor opening README). The 10-minute onboarding flow exists but requires reading planning docs in addition to README.
code-verified: `README.md`, `aidlc-docs/construction/build-and-test/platform-team-handoff.md`, source JSDoc

### 10. Spec articulation — 4.5

Requirements document (`aidlc-docs/inception/requirements/requirements.md`) is exceptional: FR-* IDs per area (ON/A/B/C/D/E/PERS), acceptance criteria in source-reviewable / unit-testable format matching the no-runtime constraint, per-program canonical sources pinned with specific mechanics, PBT invariants documented per domain unit. Stories.md (27 INVEST stories with Given/When/Then + FR traceability + story personas). Application design has an 8-entry design decision table with rationale and refs. Programs-canon.md pins contested canonical sources.

Not at 5: the spec doesn't quite *predict* the edge cases that turn up during implementation. For example, the nSuns AMRAP-to-TM mapping table is present but doesn't predict the "reps=1 means missed, use -5" subtlety that appears in code (`nsunsTmDelta`). The 5/3/1 TM bump ignoring actual AMRAP outcome isn't flagged in spec as a known simplification. These are foresight gaps.
code-verified: `aidlc-docs/inception/requirements/requirements.md`, `aidlc-docs/inception/user-stories/stories.md`, `aidlc-docs/construction/programs-engine/functional-design/programs-canon.md`

### 11. Scope clarity — 4.0

Both in and out of scope listed explicitly with brief reasons. The requirements document §§3–4 maps every feature to a FR-* requirement. Non-goals section in README is explicit (no auth, no kg toggle, no charts in this sprint). The construction design identifies deferred items (plate inventory editing UI, chart lib wiring) with clear reasons ("wired to SettingsService.updateInventory" / "wire a chart lib in native sprint"). The platform-team handoff explicitly separates what's done from what's deferred.

Not at 5: no evidence of scope being actively defended against creep during the session. The token-log notes the pre-authorization meant the methodology ran autonomously without scope gates. Scope was declared and defended in documents but not revisited when new information surfaced (e.g., when the tsc check showed the app tier couldn't be type-checked, scope wasn't formally revisited — it was simply deferred silently).
code-verified: `README.md §Non-goals`, `aidlc-docs/construction/build-and-test/platform-team-handoff.md`

### 12. Assumption surfacing — count: 12 / quality: 4.0

Documented assumptions count:
1. Pounds-only for v1 (Q4 decision, documented in requirements.md + code)
2. One active program at a time; all 7 seeded at onboarding (D8 in application-design.md)
3. Warm-ups and assistance excluded from PRs/e1RM (requirements §4.4 + code)
4. RPE/RIR optional, never blocks fast path (FR-D-2)
5. Program recommendation mapping (beginner→linear, intermediate→5/3/1/Madcow, advanced→nSuns/PPL) — accepted in Q5 with acknowledgement
6. 6-day programs first-class (nSuns/PPL fitsSchedule 4+/6+)
7. Barbell+rack+bench only; non-barbell accessories substituted or dropped (FR-B-2)
8. 45 lb bar default, configurable inventory (schema + code)
9. Live Activity is iOS-only best-effort bonus (modules/live-activity/README.md)
10. nSuns/GZCLP/PPL contested variants locked to pinned canonical source (programs-canon.md)
11. Pure domain isolation from RN/Expo (D1 in application-design.md)
12. AMRAP reps-to-TM mapping table for nSuns (nsuns.ts:nsunsTmDelta)

Assumptions are named with choices and say what changes if wrong (e.g., "if kg is needed, the data model stores canonical lb so a display toggle only requires UI change"). Categorized loosely by domain (product/technical). Not quite at 5 (no explicit mapping of assumptions to code locations that would need to change — the application-design.md D-table references areas but not file:line).
code-verified: `aidlc-docs/inception/requirements/requirement-verification-questions.md`, `aidlc-docs/inception/application-design/application-design.md`, `src/domain/programs/nsuns.ts:55-61`

---

## Dimension scores summary

| # | Dimension | Score | Evidence basis |
|---|---|---|---|
| 1 | Functionality | 4.0 | 7 programs + full flow present; charts/inventory-edit UI thin |
| 2 | Correctness | (see defect table) | |
| 3 | Code quality | 4.5 | Idiomatic TS + domain isolation + PBT; one AMRAP simplification |
| 4 | System design | 5.0 | Exceptional layering; decision table documented; absorbs stretch |
| 5 | UI design | 3.5 | Dark theme + large targets + hierarchy; no charts, no in-workout weight adjust |
| 6 | UX | 3.5 | 1-tap path + timestamp timer + keep-awake; in-workout weight-adjust missing |
| 7 | Robustness | 4.0 | Fail-closed gateways; epsilon float guards; edge cases handled |
| 8 | Security | 3.0 | Parameterized SQL + fail-safe; no audit evidence; unchecked JSON casts |
| 9 | Documentation | 4.0 | README + platform-team handoff + JSDoc; 10min onboarding path exists |
| 10 | Spec articulation | 4.5 | FR-* + Given/When/Then + pinned canons; foresight gaps on AMRAP nuances |
| 11 | Scope clarity | 4.0 | In/out declared; deferred items explicit; no scope revisit on new info |
| 12 | Assumption surfacing | 4.0 | 12 explicit assumptions; named with choices + consequences; no file:line map |

**Quality sum: 44.0 / 55**
**Product polish (Func+UI+UX+Robust): 15.0 / 20**
**Engineering rigor (Code+SysDes+Sec+Doc+Spec+Scope+Assump): 29.0 / 35**

---

## Defect count

| Severity | Tests (T) | Source-review (R) | Total |
|---|---|---|---|
| Critical | 0 | 0 | 0 |
| Major | 0 | 2 | 2 |
| Minor | 0 | 3 | 3 |

**Defect detail:**

Major:
- M1: `fivethreeone.ts:applyResult` — TM progression ignores actual AMRAP reps. The correct Wendler 5/3/1 canonical bump is +5 upper / +10 lower *per cycle* regardless of AMRAP performance, but the brief's pinned canon says "top sets AMRAP; +5 upper / +10 lower to TM per cycle" — the code is arguably canon-correct but the spec (programs-canon.md) says "+5 lb upper / +10 lb lower TM per cycle" without a failure condition, which means the code doesn't distinguish success vs. failed AMRAP. A failure scenario (lifter can't complete the minimum reps) should probably not advance the TM. INDETERMINATE: could be correct per pinned canon; flagged as major because the real-world program *does* have a failure mode. code-reviewed: `src/domain/programs/fivethreeone.ts:78-83`
- M2: No in-workout weight adjustment UI. The TodayScreen `onLog()` logs the prescription weight directly without exposing the WeightSelector for in-workout override. A real lifter who needs to log at a different weight (injury, deload, estimated) has no UI path. The WeightSelector exists but is only wired to onboarding. code-reviewed: `app/(tabs)/index.tsx:36-53`

Minor:
- m1: RPE/RIR input not exposed in `TodayScreen.onLog()`. The model supports it (optional `rpe` field in `LogSetInput`) but there's no UI input — the fast path works but the brief's "optional; feeds a better e1RM" goal isn't fully surfaced. code-reviewed: `app/(tabs)/index.tsx:44`, `src/services/workout.ts:39`
- m2: `ppl.ts:applyResult` only progresses the day's `main` lift, not the secondary lift, per the code comment. PPL's secondary lift (3×8 back-off) has its own progression logic in the real program. This is a simplification that slightly under-implements the PPL spec but is consistent within the codebase. code-reviewed: `src/domain/programs/ppl.ts:83-99`
- m3: Progress screen text-only (no volume/tonnage chart component). The `tonnage()` method exists in `ProgressService` but is not wired to any UI. code-reviewed: `app/(tabs)/progress.tsx`, `src/services/progress.ts:36-43`

**LOC (net, per token-log.md):** 7,582
**Defects per 1KLOC:** 5 / 7.582 = **0.66 defects/KLOC**

---

# COST AXIS

(From token-log.md)

| Metric | Value |
|---|---|
| Implied API cost | **$33.50** |
| API compute time | **50m 27s** |
| Wall-clock | 1h 46m 8s |
| Operator touch | ~5 min |
| Operator interventions (unplanned) | 0 |
| Net LOC | 7,582 |
| Sub-agents | 0 |
| Web searches | 1 |
| PM forwards | 11 |

**Derived ratios:**
- Quality per 1K tokens: 44.0 / (48,609k/1000) ≈ **0.91** (48.6M total = 9.8k input + 236.8k output + 48,000k cache-read + 560.6k cache-write)
- Quality per API hour: 44.0 / (50.45/60) = **52.3**
- Defects per 1KLOC: **0.66**
- Methodology overhead ratio (Inception API time / Construction API time): INDETERMINATE — phase-level breakdown not in session-log; session ran from 17:45 to 18:56 with Inception ending ~18:23 (38 min) and Construction from 18:23 to 18:56 (33 min) ≈ 1.15 — roughly 1:1 planning:implementation, which is the AI-DLC characteristic signature (substantial ceremony).
- Cost per binary outcome: $33.50 / 19 passing checks ≈ **$1.76**
- Quality per dollar: 44.0 / 33.50 = **1.31**

---

# PAIRED Δ vs run-001 (this cell)

| Metric | run-001 (with-runtime) | run-002 (no-runtime) | Δ | Interpretation |
|---|---|---|---|---|
| Quality /55 | UNSCORED | 44.0 | — | run-001 not yet scored; hypothesis: similar quality since domain is the same; minor regression on UI/UX dims expected without runtime iteration |
| Cost | $97.97 | $33.50 | **−$64.47 (−66%)** | Removing sim cycle cut AI-DLC's signature turn-count × rule-set-re-reads by 70%; the biggest cost delta of any run-002 cell |
| API compute | 1h 31m | 50m 27s | −41m (−45%) | Direct effect of fewer simulation/build turns |
| Net LOC | 8,911 | 7,582 | −1,329 (−15%) | Slightly less code; no native build scaffolding needed |
| Defects/1KLOC | UNSCORED | 0.66 | — | Can't compute Δ without run-001 score |
| Cache-read tokens | 161.4M | 48.0M | −113.4M (−70%) | The cleanest cost-driver data in the eval: AI-DLC costs scale with turn count × ceremony |

**Hypothesis:** run-002 likely matches or slightly exceeds run-001 on domain logic dims (1, 3, 4, 10-12), and will slightly underperform on UI/UX (5, 6) and Robustness (7) dims since without the runtime feedback loop the app tier is less exercised. The cost story is the biggest finding: 15% less code for 66% less cost.

---

# BINARY OUTCOMES (design-verifiable, no-runtime variant)

Per `tasks/t4-fitness-app-rich/success-criteria.md` §9 no-runtime variant, these are recategorized as design-verifiable:

| # | Outcome | Result | Evidence |
|---|---|---|---|
| 1 | Core app builds + runs | DEFERRED (platform team) | No-runtime variant; tsc clean; tests pass |
| 2 | Onboarding works | DESIGN-PASS | `app/onboarding/index.tsx` — 7-step flow, help-me-pick, starting numbers via WeightSelector |
| 3 | Four lifts present | DESIGN-PASS | `MAIN_LIFTS = ['squat', 'bench', 'deadlift', 'ohp']` in `types.ts:15` |
| 4 | Today's workout on open with weight + plate load | DESIGN-PASS | `app/(tabs)/index.tsx`, `SetRow.tsx`, `PlateBreakdownBadge.tsx` |
| 5 | Set logging (1-tap) | DESIGN-PASS | `onLog()` calls `logSet(prescription)` in one tap; no modal |
| 6 | Plate calculator | DESIGN-PASS | `plates.ts` + inventory-aware; tests pass |
| 7 | Rest timer | DESIGN-PASS | `resttimer.ts` + `timer.ts` + haptic invocation in `gateways.ts` |
| 8 | Backgrounded rest alert | DESIGN-PASS (code) / DEFERRED (runtime) | `notifications.native.ts` wired; runtime verification deferred |
| 9 | Quick-switch survives | DESIGN-PASS (code) / DEFERRED (runtime) | `RestTimerSnapshot` + `hydrate()` paths reviewable |
| 10 | Warm-up ramp | DESIGN-PASS | `warmup.ts` + tests; excluded from PRs |
| 11 | 7 programs correct progression | DESIGN-PASS | All 7 programs with per-program unit tests; 77 tests pass |
| 12 | Flexible scheduling 3–6 days | DESIGN-PASS | `fitsSchedule()` parametric; PPL requires 6+; nSuns 4-6 configurable |
| 13 | History persists + History screen | DESIGN-PASS | `schema.ts` + `sqlite.native.ts` + `app/(tabs)/history.tsx` |
| 14 | Progress + PRs | DESIGN-PASS (domain) | `progress.ts` + `pr.ts` + `detectPRs()`; chart UI minimal |

**Design-verifiable passes: 12/14** (outcomes 1 and the runtime-dependent aspects of 8+9 deferred to platform team; expected per no-runtime variant spec).

---

# RICH-BRIEF-SPECIFIC CHECKS

- [x] **Non-goals honored** — no auth, no cloud sync, no remote push, no cardio/nutrition, no multi-user, pounds-only. code-verified.
- [x] **Open assumptions engaged, not silently overridden** — Q4 accepted pounds-only explicitly (not silently); Q5 accepted pinned canons with acknowledgement; recommendation mapping accepted + documented. `requirement-verification-questions.md` shows explicit engagement with all §10 assumptions.
- [x] **Stretch stayed out** — no supersets, no export, no custom builder, no periodization, no Apple Watch. Data model has extension seams (schema migration slots, notes column) without implementing. code-verified.
- [x] **Delight north-star engaged** — coaching notes wired to AMRAP sets; PR celebration via `Alert.alert('New PR! 🎉', ...)` with specifics; warm-up ramp ("delight is not over-specifying"). Partial: no Live Activity wired, PR alert is an Alert modal (not a designed celebration screen). Binary: YES (coaching notes + PR moment + haptics + keep-awake wired).
- [x] **Runtime honored** — SDK 56 pinned in `package.json`; `npx` used; no Expo Go, no globally-installed CLI. code-verified.
- [x] **Equipment scope honored** — programs use barbell movements only; PPL accessory lifts are `closegrip`, `rdl`, `frontsquat`, `row` (all barbell); no machine/cable/dumbbell movements. code-verified: `src/domain/programs/ppl.ts:22-29`.

---

# FAILURE-MODE CHARACTERIZATION

**Where the methodology broke down:**
- Gate density was not suppressible even with explicit pre-authorization. The methodology paused twice at internal gates (requirements verification and user-stories planning), adding 11 PM-ask questions. This is a documented AI-DLC characteristic.
- The in-workout weight-adjustment UX gap (a user can't log at a different weight than the prescription in the Today screen) is a design blind spot not caught without runtime iteration.
- Progress charts deferred to "native sprint" is a mild scope shrink — the brief explicitly lists volume/tonnage charts as in scope.

**What the methodology did surprisingly well:**
- Domain isolation is the clearest architectural win in the eval: the pure domain layer + gateway pattern means 77 tests run in pure Node with zero native dependency, satisfying the no-runtime sprint brief perfectly.
- Property-based testing (fast-check) is genuinely used and meaningful — not just added as a checkbox. The PBT invariants for plate calculator, warm-up ramp, and program progression are real.
- Planning artifact trail is the richest in the hexad: requirements doc with FR-* traceability, Given/When/Then stories, component dependency diagrams, programs-canon.md, platform-team handoff. A new engineer could onboard in < 30 minutes.
- Cost compression: removing the runtime loop cut cost 66% with only 15% fewer LOC. The methodology can deliver comparable quality at a third of the cost when the build constraint relaxes.

**Notable artifacts:**
- `aidlc-docs/inception/requirements/requirements.md` — comprehensive; unusual to see FR-* → acceptance criteria at this level of traceability.
- `aidlc-docs/inception/application-design/application-design.md` — D1–D8 design decision table with rationale is the best planning artifact in the hexad so far.
- `modules/live-activity/README.md` + scaffold — the only cell in the hexad to scaffold the Live Activity bonus (as a stub; not wired).

**Moments where operator was tempted to intervene but didn't:**
- The TodayScreen missing in-workout weight adjustment. Visible in source but not caught until review. The cell didn't attempt a runtime verify loop (per brief), so this was an honest design gap.

---

# HEADLINE FINDING

AI-DLC run-002 delivered a structurally excellent codebase (Quality 44/55, 5.0 on System Design) for $33.50 / 50 min API compute — a 66% cost reduction vs run-001's $97.97 by eliminating the runtime verification loop, while losing only 15% of code and producing comparable domain correctness (77 tests passing, all 7 programs unit-tested). The no-runtime constraint exposed AI-DLC's strongest suit: a deeply spec-driven, layered architecture with gateway isolation and PBT coverage that stands on its own without a sim, and revealed where the methodology is less strong without runtime feedback — in-workout UX micro-decisions (weight-override path, RPE entry) and the visual polish of progress charts. The methodology's gate density remains a fixed overhead (~11 PM questions, ~2 forced pauses) regardless of brief size.
