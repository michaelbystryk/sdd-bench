# Feature Specification: Postal-Code Validator + CLI

**Feature Branch**: `001-postal-code-validator`

**Created**: 2026-05-27

**Status**: Draft

**Input**: User description: "Implement a Python package `postal_validator` that validates and normalizes postal codes for Canada, the US, and the UK per the rules in `reference/formats.md`, plus a small command-line interface for it."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Validate a single postal code (Priority: P1)

A developer (or an automated workflow) submits one postal code together with a country and receives a clear answer: is it valid, and if not, why not. This is the core capability the whole feature exists to provide.

**Why this priority**: Without trustworthy validation there is no product. Every other capability (normalization, batch mode, machine-readable output) builds on top of a correct yes/no decision and a usable reason for rejection.

**Independent Test**: Provide a known-good code and a known-bad code for each of CA, US, and UK; confirm that the good codes are accepted and the bad codes are rejected with a non-empty reason. Delivers value on its own as a checkable validity oracle.

**Acceptance Scenarios**:

1. **Given** the code `K1A 0B1` and country `CA`, **When** it is validated, **Then** the result is valid with no error.
2. **Given** the code `D1A 0B1` and country `CA`, **When** it is validated, **Then** the result is invalid with a short human-readable reason.
3. **Given** a code and an unsupported country such as `FR`, **When** it is validated, **Then** the result is invalid with a reason — and no exception is raised.
4. **Given** the same code with the country given in lowercase (`us`, `ca`, `uk`), **When** it is validated, **Then** validation behaves identically to the uppercase form.
5. **Given** a code padded with leading/trailing whitespace or in mixed case, **When** it is validated, **Then** the padding and case are ignored when deciding validity.

---

### User Story 2 - Normalize a code to its canonical form (Priority: P2)

A user takes a messy-but-valid code (lowercase, no internal space, padded with whitespace) and obtains the single canonical representation for storage, comparison, or display.

**Why this priority**: Canonicalization makes downstream comparison and storage reliable. It depends on validation already working, so it follows P1, but it is the second-most-valuable outcome.

**Independent Test**: Feed several equivalent spellings of the same valid code and confirm they all produce one identical canonical string; feed an invalid code and confirm canonicalization refuses it loudly.

**Acceptance Scenarios**:

1. **Given** `k1a0b1` and country `CA`, **When** it is normalized, **Then** the result is `K1A 0B1`.
2. **Given** `ec1a1bb` and country `UK`, **When** it is normalized, **Then** the result is `EC1A 1BB`.
3. **Given** ` 90210 ` and country `US`, **When** it is normalized, **Then** the result is `90210`.
4. **Given** an invalid code, **When** normalization is requested, **Then** the operation fails loudly (raises an error) rather than returning a guessed value.

---

### User Story 3 - Validate codes from the command line (Priority: P2)

An operator runs the tool from a shell to check a code, scripts around its exit status, and optionally requests machine-readable output.

**Why this priority**: The CLI is the primary way humans and scripts reach the validator. It is co-equal in value with normalization because it is how the capability is actually consumed in practice.

**Independent Test**: Invoke the tool with a valid code and confirm it prints the canonical form and exits 0; invoke it with an invalid code and confirm a non-zero exit; request `--json` and confirm well-formed structured output; request `--help` and confirm usage text with a zero exit.

**Acceptance Scenarios**:

1. **Given** the command-line invocation with a valid code and its country, **When** it runs, **Then** it prints the canonical normalized form and exits with status `0`.
2. **Given** an invalid code, **When** it runs, **Then** it exits with status `1`.
3. **Given** the `--json` flag with a valid code, **When** it runs, **Then** standard output is parseable structured data reporting validity and the normalized value, and the exit status is `0`.
4. **Given** the `--json` flag with an invalid code, **When** it runs, **Then** standard output is parseable structured data reporting that the code is not valid, and the exit status is `1`.
5. **Given** `--help`, **When** it runs, **Then** usage information is printed and the exit status is `0`.
6. **Given** an unsupported country on the command line, **When** it runs, **Then** the exit status is non-zero.

---

### User Story 4 - Batch-validate a list of codes from stdin (Priority: P3)

A user pipes a list of codes (one per line) into the tool without supplying a code argument and gets a per-line verdict, with an overall exit status that reflects whether every code passed.

**Why this priority**: Batch mode is a productivity multiplier over single-code validation, but it is strictly additive — the single-code path must work first.

**Independent Test**: Pipe a mix of valid and invalid codes and confirm each line gets a verdict and the overall exit status is non-zero; pipe an all-valid list and confirm a zero exit status.

**Acceptance Scenarios**:

1. **Given** no code argument and a country, **When** a list of codes is supplied on standard input (one per line), **Then** each line is validated and reported in input order.
2. **Given** a batch containing at least one invalid code, **When** it runs, **Then** valid lines show their canonical form, invalid lines are clearly marked as invalid, and the overall exit status is `1`.
3. **Given** a batch in which every code is valid, **When** it runs, **Then** the overall exit status is `0`.

---

### Edge Cases

- **Whitespace and case**: leading/trailing whitespace and any letter casing must never change a validity verdict; the canonical output is always uppercase with the prescribed single internal separator (or none, for US).
- **Optional internal space**: for CA and UK the separating space is optional on input (`K1A0B1` and `K1A 0B1` are both accepted) but always present in canonical output; for US the canonical form is the trimmed input unchanged.
- **Boundary lengths**: codes that are one character too short or too long for their country are rejected (e.g. CA `K1A 0B`, CA `K1A 0B1X`, US `1234`, US `123456`).
- **Wrong character class in a position**: a digit where a letter is required, or a letter where a digit is required, is rejected (e.g. CA `11A 0B1`, US `1234A`, UK outward `1A1 1AA`).
- **Country-specific letter exclusions**: CA excludes `D F I O Q U` in every letter position and additionally `W Z` in the first position; UK forbids the inward-code letters `C I K M O V`.
- **US 9-digit without hyphen**: `123456789` is rejected; the `+4` extension is only valid when preceded by a hyphen and exactly four digits long.
- **US internal whitespace**: `12345 6789` is rejected (internal whitespace is not allowed for US).
- **Unsupported country**: an unrecognized country code yields an invalid result with a reason from the library API, and a non-zero exit from the CLI — never an unhandled crash.
- **Empty stdin / blank lines**: behavior for blank input lines in batch mode must be predictable and must not crash (see Assumptions).

## Requirements *(mandatory)*

### Functional Requirements

#### Validation & normalization (library capability)

- **FR-001**: The system MUST provide a validation capability that, given a code and a country, returns a result exposing whether the code is valid, its canonical normalized form when valid (otherwise none), and a short human-readable reason when invalid (otherwise none).
- **FR-002**: The system MUST provide a normalization capability that, given a code and a country, returns the canonical normalized string for valid input and fails loudly (raises an error) for invalid input.
- **FR-003**: Country selection MUST be case-insensitive and MUST accept exactly `CA`, `US`, and `UK` (in any letter casing).
- **FR-004**: Any country value other than the three supported ones MUST produce an invalid result via the validation capability without raising an exception.
- **FR-005**: Validation MUST ignore leading and trailing whitespace and MUST be case-insensitive with respect to the code itself.
- **FR-006**: For Canada, the system MUST enforce the `ANA NAN` shape (letter, digit, letter, optional single space, digit, letter, digit), where the first letter is drawn from `A B C E G H J K L M N P R S T V X Y` and the remaining two letters from `A B C E G H J K L M N P R S T V W X Y Z`, and all digit positions are `0`–`9`.
- **FR-007**: For the United States, the system MUST accept a 5-digit ZIP (`NNNNN`) or a ZIP+4 (`NNNNN-NNNN`) where the four-digit extension is present only when preceded by a hyphen; it MUST reject any input with fewer or more than five leading digits, a nine-digit run without a hyphen, any letters, or internal whitespace.
- **FR-008**: For the United Kingdom, the system MUST accept an outward code matching 1–2 letters followed by a digit and then optionally one more letter or digit, a single (optional on input) separating space, and an inward code of one digit followed by two letters, where the two inward letters are never `C I K M O V`.
- **FR-009**: Canonical normalized output MUST be uppercase and MUST use the country's prescribed separator: a single internal space for CA (`K1A 0B1`) and UK (`EC1A 1BB`, `M1 1AE`), and the trimmed input unchanged for US (`90210`, `12345-6789`).
- **FR-010**: The system MUST implement only the rules stated in `reference/formats.md` and MUST NOT add real-world constraints beyond them.

#### Command-line interface

- **FR-011**: The system MUST provide a command-line interface, invoked as a `validate` subcommand, that takes a single code argument and a country option.
- **FR-012**: When given a single valid code, the CLI MUST print the canonical normalized form and exit with status `0`; when given an invalid code, it MUST exit with status `1`.
- **FR-013**: The CLI MUST support a `--json` option that emits parseable structured output reporting at least validity and the normalized value, while preserving the same exit-status semantics (`0` valid, `1` invalid).
- **FR-014**: When no code argument is supplied, the CLI MUST read codes from standard input (one per line), validate each against the given country, report a per-line verdict in input order, and exit `0` only if every code is valid (otherwise `1`).
- **FR-015**: In batch mode, valid lines MUST show their canonical form and invalid lines MUST be clearly marked as invalid (the marking is detectable case-insensitively as the word "INVALID").
- **FR-016**: The CLI MUST provide help/usage output (via `--help`) that prints usage text and exits with status `0`.
- **FR-017**: When given an unsupported country, the CLI MUST exit with a non-zero status.

#### Constraints

- **FR-018**: The system MUST use the standard library only and MUST NOT depend on any third-party package.
- **FR-019**: Invalid input MUST be rejected cleanly — without unhandled exceptions or stack traces leaking to the user — across both the library and CLI surfaces.

### Key Entities *(include if feature involves data)*

- **ValidationResult**: the outcome of validating one code. Attributes: `valid` (true/false), `normalized` (the canonical string when valid, otherwise none), `error` (a short human-readable reason when invalid, otherwise none).
- **Country format rule**: the per-country definition of accepted shape, allowed character classes and letter exclusions, and the canonical normalized form. Supported countries: Canada (`CA`), United States (`US`), United Kingdom (`UK`).
- **Postal code (input)**: a user-supplied string that may carry surrounding whitespace and arbitrary casing, with an optional internal separator for CA and UK.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of the codes listed as valid in `reference/formats.md` (and the project test suite) are accepted with their exact prescribed canonical form, and 100% of the listed invalid codes are rejected with a non-empty reason.
- **SC-002**: Every supported country (CA, US, UK) is validated correctly regardless of the casing of the country selector and regardless of surrounding whitespace or letter casing in the code.
- **SC-003**: A user can determine a single code's validity from the command line and branch a script on the result using only the process exit status (`0` valid, `1` invalid), with no need to parse text.
- **SC-004**: A user can validate an arbitrarily long list of codes in one invocation via standard input and receive one verdict per input line plus a single overall pass/fail exit status.
- **SC-005**: Machine consumers can obtain a structured (`--json`) verdict that parses without error and reports validity and the normalized value.
- **SC-006**: The tool runs with a stock standard-library installation only — no third-party packages need to be installed for it to work.
- **SC-007**: No supported input — valid, invalid, malformed, or an unsupported country — causes an unhandled crash on either the library or CLI surface.

## Assumptions

- **Supported scope is exactly three countries** (CA, US, UK); other country codes are intentionally out of scope and resolve to an invalid result rather than an error.
- **The rules in `reference/formats.md` are authoritative and complete.** Where real-world postal formats are more elaborate (notably the UK), the simplified rule set in that document is the one enforced, and no additional constraints are added.
- **Canonical US form is the trimmed input unchanged** (US codes are digits/hyphen only, so casing is moot; only surrounding whitespace is stripped).
- **Batch mode activates only when no positional code argument is provided.** Supplying both a code and piped input is not a defined combination; the explicit code argument takes precedence.
- **Blank or whitespace-only input lines in batch mode** are treated as a code to validate (and therefore reported invalid) rather than silently skipped, keeping per-line output aligned with input lines. This is a reasonable default and can be revisited if a different policy is desired.
- **Human-readable error reasons are short, English, and intended for diagnostics**, not localized end-user messaging.
- **The CLI exit-code contract is binary on the validity dimension** (`0` valid / `1` invalid); usage errors such as an unsupported country also produce a non-zero exit.
