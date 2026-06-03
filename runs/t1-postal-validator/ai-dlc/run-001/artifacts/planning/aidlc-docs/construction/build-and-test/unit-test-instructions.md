# Unit Test Execution

Unit tests cover the core logic (`validate` / `normalize` / `ValidationResult`) plus the
stdlib property-based tests.

## Run Unit Tests

### 1. Execute all unit tests
```bash
python -m pytest tests/test_core.py tests/test_properties.py -q
# or simply: python -m pytest
```

### 2. Review test results
- **Expected**: all pass, 0 failures.
  - `tests/test_core.py` — example-based contract for the public API (valid/invalid tables,
    type, case-insensitivity, unsupported country, `normalize` ValueError).
  - `tests/test_properties.py` — property-based (PBT) tests: domain generators (PBT-07),
    round-trip/idempotence (PBT-02), validity & error invariants (PBT-03).
- **Coverage**: the public surface (`validate`, `normalize`, `ValidationResult`) and all three
  country rule sets are exercised by both example-based and generated inputs.

### 3. Reproducibility (PBT-08)
Property tests are seeded (default `20260527`). To replay or vary:
```bash
POSTAL_VALIDATOR_SEED=12345 python -m pytest tests/test_properties.py -q
```
On failure, the assertion message embeds the seed and the exact failing example. (Automatic
shrinking is not implemented — stdlib-only constraint; the exact example is reported instead.)

### 4. Fix failing tests
1. Read the failed assertion (it names the country, seed, and failing example).
2. Re-run that one example/seed to reproduce.
3. Fix `postal_validator/_core.py` and re-run until green.
