# T3-spec-kit / Run 001 / Test Result

Objective scorer = the pre-written pytest suite, run in the cell dir after the
methodology declared done (isolated scoring venv, not the cell's own env):

```
cd ~/dev/sdd-bench-t3-builds/spec-kit
uv venv --python 3.11 .venv-score
uv pip install --python .venv-score/bin/python -e ".[dev]"
.venv-score/bin/python -m pytest -v
```

Base state at lock: **0/14** passing — `tests/test_imports.py` collection-errors on `ModuleNotFoundError: No module named 'app.main'` (no impl shipped in starter).

## Binary outcomes (per success-criteria.md)

| Outcome | Pass condition | Result |
|---|---|---|
| Tests pass | all 14 in tests/test_imports.py | **14/14** ✅ |
| No new dependencies | no additions to pyproject.toml runtime deps beyond pinned set | **yes** ✅ (pyproject.toml byte-identical to starter) |
| Pydantic v2 idiom | no v1 surface in cell code: `grep -nE 'parse_obj\|parse_raw\|\.dict\(\)\|\.json\(\)\|@validator\b' app/` returns nothing | **yes** ✅ (grep empty; uses `model_validate`) |
| Async handler | POST handler is `async def` | **yes** ✅ (`async def create_user_import` at `app/main.py:32`) |
| File-size limit enforced | test_file_too_large_returns_413 passes | **yes** ✅ (chunked read with 10 MB cap at `app/main.py:72`) |
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

============================== 14 passed in 0.87s ==============================
```

## Static checks (paste output)

```
# v2-idiom check (must be empty)
$ grep -nE 'parse_obj|parse_raw|\.dict\(\)|\.json\(\)|@validator\b' app/
(no output) ✅

# async handler check
$ grep -nE 'async\s+def|^def ' app/main.py
24:async def _whole_file_error_handler(_request: Request, exc: WholeFileError) -> JSONResponse:
32:async def create_user_import(file: UploadFile = File(...)) -> ImportResult:
61:async def get_user_import(import_id: uuid.UUID) -> ImportResult:
72:async def _read_with_size_cap(file: UploadFile) -> bytes:

# pyproject runtime deps diff vs starter
$ diff <(grep -A20 '^\[project\]' starter/pyproject.toml) <(grep -A20 '^\[project\]' cell/pyproject.toml)
(no output — byte-identical runtime dep block) ✅
```

## LOC (impl only)

```
app/__init__.py     0
app/csv_parser.py  68
app/errors.py      34
app/main.py        89
app/repository.py  15
app/schemas.py     58
app/validator.py  116
TOTAL             380
```

## Notes

- All 14 pinned tests pass cleanly in 0.87s.
- All 5 binary outcomes pass — no v1 idiom, async POST handler, streaming size guard
  (chunks of 64 KiB, 10 MB cap before `parse_csv`), no dep drift.
- Whole-file errors structurally separated from row-level errors via a single
  `WholeFileError` exception class + FastAPI exception handler that emits the
  documented `{"error": {...}}` envelope (matches `data-model.md` design).
- The cell additionally enforces a `too_many_rows` cap (100k rows → 400) per the
  OpenAPI contract, even though no pinned test exercises it (research.md §R6
  decision, implemented at `app/csv_parser.py:55-61`).
- Decoding uses `"utf-8-sig"` — implicit BOM strip rather than explicit byte check
  (research.md §R3 lists both as acceptable). One-line, idiomatic.
- Stripping the header (`header = [col.strip() for col in header]`) handles
  whitespace tolerance beyond what tests pin — a small robustness bonus.
- One latent issue worth flagging for the blind review: the validator's
  `_map_validation_errors` deduplicates missing-field errors against existing
  ones by field name only, then sorts by column index. Field order looks right
  but the dedup logic at `app/validator.py:80-84` is subtle — `iter` filter could
  be hard for a teammate to scan. Not a defect, but a Code-quality observation.
