# T3-openspec / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 1.1 K |
| Session output tokens | 39.5 K |
| Cached read tokens | 2.6 M |
| Cached write tokens | 102.4 K |
| **Total tokens** | **~2.74 M** |

Auxiliary Haiku 4.5: 0 / 0 / 0 / 0 (none reported).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$2.91** (per /status) |

Check: 0.0011·$5 + 0.0395·$25 + 2.6·$0.50 + 0.1024·$6.25 ≈ $0.01 + $0.99 + $1.30 + $0.64 ≈ **$2.93** (≈ $2.91 ✓ — small variance is /status rounding).
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **8m 46s** |
| Wall-clock incl. operator idle (context) | 10m 9s |
| Operator-touch time | _see session-log (propose / apply / archive phase boundaries + any pm-ask exchanges)_ |
| Operator intervention count | _see session-log_ |
| OpenSpec phases completed | _propose ✓ / apply ✓ / archive ✓ (or note if any skipped — T4 OpenSpec skipped archive; T1/T2 completed)_ |

## LOC

**678 lines added, 19 removed** → net **659 LOC**.
Includes implementation + OpenSpec planning artifacts (proposal/, design.md, tasks.md, capability deltas). To separate impl LOC: `wc -l app/*.py` post-cell.
**vs prior cells:** Vibe 183, Plan Mode 528, OpenSpec 659 — each tier adds ~150 LOC.
