# T4-openspec / Run 001 / Observations

Filled in during scoring (idb-driven sim walkthrough on iOS 26.5 + planning-artifact + source-code review, 2026-05-26 ~13:25 PT). Uses [`harness/scoring-rubric.md`](../../../../harness/scoring-rubric.md) v0.1.2 (0.5 increments) and [`tasks/t4-fitness-app/success-criteria.md`](../../../../tasks/t4-fitness-app/success-criteria.md).

**Reviewer:** Operator (unblinded — same-day scoring; bias acknowledged)
**Scored on:** 2026-05-26
**Methodology revealed at:** n/a (unblinded)

> **Layout note (read first).** This cell ran as a git worktree of the Spec Kit cell. The **code** lives at `~/dev/sdd-bench-cells/t4-openspec-run/` (branch `001-strength-training-app-openspec`, untracked working tree). The **OpenSpec planning artifacts** live at `~/dev/sdd-bench-cells/t4-spec-kit-run-001/openspec/changes/strength-training-app/` (the OpenSpec session ran with that cwd). The OpenSpec session transcript is `…/t4-spec-kit-run-001/f6f1a515-1501-4f20-9dd0-14694dfae92a.jsonl` (1.24 MB, 332 opsx/openspec mentions). OpenSpec genuinely ran: `/opsx:propose` + `/opsx:apply` slash commands fired; `openspec` CLI (status/validate/change/new/apply) used; opsx skills installed globally. **The `/opsx:archive` phase never finalized** — see failure-mode notes.

---

# QUALITY AXIS

## Dimension scores (0–5; 0.5 increments per v0.1.2 changelog)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | **4.5** | All 7 binary outcomes PASS live. Encodes canonical 5×5 (+5 upper/+10 lower, deload→90% after 3 fails) **and** canonical 5/3/1 (4-week wave 65/75/85→70/80/90→75/85/95→deload, top set AMRAP, TM bump on cycle complete) — verified live AND by 9 progression unit tests. Chose **5/3/1** (profile-appropriate) and pre-filled me.md's exact maxes (315/225/405/145, default 4-day), fixing both of Spec Kit's profile misses; eliminates *progression* math (next prescription weight precomputed). e1RM cross-scheme trends. **But leaves *plate-loading* math to the user** — shows total weight (270 lb), no per-side breakdown, despite me.md's explicit "no math mid-workout" — plus cuts rest timer / haptics / keep-awake like the other structured cells. (Held at 4.5 vs Spec Kit: same plate gap, but OpenSpec fixed the profile + program misses Spec Kit had.) |
| 2 | Correctness | (see defect block) | 0 critical / 0 major / 3 minor (M/R) |
| 3 | Code quality | **5** | TS strict (tsc clean); textbook layering `app/` routes + `src/domain/` (pure TS) + `src/db/` (repos) + `src/hooks/` + `src/components/` + `src/theme/`; uniform `prescribe`/`advance` scheme abstraction so UI never special-cases a program; centralized rounding util; race-guard (`inFlight` ref) against double-session creation; thorough JSDoc on every module; 24/24 tests pass. ~1,800 LOC does what Spec Kit needed ~2,500 for — more elegant. |
| 4 | System design | **5** | Pure domain isolated from I/O; **prescriptions derived, never stored** (immutable logged sets + per-(program,lift) state row) so they can't drift; versioned SQLite schema (WAL, FK ON, cascade, indexes, `user_version`) with idempotent on-launch migration; history immutable & queried across all programs; rotation advances on completion, resumes open session. design.md argues each choice with alternatives-considered. Senior-level. |
| 5 | UI design | **4.5** | Dark high-contrast palette explicitly "readable at a glance in a bright gym"; `HIT_TARGET=64pt` (well above 44); display-size weight numeral; two-rate ±5/±25 stepper; **inline-expand set editor — no modal** (meets the success-criteria 5-signal Spec Kit *missed* with its modal); Finish button turns green when all sets logged. Loses 0.5 for no post-completion state / no plate-per-side visual. |
| 6 | UX | **4** | Hits **5 of 6** success-criteria mid-workout affordances (large targets, dark default, next-weight-precomputed, single-tap increments, one-handed bottom controls — only screen-stay-awake missing). Set logging is 1-tap-to-open inline (better than Spec Kit's modal). **BUT:** finishing a workout **silently rotates** to the next session with no confirmation / rest-day state — the exact affordance Spec Kit won on and BMAD was dinged for. No rest timer. Nets even with Spec Kit. |
| 7 | Robustness | **4.5** | 24 unit tests (> Spec Kit 19; < BMAD 25) incl. table-driven deload/wave/TM-bump + `liftSucceeded` null-handling; **explicit concurrency guard** against mount+focus double-session race; idempotent migrations; weight clamped to empty-bar floor; resume-in-progress-session; empty states on Progress. Persistence survived kill+reopen live. −0.5: no DB-error handling in the UI layer; Finish is tappable with sets unlogged. |
| 8 | Security | **3** | SQLite local-only, no network/auth/secrets; all repo SQL parameterized (`?` placeholders); FK integrity on; design Non-Goals explicitly scope out network/auth/sync. No dedicated threat-boundary doc. Same local-only posture as Spec Kit / Plan Mode (3); below BMAD (4, explicit threat docs). |
| 9 | Documentation | **4.5** | 630 lines of planning artifacts (proposal 54 + design 147 + tasks 68 + six capability spec deltas 361) — ~half of Spec Kit's 1,301 by design ("delta specs stay compact"), but the design.md is the richest engineering-reasoning artifact in the eval and inline JSDoc is heavier than Spec Kit's. −0.5 vs Spec Kit's 5: no quickstart / research / contracts artifacts, and the canonical `specs/` was never populated (archive didn't run). |
| 10 | Spec articulation | **5** | proposal.md (Why / What Changes / 6 Capabilities / Impact) + **design.md** (Context / Goals / Non-Goals / Decisions-each-with-alternatives / Data-model / Risks / Migration / Open-Questions) + six capability deltas each with WHEN/THEN acceptance scenarios (e.g. "WHEN 5 reps @ 315 lb logged THEN e1RM ≈ 367"). The delta-spec set IS the spec and it is gold-standard. Ties BMAD's PRD (5) and beats Plan Mode's plan (4.5). |
| 11 | Scope clarity | **5** | design.md Goals/Non-Goals explicitly scopes OUT auth/sync/multi-user, kg/custom-plates/custom-programs, accessory lifts/supersets/**rest timers**/warm-ups, and non-Expo-Go native modules. Proposal Impact repeats "no backend, no auth, no sync." Third-program choice justified against the user profile. Scope actively defended. Ties Spec Kit / BMAD. |
| 12 | Assumption surfacing | **4.5** (count: ~12 / quality: 5) | Enumerated Non-Goals + an explicit **"Open Questions"** section that names 2 unresolved items *and states its lean* (baseline-capture wording; 5/3/1 cycle-week on a 3-day split) + Decisions-with-alternatives. Used the me.md profile as a stated assumption. Documented rather than forwarded to PM (0 clarifying Qs — same as Spec Kit). Below BMAD's per-artifact decision-log systematicity (5). |

**Quality sum (11 scored dimensions, max 55):** **49.5 / 55**

## Defect count

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | **0** |
| Major | 0 | 0 | 0 | **0** |
| Minor | 0 | 3 | 1 | **4** |

LOC produced: **~2,000** (src+app, TS/TSX total lines; 1,801 non-blank; ~2,180 incl. tests). **Defects per 1KLOC: ~2.0** (Vibe 2.97, **OpenSpec ~2.0**, BMAD 1.74, Plan Mode 1.16, Spec Kit 0.80 best).

Itemized defects:

1. **Minor (M) — finishing a workout silently rotates with no completion feedback.** Tapping "Finish workout" instantly replaces the screen with the *next* session (Squat 3/3 → Bench Press 0/3) with no toast, summary, or rest-day state. Behaviorally correct (rotation-advances-on-completion is a documented design decision; Progress confirms the save), and it lands on a *clear* next workout rather than an ambiguous one — so milder than BMAD's "silent rotate" major, but it is the precise affordance Spec Kit nailed and OpenSpec lacks. *(Open question for operator: minor vs major — see below.)*

2. **Minor (M/R) — switching program OR changing days/week silently discards the in-progress session's already-logged sets.** Both `switchProgram` and `changeDays` call `deleteOpenSessions()` (cascade-deletes the open session + its sets). Reproduced live: logged Squat 280×5 under 5×5, switched to 5/3/1, the set vanished from Progress. Completed history is genuinely never touched, so the Settings copy "Switch anytime — your logged history is kept" is *technically* true — but a user who has logged sets in an unfinished session would reasonably read it as a promise those sets survive. Claim-vs-behavior gap for in-progress data.

3. **Minor (R) — "Finish workout" is tappable with sets unlogged, no guard.** The button is greyed (not green) until all sets are logged, but remains pressable; completing early records unlogged sets as `reps=null` → `liftSucceeded` returns false → counts a *failed* session and can advance the deload counter on data the user never entered. Edge case (requires tapping the greyed button), mitigated by the affordance.

4. **Minor (M) — no plate-per-side display; plate-loading math left to the user.** The app shows the *total* prescribed weight (e.g. "270 lb") but never the per-side breakdown (45+45+10+5+2.5/side for 270). me.md *explicitly* states "I don't want to think about math mid-workout" — and computing plates is the most concrete between-sets math an intermediate lifter does at these loads. `plates.ts` exposes only `BAR_WEIGHT` + step constants + rounding; there is no `platesPerSide()`. Counted (not treated as a documented cut) because — unlike Spec Kit, which explicitly cut "plate-loading breakdown visuals" in its non-goals — OpenSpec's design scoped only the plate *model* ("standard plates, 45 lb bar") and never excluded the *visual*, making this a silent miss. **Same severity treatment as BMAD's identical miss (1 minor R).** Sharpest "planning narrows feature insight" instance in the pentad: OpenSpec is the one cell that demonstrably *ingested* me.md (it pre-filled the exact maxes) yet still didn't connect "no math mid-workout" to the plate calculator only Vibe-pure built.

**NOT counted as defects (documented scope decisions):**
- No rest timer — EXPLICITLY in design.md Non-Goals. Same deliberate cut as Spec Kit + BMAD.
- No haptics, no keep-awake — not in scope; absences, not bugs.
- Default onboarding program is 5×5 while design recommends 5/3/1 for this lifter — a defensible default (all three offered); not a defect.

## Binary outcomes (per tasks/t4-fitness-app/success-criteria.md)

All 7 verified via idb-driven iOS 26.5 sim walkthrough on 2026-05-26 ~13:10–13:26 PT (15 screenshots).

- [x] **Builds in Expo Go** — clean cold launch; iOS Metro bundle 4.35s (1,496 modules); zero redbox/yellowbox in the Metro log across the whole session.
- [x] **Four lifts present** — Squat, Bench Press, Overhead Press, Deadlift all in onboarding (pre-filled 315/225/145/405) and mapped across rotation days (Squat day 1 → Bench Press day 2 confirmed live).
- [x] **Today's workout view** — lands on Today tab post-onboarding showing the day's prescribed sets with weight precomputed.
- [x] **Set logging works** — tap set → inline weight stepper (±5/±25) + rep stepper → "Log set"; stepped 270→280, logged, badge turned green, counter advanced.
- [x] **History persists (kill + reopen)** — full Expo Go terminate + URL-reopen: logged set (280×5) survived AND the in-progress session resumed (no duplicate; onboarding skipped). Completed-session history later surfaced on Progress (Squat 280 lb e1RM = 240×5).
- [x] **Program selection works** — three programs (5×5, 5×3, **5/3/1**) selectable in onboarding AND Settings; switched 5×5→5/3/1 live, Today re-prescribed correctly (TM 285: 185/215/240-AMRAP).
- [x] **Days/week selectable** — 3/4 toggle in onboarding AND Settings; default 4 (per me.md).

**Pass count: 7 / 7**

---

# COST AXIS

## Raw metrics (from token-log.md + transcript timestamps)

| Metric | Value |
|---|---|
| Total tokens | ~5.808 M (in 6.2K + out 132.6K + cache-read 5.5M + cache-write 169.3K) |
| Implied API cost | **$7.16** (matches /status) |
| Active wall-clock (API duration) | **25 m 42 s** |
| Wall-clock raw (per /status) | 1 h 8 m 39 s (incl. operator step-away after cell complete) |
| Proposal phase (`/opsx:propose`) | ~25 m wall (18:43:13 → 19:08:09 first `/opsx:apply`) |
| Apply phase (`/opsx:apply`) | ~26 m wall (19:08:09 → 19:34:15 last activity) |
| Archive phase (`/opsx:archive`) | **never finalized** (changes/archive/ + canonical specs/ both empty) |
| Operator-touch time | ~0 min (single auto-launched `/opsx:propose`; no mid-run interventions) |
| Operator intervention count | **0** (1 task — 10.2 hands-on Expo Go walkthrough — honestly deferred to the user) |
| Clarifying questions forwarded to PM | **0** (documented assumptions + Open-Questions section instead, like Spec Kit) |
| Time to first working build | not separately stopwatched; bundle builds clean by cell end |

## Derived ratios

| Ratio | Value | Cross-methodology rank |
|---|---|---|
| Quality per 1K tokens | **0.00852** | Vibe 0.00414, Plan Mode ~0.0056, Spec Kit 0.0031, BMAD 0.000515 — **OpenSpec best in eval (lowest token count of any cell + top quality)** |
| Quality per API hour | **~115.5** | Vibe 99.7, Plan Mode 114.9, Spec Kit 98.8, BMAD 34.1 — **co-leads with Plan Mode (114.9)** |
| Defects per 1KLOC | ~1.5 | Vibe 2.97, BMAD 1.74, **OpenSpec ~1.5**, Plan Mode 1.16, Spec Kit 0.80 (best) |
| **Methodology overhead ratio (proposal / (apply + archive))** | **~0.95** (wall-clock; archive did not run) | Plan Mode 0.31, BMAD ~0.55, **OpenSpec ~0.95**, Spec Kit ~1.0–1.3. Proposal ≈ apply by wall-clock — *not* as lightweight as OpenSpec's billing implies (rich design.md + 6 deltas). Caveat: per-phase **active** time not separately stopwatched; true active ratio likely lower (apply did the 1,800-LOC + token-heavy generation). |
| Cost per binary outcome | **$1.02** | Vibe $0.83, **OpenSpec $1.02**, Plan Mode $1.11, Spec Kit $1.89, BMAD $10.84 |
| **Quality per dollar** | **6.91** | Vibe 4.97, Plan Mode 5.59, Spec Kit 3.75, BMAD 0.65 — **OpenSpec best in eval** |

---

# HEADLINE FINDING

```
Quality: 49.5 / 55  ·  Cost: $7.16 / 25m 42s  ·  Binary: 7 / 7 pass
```

**One-line verdict:**

> **OpenSpec ties the quality leaders (49.5 = Spec Kit = BMAD) at the lowest cost and lowest token count of any cell in the eval ($7.16 / 5.8 M tok / 25.7 min), making it the most cost-efficient methodology measured — best quality-per-dollar (6.91), per-hour (~115), and per-token (0.0085). It used me.md where Spec Kit ignored it (exact maxes pre-filled, 4-day default, profile-justified 5/3/1) and built the cleanest, most compact codebase in the eval — yet it still leaves *plate-loading* math to the user (no per-side display, despite me.md's explicit "no math mid-workout"), silently rotates after finishing a workout, carries a higher defect density than Spec Kit (~2.0 vs 0.80 / 1KLOC), and never ran its own archive phase. The cost-efficiency champion, but not the defect-density or product-polish one.**

---

## Cross-validation with ranthebuilder.cloud (April 2026 eval)

OpenSpec scored #1 in the ranthebuilder.cloud 13-category eval on a single Python serverless backend feature with a single reviewer. This T4 cell tests whether that ranking holds on a different domain (Expo mobile), a different ambiguity profile (medium complexity / high ambiguity), and higher-rigor scoring (anchored scales + cost axis + PM-persona control).

Findings:
- **Confirm / refute the ranking: CORROBORATES (with nuance).** OpenSpec lands at the very top of the 5-cell distribution on quality (tied 49.5/55 with Spec Kit and BMAD) and is the **outright #1 on every cost-efficiency ratio in the eval** (quality/$, quality/hr, quality/1K-tok), at the lowest absolute spend of any structured cell. On a fundamentally different task domain with stricter scoring, OpenSpec reproduces "excellent, compact, efficient" — the exact ranthebuilder thesis ("delta specs keep each document compact and reviewable").
- **Where it lands in the distribution:** quality co-leader (3-way tie at the top); clear cost-efficiency leader. The nuance ranthebuilder's single-reviewer/single-task setup couldn't surface: OpenSpec **ties rather than strictly beats** Spec Kit on quality — Spec Kit edges it on defect density (0.80 vs ~1.5) and post-finish UX; OpenSpec wins on cost, user-context-honoring, and code compactness. So "OpenSpec is #1" becomes, under anchored multi-axis rigor, "OpenSpec is a quality co-leader and the cost-efficiency champion" — a genuine reinforcement of the signal, not a refutation.
- **Notable strengths observed:** richest engineering-reasoning artifact in the eval (design.md decisions-with-alternatives); honored operator context; most elegant/compact code; cheapest structured run.
- **Notable weaknesses observed:** silent-rotate post-finish; switch-drops-in-progress-sets vs the "history kept" copy; the three-phase state machine did not complete (archive never finalized).

## Scope-handling notes

T4's four deliberate vague spots:
- **"plus one I haven't decided yet — pick one":** Raised explicitly and picked **5/3/1**, justified in design.md *by the operator's stated numbers* ("for an intermediate already at bench 225 / squat 315 / dead 405 / OHP 145, pure linear progression stalls quickly; 5/3/1 is the canonical next step"). Most defensible third-program reasoning of any cell — and the only one that ties the choice to me.md. (Spec Kit picked the safer 3×5 and ignored me.md.)
- **"feel good to use mid-workout":** Engaged as a genuine UX brief, not flavor text — design.md names it "the defining constraint" and derives concrete decisions from it (64pt targets, two-rate stepper not keypad/wheel, gym-readable dark palette, inline no-modal logging). 5 of 6 rubric affordances delivered. **But the engagement stopped at the prescription weight: it eliminated progression math, not plate-loading math** — the user still computes plates per side, the most concrete mid-workout math, which me.md explicitly asked to remove. Plus no post-completion feel-good moment.
- **"see my progress over time":** Chose **chart + table** (per-lift SVG e1RM trend line, requires ≥2 sessions, with a recent-history list of best sets) and a common cross-program metric (Epley e1RM) so 5×5 and 5/3/1 days are comparable. Rationale documented.
- **Auth / account / sync / sharing (never in brief):** Surfaced as an **explicit scoping call** — design.md Non-Goals and proposal Impact both state "no accounts, auth, networking, cloud sync, multi-user." Treated absence as an active decision (matches Spec Kit/BMAD; better than Vibe's silent omission).

## Failure mode characterization

- **Where did OpenSpec break down?** Two user-facing UX gaps (silent-rotate post-finish; mid-session program/day switch silently dropping logged sets while the copy promises history is kept) and one process gap: **the `/opsx:archive` phase never finalized** — `openspec/changes/archive/` and the canonical `openspec/specs/` are both empty, so the delta specs were never merged into the canonical record. Per the methodology config the cell should end when archive completes; here proposal ✓ + apply ✓ (38/39 tasks, the 39th being the hands-on walkthrough honestly deferred to the user) but archive ✗. Deliverable is fully functional regardless.
- **What did it do surprisingly well:**
  1. **Used me.md (partially)** — onboarding pre-fills the exact operator maxes (315/225/405/145) and defaults to 4-day; design.md *reasons about the profile* to pick 5/3/1. Sharp contrast with Spec Kit, which defaulted to beginner weights and ignored the profile — the biggest differentiator vs Spec Kit. **Caveat (the flip side):** having demonstrably ingested me.md, OpenSpec *still* didn't build the plate calculator that me.md's "no math mid-workout" most directly calls for — so the honoring was of the profile *numbers*, not the profile's *intent*. This makes OpenSpec the cleanest evidence in the pentad that planning narrows feature insight: the context was read and used, and the feature was still missed.
  2. **Cheapest structured run in the eval** at top-tier quality — the "compact delta specs → fewer tokens → lower cost" thesis held empirically (5.8 M tokens, lowest of any cell, incl. Vibe).
  3. **Concurrency-aware code** — the `inFlight` race guard against mount+focus double-session creation is a sophistication most cells didn't show.
  4. **Correct, table-tested progression math** for both linear and 5/3/1 (live-verified: 5×5 squat 270 = round(0.85×315); 5/3/1 TM 285 → 185/215/240-AMRAP; Bench TM 205 → 135/155/175).
- **Proposal-phase clarifying questions surfaced?** Zero forwarded to PM (same as Spec Kit). OpenSpec resolved ambiguity via documented Non-Goals + an explicit Open-Questions section (which *names* its uncertainties and states a lean) rather than asking — methodologically the same "document, don't ask" stance as Spec Kit, but with a cleaner dedicated surface for it.
- **Three-phase discipline benefits / costs:** The proposal discipline clearly produced the strong design (the alternatives-considered reasoning is what drove the good 5/3/1 + storage + immutable-history decisions). But the discipline was **not fully followed through** — archive never ran — and the proposal phase was *not* the lightweight step its billing implies (wall-clock proposal ≈ apply). Net: the discipline bought quality; the "lightweight" claim is only half-true on time.

---

## Cell artifacts (preserved at runs/t4-fitness-app/openspec/run-001/artifacts/)

- OpenSpec planning artifacts: `openspec/changes/strength-training-app/` — proposal.md (54), design.md (147), tasks.md (68, 38/39 checked), specs/{program-catalog, progress-tracking, progression, training-schedule, weight-selector, workout-session}/spec.md (630 lines total). *(Physically under the t4-spec-kit-run-001 worktree-root; see layout note.)*
- `screenshots/` — idb walkthrough (01-fresh-launch → 18-progress-populated): onboarding w/ me.md pre-fill, Today 5×5, weight selector, set logged, kill+reopen persistence, Settings program switch, Today 5/3/1, all-sets-logged, post-finish rotation, populated Progress.
- Session transcript: `…/t4-spec-kit-run-001/f6f1a515-1501-4f20-9dd0-14694dfae92a.jsonl` (1.24 MB).
