# Slug truncation is one character short — root cause

## Root cause

**`reference/slugify/slugify.py:56`**, inside `smart_truncate`:

```python
if separator not in string:
    cutoff = max_length if len(string) > max_length else len(string) - 1
    return string[:cutoff]
```

This is the code path taken when the truncation candidate contains **no separator**
— i.e. it is a single token with no place to break on a word boundary. The
`else len(string) - 1` branch subtracts one character every time it is hit, and as
shown below it is hit precisely when the string length equals `max_length`. That
stray `- 1` is the bug.

The mechanism is a misplaced off-by-one guard. By the time control reaches line 56,
the function has already established (at line 49, `if len(string) < max_length:
return string`) that `len(string) >= max_length`. So the ternary on line 56 only has
two reachable states:

- `len(string) > max_length` → `cutoff = max_length` (correct: truncate to the cap)
- `len(string) == max_length` → `cutoff = len(string) - 1` = `max_length - 1` (**wrong**)

When the single word is *exactly* as long as the cap, the whole word fits and should
be returned untouched, but the `else` branch lops off the last character instead.

## How it produces the symptom

Trace `slugify('newsletter', max_length=10, word_boundary=True)`:

1. `slugify` cleans `'newsletter'` to the slug `'newsletter'` (10 chars, no dashes),
   then calls `smart_truncate('newsletter', 10, True, '-', False)` (slugify.py:193).
2. `string.strip('-')` → `'newsletter'`.
3. `max_length` is 10 (truthy), so the `if not max_length` guard is skipped.
4. Line 49: `len(string) < max_length` → `10 < 10` → **False**, so we do *not*
   early-return the full string.
5. `word_boundary` is `True`, so the `if not word_boundary` branch is skipped.
6. Line 55: `separator not in string` → `'-' not in 'newsletter'` → **True**, so we
   enter the buggy branch.
7. Line 56: `len(string) > max_length` → `10 > 10` → **False**, so `cutoff =
   len(string) - 1 = 9`.
8. Line 57: `return string[:9]` → `'newslette'` — 9 characters. **The symptom.**

This also explains why the bug is so situational — the three "working" cases each
avoid step 7's `else` branch:

- **`max_length=8`** (`'newsletter'`, len 10): `len(string) > max_length` → `10 > 8`
  → True, so `cutoff = max_length = 8` → `'newslett'`. Correct.
- **`'supercalifragilistic'`, `max_length=10`** (len 20): `20 > 10` → True, so
  `cutoff = 10` → `'supercalif'`. Correct.
- **word boundary off** (`slugify('newsletter', max_length=10)`): `word_boundary` is
  `False`, so line 52–53 returns `string[:max_length]` = `'newsletter'`. The buggy
  line is never reached. Correct.

The exact trigger is therefore: **`word_boundary=True`, a slug containing no
separator (a single word), whose length is exactly `max_length`.** That matches the
editor's "titles right at the length limit" hunch — and it is narrow, which is why
the overwhelming majority of multi-word slugs are unaffected (they take the
`for word in string.split(separator)` path lower down instead).

## Minimal fix

The branch only runs when `len(string) >= max_length` and there is no separator to
break on, so the only sensible result is "truncate to the cap." Drop the `- 1`:

**Before** (slugify.py:56–57):

```python
cutoff = max_length if len(string) > max_length else len(string) - 1
return string[:cutoff]
```

**After:**

```python
cutoff = max_length
return string[:cutoff]
```

(Equivalently, `return string[:max_length]` — the ternary collapses because both
reachable states should yield `max_length`.) When `len == max_length`,
`string[:max_length]` returns the full word; when `len > max_length` the behavior is
unchanged. Verified against the reproduction and the surrounding cases:

| call | before | after |
|------|--------|-------|
| `slugify('newsletter', 10, word_boundary=True)` | `newslette` (9) | `newsletter` (10) |
| `slugify('newsletter', 8, word_boundary=True)`  | `newslett` (8)  | `newslett` (8) |
| `slugify('supercalifragilistic', 10, word_boundary=True)` | `supercalif` (10) | `supercalif` (10) |

Only the failing case changes; the others are untouched, so this does not "move the
problem somewhere else."

[ASSUMPTION] You want the full word returned when it fits exactly. The only other
defensible reading is that a separator-free word at exactly the cap should still be
shortened to leave room for something — but nothing in the code or docstrings
suggests that, and `word_boundary`'s documented contract is "truncate to a complete
word," which a single exactly-fitting word already satisfies.

## Why existing tests miss it

The shipped suite passes because **no test exercises the buggy line in its failing
state.** Two gaps combine:

1. **Every `word_boundary=True` slugify test uses multi-word input containing
   dashes.** `test_word_boundary`, `test_custom_separator`,
   `test_multi_character_separator`, and `test_save_order` all feed strings like
   `'jaja---lol-méméméoo--a'` or `'one two three four five'`. Because a separator *is*
   present, control flows into the `for word in string.split(separator)` loop
   (slugify.py:59–73) and never touches the `if separator not in string` branch at
   all. The single-word, no-separator path is simply never tested through `slugify`.

2. **The one test that targets the no-separator path never reaches the buggy line.**
   `test_smart_truncate_no_seperator` (test.py:538) calls
   `smart_truncate('1,000 reasons you are #1', max_length=100, separator='_')`. The
   string is 24 chars against a cap of 100, so line 49's `len(string) < max_length`
   (`24 < 100`) is **True** and the function early-returns the whole string. It
   confirms "short input is left alone" but exits long before line 56.

So nothing ever drives `smart_truncate` with `word_boundary=True`, a separator-free
string, *and* a length `>= max_length` — the exact and only conjunction that reaches
the defect. The bug lives in an untested corner: the intersection of "no separator"
and "length at or past the cap."

A regression test that locks this down:

```python
def test_word_boundary_single_word_at_max_length(self):
    self.assertEqual(slugify('newsletter', max_length=10, word_boundary=True), 'newsletter')
    # boundary neighbors, to guard against a re-introduced off-by-one:
    self.assertEqual(slugify('newsletter', max_length=9,  word_boundary=True), 'newslette')
    self.assertEqual(slugify('newsletters', max_length=10, word_boundary=True), 'newsletter')
```
