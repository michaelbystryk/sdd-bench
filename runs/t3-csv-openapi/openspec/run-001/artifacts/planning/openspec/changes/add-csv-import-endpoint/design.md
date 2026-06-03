## Context

The service is brand-new: `app/` contains only an empty `__init__.py`, `pyproject.toml` is already configured with FastAPI + Pydantic + python-multipart, and `tests/test_imports.py` plus `reference/openapi.yaml` together pin the exact wire contract. There is no datastore, no auth, no other endpoints. Every behavioral fork the tests care about — file-too-large, malformed CSV, missing columns, empty file, per-row errors, BOM/CRLF/embedded-newlines/unicode handling, and POST→GET round-trip — needs a deliberate code path.

## Goals / Non-Goals

**Goals:**
- Make every test in `tests/test_imports.py` pass.
- Honor the wire contract in `reference/openapi.yaml` exactly: response shape, status codes, error codes, and the closed set of `FieldError.code` values.
- Cleanly separate parsing, row validation, and HTTP concerns so each is testable on its own.
- Stay within the dependencies already declared in `pyproject.toml` (FastAPI, Pydantic, python-multipart, uvicorn, httpx). Use the stdlib `csv` module for parsing.

**Non-Goals:**
- Persistence beyond the process lifetime. The retrieval endpoint replays results from an in-memory dict; a restart loses them.
- Streaming/async CSV parsing. The 10 MB cap makes single-shot reads safe; we do not need chunked uploads.
- Auth, rate-limiting, audit logging, multi-tenant isolation.
- Stable ordering across imports or duplicate-row detection — the spec is silent and the tests do not exercise it.

## Decisions

### 1. Enforce the 10 MB limit before reading the body into memory

Read the upload as a stream and stop at the first byte past 10,485,760. If the cap is exceeded, return 413 with `error.code = file_too_large` and do not attempt to parse. Rationale: parsing a 50 MB upload to discover it's too big wastes memory and CPU, and the test (`test_file_too_large_returns_413`) writes ~11 MB. Implementation: read `UploadFile` in chunks (e.g. 64 KB) into a `bytearray`, bail when `len > MAX_BYTES`. Alternative considered: rely on FastAPI/Starlette `max_upload_size` — rejected because it raises at framework layer with a different envelope than the OpenAPI spec demands.

### 2. Parse with stdlib `csv.reader`, not Pandas or a hand-rolled parser

`csv.reader` natively handles quoted fields with embedded newlines, CRLF/mixed endings (when the file is opened with `newline=''` semantics — for in-memory bytes, decode then wrap in `io.StringIO`), and quote escaping. Hand-rolling correct CSV is error-prone; pulling in pandas violates the "no new dependencies" constraint. We decode the bytes as UTF-8 once, strip a leading BOM (`﻿`) from the resulting string, and feed it to `csv.reader`. Malformed structure (e.g. unclosed quote) raises `csv.Error`, which we catch and translate to `malformed_csv`.

### 3. Whole-file vs row-level errors are decided in distinct phases

Phase A — *structural* checks return 400 with one of three codes:
- `malformed_csv` — `csv.reader` raised, or no rows at all (not even a header).
- `missing_required_columns` — header present but missing one of `email, name, age, signup_date, country`. The 400 body includes `error.details.missing_columns: [...]`.
- `empty_file` — file is fully empty (0 bytes after BOM strip) OR header-only (zero data rows).

Phase B — *row* validation never escalates to a 4xx; per-row failures become `RowResult { status: "error", errors: [...] }` inside a 200 envelope. This split matches both the OpenAPI text and `test_single_row_type_mismatch_is_row_level_not_whole_file`.

Decision order matters: size check → decode → BOM strip → CSV parse → header check → row loop. We don't, for example, raise `missing_required_columns` if the file is empty — `empty_file` wins because the header is absent.

### 4. Use Pydantic for `UserRow`, but emit `FieldError`s manually

The closed set of error codes (`missing`, `invalid_type`, `out_of_range`, `invalid_format`) and the field-name mapping aren't a natural fit for raw `ValidationError.errors()`. We will validate each row by:
1. Building a dict from the header→cell mapping.
2. For each field, checking presence (→ `missing`), coercing the type (→ `invalid_type` on `ValueError`), then applying the range / format / enum check (→ `out_of_range` or `invalid_format`).
3. Constructing a `UserRow` Pydantic model only after the manual checks pass — purely as a typed carrier for the `data` payload.

Rationale: tests assert specific `code` values on specific `field`s (e.g. `age=abc` → `invalid_type`, `age=200` → `out_of_range`). Mapping Pydantic's internal error types onto the closed set is more brittle than just writing the four checks explicitly. The five fields are simple enough that the explicit code is short and obvious.

### 5. In-memory result store keyed by UUID4

A module-level `dict[str, ImportResult]` holds the last response keyed by `import_id`. POST writes; GET reads; unknown id → 404 with `import_not_found`. No eviction policy — the spec doesn't require one, and the test suite never produces enough imports to matter. The store lives on the FastAPI app's `state` (or as a module global) so tests using `TestClient(app)` share it within a process. Alternative considered: SQLite — rejected as overkill and against the "don't add runtime dependencies" instruction (sqlite3 is stdlib but introduces schema, migrations, and lock semantics for zero test benefit).

### 6. Single error envelope helper

All non-2xx responses return `{"error": {"code": ..., "message": ..., "details": {...}|null}}`. A small helper builds this and returns a `JSONResponse(status_code=..., content=...)`. FastAPI's default `HTTPException` shape (`{"detail": ...}`) does NOT match the spec and would fail tests — we override or simply use `JSONResponse` directly.

### 7. Row limit of 100,000

The OpenAPI spec mentions a hard cap of 100,000 data rows but the test suite doesn't exercise it. We still enforce it because the contract says we must: after parsing, if the row count exceeds 100,000, treat the whole upload as a structural failure and return 400 with a documented code. The spec doesn't name the code, so we use `too_many_rows` (snake_case, consistent with the rest). This is the only place we add a code beyond what tests directly exercise; it's necessary for spec conformance, and the tests don't constrain its name.

## Risks / Trade-offs

- **[In-memory store loses results on restart]** → Acceptable per non-goals; the GET endpoint is documented as best-effort within the process. If durability is later needed, swap the dict for SQLite without touching the public API.
- **[10 MB cap held in RAM]** → A single ~10 MB bytearray per concurrent upload is fine for the service's expected load. If concurrent uploads become significant, switch to spooling to a tempfile.
- **[Manual field validation instead of Pydantic-native]** → More code to maintain than a one-line `UserRow.model_validate(...)`, but the error-code mapping is explicit and tested. Worth the verbosity.
- **[Strict UTF-8]** → Any non-UTF-8 encoding (e.g. Latin-1) will fail decode. The OpenAPI spec says "Encoding: UTF-8" and the tests only cover UTF-8 + BOM, so we treat a `UnicodeDecodeError` as `malformed_csv`. If real users hit this, surface a clearer code later.
- **[`csv.reader` newline handling for bytes]** → We decode bytes to `str` then wrap in `io.StringIO`. `csv.reader` on a `StringIO` correctly handles `\r\n`, `\n`, and mixed endings when the underlying string is read as a whole. Verified by `test_crlf_line_endings_supported` and `test_mixed_line_endings_supported`.

## Migration Plan

Not applicable — there is no prior version of this endpoint, no existing consumers, and no data to migrate. Deployment is a fresh add.

## Open Questions

- None blocking. The OpenAPI spec is precise on the wire contract, and the test suite pins the behavior we need.
