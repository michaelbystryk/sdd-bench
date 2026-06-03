# T1-vibe-planmode / Run 001 / Test Result

T1's objective scorer is the pre-written pytest suite. Run it in the cell dir
after the methodology declares done:

```
cd ~/dev/sdd-bench-t1-builds/vibe-planmode
pip install pytest    # if not already present
pytest -v
```

## Binary outcomes

| Outcome | Pass condition | Result |
|---|---|---|
| Core tests | all of `tests/test_core.py` (~38) | **38/38** ✓ |
| CLI tests | all of `tests/test_cli.py` (8) | **8/8** ✓ |
| Stdlib only | no third-party deps added to pyproject.toml | **yes** ✓ |

## pytest output

```
46 passed in 0.38s
```

Per-suite: `test_core.py` → 38 passed; `test_cli.py` → 8 passed.

## Notes

- pytest was not on global PATH (only system Python 3.9 present); ran via the submission's own `.venv/bin/python -m pytest`. No source/config modified during scoring.
- **Stdlib-only confirmed:** runtime imports are `dataclasses`, `re`, `argparse`, `json`, `sys`. `pyproject.toml` declares zero runtime deps; `pytest` is dev-only (`optional-dependencies.dev`). No validation/CLI library pulled in.
- Time from session start → first green suite: ~**4m04s** wall (session began 11:45:46; all 46 green by 11:50:08 after a venv had to be created because only Python 3.9 was on the box). API compute to first green: within the 3m57s total.
- No deviations: core/CLI cleanly split (`core.py` has zero argparse; `cli.py` is a thin shell over `validate`), no UK over-constraint (enforces exactly the 3 stated rules), no dependency creep.
