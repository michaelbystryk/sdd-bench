---
description: "Task list for Postal-Code Validator + CLI implementation"
---

# Tasks: Postal-Code Validator + CLI

**Input**: Design documents from `/specs/001-postal-code-validator/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Test suites already exist and are authoritative (`tests/test_core.py`, `tests/test_cli.py`) — they are NOT to be rewritten. No new test-authoring tasks are generated; each story instead ends with a task that runs the relevant existing tests to verify the increment.

**Organization**: Tasks are grouped by user story so each capability can be implemented and verified independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on incomplete tasks)
- **[Story]**: US1–US4, mapping to the user stories in spec.md
- Exact file paths are given in each task

## Path Conventions

Single-project library at the **repository root**. Package lives in `postal_validator/`; tests in `tests/` (pre-existing). `pyproject.toml` sets `pythonpath = ["."]`, so the package imports from root.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Create the package skeleton so imports resolve and tests can be collected.

- [X] T001 Create the package skeleton at repo root: `postal_validator/__init__.py` (empty exports for now) and `postal_validator/__main__.py` (stub), each beginning with `from __future__ import annotations`. Confirm `python -c "import postal_validator"` succeeds.
- [X] T002 [P] Install dev dependencies with `pip install -e ".[dev]"` and confirm `pytest --collect-only` discovers `tests/test_core.py` and `tests/test_cli.py` (collection import errors are expected until Phase 2 completes).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The shared result type and country-dispatch core that every user story builds on. Also establishes the full public import surface (`validate`, `normalize`, `ValidationResult`) so `tests/test_core.py` — which imports all three at module load — can be collected and run.

**⚠️ CRITICAL**: No user-story work can begin until this phase is complete.

- [X] T003 [P] Implement the `ValidationResult` frozen dataclass (fields `valid: bool`, `normalized: str | None`, `error: str | None`) with `ok(normalized)` and `fail(error)` constructor helpers in `postal_validator/result.py`. Start the module with `from __future__ import annotations`.
- [X] T004 Implement the dispatch core in `postal_validator/rules.py` (`from __future__ import annotations`): strip leading/trailing whitespace from the code; resolve `country` case-insensitively against `{CA, US, UK}`; unsupported country → `ValidationResult.fail("unsupported country: <CC>")` (never raise); define `validate(code, country)` that routes to per-country validators (stubbed to `fail(...)` for now). (depends on T003)
- [X] T005 Define the public API surface in `postal_validator/__init__.py`: export `validate` and `ValidationResult`, plus a `normalize` stub that raises `NotImplementedError`, so `from postal_validator import validate, normalize, ValidationResult` resolves. (depends on T003, T004)

**Checkpoint**: `import postal_validator` exposes all three names; `validate` returns invalid results for everything (rules not yet filled). User stories can now begin.

---

## Phase 3: User Story 1 - Validate a single postal code (Priority: P1) 🎯 MVP

**Goal**: `validate(code, country)` correctly accepts/rejects CA, US, and UK codes per `reference/formats.md`, returning the canonical `normalized` form for valid input and a short `error` for invalid input — case- and whitespace-insensitive.

**Independent Test**: Run `pytest tests/test_core.py -k "not normalize"` — all valid codes accepted with exact normalized form, all invalid codes rejected with a non-empty reason, country case-insensitive, unsupported country invalid (not raised).

> Note: T006–T008 all edit `postal_validator/rules.py`, so they run sequentially (not `[P]`); they are logically independent per country.

- [X] T006 [US1] Implement the Canada (`CA`) rule in `postal_validator/rules.py`: `ANA NAN` shape with optional single internal space; first letter ∈ `A B C E G H J K L M N P R S T V X Y`, other two letters ∈ `A B C E G H J K L M N P R S T V W X Y Z` (i.e. exclude `D F I O Q U` everywhere, plus `W Z` in first position); digits `0`–`9`; canonical reformat to uppercase with one space after the 3rd char (`K1A 0B1`). (depends on T004)
- [X] T007 [US1] Implement the United States (`US`) rule in `postal_validator/rules.py`: accept `NNNNN` or `NNNNN-NNNN` (the `+4` of exactly 4 digits only when preceded by a hyphen); reject ≠5 leading digits, 9 digits without a hyphen, any letters, and internal whitespace; canonical = trimmed input unchanged. (depends on T004)
- [X] T008 [US1] Implement the United Kingdom (`UK`) rule in `postal_validator/rules.py`: outward `^[A-Z]{1,2}[0-9][A-Z0-9]?$`, inward `^[0-9][A-Z]{2}$` (always the final three chars), inward two letters ∉ `C I K M O V`, optional separating space; canonical = uppercase with one space before the final three chars (`EC1A 1BB`, `M1 1AE`). (depends on T004)
- [X] T009 [US1] Ensure every failure path sets a short, non-empty `error` and every success sets `normalized`; then verify by running `pytest tests/test_core.py -k "not normalize"` (covers `test_valid_codes`, `test_invalid_codes`, `test_validation_result_type`, `test_country_is_case_insensitive`, `test_unsupported_country_is_invalid_not_error`). (depends on T006, T007, T008)

**Checkpoint**: Core validation is fully functional and independently testable — this is the MVP.

---

## Phase 4: User Story 2 - Normalize a code to its canonical form (Priority: P2)

**Goal**: `normalize(code, country)` returns the canonical string for valid input and raises `ValueError` for invalid input (including unsupported country).

**Independent Test**: Run `pytest tests/test_core.py::test_normalize_valid tests/test_core.py::test_normalize_invalid_raises_valueerror`.

- [X] T010 [US2] Replace the `normalize` stub with the real implementation in `postal_validator/rules.py` (re-exported via `postal_validator/__init__.py`): call `validate(code, country)`; return `result.normalized` when `valid`, else `raise ValueError(result.error)`. (depends on T009)
- [X] T011 [US2] Verify normalization by running `pytest tests/test_core.py` (full file green, including the two `normalize` tests). (depends on T010)

**Checkpoint**: Both library functions (`validate`, `normalize`) satisfy `reference/formats.md` and `tests/test_core.py`.

---

## Phase 5: User Story 3 - Validate codes from the command line (Priority: P2)

**Goal**: `python -m postal_validator validate <code> --country <CC>` prints the normalized form and exits 0 when valid, exits 1 when invalid; supports `--json`; `--help` prints usage and exits 0; unsupported country exits non-zero.

**Independent Test**: Run `pytest tests/test_cli.py -k "valid or invalid or json or help or unknown_country"`.

- [X] T012 [US3] Implement `postal_validator/cli.py` with `main(argv=None) -> int` using `argparse` (`from __future__ import annotations`): a `validate` subcommand with an optional positional `code`, required `--country`, and a `--json` flag; rely on argparse for `--help` (printed to stdout, exit 0). (depends on T009)
- [X] T013 [US3] Implement single-code handling in `postal_validator/cli.py`: valid → print canonical form to stdout and return 0; invalid → print the short reason to stderr and return 1; `--json` → print `{"valid": ..., "normalized": ..., "error": ...}` to stdout with the same 0/1 exit semantics; unsupported country → non-zero exit. (depends on T012)
- [X] T014 [US3] Wire `postal_validator/__main__.py` to call `sys.exit(cli.main())`; confirm `python -m postal_validator validate k1a0b1 --country CA` prints `K1A 0B1` and exits 0. (depends on T012)
- [X] T015 [US3] Verify single-code CLI by running `pytest tests/test_cli.py -k "valid or invalid or json or help or unknown_country"` (covers `test_valid_prints_normalized_and_exits_zero`, `test_invalid_exits_one`, `test_json_valid`, `test_json_invalid`, `test_help_exits_zero`, `test_unknown_country_exits_nonzero`). (depends on T013, T014)

**Checkpoint**: The CLI works for single codes in plain and JSON modes with correct exit codes.

---

## Phase 6: User Story 4 - Batch-validate a list of codes from stdin (Priority: P3)

**Goal**: With no `code` argument, the CLI reads codes from stdin (one per line), prints a per-line verdict in input order (normalized form for valid, text containing `INVALID` for invalid), and exits 0 only if every line is valid.

**Independent Test**: Run `pytest tests/test_cli.py -k "batch"`.

- [X] T016 [US4] Add batch mode to `postal_validator/cli.py`: when no positional `code` is given, read `sys.stdin` line by line; for each line print the canonical form (valid) or a line containing `INVALID` (invalid), preserving input order; track an overall status and return 0 iff all valid, else 1. (depends on T013)
- [X] T017 [US4] Verify batch mode by running `pytest tests/test_cli.py -k "batch"` (covers `test_batch_stdin_mixed_exits_one`, `test_batch_stdin_all_valid_exits_zero`), then the full `pytest tests/test_cli.py`. (depends on T016)

**Checkpoint**: All CLI modes (single, JSON, batch, help) are functional.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Compatibility, robustness, and final whole-suite verification.

- [X] T018 [P] Confirm every module in `postal_validator/` begins with `from __future__ import annotations` and uses no Python 3.10+/3.11-only runtime constructs (e.g. `match` statements), so the suite passes on the installed 3.9.6 as well as the declared `>=3.11` (research.md R5).
- [X] T019 [P] Add concise module/function docstrings across `postal_validator/` pointing to `reference/formats.md` as the authoritative rule source.
- [X] T020 Edge-case hardening: confirm blank/whitespace-only stdin lines and empty input are reported invalid without crashing, and that no stack traces leak to the user on any input across both surfaces (FR-019, spec Assumptions).
- [X] T021 Run the full suite `pytest` (both `tests/test_core.py` and `tests/test_cli.py` green) and execute the `quickstart.md` commands as a manual smoke test.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories.
- **US1 (Phase 3)**: Depends on Foundational. This is the MVP.
- **US2 (Phase 4)**: Depends on US1 (`normalize` wraps `validate`).
- **US3 (Phase 5)**: Depends on US1 (the CLI calls `validate` and prints `.normalized`); independent of US2.
- **US4 (Phase 6)**: Depends on US3 (batch mode extends the same `cli.py`).
- **Polish (Phase 7)**: Depends on all targeted stories being complete.

### User Story Dependencies

- **US1 (P1)**: Foundational only — no dependency on other stories.
- **US2 (P2)**: Needs US1's working `validate`.
- **US3 (P2)**: Needs US1's working `validate`; can proceed without US2.
- **US4 (P3)**: Needs US3's CLI scaffolding.

### Within Each User Story

- Country rules (T006–T008) share `rules.py` → sequential.
- Implementation precedes its verification task (the `pytest …` run that closes each story).

### Parallel Opportunities

- **Setup**: T002 `[P]` can run alongside T001 once the directory exists.
- **Foundational**: T003 `[P]` (`result.py`) is independent of the `rules.py`/`__init__.py` wiring; T004 then T005 are sequential.
- **Polish**: T018 and T019 `[P]` touch independent concerns.
- **Cross-story**: After US1, US3 could begin in parallel with US2 (different files: `cli.py` vs `rules.py`’s `normalize`) if staffed by two people.

---

## Parallel Example: Foundational Phase

```bash
# T003 can start immediately and in parallel with planning the rules core:
Task: "Implement ValidationResult frozen dataclass in postal_validator/result.py"
# T004 (rules dispatch) depends on T003; T005 (__init__ exports) depends on both.
```

## Parallel Example: After US1 completes (two developers)

```bash
# Developer A — US2 (library normalize):
Task: "Implement normalize() wrapper in postal_validator/rules.py"
# Developer B — US3 (CLI), different file:
Task: "Implement argparse main() in postal_validator/cli.py"
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1 Setup → Phase 2 Foundational → Phase 3 US1.
2. **STOP and VALIDATE**: `pytest tests/test_core.py -k "not normalize"` green.
3. This is a usable validity oracle on its own.

### Incremental Delivery

1. Setup + Foundational → import surface ready.
2. US1 → `validate` correct → MVP.
3. US2 → `normalize` + `ValueError` semantics → full `test_core.py` green.
4. US3 → single-code CLI (+ `--json`, `--help`, exit codes).
5. US4 → stdin batch mode → full `test_cli.py` green.
6. Polish → compatibility, edge cases, full `pytest`.

---

## Notes

- `[P]` = different files, no dependency on incomplete tasks.
- `[Story]` labels map tasks to spec.md user stories for traceability.
- The existing test suites are the acceptance gate — do not modify them; make them pass.
- Keep to the standard library only (FR-018); no third-party imports in `postal_validator/`.
- Commit after each completed phase/checkpoint.
