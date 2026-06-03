# API Contract: Loan Endpoints

**Feature**: `001-loan-endpoints` | **Date**: 2026-05-27

All errors use the shared envelope rendered by `app/errors.py`:

```json
{ "error": { "code": "<code>", "message": "<human-readable>" } }
```

Validation errors on malformed request bodies / query params use FastAPI's default `422` (unchanged from the rest of the service).

---

## 1. `POST /loans` — check out a book

**Request body** (`LoanCreate`):

```json
{ "book_id": 1, "member_id": 1 }
```

**Success — `201 Created`** (`LoanRead`):

```json
{
  "id": 1,
  "book_id": 1,
  "member_id": 1,
  "status": "active",
  "returned_at": null
}
```

Side effect: the referenced book's `available_copies` decreases by 1 (`total_copies` unchanged).

**Errors**:

| Status | `error.code`           | Condition |
|--------|------------------------|-----------|
| 404    | `not_found`            | `book_id` does not exist |
| 404    | `not_found`            | `member_id` does not exist |
| 409    | `loan_limit_exceeded`  | Member already holds `MAX_ACTIVE_LOANS` (3) active loans |
| 409    | `no_copies_available`  | Book has `available_copies == 0` |

Evaluation order: book existence → member existence → loan limit → copy availability.

---

## 2. `POST /loans/{loan_id}/return` — return a checked-out book

**Path param**: `loan_id` (int). No request body.

**Success — `200 OK`** (`LoanRead`):

```json
{
  "id": 1,
  "book_id": 1,
  "member_id": 1,
  "status": "returned",
  "returned_at": "2026-05-27T12:00:00Z"
}
```

Side effect: the loan's book's `available_copies` increases by 1.

**Errors**:

| Status | `error.code`        | Condition |
|--------|---------------------|-----------|
| 404    | `not_found`         | `loan_id` does not exist |
| 409    | `already_returned`  | Loan is already in `returned` status |

---

## 3. `GET /members/{member_id}/loans` — list a member's loans

**Path param**: `member_id` (int).

**Query params**:

| Name     | Type                          | Default              | Notes |
|----------|-------------------------------|----------------------|-------|
| `status` | `active` \| `returned`        | (none — all loans)   | Invalid value → `422` |
| `limit`  | int, `1..MAX_PAGE_LIMIT` (100)| `DEFAULT_PAGE_LIMIT` (20) | Shared pagination |
| `offset` | int, `>= 0`                   | `0`                  | Shared pagination |

**Success — `200 OK`** (`Page[LoanRead]`):

```json
{
  "items": [
    { "id": 1, "book_id": 1, "member_id": 1, "status": "returned", "returned_at": "2026-05-27T12:00:00Z" },
    { "id": 2, "book_id": 2, "member_id": 1, "status": "active",   "returned_at": null }
  ],
  "total": 2,
  "limit": 20,
  "offset": 0
}
```

`total` reflects the count after the `status` filter is applied. Response keys are exactly `{items, total, limit, offset}`.

**Errors**:

| Status | `error.code` | Condition |
|--------|--------------|-----------|
| 404    | `not_found`  | `member_id` does not exist |

---

## Traceability to pinned tests (`tests/test_loans.py`)

| Test | Endpoint | Asserts |
|------|----------|---------|
| `test_checkout_creates_active_loan` | POST /loans | 201; `status=active`, `id>0`, echoes ids |
| `test_checkout_decrements_available_copies` | POST /loans | `available_copies` 2→1, `total_copies` stays 2 |
| `test_checkout_unknown_book_returns_not_found` | POST /loans | 404 `not_found` |
| `test_checkout_unknown_member_returns_not_found` | POST /loans | 404 `not_found` |
| `test_checkout_with_no_copies_available_conflicts` | POST /loans | 409 `no_copies_available` |
| `test_checkout_respects_member_loan_limit` | POST /loans | 4th active → 409 `loan_limit_exceeded` |
| `test_return_marks_loan_returned_and_restocks` | POST /loans/{id}/return | 200; `status=returned`, `returned_at` set; restock |
| `test_return_unknown_loan_returns_not_found` | POST /loans/{id}/return | 404 `not_found` |
| `test_double_return_conflicts` | POST /loans/{id}/return | 409 `already_returned` |
| `test_member_loans_lists_with_envelope_and_status_filter` | GET /members/{id}/loans | envelope keys, `total`, `status` filter counts |
