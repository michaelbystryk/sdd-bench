# P6 — A4 (BMAD Party Mode) / run-001 observations

**Scrub label:** Output **D** (sealed map in `_scoring/scrub-map.sealed.md`)
**Rater(s):** 2 × blind `claude-fable-5` (Mythos) · **Scored:** 2026-06-09 · **Blind?:** yes
**Top-level model:** `claude-opus-4-8` ✓ · **Persona subagents:** `claude-sonnet-4-6` ×4 (mixed-model cell — disclosed)
**Scrubbed sha256:** in `_scoring/scrub-map.sealed.md`

# QUALITY AXIS (blind, 2 raters) — 5 dims, 0–5

| # | Dimension | r1 | r2 | One-line evidence |
|---|---|---|---|---|
| 1 | Correctness | 4 | 4 | Arithmetic checks vs reference; the client-side-filtering risk is properly `[ASSUMPTION]`-tagged. |
| 2 | Coverage | 4 | 4 | Four sections + the filtering/effective-first-page interaction the brief only gestures at. |
| 3 | Insight depth | 4 | 4 | "Client-side filtering shrinks the effective first page" → a 50-row page may not *contain* the hunted order — non-obvious, wired into the reversal condition. |
| 4 | Actionability | 4.5 | 5 | Committed 50; reversal triggers with thresholds (>40% page-2) + named next value (100) + "set it in *that* PR" for the bulk-view case. |
| 5 | Communication | 4.5 | 4.5 | Four sections, ~1 page, number up front; standup-ready. |

**Quality sum:** r1 **21**, r2 **21.5** → mean **21.25 / 25** (within-1pt ✓) · capped **20**

# UNBLINDING CHECK
- **Guess:** r1 **A2** (med), r2 **A2** (med) — **both wrong** (actual **A4**).
- **The headline:** the real multi-agent party machinery is indistinguishable from a solo
  thinking pass. Across all four outputs, **8/8 raters guessed A2** — A4 left no detectable
  multi-agent residue. The ceremony bought nothing a blind reader can see.

# MACHINERY (from `artifacts/transcript.jsonl` + `artifacts/subagents/`)
- BMad Master convened **4** of 6 personas (Winston/Sally/Amelia/John), spawned as **parallel
  one-shot `Agent` calls on `claude-sonnet-4-6`**, each **0 tool uses** — none read
  `situation.md`; the Opus orchestrator read it and passed the facts into their prompts.
- **Not a debate.** Four independent monologues, each landing on 50, then Opus synthesis —
  no cross-persona exchange. **A3's single-prompt simulated roundtable genuinely disagreed
  *more* than A4's real one** (in A3 the architect fought the default-to-max camp).
- Convergence framed as "unanimous." One hiccup: "roster resolver errored out" → fell back to
  the known cast. No fabrication observed (the persona takes cite the reference numbers correctly).
- Did NOT try to route out to PRD/architecture; landed the deliverable without operator continues.

# COST AXIS
| Metric | Value |
|---|---|
| Implied API cost | **$0.57** (Opus $0.461 + Sonnet $0.106) = **4.0× A1** |
| API compute time | **2m 10s** (130s) |
| Total output tokens | ~7,900 (sets A2's budget) |
| Operator interventions | 0 steering |

**P6 composite:** Q_capped 20 − ceremony 0 − cost_tax 1.0 = **19.00** — the sole loser of the
four (A1=A2=A3 tie at 19.75). Divisor $0.14 locked.

# HEADLINE (this cell)
A4 ran the full machinery — 4 Sonnet personas, parallel — for **4× the cost / 4.3× the time**
of A1, produced quality that capped equal (raw 21.25, *below* solo+thinking's 22.5), was
**indistinguishable from solo** to every blind rater, and ran *less* genuine debate than the
single-prompt A3. The over-ceremony tax, measured: **−1.0 composite, last place.**
