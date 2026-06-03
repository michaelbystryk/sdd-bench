# Build & Test Summary

## Environment
- Python 3.12.13 (via `uv` — `pyproject.toml` requires `>=3.11`).
- Deps installed: `uv sync --extra dev`.

## Commands
- Install: `uv sync --extra dev`
- Test: `uv run pytest tests/test_imports.py -v`
- Run server (local): `uv run uvicorn app.main:app --reload`

## Test Results
All 14 tests in `tests/test_imports.py` pass on first run.

```
tests/test_imports.py::test_happy_path_returns_200_with_full_envelope PASSED
tests/test_imports.py::test_partial_success_returns_200_with_per_row_results_in_order PASSED
tests/test_imports.py::test_single_row_type_mismatch_is_row_level_not_whole_file PASSED
tests/test_imports.py::test_malformed_csv_returns_400 PASSED
tests/test_imports.py::test_missing_required_column_returns_400_with_details PASSED
tests/test_imports.py::test_empty_file_returns_400 PASSED
tests/test_imports.py::test_file_too_large_returns_413 PASSED
tests/test_imports.py::test_embedded_newlines_in_quoted_field_preserved PASSED
tests/test_imports.py::test_utf8_bom_stripped_from_header PASSED
tests/test_imports.py::test_crlf_line_endings_supported PASSED
tests/test_imports.py::test_mixed_line_endings_supported PASSED
tests/test_imports.py::test_unicode_in_name_field_preserved PASSED
tests/test_imports.py::test_get_import_returns_same_body_as_post PASSED
tests/test_imports.py::test_get_import_unknown_id_returns_404 PASSED

============================== 14 passed in 0.96s ==============================
```

## Coverage of Pinned Behaviors
| Behavior | Covered by test |
|---|---|
| 200 envelope with import_id + totals + per-row results | `test_happy_path_*` |
| Partial success, row ordering, error codes (`invalid_type`, `out_of_range`) | `test_partial_success_*` |
| Single-row type mismatch is row-level, not whole-file | `test_single_row_type_mismatch_*` |
| Malformed CSV (unmatched quote) → 400 `malformed_csv` | `test_malformed_csv_*` |
| Missing required header column → 400 `missing_required_columns` with details | `test_missing_required_column_*` |
| Empty file (header-only) → 400 `empty_file` | `test_empty_file_*` |
| > 10 MB upload → 413 `file_too_large` | `test_file_too_large_*` |
| Embedded newlines in quoted fields preserved | `test_embedded_newlines_*` |
| UTF-8 BOM stripped from header | `test_utf8_bom_*` |
| CRLF + mixed line endings | `test_crlf_*`, `test_mixed_endings_*` |
| Non-ASCII names preserved | `test_unicode_in_name_*` |
| GET returns identical body to POST | `test_get_import_returns_same_body_*` |
| GET unknown id → 404 `import_not_found` | `test_get_import_unknown_id_*` |

## Manual / Not Tested
- 100k-row limit (`too_many_rows`) — implemented per spec but no fixture exercises it.
- Persistence across process restart — out of scope (in-memory store).
