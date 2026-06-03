# T4-rich (PM-quality brief) / GitHub Spec Kit / Run 001 / Observations

**Reviewer:** claude-sonnet-4-6 (autonomous scoring agent)
**Scored on:** 2026-05-29
**Evidence basis:** CODE-BASED (no sim this pass) — tsc --noEmit exit 0, npm test exit 0 (58/58 pass), full source review, planning-artifact review
**Methodology revealed at:** n/a (unblinded pass — PROVISIONAL per v0.2)

---

# QUALITY AXIS

## Dimension scores (0–5 per harness/scoring-rubric.md)

| # | Dimension | Score | One-line evidence |
|---|---|---|---|
| 1 | Functionality | 2.0 | All 7 programs prescribe + progress correctly (code-verified); plate calc, e1RM, warmup, recommendation all verified by 58/58 passing tests; but no Expo app, no UI, no persistence, no rest timer, no logging screen — roughly half the brief's required behavior missing |
| 2 | Correctness | (see defect block below) | |
| 3 | Code quality | 4.5 | Idiomatic TypeScript throughout; intentional names, tight type discipline, no dead code except a trivial no-op filter in primitives.ts:181; teammate could land changes in 30 min; small surprises of skill in shared primitive abstractions (straightSets, percentSets, seedTrainingMax reduce 7 programs to data + tiny functions) |
| 4 | System design | 4.5 | Strict three-layer split (domain/data/services) declared in plan.md and fully executed in domain layer; ProgramDefinition interface enforces open-closed principle across all 7 programs; data model in data-model.md is complete, normalized, stretch-ready; boundaries documented with rationale; reads like a senior engineer designed it |
| 5 | UI design | n/a | No UI shipped (methodology declared pure domain only) |
| 6 | UX | n/a | No UI shipped |
| 7 | Robustness | 3.5 | Greedy plate-fill handles all edge cases (empty bar, inexact, unowned plates, countPerSide limits) — code-verified; programs handle stall/deload/stage-cascade; warm-up skips redundant sets; no-op AMRAP filter in primitives.ts:181 is latent (functionally correct in context but logically dead); Madcow resets on first failure not after repeat (minor canon deviation) |
| 8 | Security | 3.0 | Pure domain functions — no untrusted input surface in shipped code; no secrets, no network, no file paths; data boundary design in plan.md correctly externalizes persistence; deductions: no input validation on weight values (negative, NaN, Infinity not guarded in plates.ts or metrics.ts) |
| 9 | Documentation | 3.0 | CLAUDE.md correctly points to plan artifacts; per-file header comments are present and accurate (FR references, intent, source URLs); quickstart.md is a solid onboarding doc; no README.md at repo root; decision records are in plan.md/research.md (planning artifacts) — scored only on shipped docs per rubric |
| 10 | Spec articulation | 5.0 | spec.md produces 38 FRs, 12 SCs, 6 user stories with full BDD acceptance scenarios, edge case catalog, and key entities; coverage is complete against all brief sections; spec correctly predicts implementation edge cases (inexact plate loads, AMRAP sets, warm-up exclusion from PRs, program switching with history preservation) that all materialize in the domain code — real foresight demonstrated |
| 11 | Scope clarity | 4.5 | In-scope (domain layer, 7 programs, all core domain functions) and out-of-scope (Expo shell, native services, persistence layer, UI) are explicitly stated with the rationale ("unverifiable without iOS simulator"); the 85-task task list is bucketed by phase and story priority (P1/P2/P3); 26/85 tasks marked complete with explanation; scope was actively defended with a coherent technical argument in the session transcript; would earn a 5 if scope had been revisited mid-session rather than declared once upfront |
| 12 | Assumption surfacing | count: 9 explicit / quality: 4.0 | spec.md §Assumptions: 9 named assumptions each identifying the choice and citing the FR that depends on it (e.g. "One active program / all seeded → FR-005", "PR/e1RM source: working sets only → FR-033/034"); research.md identifies contested variants (nSuns, GZCLP) and records the decision with alternatives considered; plan.md records why Drizzle over raw SQL; categorization into technical/product/user is implicit (not labelled) — would be 5 with explicit categories |

**Quality sum: 34.0 / 45** (UI+UX n/a — no app shipped; scored out of 45 per spec-kit pure-domain variant)

Product polish (Func+UI+UX+Robust): 2.0 + n/a + n/a + 3.5 = **5.5 / 20 (n/a dims excluded: effectively /10)**
Engineering rigor (Code+SysDes+Sec+Doc+Spec+Scope+Assump): 4.5+4.5+3.0+3.0+5.0+4.5+4.0 = **28.5 / 35**

---

## Defect count (correctness, reported separately)

| Severity | Tests (T) | Manual (M) | Review (R) | Total |
|---|---|---|---|---|
| Critical | 0 | 0 | 0 | 0 |
| Major | 0 | 0 | 0 | 0 |
| Minor | 0 | 0 | 2 | 2 |

**LOC produced (shipped code only, src + tests):** 2,284 TS lines (3,401 net per token-log including planning artifacts)

**Defects per 1KLOC:** 0.88 / 1KLOC (2 minor / 2.284)

**Defect itemization:**

1. [Minor / R] `primitives.ts:181` — `results.filter((r) => !r.isAmrap || true)` is a no-op filter (always true); likely intended to filter AMRAP sets from the success check in applyLinearProgression, but has no effect. Functionally harmless given callers' behavior but signals copy-paste or incomplete refactor.

2. [Minor / R] `madcow.ts:122` — `stallCount >= 1` triggers an immediate 95% reset on first Friday failure; Madcow canonical convention is to repeat the week first, then reset. The `stallCount` variable is incremented but always trips the condition on the next evaluation, making the counter functionally useless. Minor deviation from pinned Madcow canon.

---

## Binary outcomes (pass/fail per task success-criteria.md)

| # | Outcome | Result | Evidence |
|---|---|---|---|
| 1 | Core app builds + runs as a dev build | FAIL | Methodology declared complete via documented refusal to write unverifiable Expo shell; no app.json, no expo scaffold, no native build attempted |
| 2 | Onboarding works | FAIL | No Expo app / no screens; onboarding logic exists only in spec.md user stories and tasks.md T041-T049 (unimplemented) |
| 3 | Four lifts present | PASS | code-verified: types.ts:3-14 declares squat/bench/deadlift/ohp as LiftId variants; MAIN_LIFTS array at types.ts:16; all 7 programs prescribe these lifts |
| 4 | Today's workout on open | FAIL | No Expo app / no screen; engine.ts prescribe() exists and is tested but not wired to any UI |
| 5 | Set logging works (1-tap common case) | FAIL | No UI; no persistence layer implemented (T027-T039 unimplemented) |
| 6 | Plate calculator | PASS | code-verified: plates.ts breakdown() greedy-fill, inventory respect, closest-loadable, isEmptyBar — 58/58 including 7 plate tests |
| 7 | Rest timer | FAIL | No restTimer.ts shipped; plan.md contracts/rest-timer.md fully specifies it; T031 not implemented |
| 8 | Backgrounded rest alert (both platforms) | FAIL | No native code; methodology explicitly excluded unverifiable native surface |
| 9 | Quick-switch survives | FAIL | No app shell; session state (T030) not implemented |
| 10 | Warm-up ramp | PASS | code-verified: warmup.ts warmupRamp() — empty-bar start, %ramp, deadlift fewer sets, all isWarmup:true; 3/3 warmup tests pass |
| 11 | 7 programs, correct progression | PASS (domain-only) | code-verified: all 7 definitions in src/domain/programs/definitions/; 7 program test suites pass (13 test files, 58 tests); progression logic per pinned canon verified; minor Madcow stall deviation noted (minor) |
| 12 | Flexible scheduling (3–6 days) | PASS | code-verified: meta.minDays/maxDays in each ProgramDefinition; recommend() filters by frequency; PPL hardcoded 6-day (ppl.ts:18-20); nsuns supports 4-6 days |
| 13 | History persists + History screen | FAIL | No persistence layer (T007-T016 unimplemented); no History screen |
| 14 | Progress + PRs | FAIL (partial) | PR detection code-verified in metrics.ts (detectPRs, e1rmTrend, sessionVolume); Progress screen not implemented (T035-T039 unimplemented) |

**Pass count: 5 / 14** (outcomes 3, 6, 10, 11, 12 — all domain-layer verifiable)

---

# COST AXIS

## Raw metrics (from token-log.md)

| Metric | Value |
|---|---|
| Total tokens | ~14.6M (385K input+output + 13.97M cache) |
| Implied API cost | **$14.01** |
| API compute time (scored) | **37m 50s** |
| Active session time (context) | ~42m |
| Wall-clock incl. operator idle (context) | 42m 33s |
| Operator-touch time | ~3 min (phase drives only) |
| Operator intervention count | 0 unplanned (1 asked question re: commit scope → operator confirmed) |
| Time to first working build | N/A (no Expo build attempted) |

**Phase breakdown (from session timeline — estimated from transcript timestamps):**
- /speckit-specify (16:00-16:06): ~6m
- /speckit-plan (16:06-16:19): ~13m (incl. 2 parallel research sub-agents)
- /speckit-tasks (16:19-16:24): ~5m
- /speckit-analyze (16:24-16:26): ~2m
- /speckit-implement (16:26-16:40): ~14m
- /speckit-git-commit (16:43-16:44): ~1m
- Planning phases total: ~26m | Implementation: ~14m

## Derived ratios

| Ratio | Value | Notes |
|---|---|---|
| Quality per 1K tokens (of output tokens) | 34.0 / 177.3 = **0.192** | Uses output tokens (177.3K) as denominator |
| Quality per API hour | 34.0 / 0.630 = **54.0 / hr** | 37m50s = 0.630h |
| Defects per 1KLOC | **0.88** | 2 minor / 2.284 KLOC |
| Methodology overhead ratio | ~26m planning / ~14m impl = **1.86×** | Planning-heavy by design |
| Cost per binary outcome | $14.01 / 5 = **$2.80** | 5 outcomes pass |
| Quality per dollar | 34.0 / 14.01 = **2.43** | |

---

## Paired-Δ vs run-002 (comparator)

| Metric | run-001 (with-runtime) | run-002 (no-runtime) | Δ | Δ% |
|---|---|---|---|---|
| Implied API cost | $14.01 | $30.10 | +$16.09 | +115% |
| API compute time | 37m 50s | 1h 10m 26s | +32m 36s | +86% |
| Net LOC | 3,401 | 7,342 | +3,941 | +116% |
| Quality sum | 34.0 / 45 | (comparator unscored) | — | — |
| Binary outcomes | 5 / 14 | (comparator unscored) | — | — |
| Quality per dollar | 2.43 | — | — | — |

**Cost-Δ interpretation (hard data):** run-001's $14.01 is 114% cheaper than run-002's $30.10 — almost exactly proportional to the 116% LOC difference. The methodology's cost-discipline mechanism was the domain-only scope-cut, not structural efficiency. When run-002 removed verifiability uncertainty (no-runtime brief), Spec Kit shipped proportionally more code at proportionally more cost. The "Spec Kit is cheapest" finding from run-001 is a behavioral artifact of scope-refusal, not a stable cost baseline.

---

# HEADLINE FINDING

```
Quality: 34.0 / 45  ·  Cost: $14.01 / 0h 38m API compute  ·  Binary: 5 / 14 pass
(Quality out of /45 — UI+UX n/a, pure domain only; binary fails = no app shipped)
```

**One-line verdict:**

> Spec Kit on T4-rich produced the strongest planning artifacts and cleanest domain logic of the hexad ($14.01 cost, 58/58 tests, zero critical/major defects) but adaptively refused to build the unverifiable Expo shell — trading breadth for correctness, yielding 5/14 binary outcomes and a quality score biased entirely toward rigor (28.5/35) over product (5.5/10), making it the methodology that delivered the most trustworthy foundation at the cost of zero shippable product.

---

## Failure mode characterization

**Where did Spec Kit break down?**
The methodology's deliberate scope-narrowing ("write it blind against SDK-56-specific APIs would produce a large unverifiable surface") is not a breakdown — it is a documented methodology characteristic. The *consequence* is that 9/14 binary outcomes fail because no app exists to exercise them. The real constraint is the methodology's internal verifiability gate: Spec Kit refuses to ship code it cannot unit-test, and a full Expo app cannot be unit-tested without a running simulator.

**Categories of outcome:**
- Domain layer (programs, plate calc, metrics, warmup, recommend): fully implemented, tested, zero defects found in review
- Persistence layer (SQLite repositories, schema, migrations): planned in detail (data-model.md, tasks T007-T016), not implemented
- Native services (rest timer, notifications, keep-awake, haptics): contracted (contracts/rest-timer.md), not implemented
- UI/screens: planned with file-level task breakdown, not implemented

**What did it do surprisingly well:**
1. Planning artifacts are near-exceptional: spec.md covers 38 FRs with full BDD acceptance criteria; research.md pins canonical sources for all 7 programs (resolving contested nSuns/GZCLP variants); contracts/ define exact interfaces for 4 modules; data-model.md produces a production-grade schema with normalization rationale.
2. The ProgramDefinition interface is the kind of abstraction that absorbs extension without modification — adding an 8th program requires only one new data file.
3. 18 web searches (via Haiku subagent) produced a comprehensive research pass that correctly identified the contested variants and pinned the correct ones; this level of research would be a stretch for vibe-mode.
4. 0 critical, 0 major defects — exceptionally clean domain core.

**Notable planning artifacts:**
- `specs/001-compound-strength-app/research.md`: Best-in-class research output; pinned 7 program canonical sources, identified alternatives considered, resolved the nSuns percentage ambiguity with a note to pull from the pinned spreadsheet.
- `specs/001-compound-strength-app/data-model.md`: Complete, normalized, stretch-ready schema with explicit validation rules and history-preservation design.
- `specs/001-compound-strength-app/contracts/`: 4 precise module contracts that exactly predict the domain implementation.
- `specs/001-compound-strength-app/spec.md`: 240-line functional spec with 9 assumptions, 12 SCs, 38 FRs — equivalent to a solid PRD.

**Operator-tempted-but-didn't-intervene moments:**
Session transcript shows the methodology self-identified the scope issue and made the judgment call autonomously. Operator did not redirect when Spec Kit declared domain-only scope — consistent with methodology evaluation protocol (let the methodology express its characteristic behavior).

**Methodology-as-signal:**
The run-001 vs run-002 paired-Δ reveals the mechanism: Spec Kit's cost (and breadth) is gated by its verifiability stance, not by the brief's richness. A runtime-constrained environment triggers the domain-only refusal; a no-runtime brief removes the trigger and Spec Kit ships at full proportional cost.
