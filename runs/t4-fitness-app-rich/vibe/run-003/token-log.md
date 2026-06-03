# T4-rich (PM-quality brief) / Vibe Claude Code / Run 003 / Token Capture (AUTOMATED ARM)

> Captured from `claude -p --output-format json` (single drive turn; aggregated
> by `cell-headless.sh cost`). NOT a `/status` capture — headless automated arm.
> Source of truth: `artifacts/turns/turn-001.json`.

## Raw counts (from claude -p JSON)

### claude-opus-4-8 (primary, effort: high)
| Metric | Value |
|---|---|
| Session input tokens | 34,061 |
| Session output tokens | 272,502 |
| Cached read tokens | 33,965,781 |
| Cached write tokens | 540,381 |
| Opus subtotal cost | $27.3431 |

### claude-haiku-4-5 (auxiliary)
| Metric | Value |
|---|---|
| Input | 6,291 |
| Output | 17 |
| Haiku subtotal | $0.0064 |

**Total API cost (total_cost_usd):** **$27.35**

## Time + intervention summary

| Metric | Value |
|---|---|
| **API compute time (sum duration_api_ms)** | **0 h 56 m 52 s** (3,412,222 ms) |
| Transcript wall-clock (context) | 0 h 47 m 46 s |
| Internal agent turns (num_turns) | 204 |
| Headless drive turns (phases) | 1 (single autonomous build call) |
| Operator-touch | n/a (automated arm — no human operator) |
| Operator interventions | n/a (automated arm) |
| Clarifying questions to PM | 0 (Vibe asked none — built from the brief) |
| LOC produced (ts/tsx, excl node_modules) | ~9,255 |
| Source files (ts/tsx) | 88 (69 non-test per cell's own count) |
| Sub-agents spawned | yes — fanned out 5 programs + peripheral screens to parallel subagents |
| Web searches | 0 |

## Cell-self-reported gates (from transcript; re-verify at scoring)

| Gate | Result |
|---|---|
| `npx tsc --noEmit` | ✅ clean |
| `npm test` (jest-expo) | ✅ 137 tests, 14 suites |
| `npx eslint .` | ✅ clean |
| Domain coverage | 92.8% stmts / 95.3% lines |

## Derived ratios (filled during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | ~0.00118 (41 / 34,813) |
| Quality per API hour | ~43.3 (41 / 0.9478 h) |
| Defects per 1KLOC | ~0.54 (5 / 9.255) |
| Methodology overhead ratio | n/a (Vibe — no planning phases) |
| Cost per binary outcome | ~$1.52 ($27.35 / 18 design-verifiable) |
| Quality per dollar | ~1.50 (41 / 27.35) |

## Paired Δ vs run-002 (cost axis; quality Δ after scoring)

| Metric | run-002 (manual, no-runtime) | run-003 (automated, no-runtime) | Δ |
|---|---|---|---|
| Implied API cost | $20.36 | **$27.35** | +$6.99 (+34%) |
| API compute time | 41m 13s | **56m 52s** | +15m 39s |
| Net LOC | 8,097 | **~9,255** | +1,158 |
| Tests shipped | 124 (13 suites) | **137 (14 suites)** | +13 |
| Sub-agents | 0 | **yes (parallel fan-out)** | — |

> Note: run-003 is the AUTOMATED ARM (headless `claude -p`, no human). The higher
> cost/time vs run-002 partly reflects the parallel-subagent fan-out (more
> exploration) and is **not** directly comparable to the manual runs on the
> operator-touch / intervention axes (those don't exist here).
