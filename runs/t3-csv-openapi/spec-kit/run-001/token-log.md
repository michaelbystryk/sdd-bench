# T3-spec-kit / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 592 |
| Session output tokens | 67.1 K |
| Cached read tokens | 6.0 M |
| Cached write tokens | 168.8 K |
| **Total tokens** | **~6.24 M** |

Auxiliary Haiku 4.5: 0 / 0 / 0 / 0 (none reported).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$5.72** (per /status) |

Check: 0.000592·$5 + 0.0671·$25 + 6.0·$0.50 + 0.1688·$6.25 ≈ $0.00 + $1.68 + $3.00 + $1.06 ≈ **$5.74** (≈ $5.72 ✓ — small variance is /status rounding).
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **15m 9s** |
| Wall-clock incl. operator idle (context) | 19m 10s |
| Operator-touch time | _see session-log (specify / clarify / plan / tasks / implement phase taps + any pm-ask exchanges)_ |
| Operator intervention count | _see session-log_ |
| Spec Kit phases completed | specify ✓ / clarify ✓ / plan ✓ / tasks ✓ / implement ✓ (full canonical pipeline) |

## Operator notes

- Initial `/status` after `/speckit-specify` showed $0.89; operator stopped reading there and forwarded numbers, then realized the pipeline wasn't complete. Continued through `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement` in the SAME session. Final `/status` ($5.72) is the cumulative cost across all 5 phases — authoritative.
- If `/speckit-clarify` produced clarifying questions, they should be in `artifacts/pm-convo.md` (assuming forwarded via pm-ask) — check there for retention question handling.

## LOC

**1277 lines added, 162 removed** → net **1115 LOC**.
Includes implementation + Spec Kit planning artifacts (spec.md, plan.md, tasks.md, research.md, data-model.md, contracts/, checklists/). To separate impl LOC: `wc -l app/*.py` post-cell.

**vs prior cells:**
| Cell | LOC (net) | Cost | Cost / LOC |
|---|---|---|---|
| Vibe | 184 | $0.93 | $0.0051 |
| Plan Mode | 528 | $1.41 | $0.0027 |
| OpenSpec | 659 | $2.91 | $0.0044 |
| Spec Kit | 1115 | $5.72 | $0.0051 |

Spec Kit's per-LOC cost is similar to Vibe's — planning artifacts add LOC + cost roughly proportionally. The 162 removed is template scaffolding being tightened across phases.
