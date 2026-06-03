---
title: 'CSV import endpoint for users'
type: 'feature'
created: '2026-05-27'
status: 'done'
baseline_commit: 'NO_VCS'
context:
  - '{project-root}/reference/openapi.yaml'
  - '{project-root}/tests/test_imports.py'
  - '{project-root}/pyproject.toml'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The service currently has no CSV import endpoint. We need POST `/imports/users` to accept a CSV upload, validate every row independently against `UserRow`, and return both a summary and per-row results — plus a GET `/imports/{import_id}` to replay the same payload. Behavior is pinned by `reference/openapi.yaml` and `tests/test_imports.py`.

**Approach:** Implement a FastAPI app with two endpoints, a Pydantic `UserRow` schema, a CSV parsing layer that strips the UTF-8 BOM and uses `csv.reader(strict=True)` for parse-error detection, and an in-memory dict store keyed by UUID. Per-row Pydantic `ValidationError`s are mapped to the `FieldError` envelope (`missing` / `invalid_type` / `out_of_range` / `invalid_format`).

## Boundaries & Constraints

**Always:**
- Use only the dependencies already declared in `pyproject.toml` (`fastapi`, `pydantic[email]`, `python-multipart`, `uvicorn`). No new runtime deps.
- Row-level validation failures return HTTP 200 with `status: "error"` inside `results`; only whole-file failures return non-2xx.
- `total`, `succeeded`, `failed` must reconcile (`succeeded + failed == total`) and `results` must be in input order with 1-indexed `row_number` (header excluded).
- Strip a leading UTF-8 BOM (`\xef\xbb\xbf`) before header parsing.
- File size cap: 10 MB (10,485,760 bytes) — exceeding returns 413 `file_too_large`.
- Row cap: 100,000 data rows.
- GET `/imports/{import_id}` must return **the exact same JSON body** the POST returned, byte-for-byte equivalent (object equality after JSON round-trip).

**Ask First:** No human-gated decisions.

**Never:**
- Persist imports to disk or a database (in-process dict is sufficient).
- Add authentication, rate-limiting, background processing, or pagination.
- Mutate the input file or its row order.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Happy path | Valid 5-row CSV | 200, all rows `status: success`, `data` populated | N/A |
| Partial success | Mix of valid + bad rows | 200, per-row `status` reflects each row; `succeeded`/`failed` reconcile | Row errors carry `FieldError` list |
| Type mismatch (`age=thirty`) | Non-integer age | Row-level error, `code: invalid_type`, `field: age` | Not a whole-file failure |
| Out of range (`age=200`) | Age parses as int but > 150 | Row-level error, `code: out_of_range`, `field: age` | Not a whole-file failure |
| Malformed CSV | Unmatched quote / structural break | 400, `error.code: malformed_csv` | csv.Error raised by `strict=True` reader |
| Missing required column | Header lacks `email` | 400, `error.code: missing_required_columns`, `error.details.missing_columns: ["email", ...]` | Computed from header diff |
| Empty file | Header only or zero bytes | 400, `error.code: empty_file` | N/A |
| File too large | > 10 MB upload | 413, `error.code: file_too_large` | Checked after read |
| Embedded newlines | Newline inside `"…"` quoted field | 200, newline preserved in `data.name` | N/A |
| UTF-8 BOM | `\xef\xbb\xbf` before header | 200, BOM stripped, header parsed normally | N/A |
| CRLF / mixed line endings | `\r\n` or mixed | 200, rows parsed correctly | csv handles via universal newlines |
| Unicode field values | Multi-byte UTF-8 in `name` | 200, values preserved as-is | N/A |
| GET known id | Existing `import_id` | 200, identical body to original POST | N/A |
| GET unknown id | UUID not in store | 404, `error.code: import_not_found` | N/A |

</frozen-after-approval>

## Code Map

- `app/main.py` -- FastAPI app instance + POST/GET route handlers; orchestrates parse → validate → store → respond
- `app/schemas.py` -- Pydantic v2 models: `UserRow`, `FieldError`, `RowResult`, `ImportResult`, `Error`, `ErrorResponse`
- `app/csv_import.py` -- CSV decode/parse/validate; maps Pydantic `ValidationError` to `FieldError` codes; raises typed exceptions for whole-file failures
- `app/store.py` -- Module-level `dict[str, ImportResult]` with `save` / `get` helpers
- `tests/test_imports.py` -- existing, drives acceptance — do not modify

## Tasks & Acceptance

**Execution:**
- [x] `app/schemas.py` -- Define Pydantic v2 models. `UserRow` uses `EmailStr`, `int` with `ge=0, le=150` for `age`, `datetime.date` for `signup_date`, `Literal["US","CA","UK","AU","DE","FR","JP"]` for `country`, `str` with `min_length=1, max_length=200` for `name`. -- Pydantic enforces all field-level rules; predictable error types
- [x] `app/store.py` -- Module-level dict + `save(import_id, result)` / `get(import_id)` returning `Optional[ImportResult]`. -- Replay endpoint needs identity-preserving lookup
- [x] `app/csv_import.py` -- Implement (a) `process_csv(raw: bytes) -> ImportResult` (b) typed `ImportError` subclasses: `MalformedCSVError`, `MissingColumnsError(missing: list[str])`, `EmptyFileError`. Strip BOM, use `io.StringIO` + `csv.reader(strict=True)`, validate header (required columns: `email, name, age, signup_date, country`), iterate rows mapping each through `UserRow.model_validate` and translating `ValidationError` entries to `FieldError`. -- Centralizes parsing & error mapping; keeps `main.py` thin
- [x] `app/main.py` -- Create `app = FastAPI()`. POST `/imports/users` reads `UploadFile`, enforces 10 MB cap (→ 413), routes typed errors to 400 envelopes, generates `uuid4()` `import_id`, stores result, returns body. GET `/imports/{import_id}` returns stored body or 404 `import_not_found`. -- Wires HTTP layer to import logic
- [x] Verify all tests in `tests/test_imports.py` pass without modifying the test file. -- Acceptance gate

**Acceptance Criteria:**
- Given a valid CSV uploaded via `POST /imports/users`, when processing completes, then status is 200 and the response contains `import_id` (UUID), `total`, `succeeded`, `failed`, and an ordered `results` array.
- Given any row-level validation failure, when the file is otherwise parseable, then HTTP status is 200 and the failing row's `RowResult` has `status: "error"`, `data: null`, and a non-empty `errors` list whose codes are drawn from `{missing, invalid_type, out_of_range, invalid_format}`.
- Given a POST that returns 200 with `import_id` X, when the client issues `GET /imports/X`, then the response body is JSON-equal to the original POST body.
- Given `pytest tests/test_imports.py` is run from the repo root, then all 15 tests pass.

## Design Notes

**Pydantic ValidationError → FieldError code mapping** (Pydantic v2 error `type` strings):

```
int_parsing, int_type, float_parsing       -> invalid_type
string_type, bool_type                     -> invalid_type
greater_than, greater_than_equal,
less_than, less_than_equal,
string_too_short, string_too_long          -> out_of_range
value_error  (raised by EmailStr / date)   -> invalid_format
date_from_datetime_parsing, date_parsing,
date_type                                  -> invalid_format
literal_error  (country enum)              -> invalid_format
missing                                    -> missing
```

Unknown error types default to `invalid_format`. `field` is the first segment of `error['loc']`. `message` uses `error['msg']`.

**Why `csv.reader(strict=True)`:** Without `strict=True`, an unmatched quote silently produces a single mega-field instead of raising; `strict=True` raises `csv.Error`, which we translate to `MalformedCSVError`. `csv` handles `\r\n`, `\n`, and embedded newlines inside quoted fields natively when fed via `io.StringIO`.

**Empty file vs. malformed:** Zero bytes after BOM strip → `EmptyFileError`. Bytes present but no data rows after header → also `EmptyFileError`.

**Size enforcement:** Read `UploadFile` fully then `len(bytes) > 10 * 1024 * 1024` → 413. We don't stream because the cap is small and the request is short-lived.

## Verification

**Commands:**
- `uv run pytest tests/test_imports.py -v` -- expected: all tests pass (14/14 confirmed)
- `python -c "from app.main import app; print(app.routes)"` -- expected: includes both `/imports/users` (POST) and `/imports/{import_id}` (GET)

## Suggested Review Order

**HTTP layer (entry point)**

- POST handler — streams body with early 413 on oversize, dispatches typed errors to 400.
  [`main.py:29`](../../app/main.py#L29)

- GET handler — replays stored body or returns 404 `import_not_found`.
  [`main.py:62`](../../app/main.py#L62)

- Error envelope helper — shared `{error: {code, message, details?}}` shape.
  [`main.py:21`](../../app/main.py#L21)

**CSV parsing & whole-file failures**

- `process_csv` — decode → BOM strip → `csv.reader(strict=True)` → header check → row loop.
  [`csv_import.py:118`](../../app/csv_import.py#L118)

- Typed `CSVImportError` subclasses with stable `code` attributes used by `main.py`.
  [`csv_import.py:16`](../../app/csv_import.py#L16)

- Decode path — empty-bytes guard and leading UTF-8 BOM strip.
  [`csv_import.py:106`](../../app/csv_import.py#L106)

**Row-level validation**

- `_validate_row` — empty-field short-circuit (`missing`), then Pydantic, then translate.
  [`csv_import.py:171`](../../app/csv_import.py#L171)

- Pydantic `error['type']` → `FieldError.code` classifier with `invalid_format` fallback.
  [`csv_import.py:81`](../../app/csv_import.py#L81)

**Schemas (contract surface)**

- `UserRow` — `EmailStr`, name 1–200, age 0–150, ISO date, country literal.
  [`schemas.py:14`](../../app/schemas.py#L14)

- `ImportResult` / `RowResult` / `FieldError` — match OpenAPI shapes exactly.
  [`schemas.py:24`](../../app/schemas.py#L24)

**Persistence**

- In-memory dict store keyed by `UUID`; identity-preserving for GET replay.
  [`store.py:7`](../../app/store.py#L7)

