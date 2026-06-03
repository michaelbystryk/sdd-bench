# Phase 0 Research: Library Loan Endpoints

**Feature**: `001-loan-endpoints` | **Date**: 2026-05-27

No `NEEDS CLARIFICATION` markers remained after specification — the stack and conventions are fully determined by the existing `app/` codebase and pinned by `tests/test_loans.py`. This document records the design decisions that resolve how the feature fits those conventions.

## Decision 1: Loan as a new entity + repository + service (mirror existing layering)

- **Decision**: Add a `Loan` dataclass (`models.py`), a `LoanRepository` (`repository.py`), a `LoanService` (`services.py`), a provider `get_loan_service()` (`deps.py`), and a new `routers/loans.py`. Wire `db.loans` into `Database` and `reset_db()`.
- **Rationale**: The codebase's documented architecture (`main.py` docstring) is router → service → repository, with the shared `db` instance constructed in `database.py` and exposed through `deps.py`. Loans follow the identical shape, so the change is additive and idiomatic.
- **Alternatives considered**:
  - *Fold loans into BookService/MemberService*: rejected — `services.py` explicitly says "New behavior (e.g. loans) belongs in a service of its own."
  - *Persist loans on the Book/Member entities*: rejected — loans are a first-class many-to-one relationship needing their own identity and status.

## Decision 2: LoanService depends on the loan, book, and member repositories

- **Decision**: `LoanService(loans: LoanRepository, books: BookRepository, members: MemberRepository)`. Checkout/return validate book & member existence directly against their repositories and mutate the stored `Book.available_copies`.
- **Rationale**: The established wiring pattern is *service → repositories* (e.g. `BookService(db.books)`), not service → service. Because repositories return the live in-memory dataclass instances, mutating `book.available_copies` on the fetched object updates stored state directly — matching how the in-memory store already works. The not-found check is a one-liner, so duplicating it (rather than composing `BookService`) keeps the dependency graph consistent with existing services.
- **Alternatives considered**:
  - *Compose `BookService`/`MemberService` inside `LoanService`*: rejected — would deviate from the repositories-only wiring and add no real reuse beyond a one-line `get`-or-raise.

## Decision 3: Loan status as a `str`-backed Enum shared by model and schema

- **Decision**: Define `LoanStatus(str, Enum)` with members `active = "active"` and `returned = "returned"` in `models.py`. Use it for `Loan.status`, `LoanRead.status`, and the `status` query parameter on the list endpoint.
- **Rationale**: A `str` Enum is stdlib (no new dependency), serializes to exactly `"active"`/`"returned"` (matching the asserted wire values), and—when used as the query-param type—makes FastAPI reject unknown filter values with a 422 automatically. It documents the closed vocabulary the spec assumes.
- **Alternatives considered**:
  - *Plain `str` field + `str | None` query param* (as `genre` is modeled): acceptable and minimal, but loses input validation on the filter. The Enum is a small, dependency-free upgrade that better fits "PR-ready code."
  - *`typing.Literal["active","returned"]`*: works for validation but isn't reusable as a single named type across model/schema/service; the Enum centralizes the vocabulary.

## Decision 4: Conflict precedence on checkout

- **Decision**: On `POST /loans`, evaluate in this order: (1) book exists else `404 not_found`; (2) member exists else `404 not_found`; (3) member under `MAX_ACTIVE_LOANS` else `409 loan_limit_exceeded`; (4) book has an available copy else `409 no_copies_available`. Only on passing all four is a copy decremented and the loan created.
- **Rationale**: Existence (404) must precede business conflicts (409). The two pinned conflict tests each trigger exactly one of the 409 conditions, so any precedence passes them; a fixed, documented order makes behavior deterministic for the untested both-true case (member at limit *and* no copies → reports limit first).
- **Alternatives considered**:
  - *Availability before loan limit*: equally valid against the tests; chosen order is arbitrary-but-documented, favoring the member-state check first.

## Decision 5: `returned_at` timestamp

- **Decision**: `Loan.returned_at` is `datetime | None`, `None` while active, set to `datetime.now(timezone.utc)` on return. `LoanRead.returned_at` is `datetime | None` (serializes to an ISO-8601 string, i.e. non-null after return).
- **Rationale**: The pinned test asserts only `returned_at is not None` after a return; a timezone-aware UTC timestamp is the unambiguous, conventional choice and serializes cleanly under Pydantic v2.
- **Alternatives considered**:
  - *Naive `datetime.now()`*: rejected — timezone-aware UTC is safer and equally test-compatible.
  - *Boolean `returned` flag only*: rejected — the response requires a `returned_at` value.

## Decision 6: Hosting the member-scoped list route

- **Decision**: Declare all three endpoints in `routers/loans.py` with `APIRouter(tags=["loans"])` and no `prefix`; the list route uses the full path `/members/{member_id}/loans`. The list validates the member exists (`404 not_found` otherwise) and returns a `Page[LoanRead]` envelope via the shared `paginate()` helper.
- **Rationale**: Keeping all loan logic in one module is cohesive and avoids coupling `routers/members.py` to `LoanService`. A prefix can't cover both `/loans*` and `/members/*` roots, so explicit full paths are used. Validating member existence matches the 404 semantics of the existing `/members/{id}` endpoint and the spec's "unknown references → not found" edge case.
- **Alternatives considered**:
  - *Add the GET to `routers/members.py`*: rejected — couples the members router to the loan service and splits loan code across two files.

## Resolved unknowns

| Question | Resolution |
|----------|------------|
| Loan limit value | Reuse existing `config.MAX_ACTIVE_LOANS` (3) |
| Error codes | `not_found` (404), `no_copies_available` / `loan_limit_exceeded` / `already_returned` (409) via `ConflictError(..., code=...)` |
| Pagination shape | Reuse `Page[ItemT]` + `paginate()`; default limit `DEFAULT_PAGE_LIMIT`, max `MAX_PAGE_LIMIT` |
| Status vocabulary | `active`, `returned` only (`LoanStatus` enum) |
| New dependencies | None — stdlib `datetime`/`enum` + existing FastAPI/Pydantic |
