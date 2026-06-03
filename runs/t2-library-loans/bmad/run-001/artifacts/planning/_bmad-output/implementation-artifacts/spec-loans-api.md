---
title: 'Loans API — checkout, return, and member loan listing'
type: 'feature'
created: '2026-05-27'
status: 'done'
baseline_commit: 'NO_VCS'
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The lending-library service manages books and members but has no way to lend a book. There is no record of who holds what, no copy-availability enforcement, and no per-member borrowing limit.

**Approach:** Add a `Loan` entity and a full loan lifecycle across the existing layered stack (model → schema → repository → service → router), wiring three endpoints — `POST /loans` (checkout), `POST /loans/{loan_id}/return`, `GET /members/{member_id}/loans` — while reusing the established error-envelope, pagination, and dependency-injection conventions.

## Boundaries & Constraints

**Always:** Follow the existing layering — routers stay thin and depend on a service via `deps.py`; business logic lives in `LoanService` and raises `AppError` subclasses (never `HTTPException`); the repository stays an in-memory dict keyed by id. Mutate book availability through the live `Book` entity. Reuse `Page`/`paginate` for the list endpoint and the `*Create`/`*Read` schema split. `MAX_ACTIVE_LOANS` comes from `config.py`.

**Ask First:** Any change to existing book/member endpoints, schemas, or seed data beyond what's strictly needed to wire loans in.

**Never:** No new dependencies. No persistence/database backend. No changes to the JSON error-envelope shape. No new loan fields beyond what the lifecycle needs. Do not break existing book/member tests.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Checkout happy path | `POST /loans {book_id, member_id}`, copies available, member under limit | `201`, body `{id>0, book_id, member_id, status:"active", returned_at:null}`; book `available_copies` decremented by 1 | N/A |
| Checkout unknown book | `book_id` not found | `404` | `{"error":{"code":"not_found"...}}` |
| Checkout unknown member | `member_id` not found | `404` | `{"error":{"code":"not_found"...}}` |
| Checkout, no copies | book `available_copies == 0` | `409` | code `no_copies_available` |
| Checkout, at limit | member already holds `MAX_ACTIVE_LOANS` active loans | `409` | code `loan_limit_exceeded` |
| Return happy path | `POST /loans/{id}/return`, loan active | `200`, body `status:"returned"`, `returned_at` set; book `available_copies` incremented by 1 | N/A |
| Return unknown loan | loan id not found | `404` | code `not_found` |
| Double return | loan already returned | `409` | code `already_returned` |
| List member loans | `GET /members/{id}/loans` | `200`, pagination envelope `{items,total,limit,offset}` | N/A |
| List filtered by status | `?status=active` / `?status=returned` | envelope `total` reflects filtered count | invalid status → `422` |

</frozen-after-approval>

## Code Map

- `app/config.py` -- `MAX_ACTIVE_LOANS = 3` already defined; reuse it.
- `app/models.py` -- add `Loan` dataclass + `LoanStatus` str-enum (domain value type).
- `app/schemas.py` -- add `LoanCreate`, `LoanRead` (imports `LoanStatus` from models — no cycle).
- `app/repository.py` -- add `LoanRepository` (add/get/list-for-member with status filter).
- `app/database.py` -- register `loans` repo; `reset_db()` recreates it.
- `app/services.py` -- add `LoanService` composing `BookService` + `MemberService` + `LoanRepository`.
- `app/deps.py` -- add `get_loan_service()` provider.
- `app/routers/loans.py` -- NEW: `POST /loans`, `POST /loans/{loan_id}/return`.
- `app/routers/members.py` -- add `GET /{member_id}/loans` (nested sub-resource).
- `app/main.py` -- include loans router.
- `app/exceptions.py` -- reuse `ConflictError` with custom `code=`; no new exception class needed.

## Tasks & Acceptance

**Execution:**
- [x] `app/models.py` -- add `LoanStatus(str, Enum)` {ACTIVE,RETURNED} and `Loan` dataclass (`id, book_id, member_id, status, checked_out_at, returned_at`) -- domain entity for a lend.
- [x] `app/schemas.py` -- add `LoanCreate {book_id, member_id}` and `LoanRead` (from_attributes) -- wire contract.
- [x] `app/repository.py` -- add `LoanRepository.add/get/list_for_member(member_id, *, status=None)` -- storage following `BookRepository` shape.
- [x] `app/database.py` -- add `self.loans` and reset it in `reset_db()` -- shared instance + test isolation.
- [x] `app/services.py` -- add `LoanService` with `checkout`, `return_loan`, `list_member_loans` -- enforce existence, limit, copies; mutate book availability.
- [x] `app/deps.py` -- add `get_loan_service()` -- DI provider building `LoanService(db.loans, BookService(db.books), MemberService(db.members))`.
- [x] `app/routers/loans.py` -- new router (prefix `/loans`) for checkout + return -- thin HTTP layer.
- [x] `app/routers/members.py` -- add `GET /{member_id}/loans` with status filter + pagination -- nested listing.
- [x] `app/main.py` -- `include_router(loans.router)` -- mount endpoints.

**Acceptance Criteria:**
- Given the full suite, when `pytest` runs, then all of `tests/test_loans.py`, `tests/test_books.py`, and `tests/test_members.py` pass.
- Given a checkout that fails the limit/copies checks, when it is rejected, then the book's `available_copies` is unchanged (no partial mutation).
- Given the validation order, when a member is at the loan limit but the requested book still has copies, then the response is `409 loan_limit_exceeded` (limit checked before copies).

## Design Notes

Validation order in `checkout`: (1) book exists → (2) member exists → (3) member under `MAX_ACTIVE_LOANS` → (4) copies available, then mutate + persist. This makes the limit-vs-copies tie deterministic (limit wins) and ensures no copy is decremented when the loan is rejected.

`LoanStatus` lives in `models.py` so the domain owns its states; `schemas.py` imports it (models has no app imports → no cycle). The `status` query param typed as `LoanStatus | None` gives free `422` on bad values.

Restock on return via `BookService.get_book(loan.book_id)` returning the live entity, then `available_copies += 1`.

## Verification

**Commands:**
- `python -m pytest tests/test_loans.py -q` -- expected: all loan tests pass.
- `python -m pytest -q` -- expected: full suite green (books + members + loans), no regressions.

## Suggested Review Order

**HTTP surface (entry point)**

- Start here: the three endpoints and their status codes — design intent at a glance.
  [`loans.py:9`](../../app/routers/loans.py#L9)

- Nested member sub-resource: status filter + pagination via the shared `Page`/`paginate`.
  [`members.py:44`](../../app/routers/members.py#L44)

**Business logic (the interesting part)**

- Checkout: existence → loan-limit → copies, then decrement; no mutation on rejection.
  [`services.py:73`](../../app/services.py#L73)

- Return: idempotency guard (`already_returned`) then restock the live book entity.
  [`services.py:92`](../../app/services.py#L92)

- List: validates member exists, delegates filtering to the repo.
  [`services.py:104`](../../app/services.py#L104)

**Domain & contract**

- `Loan` entity + `LoanStatus` enum (domain owns its states).
  [`models.py:15`](../../app/models.py#L15)

- `LoanCreate` / `LoanRead` split; `LoanRead` reuses `from_attributes`.
  [`schemas.py:61`](../../app/schemas.py#L61)

- `LoanRepository` mirrors `BookRepository`; `list_for_member` does the status filter.
  [`repository.py:55`](../../app/repository.py#L55)

**Wiring (peripherals)**

- DI provider composes `LoanService` from the loan repo + book/member services.
  [`deps.py:22`](../../app/deps.py#L22)

- Loan repo registered in the datastore + reset for test isolation.
  [`database.py:16`](../../app/database.py#L16)

- Router mounted (books → loans → members).
  [`main.py:29`](../../app/main.py#L29)
