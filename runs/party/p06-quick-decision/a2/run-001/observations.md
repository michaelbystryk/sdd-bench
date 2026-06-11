# P6 — A2 (Solo + matched extended thinking) / run-001 observations

**Scrub label:** Output **C** (sealed map in `_scoring/scrub-map.sealed.md`)
**Rater(s):** 2 × blind `claude-fable-5` (Mythos) · **Scored:** 2026-06-09 · **Blind?:** yes
**Model:** `claude-opus-4-8` ✓ · thinking budget 8,000 (matched to A4), ~10% used

# QUALITY AXIS (blind, 2 raters) — 5 dims, 0–5

| # | Dimension | r1 | r2 | One-line evidence |
|---|---|---|---|---|
| 1 | Correctness | 4.5 | 4.5 | Reference numbers all reconcile; the usage-model assumption is tagged; no unsourced stat (cleaner than A3). |
| 2 | Coverage | 4 | 4 | Four sections + the bidirectional reversal ("regret direction is too-small, not too-big"). |
| 3 | Insight depth | 4 | 4 | "Usage model is softer than it looks" + the asymmetric regret framing; right-sized. |
| 4 | Actionability | 5 | 5 | Committed 50; next-page-ratio reversal trigger with threshold (40–50%) + named next value. |
| 5 | Communication | 5 | 5 | Tightest of the four; four sections, well under a page, forward-unedited. |

**Quality sum:** r1 **22.5**, r2 **22.5** → mean **22.50 / 25** — the **highest raw** of all four arms (within-1pt ✓) · capped **20**

# UNBLINDING CHECK
- **Guess:** r1 **A2**, r2 **A2** — **both correct** (actual **A2**). The only "correct"
  guesses in the whole P6 set (8/8 raters guessed A2 universally; C is the one that *was* A2).

# FINDING — budget barely touched
Thinking engaged (6 thinking blocks) but A2 spent **~10% of its 8,000-token budget** (Opus
output 2,526 vs A1's 1,719) and still scored the highest raw quality. **Deliberation tokens
were not the constraint** on this question — matching A4's spend as *thinking* didn't change
the answer (still 50) and added little length. Per the A2 config, a finding, not a failure.

# COST AXIS
| Metric | Value |
|---|---|
| Implied API cost | **$0.167** (1.18× A1; 0.29× A4) |
| API compute time | 44.9s |
| Operator interventions | 0 (headless) |

**P6 composite:** Q_capped 20 − 0 − cost_tax 0.25 = **19.75** (tied A1, A3).

# HEADLINE (this cell)
Given A4's entire token spend to *think* with, solo Opus used a tenth of it, kept the same
call, and scored the **best** raw quality of the four — the cleanest evidence that on this
question neither personas nor extra deliberation tokens were the missing ingredient.
