# T1-spec-kit / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model; no auxiliary Haiku this cell):

| Metric | Value |
|---|---|
| Session input tokens | 7.2 K |
| Session output tokens | 67.2 K |
| Cached read tokens | 3.5 M |
| Cached write tokens | 117.2 K |
| **Total tokens** | **~3.69 M** |

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$4.20** (per /status) |

Check: 7.2K·$5 + 67.2K·$25 + 3.5M·$0.50 + 117.2K·$6.25 (per 1M) ≈ $0.036 + $1.680 + $1.750 + $0.733 ≈ **$4.20** ✓
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **13m 56s** |
| Wall-clock incl. operator idle (context) | 16m 13s |
| Operator-touch time | _see session-log (clarify forwards)_ |
| Operator intervention count | _see session-log_ |
| Total code changes (per /status) | 971 added, 169 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Cost per binary outcome (÷3) | **$1.40** ($4.20 / 3) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | _pending phase timing (specify→clarify→plan→tasks vs implement) — see session-log_ |

---

### Raw /status paste (provenance)

```
Total cost:            $4.20
Total duration (API):  13m 56s
Total duration (wall): 16m 13s
Total code changes:    971 lines added, 169 lines removed
Usage by model:
   claude-opus-4-7:  7.2k input, 67.2k output, 3.5m cache read, 117.2k cache write ($4.20)
```
