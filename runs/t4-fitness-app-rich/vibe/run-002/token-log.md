# T4-rich (PM-quality brief) / Vibe Claude Code / Run 002 / Token Capture

Captured via /status at end of session.

## Raw counts

### claude-opus-4-8 (primary, effort: high)
| Metric | Value |
|---|---|
| Session input tokens | 11,900 |
| Session output tokens | 202,400 |
| Cached read tokens | 27,200,000 |
| Cached write tokens | 261,700 |
| Opus subtotal cost | $20.36 |

### claude-haiku-4-5 (auxiliary)
| Metric | Value |
|---|---|
| Input | 6,300 |
| Output | 19 |
| Web searches | 0 |
| Haiku subtotal | $0.0064 |

**Total cost:** **$20.36**

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing for claude-opus-4-8 |
| Model | claude-opus-4-8 (effort: high; vendor-recommended) |
| Input $/MTok | $5.00 |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$20.36** (Opus: 0.060 + 5.06 + 13.60 + 1.64 = $20.36) |

## Time + intervention summary

| Metric | Value |
|---|---|
| API compute time | **0 h 41 m 13 s** |
| Wall-clock | 1 h 7 m 3 s |
| Operator-touch | minimal — 2 socket-error resumes only |
| Operator interventions | **0 product interventions** |
| LOC produced | 8,127 added / 30 removed (net **8,097**) |
| Sub-agents spawned | 0 |
| Web searches | 0 |

## Derived ratios (filled in during scoring)

| Ratio | Value | Note |
|---|---|---|
| Quality per 1K tokens | **~0.00147** | 40.5 / 27,475 — cache-dominated; compare like-for-like only |
| Quality per API hour | **~59.0** | 40.5 / 0.687 h |
| Defects per 1KLOC | **~0.74** | 6 / 8.097 — very low density |
| Methodology overhead ratio | **n/a** | Vibe — no planning phases |
| Cost per binary outcome | **~$1.09** | $20.36 / 18 design-verifiable outcomes |
| Quality per dollar | **~1.99** | 40.5 / 20.36 |

## Paired Δ vs run-001 (cost axis only — quality Δ filled after run-002 is scored)

| Metric | run-001 | run-002 | Δ | Δ% |
|---|---|---|---|---|
| Implied API cost | $22.74 | **$20.36** | −$2.38 | −10.5% |
| API compute time | 45m 39s | **41m 13s** | −4m 26s | −9.7% |
| Wall-clock | 1h 15m 45s | **1h 7m 3s** | −8m 42s | −11.5% |
| Net LOC | 5,116 | **8,097** | +2,981 | +58.3% |
| Cache-read tokens | 31.3M | 27.2M | −4.1M | −13.1% |
| Sub-agents | 1 | 0 | −1 | — |
| Web searches | 7 | 0 | −7 | — |
