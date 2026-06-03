---
title: 'Postal-code validator + CLI (CA / US / UK)'
type: 'feature'
created: '2026-05-27'
status: 'done'
baseline_commit: 'NO_VCS'
context:
  - '{project-root}/reference/formats.md'
  - '{project-root}/tests/test_core.py'
  - '{project-root}/tests/test_cli.py'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** There is no implementation behind the `postal_validator` package that the existing test suite imports — `validate`, `normalize`, `ValidationResult`, and the `python -m postal_validator` CLI all need to exist and behave per `reference/formats.md`.

**Approach:** Build a stdlib-only package: a small core module (per-country validators driven by the format rules) exposing `validate`/`normalize`/`ValidationResult`, plus a `__main__` CLI wrapping the core with single-code, stdin-batch, `--json`, and exit-code behavior.

## Boundaries & Constraints

**Always:**
- Standard library only — no third-party runtime deps.
- Python 3.9-compatible (`from __future__ import annotations`; no `match`, no PEP 604 at runtime).
- Validation is case-insensitive and ignores leading/trailing whitespace.
- Country code is case-insensitive; unsupported country → invalid `ValidationResult` (never raises).
- Enforce the format rules **exactly** as written in `reference/formats.md` — no extra real-world constraints.
- `normalize()` raises `ValueError` on invalid input; `validate()` never raises for bad codes/countries.

**Ask First:**
- Any deviation from the rules in `reference/formats.md` or the contract in the test files.

**Never:**
- Internationalize beyond CA/US/UK.
- Add network access, config files, or logging frameworks.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| CA valid, no space | `validate("k1a0b1","CA")` | `valid=True`, `normalized="K1A 0B1"`, `error=None` | N/A |
| CA bad first letter | `validate("D1A 0B1","CA")` | `valid=False`, `normalized=None`, non-empty `error` | reason string |
| US ZIP / ZIP+4 | `validate(" 90210 ","US")` | `valid=True`, `normalized="90210"` (trimmed, unchanged) | N/A |
| US 9 digits no hyphen | `validate("123456789","US")` | `valid=False`, non-empty `error` | reason string |
| UK no space | `validate("ec1a1bb","UK")` | `valid=True`, `normalized="EC1A 1BB"` | N/A |
| UK bad inward letter | `validate("EC1A 1CB","UK")` | `valid=False`, non-empty `error` | reason string |
| Unknown country | `validate("12345","FR")` | `valid=False`, non-empty `error` | no raise |
| `normalize` invalid | `normalize("1234","US")` | — | raises `ValueError` |
| CLI valid | `validate k1a0b1 --country CA` | prints `K1A 0B1`, exit 0 | N/A |
| CLI invalid | `validate "D1A 0B1" --country CA` | exit 1 | N/A |
| CLI `--json` | `validate 12345 --country US --json` | JSON `{valid, normalized, error}`, exit 0/1 | N/A |
| CLI stdin batch | no code, codes on stdin | one result line per input; valid→normalized, invalid→contains `INVALID`; exit 1 if any invalid else 0 | per-line |
| CLI `--help` | `--help` | usage text, exit 0 | argparse |

</frozen-after-approval>

## Code Map

- `postal_validator/__init__.py` -- public API surface: re-export `validate`, `normalize`, `ValidationResult`.
- `postal_validator/_core.py` -- `ValidationResult` dataclass + per-country validate/normalize logic (CA/US/UK rules).
- `postal_validator/__main__.py` -- CLI: argparse, single-code + stdin batch, `--json`, exit codes.
- `tests/test_core.py`, `tests/test_cli.py` -- existing acceptance gate (do not modify).
- `pyproject.toml` -- lower `requires-python` to `>=3.9` to match the 3.9 target.

## Tasks & Acceptance

**Execution:**
- [x] `postal_validator/_core.py` -- implement `ValidationResult` (dataclass: `valid`, `normalized`, `error`) and `validate`/`normalize`; route by uppercased country to CA/US/UK validators enforcing `formats.md` rules; trim+upcase handling per country.
- [x] `postal_validator/__init__.py` -- re-export `validate`, `normalize`, `ValidationResult` (and `__all__`).
- [x] `postal_validator/__main__.py` -- argparse `validate` subcommand with positional `code` (optional) and `--country` (required) and `--json`; single-code path prints normalized / JSON; stdin batch when no code; exit 0 all-valid, 1 if any invalid; unknown country → nonzero.
- [x] `pyproject.toml` -- set `requires-python = ">=3.9"`.

**Acceptance Criteria:**
- Given the repo, when `python -m pytest` runs, then all tests in `tests/` pass under Python 3.9.
- Given a valid code on the CLI, when run without `--json`, then stdout is exactly the normalized form and exit code is 0.
- Given mixed validity on stdin, when run in batch mode, then each line maps to one output line and the process exits 1.

## Spec Change Log

## Design Notes

- **CA:** strip spaces/upcase → 6 chars `ANANAN` shape. First letter ∈ `ABCEGHJKLMNPRSTVXY`; other two letters ∈ `ABCEGHJKLMNPRSTVWXYZ` (excludes `DFIOQU`). Normalized = `XXX XXX` (space after 3rd char), e.g. `H0H0H0` → `H0H 0H0`.
- **US:** trimmed input must fully match `^\d{5}(-\d{4})?$`. Normalized = the trimmed input unchanged. Internal whitespace / letters / 9-digit-no-hyphen all invalid.
- **UK:** strip *all* spaces, upcase. Inward = last 3 chars (`^[0-9][A-Z]{2}$`, inward letters not in `CIKMOV`); outward = the rest (`^[A-Z]{1,2}[0-9][A-Z0-9]?$`). Normalized = `OUTWARD INWARD`.

## Verification

**Commands:**
- `python -m pytest` -- expected: all tests pass, 0 failures.
- `python -m postal_validator validate k1a0b1 --country CA` -- expected: prints `K1A 0B1`, exit 0.
- `printf 'K1A 0B1\nD1A 0B1\n' | python -m postal_validator validate --country CA` -- expected: line 1 `K1A 0B1`, line 2 contains `INVALID`, exit 1.

## Suggested Review Order

**Public API & contract**

- Entry point — start here: dispatch by country, never-raise guards, unsupported→invalid.
  [`_core.py:101`](../../postal_validator/_core.py#L101)

- Result type the whole package returns; `.valid` / `.normalized` / `.error` semantics.
  [`_core.py:19`](../../postal_validator/_core.py#L19)

- `normalize` raises `ValueError` on invalid; explicit guard (no `assert`, `-O`-safe).
  [`_core.py:120`](../../postal_validator/_core.py#L120)

**Per-country validation logic** (highest-risk — the actual rules)

- CA: shape + first/other letter sets; single-optional-space whitespace gate.
  [`_core.py:49`](../../postal_validator/_core.py#L49)

- UK: last-3 inward split, outward/inward regexes, forbidden inward letters, space gate.
  [`_core.py:73`](../../postal_validator/_core.py#L73)

- US: ZIP / ZIP+4 regex on trimmed input; normalized unchanged.
  [`_core.py:66`](../../postal_validator/_core.py#L66)

**CLI**

- `main`: single-code vs stdin-batch dispatch, `--json`, exit-code derivation.
  [`__main__.py:63`](../../postal_validator/__main__.py#L63)

- Argparse surface: `validate` subcommand, optional `code`, required `--country`, `--help`.
  [`__main__.py:26`](../../postal_validator/__main__.py#L26)

**Peripherals**

- Public re-exports.
  [`__init__.py:10`](../../postal_validator/__init__.py#L10)

- `requires-python` lowered to `>=3.9` to match the runtime target.
  [`pyproject.toml:5`](../../pyproject.toml#L5)
