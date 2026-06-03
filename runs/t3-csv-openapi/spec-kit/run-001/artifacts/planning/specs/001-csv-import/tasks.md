---

description: "Task list for CSV User Import Service"
---

# Tasks: CSV User Import Service

**Input**: Design documents from `/specs/001-csv-import/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/openapi.yaml, quickstart.md — all present.

**Tests**: The pinned behavioral suite at `tests/test_imports.py` already exists and is the acceptance gate. No new test tasks are generated; a final validation task runs the suite.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story this task belongs to (US1, US2, US3, US4)
- File paths are absolute relative to repo root.

## Path Conventions

- Single Python package layout: `app/`, `tests/` at repository root (per plan.md "Project Structure")

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify the toolchain and confirm baseline state before writing code.

- [X] T001 Confirm `pyproject.toml` declares `fastapi`, `pydantic[email]`, `python-multipart`, `uvicorn`, `httpx`, and (under `[project.optional-dependencies].dev`) `pytest` — do **not** modify the file; just verify
- [X] T002 Verify `tests/test_imports.py` exists and is unmodified relative to its committed form, and confirm `reference/sample_csvs/` contains the fixtures referenced by the suite (`happy.csv`, `partial_success.csv`, `type_mismatch_age.csv`, `malformed_quotes.csv`, `missing_email_column.csv`, `empty.csv`, `embedded_newlines.csv`, `utf8_bom.csv`, `crlf.csv`, `mixed_endings.csv`, `unicode_names.csv`)
- [X] T003 [P] Install dev dependencies in a virtualenv: `python -m venv .venv && source .venv/bin/activate && pip install -e ".[dev]"` (one-time per developer environment)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Schemas, error envelope plumbing, in-memory store, and the bare FastAPI app skeleton. Every user story depends on this layer.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T004 [P] Create Pydantic v2 models in `app/schemas.py` per `data-model.md`: `UserRow` (with `EmailStr`, `int (ge=0, le=150)`, `date`, `Literal[...]` country), `FieldError` (with `code: Literal["missing","invalid_type","out_of_range","invalid_format"]`), `RowResult` (with `data: UserRow | None`, `errors: list[FieldError] | None` — both fields always serialized including when `None`), `ImportResult` (with `import_id: UUID`), `Error`, `ErrorResponse`. Configure model dumping so `data` and `errors` are emitted as `null` rather than omitted on the off branch (e.g., default `None`, no `exclude_none`).
- [X] T005 [P] Create `app/errors.py` defining `WholeFileError(BaseException-or-Exception)` with attributes `code: str`, `message: str`, `status_code: int`, `details: dict | None`; include constants for each documented error (`MALFORMED_CSV`, `MISSING_REQUIRED_COLUMNS`, `EMPTY_FILE`, `TOO_MANY_ROWS`, `FILE_TOO_LARGE`, `IMPORT_NOT_FOUND`) and a helper `make_error_body(code, message, details=None) -> dict` returning the `{"error": {...}}` envelope shape per `data-model.md`.
- [X] T006 [P] Create `app/repository.py` with a module-level `_store: dict[uuid.UUID, ImportResult]`, plus `put(import_id: UUID, result: ImportResult) -> None` and `get(import_id: UUID) -> ImportResult | None`. No locking; no eviction (per research §R5, §R11).
- [X] T007 Create `app/main.py` with the FastAPI app instance (`app = FastAPI(title="CSV Import Service")`), a registered exception handler for `WholeFileError` that returns `JSONResponse(status_code=exc.status_code, content=make_error_body(...))`, and route stubs for `POST /imports/users` and `GET /imports/{import_id}` (both returning `NotImplementedError` placeholders for now). Depends on T004, T005, T006. *Note: implemented with full handlers in a single pass rather than stubs, since the same file would otherwise be rewritten across US1/US2/US3.*

**Checkpoint**: `python -c "from app.main import app; print(app.routes)"` works without error. The error envelope handler is wired. User-story work can now begin.

---

## Phase 3: User Story 1 — Upload a CSV and receive per-row validation results (Priority: P1) 🎯 MVP

**Goal**: Make a multipart CSV upload to `POST /imports/users` parse, validate row-by-row, and return a full `ImportResult` envelope with `import_id`, totals, and ordered per-row results.

**Independent Test**: Run `pytest tests/test_imports.py::test_happy_path_returns_200_with_full_envelope tests/test_imports.py::test_partial_success_returns_200_with_per_row_results_in_order tests/test_imports.py::test_single_row_type_mismatch_is_row_level_not_whole_file -q` and watch all three pass.

### Implementation for User Story 1

- [X] T008 [P] [US1] Implement `app/csv_parser.py` happy-path parsing: a function `parse_csv(stream_or_bytes) -> tuple[list[str], list[dict[str, str]]]` that decodes UTF-8 (with BOM stripped via `utf-8-sig` or explicit BOM removal — see research §R3), feeds the decoded text to `csv.reader` over a `StringIO`, returns the header row and a list of data row dicts. Use `csv.reader` (not `csv.DictReader`) so we can keep header validation explicit; build dicts manually with the documented required column names. For US1, only the success branches are required; whole-file errors are filled in by US2 (T013). Depends on T004 (for the column-name constants — see T009).
- [X] T009 [P] [US1] Add a module-level tuple `REQUIRED_COLUMNS = ("email", "name", "age", "signup_date", "country")` to `app/csv_parser.py` (or `app/schemas.py`) and reuse it for header lookup. Keep the order documented and stable. *Placed in `app/schemas.py` so both parser and validator import from a single source.*
- [X] T010 [US1] Implement `app/validator.py` with `validate_row(row_dict: dict[str, str], row_number: int) -> RowResult`: (1) preprocess — for each required field, if value is `""` or absent, append `FieldError(field, code="missing", message=...)` and remove that key from the dict; (2) call `UserRow.model_validate(row_dict)`; on success, return `RowResult(row_number=row_number, status="success", data=user_row, errors=None)`; on `ValidationError`, walk `e.errors()` and map each entry to a `FieldError` using the table in `data-model.md` (Pydantic `type` → our `code`), combine with preprocessing errors (preprocessing errors first, in column order), return `RowResult(row_number=row_number, status="error", data=None, errors=[...])`. Depends on T004.
- [X] T011 [US1] Implement `POST /imports/users` handler in `app/main.py`: accept `file: UploadFile = File(...)`, read the body (chunked — but full-size-cap enforcement is deferred to T014 in US2), pass bytes to `parse_csv`, iterate rows with `enumerate(start=1)`, call `validator.validate_row(...)` for each, assemble `ImportResult(import_id=uuid.uuid4(), total=N, succeeded=Ns, failed=Nf, results=[...])`, persist via `repository.put(...)`, return the model (FastAPI serializes via Pydantic). Depends on T007, T008, T009, T010.

**Checkpoint**: User Story 1 is complete and the three happy/partial/single-bad-row tests above pass. Whole-file rejection is not yet implemented — those tests will still fail; that's US2.

---

## Phase 4: User Story 2 — Whole-file rejection with documented error codes (Priority: P1)

**Goal**: Reject malformed CSVs, files with missing required columns, empty files, oversized files, and (per OpenAPI contract) files exceeding 100,000 rows, with HTTP statuses 400/413 and the documented `error.code` values inside the uniform envelope.

**Independent Test**: Run `pytest tests/test_imports.py::test_malformed_csv_returns_400 tests/test_imports.py::test_missing_required_column_returns_400_with_details tests/test_imports.py::test_empty_file_returns_400 tests/test_imports.py::test_file_too_large_returns_413 -q` and watch all four pass. (`too_many_rows` is implemented per OpenAPI but is not pinned by a test — verify manually with a >100k row fixture or unit-test stub.)

### Implementation for User Story 2

- [X] T012 [US2] Extend `app/csv_parser.py` to detect and raise `WholeFileError(MALFORMED_CSV, ...)` when `csv.reader` raises `csv.Error` mid-iteration; raise `WholeFileError(MISSING_REQUIRED_COLUMNS, details={"missing_columns": [...]})` when the parsed header set does not include every entry in `REQUIRED_COLUMNS`; raise `WholeFileError(EMPTY_FILE, ...)` when the decoded text (post-BOM-strip) is empty or contains only a header row with zero data rows. Detection order matches `research.md` §R12: size → decode/BOM → empty-after-strip → header parse → header validation → row iteration. *Also enforced field-count match against the header to catch unterminated quotes (Python's `csv.reader` consumes such input to EOF rather than raising).*
- [X] T013 [US2] Extend `app/csv_parser.py` to enforce the 100,000-row cap (per OpenAPI; see research §R6) by raising `WholeFileError(TOO_MANY_ROWS, status_code=400, details={"max_rows": 100000})` once the 100,001st data row is encountered. Stop reading further rows after raising.
- [X] T014 [US2] Implement size-cap streaming guard in `app/main.py` POST handler: read `file.file` (the underlying `SpooledTemporaryFile`) in chunks (e.g., 64 KiB), accumulate into a `bytearray`, raise `WholeFileError(FILE_TOO_LARGE, status_code=413, details={"max_bytes": 10485760})` as soon as the running total exceeds 10 MB. Do not buffer the full body before the check; do not trust `Content-Length`. Pass the assembled bytes into `parse_csv` only after the size check passes.
- [X] T015 [US2] Confirm the `WholeFileError` handler registered in T007 returns the proper envelope shape for each of the five raised codes; if any code's status or `details` is wrong, fix it here. *Verified via the four pinned 400/413 tests plus the GET 404 case.*

**Checkpoint**: User Stories 1 AND 2 both work — all six row/file-level tests in `tests/test_imports.py` (happy, partial, single mismatch, malformed, missing col, empty) plus the size test pass.

---

## Phase 5: User Story 3 — Retrieve a prior import by id (Priority: P2)

**Goal**: `GET /imports/{import_id}` returns the original POST body for a known id, or HTTP 404 with `error.code="import_not_found"` for an unknown id.

**Independent Test**: Run `pytest tests/test_imports.py::test_get_import_returns_same_body_as_post tests/test_imports.py::test_get_import_unknown_id_returns_404 -q` and watch both pass.

### Implementation for User Story 3

- [X] T016 [US3] Implement `GET /imports/{import_id}` handler in `app/main.py`: declare path param `import_id: UUID`; call `repository.get(import_id)`; if `None`, raise `WholeFileError(IMPORT_NOT_FOUND, status_code=404, details=None)`; otherwise return the stored `ImportResult` model.
- [X] T017 [US3] Verify serialization is deterministic by checking that `model.model_dump(mode="json")` (or whatever FastAPI uses) for a cached `ImportResult` matches the original POST response byte-for-byte (key order, types, null handling). *FastAPI returns the same Pydantic model on both POST and GET; pinned test `test_get_import_returns_same_body_as_post` passes (POST and GET response bodies compare equal as dicts).*

**Checkpoint**: User Stories 1, 2, 3 work independently — eight pinned tests now pass.

---

## Phase 6: User Story 4 — Real-world CSV encoding compatibility (Priority: P2)

**Goal**: Files with UTF-8 BOM, CRLF or mixed line endings, embedded newlines inside quoted fields, and non-ASCII characters parse cleanly without operator pre-processing.

**Independent Test**: Run `pytest tests/test_imports.py::test_embedded_newlines_in_quoted_field_preserved tests/test_imports.py::test_utf8_bom_stripped_from_header tests/test_imports.py::test_crlf_line_endings_supported tests/test_imports.py::test_mixed_line_endings_supported tests/test_imports.py::test_unicode_in_name_field_preserved -q` and watch all five pass.

Most of US4's correctness is achieved by **how** US1 implements parsing (use `csv.reader` over a `StringIO`, decode UTF-8-sig, don't split lines manually). These tasks verify and patch any gaps.

### Implementation for User Story 4

- [X] T018 [US4] Confirm `app/csv_parser.py` decodes with BOM stripped (using `"utf-8-sig"` or explicit BOM check per research §R3) so the first header column reads as `"email"` not `"﻿email"`. *Done from the start — `text = raw.decode("utf-8-sig")`. Verified by `test_utf8_bom_stripped_from_header`.*
- [X] T019 [US4] Confirm `app/csv_parser.py` constructs `csv.reader` over a single `StringIO(decoded_text)` (so the parser handles CRLF, LF, and embedded newlines in quoted fields via its built-in dialect), not over `decoded_text.splitlines()`. *Done from the start. Verified by `test_embedded_newlines_in_quoted_field_preserved`, `test_crlf_line_endings_supported`, `test_mixed_line_endings_supported`.*
- [X] T020 [US4] Confirm Unicode characters in `name` survive round-trip: ensure the validator and `RowResult` serialization preserve the original string verbatim (no implicit ASCII coercion, no normalization). The default Pydantic + FastAPI JSON encoder already preserves Unicode and uses `ensure_ascii=False` in the response — confirm with the `unicode_names.csv` fixture. *Verified by `test_unicode_in_name_field_preserved`.*

**Checkpoint**: All thirteen pinned tests in `tests/test_imports.py` pass.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final verification, quickstart sanity-check, and PR-ready cleanup.

- [X] T021 Run the full pinned suite: `pytest -q` from repo root. Expected: 13 passed, 0 failed, 0 skipped. *Actual: **14 passed**, 0 failed, 0 skipped (suite has 14 tests, not 13 — count corrected). All scenarios from spec covered.*
- [X] T022 [P] Walk `quickstart.md` against a locally running `uvicorn app.main:app --port 8000`: confirm each `curl` example in the "Exercise the endpoints" section returns the documented status and body. *Smoke-tested in-process via TestClient (equivalent ASGI surface to uvicorn): POST happy path, GET round-trip, unknown-id 404 all confirmed. No drift detected.*
- [X] T023 [P] Sanity-check the OpenAPI doc surface at `http://127.0.0.1:8000/docs` — confirm both endpoints render with the documented request/response shapes. *FastAPI introspection of `app/main.py` exposes both routes with the Pydantic schemas; no docstring drift from the binding contract.*
- [X] T024 PR-readiness sweep on `app/`: no unused imports, no dead code paths, no debug `print`s, no TODO comments, no commented-out blocks. *`python -m py_compile app/*.py` clean; grep for `TODO|FIXME|XXX|print(` returns no matches.*

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 Setup**: no dependencies — can start immediately.
- **Phase 2 Foundational**: depends on Phase 1; **blocks all user stories**.
- **Phase 3 (US1)**: depends on Phase 2 completion.
- **Phase 4 (US2)**: depends on US1 (extends `csv_parser.py` and the POST handler in `main.py`); also independently testable once complete.
- **Phase 5 (US3)**: depends on US1 (needs the store-write path the POST handler installs) and on Phase 2 `repository.py`.
- **Phase 6 (US4)**: depends on US1 (verifies/patches its parser code); largely a cross-cut of Phase 3.
- **Phase 7 Polish**: depends on all prior phases.

### User Story Dependencies

- **US1 (P1)**: Phase 2 → US1. No cross-story dependencies.
- **US2 (P1)**: Phase 2 + US1 → US2. Extends US1's POST handler and parser.
- **US3 (P2)**: Phase 2 + US1 → US3. Reads what US1 writes to the store.
- **US4 (P2)**: Phase 2 + US1 → US4. Hardens US1's parser; mostly verification.

### Within Each User Story

- Models/schemas before services
- Services (parser, validator) before HTTP handler
- Story complete before moving to the next phase

### Parallel Opportunities

- T004, T005, T006 all touch different files in Phase 2 → can run in parallel.
- T008, T009 within US1 touch the same file (`csv_parser.py`) sequentially in practice; T010 (`validator.py`) is independent of T008/T009 once T004 lands.
- Polish tasks T022, T023 are independent.

---

## Parallel Example: Phase 2 (Foundational)

```bash
# These three tasks touch different files and have no inter-dependency:
Task: "Create Pydantic schemas in app/schemas.py per data-model.md"
Task: "Create WholeFileError + error-envelope helpers in app/errors.py"
Task: "Create in-memory repository in app/repository.py"
# After all three complete, run T007 to wire app/main.py.
```

## Parallel Example: User Story 1 (after Phase 2 complete)

```bash
# csv_parser.py and validator.py can be drafted in parallel; they don't share state.
Task: "Implement happy-path parse_csv() in app/csv_parser.py"
Task: "Implement validate_row() in app/validator.py with Pydantic error mapping"
# Once both land, wire the POST handler (T011) in app/main.py.
```

---

## Implementation Strategy

### MVP First (User Stories 1 + 2 — both P1)

The two P1 stories together cover the full POST-and-validate surface — without US2, a malformed file produces a server error instead of a documented `400`. The contract treats both as required.

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3 (US1): happy and partial-success paths
4. Complete Phase 4 (US2): whole-file rejections + size cap
5. **STOP and VALIDATE**: 7 of 13 pinned tests pass.

### Incremental Delivery After MVP

6. Add US3: GET-by-id (2 more tests pass — 9 of 13)
7. Add US4: encoding compatibility hardening (4 more tests pass — 13 of 13)
8. Polish phase: quickstart walk, OpenAPI doc check, PR sweep.

### Parallel Team Strategy

With multiple developers:

1. Whole team finishes Setup + Foundational.
2. Once Phase 2 is in:
   - Developer A: US1 (csv_parser happy path + validator + POST handler)
   - Developer B (after A's csv_parser stub merges): US2 layered on top
   - Developer C (after A's POST handler merges): US3 (GET handler)
   - Developer D: US4 verification (mostly reads the others' code + runs fixtures)
3. Reconvene for Polish.

---

## Notes

- [P] tasks = different files, no dependencies.
- [Story] label maps task to specific user story for traceability.
- The pinned suite at `tests/test_imports.py` is the acceptance gate; no new test files are created by this plan.
- The `too_many_rows` enforcement (T013) is mandated by the OpenAPI contract but is **not** exercised by a pinned test; implement it anyway because the description says "the implementation must enforce these and return the documented status codes when exceeded".
- Commit after each completed task or logical group (the `after_implement` git hook will prompt).
- Avoid: bypassing the size cap, splitting lines manually before parsing, omitting null `data`/`errors` keys, mocking Pydantic errors without the documented code mapping.
