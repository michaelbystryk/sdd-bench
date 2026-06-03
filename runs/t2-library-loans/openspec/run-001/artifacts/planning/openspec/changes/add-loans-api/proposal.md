## Why

The library service manages books and members but has no way to record that a member has borrowed a book. Without a loan workflow, inventory (`available_copies`) never moves and members cannot be held to borrowing limits. Adding loans turns the service into an actual lending library.

## What Changes

- Add `POST /loans` to check out a book for a member: validates the book and member exist, enforces the per-member active-loan limit and copy availability, decrements the book's `available_copies`, and creates an `active` loan.
- Add `POST /loans/{loan_id}/return` to return a checked-out book: marks the loan `returned` (stamping `returned_at`), restocks the book's `available_copies`, and rejects a second return.
- Add `GET /members/{member_id}/loans` to list a member's loans using the standard pagination envelope, with an optional `status` filter (`active` / `returned`).
- Introduce a `Loan` entity, `LoanCreate`/`LoanRead` schemas, a `LoanRepository`, and a `LoanService`, wired through `deps.py` and registered in `main.py` — following the existing routers → services → repository layering. No new dependencies.

## Capabilities

### New Capabilities
- `loans`: Checking out a book to a member, returning it, and listing a member's loans — including inventory and borrowing-limit rules.

### Modified Capabilities
<!-- No existing specs; book/member behavior is unchanged. -->

## Impact

- **New code**: `app/routers/loans.py`, plus additions to `app/models.py`, `app/schemas.py`, `app/repository.py`, `app/services.py`, `app/deps.py`, `app/database.py`, `app/routers/members.py` (the member-scoped listing), and `app/main.py` (router registration).
- **Reused**: `MAX_ACTIVE_LOANS` from `config.py`, the `AppError` envelope (`NotFoundError`, `ConflictError`), the `Page` schema, and the `paginate` helper.
- **APIs**: three new endpoints; existing book/member endpoints unchanged.
- **Dependencies**: none added. Storage remains in-memory.
- **Tests**: `tests/test_loans.py` must pass; existing `test_books.py` / `test_members.py` must stay green.
