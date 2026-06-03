# T1 — ai-dlc / run-001 observations

_Scored independently against the absolute 0–5 anchors in `harness/scoring-rubric.md` +
the T1 overlay. Single-rater, unblinded → **PROVISIONAL** until a blind/second pass
confirms within 1 point._

## Binary outcomes
- test_core.py **38/38** · test_cli.py **8/8** · stdlib-only **yes**
- Bonus: +10 methodology-added stdlib property tests pass (56/56 total). No third-party
  runtime dep; Hypothesis deliberately avoided for a seeded `random` harness.

## Quality axis (rubric 0–5; UI/UX/Security n/a for T1)

| # | Dimension | Score | Rationale |
|---|---|---|---|
| 1 | Functionality | 4.5 | Full contract works: `validate`/`normalize`/`ValidationResult`, CLI single + stdin batch + `--json` + 0/1/2 exit codes + `--help`. Handles unpinned edges well — `--country` case-insensitivity beyond the test set (`ca`→CA), specific `empty postal code` message, clean `unsupported country 'FR'…` message. Short of 5: empty/whitespace-only stdin exits 0 silently with no message (the overlay's exemplar 5-surface left on the table). |
| 3 | Code quality | 4.5 | The dim T1 weights most — exemplary core/CLI split: `_core.py` is pure logic, `cli.py` a thin shell importing `validate`; core is independently importable. Complete type discipline (`from __future__ import annotations`, full hints), frozen `ValidationResult` dataclass, per-country `_normalize_*` + `_NORMALIZERS` dispatch table, named/commented regexes. Idiomatic; a teammate lands changes in 30 min. Not a clean 5 — abstractions are textbook-clean rather than a surprising display of skill. |
| 4 | System design | 4 | Clean layering (`_core` / `cli` / `__init__` public API / `__main__` entry); dispatch table absorbs a 4th country with one entry + one normalizer; `ValidationResult` is an appropriate value object. Held at 4: the valid↔normalized/error invariant isn't enforced (`ValidationResult(True, None, None)` is constructible), and a 270-LOC module gives little room for the 5-level "senior-architecture surprise." |
| 7 | Robustness | 4.5 | Graceful on every unpinned input exercised: unsupported country (no traceback), empty input, missing `--country` (argparse usage error, exit 2), embedded control chars (tab → invalid w/ reason), mixed-validity batch (per-line, order preserved, exit 1). Defensive `isinstance` guards on `code`/`country` = defense-in-depth. Short of 5: batch buffers all results in memory and `BrokenPipeError` (e.g. `… | head`) is unhandled; no IO-failure/resource degradation story. |
| 9 | Documentation | 4.5 | README gives clone→run→test onboarding with library + CLI examples and exit-code table; `--help` is accurate and lists countries, `--json`, and stdin behavior; comments explain the non-obvious *why* (inward = final 3 chars; `__future__` for 3.9). Decision records anticipate the next question (considered-X-chose-Y: the PBT-09 Hypothesis→stdlib deviation; the 3.9-vs-3.11 runtime call). Short of 5: invalid-code errors name the country but not the *specific failing rule*, and the considered-alternatives content lives in aidlc-docs, not the README. |
| 10 | Spec articulation | 4.5 | `requirements.md` adds real content beyond restating `formats.md`: exit-code semantics, NFRs, explicit out-of-scope, the CLI contract, and PBT requirements — a different engineer could build to it. Decisions carry rationale with alternatives weighed (Hypothesis vs stdlib; Security opt-out; 3.9 vs 3.11). Genuine pre-impl foresight: it predicted the Python-3.9 runtime hazard and pre-empted it with `__future__` annotations. Short of 5: the foresight is mostly environmental, not prediction of subtle validation edge cases (e.g. the "inward always final 3 chars" parsing subtlety isn't flagged in the spec). Note: for a 3-country validator this spec is arguably *over*-specified — itself a cost signal. |
| 11 | Scope clarity | 4.5 | In/out scope listed with reasons (`requirements.md` Out of Scope; `execution-plan.md` documents every SKIP with a rationale). Actively defended: explicitly declined to add real-world UK rules beyond the simplified set (sidestepping the T1 spec-drift trap) and scoped extensions down (Security off, PBT partial). Scope/approach revisited as new info surfaced — PBT framework reconsidered when the stdlib-only constraint surfaced the conflict; 3.9-compat decided on environment detection. Not a clean 5: the revisited decisions are extension/runtime calls, not core feature scope. |
| 12 | Assumption surfacing | 4 | Count ≈ 5 documented decisions (Security opt-out, PBT mode, approval cadence, 3.9 compat, PBT-09 framework deviation) across `verification-questions.md`, the `aidlc-state.md` Extension table, and `audit.md` — decision-log lines, not literal `[ASSUMPTION]` tags. Quality: each names a choice + what depends on it (level 3 met); the 3.9 decision is mapped to a concrete code location (`from __future__ import annotations` in every module — level-5 flavor). Held at 4: loosely grouped (extensions/NFRs) rather than the systematic technical/product/user categorization, and not all are code-mapped. |

**Quality sum: 35/40**  ·  vector **(Product 9/10, Rigor 26/30)** — Product = Functionality+Robustness (UI/UX n/a); Rigor = Code+SysDesign+Doc+Spec+Scope+Assumptions (Security n/a).

## Defects
- **Critical:** none. (All 46 pinned tests pass; no wrong-answer found — `W1A 1AA` validates, `123456789` correctly rejected, no UK over-constraint.)
- **Major:** none.
- **Minor (1):** empty/whitespace-only stdin exits 0 with no output or message — defensible, but the overlay names a clear empty-stdin message as the 5-surface. *(Robustness — M)*
- **Minor (2):** invalid-code error names the country but not the specific failing rule (e.g. "invalid CA postal code: 'D1A 0B1'" rather than "first letter D not allowed"). *(Missed-req — M)*
- **Minor (3):** batch mode buffers all results in memory before printing and does not handle `BrokenPipeError` on a truncated downstream pipe. *(Robustness — R)*
- Latent (not counted): `ValidationResult` is constructible in inconsistent states (invariant not enforced). *(R)*
- Totals: `critical: 0, major: 0, minor: 3 (M: manual / R: review)` · ≈ **11 defects/1KLOC** (272 impl LOC), all minor.

## Cost axis (from token-log.md)
- Implied **$4.57** (Opus 4.7 API rates) · API compute **12m 52s** · total tokens **~4.59 M** (4.4 M cache-read dominates — AI-DLC re-reads its rule-set/aidlc-docs each turn).
- Cost / binary outcome (÷3): **$1.52**
- Quality / $: 35 / 4.57 = **7.7 per dollar**
- Quality / 1K-tok: 35 / 4,590 = **0.0076** (very low — token bloat from cache re-reads)
- Quality / API hour: 35 / 0.214 h = **~163**
- Methodology-overhead ratio (planning ÷ implementation): **≈ 0.8** wall-clock proxy (~6m inception : ~7.8m construction; ≈ 44% of the session pre-implementation). Phase-level API-compute split not captured in token-log — flagged as a gap.

## Depth / routing
AI-DLC ran its **full lifecycle skeleton but self-pruned aggressively**: it executed 5 stages
(Workspace Detection → Requirements Analysis → Workflow Planning → Code Generation → Build &
Test) and explicitly SKIPPED 8 (Reverse Engineering, User Stories, Application Design, Units
Generation, Functional Design, NFR Requirements [folded], NFR Design, Infrastructure Design),
each skip with a one-line rationale in the execution plan. This is the AI-DLC analogue of
BMAD routing to a trimmed lifecycle rather than pure quick-dev — right-sized *within* the
framework, but it still produced **12 process artifacts** (requirements, mermaid execution
plan, verification questions, code-gen plan, code summary, 5 build-and-test docs, audit log,
state file) totaling ~700 doc-lines for a 272-LOC implementation. Operator load was light:
**0 corrective interventions**; 2 designed approval gates answered (extension opt-in + plan
approval). Per the accept-adaptive policy, the self-pruning is a *feature*, not a defect — but
the residual ceremony is the cost story.

## Headline
**Quality 35/40 (Product 9/10, Rigor 26/30) · Cost $4.57 / 12m 52s API / ~4.59 M tok · Binary 3/3 (+10 bonus PBT).** A near-ideal, fully-green implementation with a textbook core/CLI split and genuine pre-impl foresight — but the full inception+construction ceremony cost $4.57 and 4.59 M tokens for a task whose code a cheap baseline could plausibly match.

## What it did well / where it lost points
**Did well:** exemplary core/CLI separation (pure `_core`, thin `cli`) — exactly the dim-3 structure T1 rewards; complete type discipline; all 46 pinned tests + 10 self-added stdlib property tests pass; resisted the UK spec-drift trap; honored stdlib-only even for PBT (chose a seeded `random` harness over Hypothesis and documented why); caught the 3.9-vs-3.11 runtime mismatch before coding and pre-empted it. Robust on every unpinned input thrown at it.
**Lost points:** no dimension reaches a clean 5 — invalid-code errors aren't per-rule specific, empty stdin exits silently, batch buffers in memory / ignores broken pipe, `ValidationResult` invariants are unenforced, and assumptions aren't systematically categorized. The cost axis is the real cost: ~4.59 M tokens (cache-read-dominated) and ~44% of the session spent planning a 3-country validator whose spec was already exhaustively pinned — the clearest T1 read on the ceremony tax buying polish-but-not-correctness over a cheap baseline.
