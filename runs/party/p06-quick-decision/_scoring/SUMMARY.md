# P6 (quick-decision / over-ceremony control) — four-arm result

*pv0.2 pilot, 2026-06-09. All four arms run on `claude-opus-4-8` (A4 mixed-model: Opus
orchestrator + Sonnet-4.6 personas, per the locked carve-out). Blind scoring by 2 ×
`claude-fable-5` (Mythos) raters per output, within-1pt on every arm. Sealed label map:
A=A3, B=A1, C=A2, D=A4.*

## The table

| Arm | Raw quality /25 (2 raters) | Q capped (≤20) | Cost (USD) | API time | Ceremony flag | Cost tax | **Composite** |
|---|---|---|---|---|---|---|---|
| **A1** solo | 21.5 (21, 22) | 20 | **$0.142** | 30s | none | 0.25 | **19.75** |
| **A2** solo+thinking | **22.5** (22.5, 22.5) | 20 | $0.167 | 45s | none | 0.25 | **19.75** |
| **A3** persona-prompt | 20.75 (20.5, 21) | 20 | $0.209 | 63s | none | 0.25 | **19.75** |
| **A4** party mode (default, mixed-model) | 21.25 (21, 21.5) | 20 | $0.57 | 130s | none | 1.00 | **19.00** |
| **A4-opus** party mode (`--model opus`) | 21.75 (21.5, 22) | 20 | **$0.71** | 195s | none | 1.25 | **18.75** |

Cost-tax divisor **locked at $0.14** (≈ A1's lean reference spend) — see
`tasks/party/p06-quick-decision/success-criteria.md` § calibration. Ceremony tax 0 for all
(no rater raised the flag; all four deliverables in-band: A1 353w, A2 ~350w, A3 375w, A4 354w).

## What it says (P6, n=1 per arm)

**1. Quality is a dead heat — and the machinery did not win it.** All four cap at the P6
right-sizing ceiling of 20. Raw, the order is **A2 (22.5) > A1 (21.5) > A4 (21.25) > A3
(20.75)** — the two cheapest-conceptually arms (solo, solo+thinking) top it; the **real
party machinery (A4) is middle of the pack, and the persona-prompt (A3) is last.** Every arm
landed the same call (default **50**) with the same core reasoning and the same risk family
(first-page-may-not-contain-the-order: A3/A4 framed it as find-in-page/filtering, A1/A2 as
the soft usage model).

**2. Blind raters cannot tell the arms apart — at all.** **8/8 raters guessed A2 for every
single output.** The lone "correct" guesses are the two on Output C, which genuinely *was*
A2; for A1, A3, and A4 the score is **0/6**. The real multi-agent party mode (A4) and the
single-prompt persona roundtable (A3) left **no more detectable trace than a plain one-shot**
— raters repeatedly reasoned *away* from a persona arm ("no roundtable/persona residue, reads
like one model thinking long"). The masquerade is total on the unblinding axis.

**3. So cost is the whole story — and A4 loses it.** With quality capped-equal and no ceremony
flags, the composite is decided by spend. A4 cost **4.0× A1** for nothing the raters could
see, and is the **sole loser** (19.00 vs a three-way 19.75 tie). The over-ceremony tax is
demonstrated — but **modestly**: party mode was only 4× here, not the 15–172× it hit on the
main track's code builds, because a one-page memo caps how much ceremony it can run. On a
small advisory call the machinery's penalty is real but small.

**4. A2's budget went mostly unspent.** Given a thinking budget of 8,000 (matched to A4's
~7.9k output), A2 used ~10% (~800 thinking tokens) and still scored the **highest** raw
quality. Deliberation tokens were not the constraint on this question.

**5. Fair-resourcing the machinery doesn't rescue it (A4-opus companion).** Re-running A4
with `--model opus` (personas on Opus 4.8, model-constant with the solo arms) lifted raw
quality ~0.5pt (21.25 → 21.75, 2nd-best of all) — confirming the Sonnet personas *were* a
mild handicap. But that lift is exactly what P6's right-sizing cap erases (still capped 20),
the output is **still indistinguishable** (both raters guessed A2 → 10/10 across the set), and
it cost **+25%** ($0.57 → $0.71, now 5× A1), so it lands the **lowest composite (18.75)**. The
spawn architecture is unchanged — parallel one-shot personas, 0 tools, no debate; `--model
opus` changes the model, not the (non-)conversation. With the handicap excuse removed, the
verdict holds: the machinery buys imperceptible polish at multiples of the cost.

## Machinery notes (A4, from the transcript)
- 4 personas (Winston/Sally/Amelia/John) spawned as **parallel one-shot `Agent` calls on
  `claude-sonnet-4-6`**, each **0 tools** — they never read `situation.md`; the Opus
  orchestrator read it and hand-fed them the facts.
- **Not a debate.** Four independent monologues that each landed on 50 → orchestrator
  synthesis. No cross-persona exchange. A3's *simulated* roundtable produced *more* genuine
  disagreement than A4's real one.
- One machinery hiccup: "roster resolver errored out," fell back to the known cast.

## Caveats
- n=1 per arm. P6 is the over-ceremony control by design (quality capped) — it is the task
  *most* tilted toward this result; the planted-truth tasks (P1/P5/P8…) test the other axes
  (recall floor, decoy precision) where the story may differ.
- A4 is mixed-model (Sonnet personas); its quality reading carries that disclosed caveat.
- Divisor lock is from this single A1/A4 pair; revisit if later tasks show very different spreads.
