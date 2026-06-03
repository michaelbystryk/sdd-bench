## ADDED Requirements

### Requirement: Structured validation result

The library SHALL expose `validate(code: str, country: str) -> ValidationResult`, where `ValidationResult` exposes `.valid: bool`, `.normalized: str | None` (the canonical form when valid, else `None`), and `.error: str | None` (a short human-readable reason when invalid, else `None`). `validate` SHALL NOT raise for any string input or unsupported country.

#### Scenario: Valid code returns populated result

- **WHEN** `validate("12345", "US")` is called
- **THEN** the result `.valid` is `True`, `.normalized` is `"12345"`, and `.error` is `None`
- **AND** the result is an instance of `ValidationResult`

#### Scenario: Invalid code returns a reason

- **WHEN** `validate("1234", "US")` is called
- **THEN** the result `.valid` is `False`, `.normalized` is `None`, and `.error` is a non-empty string

### Requirement: Case-insensitive, whitespace-tolerant input

The library SHALL accept the `country` argument case-insensitively and SHALL ignore leading and trailing whitespace in `code`. The CA middle space and UK inward-code space SHALL be optional on input.

#### Scenario: Lowercase country and code

- **WHEN** `validate("k1a0b1", "ca")` is called
- **THEN** the result `.valid` is `True` and `.normalized` is `"K1A 0B1"`

#### Scenario: Surrounding whitespace ignored

- **WHEN** `validate(" 90210 ", "US")` is called
- **THEN** the result `.valid` is `True` and `.normalized` is `"90210"`

### Requirement: normalize returns canonical form or raises

The library SHALL expose `normalize(code: str, country: str) -> str` that returns the canonical normalized string for valid input and raises `ValueError` for invalid input (including unsupported countries).

#### Scenario: Normalize valid input

- **WHEN** `normalize("ec1a1bb", "UK")` is called
- **THEN** it returns `"EC1A 1BB"`

#### Scenario: Normalize invalid input raises

- **WHEN** `normalize("D1A 0B1", "CA")` is called
- **THEN** it raises `ValueError`

### Requirement: Unsupported country is invalid, not an error

When `country` is not one of `CA`, `US`, `UK` (case-insensitive), `validate` SHALL return a result with `.valid` `False` and a non-empty `.error`, without raising.

#### Scenario: Unknown country code

- **WHEN** `validate("12345", "FR")` is called
- **THEN** the result `.valid` is `False` and `.error` is a non-empty string

### Requirement: Canada postal-code rules

The library SHALL validate Canadian codes as `ANA NAN` (six alphanumerics with an optional single middle space). The first letter SHALL be one of `A B C E G H J K L M N P R S T V X Y`; the other two letters SHALL be one of `A B C E G H J K L M N P R S T V W X Y Z`; all three digit positions SHALL be `0`–`9`. The normalized form SHALL be uppercase with a single space in the middle.

#### Scenario: Accepts spaced and unspaced forms

- **WHEN** `validate("K1A 0B1", "CA")` and `validate("k1a0b1", "CA")` are called
- **THEN** both are valid and normalize to `"K1A 0B1"`

#### Scenario: Rejects excluded first letters

- **WHEN** any of `validate("D1A 0B1", "CA")`, `validate("W1A 0B1", "CA")`, `validate("Z1A 0B1", "CA")` is called
- **THEN** the result is invalid

#### Scenario: Rejects excluded interior letter and bad shape

- **WHEN** any of `validate("K1D 0B1", "CA")`, `validate("K1A 0B", "CA")`, `validate("11A 0B1", "CA")`, `validate("K1A 0B1X", "CA")` is called
- **THEN** the result is invalid

### Requirement: United States postal-code rules

The library SHALL validate US codes as a 5-digit ZIP (`NNNNN`) or ZIP+4 (`NNNNN-NNNN`); the `+4` part, when present, SHALL be preceded by a hyphen. Anything with fewer or more than 5 leading digits, a 9-digit string without a hyphen, any letter, or internal whitespace SHALL be invalid. The normalized form SHALL be the trimmed input unchanged.

#### Scenario: Accepts ZIP and ZIP+4

- **WHEN** `validate("12345", "US")` and `validate("12345-6789", "US")` are called
- **THEN** both are valid and normalize to themselves (trimmed)

#### Scenario: Rejects malformed US codes

- **WHEN** any of `validate("1234", "US")`, `validate("123456", "US")`, `validate("123456789", "US")`, `validate("1234A", "US")`, `validate("12345-678", "US")`, `validate("12345 6789", "US")` is called
- **THEN** the result is invalid

### Requirement: United Kingdom postal-code rules

The library SHALL validate UK codes where the inward code is the final three characters matching `^[0-9][A-Z]{2}$`, the remaining outward code matches `^[A-Z]{1,2}[0-9][A-Z0-9]?$`, and the separating space is optional on input. The two inward letters SHALL NOT be any of `C I K M O V`. The normalized form SHALL be uppercase with a single space before the final three characters.

#### Scenario: Accepts varied valid UK codes

- **WHEN** `validate("EC1A 1BB", "UK")`, `validate("M1 1AE", "UK")`, `validate("DN55 1PT", "UK")`, and `validate("ec1a1bb", "UK")` are called
- **THEN** all are valid and normalize with a single space before the final three characters (e.g. `"EC1A 1BB"`, `"M1 1AE"`)

#### Scenario: Rejects excluded inward letters and bad shape

- **WHEN** any of `validate("EC1A 1CB", "UK")`, `validate("EC1A 1IO", "UK")`, `validate("1A1 1AA", "UK")`, `validate("ABCD 1AA", "UK")`, `validate("EC1A 1B", "UK")` is called
- **THEN** the result is invalid
