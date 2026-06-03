# Implementation Plan: CSV User Import Service

**Branch**: `001-csv-import` | **Date**: 2026-05-27 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-csv-import/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

Deliver a FastAPI service exposing `POST /imports/users` (multipart CSV upload) and `GET /imports/{import_id}` (re-fetch by id). Each upload is parsed with the stdlib `csv` module, validated row-by-row with a Pydantic model, and returned as a single `ImportResult` envelope with per-row outcomes. Whole-file failures (malformed CSV, missing required columns, empty file, too large) and unknown-id lookups return a uniform `{"error": {...}}` envelope with documented codes. Persistence is an in-process dict keyed by UUID. No new runtime dependencies — everything ships with the stack already in `pyproject.toml`.

The pinned behavior in `tests/test_imports.py` is the source of truth; the OpenAPI contract at `reference/openapi.yaml` is its companion. Both anchor the design decisions in `research.md`.

## Technical Context

**Language/Version**: Python 3.11+ (from `pyproject.toml`)

**Primary Dependencies**: FastAPI ≥0.110, Pydantic ≥2.6 (with `email` extras for `EmailStr`), python-multipart ≥0.0.9, uvicorn ≥0.27, httpx ≥0.27. Standard library `csv` and `uuid` for parsing and id generation. No new runtime dependencies introduced.

**Storage**: In-process Python dict keyed by `import_id` (UUID4). Process-lifetime persistence only — restart-durable storage is out of scope (see spec Assumptions). Acceptable because the pinned tests share one `TestClient` per test invocation and the contract makes no durability claim.

**Testing**: pytest ≥8.0 (already in `[project.optional-dependencies].dev`). The pinned suite at `tests/test_imports.py` is the acceptance gate. Tests use FastAPI's `TestClient` (which uses httpx — already a dependency).

**Target Platform**: Linux server (uvicorn ASGI). Runs locally on macOS for development.

**Project Type**: Single-package Python web service (one `app/` package, one `tests/` directory) — no frontend, no separate services.

**Performance Goals**: Synchronous in-request parsing of up to 100,000 rows. Reject >10 MB uploads before fully reading them. Concrete budget: a happy-path 100-row request should respond well under 1 s on a developer laptop; a 100,000-row file should respond within a few seconds. No specific throughput SLA — the pinned suite is functional, not load-tested.

**Constraints**:
- Hard size cap: 10 MB (10,485,760 bytes) → HTTP 413 `file_too_large`.
- Hard row cap: 100,000 data rows (per OpenAPI). Treat as a structural error (see research.md R6).
- No new runtime dependencies.
- HTTP error envelopes must conform to the documented `{"error": {"code", "message", "details?"}}` shape, including for FastAPI's built-in 404 (path mismatch) and 422 (request validation) cases.

**Scale/Scope**: Two HTTP endpoints, one Pydantic row model, one parser/validator module, one in-process repository. Total: roughly 250–400 lines of application code plus tests.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution at `.specify/memory/constitution.md` is the unfilled template — every `[PRINCIPLE_*]` and `[SECTION_*]` placeholder is still in place. There are no concrete principles to evaluate against, so this gate **passes trivially** (no constraints to violate).

If/when the constitution is filled in, the relevant checks would be:

- Library-first / library reuse: this feature uses only existing pinned dependencies (FastAPI + Pydantic + stdlib `csv`).
- Test-first: the behavioral test suite already exists at `tests/test_imports.py` and is the acceptance gate; implementation is built to satisfy it.
- Simplicity / YAGNI: no background jobs, no database, no auth — a single synchronous request/response per upload, with an in-memory dict for re-fetch.
- Observability: standard FastAPI/uvicorn access logging is sufficient; no structured-logging mandate.

**Post-design re-check (after Phase 1)**: still passes — no new violations introduced (see `data-model.md` and `contracts/` for the design surface).

## Project Structure

### Documentation (this feature)

```text
specs/001-csv-import/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
│   └── openapi.yaml     # Copy of reference/openapi.yaml — the binding contract
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root)

```text
app/
├── __init__.py          # Already exists (empty)
├── main.py              # FastAPI app + route handlers (POST /imports/users, GET /imports/{id})
├── schemas.py           # Pydantic models: UserRow, FieldError, RowResult, ImportResult, ErrorResponse + helpers
├── csv_parser.py        # CSV decoding (UTF-8 + BOM strip), parsing via stdlib csv, header validation
├── validator.py         # Row-by-row validation: maps raw dict rows → RowResult (success or list of FieldError)
├── repository.py        # In-process dict-backed store keyed by import_id; get/put
└── errors.py            # Error envelope helpers + custom exceptions for whole-file failures

tests/
└── test_imports.py      # Already exists — the pinned behavioral suite (do not modify)

reference/               # Already exists — read-only inputs
├── openapi.yaml
└── sample_csvs/

pyproject.toml           # Already configured — do not modify
```

**Structure Decision**: Single Python package (`app/`) plus the pre-existing `tests/` directory. The split inside `app/` keeps parsing (`csv_parser`), validation (`validator`), HTTP I/O (`main`), data shape (`schemas`), persistence (`repository`), and error formatting (`errors`) on distinct seams so the parser can be exercised without spinning up FastAPI and the validator can be exercised without parsing. No `src/` layout — `pyproject.toml` already declares `where = ["."]` with `include = ["app*"]`, and `tests/test_imports.py` imports `from app.main import app`.

## Complexity Tracking

> No constitution violations. Section intentionally empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| _(none)_  | _(n/a)_    | _(n/a)_                              |
