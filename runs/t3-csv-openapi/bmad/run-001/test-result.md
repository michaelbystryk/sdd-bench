# T3-bmad / Run 001 / Test Result

Objective scorer = the pre-written pytest suite, run in the cell dir after the
methodology declared done (isolated scoring venv, not the cell's own env):

```
cd ~/dev/sdd-bench-t3-builds/bmad
uv venv --python 3.11 .venv-score
uv pip install --python .venv-score/bin/python -e ".[dev]"
.venv-score/bin/python -m pytest -v
```

Base state at lock: **0/14** passing — `tests/test_imports.py` collection-errors on `ModuleNotFoundError: No module named 'app.main'` (no impl shipped in starter).

## Binary outcomes (per success-criteria.md)

| Outcome | Pass condition | Result |
|---|---|---|
| Tests pass | all 14 in tests/test_imports.py | **14/14** ✅ |
| No new dependencies | no additions to pyproject.toml runtime deps beyond pinned set | **yes** ✅ (diff vs `starter/pyproject.toml` is empty) |
| Pydantic v2 idiom | no v1 surface in cell code | **yes** ✅ (grep returns nothing) |
| Async handler | POST handler is `async def` | **yes** ✅ (`app/main.py:29` — `async def create_user_import`) |
| File-size limit enforced | test_file_too_large_returns_413 passes | **yes** ✅ (and implementation uses *streaming with early-abort* — does NOT load whole body before the 413) |
| **Pass count** | | **5/5** ✅ |

## pytest output

```
============================= test session starts ==============================
platform darwin -- Python 3.11.15, pytest-9.0.3, pluggy-1.6.0
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

============================== 14 passed in 0.93s ==============================
```

## Static checks (output)

```
# v2-idiom check (empty = pass)
$ grep -nE 'parse_obj|parse_raw|\.dict\(\)|\.json\(\)|@validator\b' app/
(no matches)

# async handler check
$ grep -nE 'async\s+def|^def ' app/main.py
21:def _error(status_code: int, code: str, message: str, ...) -> JSONResponse:
29:async def create_user_import(file: UploadFile = File(...)) -> JSONResponse:
62:async def get_user_import(import_id: UUID) -> JSONResponse:
```

## Notes

- **Spec/impl divergence in the right direction**: the BMAD spec said "Size enforcement: Read `UploadFile` fully then `len(bytes) > 10 * 1024 * 1024` → 413. We don't stream because the cap is small." The shipped `main.py` instead implements **streaming reads with early 413 abort** (64 KB chunks, breaks at `> MAX_FILE_SIZE`). The implementation surpassed its own spec on the security-relevant edge.
- v2 idiom adopted cleanly: `ConfigDict(extra="ignore")`, `model_validate`, `model_dump(mode="json")`, `@field_validator`-style (no `@validator`), `EmailStr` from `pydantic`.
- Multi-file separation: `main.py` (HTTP), `csv_import.py` (parse + per-row validate + typed exceptions), `schemas.py` (Pydantic models), `store.py` (in-memory dict). Per-row vs whole-file error split structurally encoded via `CSVImportError` subclasses + envelope helper.
- No README shipped. `docs/` directory is empty. All "shipped docs" are inline (sparse: one comment on the streaming-413 rationale at `main.py:30-31`).
- No critical/major defects surfaced by tests or code review.
