# T2-vibe-planmode / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 5.9 K |
| Session output tokens | 17.2 K |
| Cached read tokens | 969.8 K |
| Cached write tokens | 65.4 K |
| **Total tokens** | **~1.058 M** |

Auxiliary Haiku 4.5: 1.1 K in / 29 out / 0 cache ($0.0013 — negligible, likely title generation).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$1.35** (per /status) |

Check: 0.0059·$5 + 0.0172·$25 + 0.9698·$0.50 + 0.0654·$6.25 ≈ $0.03 + $0.43 + $0.48 + $0.41 ≈ **$1.35** ✓
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **3m 45s** |
| Wall-clock incl. operator idle (context) | 4m 13s |
| Operator-touch time | _see session-log_ |
| Operator intervention count | _see session-log (plan-approval taps = baseline operator-touch, NOT interventions)_ |
| Total code changes (per /status) | 266 added, 8 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Defects per 1KLOC (loan-code delta) | _pending_ |
| Cost per binary outcome (÷4) | **$0.34** ($1.35 / 4) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | _pending (needs planning/impl API split from session-log phase tracking)_ |

---

### Raw /status paste (provenance)

```
Total cost:            $1.35
Total duration (API):  3m 45s
Total duration (wall): 4m 13s
Total code changes:    266 lines added, 8 lines removed
Usage by model:
  claude-haiku-4-5:  1.1k input, 29 output, 0 cache read, 0 cache write ($0.0013)
   claude-opus-4-7:  5.9k input, 17.2k output, 969.8k cache read, 65.4k cache write ($1.35)
```
