# analysis/t1-postal-validator/

t1 — Postal-code validator + CLI (Python, low complexity / low ambiguity — the greenfield floor)

## Status

✅ **HEXAD COMPLETE — all 6 methodologies scored 2026-05-27.** See [`scoring-matrix.md`](scoring-matrix.md).

Headline: every cell clears the bar (46/46 tests, stdlib-only, 0 critical/0 major, 3/3 binary). Quality spreads 21 → 36/40 — almost entirely in the planning/rigor cluster (spec/scope/assumptions); CLI usability is tight (11.5–14/15). Cost spreads 7.7× ($0.59 → $4.57). **Ceremony on a trivial task buys documentation of intent, not a better program.** Spec Kit leads quality (36); OpenSpec is the cost-efficiency frontier; BMAD self-routed to quick-dev while AI-DLC ran full ceremony on the same task.

| Cell | Quality /40 | Cost | Binary | Routing |
|---|:--:|:--:|:--:|---|
| Vibe | 21 | $0.59 | 3/3 | none |
| Plan Mode | 26.5 | $1.07 | 3/3 | 1 plan |
| OpenSpec | 32.5 | $1.32 | 3/3 | full propose→apply |
| Spec Kit | 36 | $4.20 | 3/3 | full pipeline |
| AI-DLC | 35 | $4.57 | 3/3 | full (self-pruned) |
| BMAD | 31 | $4.00 | 3/3 | quick-dev (self-routed) |

## Inputs

- Task brief: `../../tasks/t1-postal-validator/brief.md` · reference: `../../tasks/t1-postal-validator/reference/`
- Per-cell: `../../runs/t1-postal-validator/<methodology>/run-001/{observations,test-result,token-log,session-log}.md`

## Companion analyses (both complete 2026-05-27)

- [`feature-matrix.md`](feature-matrix.md) — CLI-affordance audit. Finding: the *shipped* artifact converges completely (identical contract + idioms; the same two unpinned gaps — empty-stdin, BrokenPipe — missed by all six). Only AI-DLC shipped extras (README + property-based tests); error-message quality does NOT track ceremony (heaviest planner AI-DLC has the weakest messages).
- [`blind-pass-audit.md`](blind-pass-audit.md) — independent blind second-rater on the 5 code-visible dims (6 anonymized code-only bundles, fresh reviewers). Finding: blind, the code dims compress to 21–23/25 with the **no-methodology control (Vibe) at the top** — methodology-blind you can't tell the control's code from the structured cells'. Spec Kit drops most (its first-pass Doc was inflated by planning artifacts the dimension shouldn't count). Reinforces: the quality gap is the planning dims, not the code.

## Still open
- Apply (or not) the blind-pass adjustments — operator call (T4 precedent: disclose + keep provisional).
