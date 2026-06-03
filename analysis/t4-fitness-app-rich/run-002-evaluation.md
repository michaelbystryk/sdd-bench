# T4-rich run-002 (no-runtime brief) — full evaluation

**Date:** 2026-06-01. **Brief:** `brief-no-runtime.md` (source + tests only; cell forbidden from building/running the app — §7). **Scope:** all 6 methodologies, one cell each. **Scoring conditions (kept separate per rubric v0.3):**
- **Blind code-visible /40** — 2 fresh Sonnet raters per cell, 8 anonymized dims, leak-scrubbed bundles. *(spec-kit-001 was /30; all run-002 cells shipped a UI so all are /40.)*
- **Code-based /55** — single Sonnet rater, aware, all 12 dims (incl. planning), from the cell's `observations.md`. PROVISIONAL.
- **Cost** — operator `/status`, implied API $.

> Run-002 is the **no-runtime sibling** of run-001. Its purpose in the trilogy: isolate what changes when the cell builds *source as a PR* instead of *a running app*. The headline below is the paired-Δ vs run-001 + the cross-methodology picture under the no-runtime constraint.

## The table

| Methodology | Blind code /40 (2-rater avg) | Code-based /55 (aware, prov.) | Cost | Δcost vs run-001 |
|---|:--:|:--:|:--:|:--:|
| ai-dlc | **34.75** | 44.0 | $33.50 | −66% ($97.97) |
| vibe | 34.5 | 40.5 | $20.36 | −10% ($22.74) |
| bmad | 34.5 | 42.5 | **$689.47** | **+80%** ($384.05) |
| openspec | 34.25 | 45.5 | $22.91 | +11% ($20.64) |
| vibe-planmode | 33.75 | 44.0 | $24.09 | −25% ($31.94) |
| spec-kit | 30.0 | 44.0 | $30.10 | +115% ($14.01) |

**Code-based /55 order:** openspec 45.5 > ai-dlc = planmode = spec-kit 44.0 > **bmad 42.5** > vibe 40.5. Note BMAD is *behind* the cheaper structured cells on the aware /55 despite 18× the cost — its planning dims max out (Spec 5/Scope 5/Assump 5) but Product polish drags it down (13.5/20) and it carries a severity regression (below).

## Findings

### 1. Blind, the no-runtime cells are an indistinguishable cluster (33.75–34.75) + spec-kit trailing
Five of six land in a **1-point band** (33.75–34.75); spec-kit at 30.0 is the only separation, and that's a screen-wiring gap (its UI references domain capabilities not fully wired), not a code-quality collapse. **Blind, you cannot rank the methodologies by code quality on this task** — report the band, not the order. This is the same result as run-001's blind cluster (32–35) and replicates the eval-wide pattern: *the reproducible methodology separation lives in the planning dims + cost, not in blind code.*

### 2. vibe (the no-methodology control) co-leads — REPLICATES T1/T2, not T3
vibe-002 blind = 34.5, tied with bmad and just behind ai-dlc. The no-methodology control's *code*, blind, is indistinguishable from every structured cell's. Combined with run-001 (vibe 34.25, also co-leading), T4-rich joins T1/T2 in the "blind, the control is as good as the planned cells" column and does **not** reproduce T3's reversal where vibe trailed.

### 3. The no-runtime constraint did NOT lower code quality — it redirected effort
Every cell's run-002 blind score is within ~1.5pt of its run-001 sibling (ai-dlc 33.0→34.75, vibe 34.25→34.5, openspec 33.5→34.25, planmode 32.5→33.75, bmad 34.75→34.5). Removing the sim didn't hurt the code. What it changed was *where unprompted effort flowed*: run-002 cells substituted **test suites + handoff docs** for the sim-driving cycle (vibe-002 shipped 124 jest tests + ASSUMPTIONS.md/HANDOFF.md; most cells leaned harder on property-based + per-program unit tests). The sim cycle is cheap; structured artifacts are where the no-runtime budget went.

### 4. The cost-Δ ordering REVERSES run-001 — the sharpest run-002 finding
Cost moves in **opposite directions** by methodology when you remove the runtime requirement:
- **AI-DLC −66%** ($97.97→$33.50): turn-driven ceremony × rule-set re-reads collapsed proportionally without a build loop.
- **Plan Mode −25%** ($31.94→$24.09): research/SDK overhead dropped (fewer web searches, sub-agents).
- **Vibe −10%** ($22.74→$20.36): mostly fixed cost; the sim cycle is a ~10% footnote.
- **OpenSpec +11%** ($20.64→$22.91): spec authoring expanded without runtime gravity to anchor it.
- **Spec Kit +115%** ($14.01→$30.10): run-001's cheapness came from its *refuse-to-build* scope-cut; the no-runtime brief removed that trigger, so it actually shipped → proportional cost.
- **BMAD +80%** ($384.05→$689.47): multi-window lifecycle expanded; now the single most expensive cell in the entire eval.

**The ordering of who's cheap vs expensive is not stable across the brief variant** — what each methodology *spends its budget on* is structurally different, and the no-runtime constraint exposes it. (Folded into `analysis/findings/output-vs-artifacts-axis.md`.)

### 5. BMAD is the output-vs-artifacts headline, sharpened — and the ceremony didn't even buy the lowest defect count
bmad-002 blind code (34.5) is **tied with the no-methodology control (34.5)** and ai-dlc — yet cost **$689 vs vibe's $20** (34×). Blind, the code is the same. On the aware /55, BMAD (42.5) actually scores **below** openspec (45.5) and the $24–34 structured cluster (44.0), and **below** where its spec quality alone would predict: its planning dims are perfect (Spec 5 / Scope 5 / Assumptions 5 — best in the cohort, a 12-page canon doc that *pre-warned the exact GZCLP/nSuns impl traps*), but Product polish is only 13.5/20 and it carries a **severity regression** — 3 Major code-review defects vs run-001's all-Minor:
   - **GZCLP day-index double-advances** (`gzclp.ts:261,348` + `nextDay` both +1 → composed +2): the 4-day rotation becomes A1→A2→A1→A2, **B-days never run**. 683 passing tests missed it (the suite asserts dayIndex only on the skip path, never the finish-composition path).
   - **All 5 native services throw `NotImplementedError`** (timer/haptics/notifications/keep-awake/LiveActivity) — the view layer wires them, so the rest timer would throw on first tick at runtime. Declared-deferred, but "claimed-wired feature throws" is a real gap a no-runtime reviewer wouldn't catch without reading the un-shipped `deferred-work.md`.
   - **The shipped README hides the inertness** — the excellent `deferred-work.md` itemization went to `_bmad-output/` (not shipped); the repo README is the stock Expo template, so a platform-team reviewer reading only the deliverable would badly overestimate what works.

This is the thesis with teeth: **the $689 bought a spec that *correctly predicted* the edge cases — and the implementation shipped two of them as Major defects anyway, while a perfect test suite (683 green) sailed past both.** The document tax bought foresight that didn't convert to shipped correctness. Its value is (B) process-artifacts (the spec/canon docs are genuinely excellent and would be billable consultancy deliverables), not (A) a better-working product — vibe's $20 code scored the same blind and openspec's $23 code scored higher aware.

### 6. spec-kit-002 inverts spec-kit-001
spec-kit run-001 (runtime brief) **refused to build the app** (domain-only, self-scoped on an untested no-sim assumption) → 34/45. spec-kit run-002 (no-runtime brief) **shipped a full app** (44/55, blind 30.0) — because the no-runtime brief made "source as a PR" the explicit deliverable, removing the verify-ability objection that stopped run-001. Same methodology, opposite shipping behavior, driven entirely by how the brief framed verification.

## Caveats
- bmad-002 fully scored: blind 34.5, code-based 42.5, cost $689.47 — all final. (token-log raw splits not backfilled; cost is the operator /status headline.)
- All code-based /55 are PROVISIONAL (single-rater, unblinded). Blind /40 is the 2-rater-confirmed number.
- Blind vs code-based-aware are different measurement conditions — NOT averaged.
- bmad-002's first blind score (21.0) was a VOID mid-flight snapshot; 34.5 is the completed-cell re-score.
- Costs are implied API $ (operator on Pro flat-rate); comparable across cells, not actual billing.
