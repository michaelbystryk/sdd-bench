# Feature Specification: Library Loan Endpoints

**Feature Branch**: `001-loan-endpoints`

**Created**: 2026-05-27

**Status**: Draft

**Input**: User description: "Add three endpoints to the lending-library service: POST /loans (check out a book for a member), POST /loans/{loan_id}/return (return a checked-out book), and GET /members/{member_id}/loans (list a member's loans, filterable by status). Behavior is pinned by tests/test_loans.py; match existing app/ conventions, keep book/member tests green, add no new dependencies."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Check out a book (Priority: P1)

A library member borrows an available book. The service records the loan, marks it active, and reserves one copy so it can no longer be lent to someone else until returned.

**Why this priority**: Checkout is the core action of a lending library. Without it, returns and loan listings have nothing to operate on. It is the minimum viable slice that delivers value on its own.

**Independent Test**: Create a book and a member, then check the book out. Verify a loan is created with `active` status and that the book's available copy count drops by one.

**Acceptance Scenarios**:

1. **Given** a book with available copies and an existing member, **When** the member checks out the book, **Then** a new loan is created with status `active`, a positive identifier, and the requested book and member, and the response reports successful creation.
2. **Given** a checkout just succeeded, **When** the book is inspected, **Then** its available-copy count has decreased by one while its total-copy count is unchanged.
3. **Given** a checkout request referencing a book that does not exist, **When** the checkout is attempted, **Then** the request is rejected as not found.
4. **Given** a checkout request referencing a member that does not exist, **When** the checkout is attempted, **Then** the request is rejected as not found.
5. **Given** a book whose available copies are all currently lent out, **When** another member tries to check it out, **Then** the request is rejected with a conflict indicating no copies are available.
6. **Given** a member who already holds the maximum number of simultaneous active loans, **When** they attempt one more checkout, **Then** the request is rejected with a conflict indicating the loan limit is exceeded.

---

### User Story 2 - Return a checked-out book (Priority: P2)

A member returns a book they previously borrowed. The service closes the loan and returns the copy to the available pool so it can be lent again.

**Why this priority**: Returns complete the lending lifecycle and free up inventory. They depend on checkout (P1) having created loans, so they come second.

**Independent Test**: Check out a book, then return that loan. Verify the loan becomes `returned` with a return timestamp and the book's available copy count is restored.

**Acceptance Scenarios**:

1. **Given** an active loan, **When** it is returned, **Then** the loan's status becomes `returned`, a return timestamp is recorded, and the book's available-copy count is restored by one; the response reports success.
2. **Given** a return request for a loan that does not exist, **When** the return is attempted, **Then** the request is rejected as not found.
3. **Given** a loan that has already been returned, **When** a return is attempted again, **Then** the request is rejected with a conflict indicating the loan was already returned.

---

### User Story 3 - List a member's loans (Priority: P3)

A member (or librarian acting for them) reviews the loans associated with that member, optionally narrowing to only active or only returned loans.

**Why this priority**: Listing is a read-only convenience that improves visibility but is not required to operate the lending cycle, so it is lowest priority.

**Independent Test**: Create loans for a member in different states, then list that member's loans with and without a status filter. Verify the totals reflect the filter.

**Acceptance Scenarios**:

1. **Given** a member with multiple loans in differing states, **When** their loans are listed without a filter, **Then** the response is a paginated collection reporting every loan for that member.
2. **Given** the same member, **When** their loans are listed filtered to `active`, **Then** only active loans are counted and returned.
3. **Given** the same member, **When** their loans are listed filtered to `returned`, **Then** only returned loans are counted and returned.

---

### Edge Cases

- **Last copy contention**: A book with one copy can be checked out only once at a time; the second concurrent checkout is rejected as a conflict, not a generic error.
- **Loan limit boundary**: A member may hold up to the configured maximum active loans (currently 3); the limit applies to active loans only, so returning a loan frees capacity for a new checkout.
- **Returning frees capacity and stock**: After a return, both the affected book's available copies and the member's active-loan headroom are restored.
- **Re-returning**: Returning an already-returned loan is a conflict, distinct from returning a non-existent loan (which is not found).
- **Unknown references**: Checkout against an unknown book or unknown member, and return/listing against unknown identifiers, are surfaced as not-found rather than treated as empty results.
- **Empty listing**: Listing loans for a member with no loans (matching the filter) returns an empty but well-formed paginated collection.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST let a caller check out a book for a member by referencing an existing book and member, creating a loan recorded as `active`.
- **FR-002**: On a successful checkout, system MUST decrement the book's available-copy count by one while leaving the total-copy count unchanged.
- **FR-003**: System MUST reject a checkout that references a non-existent book or non-existent member as not found.
- **FR-004**: System MUST reject a checkout when the target book has no available copies, signaling a conflict that specifically identifies the cause as no copies available.
- **FR-005**: System MUST reject a checkout that would cause a member to exceed the configured maximum number of simultaneous active loans, signaling a conflict that specifically identifies the cause as the loan limit being exceeded.
- **FR-006**: System MUST let a caller return a specific loan, marking it `returned` and recording the moment it was returned.
- **FR-007**: On a successful return, system MUST restore the associated book's available-copy count by one.
- **FR-008**: System MUST reject a return for a non-existent loan as not found.
- **FR-009**: System MUST reject a return for a loan that has already been returned, signaling a conflict that specifically identifies the cause as already returned.
- **FR-010**: System MUST let a caller list all loans belonging to a given member as a paginated collection.
- **FR-011**: System MUST allow the member-loan listing to be filtered by loan status (`active` or `returned`), with the reported total reflecting only the matching loans.
- **FR-012**: System MUST express loan errors using the same machine-readable error structure and the same not-found / conflict semantics already used by the book and member endpoints, with distinct codes per failure cause (no copies available, loan limit exceeded, already returned, not found).
- **FR-013**: System MUST return the member-loan listing using the same paginated response shape already used elsewhere in the service (a collection plus total, limit, and offset).
- **FR-014**: The loan capabilities MUST be added without introducing new third-party dependencies and without regressing existing book and member behavior.

### Key Entities *(include if feature involves data)*

- **Loan**: A record that a specific member has borrowed a specific book. Key attributes: a unique identifier, the borrowed book, the borrowing member, a status (`active` or `returned`), and the time it was returned (absent while active). A loan links exactly one member to exactly one book copy.
- **Book** (existing): Lendable title tracked with a total number of copies and a count of currently available copies; checkout and return adjust the available count.
- **Member** (existing): A person who may hold loans, subject to a cap on the number of simultaneously active loans.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the loan behaviors pinned by the acceptance scenarios are satisfied (every case in the dedicated loan test suite passes).
- **SC-002**: Existing book and member behaviors remain fully intact (the existing book and member test suites continue to pass with zero regressions).
- **SC-003**: A member can borrow an available book and have the reservation reflected in inventory in a single request, with no manual reconciliation needed.
- **SC-004**: Every loan failure (unknown book/member/loan, no copies, loan limit, double return) is reported with a distinct, machine-readable cause that a client can branch on without parsing free text.
- **SC-005**: The feature ships with no new third-party dependencies added to the project.

## Assumptions

- **Pinned behavior is authoritative**: Where the feature description and the loan test suite (`tests/test_loans.py`) overlap, the tests define the exact expected behavior (status codes, error codes, response shapes).
- **Maximum active loans**: The simultaneous active-loan cap per member is the existing configured value (currently 3) rather than a new, separately specified limit.
- **Status vocabulary**: Loans have exactly two statuses, `active` and `returned`; no reserved/overdue/cancelled states are in scope.
- **Filter scope**: The member-loan listing filters only by status; the only supported filter values are `active` and `returned`.
- **Convention reuse**: Loan endpoints reuse the project's established conventions for routing, error envelope, pagination, persistence, and validation rather than introducing new patterns.
- **No due dates / fines**: Due dates, overdue handling, and fines are out of scope for this feature; a return simply closes the loan and restocks the copy.
- **Authorization**: Access control for loan operations is out of scope and assumed to follow whatever the existing endpoints already do (none beyond what books/members require).
