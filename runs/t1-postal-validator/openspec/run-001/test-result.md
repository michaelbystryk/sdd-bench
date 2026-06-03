# T1-openspec / Run 001 / Test Result

T1's objective scorer is the pre-written pytest suite. Run in the cell dir
after the methodology declares done.

Command used (no 3.11+ system python + pytest available; provisioned via uv per pyproject):

```
cd ~/dev/sdd-bench-t1-builds/openspec
uv run --with pytest pytest -q
```

## Binary outcomes

| Outcome | Pass condition | Result |
|---|---|---|
| Core tests | all of `tests/test_core.py` (38) | **38/38** ✓ |
| CLI tests | all of `tests/test_cli.py` (8) | **8/8** ✓ |
| Stdlib only | no third-party deps added to pyproject.toml | **yes** ✓ |

## pytest output

```
.............................................. [100%]
46 passed in 0.31s
```

Per-file:
```
tests/test_core.py  ...................................... 38 passed
tests/test_cli.py   ........                                8 passed
```

## Notes

- Runtime imports are stdlib only: `re`, `dataclasses` (core); `argparse`, `json`, `sys`, `typing` (cli). `pyproject.toml` declares zero runtime deps; `pytest` is the only (dev) dependency. CPython 3.12 via uv (project pins `>=3.11`).
- No dep creep (no click/typer/validators). No core/CLI tangle — `core.py` has zero I/O and is importable independently. No UK over-constraint (regexes mirror `formats.md` line-for-line; inward = final three chars).
- Time from session start → first green suite: ~4m13s wall (11:56:17 → 12:00:30 first pytest run; passed on first try after provisioning uv).
