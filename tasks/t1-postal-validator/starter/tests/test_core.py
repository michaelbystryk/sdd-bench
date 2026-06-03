"""Core-logic tests for validate() / normalize().

The behavior is fully specified by reference/formats.md.
"""

from __future__ import annotations

import pytest

from postal_validator import ValidationResult, normalize, validate

# (code, country, expected_normalized)
VALID = [
    # Canada
    ("K1A 0B1", "CA", "K1A 0B1"),
    ("k1a0b1", "CA", "K1A 0B1"),
    (" M5V 3L9 ", "CA", "M5V 3L9"),
    ("H0H0H0", "CA", "H0H 0H0"),
    # United States
    ("12345", "US", "12345"),
    ("12345-6789", "US", "12345-6789"),
    (" 90210 ", "US", "90210"),
    # United Kingdom
    ("EC1A 1BB", "UK", "EC1A 1BB"),
    ("W1A 0AX", "UK", "W1A 0AX"),
    ("M1 1AE", "UK", "M1 1AE"),
    ("B33 8TH", "UK", "B33 8TH"),
    ("CR2 6XH", "UK", "CR2 6XH"),
    ("DN55 1PT", "UK", "DN55 1PT"),
    ("ec1a1bb", "UK", "EC1A 1BB"),
    (" sw1a 1aa ", "UK", "SW1A 1AA"),
]

# (code, country)
INVALID = [
    # Canada — excluded letters / bad shape
    ("D1A 0B1", "CA"),  # first letter D excluded
    ("W1A 0B1", "CA"),  # first letter W excluded
    ("Z1A 0B1", "CA"),  # first letter Z excluded
    ("K1D 0B1", "CA"),  # interior letter D excluded
    ("K1A 0B", "CA"),   # too short
    ("11A 0B1", "CA"),  # digit where a letter is required
    ("K1A 0B1X", "CA"),  # too long
    # United States
    ("1234", "US"),       # too few digits
    ("123456", "US"),     # too many digits
    ("123456789", "US"),  # 9 digits, no hyphen
    ("1234A", "US"),      # letter present
    ("12345-678", "US"),  # +4 part too short
    ("12345 6789", "US"),  # internal whitespace
    # United Kingdom
    ("EC1A 1CB", "UK"),  # inward letter C excluded
    ("EC1A 1IO", "UK"),  # inward letters I, O excluded
    ("1A1 1AA", "UK"),   # outward starts with a digit
    ("ABCD 1AA", "UK"),  # outward all letters
    ("EC1A 1B", "UK"),   # too short / malformed inward
]


@pytest.mark.parametrize("code,country,expected", VALID)
def test_valid_codes(code, country, expected):
    r = validate(code, country)
    assert r.valid is True
    assert r.normalized == expected
    assert r.error is None


@pytest.mark.parametrize("code,country", INVALID)
def test_invalid_codes(code, country):
    r = validate(code, country)
    assert r.valid is False
    assert r.normalized is None
    assert r.error  # a non-empty reason string


def test_validation_result_type():
    assert isinstance(validate("12345", "US"), ValidationResult)


def test_country_is_case_insensitive():
    assert validate("12345", "us").valid is True
    assert validate("k1a0b1", "ca").valid is True


def test_unsupported_country_is_invalid_not_error():
    r = validate("12345", "FR")
    assert r.valid is False
    assert r.error


def test_normalize_valid():
    assert normalize("k1a0b1", "CA") == "K1A 0B1"
    assert normalize("ec1a1bb", "UK") == "EC1A 1BB"
    assert normalize(" 90210 ", "US") == "90210"


def test_normalize_invalid_raises_valueerror():
    with pytest.raises(ValueError):
        normalize("D1A 0B1", "CA")
    with pytest.raises(ValueError):
        normalize("1234", "US")
