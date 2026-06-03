# T2-ai-dlc / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 5.6 K |
| Session output tokens | 58.4 K |
| Cached read tokens | ~4.9 M |
| Cached write tokens | 127.8 K |
| **Total tokens** | **~5.09 M** |

Auxiliary Haiku 4.5: 587 in / 13 out / 0 cache ($0.0007 — negligible, likely title generation).

Note: the ~4.9 M cache-read dominates — the AI-DLC rule-set is re-read into context each turn (same pattern as T4-AI-DLC).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$4.75** (per /status) |

Check: 0.0056·$5 + 0.0584·$25 + 4.9·$0.50 + 0.1278·$6.25 ≈ $0.03 + $1.46 + $2.45 + $0.80 ≈ **$4.75** ✓
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **12m 38s** |
| Wall-clock incl. operator idle (context) | 14m 18s |
| Operator-touch time | _see session-log (approval gates = baseline operator-touch, NOT interventions)_ |
| Operator intervention count | _see session-log_ |
| Total code changes (per /status) | 1054 added, 26 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Defects per 1KLOC (loan-code delta) | _pending_ |
| Cost per binary outcome (÷4) | **$1.19** ($4.75 / 4) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | _pending (needs inception/construction vs build API split from session-log phase tracking)_ |

---

### Raw /status paste (provenance)

```
Total cost:            $4.75
Total duration (API):  12m 38s
Total duration (wall): 14m 18s
Total code changes:    1054 lines added, 26 lines removed
Usage by model:
  claude-haiku-4-5:  587 input, 13 output, 0 cache read, 0 cache write ($0.0007)
   claude-opus-4-7:  5.6k input, 58.4k output, 4.9m cache read, 127.8k cache write ($4.75)
```
