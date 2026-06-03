# T6 (OSS bug-fix) / GitHub Spec Kit / Run 001 / Token Capture

Captured via /status (or equivalent for GitHub Spec Kit). Screenshot retained at `artifacts/status-screenshot.png`.

## Raw counts

| Metric | Value |
|---|---|
| Session input tokens |  |
| Session output tokens |  |
| Cached read tokens |  |
| Cached write tokens |  |
| **Total tokens** |  |

## Cost calc (reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing as of 2026-05-22 |
| Model | Claude Opus 4.7 |
| Input $/MTok | $5.00 |
| Output $/MTok | $25.00 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | $ _.__ (compute at end: `(input/1M × 5) + (output/1M × 25) + (cache_read/1M × 0.50) + (cache_write/1M × 6.25)`) |

Pro-subscription disclosure: actual billing is flat $20/mo. Implied cost is API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | _ h _ m |
| Active session time (stopwatch, excl. rate-limit pauses — context) | _ h _ m |
| Wall-clock incl. operator idle (context) | _ h _ m |
| Operator-touch time | _ min |
| Operator intervention count | _ |
| Time to first working build/fix | _ s/m |

## Derived ratios (filled in during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | _ |
| Cost per binary outcome | $_ |
| Quality per dollar | _ |
