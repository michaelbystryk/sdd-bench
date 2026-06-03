# T2-spec-kit / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 6.0 K |
| Session output tokens | 50.2 K |
| Cached read tokens | ~3.5 M |
| Cached write tokens | 134.3 K |
| **Total tokens** | **~3.69 M** |

Auxiliary Haiku 4.5: none reported.

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$3.90** (per /status) |

Check: 0.006·$5 + 0.0502·$25 + 3.5·$0.50 + 0.1343·$6.25 ≈ $0.03 + $1.26 + $1.75 + $0.84 ≈ **$3.90** ✓ (within rounding of `3.5m` cache-read)
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **10m 30s** |
| Wall-clock incl. operator idle (context) | 13m 39s |
| Operator-touch time | _see session-log_ |
| Operator intervention count | _see session-log_ |
| Total code changes (per /status) | 959 added, 100 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Defects per 1KLOC (loan-code delta) | _pending_ |
| Cost per binary outcome (÷4) | **$0.98** ($3.90 / 4) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | _pending (needs specify/clarify/plan/tasks vs implement API split from session-log phase tracking)_ |

---

### Raw /status paste (provenance)

```
Total cost:            $3.90
Total duration (API):  10m 30s
Total duration (wall): 13m 39s
Total code changes:    959 lines added, 100 lines removed
Usage by model:
   claude-opus-4-7:  6.0k input, 50.2k output, 3.5m cache read, 134.3k cache write ($3.90)
```
