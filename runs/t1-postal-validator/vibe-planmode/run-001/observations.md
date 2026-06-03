# T1 — vibe-planmode / run-001 observations

*Provisional: scored unblinded, single-rater, on the rubric's absolute 0–5 anchors. UI/UX/Security n/a for T1.*

## Binary outcomes
- test_core.py **38/38** · test_cli.py **8/8** · stdlib-only **yes** (runtime: `dataclasses`, `re`, `argparse`, `json`, `sys`; zero runtime deps in pyproject; pytest dev-only)

## Quality axis (rubric 0–5; UI/UX/Security n/a for T1)

| # | Dimension | Score | Rationale |
|---|---|---|---|
| 1 | Functionality | **4.5** | Full contract works: `validate`/`normalize`, single + stdin-batch CLI, `--json`, exit codes (0 all-valid / 1 any-invalid), unsupported country → invalid not raise, `normalize` raises `ValueError`. Handles unpinned edges well: lowercase `--country` works (the success-criteria's named 5-marker — case-insensitivity beyond the test set), whitespace/blank stdin lines skipped, control chars (NUL) rejected cleanly. Short of a clean 5 because the *other* named 5-marker — a clear message for empty stdin — is unmet: empty stdin is silently exit-0, and nothing extra is surfaced. |
| 3 | Code quality | **4.5** | Idiomatic and clean: core/CLI cleanly separated (`core.py` has **zero** argparse — the pure validator the T1 detail asks for; `cli.py` is a thin shell over `validate`). Frozen `ValidationResult` dataclass, `_ok`/`_fail` helpers, module-load-compiled regexes, country→validator dispatch dict, full type hints (`from __future__ import annotations`, `str | None`), docstrings, section comments. One blemish keeps it off 5: `_emit` and `_emit_batch_line` are near-duplicates differing only in stderr-vs-stdout for invalid output — a small un-DRY spot a 5 would have parameterized. |
| 4 | System design | **4.0** | Clean module boundaries (core / cli / `__init__` public re-export / `__main__` entry). Dispatch dict means a 4th country = one validator + one dict line, no rewrite — absorbs the next obvious requirement. Held at 4: no in-code ADR/decision comment for the non-obvious choices, and `ValidationResult` doesn't *structurally* enforce the valid↔normalized / invalid↔error invariant (it's upheld by the `_ok`/`_fail` convention, not the type). |
| 7 | Robustness | **4.0** | Meets every named 4+ criterion: empty/whitespace stdin (no crash), unsupported country (clean `INVALID:` message, not a traceback), missing `--country` / no subcommand (argparse usage error, exit 2), control chars and tab/double-space rejected cleanly, mixed-validity batch works. Encoding edge (anchor-4) handled. Held at 4, not 5: does **not** degrade gracefully under unmentioned I/O — a large batch piped to a closing reader (`| head`) raises a `BrokenPipeError` traceback (verified). |
| 9 | Documentation | **3.0** | Strong on the surfaces T1 weights: `--help` accurate at both levels, country-specific error messages name *which* rule failed ("bad outward code", "forbidden inward letter") — short and specific, not bare "invalid". Module + function docstrings; comments explain the CA letter restrictions (the surprising "why"). Capped at 3: **no README** and no contributor onboarding flow (anchor 4); top-level `--help` lists only the `validate` subcommand, so country options / `--json` live one level down under `validate --help`. |
| 10 | Spec articulation | **3.5** | One planning artifact: a ~95-line plan (`~/.claude/plans/…truffle.md`). Genuinely a build blueprint — derives the contract from the tests, lays out file structure, per-module design with the actual regexes + rationale ("US needs no uppercasing — internal space / 9-no-hyphen / letters all fail naturally"), a CLI behavior table, and a verification section (pytest + 5 smoke checks + stdlib confirmation) that reads as acceptance criteria. A different engineer could rebuild from it → solid 3; decisions-with-rationale push toward 4. Held at 3.5: no *explicit* alternatives weighed, and no demonstrated edge-prediction foresight (the contract was handed to it by the tests). Notably **not** over-ceremonied for a 3-country validator. |
| 11 | Scope clarity | **2.0** | Lists what's *in* scope clearly (the four files, the contract, the stdlib-only constraint) and shows scope awareness in one spot (error strings kept minimal because "tests only assert truthy"). But there is **no explicit out-of-scope statement** and no reasons-for-cuts — scope boundaries are implicit ("the contract is fully fixed… no behavioral ambiguity remains"). Fits anchor 2: in-scope listed, out-of-scope implicit. |
| 12 | Assumption surfacing | **1.0** | **Count: 0 explicit assumption tags / ADR entries / decision-log lines.** No `[ASSUMPTION]` mechanism was produced. A couple of design decisions carry assumption-quality reasoning (minimal error strings tied to what the tests assert; UK "remove all internal whitespace" as the optional-space interpretation), but they're framed as choices, not surfaced assumptions, and none say "what changes if this is wrong." Above a flat 0 only because those implicit decisions name real choices. |

**Quality sum: 26.5 / 40**
*(Vector — Product polish [Functionality + Robustness] = 8.5/10; Engineering rigor [Code + Design + Doc + Spec + Scope + Assumptions] = 18.0/30. UI/UX/Security excluded as n/a.)*

## Defects
*critical: 0 · major: 0 · minor: 3 (R: review-found). ~199 LOC package → ~15 minor defects/1KLOC, all latent/low-severity.*
- **Critical:** none.
- **Major:** none.
- **Minor** (Robustness, review): batch output to a closed pipe (`… | head` on a large batch) raises an uncaught `BrokenPipeError` traceback — no SIGPIPE/broken-pipe handling. Verified.
- **Minor** (Documentation, review): no README in the repo; top-level `--help` surfaces only the `validate` subcommand, so the country options and `--json`/stdin behavior appear only under `validate --help`.
- **Minor** (Code quality, review): `_emit` / `_emit_batch_line` are near-identical (differ only in invalid→stderr vs invalid→stdout) — small duplication.

## Cost axis (read token-log.md)
- **Implied $:** **$1.07** (Opus 4.7 $0.98 + auxiliary Haiku 4.5 $0.095; Haiku ~9% here, from the Explore subagent — atypically non-trivial, flag for cross-cell).
- **API compute time:** **3m 57s** (scored). Wall-clock 5m 02s incl. operator idle + a forced `.venv` setup (box had only Python 3.9).
- **Total tokens:** **~850.9 K combined** (Opus ~587.2 K + Haiku ~263.7 K).
- **Cost per binary outcome (÷3):** **$0.36**.
- **Quality per $:** 26.5 / 1.07 ≈ **24.8 quality/$**.
- **Quality per 1K tokens:** 26.5 / 850.9 ≈ **0.031** (combined); ≈ 0.045 on Opus-only tokens.
- *(Quality per API hour: 26.5 / 0.0658 h ≈ 403. Methodology-overhead ratio: plan phase was ~1 min of a ~4 min compute run — modest, no per-phase /status breakdown captured.)*

## Depth / routing
vibe-planmode = plain Vibe with a single plan-mode gate. It routed to the lightest sensible process: one Explore subagent read the scaffold, then it wrote **one** ~95-line design plan (no PRD, no architecture doc, no stories), exited plan mode at the operator's approval, and one-shot all four package files. Tests passed 46/46 on the first run (after creating a venv), followed by manual CLI smoke checks. The single artifact is right-sized — it functions as a real build spec (contract derivation + per-module regex design + a verification checklist) rather than ceremony bolted onto a trivial task; the methodology correctly recognized "the contract is fully fixed by the spec + tests — no behavioral ambiguity remains" and did not over-specify. Per accept-adaptive policy this low ceremony is the expected, legitimate outcome, not a defect.

## Headline
**Quality 26.5/40 · $1.07 / 3m57s API · Binary 3/3.** Vibe-planmode buys a genuinely well-built CLI (clean core/CLI split, specific error messages, solid `--help`) for ~$1 and ~4 min — the one plan-mode step produced a useful blueprint without over-ceremony; the points it loses are almost all in the *articulation* tail (scope/assumptions barely surfaced) and a missing README, not in the engineering.

## What it did well / where it lost points
**Did well:** Textbook core/CLI separation — `validate`/`normalize` are pure and independently importable, the CLI is a thin argparse shell (exactly what T1's dim-3 detail rewards). Stdlib-only with no dependency creep. Country-specific, rule-level error messages. Graceful on every bad input the brief and tests imply (empty stdin, unknown country, missing flag) — no tracebacks on the documented surface. The plan was appropriately scoped: a real design doc, not bloat. Implementation was correct first try (46/46), cheaply (~$1.07, ~4 min compute).

**Where it lost points:** The articulation dimensions are thin — no explicit out-of-scope statement (Scope 2.0) and zero surfaced assumptions/ADRs (Assumptions 1.0); the plan documents *decisions* but never frames the bets it's making. No README caps Documentation at 3. The one real latent bug is an uncaught `BrokenPipeError` on piped large-batch output (interrupted I/O), which — together with no in-code ADRs and the convention-only invariant on `ValidationResult` — keeps Robustness and System design at 4 rather than 5. A small `_emit` duplication is the only code-quality blemish.
