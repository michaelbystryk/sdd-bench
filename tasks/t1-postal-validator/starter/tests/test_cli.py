"""CLI integration tests.

The CLI is invoked as ``python -m postal_validator``. These tests pin the
command contract (exit codes, plain + JSON output, stdin batch mode) without
mandating a particular argument-parsing library.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def run(args, stdin=None):
    return subprocess.run(
        [sys.executable, "-m", "postal_validator", *args],
        input=stdin,
        capture_output=True,
        text=True,
        cwd=ROOT,
    )


def test_valid_prints_normalized_and_exits_zero():
    r = run(["validate", "k1a0b1", "--country", "CA"])
    assert r.returncode == 0
    assert r.stdout.strip() == "K1A 0B1"


def test_invalid_exits_one():
    r = run(["validate", "D1A 0B1", "--country", "CA"])
    assert r.returncode == 1


def test_json_valid():
    r = run(["validate", "12345", "--country", "US", "--json"])
    assert r.returncode == 0
    data = json.loads(r.stdout)
    assert data["valid"] is True
    assert data["normalized"] == "12345"


def test_json_invalid():
    r = run(["validate", "1234", "--country", "US", "--json"])
    assert r.returncode == 1
    data = json.loads(r.stdout)
    assert data["valid"] is False


def test_batch_stdin_mixed_exits_one():
    r = run(["validate", "--country", "CA"], stdin="K1A 0B1\nD1A 0B1\n")
    assert r.returncode == 1
    lines = r.stdout.strip().splitlines()
    assert lines[0] == "K1A 0B1"
    assert "INVALID" in lines[1].upper()


def test_batch_stdin_all_valid_exits_zero():
    r = run(["validate", "--country", "US"], stdin="12345\n90210\n")
    assert r.returncode == 0


def test_help_exits_zero():
    r = run(["--help"])
    assert r.returncode == 0
    assert "usage" in r.stdout.lower()


def test_unknown_country_exits_nonzero():
    r = run(["validate", "12345", "--country", "FR"])
    assert r.returncode != 0
