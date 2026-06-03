# Implementation Plan: Library Loan Endpoints

**Branch**: `001-loan-endpoints` | **Date**: 2026-05-27 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/001-loan-endpoints/spec.md`

## Summary

Add loan management to the existing FastAPI lending-library service via three endpoints — `POST /loans` (checkout), `POST /loans/{loan_id}/return` (return), and `GET /members/{member_id}/loans` (list, filterable by status). A new `Loan` entity and a `LoanService` are layered onto the existing router → service → repository architecture, reusing the established `AppError` envelope, `Page` pagination, and in-memory `Database` wiring. Behavior is pinned by `tests/test_loans.py`; no new third-party dependencies are introduced.

## Technical Context

**Language/Version**: Python ≥3.11 (uses `from __future__ import annotations`, PEP 604 unions)

**Primary Dependencies**: FastAPI ≥0.110, Pydantic v2 (≥2.6), Uvicorn (runtime), httpx (TestClient). No new dependencies added.

**Storage**: In-memory process-local repositories (`dict` keyed by integer id), reset/seeded via `app/database.py::reset_db()`. No external datastore.

**Testing**: pytest ≥8.0 with FastAPI `TestClient`; `tests/conftest.py` reseeds state before each test. Target suite: `tests/test_loans.py`; existing `tests/test_books.py` and `tests/test_members.py` must stay green.

**Target Platform**: Linux/macOS server process (`uvicorn app.main:app`).

**Project Type**: Single web-service (REST API), one Python package `app/`.

**Performance Goals**: Not performance-sensitive; in-memory operations are O(n) over small collections. No specific targets.

**Constraints**: No new dependencies; match existing `app/` conventions exactly (layering, error envelope, pagination, schema split); keep book/member behavior unchanged.

**Scale/Scope**: Sample/demo service; small data volumes. Scope is three endpoints plus one entity, service, and repository.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

The project constitution (`.specify/memory/constitution.md`) is an unpopulated template with placeholder principles only — there are no ratified, enforceable gates. No violations possible.

Self-imposed gates derived from the feature's own constraints (all satisfied by this design):

- **No new dependencies**: Design uses only stdlib (`datetime`, `enum`) plus already-present FastAPI/Pydantic. ✅
- **Convention parity**: New code mirrors the existing router/service/repository/schema split and the `AppError` + `Page` patterns. ✅
- **No regression**: Changes are additive (new `Loan` model, `LoanRepository`, `LoanService`, `routers/loans.py`); existing modules are only extended at registration points (`database.py`, `deps.py`, `main.py`). ✅

**Result**: PASS (initial). Re-checked post-design below — still PASS.

## Project Structure

### Documentation (this feature)

```text
specs/001-loan-endpoints/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output — design decisions
├── data-model.md        # Phase 1 output — Loan entity & state transitions
├── quickstart.md        # Phase 1 output — run & verify
├── contracts/
│   └── loans.md         # Phase 1 output — endpoint contracts
├── checklists/
│   └── requirements.md  # Spec quality checklist (/speckit-specify)
└── tasks.md             # Phase 2 output (/speckit-tasks — NOT created here)
```

### Source Code (repository root)

```text
app/
├── main.py              # MODIFIED: include_router(loans.router)
├── config.py            # REUSED: MAX_ACTIVE_LOANS, page limits (no change)
├── models.py            # MODIFIED: add LoanStatus enum + Loan dataclass
├── schemas.py           # MODIFIED: add LoanCreate, LoanRead (reuse Page)
├── repository.py        # MODIFIED: add LoanRepository
├── database.py          # MODIFIED: wire db.loans into Database + reset_db
├── deps.py              # MODIFIED: add get_loan_service()
├── services.py          # MODIFIED: add LoanService (checkout/return/list)
├── exceptions.py        # REUSED: NotFoundError, ConflictError (no change)
├── errors.py            # REUSED: error envelope (no change)
├── pagination.py        # REUSED: paginate() (no change)
└── routers/
    ├── books.py         # UNCHANGED
    ├── members.py       # UNCHANGED
    └── loans.py         # NEW: 3 loan endpoints

tests/
├── test_loans.py        # TARGET (pinned, do not edit)
├── test_books.py        # MUST STAY GREEN
├── test_members.py      # MUST STAY GREEN
└── conftest.py          # UNCHANGED
```

**Structure Decision**: Single-project web service. The feature is purely additive within the existing `app/` package. All three loan endpoints live together in a new `app/routers/loans.py` (declared without a router prefix because the paths span two roots — `/loans` and `/members/{member_id}/loans`). This keeps loan logic cohesive and leaves `routers/members.py` untouched, avoiding coupling the members router to `LoanService`.

## Complexity Tracking

> No constitution violations. No complexity deviations to justify.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| (none)    | —          | —                                    |
