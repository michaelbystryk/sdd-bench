## 1. Package scaffolding

- [x] 1.1 Create `postal_validator/` package directory with `__init__.py`
- [x] 1.2 Re-export `ValidationResult`, `validate`, `normalize` from `postal_validator/__init__.py`
- [x] 1.3 Add `postal_validator/__main__.py` delegating to `cli.main()` via `raise SystemExit(main())`

## 2. Core data model

- [x] 2.1 Define `ValidationResult` as a frozen dataclass with `valid: bool`, `normalized: str | None`, `error: str | None` in `postal_validator/core.py`
- [x] 2.2 Add country dispatch that normalizes `country` with `.strip().upper()` and routes to CA/US/UK validators

## 3. Country validators (per reference/formats.md)

- [x] 3.1 Implement Canada validator/normalizer (ANA NAN, excluded letters, optional middle space → `K1A 0B1`)
- [x] 3.2 Implement US validator/normalizer (`NNNNN` or `NNNNN-NNNN`, reject letters/internal whitespace/9-no-hyphen; normalized = trimmed input)
- [x] 3.3 Implement UK validator/normalizer (inward = final 3 chars `^[0-9][A-Z]{2}$` minus `C I K M O V`; outward `^[A-Z]{1,2}[0-9][A-Z0-9]?$`; single space before final three)
- [x] 3.4 Trim and uppercase input; return short `.error` reasons for invalid cases

## 4. Public functions

- [x] 4.1 Implement `validate(code, country)` returning a `ValidationResult`, never raising (unknown country → invalid result)
- [x] 4.2 Implement `normalize(code, country)` returning the canonical string and raising `ValueError` on invalid input

## 5. CLI

- [x] 5.1 Build `argparse` parser in `postal_validator/cli.py` with a `validate` subcommand: optional positional `code`, required `--country`, `--json` flag
- [x] 5.2 Single-code mode: print normalized to stdout and exit 0 when valid; exit 1 when invalid
- [x] 5.3 `--json` single-code mode: print one JSON object with `valid`/`normalized`/`error`; exit code reflects validity
- [x] 5.4 Batch stdin mode (no code given): read one code per line, print normalized or an `INVALID`-containing line per input; exit 0 only if all valid else 1
- [x] 5.5 Ensure `--help` exits 0 with `usage` text and unknown country yields non-zero exit

## 6. Verification

- [x] 6.1 Run `python -m pytest tests/` and confirm `test_core.py` and `test_cli.py` pass
- [x] 6.2 Confirm no third-party imports are used (standard library only)
