# Build and Test Summary

## Build Status
- **Build Tool**: None (pure Python; no compile step).
- **Build Status**: Success — package imports cleanly; `python -m postal_validator` runs.
- **Build Artifacts**: none required at runtime (optional sdist/wheel via `python -m build`).
- **Build Time**: negligible.

## Test Execution Summary

### Unit Tests (core logic)
- **File**: `tests/test_core.py`
- **Total**: 38 — **Passed**: 38 — **Failed**: 0
- **Status**: Pass (validate/normalize/ValidationResult contract; valid+invalid tables for CA/US/UK;
  case-insensitivity; unsupported-country; `normalize` raises `ValueError`).

### Property-Based Tests (PBT, stdlib)
- **File**: `tests/test_properties.py`
- **Total**: 10 — **Passed**: 10 — **Failed**: 0
- **Status**: Pass. Re-verified across seeds 1, 2, 42, 99, 123456, 20260527 → all pass (not seed-sensitive).
- **PBT compliance** (Partial mode — see aidlc-state.md):
  - PBT-02 (round-trip/idempotence): **Compliant** — `normalize` idempotence + re-validation of canonical form.
  - PBT-03 (invariants): **Compliant** — valid→(valid, error None, canonical shape); invalid→(False, None, error str).
  - PBT-07 (generator quality): **Compliant** — domain generators emit structurally valid/invalid CA/US/UK codes.
  - PBT-08 (reproducibility): **Compliant (with documented limitation)** — seeded; seed + failing example
    reported on failure. Automatic shrinking not implemented (stdlib-only — documented technical reason).
  - PBT-09 (framework): **Compliant (documented deviation)** — stdlib `random`+pytest harness used instead
    of Hypothesis because the project mandates "standard library only — no third-party dependencies".
  - PBT-01/04/05/06/10: advisory in Partial mode — not blocking. (Idempotence PBT-04 is in fact covered.)

### Integration Tests (CLI ↔ core)
- **File**: `tests/test_cli.py`
- **Test Scenarios**: 8 — **Passed**: 8 — **Failed**: 0
- **Status**: Pass (single, JSON, stdin batch, exit codes 0/1, `--help`, unknown-country non-zero).

### Performance Tests
- **Status**: N/A — no performance requirements (see performance-test-instructions.md).

### Additional Tests
- **Contract Tests**: N/A (single unit, no inter-service contracts).
- **Security Tests**: N/A (Security Baseline extension opted out; offline utility, no external surface).
- **E2E Tests**: Covered by the CLI integration tests (full process invocation).

## Overall Status
- **Build**: Success
- **All Tests**: **56 passed, 0 failed** (`python -m pytest`)
- **Dependencies**: standard library only (AST-verified); runs under Python 3.9.6.
- **Ready for Operations**: Yes (Operations is a placeholder stage).

## Files Generated (build-and-test/)
- build-instructions.md
- unit-test-instructions.md
- integration-test-instructions.md
- performance-test-instructions.md
- build-and-test-summary.md

## Next Steps
All tests pass. The Operations phase is a placeholder; no deployment/monitoring work is in scope.
