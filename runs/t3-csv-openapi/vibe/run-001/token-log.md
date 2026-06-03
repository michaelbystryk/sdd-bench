# T3-vibe / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 22 |
| Session output tokens | 15.7 K |
| Cached read tokens | 638.5 K |
| Cached write tokens | 35.5 K |
| **Total tokens** | **~689.7 K** |

Auxiliary Haiku 4.5: 531 in / 15 out / 0 cache ($0.0006 — negligible, likely title generation).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$0.93** (per /status) |

Check: 0.000022·$5 + 0.0157·$25 + 0.6385·$0.50 + 0.0355·$6.25 ≈ $0.00 + $0.39 + $0.32 + $0.22 ≈ **$0.93** ✓
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **3m 36s** |
| Wall-clock incl. operator idle (context) | 4m 42s |
| Operator-touch time | _see session-log (likely 0 — Vibe trait)_ |
| Operator intervention count | _see session-log (likely 0)_ |

## LOC

184 lines added, 0 removed → net 184 LOC (per Claude Code summary).
