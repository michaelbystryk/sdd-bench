## ADDED Requirements

### Requirement: Check out a book for a member

The system SHALL provide `POST /loans` accepting `{ "book_id", "member_id" }`. On success it MUST create a loan with status `active`, decrement the book's `available_copies` by one, and respond `201` with the loan's `id` (a positive integer), `book_id`, `member_id`, and `status`.

The system MUST reject checkout when the referenced book or member does not exist, when the book has no copies available, or when the member already holds the maximum number of active loans (`MAX_ACTIVE_LOANS`). Rejections MUST use the standard `{"error": {"code", "message"}}` envelope and MUST NOT change `available_copies`.

#### Scenario: Successful checkout creates an active loan

- **WHEN** a client posts a valid `book_id` and `member_id` for a book with copies available
- **THEN** the response is `201` with `status` `"active"`, a positive `id`, and the matching `book_id` and `member_id`

#### Scenario: Checkout decrements available copies

- **WHEN** a book with `total_copies` 2 (and `available_copies` 2) is checked out once
- **THEN** the book's `available_copies` becomes 1 and `total_copies` stays 2

#### Scenario: Unknown book is rejected

- **WHEN** a client posts a `book_id` that does not exist
- **THEN** the response is `404` with error code `not_found`

#### Scenario: Unknown member is rejected

- **WHEN** a client posts a `member_id` that does not exist
- **THEN** the response is `404` with error code `not_found`

#### Scenario: Checkout with no copies available conflicts

- **WHEN** a book's only copy is already on loan and another member tries to check it out
- **THEN** the response is `409` with error code `no_copies_available`

#### Scenario: Member active-loan limit is enforced

- **WHEN** a member already holds `MAX_ACTIVE_LOANS` active loans and attempts another checkout
- **THEN** the response is `409` with error code `loan_limit_exceeded`

### Requirement: Return a checked-out book

The system SHALL provide `POST /loans/{loan_id}/return`. On success it MUST mark the loan `returned`, stamp a non-null `returned_at`, increment the book's `available_copies` by one, and respond `200` with the updated loan.

The system MUST respond `404` (`not_found`) when the loan does not exist, and MUST respond `409` (`already_returned`) when the loan has already been returned, without further changing inventory.

#### Scenario: Return marks the loan returned and restocks the book

- **WHEN** an active loan for a single-copy book is returned
- **THEN** the response is `200` with `status` `"returned"` and a non-null `returned_at`, and the book's `available_copies` returns to 1

#### Scenario: Returning an unknown loan is rejected

- **WHEN** a client returns a `loan_id` that does not exist
- **THEN** the response is `404` with error code `not_found`

#### Scenario: Double return conflicts

- **WHEN** a loan that has already been returned is returned again
- **THEN** the response is `409` with error code `already_returned`

### Requirement: List a member's loans

The system SHALL provide `GET /members/{member_id}/loans` returning the standard pagination envelope with exactly the keys `items`, `total`, `limit`, and `offset`. The endpoint MUST accept an optional `status` query parameter that, when provided, restricts results to loans with that status (`active` or `returned`).

#### Scenario: List returns the pagination envelope with all loans

- **WHEN** a member has two loans and a client requests their loans without a filter
- **THEN** the response is `200` with keys exactly `{items, total, limit, offset}` and `total` equal to 2

#### Scenario: Filter by active status

- **WHEN** a member has one active and one returned loan and a client requests `status=active`
- **THEN** `total` is 1

#### Scenario: Filter by returned status

- **WHEN** a member has one active and one returned loan and a client requests `status=returned`
- **THEN** `total` is 1
