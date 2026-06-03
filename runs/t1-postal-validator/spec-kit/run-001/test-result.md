# T1-spec-kit / Run 001 / Test Result

Objective scorer: the pre-written pytest suite, run in the cell dir after the
methodology declared done.

```
cd ~/dev/sdd-bench-t1-builds/spec-kit
python3 -m pytest -q
```

## Binary outcomes

| Outcome | Pass condition | Result |
|---|---|---|
| Core tests | all of `tests/test_core.py` (38) | **38/38 ✓** |
| CLI tests | all of `tests/test_cli.py` (8) | **8/8 ✓** |
| Stdlib only | no third-party deps added to pyproject.toml | **yes** |

## pytest output

```
$ python3 -m pytest -q
..............................................                           [100%]
46 passed in 0.37s

$ python3 -m pytest tests/test_core.py -q   →  38 passed
$ python3 -m pytest tests/test_cli.py  -q   →   8 passed
```

## Notes

- **Stdlib only: yes.** Runtime imports are `re`, `argparse`, `json`, `sys`,
  `dataclasses` only. `pyproject.toml` has no runtime dependencies; `pytest>=8.0`
  is declared under `[project.optional-dependencies] dev` only.
- pytest was not pre-installed in this environment; installed via
  `python3 -m pip install pytest` (dev-only, does not affect the stdlib-only verdict).
- Ran on Python 3.9.6 (the local interpreter). Suite is green there even though
  `pyproject.toml` declares `requires-python >=3.11` — the code deliberately
  targets a 3.9-compatible subset (`from __future__ import annotations` everywhere;
  no `match`/3.10+ runtime features). See research.md R5.
- No deviations: core/CLI cleanly split (`validate`/`normalize` importable without
  the CLI), no added runtime dep, no UK over-constraint (only the three simplified
  rules from `formats.md` are enforced).
