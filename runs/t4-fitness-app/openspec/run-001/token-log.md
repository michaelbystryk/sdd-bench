# T4-openspec / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session (2026-05-26 ~12:30 PT).

## Raw counts

| Metric | Value |
|---|---|
| Session input tokens | 6,200 |
| Session output tokens | 132,600 |
| Cached read tokens | 5,500,000 |
| Cached write tokens | 169,300 |
| **Total tokens** | **~5,808,100** (input + output + cache read + cache write) |

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing as of 2026-05-26 |
| Model | Claude Opus 4.7 |
| Input $/MTok | $5.00 |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| Input cost | $0.031 (6,200 / 1M × $5) |
| Output cost | $3.315 (132,600 / 1M × $25) |
| Cache read cost | $2.750 (5,500,000 / 1M × $0.50) |
| Cache write cost | $1.058 (169,300 / 1M × $6.25) |
| **Implied API cost** | **$7.16** (matches /status) |

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status)** | **25 m 42 s** |
| Wall-clock raw, incl. operator idle (context) | 1 h 8 m 39 s (includes operator-step-away after cell complete) |
| Proposal phase (`/opsx:proposal`) | _ min (to be filled from session-log) |
| Apply phase (`/opsx:apply`) | _ min |
| Archive phase (`/opsx:archive`) | _ min |
| Operator-touch time | ~0 min (single auto-launched command per harness/methodology-configs/openspec.md) |
| Operator intervention count | _ (to be confirmed during scoring) |
| Time to first working build | not separately stopwatched |

## Derived ratios (filled in during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ (compute as quality_sum / (total_tokens / 1000)) |
| Quality per API hour | _ (compute as quality_sum / (25.7/60) ≈ quality_sum × 2.33; 25m42s = API compute) |
| Defects per 1KLOC | _ |
| Methodology overhead ratio (proposal / (apply + archive)) | _ |
| Cost per binary outcome | $_ (compute as $7.16 / binary_pass_count) |
| Quality per dollar | _ (compute as quality_sum / $7.16) |
