# Integration Test Instructions

## Purpose
Verify the loans feature works correctly with the existing book/member components
through the full HTTP stack. In this project, the pytest suite already runs as
integration tests: each test drives the real FastAPI app via Starlette's
`TestClient` (an in-process HTTP client), exercising router → service → repository
together. There are no separate microservices, so no external services are started.

## Setup
No external services, containers, or databases are required (storage is in-memory).
The `client` fixture and an autouse `reset_db()` fixture (`tests/conftest.py`) give
each test a freshly seeded datastore for isolation.

## Test Scenarios (cross-component)

### Scenario 1: Loans ↔ Books (copy accounting)
- **Description**: Checkout decrements `available_copies`; return restocks it; a book
  with no available copies rejects checkout with 409 `no_copies_available`.
- **Covered by**: `test_checkout_decrements_available_copies`,
  `test_return_marks_loan_returned_and_restocks`,
  `test_checkout_with_no_copies_available_conflicts`.

### Scenario 2: Loans ↔ Members (existence + loan limit)
- **Description**: Checkout validates member existence and enforces
  `MAX_ACTIVE_LOANS = 3`; listing a member's loans returns the paginated envelope
  and honors the `status` filter.
- **Covered by**: `test_checkout_unknown_member_returns_not_found`,
  `test_checkout_respects_member_loan_limit`,
  `test_member_loans_lists_with_envelope_and_status_filter`.

### Scenario 3: Loan lifecycle integrity
- **Description**: A returned loan cannot be returned again (409 `already_returned`);
  unknown loan/book IDs yield 404 `not_found`.
- **Covered by**: `test_double_return_conflicts`,
  `test_return_unknown_loan_returns_not_found`,
  `test_checkout_unknown_book_returns_not_found`.

## Run Integration Tests
```bash
.venv/bin/python -m pytest -q
```

### Verify Interactions
- **Expected Results**: 21 passed. Book/member endpoints remain unaffected (regression
  coverage from `test_books.py` / `test_members.py`).
- **Logs Location**: console (no centralized logging configured in this sample service).

### Cleanup
None required — state is in-memory and reset per test by the autouse fixture; the
process exits when pytest finishes.

## Manual Smoke Test (optional)
```bash
.venv/bin/uvicorn app.main:app --reload      # then, in another shell:
curl -s -X POST localhost:8000/loans -H 'content-type: application/json' \
     -d '{"book_id":1,"member_id":1}'         # -> 201 active loan
curl -s -X POST localhost:8000/loans/1/return # -> 200 returned loan
curl -s 'localhost:8000/members/1/loans?status=returned'  # -> Page envelope, total=1
```
