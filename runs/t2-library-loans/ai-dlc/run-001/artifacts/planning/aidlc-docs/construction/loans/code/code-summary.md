# Code Summary — Unit: `loans`

> Documentation only. All application code lives under the workspace root (`app/`).

## Files Created
- `app/routers/loans.py` — loans router: `POST /loans` (201, checkout) and `POST /loans/{loan_id}/return` (200, return).

## Files Modified
- `app/models.py` — added `LoanStatus = Literal["active","returned"]` and the `Loan` dataclass (`id, book_id, member_id, status, created_at, returned_at`).
- `app/schemas.py` — added `LoanCreate` (request) and `LoanRead` (response, `from_attributes=True`).
- `app/repository.py` — added `LoanRepository` (`add`, `get`, `list(*, member_id, status)`).
- `app/services.py` — added `LoanService` (`checkout`, `return_loan`, `list_member_loans`) enforcing the 5 business rules; raises `AppError` subclasses only.
- `app/database.py` — added `Database.loans` and reset it in `reset_db()`.
- `app/deps.py` — added `get_loan_service()`.
- `app/routers/members.py` — added `GET /members/{member_id}/loans` (`Page[LoanRead]`, optional `status` filter, OpenAPI tag `loans`).
- `app/main.py` — registered the loans router.

## Endpoints
| Method | Path | Success | Error codes |
|---|---|---|---|
| POST | `/loans` | 201 `LoanRead` | 404 `not_found` (book/member), 409 `no_copies_available`, 409 `loan_limit_exceeded` |
| POST | `/loans/{loan_id}/return` | 200 `LoanRead` | 404 `not_found`, 409 `already_returned` |
| GET | `/members/{member_id}/loans` | 200 `Page[LoanRead]` | 404 `not_found` (member), 422 (invalid `status`) |

## Conventions Followed
- Layered routers → services → repository → models/schemas.
- `AppError` envelope for all client-facing errors (no `HTTPException` raised directly).
- Shared `Page[T]` + `paginate(...)` for the listing; `*Create`/`*Read` schema split.
- In-memory `dict`-backed repository with `_next_id`, reset via `reset_db()`.
- No new dependencies (stdlib `datetime` + existing FastAPI/Pydantic).

## Verification
- `pytest`: **21 passed** (10 new loan tests + 11 existing book/member tests).
- Byte-compiles cleanly; `pyproject.toml` dependencies unchanged.
- Spot-checks: invalid `status` → 422; unknown member → 404 `not_found`.

## Security Compliance (Baseline extension)
See `../functional-design/functional-design.md` → "Security Compliance". No blocking findings; applicable rules (SECURITY-05/09/15) compliant, remainder N/A for this in-memory, auth-less sample service.
