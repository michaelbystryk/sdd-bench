# T1-vibe-planmode / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 5.6 K |
| Session output tokens | 14.6 K |
| Cached read tokens | 514.1 K |
| Cached write tokens | 52.9 K |
| **Total tokens (Opus)** | **~587.2 K** |

Auxiliary Haiku 4.5 (non-trivial this cell): 1.2 K in / 5.6 K out / 222.2 K cache read / 34.7 K cache write (**$0.095**) — ~263.7 K tokens. **Combined ~850.9 K tokens, combined cost $1.07.** (Worth noting the Haiku spend is ~9% here, unlike the negligible Haiku in other cells — flag for the cross-cell write-up.)

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$1.07** (Opus $0.98 + Haiku $0.095, per /status) |

Check (Opus): 5.6K·$5 + 14.6K·$25 + 514.1K·$0.50 + 52.9K·$6.25 (per 1M) ≈ $0.028 + $0.365 + $0.257 + $0.331 ≈ **$0.98** ✓ (+ $0.095 Haiku = $1.07)
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **3m 57s** |
| Wall-clock incl. operator idle (context) | 5m 2s |
| Operator-touch time | _see session-log (plan-approval gate)_ |
| Operator intervention count | _see session-log_ |
| Total code changes (per /status) | 298 added, 0 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Cost per binary outcome (÷3) | **$0.36** ($1.07 / 3) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | _pending phase timing (plan vs implementation) — see session-log_ |

---

### Raw /status paste (provenance)

```
Total cost:            $1.07
Total duration (API):  3m 57s
Total duration (wall): 5m 2s
Total code changes:    298 lines added, 0 lines removed
Usage by model:
  claude-haiku-4-5:  1.2k input, 5.6k output, 222.2k cache read, 34.7k cache write ($0.0950)
   claude-opus-4-7:  5.6k input, 14.6k output, 514.1k cache read, 52.9k cache write ($0.98)
```
