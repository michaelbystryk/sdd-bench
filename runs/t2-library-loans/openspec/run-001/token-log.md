# T2-openspec / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 6.1 K |
| Session output tokens | 22.7 K |
| Cached read tokens | ~2.0 M |
| Cached write tokens | 51.2 K |
| **Total tokens** | **~2.08 M** |

Auxiliary Haiku 4.5: none reported.

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$1.89** (per /status) |

Check: 0.0061·$5 + 0.0227·$25 + 2.0·$0.50 + 0.0512·$6.25 ≈ $0.03 + $0.57 + $1.00 + $0.32 ≈ $1.92 — within rounding of the displayed `2.0m` cache-read; the /status bottom-line **$1.89** is authoritative.
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **5m 19s** |
| Wall-clock incl. operator idle (context) | 7m 47s |
| Operator-touch time | _see session-log_ |
| Operator intervention count | _see session-log_ |
| Total code changes (per /status) | 322 added, 10 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Defects per 1KLOC (loan-code delta) | _pending_ |
| Cost per binary outcome (÷4) | **$0.47** ($1.89 / 4) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | _pending (needs propose/apply vs impl API split from session-log phase tracking)_ |

---

### Raw /status paste (provenance)

```
Total cost:            $1.89
Total duration (API):  5m 19s
Total duration (wall): 7m 47s
Total code changes:    322 lines added, 10 lines removed
Usage by model:
   claude-opus-4-7:  6.1k input, 22.7k output, 2.0m cache read, 51.2k cache write ($1.89)
```
