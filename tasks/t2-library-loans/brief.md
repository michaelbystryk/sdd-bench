# Library API extension

Here's a small FastAPI lending-library service. It manages books and members.
Add three endpoints:

- `POST /loans` — check out a book for a member.
- `POST /loans/{loan_id}/return` — return a checked-out book.
- `GET /members/{member_id}/loans` — list a member's loans, filterable by status.

The exact behavior is pinned by `tests/test_loans.py` — make those tests pass.
Match the conventions already established in `app/`, keep the existing
book/member tests green, and don't add new dependencies. Produce PR-ready code.
