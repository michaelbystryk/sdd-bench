# Phase 0 Research: Postal-Code Validator + CLI

The behavior is fully specified by `reference/formats.md` and the existing tests, so "research" here is design-decision resolution rather than open investigation. No `NEEDS CLARIFICATION` markers remained from the spec.

## R1 — Matching strategy: regex + explicit exclusions

**Decision**: Use precompiled `re` patterns per country for the structural shape, combined with explicit set-membership checks for the letter exclusions that are awkward to express purely in regex.

**Rationale**:
- The CA/UK letter exclusions (CA first letter ∉ `W Z` and all letters ∉ `D F I O Q U`; UK inward letters ∉ `C I K M O V`) are clearest as a character-class regex or an explicit `not in EXCLUDED` check. A constrained character class keeps the pattern readable and the rule co-located.
- Regex cleanly captures the optional internal space (CA/UK) and the US ZIP / ZIP+4 alternation, including rejecting internal whitespace and the 9-digit-no-hyphen case.
- Standard-library `re` only — satisfies FR-018.

**Alternatives considered**: Hand-rolled character-by-character parsing (more code, more edge-case risk); a third-party validation library (violates the stdlib-only constraint).

## R2 — Canonical normalization per country

**Decision**:
- **CA**: strip → uppercase → remove any internal space → re-insert a single space after the 3rd character → `K1A 0B1`.
- **UK**: strip → uppercase → remove any internal space → re-insert a single space before the final 3 characters (the inward code is always the last three) → `EC1A 1BB`, `M1 1AE`.
- **US**: strip → return unchanged (digits/hyphen only; no case folding needed) → `90210`, `12345-6789`.

**Rationale**: Matches the "Normalized form" lines in `reference/formats.md` exactly and the `expected_normalized` column in `tests/test_core.py` (`H0H0H0` → `H0H 0H0`, `ec1a1bb` → `EC1A 1BB`, `sw1a 1aa` → `SW1A 1AA`).

**Alternatives considered**: Returning the input verbatim for CA/UK (fails the "always single internal space" rule and the tests).

## R3 — ValidationResult shape

**Decision**: A frozen `@dataclass` with fields `valid: bool`, `normalized: str | None = None`, `error: str | None = None`. Provide a single internal construction path so the three invariants always hold (valid ⇒ normalized set, error None; invalid ⇒ normalized None, error set).

**Rationale**: `reference/formats.md` API contract mandates exactly `.valid`, `.normalized`, `.error`. `tests/test_core.py::test_validation_result_type` asserts `isinstance(validate(...), ValidationResult)`, so the type must be importable from the package root. A dataclass gives a clean repr and equality for free.

**Alternatives considered**: `NamedTuple` (works, but a frozen dataclass reads better and allows helper constructors); plain dict (fails the `isinstance` and attribute-access contract).

## R4 — CLI framework and contract

**Decision**: Use `argparse` with a `validate` subcommand: positional optional `code`, required `--country`, flag `--json`. No code argument ⇒ read stdin line by line (batch mode).

**Rationale**:
- `argparse` is stdlib and gives `--help`/usage text with exit code 0 for free (`tests/test_cli.py::test_help_exits_zero` checks `"usage"` in stdout). Note: argparse prints `--help` to **stdout** and exits 0, which is what the test reads.
- Exit codes: 0 = all valid, 1 = any invalid (`test_invalid_exits_one`, `test_batch_stdin_mixed_exits_one`). Unsupported country must exit non-zero (`test_unknown_country_exits_nonzero`) — a validity failure yields exit 1, which satisfies "non-zero".
- `--json` emits `{"valid": ..., "normalized": ..., "error": ...}` via `json.dumps`; tests parse `data["valid"]` and `data["normalized"]`.
- Batch output: valid line → its normalized form; invalid line → text containing `INVALID` (matched case-insensitively by `test_batch_stdin_mixed_exits_one`).

**Open contract detail (resolved by decision)**: For a single invalid code in plain (non-JSON) mode, print the short error reason to **stderr** and exit 1 (keeps stdout clean for piping); the tests only assert the exit code for that case, so this is a safe, conventional choice. JSON mode prints the JSON object to stdout regardless of validity.

**Alternatives considered**: `click`/`typer` (third-party — disallowed); hand-rolled `sys.argv` parsing (loses free `--help`/usage handling that a test depends on).

## R5 — Python version compatibility

**Decision**: Target the language subset that runs on **both** the declared `>=3.11` and the locally installed **3.9.6**. Concretely: put `from __future__ import annotations` at the top of every module so PEP 604 (`str | None`) annotations are treated as strings and never evaluated at runtime; avoid `match` statements and other 3.10+/3.11-only runtime features.

**Rationale**: `pyproject.toml` says `requires-python >=3.11`, but the interpreter on this machine is 3.9.6, and `tests/test_cli.py` launches the CLI via `sys.executable` (whatever runs pytest). Writing to the 3.9 subset removes the risk of a `SyntaxError`/`TypeError` at import or runtime regardless of which interpreter executes the suite. The test files themselves already use `from __future__ import annotations`, confirming the pattern.

**Alternatives considered**: Using 3.11-only features freely (would break if the suite runs under 3.9); pinning/installing 3.11 (out of scope for this change and unnecessary).

## R6 — Unsupported country handling

**Decision**: `validate()` returns an invalid `ValidationResult` with an error like `"unsupported country: FR"` for any country outside `{CA, US, UK}` (case-insensitive) — it never raises. `normalize()` raises `ValueError` for unsupported countries (consistent with "raises on invalid input"). The CLI exits non-zero (1) for an unsupported country.

**Rationale**: `reference/formats.md` API contract: "Any other value → an invalid result (do not raise)." `tests/test_core.py::test_unsupported_country_is_invalid_not_error` and `test_cli.py::test_unknown_country_exits_nonzero` confirm.

**Alternatives considered**: Raising in `validate()` (explicitly forbidden by the contract).

## Summary of resolved decisions

| ID | Topic | Decision |
|----|-------|----------|
| R1 | Matching | Precompiled regex + explicit letter-exclusion checks |
| R2 | Normalization | Per-country canonical reformatting (CA/UK re-space, US trim-only) |
| R3 | Result type | Frozen `ValidationResult` dataclass, exported from package root |
| R4 | CLI | `argparse` `validate` subcommand; `--json`; stdin batch; exit 0/1 |
| R5 | Python version | Write 3.9-compatible subset; `from __future__ import annotations` everywhere |
| R6 | Unknown country | `validate` returns invalid (no raise); `normalize` raises; CLI exits non-zero |
