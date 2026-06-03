# Unit Test Execution

## Run Unit Tests

### 1. Execute All Tests
```bash
.venv/bin/python -m pytest -q
```
(`pyproject.toml` sets `pythonpath = ["."]` and `testpaths = ["tests"]`, so pytest
discovers the suite without extra flags.)

To run only the loans feature:
```bash
.venv/bin/python -m pytest tests/test_loans.py -v
```

### 2. Review Test Results
- **Expected**: **21 passed, 0 failed**.
  - `tests/test_loans.py` — 10 tests (the feature spec for this unit)
  - `tests/test_books.py` — 7 tests (existing, must stay green)
  - `tests/test_members.py` — 4 tests (existing, must stay green)
- **Coverage**: no coverage gate is configured. The pinned `test_loans.py` exercises every
  branch of the loan endpoints (success + each error code). Optional measurement:
  `pip install pytest-cov && pytest --cov=app` (adds a dev tool; not part of the project).
- **Test Report Location**: console output (no report files configured).

### 3. Fix Failing Tests
If tests fail:
1. Read the pytest failure output (assertion + traceback).
2. Identify the failing case in `tests/test_loans.py` (each maps to one business rule).
3. Fix the corresponding code in `app/services.py` / `app/routers/` and re-run.
4. Repeat until `21 passed`.

## Test Inventory — `tests/test_loans.py`
| Test | Verifies |
|---|---|
| `test_checkout_creates_active_loan` | 201 + active loan shape |
| `test_checkout_decrements_available_copies` | `available_copies` decremented |
| `test_checkout_unknown_book_returns_not_found` | 404 `not_found` |
| `test_checkout_unknown_member_returns_not_found` | 404 `not_found` |
| `test_checkout_with_no_copies_available_conflicts` | 409 `no_copies_available` |
| `test_checkout_respects_member_loan_limit` | 409 `loan_limit_exceeded` (MAX_ACTIVE_LOANS=3) |
| `test_return_marks_loan_returned_and_restocks` | 200 + returned + restock |
| `test_return_unknown_loan_returns_not_found` | 404 `not_found` |
| `test_double_return_conflicts` | 409 `already_returned` |
| `test_member_loans_lists_with_envelope_and_status_filter` | `Page` envelope + `status` filter |
