# T1-ai-dlc / Run 001 / Test Result

T1's objective scorer is the pre-written pytest suite, run in the cell dir after the
methodology declared done:

```
cd ~/dev/sdd-bench-t1-builds/ai-dlc
python3 -m pytest -q          # pytest 8.x; interpreter is Python 3.9.6 locally
```

## Binary outcomes

| Outcome | Pass condition | Result |
|---|---|---|
| Core tests | all of `tests/test_core.py` (38) | **38/38 PASS** |
| CLI tests | all of `tests/test_cli.py` (8) | **8/8 PASS** |
| Stdlib only | no third-party deps added to pyproject.toml | **yes** |

## pytest output

```
$ python3 -m pytest -q
........................................................                 [100%]
56 passed in 0.41s

# per-file:
tests/test_core.py ...... 38 passed
tests/test_cli.py  ...... 8 passed
tests/test_properties.py  10 passed   (added by the methodology — stdlib PBT)
```

## Notes

- **56/56 pass** total: 38 core + 8 CLI + 10 methodology-added stdlib property tests.
- **Stdlib only: YES.** `pyproject.toml` declares no runtime deps; pytest is the only
  (dev/optional) dep. The added `tests/test_properties.py` deliberately avoids Hypothesis
  and uses a seeded `random` + pytest harness to honor the stdlib-only constraint
  (documented as the PBT-09 deviation). Imports across `postal_validator/` + tests are
  stdlib + internal only (verified by grep; no click/typer/hypothesis).
- Time from session start → first green suite: ~11 min (12:23:27 start → 12:34:29 first
  full green run, per reconstructed transcript).
- Deviations: none harmful. Core/CLI cleanly split (`_core.py` pure, `cli.py` thin shell);
  no UK over-constraint (`W1A 1AA` validates, `123456789` correctly rejected); no dep creep.
```
