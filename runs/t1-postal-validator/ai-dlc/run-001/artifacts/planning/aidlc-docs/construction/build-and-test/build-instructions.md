# Build Instructions

## Prerequisites
- **Build Tool**: None for runtime — pure Python package, no compile step.
- **Runtime**: Python 3.9+ (validated on 3.9.6; `pyproject.toml` declares `requires-python >=3.11`,
  but the code uses `from __future__ import annotations` and is 3.9-compatible).
- **Dependencies**: Standard library only. No third-party runtime dependencies.
  Test-only: `pytest>=8.0` (declared as the `dev` optional-dependency in `pyproject.toml`).
- **Environment Variables**: None required. Optional: `POSTAL_VALIDATOR_SEED` to pin property tests.
- **System Requirements**: Negligible (CPU/memory/disk).

## Build Steps

### 1. (Optional) Create a virtual environment and install dev deps
```bash
python -m venv .venv
. .venv/bin/activate
pip install -e ".[dev]"      # installs pytest; the package itself has no runtime deps
```

### 2. "Build" the package
No build/compile is needed. The importable package lives at the workspace root (`postal_validator/`).
For an installable artifact (optional):
```bash
python -m pip install build && python -m build   # produces sdist + wheel in dist/
```

### 3. Verify the package imports and the CLI runs
```bash
python -c "import postal_validator; print(postal_validator.__version__)"
python -m postal_validator --help
```

## Verify Build Success
- **Expected Output**: version prints (`0.1.0`); `--help` prints usage and exits 0.
- **Build Artifacts**: none required to run; optional `dist/*.whl` and `dist/*.tar.gz` if `build` is used.
- **Common Warnings**: none expected.

## Troubleshooting
### `ModuleNotFoundError: postal_validator`
- **Cause**: running from outside the workspace root.
- **Solution**: run from the repo root (the dir containing `postal_validator/`), or `pip install -e .`.
  `python -m postal_validator` prepends the current directory to `sys.path`, so run it from the root.

### `pytest: command not found`
- **Cause**: dev dependency not installed.
- **Solution**: `pip install ".[dev]"` or `pip install pytest`, then use `python -m pytest`.
