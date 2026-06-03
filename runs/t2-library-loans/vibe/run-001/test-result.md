# T2-vibe / Run 001 / Test Result

Objective scorer = the pre-written pytest suite, run in the cell dir after the
methodology declared done (isolated scoring venv, not the cell's own env):

```
cd ~/dev/sdd-bench-t2-builds/vibe
uv venv .venv-score && uv pip install --python .venv-score/bin/python -e ".[dev]"
.venv-score/bin/python -m pytest -q
```

Base state at lock: **11 passing** (books 7 + members 4), **10 failing** (loan suite).

## Binary outcomes (per success-criteria.md)

| Outcome | Pass condition | Result |
|---|---|---|
| Existing tests still pass | test_books.py (7) + test_members.py (4) = 11; zero regressions | **11/11** ✓ |
| Loan tests pass | all 10 in test_loans.py | **10/10** ✓ |
| No new dependencies | no additions to pyproject.toml dependencies | **yes** ✓ |
| Convention-adherence cut | AppError (not inline HTTPException) · logic in a service · *Create/*Read split · Page reused for loans list | **pass** ✓ |
| **Pass count** | | **4/4** |

## pytest output

```
21 passed
tests/test_books.py + tests/test_members.py   11 passed
tests/test_loans.py                           10 passed
```

## Notes

- No-new-deps confirmed: `pyproject.toml` dependencies unchanged (fastapi / uvicorn /
  pydantic / httpx + dev pytest). The only `HTTPException` string in `app/` is the
  starter's `exceptions.py` docstring warning against it — **zero actual usage**.
- Convention cut PASS: `app/routers/loans.py` added, `LoanRepository` wired into
  `database.py` `reset_db()`, `LoanCreate`/`LoanRead` split present, `Page[LoanRead]`
  envelope reused for the list endpoint.
- Member-loans route placement varies by cell (`loans.py` vs `members.py`
  `/{member_id}/loans`) — design variation, scored under System design (dim 4), not a defect.
- The *depth* of convention adherence (dims 3 + 4) is the blind-pass discriminator — see observations.md.
