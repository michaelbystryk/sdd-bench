# Phase 1 Data Model: Postal-Code Validator + CLI

This feature has no persistent storage. The "data model" is the small set of in-memory value objects and the per-country rule definitions.

## Entity: ValidationResult

The outcome of validating one code against one country. Exported from the package root.

| Field | Type | Meaning | Invariant |
|-------|------|---------|-----------|
| `valid` | `bool` | Whether the code is valid for the country | — |
| `normalized` | `str \| None` | Canonical form when valid, else `None` | non-`None` **iff** `valid is True` |
| `error` | `str \| None` | Short human-readable reason when invalid, else `None` | non-`None` **iff** `valid is False` |

**Representation**: frozen dataclass. Two convenience constructors keep the invariants un-violatable:
- `ok(normalized)` → `ValidationResult(valid=True, normalized=normalized, error=None)`
- `fail(error)` → `ValidationResult(valid=False, normalized=None, error=error)`

**Validation rules** (from spec FR-001, `reference/formats.md` API contract): exactly the three attributes above must be present and accessible; `isinstance(validate(...), ValidationResult)` must hold.

## Entity: CountryRule (internal)

The per-country definition that drives validation and normalization. One instance per supported country, held in a lookup table keyed by the uppercased country code.

| Field | Type | Meaning |
|-------|------|---------|
| `code` | `str` | `"CA"`, `"US"`, or `"UK"` |
| `pattern` | `re.Pattern` | Precompiled regex for the structural shape (case-insensitive, applied to the trimmed input) |
| `check_extra` | callable | Extra constraints not in the regex (e.g. CA first-letter exclusions, UK inward-letter exclusions); returns ok / reason |
| `normalize` | callable | Maps a trimmed, validated input to its canonical form |

**Supported set**: `{CA, US, UK}`. Country lookup is case-insensitive (FR-003). A miss yields an invalid result (FR-004), never a raise.

### Rule details (derived from `reference/formats.md`)

**Canada (`CA`)** — shape `ANA NAN`, six alphanumerics, optional single internal space:
- Letters never include `D F I O Q U`.
- First letter additionally excludes `W Z` → first ∈ `A B C E G H J K L M N P R S T V X Y`; other two ∈ `A B C E G H J K L M N P R S T V W X Y Z`.
- Digits `0`–`9` in all three digit positions.
- Canonical: uppercase, single space after 3rd char → `K1A 0B1`.

**United States (`US`)** — `NNNNN` or `NNNNN-NNNN`:
- Exactly 5 leading digits; optional `+4` of exactly 4 digits, only when preceded by a hyphen.
- Reject: ≠5 leading digits, 9 digits with no hyphen, any letters, internal whitespace.
- Canonical: trimmed input unchanged → `90210`, `12345-6789`.

**United Kingdom (`UK`)** — outward + (optional space) + 3-char inward:
- Outward `^[A-Z]{1,2}[0-9][A-Z0-9]?$`.
- Inward `^[0-9][A-Z]{2}$`.
- Inward two letters must **not** be `C I K M O V`.
- Inward code is always the final three characters.
- Canonical: uppercase, single space before final three chars → `EC1A 1BB`, `M1 1AE`.

## Entity: Postal code (input)

A raw user-supplied string. May contain surrounding whitespace and any letter casing; CA/UK may include or omit the internal separator. Pre-processing for all countries: strip leading/trailing whitespace, then uppercase for matching (US matching is digit-only so casing is moot). Internal whitespace is **not** stripped and is significant (US rejects it; CA/UK collapse only the single optional separator via the normalization step).

## Relationships

- `validate(code, country)` selects one `CountryRule` by `country` → returns one `ValidationResult`.
- `normalize(code, country)` reuses `validate`; on `valid` returns `result.normalized`, otherwise raises `ValueError(result.error)`.
- The CLI maps each input (single arg or one stdin line) to a `ValidationResult` and renders it (plain or `--json`), then derives the process exit code from validity.

## State & lifecycle

Stateless. No transitions, no persistence. `CountryRule` instances and compiled patterns are module-level constants built once at import.
