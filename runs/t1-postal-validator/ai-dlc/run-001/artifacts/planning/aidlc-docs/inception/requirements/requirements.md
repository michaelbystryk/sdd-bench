# Requirements — postal_validator

## Intent Analysis Summary
- **User Request**: Implement a Python package `postal_validator` that validates and normalizes
  postal codes for Canada (CA), the United States (US), and the United Kingdom (UK) per
  `reference/formats.md`, plus a small CLI. The provided `tests/` must pass.
- **Request Type**: New Project (greenfield implementation against a fixed spec).
- **Scope Estimate**: Single Component — one Python package (`postal_validator`) with a core
  module and a CLI entry point.
- **Complexity Estimate**: Simple — pure-function parsing/validation, no I/O beyond stdin/stdout,
  no external dependencies.
- **Depth**: Minimal (requirements fully pinned by `reference/formats.md` + the test contract).

## Authoritative Sources
- `reference/formats.md` — the exact, complete validation rules (do not add constraints beyond these).
- `tests/test_core.py` — contract for `validate()` / `normalize()` / `ValidationResult`.
- `tests/test_cli.py` — contract for the CLI (`python -m postal_validator ...`).

## Functional Requirements

### FR-1: Public API
- `validate(code: str, country: str) -> ValidationResult`
- `normalize(code: str, country: str) -> str`
- `ValidationResult` exposes `.valid: bool`, `.normalized: str | None`, `.error: str | None`.
- `ValidationResult`, `validate`, `normalize` are importable from the top-level package
  (`from postal_validator import ValidationResult, normalize, validate`).
- `validate` never raises for bad input or unsupported country — it returns an invalid result.
- `normalize` raises `ValueError` for invalid input; returns the canonical string for valid input.

### FR-2: Country handling
- `country` ∈ {`CA`, `US`, `UK`}, **case-insensitive** (`"us"` == `"US"`).
- Any other country value → invalid result (`valid=False`, `error` set, `normalized=None`); never raise.

### FR-3: Input handling (all countries)
- Validation is **case-insensitive**.
- **Leading/trailing whitespace** is ignored.
- Normalization returns the canonical **uppercased** form with a single separating space where applicable.

### FR-4: Canada rules (`CA`)
- Shape `ANA NAN`: letter, digit, letter, (optional single space), digit, letter, digit. 6 alphanumerics.
- Letters never include `D F I O Q U`. First letter additionally excludes `W` and `Z`.
  - First letter ∈ `A B C E G H J K L M N P R S T V X Y`.
  - Other two letters ∈ `A B C E G H J K L M N P R S T V W X Y Z`.
- Digits `0`–`9` in all three digit positions.
- Internal space optional on input. **Normalized**: uppercase, single mid space, e.g. `K1A 0B1`.

### FR-5: United States rules (`US`)
- `NNNNN` (5-digit ZIP) **or** `NNNNN-NNNN` (ZIP+4). Digits only; `+4` must be hyphen-preceded.
- Invalid: ≠5 leading digits; 9 digits with no hyphen; any letters; internal whitespace.
- **Normalized**: the trimmed input unchanged, e.g. `90210`, `12345-6789`.

### FR-6: United Kingdom rules (`UK`) — simplified, enforce exactly these three constraints
- Outward + separating space (optional on input) + 3-char inward; inward is always the final 3 chars.
- Outward matches `^[A-Z]{1,2}[0-9][A-Z0-9]?$`.
- Inward matches `^[0-9][A-Z]{2}$`.
- The two inward letters must NOT be `C I K M O V`.
- **Normalized**: uppercase, single space before final three chars, e.g. `EC1A 1BB`, `M1 1AE`.

### FR-7: CLI
- Invoked as `python -m postal_validator validate <code> --country <CC>`.
- Valid single code → print normalized form, exit `0`.
- Invalid single code → exit `1` (and report invalidity; `INVALID` appears in batch lines).
- `--json` → print a JSON object with at least `valid` (bool) and `normalized` keys; exit code unchanged.
- No positional `<code>` given → read codes from **stdin**, one per line (batch mode).
  - All valid → exit `0`; any invalid → exit `1`. Per-line output: normalized for valid lines,
    a line containing `INVALID` for invalid lines (order preserved).
- `--help` → usage text containing "usage", exit `0`.
- Unknown/unsupported country → exit non-zero.

## Non-Functional Requirements
- **NFR-1 (Dependencies)**: Standard library only. No third-party runtime dependencies. Dev/test may
  use `pytest` (already declared as an optional dev dependency).
- **NFR-2 (Compatibility)**: Must run under the available interpreter (Python 3.9.6 locally). Use
  `from __future__ import annotations` so modern type-hint syntax (`str | None`) is safe at runtime.
- **NFR-3 (Robustness)**: `validate` never raises; bad/empty input and unsupported countries yield a
  clean invalid result with a short human-readable `error`.
- **NFR-4 (Determinism / purity)**: `validate`/`normalize` are pure functions of their inputs.
- **NFR-5 (Testability)**: All provided tests pass; additional property-based tests added (see below).
- **NFR-6 (Exit codes)**: CLI uses meaningful exit codes — 0 = valid, 1 = invalid, non-zero for
  usage/unknown-country errors.

## Property-Based Testing Requirements (Extension: Partial mode)
Enforced rules PBT-02, PBT-03, PBT-07, PBT-08, PBT-09 (see `aidlc-state.md` for deviations):
- **PBT-02 (Round-trip / parse↔format)**: For generated *valid* codes of each country,
  `normalize` produces a canonical form that (a) re-validates as valid and (b) is idempotent
  (`normalize(normalize(x)) == normalize(x)`).
- **PBT-03 (Invariants)**: For valid inputs, `result.valid is True`, `result.error is None`, and the
  normalized form matches the country's canonical shape. For generated *invalid* inputs,
  `result.valid is False`, `result.normalized is None`, `result.error` is a non-empty string, and
  `normalize` raises `ValueError`.
- **PBT-07 (Generator quality)**: Domain-specific generators emit structurally valid CA/US/UK codes
  (respecting the letter/digit constraints), plus targeted invalid generators — not raw random strings.
- **PBT-08 (Reproducibility)**: Property tests are seeded; the seed is fixed/overridable and the seed +
  failing input are reported on failure. Lightweight stdlib shrinking attempts a minimal counterexample.
- **PBT-09 (Framework)**: Per the stdlib-only constraint, the "framework" is a stdlib property harness
  (`random` + pytest). Documented deviation from using Hypothesis.

## Out of Scope
- Real-world postal rules beyond the simplified set in `reference/formats.md`.
- Countries other than CA/US/UK.
- Network lookups, persistence, configuration files, packaging/publishing, deployment.

## Key Requirements Summary
A small, pure-Python, stdlib-only package exposing `validate`/`normalize` over a `ValidationResult`,
backed by per-country rule logic faithful to `reference/formats.md`, with a `__main__` CLI supporting
single-code, JSON, and stdin-batch modes with 0/1 exit codes. Example-based tests (provided) plus
stdlib property-based tests must pass.
