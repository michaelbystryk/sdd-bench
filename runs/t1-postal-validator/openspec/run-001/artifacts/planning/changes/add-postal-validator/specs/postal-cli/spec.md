## ADDED Requirements

### Requirement: Single-code validation command

The CLI SHALL be invocable as `python -m postal_validator validate <code> --country <CC>`. For a single code, it SHALL print the normalized form to stdout and exit `0` when valid, and exit `1` when invalid.

#### Scenario: Valid single code prints normalized and exits zero

- **WHEN** `validate k1a0b1 --country CA` is run
- **THEN** stdout (trimmed) is `K1A 0B1` and the exit code is `0`

#### Scenario: Invalid single code exits one

- **WHEN** `validate "D1A 0B1" --country CA` is run
- **THEN** the exit code is `1`

### Requirement: JSON output

The CLI SHALL support a `--json` flag that, for single-code validation, prints a single JSON object containing at least `valid` and `normalized` fields. The exit code SHALL still reflect validity (`0` valid, `1` invalid).

#### Scenario: JSON for valid code

- **WHEN** `validate 12345 --country US --json` is run
- **THEN** stdout parses as JSON with `valid` `true` and `normalized` `"12345"`, and the exit code is `0`

#### Scenario: JSON for invalid code

- **WHEN** `validate 1234 --country US --json` is run
- **THEN** stdout parses as JSON with `valid` `false`, and the exit code is `1`

### Requirement: Batch validation from stdin

When no code argument is given, the CLI SHALL read codes from stdin, one per line, and validate each against `--country`. It SHALL print one output line per input line — the normalized code when valid, otherwise a line whose text contains `INVALID`. The exit code SHALL be `0` only if every line is valid, otherwise `1`.

#### Scenario: Mixed batch exits one with per-line output

- **WHEN** `validate --country CA` is run with stdin `"K1A 0B1\nD1A 0B1\n"`
- **THEN** the first output line is `K1A 0B1`, the second output line contains `INVALID` (case-insensitive), and the exit code is `1`

#### Scenario: All-valid batch exits zero

- **WHEN** `validate --country US` is run with stdin `"12345\n90210\n"`
- **THEN** the exit code is `0`

### Requirement: Help and unknown-country handling

The CLI SHALL provide `--help` output containing the word `usage` and exit `0`. An unknown country SHALL cause a non-zero exit.

#### Scenario: Help exits zero

- **WHEN** `--help` is run
- **THEN** stdout (case-insensitive) contains `usage` and the exit code is `0`

#### Scenario: Unknown country exits non-zero

- **WHEN** `validate 12345 --country FR` is run
- **THEN** the exit code is non-zero
