## Context

`reference/formats.md` defines exact, intentionally simplified rules for CA, US, and UK postal codes, and `pyproject.toml` pins a stdlib-only, Python ≥3.11 runtime. Two test suites already encode the contract: `tests/test_core.py` (library) and `tests/test_cli.py` (CLI run via `python -m postal_validator`). The package does not exist yet. The design must satisfy those tests exactly without adding constraints beyond the reference.

## Goals / Non-Goals

**Goals:**
- A `postal_validator` package importable as `from postal_validator import ValidationResult, normalize, validate`.
- `validate` returns a structured result; `normalize` raises `ValueError` on invalid input.
- A `python -m postal_validator` CLI with single-code, JSON, and stdin batch modes plus correct exit codes.
- Standard library only.

**Non-Goals:**
- Real-world completeness of UK rules (only the three stated constraints).
- Countries beyond CA/US/UK (treated as invalid, not an error).
- Configurable output formats beyond plain text and `--json`.

## Decisions

**Package layout.** Split responsibilities into small modules:
- `postal_validator/__init__.py` — re-exports `ValidationResult`, `validate`, `normalize` (public API).
- `postal_validator/core.py` — `ValidationResult` dataclass + per-country validators and the dispatch in `validate`/`normalize`.
- `postal_validator/cli.py` — argument parsing, single/batch/JSON modes, exit codes; exposes `main()`.
- `postal_validator/__main__.py` — `from .cli import main; raise SystemExit(main())`.

Rationale: keeps core logic free of I/O so both tests and the CLI share one source of truth.

**`ValidationResult` as a frozen dataclass** with fields `valid: bool`, `normalized: str | None`, `error: str | None`. Simple, typed, satisfies `isinstance` and attribute-access tests. Alternative (NamedTuple) rejected — dataclass reads clearer and allows future helper methods.

**Per-country logic via regex on the trimmed, uppercased input.** Each country has a validator returning either the normalized string or a short error reason:
- CA: regex `^[ABCEGHJKLMNPRSTVXY][0-9][ABCEGHJKLMNPRSTVWXYZ][0-9][ABCEGHJKLMNPRSTVWXYZ][0-9]$` after stripping an optional middle space; normalize inserts the single middle space → `ANA NAN`.
- US: regex `^[0-9]{5}(-[0-9]{4})?$`; normalized form is the trimmed input unchanged.
- UK: split so the inward code is the final 3 chars and the rest (minus optional space) is outward; validate outward `^[A-Z]{1,2}[0-9][A-Z0-9]?$`, inward `^[0-9][A-Z]{2}$`, and reject inward letters in `C I K M O V`; normalize joins `outward + " " + inward`.

Rationale: regexes mirror `reference/formats.md` line-for-line, minimizing interpretation. Excluded-letter sets are baked into character classes so no extra checks drift from the spec.

**Country dispatch is case-insensitive** via `country.strip().upper()`; unknown codes return an invalid `ValidationResult` (never raise) from `validate`, while `normalize` raises `ValueError`.

**CLI argument parsing with `argparse`.** Gives `--help` containing "usage" (test) and standard error exit codes for free. A `validate` subcommand takes an optional positional `code`, required `--country`, and flags `--json`. When `code` is omitted, read stdin line-by-line.

Exit-code/output rules:
- Single valid: print normalized to stdout, exit 0.
- Single invalid: print an error (or JSON), exit 1.
- `--json`: print one JSON object (`valid`, `normalized`, `error`) for single-code mode; exit reflects validity.
- Batch (stdin): one output line per input line — normalized when valid, otherwise a line containing `INVALID`; exit 0 only if every line is valid, else 1.
- Unknown country: non-zero exit (treated as invalid).

## Risks / Trade-offs

- [Over-engineering UK normalization by inferring outward/inward] → Anchor on "inward = final three chars" exactly as the reference states; outward is everything before it.
- [Regex character classes drifting from the excluded-letter lists] → Derive classes directly from the reference's explicit allowed sets and cover them with the existing parametrized tests.
- [Batch-mode JSON ambiguity] → Tests only exercise plain-text batch output; keep `--json` scoped to single-code mode and emit plain lines for batch to avoid an undefined contract.
- [Exit code for unknown country] → Test only requires non-zero; invalid result naturally yields exit 1, satisfying it.

## Open Questions

- None blocking. `--json` behavior in batch mode is unspecified by tests; default to plain-line batch output and revisit only if a JSON-batch requirement emerges.
