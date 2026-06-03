# T1-openspec / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model; no auxiliary Haiku this cell):

| Metric | Value |
|---|---|
| Session input tokens | 6.5 K |
| Session output tokens | 20.6 K |
| Cached read tokens | 1.0 M |
| Cached write tokens | 43.9 K |
| **Total tokens** | **~1.07 M** |

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$1.32** (per /status) |

Check: 6.5K·$5 + 20.6K·$25 + 1.0M·$0.50 + 43.9K·$6.25 (per 1M) ≈ $0.033 + $0.515 + $0.500 + $0.274 ≈ **$1.32** ✓
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **4m 25s** |
| Wall-clock incl. operator idle (context) | 8m 13s |
| Operator-touch time | _see session-log_ |
| Operator intervention count | _see session-log_ |
| Total code changes (per /status) | 486 added, 0 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Cost per binary outcome (÷3) | **$0.44** ($1.32 / 3) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | _pending phase timing (propose / apply / archive) — see session-log_ |

---

### Raw /status paste (provenance)

```
Total cost:            $1.32
Total duration (API):  4m 25s
Total duration (wall): 8m 13s
Total code changes:    486 lines added, 0 lines removed
Usage by model:
   claude-opus-4-7:  6.5k input, 20.6k output, 1.0m cache read, 43.9k cache write ($1.32)
```
