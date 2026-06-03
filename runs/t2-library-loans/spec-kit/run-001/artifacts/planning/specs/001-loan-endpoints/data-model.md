# Phase 1 Data Model: Library Loan Endpoints

**Feature**: `001-loan-endpoints` | **Date**: 2026-05-27

## New entity: `Loan`

Internal domain entity (dataclass in `app/models.py`), distinct from the API schemas. Stored in `LoanRepository` keyed by integer `id`.

| Field         | Type                  | Notes |
|---------------|-----------------------|-------|
| `id`          | `int`                 | Assigned by the repository on `add` (starts at 1, monotonic). `0` before insertion. |
| `book_id`     | `int`                 | References an existing `Book.id`. |
| `member_id`   | `int`                 | References an existing `Member.id`. |
| `status`      | `LoanStatus`          | `active` on creation; `returned` after return. |
| `returned_at` | `datetime \| None`    | `None` while active; UTC timestamp set on return. |

### Enum: `LoanStatus(str, Enum)`

| Member     | Value        |
|------------|--------------|
| `active`   | `"active"`   |
| `returned` | `"returned"` |

A `str`-backed enum so it serializes to the bare string on the wire and validates the list endpoint's `status` filter. Defined in `app/models.py`; imported by `schemas.py`, `services.py`, and `routers/loans.py`.

## Relationships

- `Loan.book_id` → `Book` (many loans to one book). Checkout/return adjust that book's `available_copies`.
- `Loan.member_id` → `Member` (many loans to one member). A member holds at most `MAX_ACTIVE_LOANS` (3) loans with `status == active` at once.

## State transitions

```text
            checkout (POST /loans)
   (none) ──────────────────────────▶ active
                                         │
                                         │ return (POST /loans/{id}/return)
                                         ▼
                                     returned   ── return again ──▶ 409 already_returned (no transition)
```

- **→ active**: created by checkout. Preconditions: book exists, member exists, member has `< MAX_ACTIVE_LOANS` active loans, book `available_copies > 0`. Effect: `available_copies -= 1`.
- **active → returned**: by return. Effect: `status = returned`, `returned_at = now(UTC)`, book `available_copies += 1`.
- **returned → (terminal)**: a second return raises `ConflictError(code="already_returned")`; no state change.

## Validation & invariants

- A loan's `status` is always one of `LoanStatus`. `returned_at` is non-null iff `status == returned`.
- `available_copies` never drops below 0 (the `no_copies_available` guard) and never exceeds `total_copies` under normal checkout/return flow (each return matches a prior checkout decrement).
- Active-loan count per member = `len(LoanRepository.list(member_id=m, status=active))`, enforced `< MAX_ACTIVE_LOANS` before a new checkout.

## API schemas (`app/schemas.py`)

### `LoanCreate` (request body for `POST /loans`)

| Field       | Type  | Constraints |
|-------------|-------|-------------|
| `book_id`   | `int` | required |
| `member_id` | `int` | required |

### `LoanRead` (response model for all three endpoints)

`model_config = ConfigDict(from_attributes=True)` — built from the `Loan` dataclass.

| Field         | Type               |
|---------------|--------------------|
| `id`          | `int`              |
| `book_id`     | `int`              |
| `member_id`   | `int`              |
| `status`      | `LoanStatus`       |
| `returned_at` | `datetime \| None` |

### Pagination

The list endpoint returns the existing generic `Page[LoanRead]` envelope: `{ items, total, limit, offset }` — no new schema needed.

## Repository: `LoanRepository` (`app/repository.py`)

Mirrors `BookRepository`/`MemberRepository` (dict + monotonic `_next_id`).

| Method | Signature | Behavior |
|--------|-----------|----------|
| `add`  | `add(loan: Loan) -> Loan` | Assigns `id`, stores, increments `_next_id`. |
| `get`  | `get(loan_id: int) -> Loan \| None` | Lookup by id. |
| `list` | `list(*, member_id: int \| None = None, status: LoanStatus \| None = None) -> list[Loan]` | Returns all loans, optionally filtered by member and/or status. |

Wired into `Database.__init__` and `reset_db()` as `self.loans = LoanRepository()`.
