# Contract: Command-Line Interface

Invoked as `python -m postal_validator ...`. Pinned by `tests/test_cli.py`.

## Command schema

```text
python -m postal_validator validate [CODE] --country CC [--json]
python -m postal_validator --help
```

- `validate` — the (only required) subcommand.
- `CODE` — positional, **optional**. When omitted, codes are read from stdin (one per line) → batch mode.
- `--country CC` — required; one of `CA`/`US`/`UK`, case-insensitive.
- `--json` — optional flag; emit a structured JSON object instead of plain text.
- `--help` — print usage and exit 0 (provided by argparse).

## Exit codes

| Situation | Exit code |
|-----------|-----------|
| Single valid code | `0` |
| Single invalid code | `1` |
| Batch: every line valid | `0` |
| Batch: ≥1 invalid line | `1` |
| Unsupported country | non-zero (`1`) |
| `--help` | `0` |

## Output formats

### Single code, plain (no `--json`)

- Valid → print the **canonical normalized form** to stdout; exit 0.
  - `validate k1a0b1 --country CA` → stdout `K1A 0B1`, exit 0.
- Invalid → print a short reason to stderr (stdout stays clean); exit 1.
  - `validate "D1A 0B1" --country CA` → exit 1.

### Single code, `--json`

- Print one JSON object to stdout with at least `valid` and `normalized` (include `error` too); exit reflects validity.
  - Valid: `{"valid": true, "normalized": "12345", "error": null}` → exit 0.
  - Invalid: `{"valid": false, "normalized": null, "error": "..."}` → exit 1.

### Batch (stdin, no CODE arg)

- One output line per input line, in input order:
  - valid line → its canonical normalized form,
  - invalid line → text containing the word `INVALID` (case-insensitive match by tests; reason may be appended).
- Exit 0 only if all lines valid, else 1.
- `--json` in batch mode (not asserted by tests): emit one JSON object per line (JSON Lines) — chosen for consistency; safe because untested.

## Contract test mapping (`tests/test_cli.py`)

| Behavior | Test |
|----------|------|
| Valid prints normalized, exit 0 | `test_valid_prints_normalized_and_exits_zero` |
| Invalid exits 1 | `test_invalid_exits_one` |
| `--json` valid → parseable, `valid=true`, `normalized` set, exit 0 | `test_json_valid` |
| `--json` invalid → parseable, `valid=false`, exit 1 | `test_json_invalid` |
| Batch mixed → first line normalized, second line `INVALID`, exit 1 | `test_batch_stdin_mixed_exits_one` |
| Batch all-valid → exit 0 | `test_batch_stdin_all_valid_exits_zero` |
| `--help` → `usage` in stdout, exit 0 | `test_help_exits_zero` |
| Unknown country → exit non-zero | `test_unknown_country_exits_nonzero` |

## Notes

- argparse prints `--help` to stdout and exits 0; the usage-text test reads stdout, so rely on the default behavior (do not redirect help to stderr).
- An argparse usage error (e.g. missing `--country`) exits with code 2, which is non-zero and consistent with the contract.
