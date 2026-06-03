# T1-vibe / Run 001 / Test Result

T1's objective scorer is the pre-written pytest suite. Run it in the cell dir
after the methodology declares done:

```
cd ~/dev/sdd-bench-t1-builds/vibe
pip install pytest    # if not already present
pytest -v
```

## Binary outcomes

| Outcome | Pass condition | Result |
|---|---|---|
| Core tests | all of `tests/test_core.py` (38) | **38/38** ✓ |
| CLI tests | all of `tests/test_cli.py` (8) | **8/8** ✓ |
| Stdlib only | no third-party deps added to pyproject.toml | **yes** ✓ |

## pytest output

```
$ .venv/bin/python -m pytest -q
..............................................                           [100%]
46 passed in 0.29s

# per-file
tests/test_core.py  38 passed
tests/test_cli.py    8 passed
```

## Notes

- Stdlib-only confirmed: runtime imports are `re`, `dataclasses`, `argparse`,
  `json`, `sys`, `typing`, `__future__` only. `pyproject.toml` lists no runtime
  deps (pytest is a dev-only optional dependency).
- Time from session start → first green suite: ~02:00 (single write pass, then
  `uv venv` + pytest; all 46 green on first run — no rework).
- Deviations: none. No dep added; core (`validate`/`normalize`) is cleanly
  importable without the CLI; UK rules enforced exactly as specified (no
  over-constraint).
