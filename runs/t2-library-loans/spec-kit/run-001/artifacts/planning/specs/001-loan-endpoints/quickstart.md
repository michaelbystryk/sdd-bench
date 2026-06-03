# Quickstart: Library Loan Endpoints

**Feature**: `001-loan-endpoints`

## Prerequisites

- Python ≥ 3.11
- Install the project with dev extras (no new dependencies are added by this feature):

```bash
pip install -e ".[dev]"
```

## Run the test suites

The feature is pinned by `tests/test_loans.py`. Existing book/member suites must stay green.

```bash
# Target suite for this feature
pytest tests/test_loans.py -v

# Full suite — confirms no regressions
pytest -v
```

Expected after implementation: all of `tests/test_loans.py`, `tests/test_books.py`, and `tests/test_members.py` pass.

## Run the service locally

```bash
uvicorn app.main:app --reload
```

Interactive docs at `http://127.0.0.1:8000/docs`. Seed data (`app/seed.py`) provides 5 books and 2 members.

## Manual smoke test

```bash
# Create a book and a member
BOOK=$(curl -s -X POST localhost:8000/books \
  -H 'content-type: application/json' \
  -d '{"title":"Demo","author":"A","genre":"tech","total_copies":1}' | python -c 'import sys,json;print(json.load(sys.stdin)["id"])')
MEMBER=$(curl -s -X POST localhost:8000/members \
  -H 'content-type: application/json' \
  -d '{"name":"Demo","email":"demo@example.com"}' | python -c 'import sys,json;print(json.load(sys.stdin)["id"])')

# Check out  → 201, status "active"
curl -s -X POST localhost:8000/loans \
  -H 'content-type: application/json' \
  -d "{\"book_id\":$BOOK,\"member_id\":$MEMBER}"

# The book now shows available_copies = 0
curl -s localhost:8000/books/$BOOK

# Second checkout of the same single-copy book → 409 no_copies_available
curl -s -X POST localhost:8000/loans \
  -H 'content-type: application/json' \
  -d "{\"book_id\":$BOOK,\"member_id\":$MEMBER}"

# List the member's loans, filter by status
curl -s "localhost:8000/members/$MEMBER/loans?status=active"

# Return loan id 1 → 200, status "returned", restocks the copy
curl -s -X POST localhost:8000/loans/1/return
```

## Verification checklist

- [ ] `POST /loans` returns `201` with `status: "active"` and decrements `available_copies`.
- [ ] Unknown `book_id`/`member_id` → `404` `not_found`.
- [ ] No copies → `409` `no_copies_available`; 4th active loan → `409` `loan_limit_exceeded`.
- [ ] `POST /loans/{id}/return` → `200`, `status: "returned"`, `returned_at` set, copy restocked.
- [ ] Unknown loan → `404` `not_found`; double return → `409` `already_returned`.
- [ ] `GET /members/{id}/loans` returns `{items, total, limit, offset}`; `status` filter narrows `total`.
- [ ] `pytest` — full suite green (loans + books + members).
