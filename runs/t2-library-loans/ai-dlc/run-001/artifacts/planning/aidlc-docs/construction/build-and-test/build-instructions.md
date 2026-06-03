# Build Instructions

## Prerequisites
- **Build Tool**: setuptools via `pyproject.toml` (PEP 517). Installed with `pip` or `uv`.
- **Language Runtime**: Python ≥ 3.11 (the project sets `requires-python = ">=3.11"`).
- **Dependencies** (declared in `pyproject.toml`, unchanged by this feature):
  - Runtime: `fastapi>=0.110`, `uvicorn>=0.27`, `pydantic>=2.6`, `httpx>=0.27`
  - Dev: `pytest>=8.0`
- **Environment Variables**: none required.
- **System Requirements**: any OS with Python 3.11+ (verified on macOS / CPython 3.11.15).

> Note: this is a pure-Python service — there is no compile/bundle step. "Build" means
> creating an environment and installing the package (editable) so it is importable.

## Build Steps

### 1. Install Dependencies
Using `uv` (recommended — also provisions Python 3.11 if absent):
```bash
uv venv --python 3.11
uv pip install -e ".[dev]"
```

Or using stock `pip` in a Python 3.11+ environment:
```bash
python -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
```

### 2. Configure Environment
No environment variables or credentials are needed. (Storage is in-memory.)

### 3. Build All Units
No separate build artifact is produced. The single unit (`loans`) is installed as part
of the `app` package by the editable install above. Optionally verify it imports:
```bash
.venv/bin/python -c "import app.main; print('app import OK')"
```

### 4. Verify Build Success
- **Expected Output**: editable install completes; `import app.main` prints `app import OK`.
- **Build Artifacts**: none beyond the editable install metadata (`*.egg-info/`, gitignored).
- **Common Warnings**: none expected.

## Troubleshooting

### Build Fails with Dependency Errors
- **Cause**: offline environment or stale index.
- **Solution**: ensure network access to PyPI; re-run the install. With `uv`, retry `uv pip install -e ".[dev]"`.

### Build Fails with Python Version Errors
- **Cause**: active interpreter is < 3.11 (e.g. system Python 3.9). The code uses 3.10+ syntax (`X | None`).
- **Solution**: create the venv with Python 3.11+ (`uv venv --python 3.11`) and install into it.
