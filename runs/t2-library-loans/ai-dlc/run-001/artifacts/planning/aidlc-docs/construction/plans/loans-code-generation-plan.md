# Code Generation Plan — Unit: `loans`

Single source of truth for generating the loans feature. Brownfield: modify
existing files in place; create only the genuinely new file (`app/routers/loans.py`).
All paths are under the workspace root (never `aidlc-docs/`).

## Steps

- [x] **Step 1 — Domain entity** (`app/models.py`, modify)
  Add `LoanStatus = Literal["active", "returned"]` and a `Loan` dataclass
  (`id, book_id, member_id, status, created_at, returned_at`).

- [x] **Step 2 — Schemas** (`app/schemas.py`, modify)
  Add `LoanCreate` (`book_id`, `member_id`) and `LoanRead`
  (`from_attributes=True`; `id, book_id, member_id, status, created_at, returned_at`).

- [x] **Step 3 — Repository** (`app/repository.py`, modify)
  Add `LoanRepository` with `add`, `get`, `list(*, member_id=None, status=None)`,
  mirroring `BookRepository`/`MemberRepository`.

- [x] **Step 4 — Service** (`app/services.py`, modify)
  Add `LoanService(loans, books, members)` with `checkout`, `return_loan`,
  `list_member_loans`, enforcing the 5 business rules from functional-design.md.

- [x] **Step 5 — Wiring** (`app/database.py`, `app/deps.py`, modify)
  Add `Database.loans` (+ reset in `reset_db`) and `get_loan_service()`.

- [x] **Step 6 — Loans router** (`app/routers/loans.py`, create)
  `POST /loans` (201) and `POST /loans/{loan_id}/return` (200).

- [x] **Step 7 — Member loans listing** (`app/routers/members.py`, modify)
  Add `GET /members/{member_id}/loans` returning `Page[LoanRead]`, optional
  `status` filter, OpenAPI tag `loans`.

- [x] **Step 8 — App registration** (`app/main.py`, modify)
  Include the loans router.

- [x] **Step 9 — Tests** (`tests/test_loans.py` already present as the spec)
  Run the full suite; confirm 10 loan tests pass and book/member tests stay green.

- [x] **Step 10 — Docs** (`aidlc-docs/construction/loans/code/` summary)
  Write a code summary; no source duplication.

## Story / Requirement Traceability
- FR-1 (checkout) → Steps 1–6
- FR-2 (return) → Steps 1–6
- FR-3 (list member loans) → Steps 1–5, 7

## Notes
- No new dependencies (stdlib `datetime` + existing FastAPI/Pydantic only).
- Brownfield rule: edit files in place; no `*_new`/`*_modified` copies.
