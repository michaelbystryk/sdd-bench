## 1. Module Scaffolding

- [x] 1.1 Create `app/main.py` exposing a FastAPI `app` instance (importable as `from app.main import app`, per `tests/test_imports.py`).
- [x] 1.2 Create `app/models.py` with Pydantic models for `UserRow`, `FieldError`, `RowResult`, `ImportResult`, `Error`, and `ErrorResponse` matching `reference/openapi.yaml`. Use `EmailStr` for `email`, an `int` with bounds for `age`, and a `Literal` (or `Enum`) for the `country` whitelist.
- [x] 1.3 Create `app/errors.py` with a `make_error_response(status_code, code, message, details=None)` helper that returns a `JSONResponse` shaped as `{"error": {"code", "message", "details"}}`.
- [x] 1.4 Create `app/store.py` with a module-level `dict[str, ImportResult]` (or equivalent) plus `save(import_id, result)` and `get(import_id) -> ImportResult | None` accessors.

## 2. CSV Parsing And Row Validation

- [x] 2.1 Create `app/parsing.py` with a `parse_csv(raw: bytes) -> tuple[list[str], list[list[str]]]` function that: decodes UTF-8, strips a leading BOM (`U+FEFF`) from the result, wraps in `io.StringIO`, runs `csv.reader`, raises a typed `MalformedCSVError` on `csv.Error` or `UnicodeDecodeError`, and returns `(header, data_rows)`.
- [x] 2.2 In `app/parsing.py`, add a check that returns a typed `EmptyFileError` when the byte buffer is empty (post-BOM-strip) OR when there are zero data rows after the header.
- [x] 2.3 In `app/parsing.py`, add a `validate_header(header) -> list[str]` that returns the list of missing required columns (empty list = OK). Required set: `email, name, age, signup_date, country`.
- [x] 2.4 Create `app/validation.py` with `validate_row(row_dict: dict[str, str]) -> tuple[UserRow | None, list[FieldError]]`. For each of the 5 required fields, check presence → `missing`, coerce/parse → `invalid_type`, range/format/enum → `out_of_range` or `invalid_format`. Return `(UserRow(...), [])` only when no errors were collected.
- [x] 2.5 In `app/validation.py`, implement the specific rules: `email` must match a valid-email check (Pydantic `EmailStr` via `TypeAdapter` is fine — catch `ValidationError` and emit `invalid_format`); `name` empty → `missing`, length > 200 → `out_of_range`; `age` non-integer → `invalid_type`, outside `[0, 150]` → `out_of_range`; `signup_date` not matching `YYYY-MM-DD` parseable by `datetime.date.fromisoformat` → `invalid_format`; `country` not in the whitelist → `invalid_format`.

## 3. HTTP Endpoints

- [x] 3.1 In `app/main.py`, implement `POST /imports/users` accepting `UploadFile`. Stream the upload, aborting with 413 + `file_too_large` as soon as cumulative bytes exceed 10,485,760.
- [x] 3.2 After reading the bytes, call `parse_csv`. On `MalformedCSVError` → 400 + `malformed_csv`. On `EmptyFileError` → 400 + `empty_file`.
- [x] 3.3 Run `validate_header`. If any required columns are missing → 400 + `missing_required_columns` with `details.missing_columns = [...]`.
- [x] 3.4 If data-row count > 100,000 → 400 + `too_many_rows` (snake_case, per spec's row cap; the closed test set does not exercise this, but the OpenAPI contract requires the cap).
- [x] 3.5 Iterate data rows in input order. Build a `dict` zipping the header to the row's cells (truncate/pad short rows defensively only if `csv.reader` returns them — current samples do not). Call `validate_row` and build a `RowResult` with `row_number` starting at 1.
- [x] 3.6 Construct `ImportResult` with a freshly generated `uuid.uuid4()` for `import_id`, populated counts, and per-row results. Save to the store and return the JSON body with status 200.
- [x] 3.7 Implement `GET /imports/{import_id}`. Lookup in the store; on hit return the stored `ImportResult` as JSON with 200; on miss return 404 + `import_not_found`.
- [x] 3.8 Confirm the error envelope is `{"error": {...}}` (NOT FastAPI's default `{"detail": ...}`) for every non-2xx path, by using `make_error_response` consistently rather than raising `HTTPException`.

## 4. Verification

- [x] 4.1 Run `pytest tests/test_imports.py -v` from `~/dev/sdd-bench-t3-builds/openspec` and confirm all tests pass.
- [x] 4.2 If any test fails, fix the root cause in `app/` rather than modifying the test, then re-run.
- [ ] 4.3 Smoke-check: `uvicorn app.main:app --port 8000` starts cleanly with no import errors, and `curl -F file=@reference/sample_csvs/happy.csv http://localhost:8000/imports/users` returns a 200 envelope with `succeeded: 5`. (Optional but recommended for PR readiness.)
