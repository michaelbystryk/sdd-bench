# T3-ai-dlc / Run 001 / Token Capture

Captured via Claude Code `/status` at end of session.

## Raw counts (operator /status — authoritative)

Claude Opus 4.7 (the cell model):

| Metric | Value |
|---|---|
| Session input tokens | 54 |
| Session output tokens | 30.7 K |
| Cached read tokens | 2.6 M |
| Cached write tokens | 102.1 K |
| **Total tokens** | **~2.73 M** |

Auxiliary Haiku 4.5: 537 in / 15 out / 0 cache ($0.0006 — negligible, likely title generation).

## Cost calc (must be reproducible)

| Field | Value |
|---|---|
| Pricing source | anthropic.com/pricing — Opus 4.7 rates |
| Input $/MTok | $5 |
| Output $/MTok | $25 |
| Cache read $/MTok | $0.50 |
| Cache write $/MTok | $6.25 |
| **Implied API cost** | **$2.73** (per /status) |

Check: 0.000054·$5 + 0.0307·$25 + 2.6·$0.50 + 0.1021·$6.25 ≈ $0.00 + $0.77 + $1.30 + $0.64 ≈ **$2.71** (≈ $2.73 ✓ — small variance is /status rounding).
Pro-subscription disclosure: actual billing is flat $20/mo; implied cost is the API-equivalent.

## Time + intervention summary (cross-ref session-log.md)

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | **7m 29s** |
| Wall-clock incl. operator idle (context) | 8m 13s |
| Operator-touch time | _see session-log (approval gates + any pm-ask exchanges; gates are baseline touch, NOT interventions per ai-dlc.md)_ |
| Operator intervention count | _see session-log_ |
| AI-DLC phases completed | Inception ✓ + Construction ✓ (Operations is a v0.1.8 placeholder — cell ends at Build-and-Test per config) |

## Cross-task AI-DLC comparison (cost has dropped sharply)

| Task | AI-DLC cost | Cache-read tokens | Notes |
|---|---|---|---|
| T1 | $4.57 | ~? | Full ceremony on trivial task — adaptive opposite of BMAD's quick-dev routing |
| T2 | $4.75 | ~20.4 M | Full Inception→Construction; cache-read dominated by 25 KB rule-set re-read per turn |
| **T3** | **$2.73** | **2.6 M** | Sharp drop. Spec being explicit reduced construction iterations → fewer turns × 25 KB rule-set re-read = ~8× less cache-read than T2. |

vs Vibe ratio: T1 7.7× → T2 4.7× → **T3 2.9×** (lowest ratio yet for AI-DLC).

## LOC

**461 lines added, 0 removed** → net **461 LOC**.

Post-cell sanity check (filesystem):
- Impl (`app/main.py`): **223 LOC** — single file, same shape as Vibe (no parse/validate/store/shape separation in separate modules).
- Planning artifacts (`aidlc-docs/inception/` + `construction/` + `audit.md` + `aidlc-state.md`): ~238 LOC.

**vs prior cells:**
| Cell | LOC (net) | Approx impl | Approx planning |
|---|---|---|---|
| Vibe | 184 | 184 | 0 |
| Plan Mode | 528 | ~528 | 0 (plan lives in CC JSONL transcript) |
| OpenSpec | 659 | ~? | ~? |
| Spec Kit | 1115 | ~? | ~? (spec/plan/tasks/research/data-model/contracts/checklists) |
| AI-DLC | 461 | **223** | ~238 |

**Interesting finding for blind pass:** AI-DLC's implementation (223 LOC) is closer to Vibe's (184) than to Plan Mode's (528). Same single-file shape — `app/main.py` only. Likely depresses dim 4 (System design) in the blind pass — for a methodology this heavy on inception planning, the construction output is structurally identical to the no-planning control. Worth flagging.
