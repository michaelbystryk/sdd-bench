# Code Generation Plan — Unit: postal-validator-core

**Single source of truth for Code Generation of this unit.** Greenfield, single unit.
Workspace root: `~/dev/sdd-bench-t1-builds/ai-dlc`. Application code at workspace root
(package `postal_validator/`); documentation summaries under `aidlc-docs/construction/postal-validator-core/code/`.

## Unit Context
- **Stories/Requirements implemented**: FR-1..FR-7, NFR-1..NFR-6 (see `aidlc-docs/inception/requirements/requirements.md`).
- **Dependencies**: none (stdlib only: `re`, `dataclasses`, `argparse`, `json`, `sys`, `typing`).
- **Interfaces/Contracts**: `validate`, `normalize`, `ValidationResult` (importable from package root);
  CLI `python -m postal_validator validate <code> --country <CC> [--json]` + stdin batch.
- **Testable properties (PBT)**: round-trip/idempotence of `normalize`; validity & error invariants;
  domain generators for CA/US/UK (see requirements PBT section).

## Steps

- [x] **Step 1 — Project Structure Setup** (greenfield): create `postal_validator/` package dir.
- [x] **Step 2 — Business Logic Generation**: `postal_validator/_core.py`
  - `ValidationResult` dataclass (`valid`, `normalized`, `error`).
  - Per-country rule engine via `re` (CA / US / UK) faithful to `reference/formats.md`.
  - `validate()` (never raises; unsupported country → invalid) and `normalize()` (raises `ValueError`).
- [x] **Step 3 — Package API**: `postal_validator/__init__.py` re-exporting public names.
- [x] **Step 4 — API/CLI Layer Generation**:
  - `postal_validator/cli.py` — argparse CLI: `validate` subcommand, single + stdin-batch modes,
    `--json`, `--country`, exit codes (0 valid / 1 invalid), `--help`.
  - `postal_validator/__main__.py` — entry point delegating to `cli.main()`.
- [x] **Step 5 — Property-Based Tests (PBT, stdlib)**: `tests/test_properties.py`
  - Domain generators (PBT-07), round-trip/idempotence (PBT-02), validity/error invariants (PBT-03),
    seeded + failing-input reporting (PBT-08).
- [x] **Step 6 — Documentation**: `aidlc-docs/construction/postal-validator-core/code/code-summary.md`
  and a top-level `README.md` (usage).
- [x] **Step 7 — Verify**: full test suite green (56 passed); see Build & Test stage.

## Traceability
| Requirement | Implemented by |
|---|---|
| FR-1 API | `_core.py`, `__init__.py` |
| FR-2 country case-insensitive / unsupported | `_core.validate` |
| FR-3 whitespace/case | `_core` normalizers |
| FR-4 CA | `_core._normalize_ca` |
| FR-5 US | `_core._normalize_us` |
| FR-6 UK | `_core._normalize_uk` |
| FR-7 CLI | `cli.py`, `__main__.py` |
| NFR-1 stdlib-only | all modules |
| NFR-2 py3.9 | `from __future__ import annotations` |
| PBT-02/03/07/08 | `tests/test_properties.py` |

## Notes
- **NO third-party deps.** No `ClassName_new` duplicates (greenfield, all new files).
- Do not add validation constraints beyond `reference/formats.md`.
