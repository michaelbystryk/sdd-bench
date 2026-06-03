# CSV import endpoint

Build a CSV import service per `reference/openapi.yaml`. The behavior is pinned
by `tests/test_imports.py` — make those tests pass.

Stack: FastAPI + Pydantic per `pyproject.toml` (already configured). Don't add
new runtime dependencies. Produce PR-ready code.

Sample CSVs for local testing are in `reference/sample_csvs/`.
