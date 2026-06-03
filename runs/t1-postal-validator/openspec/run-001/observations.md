# T1 — openspec / run-001 observations

_Provisional: scored unblinded, single-rater. Confirm with a blind/second-rater pass before treating as final._

## Binary outcomes
- test_core.py 38/38 · test_cli.py 8/8 · stdlib-only yes

## Quality axis (rubric 0–5; UI/UX/Security n/a for T1)

| # | Dimension | Score | Rationale |
|---|---|---|---|
| 1 | Functionality | 4.5 | validate/normalize + full CLI contract (single, --json, stdin batch, exit codes) all work; 46/46. Beyond the pinned set it generalizes case-insensitivity to *all* countries (`.strip().upper()`; tests only pin lowercase us/ca) and degrades cleanly on unknown/missing country. Short of a clean 5: empty/whitespace-only stdin exits 0 *silently* — the one anchor-5 exemplar ("clear message for empty stdin") is not surfaced. |
| 3 | Code quality | 4.5 | Idiomatic, fully type-hinted (`from __future__ import annotations`), frozen dataclass, short functions, intentional names. Clean per-country validators returning `(normalized|None, error|None)`; excluded-letter sets baked directly into regex char-classes with comments tying them to the spec; `assert ... # for type-checkers` is a nice touch. Restraint over a tiny task. Just shy of 5 — competent-clean rather than a genuine "surprise of skill." |
| 4 | System design | 4.5 | Clean boundaries: `core.py` (pure logic, zero I/O) / `cli.py` (I/O) / `__init__.py` (public API) / `__main__.py` (entry). Dict dispatch absorbs a 4th country trivially; design.md documents the non-obvious decisions (dataclass-vs-NamedTuple, regex-mirrors-spec, batch-JSON scoping) with alternatives — meeting most of anchor 5. Held at 4.5: the `ValidationResult` dataclass doesn't structurally enforce the valid⟺normalized invariant (an inconsistent result can be constructed directly; it's enforced only by convention in `validate`). |
| 7 | Robustness | 4 | All brief/test bad inputs handled with specific messages. Manually exercised unpinned edges: empty stdin → exit 0 no crash; whitespace-only lines skipped; missing `--country` → argparse usage error (exit 2); unknown country → clean `INVALID: unsupported country: 'FR'` (exit 1, plain + --json); no subcommand → usage error. No tracebacks anywhere. Not 5: no handling of exotic degradation (broken pipe, huge input) and empty stdin is silent rather than messaged. |
| 9 | Documentation | 3.5 | Strong decision records (design.md: rationale + alternatives + risks + open questions), module/function docstrings everywhere, accurate `--help` (lists the `validate` subcommand, `--country CA/US/UK`, `--json`, stdin behavior), and specific error messages naming the failed rule. Capped below 4: **no top-level README** — setup/run/test instructions live only in pyproject + `--help` (running the suite even required discovering `uv`); no consolidated contributor onboarding. |
| 10 | Spec articulation | 4.5 | proposal.md + design.md + two EARS spec files (WHEN/THEN scenarios) + 18-task tasks.md. Anchor 4 clearly met (decisions documented with rationale; NamedTuple alternative rejected explicitly). Real foresight toward 5: design.md's Risks/Open-Questions predicted the actual impl pitfalls — batch-mode `--json` ambiguity (proactively scoped out), regex char-class drift, UK outward/inward inference. Not a clean 5 because the agent read the test files first, so part of the "foresight" is transcription of a known contract, and the two spec files largely restate `formats.md`. |
| 11 | Scope clarity | 4 | Explicit Goals/Non-Goals with reasons (real-world UK completeness out; countries beyond CA/US/UK out → invalid not error; output formats beyond plain/--json out). Goes past a bare 3 by proactively cutting batch-mode `--json` and framing it conditionally ("revisit only if a JSON-batch requirement emerges"). Not 5: no new information actually surfaced to trigger a revisit, and there was no scope-creep pressure to push back on (fully-specified task, zero clarifying Qs). |
| 12 | Assumption surfacing | 3 | ~5 documented items (4 Risks/Trade-offs + 1 Open Question), each naming a real choice and its mitigation; the batch-JSON open question names what would change if revisited. Anchor 3 (choice + consequence) substantially met. Not 4/5: framed as risk-mitigations rather than tagged assumptions, not categorized (technical/product/user), and not mapped to specific code locations. |

Quality sum: **32.5/40**  ·  vector — Product (Functionality + Robustness) **8.5/10**, Rigor (Code + Design + Docs + Spec + Scope + Assumptions) **24/30**.

## Defects
- **Critical:** none.
- **Major:** none.
- **Minor** (Robustness, R): empty / whitespace-only stdin in batch mode produces a silent exit 0 — no "no input" feedback. Benign, not a crash.
- **Minor** (Documentation, Missed-req): no top-level README; running the test suite required discovering `uv` (no system 3.11+/pytest).
- **Minor** (Robustness, R-latent): `ValidationResult` frozen dataclass allows constructing inconsistent states (`valid=True, normalized=None`); invariant upheld only by convention in `validate()`. No user-facing impact.

Totals: critical 0, major 0, minor 3 (T:0 / M:1 / R:2). defects/1KLOC ≈ 3/0.199 ≈ **15 per 1KLOC** (199 LOC impl).

## Cost axis (read token-log.md)
- **Implied $:** $1.32 (Opus 4.7; 6.5K in, 20.6K out, 1.0M cache-read, 43.9K cache-write — rates in token-log)
- **API compute time:** 4m 25s (wall 8m 13s, disclosed)
- **Total tokens:** ~1.07 M
- **Cost / binary outcome (÷3):** $0.44
- **Quality / $:** 32.5 / 1.32 ≈ **24.6 quality-points per dollar**
- **Quality / 1K tokens:** 32.5 / 1070 ≈ **0.030**
- **Quality / API hour:** 32.5 / 0.0736 h ≈ **441** (context)
- **Methodology overhead ratio:** not separately instrumented per phase; by wall clock propose (~11:56→11:58) ≈ apply (~11:59→12:01), roughly 50/50 planning vs implementation — a real but absolutely tiny ceremony tax (total 4m25s API).

## Depth / routing
OpenSpec ran its **full standard spec-driven lifecycle**, not a shortcut: `/opsx:propose` produced four planning artifacts — proposal.md (why + capabilities), design.md (decisions/risks/open-questions), two EARS spec files (`postal-validation`, `postal-cli`, with WHEN/THEN scenarios), and an 18-item tasks.md — then `/opsx:apply` implemented the package, ran the suite, and checked off all tasks (no `archive` step in this run). It did not self-select a lighter path. For a fully-specified 3-country validator this is moderate-to-high ceremony: the design.md earns its keep (genuine decisions — frozen dataclass, regex-mirrors-spec, conditional batch-JSON scoping — and foresight on the real impl edge cases), but the two EARS spec files are largely a restatement of `formats.md` and the already-present test contract, which is the over-specification cost signal T1 is built to catch. The payoff vs. a bare baseline shows up as a clean core/CLI split and documented decisions, not as a materially different green bar.

## Headline
Clean, fully-passing implementation (46/46, stdlib-only) at low cost ($1.32 / 4m25s API) → strong quality-per-dollar (~24.6). The SDD ceremony bought a genuinely useful design.md and a tidy core/CLI separation; its EARS spec files mostly re-state the brief. Quality 32.5/40 (Product 8.5/10, Rigor 24/30), 0 critical/major defects.

## What it did well / where it lost points
**Did well:** zero spec drift (UK rules enforced *exactly*, regexes mirror `formats.md` line-for-line); textbook core/CLI separation (pure, importable `core.py`); graceful on every unpinned input I tried (no tracebacks); specific, rule-naming error messages; a design.md that documents real decisions + alternatives and predicted the implementation's actual ambiguities (batch-`--json`); right-sized regexes and dispatch with restraint; passed the suite on the first run.
**Lost points:** no top-level README / contributor onboarding (caps Documentation); empty-stdin handled silently rather than surfaced (caps Functionality + a minor Robustness defect); `ValidationResult` invariant enforced only by convention; the two EARS spec files add limited value over `formats.md` + the test files (the visible over-ceremony for a trivial, fully-specified task); assumptions surfaced as risk-mitigations rather than categorized, code-mapped assumption tags.
