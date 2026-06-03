# T2-vibe / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 4.4 K |
| Session output tokens | 16.0 K |
| Cached read tokens | 750.7 K |
| Cached write tokens | 33.2 K |
| **Total tokens** | **~804.3 K** |

Auxiliary Haiku 4.5: 581 in / 16 out / 0 cache ($0.0007 — negligible, likely title generation).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$1.01** (per /status) |

Check: 0.0044·$5 + 0.016·$25 + 0.7507·$0.50 + 0.0332·$6.25 ≈ $0.02 + $0.40 + $0.38 + $0.21 ≈ **$1.01** ✓
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **3m 27s** |
| Wall-clock incl. operator idle (context) | 5m 10s |
| Operator-touch time | _see session-log_ |
| Operator intervention count | _see session-log_ |
| Total code changes (per /status) | 180 added, 12 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Defects per 1KLOC (loan-code delta) | _pending_ |
| Cost per binary outcome (÷4) | **$0.25** ($1.01 / 4) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | n/a (Vibe — no planning phase) |

---

### Raw /status paste (provenance)

```
Total cost:            $1.01
Total duration (API):  3m 27s
Total duration (wall): 5m 10s
Total code changes:    180 lines added, 12 lines removed
Usage by model:
  claude-haiku-4-5:  581 input, 16 output, 0 cache read, 0 cache write ($0.0007)
   claude-opus-4-7:  4.4k input, 16.0k output, 750.7k cache read, 33.2k cache write ($1.01)
```
