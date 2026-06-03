# Quickstart: Postal-Code Validator + CLI

## Prerequisites

- Python (target `>=3.11` per `pyproject.toml`; the code also runs on 3.9+). Standard library only — no runtime installs.
- For tests: `pip install -e ".[dev]"` (installs `pytest`).

## Library usage

```python
from postal_validator import validate, normalize

r = validate("k1a0b1", "CA")
r.valid          # True
r.normalized     # "K1A 0B1"
r.error          # None

bad = validate("D1A 0B1", "CA")
bad.valid        # False
bad.error        # short reason, e.g. "first letter not allowed"

normalize("ec1a1bb", "UK")   # "EC1A 1BB"
normalize("1234", "US")      # raises ValueError
```

## CLI usage

Run from the repository root (so `postal_validator` is importable):

```bash
# single code → prints canonical form, exit 0
python -m postal_validator validate k1a0b1 --country CA      # -> K1A 0B1

# invalid → exit 1
python -m postal_validator validate "D1A 0B1" --country CA   # exit 1

# JSON output
python -m postal_validator validate 12345 --country US --json
# -> {"valid": true, "normalized": "12345", "error": null}

# batch from stdin (no code arg): one verdict per line; exit 1 if any invalid
printf 'K1A 0B1\nD1A 0B1\n' | python -m postal_validator validate --country CA
# -> K1A 0B1
#    INVALID: ...

# help
python -m postal_validator --help     # prints usage, exit 0
```

## Verify

```bash
pytest            # tests/test_core.py + tests/test_cli.py must all pass
```

Success = both suites green: `validate`/`normalize` behavior (`test_core.py`) and the CLI contract — exit codes, `--json`, stdin batch, `--help` (`test_cli.py`).
