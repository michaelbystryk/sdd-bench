# P8 — Answer Key (SEALED, HARNESS-ONLY)

**Never seed this file into any cell directory.** Planted-truth task, fully
objective: there is exactly ONE injected bug, and the deliverable either names
the right line + mechanism or it does not.

The vendored library is `python-slugify` (the `slugify` package), MIT-licensed,
upstream commit `7b6d5d96c1995e6dccb39a19a13ba78d7d0a3ee4` (version 8.0.4). One
single-line regression was injected into `smart_truncate`. Everything else
in `reference/` is the unmodified upstream source and test suite, and the test
suite passes as vendored (82 tests OK) — so "why did the tests miss it" has a
real, verifiable answer.

Line references are to `reference/slugify/slugify.py` as vendored.

---

### K1 — Boundary off-by-one in `smart_truncate`'s no-separator word-boundary branch [moderate]

- What it is: In `smart_truncate`, the branch that handles a string containing no
  separator while `word_boundary=True` computes its slice bound with a `cutoff`
  local that is one short *only when the input length equals `max_length` exactly*.
  The vendored code is:

  ```python
  # reference/slugify/slugify.py, lines 55-57
  if separator not in string:
      cutoff = max_length if len(string) > max_length else len(string) - 1
      return string[:cutoff]
  ```

  The correct (upstream) code is the single line `return string[:max_length]`. The
  injected ternary equals upstream for the `len(string) > max_length` arm, but the
  `else` arm — reached *only* when `len(string) == max_length`, because
  `len(string) < max_length` already returned at line 49 — uses `len(string) - 1`,
  one character too few. There is no literal `string[:max_length - 1]` anywhere; the
  off-by-one lives in the `else len(string) - 1` arm of the `cutoff` expression.

- Where detectable: `reference/slugify/slugify.py:56` (the `cutoff` assignment, the
  `else len(string) - 1` arm) feeding the `string[:cutoff]` slice on line 57, inside
  `smart_truncate` (function begins at line 27). Reachable from the brief's
  reproduction: `slugify('newsletter', max_length=10, word_boundary=True)` flows
  through `slugify(...)`; the `max_length > 0` tail calls
  `smart_truncate(text, 10, True, '-', False)`. In `smart_truncate`: `'newsletter'`
  has length 10, so line 49 `len(string) < max_length` (`10 < 10`) is False and does
  NOT return early; line 52 `not word_boundary` is False; line 55 `separator not in
  string` is True (`-` absent), so the `cutoff` line runs with `len(string) > max_length`
  (`10 > 10`) False, giving `cutoff = len(string) - 1 = 9`, hence `string[:9]` =
  `'newslette'`, the 9-character symptom. The bug fires only at the length boundary:
  with `max_length=8` the string is *longer* than the cap (`10 > 8` True) so
  `cutoff = max_length = 8` and the result is the correct 8 chars; with the much
  longer `'supercalifragilistic'` (len 20) and `max_length=10`, `20 > 10` is True,
  `cutoff = 10`, correct `'supercalif'`. With `word_boundary=False` (the brief's
  contrast), control returns at line 53 via `string[:max_length]` (no `cutoff`),
  also correct. That cluster (short cap fine, over-length word fine, boundary-length
  word broken, only on the word-boundary path) is the fingerprint of this branch.

- Minimum credit: The deliverable must (a) locate the responsible code as the
  `separator not in string` branch inside `smart_truncate` and specifically the
  `cutoff` computation (the `else len(string) - 1` arm / the `string[:cutoff]` slice
  it feeds), citing `slugify.py` line ~56-57 or unambiguously quoting that code; AND
  (b) state the mechanism INCLUDING its exact trigger: the slice takes
  `len(string) - 1` characters instead of `len(string)` (= `max_length`) precisely
  when the no-separator input's length equals `max_length` (so `len(string) > max_length`
  is False), while `word_boundary=True`; for any input strictly longer than the cap
  the same line is correct. A finding that says "off-by-one in the truncation" or
  "the word-boundary path is one short" WITHOUT naming the boundary condition
  (no-separator AND `word_boundary=True` AND `len(string) == max_length`) does NOT
  get credit: a vague "off-by-one somewhere" is explicitly insufficient now that the
  bug is boundary-gated. Pointing at the wrong line (line 53, the non-word-boundary
  path; line 49 `len(string) < max_length`, which is upstream-correct and a salted
  decoy; or line 72 `truncated = string[:max_length]`) does NOT count, because none
  produces the symptom for this input.

- Full credit (objective recall = found): (a) + (b) above, AND a minimal fix that
  restores the full-length slice for this branch, collapsing the `cutoff` expression
  back to `return string[:max_length]` (or an equivalent that makes the
  `len(string) == max_length` case return `len(string)` characters) without altering
  the `len(string) > max_length` behavior or any other path. A fix that, e.g.,
  rewrites the whole function, removes the branch, or changes the non-word-boundary
  path is "partial" unless it still corrects the boundary arm and leaves the 82 tests
  passing.

---

## Why the existing tests miss it (reference for the scorer)

This is itself a scored brief section, and the objective answer is fixed:

- `reference/test.py` exercises `word_boundary=True` only against the string
  `'jaja---lol-méméméoo--a'` (and its unicode/RTL analogues), which all DO contain
  the `-` separator. Those inputs never take the `separator not in string` branch
  (line 55-57); they fall through into the per-word loop (line 59+).
- The only direct `smart_truncate` tests (`TestUtils`) are
  `test_smart_truncate_no_max_length` (returns early at line 47, `max_length=0`) and
  `test_smart_truncate_no_seperator` (uses `max_length=100`, longer than the input,
  so it returns early at line 49 `len(string) < max_length`). Neither reaches the
  `cutoff` line.
- Crucially, even a test that DID reach the no-separator branch with an over-length
  input would still pass: the injected `cutoff` is correct for `len(string) > max_length`
  and is wrong ONLY at the single point `len(string) == max_length`. So the bug is
  not merely in an uncovered *branch*, it is at an uncovered *boundary value* within
  that branch (no-separator AND `word_boundary=True` AND `len(string)` exactly equal
  to `max_length`). No vendored test pins any equal-length no-separator word-boundary
  case, which is why all 82 tests still pass.
- A solver that names this intersection (the no-separator word-boundary branch is
  untested AND, even if it were, only the `len == max_length` boundary value exposes
  the bug) has the full answer. A solver that only says "the no-separator branch is
  untested" is partially right but misses the boundary-value subtlety; one that
  vaguely says "tests are incomplete" is under-credited on the "why tests miss it"
  section (Coverage/Insight), though the recall item K1 can still be found.

## Provenance of the injection (for the scorer; mirrored in success-criteria § provenance)

- Repo: https://github.com/un33k/python-slugify — License: MIT — Commit:
  `7b6d5d96c1995e6dccb39a19a13ba78d7d0a3ee4` (v8.0.4).
- Vendored, unmodified except for the injection: `reference/slugify/{__init__.py,
  __main__.py, __version__.py, slugify.py, special.py}`, `reference/test.py`,
  `reference/LICENSE`.
- Injection (`reference/slugify/slugify.py`, lines 55-57, inside `smart_truncate`):
  - before (upstream, one line):
    `        return string[:max_length]`
  - after (injected, two lines):
    `        cutoff = max_length if len(string) > max_length else len(string) - 1`
    `        return string[:cutoff]`
  - The `else len(string) - 1` arm is reachable only when `len(string) == max_length`
    (shorter strings already returned at line 49), so the regression is gated on that
    exact boundary value.
- Verification: `cd reference && python3 -m unittest test` (or `python3 test.py`)
  gives 82 tests OK with the bug present (requires `text-unidecode` installed).
  Symptom: `slugify('newsletter', max_length=10, word_boundary=True)` returns
  `'newslette'` (buggy, 9 chars) vs `'newsletter'` expected. Bug does NOT fire for
  `max_length=8` (`'newslett'`, correct) or for an over-length token like
  `slugify('supercalifragilistic', max_length=10, word_boundary=True)`
  (`'supercalif'`, correct), nor with `word_boundary=False`.
