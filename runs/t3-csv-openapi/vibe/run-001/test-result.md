# T3-vibe / Run 001 / Test Result

Objective scorer = the pre-written pytest suite, run in the cell dir after the
methodology declared done (isolated scoring venv, not the cell's own env):

```
cd ~/dev/sdd-bench-t3-builds/vibe
uv venv --python 3.11 .venv-score
uv pip install --python .venv-score/bin/python -e ".[dev]"
.venv-score/bin/python -m pytest -v
```

Base state at lock: **0/14** passing — `tests/test_imports.py` collection-errors on `ModuleNotFoundError: No module named 'app.main'` (no impl shipped in starter).

## Binary outcomes (per success-criteria.md)

| Outcome | Pass condition | Result |
|---|---|---|
| Tests pass | all 14 in tests/test_imports.py | **14/14** ✓ |
| No new dependencies | no additions to pyproject.toml runtime deps beyond pinned set | **yes** ✓ (diff vs starter pyproject = empty) |
| Pydantic v2 idiom | no v1 surface in cell code: `grep -nE 'parse_obj\|parse_raw\|\.dict\(\)\|\.json\(\)\|@validator\b' app/` returns nothing | **yes** ✓ (vacuously — cell uses zero Pydantic models; hand-rolled validation with regex) |
| Async handler | POST handler is `async def` | **yes** ✓ (`async def create_user_import` at main.py:91; GET also async at :179) |
| File-size limit enforced | test_file_too_large_returns_413 passes | **yes** ✓ (chunked read with running byte accumulator; trips 413 at 10 MB before buffering full file) |
| **Pass count** | | **5/5** |

## pytest output

```
============================= test session starts ==============================
platform darwin -- Python 3.11.15, pytest-9.0.3, pluggy-1.6.0
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

============================== 14 passed in 0.83s ==============================
```

## Static checks (paste output)

```
# v2-idiom check
$ grep -nE 'parse_obj|parse_raw|\.dict\(\)|\.json\(\)|@validator\b' app/
(no matches; RC=1)

# async handler check
$ grep -nE 'async\s+def|^def ' app/main.py
23:def _error(status: int, code: str, message: str, details: Optional[dict] = None) -> JSONResponse:
30:def _validate_row(row: dict[str, str]) -> tuple[Optional[dict], list[dict]]:
91:async def create_user_import(file: UploadFile = File(...)):
179:async def get_user_import(import_id: str):
```

POST and GET handlers are both `async def`. The two sync `def`s are internal helpers (`_error`, `_validate_row`) — fine.

## Notes

- **v2-idiom vacuous pass.** The grep returns nothing because the cell shipped **zero Pydantic models** — `pydantic[email]` is in deps but unused. All validation is hand-rolled with `re.compile` patterns + `int()` / `date.fromisoformat()`. The v1-trap check is *technically* satisfied, but the cell sidestepped the idiom question entirely. Worth flagging for the blind reviewers on dim 3 (Code quality) and dim 4 (System design) — using `pydantic[email]>=2.6` while hand-rolling an email regex is the inverse of the v2 idiom the spec was probing for.
- **Streaming → re-buffer.** The chunked-read 413 guard is correct and trips at 10 MB before materializing the full file — but then `body = b"".join(chunks)` re-materializes everything anyway, and `csv.reader(io.StringIO(text), ...)` loads all rows via `list(reader)`. Up-front size check works; "real" streaming does not. Score under Robustness/Security in the blind pass.
- **Extra/missing column count is whole-file 400.** `if len(r) != expected_cols: return _error(400, "malformed_csv", ...)` — the spec is silent on this edge; tests don't pin it. Defensible either way (whole-file = "the CSV is structurally broken", per-row = "this row failed"); flagging as a scope/judgment call rather than a defect.
- **Country error leaks Python repr.** `f"country must be one of {sorted(ALLOWED_COUNTRIES)}"` produces `country must be one of ['AU', 'CA', 'DE', 'FR', 'JP', 'UK', 'US']` — minor cosmetic.
- **In-memory `_imports: dict[str, dict] = {}` at module scope.** No eviction, no TTL, no comment, no docstring acknowledging the lifecycle. This is the C-axis retention behavior — silently picked the default with no surfacing. Classification in observations.md §C-axis.
