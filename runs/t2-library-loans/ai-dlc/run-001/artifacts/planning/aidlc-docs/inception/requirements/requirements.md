# Requirements — Library API: Loans Extension

## Intent Analysis
- **User Request**: Add three loan endpoints to the existing FastAPI lending-library service, with behavior pinned by `tests/test_loans.py`, matching `app/` conventions, keeping existing book/member tests green, and adding no new dependencies.
- **Request Type**: New Feature (extension of an existing brownfield service)
- **Scope Estimate**: Single Component (the `app/` package)
- **Complexity Estimate**: Simple → Moderate (straightforward CRUD + a few business rules)
- **Requirements Depth**: Minimal-to-Standard (behavior is fully specified by the target tests)

## Functional Requirements

### FR-1 — Checkout: `POST /loans`
- Accepts `{ "book_id": int, "member_id": int }`.
- On success returns **201** with the created loan: `id` (>0), `book_id`, `member_id`, `status == "active"`, and a null `returned_at`.
- **Decrements** the book's `available_copies` by 1.
- **404 `not_found`** if the book does not exist.
- **404 `not_found`** if the member does not exist.
- **409 `no_copies_available`** if the book has no available copies.
- **409 `loan_limit_exceeded`** if the member already holds `MAX_ACTIVE_LOANS` (=3) active loans.

### FR-2 — Return: `POST /loans/{loan_id}/return`
- On success returns **200** with the loan: `status == "returned"` and a non-null `returned_at`.
- **Restocks** the book (increments `available_copies` by 1).
- **404 `not_found`** if the loan does not exist.
- **409 `already_returned`** if the loan has already been returned (double-return).

### FR-3 — List a member's loans: `GET /members/{member_id}/loans`
- Returns the standard pagination envelope `{ items, total, limit, offset }`.
- `total` reflects the (optionally filtered) number of the member's loans.
- Optional `status` query param filters to `active` or `returned`.

## Non-Functional Requirements
- **Conventions**: Match the existing layered architecture and naming exactly (routers → services → repository → models/schemas; `AppError` envelope; `Page[T]`; `*Create`/`*Read`).
- **No new dependencies**: Implement using FastAPI/Pydantic/stdlib only.
- **Backward compatibility**: All existing book/member tests must remain green.
- **Determinism / isolation**: New storage must reset with `reset_db()` like the others.
- **PR-ready**: Clean diff, docstrings consistent with neighbours, no dead code.

## Security (Baseline extension — ENABLED)
- **SECURITY-05 (Input validation)**: Loan request bodies and the `status` filter are validated via Pydantic / typed query params (allowlist of `active`/`returned`).
- **SECURITY-09 / SECURITY-15 (Safe error handling, fail-closed)**: Errors surface through the existing `AppError` envelope (generic messages, no stack traces); invalid states (no copies, over limit, double return) fail closed via `ConflictError`.
- Remaining SECURITY rules are evaluated for applicability in the Functional Design / Code Generation compliance summaries (most are N/A for an in-memory, auth-less sample service).

## Success Criteria
- `tests/test_loans.py` passes (10 tests) and `tests/test_books.py` + `tests/test_members.py` remain green.
- No new runtime or dev dependencies added.
