# Postal-code format rules (CA / US / UK)

These are the **exact, complete** rules the validator must enforce. Where a real-world rule is more elaborate (especially UK), the simplified rule below is the one that counts; do not add constraints beyond what is stated here.

Validation is **case-insensitive** and ignores **leading/trailing whitespace**. Normalization always returns the canonical uppercased form with a single separating space where applicable.

---

## Canada (`CA`)

**Format:** `ANA NAN` — letter, digit, letter, (optional single space), digit, letter, digit. Six alphanumeric characters total.

**Letter restrictions:**
- Letters never include `D F I O Q U` (in any position).
- The **first** letter additionally excludes `W` and `Z`.
- So: first letter ∈ `A B C E G H J K L M N P R S T V X Y`; the other two letters ∈ `A B C E G H J K L M N P R S T V W X Y Z`.

**Digits:** `0`–`9` in all three digit positions.

**Whitespace:** the space between the third and fourth characters is optional on input (`K1A 0B1` and `K1A0B1` are both accepted).

**Normalized form:** uppercase, single space in the middle — e.g. `K1A 0B1`.

---

## United States (`US`)

**Format:** `NNNNN` (5-digit ZIP) **or** `NNNNN-NNNN` (ZIP+4). Digits only; the `+4` part, if present, must be preceded by a hyphen.

**Invalid:** fewer or more than 5 leading digits; a 9-digit string with no hyphen (`123456789`); any letters; internal whitespace.

**Normalized form:** the trimmed input unchanged — e.g. `90210`, `12345-6789`.

---

## United Kingdom (`UK`)

**Format:** an **outward** code, a separating space, then a 3-character **inward** code. The space is optional on input; the inward code is always the final three characters.

- **Outward** matches `^[A-Z]{1,2}[0-9][A-Z0-9]?$` — i.e. 1–2 letters, a digit, then optionally one more letter or digit. (Covers `M1`, `B33`, `CR2`, `W1A`, `EC1A`, `DN55`.)
- **Inward** matches `^[0-9][A-Z]{2}$` — a digit followed by two letters.
- The two inward letters must **not** be `C I K M O V`.

> This is a deliberately simplified UK rule set. Enforce exactly these three constraints — no more.

**Normalized form:** uppercase, single space before the final three characters — e.g. `EC1A 1BB`, `M1 1AE`.

---

## API contract

```python
validate(code: str, country: str) -> ValidationResult
normalize(code: str, country: str) -> str
```

- `country` is one of `"CA"`, `"US"`, `"UK"` (case-insensitive). Any other value → an invalid result (do not raise).
- `ValidationResult` must expose:
  - `.valid: bool`
  - `.normalized: str | None` — the canonical form if valid, else `None`
  - `.error: str | None` — a short human-readable reason if invalid, else `None`
- `normalize()` returns the canonical string for valid input and **raises `ValueError`** for invalid input.
- No third-party dependencies — standard library only.
