# T1-ai-dlc / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session (AI-DLC runs on Claude Code).

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 5.2 K |
| Session output tokens | 61.9 K |
| Cached read tokens | 4.4 M |
| Cached write tokens | 127.5 K |
| **Total tokens** | **~4.59 M** |

Auxiliary Haiku 4.5: 651 in / 15 out / 0 cache (~$0.0007 — negligible).
The 4.4 M cache-read dominates — AI-DLC re-reads its rule-set / aidlc-docs each turn (same cost signature as the T4 AI-DLC cell).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$4.57** (per /status) |

Check: 5.2K·$5 + 61.9K·$25 + 4.4M·$0.50 + 127.5K·$6.25 (per 1M) ≈ $0.026 + $1.548 + $2.200 + $0.797 ≈ **$4.57** ✓
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **12m 52s** |
| Wall-clock incl. operator idle (context) | 14m 1s |
| Operator-touch time | _see session-log (approval gates)_ |
| Operator intervention count | _see session-log_ |
| Total code changes (per /status) | 1269 added, 27 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Cost per binary outcome (÷3) | **$1.52** ($4.57 / 3) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | _pending phase timing (Inception vs Construction) — see session-log_ |

---

### Raw /status paste (provenance)

```
Total cost:            $4.57
Total duration (API):  12m 52s
Total duration (wall): 14m 1s
Total code changes:    1269 lines added, 27 lines removed
Usage by model:
  claude-haiku-4-5:  651 input, 15 output, 0 cache read, 0 cache write ($0.0007)
   claude-opus-4-7:  5.2k input, 61.9k output, 4.4m cache read, 127.5k cache write ($4.57)
```
