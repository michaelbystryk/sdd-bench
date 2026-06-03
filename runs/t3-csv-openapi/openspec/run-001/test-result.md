# T3-openspec / Run 001 / Test Result

Objective scorer = the pre-written pytest suite, run in the cell dir after the
methodology declared done (isolated scoring venv, not the cell's own env):

```
cd ~/dev/sdd-bench-t3-builds/openspec
uv venv --python 3.11 .venv-score
uv pip install --python .venv-score/bin/python -e ".[dev]"
.venv-score/bin/python -m pytest -v
```

Base state at lock: **0/14** passing — `tests/test_imports.py` collection-errors on `ModuleNotFoundError: No module named 'app.main'` (no impl shipped in starter).

## Binary outcomes (per success-criteria.md)

| Outcome | Pass condition | Result |
|---|---|---|
| Tests pass | all 14 in tests/test_imports.py | **14/14** ✓ |
| No new dependencies | no additions to pyproject.toml runtime deps beyond pinned set | **yes** ✓ (pyproject.toml byte-identical to starter) |
| Pydantic v2 idiom | no v1 surface in cell code: `grep -nE 'parse_obj\|parse_raw\|\.dict\(\)\|\.json\(\)\|@validator\b' app/` returns nothing | **yes** ✓ (no matches) |
| Async handler | POST handler is `async def` | **yes** ✓ (`async def create_user_import` at main.py:21; GET also async) |
| File-size limit enforced | test_file_too_large_returns_413 passes | **yes** ✓ (chunked 64KB streaming read; bails at MAX_BYTES = 10,485,760) |
| **Pass count** | | **5/5** ✓ |

## pytest output

```
============================= test session starts ==============================
platform darwin -- Python 3.11.15, pytest-9.0.3, pluggy-1.6.0
rootdir: ~/dev/sdd-bench-t3-builds/openspec
configfile: pyproject.toml
testpaths: tests
plugins: anyio-4.13.0
collected 14 items

tests/test_imports.py::test_happy_path_returns_200_with_full_envelope PASSED [  7%]
tests/test_imports.py::test_partial_success_returns_200_with_per_row_results_in_order PASSED [ 14%]
tests/test_imports.py::test_single_row_type_mismatch_is_row_level_not_whole_file PASSED [ 21%]
tests/test_imports.py::test_malformed_csv_returns_400 PASSED             [ 28%]
tests/test_imports.py::test_missing_required_column_returns_400_with_details PASSED [ 35%]
tests/test_imports.py::test_empty_file_returns_400 PASSED                [ 42%]
tests/test_imports.py::test_file_too_large_returns_413 PASSED            [ 50%]
tests/test_imports.py::test_embedded_newlines_in_quoted_field_preserved PASSED [ 57%]
tests/test_imports.py::test_utf8_bom_stripped_from_header PASSED         [ 64%]
tests/test_imports.py::test_crlf_line_endings_supported PASSED           [ 71%]
tests/test_imports.py::test_mixed_line_endings_supported PASSED          [ 78%]
tests/test_imports.py::test_unicode_in_name_field_preserved PASSED       [ 85%]
tests/test_imports.py::test_get_import_returns_same_body_as_post PASSED  [ 92%]
tests/test_imports.py::test_get_import_unknown_id_returns_404 PASSED     [100%]

============================== 14 passed in 0.84s ==============================
```

## Static checks

```
$ grep -rnE 'parse_obj|parse_raw|\.dict\(\)|\.json\(\)|@validator\b' app/
(no matches)

$ grep -nE 'async\s+def|^def ' app/main.py
21:async def create_user_import(file: UploadFile = File(...)):
101:async def get_user_import(import_id: str):

$ diff pyproject.toml ~/dev/sdd-bench/tasks/t3-csv-openapi/starter/pyproject.toml
(no diff — byte-identical)
```

## Notes

- Implementation shipped clean: `app/{main.py, models.py, parsing.py, validation.py, store.py, errors.py}` — 370 impl LOC total. Layering is exactly what design.md prescribed (CSV parsing in `parsing.py`, row validation in `validation.py`, HTTP shaping in `main.py`, error envelope in `errors.py`, store as a separate module).
- All 4 silent discriminators landed correctly: v2 idiom (uses `TypeAdapter(EmailStr)`, no v1 surface), async handler with chunked streaming read, per-row vs whole-file split structurally encoded via typed `MalformedCSVError` / `EmptyFileError` exceptions caught at the handler boundary, and 10 MB enforced *before* full-file buffering (chunks accumulated to a list with byte budget).
- The cell also enforces the 100,000-row cap with snake_case `too_many_rows` — not exercised by the tests, but pre-declared in design.md §7 and shipped accordingly.
- No `[ASSUMPTION]` literal tags, but retention is treated as an ADR-style decision in three places (proposal.md "results live for the lifetime of the process only"; design.md Non-Goals + Decision #5 + Risks/Trade-offs #1) with rationale + alternative considered (SQLite, rejected) + migration path.
- No README in cell dir — docs are inside the openspec/ planning artifacts, not shipped alongside `app/`. (Affects dim 9 docs scoring at blind pass — planning artifacts do NOT count for dim 9 per the rubric clarification.)
- Country whitelist enforced in `validation.py` (`ALLOWED_COUNTRIES` frozenset) rather than as a Pydantic `Literal` in the model as `tasks.md` §1.2 prescribed. Minor own-plan deviation but functionally equivalent — `UserRow.country` is plain `str`.
- No `Content-Type` validation on the multipart upload — accepts any content type. T3 success-criteria.md flags content-type validation as a "common 4-tier behavior" for dim 8; absence noted for blind pass.
