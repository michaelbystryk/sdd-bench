# Code Summary — Unit: postal-validator-core

Greenfield unit. All files created (no modifications). Standard library only.

## Created — Application Code (workspace root)
- `postal_validator/__init__.py` — package API; re-exports `validate`, `normalize`,
  `ValidationResult`, `SUPPORTED_COUNTRIES`; defines `__version__`.
- `postal_validator/_core.py` — `ValidationResult` dataclass and the CA/US/UK rule engine:
  - `validate(code, country) -> ValidationResult` — case-insensitive country; trims whitespace;
    never raises; unsupported country / malformed input → invalid result with a short `error`.
  - `normalize(code, country) -> str` — canonical form; raises `ValueError` when invalid.
  - Per-country normalizers (`_normalize_ca/_us/_uk`) using compiled `re` patterns.
- `postal_validator/cli.py` — argparse CLI (`validate` subcommand): single-code and stdin-batch
  modes, `--json`, `-c/--country`, plain output, exit codes (0 valid / 1 invalid / 2 usage).
- `postal_validator/__main__.py` — `python -m postal_validator` entry point → `cli.main()`.

## Created — Tests
- `tests/test_properties.py` — stdlib property-based tests (seeded; `POSTAL_VALIDATOR_SEED`):
  domain generators for valid/invalid CA/US/UK codes, round-trip/idempotence (PBT-02),
  validity & error invariants (PBT-03).

## Created — Docs
- `README.md` (workspace root) — library + CLI usage.
- This summary.

## Rule-fidelity notes (per reference/formats.md)
- **CA**: 6 alphanumerics `ANA NAN`; first letter ∈ `ABCEGHJKLMNPRSTVXY`, other letters ∈
  `ABCEGHJKLMNPRSTVWXYZ`; optional single mid-space on input; normalized adds one mid-space.
- **US**: `^[0-9]{5}(-[0-9]{4})?$`; normalized = trimmed input unchanged; internal whitespace rejected.
- **UK**: inward = final 3 chars; outward `^[A-Z]{1,2}[0-9][A-Z0-9]?$`; inward `^[0-9][A-Z]{2}$`;
  inward letters must not be `C I K M O V`; optional separating space; normalized uses one space.

## Verification
- `python -m pytest` → **56 passed** (provided `test_core.py` + `test_cli.py` + new `test_properties.py`).
- Property suite re-checked across seeds 1, 2, 42, 99, 123456, 20260527 → all PASS (not seed-sensitive).
- AST scan confirms package imports only stdlib (`re`, `dataclasses`, `typing`, `argparse`, `json`, `sys`).
