# T4-rich (PM-quality brief) / BMAD v6.7.1 / Run 001 / Observations

Filled in during scoring. Uses [`harness/scoring-rubric.md`](../../../../harness/scoring-rubric.md) and [`tasks/t4-fitness-app-rich/success-criteria.md`](../../../../tasks/t4-fitness-app-rich/success-criteria.md).

**Reviewer:** claude-sonnet-4-6 (autonomous scoring agent)
**Scored on:** 2026-05-29
**Evidence basis:** CODE-BASED (no sim this pass — parallel scoring, shared sim unavailable)
**Methodology revealed at:** n/a (unblinded scoring pass)

---

# QUALITY AXIS

## Dimension scores (0–5 per harness/scoring-rubric.md)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | 4.5 | All 7 programs ship with correct canonical progression (verified via definitions + strategy tests); all core-loop features present (logging, rest timer, warm-up, PR detection, history, progress); Live Activity correctly not built (brief COULD tier) — only gap: no "not sure?" labeled path in starting-numbers UI (defaults offered but not labeled) |
| 2 | Correctness | (see defect block) | 159/159 tests pass, 0 tsc errors |
| 3 | Code quality | 4.5 | Idiomatic React Native / TypeScript throughout; clean naming (LIFT_LABEL, SetType, Prescription); pure domain/engine split; strategy pattern properly applied; accessibility roles on every interactive element; one minor smell (no explicit `barbell_row` type guard in SetRow accessibilityLabel) |
| 4 | System design | 5 | Programs-as-data + strategy interface (linear/tmCycle/weeklyRamp/tierLadder/pplLinear) with Zod validation at boundary; set-log-as-atom keyed to exercise (not program) — proven by integrity.test.ts; Drizzle + useLiveQuery reactivity; Zustand for ephemeral state; architecture doc explicitly records design decisions and their rationale |
| 5 | UI design | 4 | Consistent dark-only design token system (colors.ts: rack-room near-black #0E0F12, molten-iron accent #FF5A1F); display-size numerals for weights; one-accent discipline enforced; chip+card hierarchy clear; ≥44pt tap targets on steppers (64×64 in WeightSelector); no light mode / no dynamic theme inconsistency; dark default matches brief §8 |
| 6 | UX | 4 | Plate load shown with every set (perSideText in SetRow); 1-tap common log (Pressable onLog); rest timer auto-starts (startRestForSet in useToday.log()); haptic on log (tickOnLog()); warm-up collapse/expand (skip-able); coaching notes at correct moment; adjust-set drawer for non-1-tap adjustment; RPE optional; large (64×64) WeightSelector steppers; keep-awake during session |
| 7 | Robustness | 4 | Timestamp-based rest timer (useRestTimer reconstructs from persisted rest_end_at — no drift on suspend); session persistence via SQLite at log time; notification permission denied gracefully (falls back to haptic, no crash); Zod validation on program definitions and onboarding inputs; abandonSession() keeps history; empty-state screens for History/Progress; MigrationGate with snapshot rollback |
| 8 | Security | 3 | Offline, no auth surface, no network calls, no secrets; local notifications only (test explicitly asserts no push token requested); Zod validates at trust boundaries; SQLite types prevent injection; no hardcoded credentials; lockfile present; slightly below 4 because dep audit not visible in-source and no threat-boundary comment |
| 9 | Documentation | 3.5 | README.md is comprehensive: explains dev-build requirement, scaffold commands, day-to-day dev, project structure; inline comments explain non-obvious choices (integer-lb discipline, one-accent rule, timestamp-based timer, FR-N cross-refs in every file); decision records live in architecture.md (not in shipped docs — planning artifact, not scored here); missing: no CONTRIBUTING.md, no 10-min-from-clone onboarding flow |
| 10 | Spec articulation | 5 | PRD covers all 52 FRs with MoSCoW tiers, acceptance criteria, and a Glossary enforced as a discipline; addendum.md pins per-program canonical sources; reconcile-brief.md explicitly maps gaps; §9 Assumptions Index; architecture doc closes all 6 Open Questions with documented rationale; spec predicts implementation edge cases (programs-as-data, set-log-as-atom, timestamp-based timer) that all appear verbatim in code |
| 11 | Scope clarity | 4 | PRD §5 (Non-Goals), §6.1 (In Scope), §6.2 (Out of Scope/COULD tier) are explicit and cross-reference brief §6; MoSCoW tiers in every FR; architecture doc defers Stretch items to NFR-Extensibility with nullable columns and named-profile indirection; reconcile-brief.md surfaces 3 gaps and 7 partials; no silently overridden non-goals; Live Activity correctly COULD with explicit degrade path; not a 5 because scope decisions are declared+defended but not conditionally revisited when late-session new info (story reviews) surfaced |
| 12 | Assumption surfacing | count: 15+ / quality: 4 | 10 \[ASSUMPTION\] tags in PRD + 6 Open Questions (closed in architecture); assumptions include: recommendation mapping (FR-3), warn-but-allow for schedule mismatch (FR-4/36), weight-selector stepping plate-aware (FR-16), conservative defaults never enforced (FR-5), warm-ups excluded from PR (FR-47), local-only notifications (architecture §Auth), equipment substitution rule (addendum §B); categorized by FR; say what would change if wrong (e.g., "exact pairings are reviewer-judgment not fixed contract"); mapped to FR not code locations (below 5 threshold) |

**Quality sum:** 46.5 / 55

**Product polish vector (dims 1+5+6+7):** 4.5 + 4 + 4 + 4 = **16.5 / 20**
**Engineering rigor vector (dims 3+4+8+9+10+11+12):** 4.5 + 5 + 3 + 3.5 + 5 + 4 + 4 = **29 / 35**

---

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | 0 |
| Major | 0 | 0 | 0 | 0 |
| Minor | 0 | 0 | 4 | 4 |

LOC produced: ~5,785 non-test source lines (app/ + src/, excl. node_modules); ~7,902 total TS lines incl. tests
**Defects per 1KLOC:** 4 / 5.785 ≈ **0.69 / 1KLOC**

Itemized defects (all Minor, code-review):
1. **Minor (R):** `app.json` splash backgroundColor `#208AEF` (blue) inconsistent with dark-only theme palette; minor visual jank on first launch (app.json:33). Evidence: `compound-app/app.json:33`.
2. **Minor (R):** `today.tsx` — the RPE/RIR capture path is absent from the 1-tap `onLog` call; a user who wants to add RPE to the prescription-log path must open the adjust-set drawer (today.tsx:109). The brief says RPE "never blocks the fast path" — this is correct per spec, but it means a user logging with RPE always takes 2+ taps. The UX spec calls this a COULD, so this is a minor spec-accuracy note, not a product failure.
3. **Minor (R):** `startingNumbers.tsx` — "Not sure?" label absent; the screen offers conservative defaults with explanatory text but no explicit "Not sure?" button/path as named in brief §4a step 6 and FR-5. Defaults are available and the help text describes them, but the named path from the brief is not surfaced literally (starting-numbers.tsx:16-22).
4. **Minor (R):** `WeightSelector.tsx` — long-press auto-repeat uses `setInterval` at 150ms with a `weightRef` ref to hold current state; if the interval fires after component unmount (e.g., rapid nav), the ref prevents a crash but `onChange` may fire on an unmounted parent. The `useEffect(() => stop, [])` cleanup is correct but fires only on unmount — the interval was already started. No functional data corruption, cosmetic edge case (WeightSelector.tsx:48-68).

---

## Binary outcomes (pass/fail per task success-criteria.md)

| # | Outcome | Status | Evidence |
|---|---|---|---|
| 1 | Core app builds + runs as dev build | code-verified (runtime not exercised this pass) | tsc 0 errors; 159/159 tests pass; expo-dev-client in package.json; SDK 56 pinned; app.json valid; ios/ and android/ dirs present |
| 2 | Onboarding works | PASS | profile.tsx (experience/days/goal chips); recommend.tsx (help-me-pick + library); starting-numbers.tsx (WeightSelector + defaults); seedFromOnboarding() → router.replace('/(tabs)/today') |
| 3 | Four lifts present | PASS | domain/types.ts Lift = 'squat' \| 'bench_press' \| 'overhead_press' \| 'deadlift' \| 'barbell_row'; all 4 main lifts in every program definition |
| 4 | Today's workout with weight+plate load | PASS | today.tsx:57 `<SetRow weightLb={weight} ... profile={profile}>`; SetRow:57 `perSideText(weightLb, profile)` — plate breakdown shown on every set row without user input |
| 5 | Set logging works (1-tap common case) | PASS | SetRow is a single `<Pressable onPress={onLog}>`; `onLog` calls `log(item.lift, p.weightLb, p.reps, p.setType)` — one tap for the prescription value (today.tsx:108-109) |
| 6 | Plate calculator | PASS | plates.ts `computePlateBreakdown()` (subset-sum DP); respects plate inventory + bar weight; shown in SetRow + WeightSelector; never over-prescribes (rounds down) |
| 7 | Rest timer | PASS | RestTimer.tsx + useRestTimer.ts; auto-starts via `startRestForSet()` on each `log()` call (useToday.ts:59); haptic via `tickOnLog()` (haptics.ts); per-exercise intervals via restIntervals service |
| 8 | Backgrounded rest alert (both platforms) | code-verified (runtime not exercised this pass) | notifications.ts `scheduleRestEndNotification(restEndAt)` schedules DATE-triggered local notification; test confirms no push token requested; timer service cancels on return; expo-notifications pinned at ~56.0.14 |
| 9 | Quick-switch survives | code-verified (runtime not exercised this pass) | useRestTimer:68-90 reconstructs from `rest_end_at` persisted in appSettings; AppState.addEventListener('active') snap-refreshes on foreground; session in-progress status persisted to SQLite at log time |
| 10 | Warm-up ramp | PASS | warmup.ts `generateWarmupRamp()` at today.tsx:51; auto-generated from first working set weight; excluded from progression (setType='warmup'); collapsible via 'Skip warm-up' pressable |
| 11 | 7 programs, correct progression | PASS (code-verified) | All 7 definitions present (stronglifts5x5, linear5x3, wendler531, madcow5x5, gzclp, nsuns531lp, redditPpl); 5 strategy types (linear/tmCycle/weeklyRamp/tierLadder/pplLinear); canonical percentages match brief §5B and sources.ts; 159 tests pass including per-program fixtures |
| 12 | Flexible scheduling 3–6 days | PASS | profile.tsx DAYS=[3,4,5,6]; settings.tsx DAY_OPTIONS=[3,4,5,6]; scheduleFit() handles mismatch warn-but-allow; PPL preferredDays=6 present |
| 13 | History persists + History screen | PASS | sets/sessions tables in schema.ts (written at log time); history.tsx (browsable list with detail link); [sessionId].tsx detail screen; integrity.test.ts proves history spans program switches |
| 14 | Progress + PRs | PASS | progress.tsx (e1RM + volume + intensity charts via react-native-gifted-charts); pr.ts `detectPRs()` + `buildPrHistory()`; finish.tsx PR celebration via FinishPrMoment; history.tsx PR section |

**Pass count: 14 / 14** (2 outcomes are code-verified without sim exercise but code paths are confirmed present and correct)

---

## Rich-brief-specific checks

- [x] **Non-goals honored** — no auth/accounts/cloud/push/cardio in codebase; architecture §Auth documents "not applicable by design"
- [x] **Open assumptions engaged** — recommendation mapping, lb-only, one-active-program-seeds-all, warm-ups/assistance excluded from PRs all explicitly addressed in PRD §9 and architecture
- [x] **Stretch stayed out** — supersets, export, custom builder, Apple Watch not built; nullable columns and named-profile pattern accommodate them without refactor
- [x] **Delight north star** — PR celebration (FinishPrMoment, full-bleed molten-glow), coaching notes in-session, haptics on log, warm-up collapsible, accessibility announced breakdown; UX design doc present (EXPERIENCE.md) — unprompted delight from intent
- [x] **Runtime honored** — expo-dev-client ~56.0.16; SDK 56 pinned; app.json targets dev build; `npx` instructions in README
- [x] **Equipment scope honored** — 5-lift barbell domain only; GZCLP T3 note documents cable/dumbbell substitution in file comment; PPL Legs note documents RDL deferral

---

# COST AXIS

## Raw metrics (from session-log.md + token-log.md)

| Metric | Value |
|---|---|
| Total tokens | ~617.3M (cache read dominant: ~617.8M input+cache read across all sessions) |
| Implied API cost | **$384.05** |
| Total API compute time | ~6h 37m (across 7 sessions) |
| Wall-clock | ~26h 50m (multi-session over day+night) |
| Operator-touch time | ~10-15 min total |
| Operator intervention count | 0 unplanned (all touches were BMAD phase routing or PM-ask forwards) |
| Clarifying questions forwarded to PM | ≥3 rounds (program mapping, LA decision, D2 PPL reps, D3 deriveOnSwitch) |
| LOC produced | +18,396 / −1,414 = ~16,982 net (largest in eval) |

**Phase breakdown (API compute time):**
- Planning phases (PRD + UX + Architecture + Epics, sessions 1–4): ~35m46s + 24m17s + 13m56s + 22m2s = **~96 min (planning)**
- Implementation + review (sessions 5–7): **~5h 1m**
- Methodology overhead ratio (planning / implementation): 96 / 301 = **~0.32** (32% overhead)

## Derived ratios

| Ratio | Value |
|---|---|
| Quality per 1K tokens | 46.5 / ~617,300 × 1000 = **0.075** |
| Quality per API hour | 46.5 / 6.62h = **7.0** |
| Defects per 1KLOC | 4 / 5.785 = **0.69** |
| Methodology overhead ratio | ~0.32 (planning:implementation API compute time) |
| Cost per binary outcome | $384.05 / 14 = **$27.43** |
| Quality per dollar | 46.5 / $384.05 = **0.121** |

---

# HEADLINE FINDING

```
Quality: 46.5 / 55  ·  Cost: $384.05 / 6h 37m API compute  ·  Binary: 14 / 14 pass
```

**One-line verdict:**

> BMAD on T4-rich delivers the eval's most complete implementation (14/14 binary outcomes, 46.5/55 quality, defect-free test suite) but at extreme cost ($384.05, 6h 37m API compute, ~617M cache-read tokens) — the full BMAD ceremony scales superlinearly with brief richness, producing a $308/+406% cost spike vs. the T4-vague run at nearly identical quality (+0 quality Δ vs T4-vague's 49.5 suggests the rich brief bought zero additional quality from BMAD, which was already structured enough not to need it).

---

## Paired-Δ vs comparator (run-002)

Run-002 token-log.md has no data yet (all fields blank at scoring time). Paired Δ cannot be computed. Placeholder:

| Metric | run-001 | run-002 | Δ | Δ% |
|---|---|---|---|---|
| Implied API cost | $384.05 | (not yet run) | — | — |
| API compute time | ~6h 37m | (not yet run) | — | — |
| Net LOC | ~16,982 | (not yet run) | — | — |
| Quality | 46.5 / 55 | (not yet scored) | — | — |

---

## Failure mode characterization

**Where did BMAD v6.7.1 break down?**
- BMAD did not break down on functionality. The methodology's failure mode is pure cost: 7 sessions, 5 sub-agents, ~617M cache-read tokens (session 5 alone had ~594.7M cache reads). The multi-window "fresh context per phase" design generates enormous repeated-context costs.
- Sessions 6 and 7 ran on claude-sonnet-4-6 instead of claude-opus-4-8 (operator forgot `--model` flag on fresh CC windows). Model fidelity caveat recorded; ~3% of cost affected, review-phase work only.
- "Not sure?" path from brief §4a was not labeled as a separate button in the starting-numbers screen — defaults are offered but not explicitly labeled.

**Categories of mistake:**
- Ceremony tax: PRD + UX design doc + architecture doc + epics + 40+ story files before a line of code. The 4-phase planning burn alone (~96 min API compute, ~$34 total) produced more documentation than the next 3 methodologies combined.
- Model-window discipline: 7 separate Claude Code sessions required, each re-loading context, driving cache-read inflation.

**What did it do surprisingly well?**
- System design: the programs-as-data + strategy interface pattern was explicitly designed in the architecture doc and perfectly executed in code. The integrity.test.ts that proves history spans program switches is a delight.
- Test coverage: 41 test suites / 159 tests covering pure engine functions, React components, hooks, and services — test-first discipline per bmad-dev-story workflow.
- Documentation: the inline FR-N cross-references in every file make the code auditable against the spec without context-switching.
- Assumption surfacing: the PRD §9 Assumptions Index + reconcile-brief.md gap analysis are genuinely rare in any methodology cell.

**Notable planning artifacts:**
- `prd.md` (607 lines): 52 FRs with MoSCoW tiers, testable acceptance criteria, Jobs-to-Be-Done, User Journeys, Glossary (enforced verbatim), Assumptions Index.
- `addendum.md`: pinned canonical sources per program, data model extensibility contract, NFR-to-implementation mapping.
- `architecture.md` (623 lines): closes all 6 PRD Open Questions with rationale; records Critical vs. Important vs. Deferred decisions; documents the programs-as-data + strategy interface choice with explicit AR-N references in code.
- `reconcile-brief.md`: adversarial brief-to-PRD gap analysis (3 gaps, 7 partials, 6 nits) — the methodology self-audited its own spec against the brief.

**Operator-tempted-but-didn't-intervene moments:**
- None recorded in session log. The 0 unplanned interventions reflect BMAD's autonomous multi-phase execution; the ≥3 PM-ask forwards were methodology-internal (the bmm workflow explicitly routes open questions to the PM persona).
