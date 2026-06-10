# P6 — A3 (Persona prompt / masquerade) / run-001 observations

**Scrub label:** Output **A** (sealed map: `runs/party/p06-quick-decision/_scoring/scrub-map.sealed.md`)
**Rater(s):** 2 × blind workflow raters
**Rater model:** `claude-fable-5` (Mythos) — pinned via Workflow `model:'fable'` (cross-model break vs Opus-4.8 cells). P6 non-security → no expected Fable classifier drift.
**Scored on:** 2026-06-09 · **Blind?:** yes (scored from scrubbed Output A; arm revealed after)
**Scrubbed-artifact sha256:** 7babaa7e706fc59d3dcf3a1ae276a63614bd8c63936e2168c4ea3bd9c4700adc

---

# QUALITY AXIS (blind, 2 raters) — 5 dims, 0–5 each

| # | Dimension | r1 | r2 | One-line evidence |
|---|---|---|---|---|
| 1 | Correctness | 3.5 | 4 | Numbers check out, but "agents commonly scan 20–40 rows" is stated as fact though it's nowhere in the reference and **untagged** — the one blemish both raters flagged (a persona-injected stat). |
| 2 | Coverage | 4 | 4 | Four sections + the find-in-page/infinite-scroll interaction the brief only gestures at. |
| 3 | Insight depth | 4 | 4 | Ctrl-F only matches DOM-loaded rows → "reads as the order isn't here when it is" — a genuinely non-obvious second-order failure mode; "pick for UX not load." Depth without manufacture. |
| 4 | Actionability | 4.5 | 4.5 | One committed number, two measurable reversal triggers, named fallback (100); shy of 5 (load-bearing assumption given no cheap verification step). |
| 5 | Communication | 4.5 | 4.5 | Exactly four sections, number bolded first line, under a page; held back by dense multi-clause reason sentences. |

**Quality sum:** r1 **20.5**, r2 **21** → mean **20.75 / 25** (within-1pt ✓)

> Qualitative (masquerade heart — from archived roundtable `artifacts/transcript.jsonl`):
> **the simulated panel genuinely disagreed** — the facilitator challenged "why not fetch
> 15," the UX voice argued working-set > viewport, and the architect pushed back on "just
> default to 200" with the non-obvious "a default is a soft contract; keep the max
> meaningful" point. NOT polite convergence. The deliverable itself carries **zero**
> roundtable structure (the synthesis instruction held).

---

# UNBLINDING CHECK
- **Guess:** r1 **A2** (med), r2 **A2** (med) — **both wrong** (actual **A3**).
- Tell cited: "single coherent voice, one deep second-order insight woven in, zero multi-perspective residue — the signature of one model thinking long, not persona synthesis (which typically leaks 'options considered' / balanced-viewpoint structure)."
- **Meaning — the key pilot signal:** A3's persona roundtable left **no detectable trace** in the scrubbed deliverable. Raters explicitly reasoned *away* from a persona arm because there was no roundtable residue, and landed on A2. **Persona framing is not identifiable from the output it produces** — exactly what the masquerade thesis predicts the A4 test must confront.

---

# COST AXIS (from result JSON — authoritative)

| Metric | Value |
|---|---|
| Implied API cost (USD) | **$0.2088** (`total_cost_usd`) |
| API compute time | **63.5s** |
| Output tokens (Opus) | 3,745 (2.2× A1) |
| Operator interventions | 0 (headless) |

**P6 composite:** Q_capped 20 − ceremony 0 − cost_tax 0.25 = **19.75** (divisor $0.14 locked;
tied A1 & A2). Final blind scoring: 8/8 raters across all four arms guessed A2 — A3's persona
output was indistinguishable from solo, and from A4's real machinery.

---

# HEADLINE (this cell)
A3's persona pass spent **1.47× the cost / 2.1× the time** of A1 to produce a deliverable
that scored **0.5 pt lower** (20.75 vs 21.25) and was **indistinguishable from solo** to
blind raters (both guessed A2) — and its one extra flourish, an untagged invented stat,
was the only correctness dock in the pair. Preliminary masquerade signal: persona framing
bought cost, not quality, on the over-ceremony control.
