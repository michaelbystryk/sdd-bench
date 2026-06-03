# Implementation Plan: Postal-Code Validator + CLI

**Branch**: `001-postal-code-validator` | **Date**: 2026-05-27 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-postal-code-validator/spec.md`

## Summary

Build a standard-library-only Python package `postal_validator` that validates and normalizes Canadian, US, and UK postal codes per `reference/formats.md`, exposing `validate(code, country) -> ValidationResult` and `normalize(code, country) -> str`, plus a `python -m postal_validator validate ...` CLI with `--json`, stdin batch mode, and meaningful exit codes (0 valid / 1 invalid). Behavior is fully pinned by `reference/formats.md` and the existing suites in `tests/`; the approach is a per-country rule table driven by precompiled regular expressions plus explicit letter-exclusion checks, a frozen `ValidationResult` dataclass, and an `argparse`-based CLI.

## Technical Context

**Language/Version**: Python — target `>=3.11` per `pyproject.toml`; write to a 3.9-compatible subset (the locally installed interpreter is 3.9.6) so the test runner passes regardless of which interpreter `sys.executable` points at. See research.md R5.

**Primary Dependencies**: None at runtime — standard library only (`re`, `argparse`, `json`, `sys`, `dataclasses`). `pytest>=8.0` is a dev-only dependency already declared.

**Storage**: N/A — pure computation, no persistence.

**Testing**: `pytest` (`tests/test_core.py`, `tests/test_cli.py`). `pyproject.toml` sets `pythonpath = ["."]` and `testpaths = ["tests"]`, so the package is imported from the repo root.

**Target Platform**: Cross-platform CLI / library (any OS with a supported CPython). The CLI is reached via `python -m postal_validator`.

**Project Type**: Single project — a library with a CLI entry point at the repo root.

**Performance Goals**: Effectively instant per code (regex match over a ≤10-char string). No throughput target beyond "a batch of many lines completes interactively."

**Constraints**: Standard library only (FR-018); no unhandled exceptions on any input (FR-019); canonical output rules exactly as in `reference/formats.md` (FR-009, FR-010); CLI exit-code contract 0/1 (FR-012, FR-014).

**Scale/Scope**: Three countries, two public functions, one CLI subcommand. Small, bounded surface (~3 source files plus package init/main).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution at `.specify/memory/constitution.md` is an unedited template with no ratified principles, so there are no binding gates to evaluate. No violations possible; no Complexity Tracking entries required. The design nonetheless follows the spirit of the example principles that ship in the template — library-first, CLI with text + JSON I/O, tests already authored (test-first), and YAGNI simplicity.

**Result**: PASS (no constitutional constraints defined).

## Project Structure

### Documentation (this feature)

```text
specs/001-postal-code-validator/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── library-api.md   # validate() / normalize() / ValidationResult contract
│   └── cli.md           # command schema, exit codes, output formats
├── checklists/
│   └── requirements.md  # Spec quality checklist (/speckit-specify output)
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
postal_validator/
├── __init__.py          # Public API: exports validate, normalize, ValidationResult
├── __main__.py          # CLI entry point: `python -m postal_validator ...`
├── result.py            # ValidationResult dataclass
├── rules.py             # Per-country format rules (regex + letter-exclusion logic)
└── cli.py               # argparse wiring, single + stdin batch modes, --json, exit codes

tests/                   # Pre-existing — must pass unchanged
├── __init__.py
├── test_core.py         # validate()/normalize() behavior
└── test_cli.py          # CLI contract (exit codes, --json, stdin batch, --help)

reference/formats.md     # Authoritative rule set (input, not modified)
pyproject.toml           # Packaging + pytest config (pre-existing)
```

**Structure Decision**: Single-project library at the repo root. The package lives in `postal_validator/` (importable from root because `pyproject.toml` sets `pythonpath = ["."]`). `__init__.py` is the library surface; `__main__.py` + `cli.py` are the CLI surface; `rules.py` holds the country logic that both surfaces share; `result.py` defines the result object. No `src/` layout is used because the tests import `postal_validator` directly from the repo root and run `python -m postal_validator` with `cwd` at the root.

## Complexity Tracking

No constitution violations — section intentionally empty.
