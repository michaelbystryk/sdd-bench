# Phase 0 Research: CSV User Import Service

This file resolves every open design question raised by the spec and the Technical Context. Each entry follows the Decision / Rationale / Alternatives format. Findings here drive `data-model.md`, `contracts/`, and `quickstart.md`.

There are no `NEEDS CLARIFICATION` markers in `plan.md` — the contract pins enough of the behavior that all open questions are design choices, not unknowns.

---

## R1 — Size-limit enforcement before full parse

**Decision**: Enforce the 10 MB limit by reading the request body in bounded chunks (e.g., 64 KiB) and short-circuiting as soon as `bytes_read > 10_485_760`, returning HTTP 413 with `{"error":{"code":"file_too_large", ...}}`. Do not rely on `Content-Length` headers (clients may omit them or lie). Do not buffer the whole body before checking.

**Rationale**: The pinned test `test_file_too_large_returns_413` uploads an ~11 MB CSV; we must reject it without OOM-ing or wasting parsing time. FastAPI's `UploadFile` exposes async `read(size)` over the underlying SpooledTemporaryFile, so we can iterate. Cutting off at the threshold also satisfies SC-006 in the spec.

**Alternatives considered**:
- Trust `Content-Length`: fragile, easily spoofed, breaks for chunked uploads.
- Read entire body then check `len(body)`: works for the test fixture but defeats the spirit of the limit on much larger uploads.
- Add starlette `Middleware` to cap request size globally: overreach — the cap is endpoint-specific (other endpoints may legitimately accept more), and middleware-level errors produce non-conforming error envelopes.

---

## R2 — CSV parsing library

**Decision**: Use the Python standard library `csv` module (`csv.reader` over a `StringIO` decoded as UTF-8 with BOM stripped). Do not introduce `pandas` or `polars` or any third-party parser.

**Rationale**: The "no new runtime dependencies" constraint is explicit. The stdlib `csv` module already handles:
- RFC 4180 quoting (covers `embedded_newlines.csv` — quoted field with `\n` inside).
- Mixed line endings via the `newline=""` open-mode convention; for in-memory parsing we feed a `StringIO` with `newline=""` so the module's universal-newline machinery sees both `\r\n` and `\n` correctly.
- Malformed quotes raise `csv.Error`, which we catch and convert to `malformed_csv`.

It does **not** handle BOM stripping or row-cap enforcement — we handle those before/around the call.

**Alternatives considered**:
- `pandas.read_csv`: would add a heavy dep; per-row error reporting via `error_bad_lines` is coarser; out of scope.
- `polars`: same concern; not pinned.
- Hand-rolled parser: more code, more bugs around quoting and embedded newlines — strictly worse than `csv`.

---

## R3 — UTF-8 BOM stripping

**Decision**: After reading bytes, decode as UTF-8. If the decoded string starts with `﻿` (the BOM character), drop it before feeding the buffer to `csv.reader`. Equivalently, decode with `codecs.BOM_UTF8` stripped from bytes first.

**Rationale**: Pinned test `test_utf8_bom_stripped_from_header` ends with `assert body["results"][0]["data"]["email"] == "alice@example.com"` — if BOM survives, the first header column becomes `"﻿email"`, our schema would not see `email`, and we'd return `400 missing_required_columns` instead of `200`. Stripping at the boundary is the smallest fix and matches the OpenAPI text ("A leading UTF-8 BOM is permitted and must be stripped before parsing the header").

**Alternatives considered**:
- Decode with `"utf-8-sig"`: works and is idiomatic — equally acceptable. Picking explicit BOM removal makes the intent visible in code. Either is correct.
- Strip BOM only from the first header cell: too clever; if a BOM somehow appears mid-stream we'd rather decode cleanly once at the top.

---

## R4 — Pydantic vs. manual validation

**Decision**: Define `UserRow` as a Pydantic v2 `BaseModel` with `EmailStr`, an `int` with `ge=0, le=150` for `age`, a `date` for `signup_date`, and a `Literal[...]` enum for `country`. Validate by calling `UserRow.model_validate(row_dict)` inside a try/except `ValidationError`. Map Pydantic's error `type` codes back to the four documented `FieldError.code` values (`missing` / `invalid_type` / `out_of_range` / `invalid_format`) via an explicit lookup table.

**Rationale**: Pydantic is already a pinned dependency with email extras. Doing validation manually re-implements three things Pydantic already does (email syntax, integer parse, date parse). What Pydantic does **not** do directly is emit our four stable error codes — so we add a thin mapper from Pydantic's `errors()` output (`type`, `loc`) to `FieldError`. Mapping table (see `data-model.md` for the canonical version):

| Pydantic error `type`            | Our `code`       |
|----------------------------------|------------------|
| `missing`, `string_too_short` on a required field | `missing`        |
| `int_parsing`, `int_type`        | `invalid_type`   |
| `greater_than_equal`, `less_than_equal` (for `age`) | `out_of_range`   |
| `value_error` (EmailStr), `date_from_datetime_parsing`, `date_parsing`, `literal_error` (country) | `invalid_format` |

Empty-string detection (`""`) is treated as `missing` before handing to Pydantic for `email`, `signup_date`, `country` so we don't conflate an empty cell with a format violation.

**Alternatives considered**:
- All-manual validation: less code reuse, more cases to test ourselves, easy to drift from `EmailStr`'s rules.
- Pydantic with default error formatting passed straight through: violates the contract — clients expect our four codes, not Pydantic's larger error vocabulary.

---

## R5 — Persistence strategy

**Decision**: A module-level dict `_store: dict[uuid.UUID, ImportResult]` in `app/repository.py`, with `put(import_id, result)` and `get(import_id) -> ImportResult | None`. No locking — uvicorn's default workers are single-process and FastAPI handles requests on the asyncio loop; the GIL plus dict-assignment atomicity is sufficient for this contract.

**Rationale**: The pinned test only requires that `GET /imports/{id}` returns the same body as the originating POST within the same `TestClient` session. The OpenAPI text says nothing about durability across restarts or workers. An in-process dict satisfies the entire contract with the smallest possible surface area.

**Alternatives considered**:
- SQLite via `sqlite3` (stdlib, no new dep): would satisfy durability we don't need; complicates teardown; not warranted.
- `functools.lru_cache`: wrong abstraction — that's bounded eviction; we want explicit `put`/`get`.

---

## R6 — Row-count cap (100,000 rows)

**Decision**: Enforce the 100,000-row cap as a whole-file rejection. If the data row count exceeds 100,000 while parsing, abort and return HTTP 400 with `error.code="too_many_rows"` (mirroring the OpenAPI text "Maximum data rows: 100,000"). Stop reading further rows once the cap is crossed — do not validate them.

**Rationale**: The OpenAPI explicitly documents the cap and groups it under "Limits". The pinned test suite does not exercise this case (no fixture beyond the 10 MB one), but the OpenAPI says the implementation "must enforce these and return the documented status codes when exceeded". `413` is reserved by the spec text for size-in-bytes; `400` is the natural fit for "structural" rejection of a too-large row count, with a fresh stable code. This keeps the pinned suite green while honoring the documented contract for the full surface.

**Alternatives considered**:
- Return `413` for too many rows: would conflate size and count; not what the OpenAPI text says.
- Silently truncate at row 100,000 and return `200`: contradicts "must enforce ... return the documented status codes when exceeded" and would surprise operators who think their tail rows succeeded.
- Skip enforcement entirely: arguable since no test pins it, but the OpenAPI mandates the check and PR-ready code should match the documented contract, not the test minimum.

---

## R7 — Embedded-newline handling

**Decision**: Pass `StringIO` text (not raw bytes) to `csv.reader`. Use the stdlib parser's default dialect — its quote-aware machinery preserves `\n` inside double-quoted fields automatically. Do not split the input on `\n` before handing to `csv.reader`.

**Rationale**: The pinned test `test_embedded_newlines_in_quoted_field_preserved` asserts `"\n" in alice["data"]["name"]`. The fixture has `"Alice\nSmith"` as a quoted name field. Splitting on newlines first would cut the row in half. `csv.reader` does the right thing if we just feed it the whole decoded string at once.

**Alternatives considered**:
- Stream line-by-line via `splitlines()`: breaks quoted-newline fields. Rejected.
- `csv.reader` over a file object: equivalent, but requires constructing a `StringIO` either way.

---

## R8 — Error envelope shape across all non-2xx responses

**Decision**: Install a single custom exception class `WholeFileError(code, message, status, details=None)` and a FastAPI exception handler that emits `{"error": {"code": code, "message": message, "details": details}}` with the corresponding HTTP status. Register this for our endpoints. Also register handlers for FastAPI's built-in `RequestValidationError` and `StarletteHTTPException` (specifically 404 path-mismatch and 405) so the envelope shape is consistent even when FastAPI handles the response itself — but only insofar as the pinned suite exercises them.

**Rationale**: The pinned suite only asserts the envelope shape for cases we raise ourselves (`malformed_csv`, `missing_required_columns`, `empty_file`, `file_too_large`, `import_not_found`). For those five, the cleanest path is one exception class plus one handler. Wrapping the FastAPI-built-in errors keeps the surface consistent for clients beyond the pinned tests, at zero risk of breaking them.

**Alternatives considered**:
- Per-error-type exception classes: more files, no behavior win for five codes.
- Raise `HTTPException` directly with a JSON-shaped detail: works, but leaks the FastAPI default `{"detail": ...}` shape in places we don't override — violates the uniform envelope claim.

---

## R9 — Row-number assignment

**Decision**: `row_number` starts at 1 for the first data row and increments by one per row in input order. Quoted fields containing embedded newlines do **not** advance `row_number` (the stdlib `csv.reader` returns one row per logical record).

**Rationale**: The OpenAPI text and the pinned tests (`partial_success.csv` — Bob's row is `row_number == 2`) both confirm this scheme. Using `csv.reader`'s row iteration (rather than line iteration) gives the right semantics for free.

**Alternatives considered**: None — the contract is explicit.

---

## R10 — `data` and `errors` field nullability in `RowResult`

**Decision**: Always serialize **both** `data` and `errors` keys on every `RowResult`. On `status="success"`: `data` populated, `errors: null`. On `status="error"`: `data: null`, `errors` populated. Use Pydantic's `model_dump(by_alias=False, exclude_none=False)` (or equivalently `Field(...)` with `None` defaults) to keep both keys present.

**Rationale**: The pinned test `test_single_row_type_mismatch_is_row_level_not_whole_file` asserts `row["data"] is None` for an error row — which requires the `data` key to be present and null, not omitted. The OpenAPI schema marks both fields `nullable: true`, consistent with "present but null on the off branch."

**Alternatives considered**:
- Omit the off-branch field entirely (`exclude_none=True`): would cause `KeyError: "data"` in the assert above.
- Use a discriminated union: heavier than needed; the explicit-null shape is what the contract describes.

---

## R11 — Concurrency / thread safety for the in-process store

**Decision**: No explicit locking around the `_store` dict. POSTs that write and GETs that read are single-threaded under uvicorn's default worker (`--workers 1`) and inside `TestClient`, which is what the pinned tests use. The dict operations we perform (single `__setitem__`, single `__getitem__`) are atomic under CPython's GIL.

**Rationale**: The contract has no multi-worker durability guarantee. Adding `asyncio.Lock` would mask, not protect against, scenarios the contract doesn't require. We'd revisit only if the deployment story changes (multi-process, persistent store).

**Alternatives considered**:
- `asyncio.Lock`: unnecessary; can introduce deadlocks if mis-used.
- `threading.Lock`: unnecessary under asyncio + single worker.

---

## R12 — How the empty-file check distinguishes "header-only" from "fully empty"

**Decision**: Both fully-empty (zero bytes after BOM strip) and header-only (one row that successfully parses as a header but no subsequent data rows) produce `error.code="empty_file"`. Detection order in the handler:
1. After size check passes, decode UTF-8 and strip BOM.
2. If the resulting text is empty or whitespace-only → `empty_file`.
3. Otherwise feed to `csv.reader`. The first row is the header. If no further rows arrive before iterator exhaustion → `empty_file`.
4. `malformed_csv` (raised as `csv.Error` mid-parse) wins over `empty_file` if iterating raises before we know whether data rows exist.

**Rationale**: The pinned test fixture `empty.csv` contains a header line and nothing else, and the test asserts `error.code == "empty_file"`. The OpenAPI text says "file contains zero data rows (header-only file or fully empty file)" — both cases share one code. Putting size and decode checks before parse keeps `empty_file` from misclassifying a malformed file.

**Alternatives considered**:
- Separate `empty_file` vs. `header_only` codes: would split the contract code we're documented to return.
- Always treat zero rows as a successful import with `total=0`: contradicts the test fixture and the OpenAPI text.

---

## R13 — Test runner & invocation

**Decision**: Tests are run with `pytest tests/test_imports.py -q`. The suite imports `from app.main import app` and instantiates `TestClient(app)` per test (fixture). No conftest needed; nothing global to set up.

**Rationale**: Already wired in `pyproject.toml` (`testpaths = ["tests"]`, `pythonpath = ["."]`). Per-test client means each test gets a fresh `_store`. Actually — re-reading: the store is module-level, so it persists *across* tests in the same process. The pinned tests are written so this is fine (no test asserts the store is empty), and `test_get_import_unknown_id_returns_404` uses a freshly generated `uuid.uuid4()` that can't collide with prior POSTs.

**Alternatives considered**:
- Clear `_store` between tests via a pytest fixture: not needed; the suite tolerates accumulated state.
- Use FastAPI dependency injection to swap the store: overkill for a 1-key dict.
