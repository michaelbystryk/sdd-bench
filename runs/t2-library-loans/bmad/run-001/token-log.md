# T2-bmad / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the primary cell model):

| Metric | Value |
|---|---|
| Session input tokens | 16.0 K |
| Session output tokens | 60.5 K |
| Cached read tokens | ~3.1 M |
| Cached write tokens | 153.3 K |
| **Total tokens (Opus)** | **~3.33 M** |

**Auxiliary Haiku 4.5 is NOT negligible here** — BMAD dispatches Haiku subagents as part of its workflow: 151 in / 9.2 K out / 956.1 K cache read / 65.7 K cache write (~1.03 M tokens, **$0.2239**). Counts toward the implied cost (unlike the title-gen Haiku in the other cells).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 + Haiku 4.5 rates |
| Opus input / output $/MTok | $5 / $25 |
| Opus cache read / write $/MTok | $0.50 / $6.25 |
| **Implied API cost** | **$4.33** (per /status — Opus $4.11 + Haiku $0.22) |

Check (Opus): 0.016·$5 + 0.0605·$25 + 3.1·$0.50 + 0.1533·$6.25 ≈ $0.08 + $1.51 + $1.55 + $0.96 ≈ **$4.11** ✓; + Haiku **$0.22** = **$4.33** total ✓
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **14m 11s** |
| Wall-clock incl. operator idle (context) | 20m 10s |
| Operator-touch time | _see session-log_ |
| Operator intervention count | _see session-log (note routing: quick-dev vs full lifecycle — must be BMAD's own call)_ |
| Total code changes (per /status) | 565 added, 25 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Defects per 1KLOC (loan-code delta) | _pending_ |
| Cost per binary outcome (÷4) | **$1.08** ($4.33 / 4) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | _pending (needs planning vs impl API split from session-log phase tracking)_ |

---

### Raw /status paste (provenance)

```
Total cost:            $4.33
Total duration (API):  14m 11s
Total duration (wall): 20m 10s
Total code changes:    565 lines added, 25 lines removed
Usage by model:
   claude-opus-4-7:  16.0k input, 60.5k output, 3.1m cache read, 153.3k cache write ($4.11)
  claude-haiku-4-5:  151 input, 9.2k output, 956.1k cache read, 65.7k cache write ($0.2239)
```
