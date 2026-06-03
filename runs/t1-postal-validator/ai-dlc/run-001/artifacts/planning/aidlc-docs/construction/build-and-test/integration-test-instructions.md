# Integration Test Instructions

## Purpose
There is a single unit (`postal-validator-core`), so "integration" here means the **CLI ↔ core
library** boundary: the `python -m postal_validator` process wiring, argument parsing, stdin batch
handling, output formats, and exit codes. These are covered by `tests/test_cli.py`, which invokes
the CLI as a real subprocess.

## Test Scenarios (covered by tests/test_cli.py)
| Scenario | Input | Expected |
|---|---|---|
| Single valid | `validate k1a0b1 --country CA` | stdout `K1A 0B1`, exit 0 |
| Single invalid | `validate "D1A 0B1" --country CA` | exit 1 |
| JSON valid | `validate 12345 --country US --json` | JSON `valid=true, normalized="12345"`, exit 0 |
| JSON invalid | `validate 1234 --country US --json` | JSON `valid=false`, exit 1 |
| Batch mixed (stdin) | `validate --country CA` ⇐ `K1A 0B1\nD1A 0B1\n` | line0 `K1A 0B1`, line1 contains `INVALID`, exit 1 |
| Batch all valid (stdin) | `validate --country US` ⇐ `12345\n90210\n` | exit 0 |
| Help | `--help` | usage text, exit 0 |
| Unknown country | `validate 12345 --country FR` | exit non-zero |

## Run Integration Tests
```bash
python -m pytest tests/test_cli.py -q
```
No services, network, or environment setup required (the CLI is offline and self-contained).

### Manual spot-checks
```bash
python -m postal_validator validate k1a0b1 --country CA          # -> K1A 0B1   (exit 0)
python -m postal_validator validate 1234 --country US --json     # -> {...valid:false...} (exit 1)
printf 'K1A 0B1\nD1A 0B1\n' | python -m postal_validator validate --country CA   # mixed (exit 1)
echo $?
```

### Cleanup
None required.
