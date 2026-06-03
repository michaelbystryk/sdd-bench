# T4-rich (PM-quality brief) / Spec Kit / Run 003 / Token Capture (AUTOMATED ARM)

> Aggregated from `claude -p --output-format json` across 11 headless turns
> (`cell-headless.sh cost`). NOT a `/status` capture — headless automated arm.
> Source: `artifacts/turns/turn-001..011.json`.

## Raw counts (aggregated across all 11 phases)

### claude-opus-4-8 (primary)
| Metric | Value |
|---|---|
| Session input tokens | 20,052 |
| Session output tokens | 174,251 |
| Cached read tokens | 34,955,069 |
| Cached write tokens | 376,253 |
| Opus subtotal cost | $24.2857 |

### claude-haiku-4-5 (auxiliary)
| Metric | Value |
|---|---|
| Input | 6,296 |
| Output | 18 |
| Haiku subtotal | $0.0064 |

**Total API cost:** **$24.29**

## Time + phase summary

| Metric | Value |
|---|---|
| **API compute time (sum duration_api_ms)** | **0 h 37 m 37 s** (2,257,007 ms) |
| Internal agent turns (num_turns sum) | 156 |
| Headless drive turns (phases) | 11 |
| Phases | specify · clarify (5 Qs) · plan · tasks · implement |
| Clarifying questions to PM | **5** (all via pm-ask — see pm-convo.md) |
| Operator-touch / interventions | n/a (automated arm) |
| LOC produced (ts/tsx, excl node_modules) | ~5,164 |
| Source files (ts/tsx) | 98 |
| implement phase alone | 108 turns · $18.67 · 21.5 min |

## Methodology phase breakdown (overhead ratio input)

| Phase | turns | cost |
|---|---|---|
| specify (turn-001) | 8 | $0.88 |
| clarify scan (turn-002) | 2 | $0.18 |
| clarify integrate Q1-Q5 (turn-003..007) | 16 | $1.01 |
| plan (turn-008) | 18 | $2.01 |
| tasks (turn-009) | 4 | $1.53 |
| implement (turn-011) | 108 | $18.67 |
| **planning subtotal (specify→tasks)** | **48** | **$5.61** |
| **build (implement)** | **108** | **$18.67** |

Methodology overhead ratio (planning $ / build $) ≈ **0.30** (planning is ~23% of cell cost).

## Derived ratios (filled during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | ~0.30 (planning/build cost) |
| Cost per binary outcome | $_ |
| Quality per dollar | _ |

## vs run-003 vibe (same automated arm)

| Metric | vibe-003 | spec-kit-003 |
|---|---|---|
| API cost | $27.35 | **$24.29** |
| API time | 56.9 min | **37.6 min** |
| LOC | ~9,255 | **~5,164** |
| PM questions | 0 | **5** |
| Planning artifacts | post-hoc docs | spec.md + clarify + plan + tasks (pre-build) |

> spec-kit's clarify phase genuinely paused and asked 5 product questions
> (rounding rule, program-variant canon, onboarding seeding, training-day
> reconciliation, warm-up ramp) — all routed to the PM persona. Leaner build
> than vibe (5.2K vs 9.3K LOC) with real pre-build planning artifacts.
