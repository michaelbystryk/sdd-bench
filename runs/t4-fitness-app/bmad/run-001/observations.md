# T4-bmad / Run 001 / Observations

Filled in during scoring (live walkthrough via idb-driven iOS 26.5 sim 2026-05-25 22:00 PT, ~3 h after cell end). Uses [`harness/scoring-rubric.md`](../../../../harness/scoring-rubric.md) v0.1.2 (0.5 increments permitted) and [`tasks/t4-fitness-app/success-criteria.md`](../../../../tasks/t4-fitness-app/success-criteria.md).

**Reviewer:** Operator (unblinded — same-day scoring; bias acknowledged)
**Scored on:** 2026-05-25
**Methodology revealed at:** n/a (unblinded)

---

# QUALITY AXIS

## Dimension scores (0–5 per harness/scoring-rubric.md; 0.5 increments permitted)

**Revised 2026-05-25 after operator's user-perspective review caught issues I missed in the happy-path idb walkthrough. Original scores in parentheses.**

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | **4.5** (was 5) | All 7 binary outcomes PASS; 5/3/1 with TM=90%, AMRAP, deload, edit/delete, e1RM, export. **But missing plate-per-side display that Vibe-pure built** — for a weight-selector-fast brief, plate math is implicit. Dropped 0.5 for the feature miss. |
| 2 | Correctness | (see defect block) | 0 critical / **1 major** / **3 minor** (revised — +1 major +1 minor below) |
| 3 | Code quality | **5** | TS strict throughout; named functions short + purpose-specific; small surprises of skill (memoized DB init with race-fix doc comment; `currentCycleWeek` defensive modulo); tabular numerals for glanceability. |
| 4 | System design | **5** | Pure engine layer / DB layer / stores / components / theme tokens — boundaries clean and tested in isolation. Versioned append-only migrations. Data model already absorbs cardio/rest-timer/program-editor without refactor. ADR-style inline comments. Senior-engineer code. |
| 5 | UI design | **4** (was 5) | Dark + lime, tabular numerals, clear hierarchy — but operator's lived gestalt: "UI looked worse than Plan Mode." The post-finish transition is a UI signaling failure (silently rotates to next lift with no "session complete" visual). Dropped 5 → 4. |
| 6 | UX | **3.5** (was 4.5) | Set-logging primary loop is great (±5/±2.5-on-hold stepper, one-tap confirm). **But the end-of-workout transition is a primary-loop UX defect** — tapping Finish silently rolls into the next rotation slot, no "you finished today" affordance, looks like a different set of the same session. Dropped 1 full point. Also still missing a rest timer. |
| 7 | Robustness | **3.5** (was 4) | DB migration race discovered + fixed; setup validation; empty states. **But end-of-session state transition is a robustness gap** — the app doesn't distinguish "this session is complete" from "go log the next rotation slot now." Plus the dup-key React warning. Dropped 0.5. |
| 8 | Security | **4** | Parameterized SQL throughout, local-only enforced (NFR-1), no secrets/network, deps pinned. Threat boundaries implicit. |
| 9 | Documentation | **5** | README + CLAUDE.md + AGENTS.md + inline JSDoc + 2,146 lines of BMAD planning artifacts + decision logs per artifact. Anticipates the next question. |
| 10 | Spec articulation | **5** | PRD (294 lines, 20 FRs + 6 NFRs), Architecture (389 lines), Epics + 14 stories (333 lines), UX DESIGN + EXPERIENCE peer contracts, Implementation Readiness Assessment. Spec correctly predicted edge cases (AMRAP-feeds-e1RM, deload trigger, FR-16). **But the spec didn't catch the plate-calculator omission or the post-finish UX transition — two real user-visible gaps the planning rigor "should" have surfaced. Stays at 5 because by-the-anchor it qualifies (predicts edge cases), but flagged.** |
| 11 | Scope clarity | **5** | Non-goals explicit in PRD; variances documented; 5/3/1 choice has rationale; .decision-log per artifact. |
| 12 | Assumption surfacing | **count: ~12+ / quality: 5** | Decision logs per major artifact; each assumption names choice + dependency; FR-N references in build log. |

**Quality sum (11 scored dimensions, max 55):** **49.5 / 55** (revised from 52.5)

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | **0** |
| Major | 0 | **1** | 0 | **1** |
| Minor | 0 | 0 | **3** | **3** |

LOC produced: 2,300 (app source, TS/TSX)   |   **Defects per 1KLOC: 1.74** (revised from 0.87)

Itemized defects:

1. **Major (M) — post-finish UX silently rotates to next workout with no "session complete" state.** Tapping "Finish workout" on the Squat session immediately transitions the Today screen to Bench Press (next in rotation). No confirmation, no "great session" affordance, no visual cue that the user has *finished* today vs. is now expected to *keep going* with the next lift. For a mid-workout app where state-awareness matters (am I done? do I keep training?), this is a real user-confusion defect. Caught by operator's lived review, not by the idb walkthrough. The methodology's UX DESIGN + EXPERIENCE artifacts (239 lines combined) did not address end-of-session signaling. Fix scope: add a "Workout complete" sheet / toast / dedicated state before the rotation advances on the Today screen.

2. **Minor (R) — no plate-per-side display.** Vibe-pure built `src/lib/plates.ts` with `platesPerSide()` and integrated it into the set-logging UI. BMAD (and Plan Mode) did not. For a brief that explicitly says "weight selector specifically should be fast" with a user lifting at intermediate-plus loads (squat 315, deadlift 405), plate math is implicit to weight selection — without it the lifter still has to mentally compute "315 means 2 plates + 1 quarter + 2 dimes per side." Vibe-pure surfaced this need from nothing; BMAD with 1,500+ lines of planning rigor missed it. Feature gap, not a code bug.

3. **Minor (R) — duplicate React keys in `(tabs)/index.tsx:108`.** Upcoming-set rows use `key={i}` from the prescribed-sets array index; on re-render when the active set transitions, React sees the same `i` reused across the active-card sub-tree and the upcoming-rows sub-tree → "Encountered two children with the same key" yellowbox in dev. Fix: prefix the key (`key={`upcoming-${i}`}`).

4. **Minor (R) — expo-router default back-button label leak `< (tabs)`** on History detail screen. Should be `← History` or `← Back`. Cosmetic but exposes routing internals.

**Note on the pre-existing fixed defect:** the build log documents a DB migration race condition (`cannot start a transaction within a transaction`) that surfaced during the operator's device smoke test and was fixed within the cell. NOT counted as a defect here because it was found and fixed during the build phase. Documented in `database.ts` with an explanatory comment.

## Binary outcomes (pass/fail per tasks/t4-fitness-app/success-criteria.md)

- [x] **Builds in Expo Go** — confirmed running in Expo Go runtime on iOS 26.5 sim 2026-05-25 22:00 PT (cold-launch via openurl into freshly reinstalled Expo Go; physical-device run still untested but proxy is strong — same runtime container).
- [x] **Four lifts present** — Squat, Bench Press, Deadlift, Overhead Press all selectable in setup wizard (1RM entry) and present in the rotation (Squat → Bench verified live).
- [x] **Today's workout view on open** — lands on Today tab on cold start with no extra taps required. After Squat completion + app termination + relaunch: lands directly on Today showing Bench Press (rotation advanced AND view-on-open preserved).
- [x] **Set logging works** — logged 185×5, 215×5, 240×5+ for Squat via WeightStepper; all 3 sets persisted across in-session reload (verified via UI state — ✓ marks, "All sets logged.").
- [x] **History persists across app close + reopen** — full Expo Go terminate + reinstall + relaunch: Squat session 2026-05-25 10:08:42 PM still in History tab, including full set detail (185×5, 215×5, 240×5+).
- [x] **Program selection works** — wizard offers all three programs (5×5, 5×3, 5/3/1); selecting 5/3/1 propagates to Today screen ("5/3/1 · Week 1" header) and to history ("5/3/1" subtitle).
- [x] **Days/week selectable** — 3 / 4 toggle in wizard step 1; selected (4); persisted to DB (no negative observation).

**Pass count: 7 / 7**

---

# COST AXIS

## Raw metrics (from session-log.md + token-log.md)

| Metric | Value |
|---|---|
| Total tokens | ~102.3 M (Opus 102.2M + Haiku 0.1M) |
| Implied API cost | **$75.85** |
| Active wall-clock (excl. pauses) | **1 h 42 m 7 s** |
| API compute time (transparency) | 1 h 32 m 19 s |
| Operator-touch time | _ min (low — mostly autonomous w/ baseline approval gates) |
| Operator intervention count (unplanned) | 0 |
| Clarifying questions forwarded to PM | _ (TBD from session-log; expect 3-5 from BMAD's gap-batch — Working mode answered per config; Units + 3rd-program were product questions) |
| Time to first working build | _ s/m (build verified next session; not separately stopwatched in-cell) |

**Phase breakdown** (estimate; refine when session-log captures phase timestamps):
- Planning phases total (Analysis + Planning + Solutioning): ~35-40 min
- Implementation phase total (14 stories × ~5 min avg): ~60-65 min

## Derived ratios

| Ratio | Value | Cross-methodology rank |
|---|---|---|
| Quality per 1K tokens | 0.000515 | **Worst of 3** — Vibe 0.00414 (8×), Plan Mode ~0.00? |
| Quality per API hour | 34.1 | **Worst of 3** — Vibe 99.7, Plan Mode 114.9 |
| Defects per 1KLOC | 0.87 | **Best of 3** — Vibe 2.97, Plan Mode 1.16 |
| Methodology overhead ratio | ~0.55 | Highest of 3 (Vibe n/a, Plan Mode 0.31) |
| Cost per binary outcome | $10.84 | **Worst of 3** — Vibe $0.83 (13×), Plan Mode $1.11 |
| Quality per dollar | 0.69 | **Worst of 3** — Vibe 4.97 (7.2×), Plan Mode 5.59 |

---

# HEADLINE FINDING

```
Quality: 49.5 / 55  ·  Cost: $75.85 / 1h 42m  ·  Binary: 7 / 7 pass  ·  Defects: 0 / 1 / 3
```

**One-line verdict** (covering BOTH axes — revised after user-perspective review):

> **BMAD still delivers the highest quality of any methodology tested (+6 over Vibe Plan Mode, +20.5 over Vibe-pure) but at 10× Plan Mode's cost and 13× Vibe-pure's. The marginal $68 over Plan Mode bought engineering rigor (25 unit tests, versioned migrations, FR-N traceability, 1,500+ lines of planning) — but introduced a new Major UX defect (post-finish state confusion) AND missed a feature Vibe-pure invented from nothing (plate-per-side display). On the user-visible outcomes a real lifter cares about most, BMAD scored *below* Plan Mode despite the extra rigor. Planning quality ≠ product quality.**

---

## T4 four-way comparison (matched triad — same task, same brief, same operator, same model)

The first full matched triad in the eval. All three cells: vague T4 brief, Claude Opus 4.7, idb-verified live.

| | **Vibe-pure** | **Vibe Plan Mode** | **BMAD v6.8.0** |
|---|---|---|---|
| Quality | 29 / 55 | 43.5 / 55 | **49.5 / 55** (revised from 52.5) |
| Cost (implied API) | $5.84 | $7.78 | **$75.85** |
| Active time | 19m 45s | ~27m | **1h 42m** |
| Binary outcomes | 7 / 7 | 7 / 7 | 7 / 7 |
| Clarifying questions | 0 | 3 surfaced | (TBD; ≥3 batched) |
| Unplanned interventions | 0 | 0 | 0 |
| Methodology overhead ratio | n/a | 0.31 | ~0.55 |
| Defects (crit/maj/min) | 0/1/5 | 0/1/2 | **0/1/3** (revised) |
| Defects per 1KLOC | 2.97 | 1.16 | **1.74** (revised; worse than Plan Mode) |
| Quality per dollar | 4.97 | 5.59 | 0.65 |
| Cost per binary outcome | $0.83 | $1.11 | $10.84 |
| Spec articulation | 0 | 4.5 | 5 |
| Documentation | 2.5 | 3.5 | 5 |
| Code quality | 4 | 4.5 | 5 |
| System design | 3.5 | 4.5 | 5 |
| **UI design** | 4.5 | **5** | **4** (BMAD < Plan Mode) |
| **UX** | 3.5 | 4.5 | **3.5** (BMAD = Vibe-pure, < Plan Mode) |
| **Plate calculator** | **YES (built)** | NO | NO |
| Unit tests | 0 | 0 | **25 passing** |

**Where the +6 (Plan Mode → BMAD, revised) lives:** clustered in planning + ceremony dimensions (Spec articulation, Documentation +1.5, Code quality, System design, Assumption surfacing, Scope clarity), plus 25 unit tests reducing defect density.

**Where BMAD scored WORSE than Plan Mode:** UI design (Plan Mode 5 vs BMAD 4 — operator's gestalt + post-finish UX), UX (Plan Mode 4.5 vs BMAD 3.5 — post-finish state confusion in primary loop). Defect density 1.74 vs Plan Mode's 1.16 (added Major UX defect + plate-calculator feature miss).

**Where Vibe-pure beat BMAD outright:** plate-per-side display, which Vibe-pure invented from nothing and which BMAD planned away from despite 1,500+ lines of planning. **Less planning, more user insight in this one specific feature**.

**Headline interpretation for the writeup (revised):**

1. **Plan Mode buys ~80% of the user-visible value at ~10% of BMAD's cost.** The user-facing outcome (UI, UX, Functionality binary, all the things a real lifter notices in 30 seconds of use) is actually *better* at the Plan Mode tier than at the BMAD tier for this task. BMAD wins decisively on engineering rigor (tests, migrations, traceability) but loses on lived product.

2. **Planning quality is not the same as product quality.** BMAD's spec correctly predicted internal-implementation edge cases (deload trigger, AMRAP-feeds-e1RM, FR-16 progression-off-actual-weight) — but missed two user-visible things that Vibe-pure either built (plates) or that careful UX work should have caught (post-finish state). The discovery rigor that helped engineering didn't help product.

3. **The discovery-gap thesis cuts both ways.** BMAD's planning DID surface implementation edge cases Vibe-pure missed (defect density lead). But the planning ALSO narrowed feature insight by anchoring on what was explicitly in the brief — Vibe-pure's lower-planning approach generated a useful feature (plate math) by intuiting the spirit of "fast weight selector." For SDD methodologies, this is a real tension worth naming in the writeup: planning ≠ better product, especially on UX intuitive leaps.

This is the first headline finding ready for the writeup. Strong, counterintuitive, defensible.

---

## Scope-handling notes

How did BMAD engage with T4's four deliberate vague spots?

- **"plus one I haven't decided yet — pick one":** Picked **5/3/1** with explicit rationale in the PRD ("Wendler's classic, fits the user's intermediate-4-day pattern"). Documented in .decision-log for the brief artifact. *Compare*: Vibe-pure also picked 5/3/1 silently; Plan Mode picked 5/3/1 after asking.
- **"feel good to use mid-workout":** Engaged as a UX brief — dedicated UX DESIGN + EXPERIENCE artifacts; concrete affordances delivered (WeightStepper ±5/±2.5-on-hold; ConfirmButton with checkmark icon; tabular numerals; large tap targets ≥48dp; accessibility labels including hold-hints). NOT delivered: rest timer (real mid-workout absence). NFR-5 was stated but the timer wasn't included in v1 scope — a defensible decision but a real gap vs. "mid-workout" reality.
- **"see my progress over time":** Custom Progress tab with per-lift chips + LineChart (react-native-gifted-charts) + BEST SET + EST. 1RM (Epley) cards. AMRAP sets feed e1RM (FR-11/FR-18 explicit). *Compare*: Vibe-pure also built a chart (custom SVG); Plan Mode built a chart.
- **Auth / account / sync / sharing (never mentioned in brief):** Surfaced as **explicit non-goals** in PRD ("export-only in v1, NFR-1 offline-first/local-only — all functionality works with no network; no data leaves the device"). JSON export via OS share sheet is the safety net. *Compare*: Vibe-pure silently out-scoped; Plan Mode flagged as scoping question. **BMAD treated the absence as an active scope decision and documented why.**

## Failure mode characterization

- **Where did BMAD break down?** Did NOT break down end-to-end. Two minor defects discovered in scoring (dup-key warning, expo-router back-label leak) but no functional failures. Build log documents one mid-build defect (DB migration race) that was found via device smoke test and fixed within the cell — that's process working as intended.
- **Categories of mistake:** Polish/edge-case oversights (key uniqueness across React subtrees; default-label exposure). No architectural or logic defects.
- **What did it do surprisingly well:** (1) The DB layer architecture — versioned append-only migrations with the race-condition fix explained in source comments is genuinely senior-engineer thinking; (2) the FR-N reference convention in source comments + per-story build log creates a traceability matrix from brief → PRD → story → code; (3) the pure-engine + tests pattern made 25 unit tests trivial and locked the highest-risk logic; (4) the .decision-log per artifact captures the "why" that usually rots away.
- **Notable planning artifacts (BMAD-specific):** PRD (294 lines), Architecture (389 lines — separates concerns at module + dependency level), UX DESIGN (113) + UX EXPERIENCE (126) split as peer contracts (one for visual specs, one for user-flow narrative), Implementation Readiness Assessment (201 lines — gate before story drafting), 14 sharded story files + Build Log (per-story dev + code-review verdicts + FR coverage + variances). The Build Log alone is unprecedented operational documentation for a from-scratch cell.
- **Operator-tempted-but-didn't-intervene moments:** During the gap-batch (Working mode / Units / 3rd-program), operator answered "Fast" (methodology mode) per config without engaging on Coaching merits — could have been tempted to coach BMAD into better discovery. Didn't.

---

## Cell artifacts (preserve before cell-dir cleanup)

Path: `~/dev/sdd-bench-cells/t4-bmad-run-001/`

Key sub-trees to copy to `artifacts/code/` and `artifacts/planning/`:
- `strength-app/` — full app source (excluding node_modules, .expo, .git)
- `_bmad-output/planning-artifacts/` — PRD, architecture, UX, epics, readiness report, briefs, decision logs
- `_bmad-output/implementation-artifacts/` — build-log.md, sprint-status.yaml, 1-1-initialize-the-project-and-app-foundation.md (the one story file with detailed content)
- `_bmad/` config — record BMAD v6.8.0 with bmm + core modules only

Screenshots from idb walkthrough in `/tmp/t4-bmad-screens/` — copy 01 through 22 to `artifacts/screenshots/`.
