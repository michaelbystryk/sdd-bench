# T1-bmad / Run 001 / Test Result

T1's objective scorer is the pre-written pytest suite. Run it in the cell dir
after the methodology declares done:

```
cd ~/dev/sdd-bench-t1-builds/bmad
python3 -m pip install -q pytest   # if not already present
python3 -m pytest -q
```

## Binary outcomes

| Outcome | Pass condition | Result |
|---|---|---|
| Core tests | all of `tests/test_core.py` (38) | **38/38 ✅** |
| CLI tests | all of `tests/test_cli.py` (8) | **8/8 ✅** |
| Stdlib only | no third-party deps added to pyproject.toml | **yes ✅** (only `argparse`, `json`, `sys`, `re`, `dataclasses`, `typing`) |

## pytest output

```
$ python3 -m pytest -q
..............................................                           [100%]
46 passed in 0.37s

$ python3 -m pytest tests/test_core.py -q
38 passed in 0.02s

$ python3 -m pytest tests/test_cli.py -q
8 passed in 0.34s
```

No failures. `pyproject.toml` declares only `pytest` under the optional `dev`
extra; no runtime third-party dependency. `requires-python` lowered to `>=3.9`.

## Notes

- All 46 tests green on first run; no deps added (stdlib-only constraint held).
- Core/CLI cleanly separated: `_core.py` holds `validate`/`normalize`/`ValidationResult`;
  `__main__.py` is a thin argparse shell with no validation logic inline.
- No UK over-constraint: enforces exactly the simplified `formats.md` rule set
  (inward forbidden letters `CIKMOV`, outward regex as stated) — no extra real-world rules.
- Pytest invoked as `python3 -m pytest` (bare `pytest` not on PATH; pytest 8.4.2).
