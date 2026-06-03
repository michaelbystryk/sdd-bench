# Requirements — CSV Import Service

**Sources of truth**:
- `reference/openapi.yaml` (API contract)
- `tests/test_imports.py` (16 pinned behaviors)
- `reference/sample_csvs/` (canonical fixtures)

## Functional

### POST /imports/users
- Accepts `multipart/form-data` with field `file`.
- Parses CSV (UTF-8). A leading UTF-8 BOM on the header is stripped before parsing.
- Header must contain all required columns: `email`, `name`, `age`, `signup_date`, `country`. Missing columns → `400 missing_required_columns` with `details.missing_columns: [..]`.
- Malformed CSV (unmatched quote, structural break) → `400 malformed_csv`.
- Zero data rows (header-only or fully empty) → `400 empty_file`.
- File > 10 MB (10,485,760 bytes) → `413 file_too_large`.
- Per-row validation against `UserRow`; rows are reported with `status: success|error`, `row_number` starting at 1 for first data row. Response is `200` even if every row fails.
- Embedded newlines in quoted fields are preserved.
- CRLF, LF, and mixed line endings are supported.
- Non-ASCII characters in `name` are preserved.
- Each successful row's `data` is the parsed `UserRow`; each failed row has a non-empty `errors` array.

### GET /imports/{import_id}
- Returns the exact same JSON body emitted by the originating POST.
- Unknown id → `404 import_not_found`.

## Per-field validation rules (`UserRow`)
| Field | Type | Constraints | Failure code(s) |
|---|---|---|---|
| email | string | RFC-style email | `missing`, `invalid_format` |
| name | string | 1 ≤ len ≤ 200 | `missing`, `out_of_range` |
| age | integer | 0 ≤ age ≤ 150 | `missing`, `invalid_type`, `out_of_range` |
| signup_date | string (ISO 8601 `YYYY-MM-DD`) | parseable date | `missing`, `invalid_format` |
| country | string | enum: US, CA, UK, AU, DE, FR, JP | `missing`, `invalid_format` |

`FieldError.code` is one of: `missing`, `invalid_type`, `out_of_range`, `invalid_format`.

## Non-Functional / Implementation Constraints
- Stack: FastAPI + Pydantic v2 + python-multipart (already in `pyproject.toml`).
- No new runtime dependencies.
- Storage: in-memory dict keyed by import_id (UUID). Lost on restart — acceptable for this scope.
- Implementation must enforce file-size and row-count limits before doing expensive per-row work where possible.

## Out of Scope
- Persistence beyond process lifetime.
- AuthN/AuthZ.
- Rate limiting.
- Streaming uploads.
- Async background processing.
