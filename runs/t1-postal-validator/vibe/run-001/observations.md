# T1 — vibe / run-001 observations

## Binary outcomes
- test_core.py 38/38 · test_cli.py 8/8 · stdlib-only yes

## Quality axis (rubric 0–5; UI/UX/Security n/a for T1)

| # | Dimension | Score | Rationale |
|---|---|---|---|
| 1 | Functionality | 4 | All required behavior works: `validate`/`normalize`, single + stdin-batch CLI, `--json`, exit codes (0 all-valid / 1 any-invalid), country case-insensitivity. Brief edge cases handled. Not 5: unpinned edges aren't *surfaced well* — empty/whitespace stdin exits 0 silently with no "no codes" feedback. |
| 3 | Code quality | 4.5 | Idiomatic, fully typed (`str \| None`, `from __future__`), `__all__`, frozen `ValidationResult` dataclass with `to_dict`, named+commented regex constants, `_VALIDATORS` dispatch table. Clean core/CLI split — core has zero CLI deps. Shows judgment + restraint (partial level-5); shy of a full 5 (no standout abstraction; one `# type: ignore` leans on the valid⇒normalized invariant). |
| 4 | System design | 4 | Clean boundaries: `core` / `cli` / `__main__` / `__init__`. Dispatch dict + per-country validator fns absorb the next obvious requirement (more countries) without rewrite; `ValidationResult` encodes the valid/normalized/error invariant. Not 5: design is sound but no ADR/decision-record for the (admittedly obvious) choices. |
| 7 | Robustness | 4 | Unknown country → graceful invalid result (no traceback); missing `--country` → argparse usage error (exit 2); empty/whitespace stdin → no crash; non-string `code` guarded with `isinstance`; control chars rejected by anchored regex. Thoughtful on unpinned edges (level 4). Not 5: empty stdin is silent rather than messaged; no degrade-under-adverse-conditions story. |
| 9 | Documentation | 3.5 | `--help` accurate and complete (lists country options, `--json`, stdin behavior); error messages name *which* rule failed ("bad outward code", "forbidden inward letter") — the T1-weighted Documentation signals are strong. Thorough module/function docstrings double as usage/design docs. Held below 4: no top-level README and no contributor onboarding flow. |
| 10 | Spec articulation | 0 | Vibe produced no spec/PRD/planning artifact. Per rubric's explicit Vibe rule, no spec artifact → 0. (Docstrings reference `formats.md` as source of truth but that is not a spec.) |
| 11 | Scope clarity | 1 | Only an implicit scope signal — the core docstring's "exactly those in `reference/formats.md` — no more, no less." No explicit in/out-of-scope list and no reasons for cuts. |
| 12 | Assumption surfacing | 0 | No explicit assumption tags / ADRs / decision log. Count: 0. Design decisions exist (UK whitespace handling, batch-JSON-as-array) but none are surfaced as assumptions with what-changes-if-wrong. |

Quality sum: 21/40

## Defects
- Critical: none.
- Major: none.
- Minor (Robustness): empty / whitespace-only stdin exits 0 silently — a user piping an empty file gets no signal that nothing was validated.
- Minor (Robustness): UK validator does `code.replace(" ", "")` (strips *all* spaces), so irregular spacing like `"M  1  1AE"` is accepted/normalized — more lenient than the spec's single optional space (no valid code rejected, no invalid code accepted, so low impact).
- Minor (Code): `_format_plain` returns `result.normalized` (typed `str | None`) under a `# type: ignore[return-value]`, leaning on the valid⇒normalized invariant — latent typing smell, not a runtime bug.

## Cost axis (read token-log.md)
- Implied API cost: **$0.59** · API compute time: **2m 24s** · total tokens: **~372.9K** (3.8K in / 10.8K out / 336.7K cache-read / 21.6K cache-write).
- Cost per binary outcome (÷3): **$0.20** · Quality per dollar: **~35.6** (21 / $0.59) · Quality per 1K tokens: **~0.056** (21 / 372.9).

## Depth / routing
Pure Vibe — no methodology layer and no planning phase. Process was a single straight pass: read `formats.md`, both test files, and `pyproject.toml`; write all four package files in one go; stand up a Python 3.12 venv via `uv`; run pytest (46/46 green on the first run, no rework); do a quick manual CLI sanity check; declare done. Zero process artifacts produced — no spec, PRD, architecture doc, or stories; the session transcript is the only "artifact." Methodology-overhead ratio is n/a (no planning phase). This is the cheap, low-ceremony baseline the structured methodologies are measured against.

## Headline
Quality 21/40 · Cost $0.59 / 2m 24s API compute · Binary 46/46 pass. Clean, correct, idiomatic stdlib-only build that nails the engineering dimensions on the first pass for pennies — but scores near-zero on the planning dimensions (spec/scope/assumptions) because Vibe produces no artifacts, exactly the expected baseline profile.

## What it did well / where it lost points
**Did well:** first-pass green on all 46 tests with no rework; textbook core/CLI separation (`validate`/`normalize` importable with no argparse coupling); idiomatic, fully-typed code with a clean country-dispatch table and a frozen result dataclass; specific, rule-naming error messages and an accurate `--help`; UK rules enforced *exactly* (avoided the spec-drift failure mode); all at ~$0.59 and 2m24s API compute.
**Lost points:** the three planning dimensions — Spec articulation (0), Scope clarity (1), Assumption surfacing (0) — drag the sum down because no artifacts were produced; no README/onboarding caps Documentation; and the only robustness nits are a silent empty-stdin exit and over-lenient UK whitespace stripping.
