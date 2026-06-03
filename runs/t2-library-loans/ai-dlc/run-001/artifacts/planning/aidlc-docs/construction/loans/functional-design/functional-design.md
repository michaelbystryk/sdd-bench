# Functional Design — Unit: `loans`

## Domain Entity: `Loan`
| Field | Type | Notes |
|---|---|---|
| `id` | `int` | Assigned by the repository (like `Book`/`Member`). |
| `book_id` | `int` | The borrowed book. |
| `member_id` | `int` | The borrowing member. |
| `status` | `LoanStatus` = `Literal["active", "returned"]` | Lifecycle state. |
| `created_at` | `datetime` | Checkout time (UTC). |
| `returned_at` | `datetime \| None` | Set when returned; `None` while active. |

## Status Lifecycle
```
checkout                 return
  --> [active] -------------------> [returned]   (terminal)
                  double return --> 409 already_returned
```

## Business Rules

### Checkout (`POST /loans`)
Evaluated in this order so the error codes match the pinned tests:
1. Book must exist          → else `NotFoundError` (404 `not_found`).
2. Member must exist        → else `NotFoundError` (404 `not_found`).
3. Member's active-loan count `< MAX_ACTIVE_LOANS` (3) → else `ConflictError(code="loan_limit_exceeded")` (409).
4. Book `available_copies > 0` → else `ConflictError(code="no_copies_available")` (409).
5. On success: decrement `book.available_copies` by 1, create an `active` loan with `created_at = now(UTC)`, persist, return it.

### Return (`POST /loans/{loan_id}/return`)
1. Loan must exist → else `NotFoundError` (404 `not_found`).
2. Loan must be `active` → else `ConflictError(code="already_returned")` (409).
3. On success: set `status = "returned"`, `returned_at = now(UTC)`, increment the book's `available_copies` by 1, return the loan.

### List member loans (`GET /members/{member_id}/loans`)
1. Member must exist → else `NotFoundError` (404 `not_found`).
2. Collect the member's loans, optionally filtered by `status` (`active` / `returned`).
3. Return the standard `Page[LoanRead]` envelope via `paginate(...)`; `total` is the filtered count.

## Component Shape (mirrors existing layers)
- **`models.Loan`** — dataclass entity + `LoanStatus` type alias.
- **`repository.LoanRepository`** — `add` / `get` / `list(*, member_id=None, status=None)`, in-memory `dict[int, Loan]` + `_next_id`.
- **`services.LoanService`** — holds `loans`, `books`, `members` repositories; methods `checkout`, `return_loan`, `list_member_loans`. Raises `AppError` subclasses only.
- **`schemas.LoanCreate`** (request: `book_id`, `member_id`) and **`schemas.LoanRead`** (response, `from_attributes=True`).
- **`routers/loans.py`** — `POST /loans`, `POST /loans/{loan_id}/return`.
- **`routers/members.py`** — adds `GET /members/{member_id}/loans` (member sub-resource; OpenAPI tag `loans`).
- **Wiring** — `database.Database.loans`, `reset_db()`, `deps.get_loan_service`, `main.create_app` include.

## Security Compliance (Baseline extension — ENABLED)
| Rule | Status | Rationale |
|---|---|---|
| SECURITY-05 Input validation | Compliant | `LoanCreate` (typed body) + `status` query param constrained to `active`/`returned` (422 otherwise). Integer path/body params type-checked by FastAPI. |
| SECURITY-09 Misconfiguration / safe errors | Compliant | Errors via `AppError` envelope — generic messages, no stack traces or internals. |
| SECURITY-15 Exception handling / fail-closed | Compliant | Invalid states (no copies, over limit, double return, missing entities) fail closed with explicit `AppError`; global handler already registered. |
| SECURITY-11 Secure design (rate limiting) | N/A | In-memory sample service with no gateway/throttle layer; adding one is out of scope and absent from the existing app. Separation of concerns is honored (logic isolated in `LoanService`). |
| SECURITY-03 App logging | N/A | Existing sample app configures no logging framework; adding centralized logging is out of scope and not introduced by this change. |
| SECURITY-08 App access control / authz | N/A | The service has no authentication/principal model; all endpoints are unauthenticated by existing design. No IDOR surface beyond the pre-existing pattern. Out of scope for this feature. |
| SECURITY-10 Supply chain | N/A | This change adds **no** dependencies; build/lockfile policy is a pre-existing repo concern, unchanged here. |
| SECURITY-01,02,04,06,07,12,13,14 | N/A | No data store/encryption, network intermediaries, HTML responses, IAM, network config, user auth/credentials, untrusted deserialization, or monitoring infra in this in-memory service. |

**Blocking findings: none.**
