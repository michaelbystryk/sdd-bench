# P6 — A1 (Solo) / run-001 observations

**Scrub label:** Output **B** (sealed map: `runs/party/p06-quick-decision/_scoring/scrub-map.sealed.md`)
**Rater(s):** 2 × blind workflow raters
**Rater model:** `claude-fable-5` (Mythos) — pinned via Workflow `model:'fable'` to break LLM-rater circularity (cells on Opus 4.8). P6 is non-security, so Fable's cybersecurity classifier should not drift it to Opus (unlike P1/P8/P9/P10).
**Scored on:** 2026-06-09 · **Blind?:** yes (scored from scrubbed Output B; arm revealed after)
**Scrubbed-artifact sha256:** eb5a30fe6bc4dc261e6315a633179860d58fb17b90fb6d8e0ae60d77b9dbf245

---

# QUALITY AXIS (blind, 2 raters) — 5 dims, 0–5 each

| # | Dimension | r1 | r2 | One-line evidence |
|---|---|---|---|---|
| 1 | Correctness | 4 | 4 | All derived numbers check vs reference (70 KB, ~11 ms DB, ~15 ms serialization, 3–4× CPU at 200); the one inference (prefetch) properly tagged `[ASSUMPTION]`. |
| 2 | Coverage | 4 | 4 | Four sections + implicit concerns (quantified telemetry trigger; asymmetric "go down not up" latency case). |
| 3 | Insight depth | 4 | 4 | "max-size default burns ~3–4× CPU rendering rows nobody sees"; prefetch defuses the round-trip counterargument; asymmetric reversal logic — depth without manufacture. |
| 4 | Actionability | 4.5 | 5 | Committed number up front; explicit quantified what-would-change-my-mind (">40% second-page → bump to 100 in the one-line PR"). |
| 5 | Communication | 4.5 | 4.5 | Exactly four sections, answer in the first word (**50.**), well under a page, standup-ready. |

**Quality sum (final 4-arm scoring):** r1 **21**, r2 **22** → mean **21.50 / 25** (within-1pt ✓) · capped 20 · cross-arm table in `_scoring/SUMMARY.md`

> r1's only reservation: never explicitly *names the question as small* (the guidance's
> highest-insight move). Reasons run slightly long. No major docks.

---

# UNBLINDING CHECK
- **Guess:** r1 **A2** (low), r2 **A2** (med) — **both wrong** (actual **A1**).
- Tell cited: "dense derived arithmetic + counterargument anticipation reads like reasoning budget spent on analysis." A strong one-shot read as extended-thinking (A1↔A2 are the single-voice/no-persona family).
- **Meaning:** there is no persona/roundtable residue to detect (A1 is solo); depth alone pulled the guess to A2.

---

# COST AXIS (from result JSON — authoritative)

| Metric | Value |
|---|---|
| Implied API cost (USD) | **$0.1416** (`total_cost_usd`) |
| API compute time | **30.0s** |
| Output tokens (Opus) | 1,719 |
| Operator interventions | 0 (headless) |

**P6 composite:** Q_capped 20 − ceremony 0 − cost_tax 0.25 = **19.75** (divisor $0.14 locked;
**tied for first** with A2 & A3 — A4 lost alone at 19.00).

---

# HEADLINE (this cell)
A1 solo lands a near-ideal right-sized memo — committed **50**, reference-grounded
arithmetic, one quantified bidirectional reversal trigger — at **$0.14 / 30s**, quality
mean **21.50/25** (capped 20). The cheapest arm, tied for the best composite; the bar party
mode had to clear and didn't.
