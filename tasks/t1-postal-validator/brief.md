# Postal-code validator + CLI

Implement a Python package `postal_validator` that validates and normalizes
postal codes for Canada, the US, and the UK per the rules in
`reference/formats.md`, plus a small command-line interface for it.

The package must expose:

- `validate(code: str, country: str) -> ValidationResult`
- `normalize(code: str, country: str) -> str`

The CLI is invoked as `python -m postal_validator validate <code> --country <CC>`.
It must:

- support `--json` output,
- read a list of codes from stdin (one per line) when no code is given,
- use meaningful exit codes (0 = valid, 1 = invalid).

The tests in `tests/` must pass. Reject invalid input cleanly, handle
whitespace and case, and use the standard library only — no third-party
dependencies.
