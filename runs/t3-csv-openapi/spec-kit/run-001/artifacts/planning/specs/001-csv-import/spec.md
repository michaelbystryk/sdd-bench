# Feature Specification: CSV User Import Service

**Feature Branch**: `001-csv-import`

**Created**: 2026-05-27

**Status**: Draft

**Input**: User description: "Build a CSV import service per `reference/openapi.yaml`. The behavior is pinned by `tests/test_imports.py` — make those tests pass. Stack: FastAPI + Pydantic per `pyproject.toml` (already configured). Don't add new runtime dependencies. Produce PR-ready code. Sample CSVs for local testing are in `reference/sample_csvs/`."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Upload a CSV of users and receive per-row validation results (Priority: P1)

A data operator uploads a CSV file containing user records. The service parses the file, validates each row independently, and returns a single response that lists every row's outcome along with a summary count of successes and failures. Successful rows include the parsed user data; failed rows include structured field-level error codes. The response carries a unique import identifier so the operator can refer back to the same results later.

**Why this priority**: This is the core value of the feature. Without it, no other capability matters. Operators need to know which rows landed cleanly and which need correction, in one pass, without an opaque "import failed" answer.

**Independent Test**: Submit any of the sample CSVs to the upload endpoint and verify the response contains an import id, total/succeeded/failed counts, and a per-row results array in input order. Both fully-valid and partially-invalid files must return success (HTTP 200) with per-row outcomes inside the payload.

**Acceptance Scenarios**:

1. **Given** a CSV with five valid user rows, **When** the operator uploads it, **Then** the response is HTTP 200, `total=5`, `succeeded=5`, `failed=0`, and every result has `status="success"` with parsed `data`.
2. **Given** a CSV with three valid and two invalid rows (one with a non-numeric age, one with age out of range), **When** the operator uploads it, **Then** the response is HTTP 200, `total=5`, `succeeded=3`, `failed=2`, results appear in input order, and each invalid row carries field-level error codes (`invalid_type`, `out_of_range`) identifying which column failed.
3. **Given** a CSV whose only data row has a non-numeric age, **When** the operator uploads it, **Then** the response is HTTP 200 with one result whose `status="error"`, `data` is null, and `errors` contains a `{field: "age", code: "invalid_type"}` entry — a single bad row is a row-level failure, never a whole-file failure.

---

### User Story 2 - Reject malformed or unusable uploads with a clear envelope (Priority: P1)

When the file cannot be processed at all — it isn't valid CSV, it's missing required columns, it has no data rows, or it exceeds the size limit — the service refuses the request and returns a structured error envelope explaining why. The operator can distinguish "the whole file is wrong" from "some rows are wrong" by looking at the HTTP status alone.

**Why this priority**: Without crisp whole-file rejection, operators cannot tell whether to retry, fix the file, or contact support. Mixing whole-file failures into the per-row response would force every client to inspect counts and infer file-level problems.

**Independent Test**: Upload each failure-mode fixture (malformed quotes, header missing a required column, header-only file, file over 10 MB) and verify the matching HTTP status (400 or 413) and `error.code` in the response body.

**Acceptance Scenarios**:

1. **Given** a CSV with an unmatched quote that breaks parsing, **When** uploaded, **Then** the response is HTTP 400 with `error.code="malformed_csv"`.
2. **Given** a CSV whose header is missing the `email` column, **When** uploaded, **Then** the response is HTTP 400 with `error.code="missing_required_columns"` and `error.details.missing_columns` containing `"email"`.
3. **Given** a CSV with only a header row (zero data rows), **When** uploaded, **Then** the response is HTTP 400 with `error.code="empty_file"`.
4. **Given** a CSV larger than 10 MB, **When** uploaded, **Then** the response is HTTP 413 with `error.code="file_too_large"`.

---

### User Story 3 - Retrieve the results of a prior import by id (Priority: P2)

After an upload, the operator (or another system) can fetch the exact same response payload using the `import_id` returned by the original POST. Unknown ids produce a structured not-found error.

**Why this priority**: Operators often need to re-examine an import after the fact — to share results, audit a partial-success file, or pass the id to a downstream system. Persistence-by-id keeps the operator from having to re-upload. Lower priority than P1 because it depends on P1 having executed first and is a convenience over the primary upload-and-inspect flow.

**Independent Test**: Upload a valid CSV, capture `import_id` from the response, then GET `/imports/{import_id}` and verify the returned body is byte-equivalent to the POST response. Separately, GET with a random UUID and verify a 404 envelope.

**Acceptance Scenarios**:

1. **Given** a successful upload with `import_id=X`, **When** the operator calls `GET /imports/X`, **Then** the response is HTTP 200 and the body equals the original POST response body.
2. **Given** an id that was never issued, **When** the operator calls `GET /imports/{id}`, **Then** the response is HTTP 404 with `error.code="import_not_found"`.

---

### User Story 4 - Accept common real-world CSV encodings and line endings (Priority: P2)

Spreadsheet exports from different operating systems and locales produce CSV files with quirks: a leading UTF-8 byte-order mark, CRLF or mixed line endings, non-ASCII characters in names, and quoted fields that contain embedded newlines. The service handles each of these without error so operators don't have to pre-process files.

**Why this priority**: These quirks are common (Excel exports add BOMs; Windows tools emit CRLF; international names contain accented and non-Latin characters). Failing on them would force every operator to clean files before upload — a frustrating gate on the primary flow. Listed as P2 because the core happy path can work without each of these in isolation, but realistic operator files routinely combine several.

**Independent Test**: Upload each compatibility fixture (BOM-prefixed, CRLF, mixed endings, embedded newlines in a quoted field, unicode names) and verify HTTP 200 with all rows succeeding and the original text content preserved in the parsed data.

**Acceptance Scenarios**:

1. **Given** a CSV with a leading UTF-8 BOM, **When** uploaded, **Then** the response is HTTP 200, the row parses cleanly, and the BOM is not retained in any field value (in particular, the first header is `email`, not `﻿email`).
2. **Given** a CSV with CRLF line endings (or mixed CRLF/LF), **When** uploaded, **Then** every row parses successfully.
3. **Given** a CSV where a quoted `name` field contains an embedded newline, **When** uploaded, **Then** the row parses successfully and the embedded newline is preserved in the returned `data.name`.
4. **Given** a CSV with non-ASCII names ("Álvaro García", "日本太郎", "Müller Karl"), **When** uploaded, **Then** every row parses successfully and the names are returned verbatim.

---

### Edge Cases

- **Header-only file**: A file with a valid header row and no data rows is rejected as `empty_file` (not returned as a successful import with `total=0`). This protects operators from accidentally "succeeding" on a truncated upload.
- **Single bad row**: A file whose only data row fails validation returns HTTP 200 with one row-level error, not HTTP 400. Whole-file errors describe file structure; row errors describe row content.
- **Multiple missing columns**: When the header is missing more than one required column, all missing names are listed in `error.details.missing_columns`.
- **Boundary values for `age`**: `0` and `150` are accepted; `-1` and `151` are `out_of_range`. A non-numeric value is `invalid_type`, not `out_of_range`.
- **Row ordering**: `results` is returned in input order, with `row_number` starting at 1 for the first data row (header is not counted).
- **Repeated GET**: Fetching the same `import_id` repeatedly returns the same body each time; the original POST response is the source of truth.

## Requirements *(mandatory)*

### Functional Requirements

#### Upload endpoint

- **FR-001**: The service MUST accept a CSV file via multipart upload at `POST /imports/users` with the file part named `file`.
- **FR-002**: The service MUST require a header row that contains every required column: `email`, `name`, `age`, `signup_date`, `country`. Additional unknown columns are permitted and ignored.
- **FR-003**: The service MUST validate each data row independently against the schema below and report results per row, never aborting the import because of row-level failures.
- **FR-004**: For each row, the service MUST emit a `RowResult` containing `row_number` (1-based, header excluded), `status` (`success` or `error`), `data` (the parsed user object when successful, otherwise null), and `errors` (an array of field-level errors when failed, otherwise null).
- **FR-005**: The service MUST return an `ImportResult` envelope containing `import_id` (UUID), `total`, `succeeded`, `failed`, and `results` (per-row results in input order). HTTP status is 200 whenever the file was structurally processable, regardless of how many rows failed validation.

#### Row validation

- **FR-006**: `email` MUST be present and be a syntactically valid email address; failure is reported as `invalid_format` (or `missing` if empty/absent).
- **FR-007**: `name` MUST be present, non-empty, and no longer than 200 characters; embedded newlines inside quoted fields MUST be preserved verbatim.
- **FR-008**: `age` MUST be an integer between 0 and 150 inclusive. A non-integer value reports `invalid_type`; an integer outside the range reports `out_of_range`; an empty value reports `missing`.
- **FR-009**: `signup_date` MUST be a valid ISO 8601 calendar date (`YYYY-MM-DD`); other shapes report `invalid_format`; empty reports `missing`.
- **FR-010**: `country` MUST be one of `US`, `CA`, `UK`, `AU`, `DE`, `FR`, `JP`; other values report `invalid_format`; empty reports `missing`.
- **FR-011**: Each `FieldError` MUST carry `field` (the column name), `code` (one of `missing`, `invalid_type`, `out_of_range`, `invalid_format`), and a human-readable `message`.

#### Whole-file failures

- **FR-012**: If the file is not parseable as CSV (e.g., unmatched quote, structural break), the service MUST return HTTP 400 with `error.code="malformed_csv"`.
- **FR-013**: If the header row is missing one or more required columns, the service MUST return HTTP 400 with `error.code="missing_required_columns"` and `error.details.missing_columns` set to an array of the missing column names.
- **FR-014**: If the file has zero data rows (header-only or fully empty), the service MUST return HTTP 400 with `error.code="empty_file"`.
- **FR-015**: If the uploaded file exceeds 10 MB (10,485,760 bytes), the service MUST return HTTP 413 with `error.code="file_too_large"`. The limit MUST be enforced before full parsing where practical.
- **FR-016**: All non-2xx responses MUST use a single envelope shape: `{"error": {"code": "...", "message": "...", "details": {...}?}}`.

#### Encoding compatibility

- **FR-017**: The service MUST accept UTF-8 input and MUST strip a leading UTF-8 byte-order mark before parsing the header row.
- **FR-018**: The service MUST accept LF, CRLF, and mixed line endings.
- **FR-019**: The service MUST preserve embedded newlines inside RFC 4180-style quoted fields.
- **FR-020**: The service MUST preserve non-ASCII characters in field values (e.g., accented Latin, CJK).

#### Retrieval endpoint

- **FR-021**: After a successful POST, the service MUST persist the `ImportResult` keyed by `import_id` so that `GET /imports/{import_id}` returns a body equal to the original POST response.
- **FR-022**: `GET /imports/{import_id}` with an unknown id MUST return HTTP 404 with `error.code="import_not_found"`.

### Key Entities

- **UserRow**: A single parsed user record — `email`, `name`, `age`, `signup_date`, `country`. Represents one valid data row.
- **FieldError**: A validation failure on one column of one row — `field`, `code` (one of `missing`/`invalid_type`/`out_of_range`/`invalid_format`), `message`.
- **RowResult**: The outcome for one input row — `row_number`, `status`, plus exactly one of `data` (on success) or `errors` (on failure).
- **ImportResult**: The full response payload — `import_id` (UUID), `total`, `succeeded`, `failed`, `results` (ordered list of `RowResult`). Persisted by `import_id` so it can be re-fetched.
- **ErrorResponse**: The envelope used for any non-2xx response — `error: { code, message, details? }`. Used for whole-file rejections and unknown-id lookups.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All scenarios pinned by the project's behavioral test suite for the import endpoints pass with no failures and no skips.
- **SC-002**: For a fully-valid CSV of N rows, the response reports `total=N`, `succeeded=N`, `failed=0`, with `results` of length N in input order.
- **SC-003**: For a partially-valid CSV, every invalid row carries at least one `FieldError` whose `field` matches the column at fault and whose `code` is one of the four documented codes; `succeeded + failed == total` always.
- **SC-004**: Whole-file rejections (`malformed_csv`, `missing_required_columns`, `empty_file`, `file_too_large`, `import_not_found`) each return the documented HTTP status and the documented `error.code` value 100% of the time, distinguishable by code alone without parsing `message`.
- **SC-005**: For every successful upload, a subsequent `GET /imports/{import_id}` returns a body equal to the POST response body. The id is a valid UUID.
- **SC-006**: A 10 MB upload is rejected with HTTP 413 and the operator does not have to wait for the full file to be parsed before receiving the rejection.

## Assumptions

- **Authentication is out of scope** for this feature. The endpoints are reachable without credentials; access control is expected to be layered on by deployment/infra later. The pinned behavioral suite does not exercise auth.
- **Storage is in-process and ephemeral.** Persisted `ImportResult` payloads live for the lifetime of the running service process. Cross-process or restart-durable persistence is not required by the contract and is not implied by the test suite; if a deployment needs durability, that is a follow-on concern.
- **Concurrency profile is light.** The service handles imports one upload at a time per client; there is no batching, queueing, or async job model in the contract — the POST returns the full result synchronously.
- **No new runtime dependencies are introduced.** The implementation uses only the packages already declared in `pyproject.toml` (FastAPI, Pydantic with email extras, python-multipart, uvicorn, httpx). CSV parsing uses the Python standard library.
- **Schema is fixed.** The required columns and the `country` enum are exactly the set documented in the OpenAPI contract; additional locales or columns would be a separate feature.
- **The OpenAPI contract and the pinned test suite are the authoritative behavior.** Where the description here and those documents could disagree, those documents win.
