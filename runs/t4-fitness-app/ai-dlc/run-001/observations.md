# T4-ai-dlc / Run 001 / Observations

idb-driven Expo Go walkthrough on iOS 26.5 (iPhone 17 Pro sim) + planning-artifact + source review, 2026-05-27. Uses [`harness/scoring-rubric.md`](../../../../harness/scoring-rubric.md) v0.1.2 (0.5 increments) and [`tasks/t4-fitness-app/success-criteria.md`](../../../../tasks/t4-fitness-app/success-criteria.md).

**Reviewer:** Operator (unblinded — same-day; bias acknowledged)
**Scored on:** 2026-05-27
**Methodology revealed at:** n/a (unblinded)

> **Cell facts.** AI-DLC v0.1.8 (awslabs) run on **Claude Code (claude-opus-4-7)** — so model + token measurement match the other 5 cells (single-tool/single-model hexad). Vague T4 brief, **Expo Go** runtime. Cell dir `~/dev/sdd-bench-cells/t4-ai-dlc-run-001`; transcript `…/t4-ai-dlc-run-001/cdfe9adc-….jsonl` (2.25 MB, 547 events).
> **Two fidelity notes that shape interpretation:**
> 1. **Autonomous mode.** Operator authorized "always take the recommended option, do not stop at approval gates" after the first requirements round. AI-DLC's signature dense gating (a "DO NOT PROCEED" gate at nearly every stage) was therefore **collapsed to ~1 operator round + autonomous execution** — so we do NOT observe its gating cost as operator-touch. The token cost is high regardless (below).
> 2. **Property-Based Testing extension = ENABLED (partial), per AI-DLC's recommendation.** Eval policy = *take each methodology's recommendations* (use the tool as a real user would). **Only AI-DLC offers/recommends PBT** — Spec Kit / OpenSpec / BMAD / Plan Mode don't surface it at all — so PBT is a **genuine methodology difference, not a cross-cell confound, and is scored as earned.** (This supersedes the `ai-dlc.md` "decline extensions for parity" line, which would have tested a hobbled AI-DLC no real user would produce.) Security extension was also offered; its recommendation was *skip*, so it's off.

---

# QUALITY AXIS

## Dimension scores (0–5; 0.5 increments)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | **4.5** | All 7 binary outcomes PASS live. Canonical 5×5 / 5×3 (+5 upper / +10 lower, deload ×0.9 after 3 fails) **and** 5/3/1 (TM = 90% 1RM, 4-week wave, AMRAP top set, TM bump after deload week) — verified live (squat 235 = round(0.75×315); OHP 5/3/1 wk1 85–110 = 0.65/0.85×130) + 15 tests. **Honored me.md** (FR-7 pre-fills 315/225/405/145, default 4-day). Chose **5/3/1**. e1RM (Epley) on Progress. Cut rest timer / warm-up (documented §9). |
| 2 | Correctness | (see defect block) | 0 critical / 0 major / 1 minor (R). Clean walkthrough — no redbox; logging, persistence, program-switch, progression math all correct. |
| 3 | Code quality | **4.5** | TS strict (tsc clean); clean layering data→domain→services→ui→state; **pure progression engine** (no I/O, single source of truth for "next weight"); fast-check PBT; named/JSDoc'd. 15 tests pass. (Held at 4.5 vs 5: deep-read the domain — excellent — but did not line-read all of db/repositories/services/screens.) |
| 4 | System design | **5** | Layered (NFR-14); pure domain isolated from I/O; **prescriptions derived not stored**; per-(program,lift) state retained so switching resumes; SQLite + immediate commit; e1RM as cross-program metric. application-design docs (components/services/methods/dependency) back it. |
| 5 | UI design | **4.5** | Dark high-contrast; display-size weight numerals; plate-aware stepper (−45/−25/−5/+5/+25/+45) with large targets; **inline editor, no modal** (NFR-4); glanceable Today + Setup. e1RM trend chart. −0.5: chart sparse (single-point); no completion/celebration polish; **no plate-per-side display**. |
| 6 | UX | **4** | Hits most mid-workout affordances: large targets (≥44pt, NFR-2), dark, next-working-weight precomputed, ~1-tap log (Done, or tap→edit→Log set), inline (no modal), resume "Continue workout · 1/10 sets logged". **But:** plate-loading math still on the user (no per-side display), no keep-awake, no rest timer. Nets even with Spec Kit / OpenSpec. |
| 7 | Robustness | **4.5** | **Only cell with property-based testing** (fast-check: progression math, plate-load round-trips, storage round-trips) — covers input ranges example tests miss. Deterministic engine (NFR-12); immediate persistence (verified kill+reopen); resume in-progress session; weights rounded to loadable. The PBT edge is **earned** — AI-DLC is the only methodology that scaffolds property-based testing (the others don't offer it). |
| 8 | Security | **3** | Local-only SQLite, no network/auth/secrets (NFR-10); parameterized repo layer. Security extension declined. Same posture as the other Claude Code cells. |
| 9 | Documentation | **5** | **1,842 lines** of aidlc-docs: requirements (27 FR + 15 NFR + assumptions + out-of-scope), user-stories + personas, application-design (components/services/methods/dependency), functional-design (business-rules/entities/frontend-components), nfr-requirements + tech-stack-decisions, nfr-design, build-and-test instructions (×4) + summary, code-summary, + `aidlc-state.md` + `audit.md` (full audit trail) + inline JSDoc. Comparable to Spec Kit (1,301) / BMAD (1,456). |
| 10 | Spec articulation | **5** | `requirements.md` is gold-standard: intent-analysis table, **27 numbered FRs + 15 NFRs**, data requirements, PBT requirements, **§8 Assumptions & Decisions**, **§9 explicit Out-of-Scope**, me.md usage. Plus user-stories + personas + application-design. The AI-DLC delta artifacts ARE the spec and they're excellent. Ties Spec Kit / BMAD. |
| 11 | Scope clarity | **5** | §9 Out-of-Scope explicitly lists rest timer, warm-up auto-calc, accessory lifts, data export, accounts/sync/social, custom programs — "explicitly excluded now to respect the locked brief." "Scope is the 5 capabilities — not expanding it." Strong discipline. |
| 12 | Assumption surfacing | **4.5** (count: 6 asked + ~12 documented / quality: high) | **Surfaced 6 clarification questions** at the Requirements gate (third program, units, progression, weight selector, + 2 extension opt-ins) — *more than any other cell* — AND documented §8 Assumptions + the audit trail. Below BMAD's 5 only because the operator answered "all recommendations" (low engagement) and §8 is less systematic than BMAD's per-artifact logs. |

**Quality sum (11 scored dimensions, max 55):** **49.5 / 55**

> A clean 4-way tie at the top (OpenSpec = Spec Kit = BMAD = AI-DLC = 49.5). Robustness 4.5 is earned via AI-DLC's property-based testing — the only methodology that scaffolds it; not discounted.

## Defect count

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | **0** |
| Major | 0 | 0 | 0 | **0** |
| Minor | 0 | 0 | 1 | **1** |

LOC produced: **~2,350** (src + App.tsx, TS/TSX non-blank). **Defects per 1KLOC: ~0.4.** Coverage: build, set logging, persistence/resume, program switch, progression math, Progress, **workout-finish (advances cleanly to the next day with progression applied — see below), and edit-of-a-logged-set (✅ re-tap re-opens the editor)** all verified live. Not exercised: a full 3-session deload sequence (covered by code + unit tests) and PR celebration (not in the vague brief). Single run.

Itemized:
1. **Minor (R) — plate-per-side computed + PBT-tested but never surfaced in the UI.** `weightMath.platesPerSide()` exists and is round-trip tested, but no screen renders it — the workout/log screens show only the total ("235 lb"), so the lifter still does the plate-loading math that me.md explicitly asked to remove. AI-DLC got *closer* than any other structured cell (it wrote + tested the per-side function) but left it unwired — same end-user outcome as OpenSpec. Counted to match the OpenSpec/BMAD treatment of the missing plate display.

**NOT counted (documented scope cuts, §9):** rest timer, warm-up auto-calc, accessory lifts, data export, haptics, keep-awake — all explicitly excluded in `requirements.md §9` to respect the locked brief.

## Binary outcomes (per success-criteria.md) — 7 / 7

- [x] **Builds in Expo Go** — cold launch via Expo Go, iOS bundle 5.0s (1,114 modules), zero redbox across the session.
- [x] **Four lifts present** — squat/bench/OHP/deadlift in Setup (pre-filled) + across the rotation.
- [x] **Today's workout view** — opens to Today with prescribed sets + precomputed weight.
- [x] **Set logging works** — tap weight → plate-aware stepper → "Log set" (or "Done" at prescribed); set flips to ✓.
- [x] **History persists** — kill + reopen: restored to Today, "Day 1 · 1/10 sets logged", logged set in Progress "Recent sets"; in-progress session resumed ("Continue workout").
- [x] **Program selection works** — 3 programs (5×5/5×3/5/3/1) in Setup AND Programs tab; switched 5×5→5/3/1 live, Today re-prescribed (TM wave) correctly; "Switching programs keeps all your logged history."
- [x] **Days/week selectable** — 3/4 toggle in Setup + Programs (default 4 per me.md).

---

# COST AXIS

## Raw metrics (from the operator's `/status` capture of the AI-DLC build session — authoritative)

| Metric | Value |
|---|---|
| Total tokens | **~21.3 M** (in 9.5K + out 187.2K + cache-read 20.4M + cache-write 679.3K) |
| Implied API cost | **$19.15** (Opus 4.7 rates; matches `/status`) |
| Model | claude-opus-4-7 (single model across the hexad) |
| API compute time | **not captured** (no /status paste survived); active 34 m 53 s transcript / 38 m 30 s stopwatch; wall-clock 2 h 33 m (incl. idle) |
| Operator interventions | ~0 (1 requirements round, then autonomous; "all recommendations") |
| Clarifying questions surfaced | 6 (at the Requirements gate) — answered "all recommendations" via claude.ai, logged in pm-convo.md |

## Derived ratios

| Ratio | Value | Cross-methodology rank |
|---|---|---|
| Quality per 1K tokens | **~0.0023** | OpenSpec 0.0085 · Plan Mode 0.0056 · Vibe 0.0041 · Spec Kit 0.0031 · **AI-DLC 0.0023** · BMAD 0.00052 |
| Quality per API hour | **≥ 85** (floor; 49.5 / 0.581 h transcript-active, API ≤ active) | between Spec Kit (98.8) and BMAD (34.1) |
| Defects / 1KLOC | ~0.4 (floor) | lowest observed, but light count |
| Methodology overhead ratio | ~1.0 (Inception ≈ Construction; not separately stopwatched) | — |
| Cost per binary outcome | **$2.74** ($19.15 / 7) | Vibe $0.83 · OpenSpec $1.02 · Plan Mode $1.11 · Spec Kit $1.89 · **AI-DLC $2.74** · BMAD $10.84 |
| **Quality per dollar** | **2.59** | OpenSpec 6.91 · Plan Mode 5.59 · Vibe 4.97 · Spec Kit 3.75 · **AI-DLC 2.59** · BMAD 0.65 — 5th of 6, but far above BMAD |

---

# HEADLINE FINDING

```
Quality: 49.5 / 55  ·  Cost: $19.15 / ~34m 53s active (API compute n/a)  ·  Binary: 7 / 7 pass
```

**One-line verdict:**

> **AI-DLC ties the quality leaders (49.5, a 4-way tie with OpenSpec / Spec Kit / BMAD) at moderate cost ($19.15) — mid-pack: pricier than Spec Kit ($13.21), far cheaper than BMAD ($75.85). OpenSpec still ships the same 49.5 for ~40% the cost (~2.7× efficiency gap), so AI-DLC isn't the value pick — but it's nowhere near BMAD's expensive tail. It honored me.md (pre-filled 315/225/405/145, picked 5/3/1) and is the only structured cell to even *write* the per-side plate calculator — but left it unwired, so the lifter still does plate math. It's also the only methodology that scaffolds property-based testing (a genuine robustness strength). The standout product of a thorough, well-documented, gated workflow — at a price that's reasonable, not punishing.**

## Cross-cell context (completes the hexad)

Quality converges: **4 of 6 methodologies tie at 49.5** (OpenSpec, Spec Kit, BMAD, AI-DLC); Vibe 29, Plan Mode 43.5 below. **Cost spans 13×:** Vibe $5.84 · OpenSpec $7.16 · Plan Mode $7.78 · Spec Kit $13.21 · **AI-DLC $19.15** · BMAD $75.85. The finding: **four methodologies deliver identical 49.5 quality across a 13× cost range** — structure converges on quality; the methodology you pick determines cost, not ceiling. OpenSpec is the efficiency frontier (~2.7× cheaper than AI-DLC for the same quality); BMAD is the lone expensive tail; AI-DLC sits mid-pack.

## Scope-handling notes (vague-brief vague spots)

- **"plus one … pick one":** picked **5/3/1 (Wendler)**, justified for an intermediate (matches the pentad majority; Spec Kit was the lone 3×5).
- **"feel good mid-workout":** engaged as a first-class requirement (NFR-1..4); fast plate-aware stepper, inline logging, ≥44pt targets. But stopped at the working weight — **plate-loading math not surfaced**, no keep-awake.
- **"see progress over time":** per-lift **e1RM trend chart + recent-sets history**, aggregated across programs (FR-23/24). Logged set surfaced immediately (better than OpenSpec).
- **auth/sync/sharing:** explicit Out-of-Scope (§9) + NFR-10. Surfaced as a scoping decision.

## Failure-mode characterization

- **me.md honored** (2nd structured cell after OpenSpec): FR-7 pre-fills the exact maxes; setup defaults to 4-day. Spec Kit ignored the same profile.
- **Built the plate calculator** (`platesPerSide`, PBT round-trip tested) — the feature only Vibe-pure surfaced and every other structured cell cut/missed. **But never wired to the UI**, so the user-facing "no plate math" outcome is the same miss as OpenSpec. The closest a structured methodology has come to the plate calculator — and still short at the UI.
- **Mid-pack on cost ($19.15).** Pricier than Spec Kit ($13.21), far cheaper than BMAD ($75.85). The gated multi-stage workflow + 25 KB rule set re-read every turn (20.4 M cache-read tokens of ~21.3 M total) + 1,842 doc lines make it token-heavy — but well short of BMAD's expensive tail.
- **Gating not observed:** autonomous authorization collapsed AI-DLC's defining "DO NOT PROCEED" gates — so its operator-touch cost is unmeasured here (a fidelity gap; a strict run would clear ~10 gates).
- **Did surprisingly well:** the requirements artifact (27 FR + 15 NFR + assumptions + out-of-scope) is among the best specs in the eval; property-based tests are a genuine (if deviation-sourced) robustness asset; the app is clean and correct.
