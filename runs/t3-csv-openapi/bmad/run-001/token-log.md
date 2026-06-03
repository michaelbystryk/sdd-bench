# T3-bmad / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 2.4 K |
| Session output tokens | 47.5 K |
| Cached read tokens | 4.3 M |
| Cached write tokens | 210.4 K |
| **Total tokens** | **~4.56 M** |

Auxiliary Haiku 4.5: 0 / 0 / 0 / 0 (none reported).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$4.67** (per /status) |

Check: 0.0024·$5 + 0.0475·$25 + 4.3·$0.50 + 0.2104·$6.25 ≈ $0.01 + $1.19 + $2.15 + $1.32 ≈ **$4.66** (≈ $4.67 ✓ — small variance is /status rounding).
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **12m 1s** |
| Wall-clock incl. operator idle (context) | 13m 31s |
| Operator-touch time | _see session-log_ |
| Operator intervention count | _see session-log_ |
| BMAD routing | **quick-dev** (confirmed: one artifact in `_bmad-output/implementation-artifacts/spec-csv-import-users.md`; no PRD / architecture / epics / stories produced) |

## BMAD adaptive routing — replicates across all 3 code tasks

| Task | Routing | Cost | Notes |
|---|---|---|---|
| T1 | **quick-dev** | $4.00 | "Adaptive opposite of AI-DLC's full ceremony" |
| T2 | **quick-dev** | $4.33 | 3 artifacts: one spec + diff + deferred-work |
| **T3** | **quick-dev** | **$4.67** | 1 artifact: spec-csv-import-users.md |
| T4 | full lifecycle | $75.85 | Vague brief → BMAD's planning surfaced complexity → full lifecycle |

**Cross-task finding (now 3 corroborations + 1 contrast):** BMAD's adaptive routing reliably right-sizes for code tasks with clear briefs (quick-dev, $4–5 range), and escalates to full ceremony when the brief is vague (T4 vague). The routing is a measured property, not noise. Operator policy ("accept BMAD's own adaptive routing") proven correct.

vs Vibe ratio: T1 6.8× → T2 4.3× → **T3 5.0×**.

## LOC

**545 lines added, 24 lines removed** → net **521 LOC**.

Post-cell sanity check (filesystem):

| File | LOC |
|---|---|
| `app/csv_import.py` | 221 |
| `app/main.py` | 70 |
| `app/schemas.py` | 52 |
| `app/store.py` | 15 |
| **Total app/** | **358** |
| `_bmad-output/implementation-artifacts/spec-csv-import-users.md` | ~? (the rest) |

**Headline finding for blind raters:** BMAD is the FIRST T3 cell to ship multi-file implementation with named-by-concern separation. Other cells observed so far:

| Cell | Impl files | Impl LOC | Shape |
|---|---|---|---|
| Vibe | 1 (main.py) | 184 | god file |
| AI-DLC | 1 (main.py) | 223 | god file |
| **BMAD** | **4 (csv_import + main + schemas + store)** | **358** | **named separation of concerns** |
| Plan Mode | ? | (528 net total) | TBD — check filesystem |
| OpenSpec | ? | (659 net total) | TBD — check filesystem |
| Spec Kit | ? | (1115 net total) | TBD — check filesystem |

The `schemas.py` strongly implies Pydantic models (engaged the v2 trap); `store.py` strongly implies the retention question got NAMED as a concern (broken out as a separate file). This is the v0.3 blind-pass dim 4 (System design) discriminator firing — BMAD's quick-dev still produced a more structured artifact than the no-planning + heavy-planning extremes.
