# csv-import — Code Summary

## File
- `app/main.py` — entire service (single module, ~180 LOC).

## Components
| Symbol | Purpose |
|---|---|
| `UserRow`, `FieldError`, `RowResult`, `ImportResult` | Pydantic response models matching the OpenAPI schemas. |
| `MAX_FILE_SIZE`, `MAX_ROWS`, `REQUIRED_COLUMNS`, `COUNTRY_ENUM`, `DATE_PATTERN` | Constants from the spec. |
| `_STORE` | Module-level `dict[str, ImportResult]` — in-memory persistence keyed by import_id. |
| `_error()` | Helper for the standard `ErrorResponse` envelope. |
| `_is_valid_email()` | Thin wrapper around `email_validator.validate_email` (no DNS lookup). |
| `_validate_row()` | Per-field validation, returns `(UserRow \| None, [FieldError])`. |
| `_read_capped()` | Reads `UploadFile` in 64KB chunks, aborts when threshold exceeded. |
| `POST /imports/users` | Multipart upload → parse → validate → store → return `ImportResult`. |
| `GET /imports/{import_id}` | Lookup by id → return stored `ImportResult` or 400/404 envelope. |

## Behavior decisions
- **File size**: enforced by `_read_capped` — bails as soon as buffered bytes exceed 10 MB to avoid OOM on huge uploads.
- **BOM**: `bytes.decode("utf-8-sig")` strips a single leading UTF-8 BOM.
- **CSV parsing**: stdlib `csv.reader` on a `StringIO`. Handles CRLF, LF, and mixed line endings natively, preserves embedded newlines in quoted fields.
- **Malformed detection**: combination of (a) `csv.Error` exceptions and (b) any data row whose column count differs from the header (catches the unmatched-quote case where the parser consumes the rest of the file as one field).
- **Empty file**: covers both fully-empty payloads (zero bytes / whitespace only) and header-only files.
- **Per-field error codes**: assigned by hand (`missing`/`invalid_type`/`out_of_range`/`invalid_format`) so we keep precise control instead of mapping Pydantic `ValidationError`s.
- **Email**: `email_validator` is already pulled in via `pydantic[email]`; no new runtime dep.
- **Date**: regex pre-check enforces strict `YYYY-MM-DD`, then `date.fromisoformat` confirms calendar validity.
- **Row-count limit (100k)**: enforced; returns `400 too_many_rows`. Not exercised by the test suite but required by spec.
- **`null` data/errors**: success rows serialize `errors: null`; error rows serialize `data: null` — matches the spec's `nullable: true` on both fields.

## Dependencies
- No new runtime deps. Uses only what `pyproject.toml` already declares: `fastapi`, `pydantic[email]`, `python-multipart`.
- stdlib: `csv`, `io`, `re`, `uuid`, `datetime`, `typing`.
