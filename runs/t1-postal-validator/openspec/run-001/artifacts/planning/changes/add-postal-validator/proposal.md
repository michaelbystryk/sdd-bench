## Why

There is no shared, dependency-free way to validate and normalize postal codes for Canada, the US, and the UK. Downstream code re-implements ad-hoc regexes that disagree on edge cases (excluded letters, ZIP+4, optional spaces). A single library plus a CLI gives one authoritative implementation of the rules in `reference/formats.md`.

## What Changes

- Add a Python package `postal_validator` (standard library only) exposing:
  - `validate(code: str, country: str) -> ValidationResult`
  - `normalize(code: str, country: str) -> str`
- `ValidationResult` exposes `.valid: bool`, `.normalized: str | None`, `.error: str | None`.
- Validation/normalization for CA, US, and UK per `reference/formats.md`: case-insensitive, whitespace-trimming, with canonical normalized output.
- Add a CLI `python -m postal_validator validate <code> --country <CC>` supporting `--json` output, stdin batch mode (one code per line when no code is given), and exit codes (0 = all valid, 1 = any invalid).
- Unsupported country and malformed input are reported as invalid results; `normalize()` raises `ValueError` on invalid input.

## Capabilities

### New Capabilities
- `postal-validation`: Core library that validates and normalizes CA/US/UK postal codes and returns a structured result.
- `postal-cli`: Command-line interface over the library with single-code, batch-stdin, JSON output, and exit-code semantics.

### Modified Capabilities
<!-- None — this is a greenfield package. -->

## Impact

- New code: `postal_validator/` package (`__init__.py`, `__main__.py`, core + CLI modules).
- Public API surface: `validate`, `normalize`, `ValidationResult` importable from `postal_validator`.
- Test suites `tests/test_core.py` and `tests/test_cli.py` must pass.
- No dependencies added; runtime is standard library only (`pyproject.toml` already pins this).
