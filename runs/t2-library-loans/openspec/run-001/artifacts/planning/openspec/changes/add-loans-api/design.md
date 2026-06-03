## Context

The service is layered routers → services → repositories, with Pydantic `*Create`/`*Read` schemas at the HTTP boundary, dataclass entities in storage, and a shared in-memory `db` reset between tests. Errors surface through the `AppError` envelope (`NotFoundError` → 404, `ConflictError` → 409, with an overridable `code`). `MAX_ACTIVE_LOANS = 3` already lives in `config.py`. Loans are a new entity that must follow these patterns without new dependencies. Behavior is pinned by `tests/test_loans.py`.

## Goals / Non-Goals

**Goals:**
- Implement the three loan endpoints so `tests/test_loans.py` passes and the existing book/member tests stay green.
- Reuse existing layering, the error envelope, the `Page` schema, and `paginate` so loans look native to the codebase.

**Non-Goals:**
- Persistence beyond the in-memory store; due dates, renewals, or fines; member-existence validation on the listing endpoint beyond what tests require.

## Decisions

- **New `Loan` entity + repository, mirroring books/members.** Add a `Loan` dataclass (`id`, `book_id`, `member_id`, `status`, `returned_at`) and a `LoanRepository` with `add`/`get` plus `list_for_member(member_id, status=None)`. Storage is a process-local dict with an incrementing id, exactly like `BookRepository`. Add `db.loans` and reset it in `reset_db()`. *Alternative considered:* storing loans on the member entity — rejected; it breaks the one-repository-per-entity pattern and complicates id assignment.
- **Status as a plain string `"active"`/`"returned"`.** Tests pass `status` as a query string and read it from the response. A bare string matches the wire format with no enum machinery; `LoanRead.status` is typed `str`. *Alternative:* a `StrEnum` — more ceremony than the tests justify.
- **`LoanService` owns all loan rules and depends on the book, member, and loan repositories.** It needs books (read/adjust `available_copies`), members (existence check on checkout), and loans (CRUD). `get_loan_service()` in `deps.py` wires `LoanService(db.books, db.members, db.loans)`. Routers stay thin and never touch repositories — consistent with `deps.py`'s contract.
- **Checkout validation order: book exists → member exists → loan limit → copy availability.** Each failure raises the matching `AppError` before any mutation, so a rejected checkout never changes inventory. The limit uses the count of the member's `active` loans against `MAX_ACTIVE_LOANS`. Conflict codes are set via `ConflictError(message, code="no_copies_available" | "loan_limit_exceeded" | "already_returned")`. The two 409 cases never co-occur in the tests, so the relative order of the limit and availability checks is not observable; the chosen order checks the member-scoped rule before the inventory rule.
- **`returned_at` is a UTC `datetime`, null until return.** Set to `datetime.now(timezone.utc)` on return; `LoanRead.returned_at` is `datetime | None` and serializes to ISO-8601. Tests only assert non-null after return.
- **Route placement: a `/loans` router for checkout and return; the member-scoped listing lives in the members router.** `app/routers/loans.py` (`prefix="/loans"`) owns `POST /loans` and `POST /loans/{loan_id}/return`. `GET /members/{member_id}/loans` is added to `app/routers/members.py` so each router's routes match its URL prefix; that handler depends on `get_loan_service`. Register the loans router in `main.py`. *Alternative:* defining the `/members/...` path inside the loans router — rejected as it mismatches the router prefix convention.
- **Reuse `Page` + `paginate` for the listing.** The listing returns `Page[LoanRead]` built via `paginate`, yielding exactly `{items, total, limit, offset}` with the same `limit`/`offset` query params as other list endpoints.

## Risks / Trade-offs

- **In-memory state shared across the process** → tests reset via `reset_db()`; acceptable for the sample service and unchanged from books/members.
- **`available_copies` could drift if checkout/return logic is asymmetric** → decrement on checkout and increment on return live in one service, guarded so a rejected checkout and a double return never mutate inventory.
- **Status typed as a free string accepts arbitrary `status` filter values** → an unknown filter value simply matches no loans (`total` 0); the tests only exercise `active`/`returned`, so stricter validation is deferred as a non-goal.
