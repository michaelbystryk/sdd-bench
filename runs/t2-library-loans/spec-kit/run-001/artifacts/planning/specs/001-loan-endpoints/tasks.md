---
description: "Task list for Library Loan Endpoints"
---

# Tasks: Library Loan Endpoints

**Input**: Design documents from `/specs/001-loan-endpoints/`

**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/loans.md ✅

**Tests**: The behavioral test suite `tests/test_loans.py` is **already provided and pinned** — it is the acceptance contract for this feature. No test-authoring tasks are generated; each story instead ends with a task that runs the relevant subset of that suite. Existing `tests/test_books.py` and `tests/test_members.py` must stay green.

**Organization**: Tasks are grouped by user story so each can be implemented and verified independently. Note: the three loan service methods all live in `app/services.py` (one `LoanService` class) and the three endpoints all live in `app/routers/loans.py`, so once the foundation exists the per-story work is largely sequential on those two shared files rather than file-parallel.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies on incomplete tasks)
- **[Story]**: Which user story the task belongs to (US1, US2, US3)
- Exact file paths are included in every task.

## Path Conventions

Single-project Python web service. Application code under `app/`, tests under `tests/` at the repository root (per plan.md).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm the working environment and capture the baseline test state before changes.

- [X] T001 Install dev dependencies and capture baseline by running `pip install -e ".[dev]"` then `pytest -v`; confirm `tests/test_books.py` and `tests/test_members.py` pass and `tests/test_loans.py` fails (endpoints not yet implemented). No new dependencies will be added.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Domain entity, persistence, schemas, and wiring shared by all three stories.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

- [X] T002 Add `LoanStatus(str, Enum)` (`active`, `returned`) and the `Loan` dataclass (`id`, `book_id`, `member_id`, `status: LoanStatus`, `returned_at: datetime | None = None`) to `app/models.py`.
- [X] T003 [P] Add `LoanCreate` (`book_id: int`, `member_id: int`) and `LoanRead` (`model_config = ConfigDict(from_attributes=True)`; fields `id`, `book_id`, `member_id`, `status: LoanStatus`, `returned_at: datetime | None`) to `app/schemas.py`, importing `LoanStatus` from `app/models.py`. (depends on T002)
- [X] T004 [P] Add `LoanRepository` (dict + monotonic `_next_id`; `add`, `get`, and `list(*, member_id=None, status=None)` filtering by member and/or status) to `app/repository.py`, importing `Loan`/`LoanStatus` from `app/models.py`. (depends on T002)
- [X] T005 [P] Wire loans into the datastore in `app/database.py`: add `self.loans = LoanRepository()` in `Database.__init__` and recreate it in `reset_db()`. (depends on T004)
- [X] T006 [P] Add the `LoanService` class with `__init__(self, loans: LoanRepository, books: BookRepository, members: MemberRepository)` (method bodies added per story) to `app/services.py`, importing `Loan`/`LoanStatus`, `LoanCreate`, `NotFoundError`/`ConflictError`, and `MAX_ACTIVE_LOANS`. (depends on T002, T004)
- [X] T007 Add `get_loan_service()` provider returning `LoanService(db.loans, db.books, db.members)` to `app/deps.py`. (depends on T005, T006)
- [X] T008 Create `app/routers/loans.py` with `router = APIRouter(tags=["loans"])` (no prefix; imports `paginate`, `Page`/`LoanCreate`/`LoanRead`, `get_loan_service`, page-limit config, `LoanStatus`) and register it in `app/main.py` via `app.include_router(loans.router)`. (depends on T007)

**Checkpoint**: Foundation ready — `import app.main` succeeds, all three loan routes resolve (returning errors until methods are filled). User stories can now begin.

---

## Phase 3: User Story 1 - Check out a book (Priority: P1) 🎯 MVP

**Goal**: A member can borrow an available book; a loan is created `active` and one copy is reserved, with all checkout guardrails enforced.

**Independent Test**: Run the checkout cases of the pinned suite — `pytest tests/test_loans.py -k checkout -v` — covering happy path, copy decrement, unknown book/member (404), no copies (409), and loan limit (409).

### Implementation for User Story 1

- [X] T009 [US1] Implement `LoanService.checkout(self, data: LoanCreate) -> Loan` in `app/services.py`: resolve book (`NotFoundError("Book … not found")` if missing) → resolve member (`NotFoundError` if missing) → reject if member's active-loan count ≥ `MAX_ACTIVE_LOANS` (`ConflictError(code="loan_limit_exceeded")`) → reject if `book.available_copies <= 0` (`ConflictError(code="no_copies_available")`) → decrement `book.available_copies`, create and store an `active` loan with `returned_at=None`, return it. (depends on T006)
- [X] T010 [US1] Add the `POST /loans` endpoint to `app/routers/loans.py`: `@router.post("/loans", response_model=LoanRead, status_code=201)`, body `LoanCreate`, `service: LoanService = Depends(get_loan_service)`, returns `LoanRead.model_validate(service.checkout(data))`. (depends on T008, T009)
- [X] T011 [US1] Verify the story: `pytest tests/test_loans.py -k checkout -v` — all six checkout tests pass.

**Checkpoint**: Checkout is fully functional and independently testable (MVP).

---

## Phase 4: User Story 2 - Return a checked-out book (Priority: P2)

**Goal**: A member can return an active loan; the loan is marked `returned` with a timestamp and the copy is restocked.

**Independent Test**: `pytest tests/test_loans.py -k return -v` — covering successful return + restock, unknown loan (404), and double-return (409).

### Implementation for User Story 2

- [X] T012 [US2] Implement `LoanService.return_loan(self, loan_id: int) -> Loan` in `app/services.py`: resolve loan (`NotFoundError("Loan … not found")` if missing) → reject if already `returned` (`ConflictError(code="already_returned")`) → set `status = returned` and `returned_at = datetime.now(timezone.utc)`, increment the associated book's `available_copies`, return the loan. (depends on T006)
- [X] T013 [US2] Add the `POST /loans/{loan_id}/return` endpoint to `app/routers/loans.py`: `@router.post("/loans/{loan_id}/return", response_model=LoanRead)` (default `200`), `loan_id: int`, returns `LoanRead.model_validate(service.return_loan(loan_id))`. (depends on T008, T012)
- [X] T014 [US2] Verify the story: `pytest tests/test_loans.py -k return -v` — all three return tests pass.

**Checkpoint**: Checkout and return both work independently.

---

## Phase 5: User Story 3 - List a member's loans (Priority: P3)

**Goal**: List all loans for a member as a paginated envelope, optionally filtered by `status`.

**Independent Test**: `pytest tests/test_loans.py -k member_loans -v` — verifies the `{items, total, limit, offset}` envelope and that `status=active`/`status=returned` narrow the `total`.

### Implementation for User Story 3

- [X] T015 [US3] Implement `LoanService.list_member_loans(self, member_id: int, *, status: LoanStatus | None = None) -> list[Loan]` in `app/services.py`: resolve member (`NotFoundError` if missing), return `self.loans.list(member_id=member_id, status=status)`. (depends on T006)
- [X] T016 [US3] Add the `GET /members/{member_id}/loans` endpoint to `app/routers/loans.py`: `@router.get("/members/{member_id}/loans", response_model=Page[LoanRead])` with `status: LoanStatus | None = None`, `limit = Query(DEFAULT_PAGE_LIMIT, ge=1, le=MAX_PAGE_LIMIT)`, `offset = Query(0, ge=0)`; call the service, `paginate(...)`, and return `Page[LoanRead](items=[LoanRead.model_validate(l) for l in page_items], total=total, limit=limit, offset=offset)`. (depends on T008, T015)
- [X] T017 [US3] Verify the story: `pytest tests/test_loans.py -k member_loans -v` — the listing/filter test passes.

**Checkpoint**: All three user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Confirm the whole feature and guard against regressions.

- [X] T018 Run the full loan suite: `pytest tests/test_loans.py -v` — all 10 tests pass.
- [X] T019 [P] Run the full test suite for regressions: `pytest -v` — `tests/test_books.py` and `tests/test_members.py` remain green alongside loans.
- [X] T020 [P] Walk the manual smoke test in `specs/001-loan-endpoints/quickstart.md` against `uvicorn app.main:app`.
- [X] T021 [P] Confirm no new dependencies were introduced — `pyproject.toml` `dependencies`/`optional-dependencies` are unchanged; only stdlib `datetime`/`enum` and existing FastAPI/Pydantic are used.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately.
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories.
- **User Stories (Phase 3–5)**: All depend on Foundational completion. Independent of one another in behavior, but US1→US2→US3 is the natural order because all three add methods to the same `LoanService` (`app/services.py`) and endpoints to the same `app/routers/loans.py`.
- **Polish (Phase 6)**: Depends on the user stories you intend to ship.

### Within Each User Story

- Service method (in `app/services.py`) before its endpoint (in `app/routers/loans.py`).
- Endpoint before the per-story verification task.

### Parallel Opportunities

- **Foundational**: after T002, run T003 and T004 in parallel (different files); then T005 and T006 in parallel (different files, both depend on T004).
- **Across stories**: limited — the three service methods share `app/services.py` and the three endpoints share `app/routers/loans.py`, so they should not be edited simultaneously. Stories are otherwise behaviorally independent.
- **Polish**: T019, T020, T021 are independent and can run in parallel.

---

## Parallel Example: Foundational Phase

```bash
# After T002 (models) is committed, run in parallel:
Task: "T003 Add LoanCreate/LoanRead schemas in app/schemas.py"
Task: "T004 Add LoanRepository in app/repository.py"

# After T004, run in parallel:
Task: "T005 Wire db.loans in app/database.py"
Task: "T006 Add LoanService class scaffold in app/services.py"
```

---

## Implementation Strategy

### MVP First (User Story 1 only)

1. Phase 1: Setup (baseline test snapshot).
2. Phase 2: Foundational (model, repo, schemas, wiring, router skeleton) — CRITICAL, blocks everything.
3. Phase 3: User Story 1 (checkout).
4. **STOP and VALIDATE**: `pytest tests/test_loans.py -k checkout -v`.

### Incremental Delivery

1. Setup + Foundational → foundation ready.
2. Add US1 (checkout) → verify checkout tests → MVP.
3. Add US2 (return) → verify return tests.
4. Add US3 (list) → verify listing test.
5. Polish → full suite green, no regressions, no new deps.

---

## Notes

- The pinned `tests/test_loans.py` is the source of truth for status codes and error codes; do not edit it.
- `[P]` tasks touch different files with no incomplete dependencies.
- `[Story]` labels (US1/US2/US3) map tasks to spec.md user stories for traceability.
- Reuse existing infrastructure (`AppError`/`ConflictError`, `Page`, `paginate`, `MAX_ACTIVE_LOANS`) — do not add new patterns or dependencies.
- Commit after each task or logical group.
