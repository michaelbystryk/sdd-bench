## 1. Domain layer

- [x] 1.1 Add a `Loan` dataclass to `app/models.py` with `id`, `book_id`, `member_id`, `status`, and `returned_at: datetime | None`
- [x] 1.2 Add `LoanCreate` (`book_id`, `member_id`) and `LoanRead` (`id`, `book_id`, `member_id`, `status`, `returned_at`) schemas to `app/schemas.py`, with `LoanRead` using `from_attributes`

## 2. Storage layer

- [x] 2.1 Add `LoanRepository` to `app/repository.py` with `add`, `get`, and `list_for_member(member_id, status=None)`, following the in-memory dict + incrementing id pattern
- [x] 2.2 Add `self.loans = LoanRepository()` to `Database` and reset it in `reset_db()` in `app/database.py`

## 3. Business logic

- [x] 3.1 Add `LoanService(books, members, loans)` to `app/services.py`
- [x] 3.2 Implement `checkout(book_id, member_id)`: verify book exists (`NotFoundError`), verify member exists (`NotFoundError`), reject when active loans reach `MAX_ACTIVE_LOANS` (`ConflictError` code `loan_limit_exceeded`), reject when no copies available (`ConflictError` code `no_copies_available`), then decrement `available_copies` and create an `active` loan
- [x] 3.3 Implement `return_loan(loan_id)`: verify loan exists (`NotFoundError`), reject if already returned (`ConflictError` code `already_returned`), set status `returned` and `returned_at` to now (UTC), increment the book's `available_copies`
- [x] 3.4 Implement `list_member_loans(member_id, status=None)` delegating to the repository

## 4. Wiring & routes

- [x] 4.1 Add `get_loan_service()` to `app/deps.py` returning `LoanService(db.books, db.members, db.loans)`
- [x] 4.2 Create `app/routers/loans.py` with `prefix="/loans"`, `tags=["loans"]`: `POST ""` (201 → `LoanRead`) and `POST "/{loan_id}/return"` (200 → `LoanRead`)
- [x] 4.3 Add `GET /members/{member_id}/loans` to `app/routers/members.py` returning `Page[LoanRead]` via `paginate`, with optional `status` query param and standard `limit`/`offset`
- [x] 4.4 Register the loans router in `app/main.py`
- [x] 4.5 Add `app.routers` already covers the new module; confirm `pyproject.toml` packages need no change

## 5. Verification

- [x] 5.1 Run `pytest tests/test_loans.py` and confirm all loan tests pass
- [x] 5.2 Run the full suite and confirm `test_books.py` and `test_members.py` stay green, with no new dependencies added
