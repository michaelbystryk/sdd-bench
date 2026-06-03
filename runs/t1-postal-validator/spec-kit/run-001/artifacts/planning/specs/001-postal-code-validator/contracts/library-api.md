# Contract: Library API (`postal_validator`)

The public surface importable from the package root. Mirrors the API contract in `reference/formats.md` and the assertions in `tests/test_core.py`.

## Exports

```python
from postal_validator import validate, normalize, ValidationResult
```

`postal_validator/__init__.py` MUST export exactly these three names (at minimum).

## `validate(code: str, country: str) -> ValidationResult`

Validate `code` for `country`.

- `country` is matched case-insensitively against `{"CA", "US", "UK"}`. Any other value → invalid result (do **not** raise).
- Leading/trailing whitespace in `code` is ignored; matching is case-insensitive.
- Returns a `ValidationResult`:
  - valid input → `valid=True`, `normalized=<canonical form>`, `error=None`
  - invalid input → `valid=False`, `normalized=None`, `error=<short reason>` (non-empty)

**Guarantees**
- Never raises for any string inputs (FR-019). Unsupported country, malformed code, empty string → invalid result, not an exception.
- `isinstance(validate(...), ValidationResult)` is `True`.

## `normalize(code: str, country: str) -> str`

Return the canonical form for valid input; **raise `ValueError`** for invalid input (including unsupported country).

- Equivalent to: `r = validate(code, country); return r.normalized if r.valid else raise ValueError(r.error)`.

## `ValidationResult`

```python
@dataclass(frozen=True)
class ValidationResult:
    valid: bool
    normalized: str | None = None
    error: str | None = None
```

- `valid` — bool.
- `normalized` — canonical string iff `valid`, else `None`.
- `error` — short human-readable reason iff not `valid`, else `None`.

## Canonical forms (must match exactly)

| Country | Input examples | Canonical output |
|---------|----------------|------------------|
| CA | `K1A 0B1`, `k1a0b1`, ` M5V 3L9 `, `H0H0H0` | `K1A 0B1`, `K1A 0B1`, `M5V 3L9`, `H0H 0H0` |
| US | `12345`, `12345-6789`, ` 90210 ` | `12345`, `12345-6789`, `90210` |
| UK | `EC1A 1BB`, `ec1a1bb`, `M1 1AE`, ` sw1a 1aa ` | `EC1A 1BB`, `EC1A 1BB`, `M1 1AE`, `SW1A 1AA` |

## Contract test mapping (`tests/test_core.py`)

| Behavior | Test |
|----------|------|
| Valid codes accepted + exact normalized form | `test_valid_codes` (parametrized `VALID`) |
| Invalid codes rejected with non-empty `error`, `normalized is None` | `test_invalid_codes` (parametrized `INVALID`) |
| Return type is `ValidationResult` | `test_validation_result_type` |
| Country case-insensitive | `test_country_is_case_insensitive` |
| Unsupported country → invalid, not exception | `test_unsupported_country_is_invalid_not_error` |
| `normalize` returns canonical for valid | `test_normalize_valid` |
| `normalize` raises `ValueError` for invalid | `test_normalize_invalid_raises_valueerror` |
