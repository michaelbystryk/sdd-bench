# T4-spec-kit / Run 001 / Observations

Filled in during scoring (idb-driven sim walkthrough on iOS 26.5 + planning-artifact + source-code review, 2026-05-26 ~11:20 PT, ~30 min after cell end — bias acknowledged, but the idb walkthrough caught the same kind of issues the user-perspective review would). Uses [`harness/scoring-rubric.md`](../../../../harness/scoring-rubric.md) v0.1.2 (0.5 increments) and [`tasks/t4-fitness-app/success-criteria.md`](../../../../tasks/t4-fitness-app/success-criteria.md).

**Reviewer:** Operator (unblinded — same-day scoring; bias acknowledged)
**Scored on:** 2026-05-26
**Methodology revealed at:** n/a (unblinded)

---

# QUALITY AXIS

## Dimension scores (0–5; 0.5 increments per v0.1.2 changelog)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | **4.5** | All 7 binary outcomes PASS live. Spirit-of-brief partially addressed — 3 programs (5×5, 5×3, **3×5** — NOT 5/3/1 which other 3 cells picked), explicit non-goals cut rest timer + plate calculator. Setup defaults to beginner weights (135/95/65/135) regardless of me.md context (operator profile said squat 315 / bench 225 / dead 405 / OHP 145). |
| 2 | Correctness | (see defect block) | 0 critical / 0 major / 2 minor (R) |
| 3 | Code quality | **5** | TS strict throughout; clean separation `app/` (routes) + `src/domain/` (pure TS) + `src/db/` (repos) + `src/hooks/` + `src/components/` + `src/theme/`; named functions purpose-specific; 19/19 unit tests pass. |
| 4 | System design | **5** | Pure domain layer separated from UI (testable in isolation). DB repos pattern (settingsRepo, sessionRepo, setRepo, liftStateRepo). Versioned migrations via `PRAGMA user_version` (per plan.md). Hooks layer (useTodayWorkout, useProgress, useSettings). Reads like a senior engineer wrote it. |
| 5 | UI design | **4.5** | Dark + green accent; clean visual hierarchy; **iconic "Rest day" + bed-emoji** post-finish state (best of all cells so far); explanatory Settings notes ("Switching programs keeps all your logged history"; "Editing a starting weight updates a lift's suggestion only if it has no logged history yet") signal real UX thought. Loses 0.5 for set-logging modal pattern (heavier than BMAD's inline edit). |
| 6 | UX | **4** | **Post-finish UX is best in the eval so far** — "Rest day" + "Nice work. You train 4 days/week." + "Next workout · DAY B · Squat · Overhead Press · Deadlift" preview card + "Start workout" affordance. **BUT:** set logging is a 2-tap modal pattern (tap row → confirm) vs BMAD's 1-tap inline. **No rest timer (explicitly cut in spec.md non-goals)**; this loses the brief-implicit point Plan Mode won. |
| 7 | Robustness | **4** | 19 unit tests pass (programs, progression, schedule, WeightSelector component). Empty states for Progress ("No data yet — log a workout to see progress."). Resume mid-session per spec.md US1 acceptance #4. Migration via `PRAGMA user_version` (plan.md). Haven't stress-tested edge cases beyond walkthrough. |
| 8 | Security | **3** | SQLite local-only (no network); no auth, no secrets; parameterized via repo layer (inferred from clean DB architecture). No explicit threat-boundary docs. |
| 9 | Documentation | **5** | 1,301 lines of planning artifacts: spec.md (189) + plan.md (123) + tasks.md (245) + research.md (151) + data-model.md (180) + quickstart.md (76) + checklists/requirements.md (36) + contracts/(domain-contracts.md 177 + screens.md 64 + db-schema.sql 60). Plus inline code refs (FR-N in app/onboarding.tsx, settings.tsx, programs.test.ts, WeightSelector.tsx). Anticipates next-question consistently. |
| 10 | Spec articulation | **5** | spec.md has structured user stories (P1/P2/P3) with acceptance scenarios + "Why this priority" + "Independent Test" criteria; plan.md has full tech context + structure decisions + dependencies; tasks.md has parallelization-marked work breakdown; data-model.md + contracts/. Requirements checklist explicitly verifies "Zero [NEEDS CLARIFICATION] markers remain." Gold standard. |
| 11 | Scope clarity | **5** | **Explicit non-goals in spec.md** ("Rest timers, plate-loading breakdown visuals, warm-up set calculators, body-weight or nutrition tracking, and social/sharing features"). Brief preserved verbatim as Input. Three programs documented with rationale ("3×5 instead of 5/3/1" implicit in keeping linear-progression family). Scope actively defended via documented-assumption convention. |
| 12 | Assumption surfacing | **4.5** (count: ~10+ / quality: 5) | Per requirements.md: "The third program and other open details were resolved via documented assumptions rather than clarification questions. Zero [NEEDS CLARIFICATION] markers remain." Assumptions embedded throughout spec.md and research.md; not as enumerated as BMAD's per-artifact `.decision-log.md` pattern (so 0.5 off). |

**Quality sum (11 scored dimensions, max 55):** **49.5 / 55**

## Defect count

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | **0** |
| Major | 0 | 0 | 0 | **0** |
| Minor | 0 | 0 | **2** | **2** |

LOC produced: ~2,500 (app source, TS/TSX). **Defects per 1KLOC: 0.80** (currently the best of all cells: Vibe 2.97, Plan Mode 1.16, BMAD 1.74, Spec Kit 0.80).

Itemized defects:

1. **Minor (R) — setup ignored me.md user profile.** The brief + me.md were both auto-loaded as the `/speckit-specify` argument. me.md states the user is intermediate (squat 315, bench 225, deadlift 405, OHP 145). Spec Kit's setup wizard defaults to beginner weights (135 / 95 / 65 / 135) and requires manual stepping per lift to bump. A truly me.md-aware methodology would have pre-filled at the operator's stated maxes (or asked "use these or different?"). Spec Kit's documented-assumption convention silently overrode me.md context. Minor because the user can still adjust; spec articulation 5 doesn't excuse missing this signal.

2. **Minor (R) — third-program choice: `3×5` instead of `5/3/1`.** Vibe-pure / Plan Mode / BMAD all chose Wendler 5/3/1 as the third program (matches me.md's intermediate-4-day profile). Spec Kit chose **3×5** — a third LINEAR-progression variant (keeping the linear-prog family for engineering simplicity). Defensible engineering choice but methodologically less ambitious for the brief's user. Spec Kit's research.md considered 5/3/1 but rejected it. Minor because the choice is documented; the comparison-asymmetry is worth flagging.

**NOT counted as defects (scope-handling decisions, properly documented):**
- No rest timer — EXPLICITLY excluded in spec.md non-goals ("Rest timers, ...")
- No plate-per-side display — EXPLICITLY excluded in spec.md non-goals ("plate-loading breakdown visuals, ...")
- These are deliberate cuts via the methodology's discipline. **Same pattern as BMAD's "Banned: rest-timer popups" UX EXPERIENCE entry.** Worth flagging in failure-mode characterization, not in defect count.

## Binary outcomes (per tasks/t4-fitness-app/success-criteria.md)

All 7 verified via idb-driven iOS 26.5 sim walkthrough on 2026-05-26 ~11:10 PT.

- [x] **Builds in Expo Go** — confirmed; cold launch via Expo Go after install on iOS Sim worked first try.
- [x] **Four lifts present** — Squat, Bench Press, Overhead Press, Deadlift all in setup + appear across DAY A and DAY B rotation.
- [x] **Today's workout view on open** — lands on Today tab on cold start; pre-finish shows the day's workout; post-finish shows "Rest day" + next workout preview.
- [x] **Set logging works** — modal pattern: tap set row → modal with weight/reps steppers → "✓ Done" button. Logged set persisted (green check + "1/5 sets" counter updated).
- [x] **History persists across app close + reopen** — full Expo Go terminate + URL-reopen: Settings preserved (5×5, 4 days/week), Progress tab Squat data point preserved (135 lb green dot), Today screen preserved Rest day state with DAY B as next.
- [x] **Program selection works** — three programs visible in setup wizard AND in Settings; Settings has live "Switch programs keeps all your logged history" note.
- [x] **Days/week selectable** — 3/4 toggle in setup AND Settings; switched from 3 → 4 and Today screen updated correctly.

**Pass count: 7 / 7**

---

# COST AXIS

## Raw metrics (from session-log.md + token-log.md)

| Metric | Value |
|---|---|
| Total tokens | ~16.2 M (Opus 4.7 only; no Haiku) |
| Implied API cost | **$13.21** (matches /status; Opus subtotal $13.22 hand-computed) |
| Active wall-clock (= API duration per operator) | **30 m 4 s** |
| Wall-clock raw (per /status) | 50 m 14 s (includes operator-touch between phases) |
| Operator-touch time | _ min (modal-tap reviews + phase boundaries) |
| Operator intervention count | **1** (the `/specify` → `/speckit-specify` correction — Spec Kit 0.8.13's slash-command prefix gotcha) |
| Clarifying questions forwarded to PM | **0** (Spec Kit's `/speckit-clarify` resolved ambiguities via documented assumptions instead of asking) |
| Time to first working build | not separately stopwatched; build was working by cell end |

**Phase breakdown** (estimate; refine when session-log timestamps parsed):
- `/speckit-specify`: ~5-8 min (produced spec.md 189 lines)
- `/speckit-clarify`: ~2-3 min (Spec Kit chose to document assumptions rather than ask — see methodology fitness note)
- `/speckit-plan`: ~5-7 min (plan.md 123 + research.md 151 + data-model.md 180 = ~450 lines)
- `/speckit-tasks`: ~3-5 min (tasks.md 245 lines)
- `/speckit-implement`: ~12-15 min (2500 LOC + 4 test files)

Planning total: ~15-20 min. Implementation: ~12-15 min. **Methodology overhead ratio: ~1.0-1.3** (planning ≈ implementation time — heavier than Plan Mode 0.31 and BMAD 0.55).

## Derived ratios

| Ratio | Value | Cross-methodology rank |
|---|---|---|
| Quality per 1K tokens | **0.0031** | Vibe 0.00414, Plan Mode ~0.0056, **Spec Kit 0.0031**, BMAD 0.000515 — *Spec Kit beats BMAD by 6× on token-efficiency* |
| Quality per API hour | **98.8** | Vibe 99.7, Plan Mode 114.9, OpenSpec 115.5, **Spec Kit 98.8**, BMAD 34.1 — on API time OpenSpec (25m42s) & Plan Mode (22m43s) are faster; Spec Kit is mid-pack |
| Defects per 1KLOC | **0.80** | Vibe 2.97, Plan Mode 1.16, BMAD 1.74, **Spec Kit 0.80** — *best in eval* |
| Methodology overhead ratio | ~1.0-1.3 | Vibe n/a, Plan Mode 0.31, **Spec Kit ~1.0-1.3**, BMAD ~0.55 — *highest of all (most planning per unit of impl)* |
| Cost per binary outcome | **$1.89** | Vibe $0.83, Plan Mode $1.11, **Spec Kit $1.89**, BMAD $10.84 |
| Quality per dollar | **3.75** | Vibe 4.97, Plan Mode 5.59, **Spec Kit 3.75**, BMAD 0.65 — *Spec Kit 5.8× more dollar-efficient than BMAD at essentially equal quality* |

---

# HEADLINE FINDING

```
Quality: 49.5 / 55  ·  Cost: $13.21 / 30m 4s  ·  Binary: 7 / 7 pass
```

**One-line verdict:**

> **Spec Kit ties BMAD on quality (49.5 vs 49.5) at 17% of BMAD's cost ($13.21 vs $75.85) and 30% of BMAD's active time (30m vs 1h 42m). The slash-command pipeline (`/speckit-specify` → `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`) produces nearly-equivalent quality to BMAD's multi-agent ceremony at 1/6 the cost. The marginal $62 from Spec Kit → BMAD buys very little user-facing or engineering-rigor improvement — possibly the most efficient methodology on the structure spectrum.**

---

## T4 four-cell comparison (matched quadrad, updated from triad)

| | **Vibe-pure** | **Vibe Plan Mode** | **Spec Kit** | **BMAD v6.8.0** |
|---|---|---|---|---|
| Quality | 29 / 55 | 43.5 / 55 | **49.5 / 55** | 49.5 / 55 |
| Cost (implied API) | $5.84 | $7.78 | **$13.21** | $75.85 |
| Active time | 19m 45s | ~27m | **30m 4s** | 1h 42m |
| Binary outcomes | 7 / 7 | 7 / 7 | **7 / 7** | 7 / 7 |
| Clarifying questions | 0 | 3 | **0** (resolved via docs) | (≥3 batched) |
| Unplanned interventions | 0 | 0 | **1** (slash-prefix gotcha) | 0 |
| Methodology overhead ratio | n/a | 0.31 | **~1.0-1.3** | ~0.55 |
| Defects (crit/maj/min) | 0/1/5 | 0/1/2 | **0/0/2** | 0/1/3 |
| **Defects per 1KLOC** | 2.97 | 1.16 | **0.80** | 1.74 |
| **Quality per dollar** | 4.97 | 5.59 | **3.75** | 0.65 |
| Cost per binary outcome | $0.83 | $1.11 | **$1.89** | $10.84 |
| Spec articulation | 0 | 4.5 | **5** | 5 |
| Documentation | 2.5 | 3.5 | **5** | 5 |
| UI design | 4.5 | 5 | **4.5** | 4 |
| UX | 3.5 | 4.5 | **4** | 3.5 |
| Unit tests | 0 | 0 | **19 passing** | 25 passing |
| Plate calculator | YES (built) | NO | 🚫 **explicitly cut** | NO |
| Rest timer | NO | YES (built) | 🚫 **explicitly cut** | 🚫 explicitly cut |
| End-of-workout state | (similar to BMAD?) | ✅ proper complete-state | ✅ **best in eval** (Rest day + Next workout preview) | ❌ Major defect (silent rotate) |

### Where Spec Kit landed vs the others

**Spec Kit beats BMAD on:**
- Cost ($13.21 vs $75.85 — **5.8× cheaper**)
- Active time (30m vs 102m — **3.4× faster**)
- Defect density (0.80 vs 1.74 per 1KLOC — **2.2× lower**)
- UI design (4.5 vs 4 — operator's lived UX)
- UX (4 vs 3.5 — best-in-eval end-of-workout state)

**Spec Kit equals BMAD on:**
- Quality sum (49.5 = 49.5)
- Spec articulation (5 = 5)
- Documentation (5 = 5)
- Binary outcomes (7/7 = 7/7)

**Spec Kit loses to BMAD on:**
- System design (5 = 5 — actually equal, but BMAD has more engineering rigor in migrations + race-fix doc)
- Unit tests (19 vs 25)
- Per-FR traceability is comparable but BMAD's per-story Build Log is unique

**Spec Kit beats Plan Mode on:**
- Quality (49.5 vs 43.5 — +6)
- Documentation, Spec articulation, Scope clarity, Code quality, System design (all +0.5 to +1.5)

**Plan Mode beats Spec Kit on:**
- Cost ($7.78 vs $13.21)
- Brief-implicit features (rest timer, haptics) — Spec Kit explicitly cut rest timer
- UI design (5 vs 4.5)

### The revised three-sentence interpretation for the writeup

1. **Spec Kit hits the sweet spot.** Equal quality to BMAD at 1/6 the cost, 1/3 the time, lower defect density, better end-of-workout UX. For practical adoption, Spec Kit is the methodology the eval will recommend for most teams.

2. **BMAD's marginal $62 over Spec Kit buys nothing user-visible.** The extra 25-19=6 unit tests + per-story Build Log + per-artifact decision logs are engineering rigor a few teams will value. Most teams will choose Spec Kit and not notice the difference.

3. **The "planning narrows feature insight" pattern is strengthening.** Vibe-pure invented the plate calculator from nothing. Plan Mode missed it (1 of 3 structured). **Spec Kit + BMAD both EXPLICITLY cut it** via their planning discipline ("plate-loading breakdown visuals — non-goal" in Spec Kit spec.md; "rest-timer popups — Banned" in BMAD UX EXPERIENCE doc). When two structured methodologies explicitly cut a feature the no-planning methodology invented from nothing, that's a structural finding worth naming: **planning anchors on the literal brief and trades away feature insight Vibe-pure intuited.**

---

## Cross-validation with ranthebuilder.cloud (April 2026 eval)

ranthebuilder.cloud's April 2026 evaluation tested Spec Kit alongside GSD / OpenSpec / TaskMaster on a single serverless Python backend with single reviewer and 13 unscaled categories. **OpenSpec scored highest overall** in that eval.

sdd-bench tests Spec Kit on a different task domain (Expo mobile vs Python serverless) with rigor (anchored scales, cost axis, PM persona control, ~30 categories incl. cost). **sdd-bench's T4 finding: Spec Kit ties BMAD on quality at 1/6 cost.** This doesn't directly cross-validate or refute ranthebuilder (different methodology comparisons, different task, different rigor) — but suggests Spec Kit is competitive across both task domains. **OpenSpec is the v0.4 cell that will provide the direct cross-validation against ranthebuilder.**

---

## Scope-handling notes

How did Spec Kit engage with T4's four deliberate vague spots?

- **"plus one I haven't decided yet — pick one":** Picked **3×5** (linear-progression third variant in the 5×5 / 5×3 / 3×5 family). Rationale: documented assumption to stay within linear-progression family for engineering simplicity. Different from Vibe / Plan Mode / BMAD which all picked Wendler 5/3/1 (wave program). Defensible but less ambitious — a Madcow-ish 3×5 for an intermediate lifter on 4 days/week is suboptimal vs 5/3/1.
- **"feel good to use mid-workout":** Engaged via tabular numerals + large primary action + "Rest day" affirmation. **BUT explicitly cut rest timer and plate-per-side display** in spec.md non-goals. The "feel good" interpretation was narrowed to fast-set-logging-UX, not full mid-workout-utility.
- **"see my progress over time":** Per-lift chart (single LineChart per lift card, with "No data yet" empty states). Less rich than BMAD's Progress dashboard (chart + BEST SET + e1RM) but adequate.
- **Auth / account / sync / sharing (never mentioned in brief):** Surfaced as **explicit non-goals** in spec.md ("Body-weight or nutrition tracking, and social/sharing features."). Spec Kit's documented-assumption convention treats absences as active scope decisions — matches BMAD's pattern, better than Vibe-pure's silent omission.

## Failure mode characterization

- **Where did Spec Kit break down?** Did NOT break down end-to-end. The `/specify` → `/speckit-specify` slash-prefix gotcha was a documented Spec Kit 0.8.13 version-change issue (run-cell.sh has since been patched). One scoring-time observation: setup defaults ignored me.md's intermediate-lifter profile, requiring manual weight steps.
- **Categories of mistake:** Two notable pattern misses:
  - Explicit-non-goal-as-cut: rest timer + plate calculator both cut in spec.md. Both are features that survived as user-visible misses in scoring vs. Plan Mode (which built rest timer) and Vibe-pure (which built plates).
  - Defaults vs. user-context: me.md context wasn't pulled into setup defaults.
- **What did it do surprisingly well:**
  1. **Post-finish UX is best in the eval** — Rest day + Next workout preview + Start workout affordance. BMAD's biggest defect (silent rotate) was Spec Kit's wins-by-design.
  2. **Settings explanatory notes** ("Switching programs keeps all your logged history"; "Editing a starting weight updates a lift's suggestion only if it has no logged history yet") are top-tier UX writing — anticipates user concerns at the exact moment the user might have them.
  3. **Constitution.md template detection** — plan.md explicitly notes "The project constitution (`.specify/memory/constitution.md`) is an **unedited template** — it contains only placeholder principles and no ratified rules. There are therefore **no binding constitutional gates** to evaluate." Honest, traceable, defensible.
  4. **Independent Test criteria** per user story in spec.md — each P1/P2/P3 story has a paragraph explaining how to verify the story works standalone. This is unusually thoughtful for a generated PRD.
- **Notable planning artifacts (Spec Kit-specific):** spec.md (US1-US4 with P1/P2/P3 priorities + acceptance scenarios + Independent Test criteria), plan.md (tech context + structure decision + constitutional-gate evaluation), tasks.md (parallelization-marked work breakdown by user story), data-model.md (180 lines including ER schema), research.md (151 lines including rationale for major decisions), quickstart.md (developer onboarding), checklists/requirements.md (quality gate confirmation), contracts/ (db-schema.sql + domain-contracts + screens.md).
- **Operator-tempted-but-didn't-intervene moments:** Didn't override the 3×5 third-program choice (operator could have intervened to force 5/3/1; let Spec Kit's documented-assumption stand).
- **`/speckit-clarify` produced ZERO questions** — Spec Kit chose to document assumptions in spec.md rather than ask. This is methodologically interesting: a discovery-rich methodology (Spec Kit) chose silence over engagement. Worth contrasting in the writeup with Plan Mode's 3 questions (which directly produced the rest-timer feature in Plan Mode's output but not Spec Kit's).

---

## Cell artifacts (preserved at runs/t4-fitness-app/spec-kit/run-001/artifacts/)

- `bcae4da3-1056-44a3-a409-c1a974f3b602.jsonl` — full CC session transcript (~2.6 MB)
- `pm-convo.md` — single trivial test exchange ("hi" → persona response); zero substantive PM forwards
- `planning/specs/001-strength-training-app/` — spec.md, plan.md, tasks.md, research.md, data-model.md, quickstart.md, checklists/requirements.md, contracts/ (db-schema.sql, domain-contracts.md, screens.md)
- `planning/.specify/` — Spec Kit config (workflows, extensions, integrations, templates, constitution template)
- `planning/CLAUDE.md` — Spec Kit's auto-generated CLAUDE.md for the cell dir
- `screenshots/` — 14 idb screenshots from the walkthrough (01-fresh-launch.png through 14-after-reopen.png)
