# T3-vibe-planmode / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 542 |
| Session output tokens | 18.1 K |
| Cached read tokens | 1.2 M |
| Cached write tokens | 60.1 K |
| **Total tokens** | **~1.28 M** |

Auxiliary Haiku 4.5: 1.1 K in / 26 out / 0 cache ($0.0012 — negligible, likely title generation).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$1.41** (per /status) |

Check: 0.000542·$5 + 0.0181·$25 + 1.2·$0.50 + 0.0601·$6.25 ≈ $0.00 + $0.45 + $0.60 + $0.38 ≈ **$1.43** (≈ $1.41 ✓ — small variance is /status rounding).
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **4m 10s** |
| Wall-clock incl. operator idle (context) | 9m 45s |
| Operator-touch time | _see session-log (Plan Mode: plan-approval taps + any pm-ask exchanges; baseline operator-touch, NOT interventions per runbook)_ |
| Operator intervention count | _see session-log_ |
| Plan revisions | _0 (converged easily) / 1-2 (some refinement) / 3+ (methodology struggled) — fill from your stopwatch + recall_ |

## LOC

**528 lines added, 0 removed** → net 528 LOC (per Claude Code summary).
**vs Vibe: 2.9× more code** (vibe-pure shipped 183 LOC). Worth noting in observations: the LOC delta is likely Pydantic models + layering + per-row error classes that Vibe sidestepped.
