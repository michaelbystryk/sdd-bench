# T1-vibe / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 3.8 K |
| Session output tokens | 10.8 K |
| Cached read tokens | 336.7 K |
| Cached write tokens | 21.6 K |
| **Total tokens** | **~372.9 K** |

Auxiliary Haiku 4.5: 645 in / 15 out / 0 cache (~$0.0007 — negligible, likely title generation).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$0.59** (per /status) |

Check: 3.8K·$5 + 10.8K·$25 + 336.7K·$0.50 + 21.6K·$6.25 (per 1M) ≈ $0.019 + $0.270 + $0.168 + $0.135 ≈ **$0.59** ✓
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **2m 24s** |
| Wall-clock incl. operator idle (context) | 18m 1s |
| Operator-touch time | _see session-log_ |
| Operator intervention count | _see session-log_ |
| Total code changes (per /status) | 220 added, 0 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Cost per binary outcome (÷3) | **$0.20** ($0.59 / 3) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | n/a (Vibe — no planning phase) |

---

### Raw /status paste (provenance)

```
Total cost:            $0.59
Total duration (API):  2m 24s
Total duration (wall): 18m 1s
Total code changes:    220 lines added, 0 lines removed
Usage by model:
  claude-haiku-4-5:  645 input, 15 output, 0 cache read, 0 cache write ($0.0007)
   claude-opus-4-7:  3.8k input, 10.8k output, 336.7k cache read, 21.6k cache write ($0.59)
```
