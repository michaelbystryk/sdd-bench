## Why

The service has no way to onboard users in bulk. Operators need to upload a CSV of users, get a per-row validation report (so they can fix the bad rows offline), and later re-fetch that same report by id. The contract is already documented in `reference/openapi.yaml` and pinned by `tests/test_imports.py`; we just need to implement it.

## What Changes

- Add `POST /imports/users` that accepts a `multipart/form-data` CSV upload, validates each data row against the `UserRow` schema, and returns an `ImportResult` envelope (`import_id`, `total`, `succeeded`, `failed`, `results`) with HTTP 200 — even when some or all rows fail row-level validation.
- Add `GET /imports/{import_id}` that returns the exact `ImportResult` body produced by the original POST, or 404 with `error.code = import_not_found`.
- Enforce whole-file failure modes with HTTP 400 and stable error codes: `malformed_csv`, `missing_required_columns` (with `details.missing_columns`), `empty_file`.
- Enforce the 10 MB file-size limit with HTTP 413 and `error.code = file_too_large`; cap data rows at 100,000.
- Parse CSV with UTF-8, strip a leading UTF-8 BOM from the header, preserve embedded newlines inside quoted fields, and accept LF, CRLF, and mixed line endings.
- Emit per-field error codes from a closed set: `missing`, `invalid_type`, `out_of_range`, `invalid_format`.
- Persist import results in-process (keyed by `import_id`) so the GET can replay them within the lifetime of the server process.

## Capabilities

### New Capabilities
- `csv-user-import`: HTTP endpoints for uploading a CSV of users for row-level validation, and retrieving the resulting report by `import_id`.

### Modified Capabilities
<!-- None — this is the first capability in the service. -->

## Impact

- New code under `app/`: FastAPI router for `/imports/users` and `/imports/{import_id}`, Pydantic `UserRow` model, CSV parsing + row-validation service, in-memory result store, and wiring in `app/main.py` (currently an empty package).
- Test surface: `tests/test_imports.py` (already authored) must pass end-to-end.
- No new runtime dependencies — uses FastAPI, Pydantic, and the stdlib `csv` module already declared in `pyproject.toml`.
- No persistence layer, no auth, no background workers; results live for the lifetime of the process only.
