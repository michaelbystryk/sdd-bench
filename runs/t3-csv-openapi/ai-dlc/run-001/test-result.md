# T3-ai-dlc / Run 001 / Test Result

Objective scorer = the pre-written pytest suite, run in the cell dir after the
methodology declared done (isolated scoring venv, not the cell's own env):

```
cd ~/dev/sdd-bench-t3-builds/ai-dlc
uv venv --python 3.11 .venv-score
uv pip install --python .venv-score/bin/python -e ".[dev]"
.venv-score/bin/python -m pytest -v
```

Base state at lock: **0/14** passing — `tests/test_imports.py` collection-errors on `ModuleNotFoundError: No module named 'app.main'` (no impl shipped in starter).

## Binary outcomes (per success-criteria.md)

| Outcome | Pass condition | Result |
|---|---|---|
| Tests pass | all 14 in tests/test_imports.py | **14/14** ✓ |
| No new dependencies | no additions to pyproject.toml runtime deps beyond pinned set | **yes** ✓ (diff empty vs starter) |
| Pydantic v2 idiom | no v1 surface in cell code | **yes** ✓ (grep returns nothing) |
| Async handler | POST handler is `async def` | **yes** ✓ (`async def create_user_import` at main.py:146) |
| File-size limit enforced | test_file_too_large_returns_413 passes | **yes** ✓ (passes; impl streams in 64 KB chunks, aborts past 10 MB) |
| **Pass count** | | **5 / 5** |

## pytest output (tail)

```
============================= test session starts ==============================
platform darwin -- Python 3.11.15, pytest-9.0.3, pluggy-1.6.0
rootdir: ~/dev/sdd-bench-t3-builds/ai-dlc
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

============================== 14 passed in 0.95s ==============================
```

## Static checks (output)

```
# v2-idiom check
$ grep -nE 'parse_obj|parse_raw|\.dict\(\)|\.json\(\)|@validator\b' app/
(no matches — v2-clean)

# async handler check
$ grep -nE 'async\s+def|^def ' app/main.py
56:def _error(status_code: int, code: str, message: str, details: dict | None = None) -> JSONResponse:
63:def _is_valid_email(value: str) -> bool:
71:def _validate_row(row: dict[str, str]) -> tuple[Optional[UserRow], list[FieldError]]:
132:async def _read_capped(file: UploadFile) -> Optional[bytes]:
146:async def create_user_import(file: UploadFile = File(...)) -> JSONResponse:
219:async def get_user_import(import_id: str) -> JSONResponse:

# pyproject runtime-deps diff vs starter
$ diff pyproject.toml ~/dev/sdd-bench/tasks/t3-csv-openapi/starter/pyproject.toml
(empty — no changes)
```

## Notes

- Both HTTP handlers and `_read_capped` are `async def`; helper validators are sync (correct — no I/O on the validators).
- `_read_capped` accumulates 64 KB chunks and bails the moment buffered bytes exceed `MAX_FILE_SIZE` (10 MB), so the 413 is enforced during the read, not after a full-buffer load. Matches the success-criteria intent.
- Error envelope `{"error": {code, message, [details]}}` matches `ErrorResponse` schema in `reference/openapi.yaml` — single consistent shape across 400/404/413.
- Implementation also enforces a 100 k row cap (`too_many_rows`) which the spec requires but is NOT exercised by any of the 14 shipped tests — bonus coverage.
- `csv.reader` over `StringIO` with `decode("utf-8-sig")` handles BOM, CRLF, mixed line endings, and embedded newlines natively — no hand-rolled splitting.
- Custom `_validate_row` hand-assembles `FieldError`s instead of routing through Pydantic field validators. Loses some idiom but gives precise control over the `missing` / `invalid_type` / `out_of_range` / `invalid_format` code mapping the spec pins. Architectural choice, not a defect.
- No observable defects from review (Critical: 0, Major: 0, Minor: 0).
- Single-file shape (`app/main.py` only, 223 LOC) — no separate `parser`/`validator`/`store` modules. Functional separation is via private helpers, not module boundaries. (Likely depresses dim 4 in the blind pass; load-bearing for T3.)
