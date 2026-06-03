# Security Test Instructions

> Included because the **Security Baseline** extension is enabled for this project.
> Scope is limited to what applies to an in-memory, auth-less sample service.

## Applicable Checks

### SECURITY-05 — Input Validation
- **What to test**: malformed/invalid inputs are rejected before processing.
- **How**:
  ```bash
  .venv/bin/uvicorn app.main:app --port 8000
  # invalid status filter -> 422
  curl -s -o /dev/null -w '%{http_code}\n' 'localhost:8000/members/1/loans?status=bogus'
  # missing/!int body fields -> 422
  curl -s -o /dev/null -w '%{http_code}\n' -X POST localhost:8000/loans \
       -H 'content-type: application/json' -d '{"book_id":"x"}'
  ```
- **Expected**: `422` in both cases (Pydantic body validation + `Literal["active","returned"]`
  query constraint). Verified during code generation.

### SECURITY-09 / SECURITY-15 — Safe Errors & Fail-Closed
- **What to test**: error responses never leak stack traces/internal details, and invalid
  states are denied (not silently allowed).
- **How**: trigger each error path (unknown book/member/loan → 404 `not_found`;
  no copies → 409 `no_copies_available`; over limit → 409 `loan_limit_exceeded`;
  double return → 409 `already_returned`).
- **Expected**: each returns the structured `{"error":{"code","message"}}` envelope with a
  generic message and correct status. Covered by `tests/test_loans.py`.

## Dependency / Supply-Chain (SECURITY-10)
- This change adds **no** dependencies. To scan the existing dependency set you may run a
  scanner such as `pip-audit` (not part of the project; would add a dev tool):
  ```bash
  pip install pip-audit && pip-audit
  ```
- Note: the repository does not currently commit a lock file; that is a pre-existing repo
  concern, unchanged by this feature.

## Not Applicable (documented)
The following baseline rules are N/A for this service and require no tests here:
encryption at rest/in transit (no datastore), access logging on network intermediaries
(none), app-level/centralized logging (none configured), HTTP security headers (no HTML),
IAM least-privilege (no cloud IAM), network config (none), application access control /
authn (no auth model), credential management (no credentials), software-integrity /
deserialization (Pydantic-only parsing of trusted JSON), alerting/monitoring infra (none).

See `aidlc-docs/construction/loans/functional-design/functional-design.md` for the full
per-rule compliance table. **No blocking findings.**
