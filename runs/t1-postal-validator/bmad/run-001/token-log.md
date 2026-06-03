# T1-bmad / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Routing (primary finding — accept-adaptive policy)

**BMAD self-routed to `bmad-quick-dev` (freeform path), from a neutral `/bmad-help` kickoff.**
bmad-help assessed the task and reasoned: *"a fresh, self-contained coding task, not a
multi-phase product effort… spec is already pinned down… the freeform path (not an epic
story)"* — so it skipped the full PRD → architecture → epics/stories → dev → QA lifecycle.
Output: one `implementation-artifacts/spec-postal-validator.md` (no planning-artifacts). This
is BMAD's own right-sizing of a trivial task, not a failure (contrast AI-DLC, which ran full
ceremony on the same task at $4.57). Run is clean/neutral (vs. the two voided earlier attempts).

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 23.9 K |
| Session output tokens | 67.2 K |
| Cached read tokens | 2.5 M |
| Cached write tokens | 151.9 K |
| **Total tokens** | **~2.74 M** |

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$4.00** (per /status) |

Check: 23.9K·$5 + 67.2K·$25 + 2.5M·$0.50 + 151.9K·$6.25 (per 1M) ≈ $0.120 + $1.680 + $1.250 + $0.949 ≈ **$4.00** ✓
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **13m 48s** |
| Wall-clock incl. operator idle (context) | 14m 31s |
| Operator-touch time | _see session-log_ |
| Operator intervention count | _see session-log (neutral kickoff via /bmad-help)_ |
| Total code changes (per /status) | 394 added, 24 removed |

## Derived ratios (fill after quality scored)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _pending quality score_ |
| Quality per API hour | _pending quality score_ |
| Cost per binary outcome (÷3) | **$1.33** ($4.00 / 3) |
| Quality per dollar | _pending quality score_ |
| Methodology overhead ratio | quick-dev path (bmad-help orient + freeform build; no separate planning phases) |

---

### Raw /status paste (provenance)

```
Total cost:            $4.00
Total duration (API):  13m 48s
Total duration (wall): 14m 31s
Total code changes:    394 lines added, 24 lines removed
Usage by model:
   claude-opus-4-7:  23.9k input, 67.2k output, 2.5m cache read, 151.9k cache write ($4.00)
```
