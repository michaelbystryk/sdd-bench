# Slug truncation is one character short — root cause

## Root cause

**`reference/slugify/slugify.py:56`**, inside `smart_truncate`:

```python
if separator not in string:
    cutoff = max_length if len(string) > max_length else len(string) - 1
    return string[:cutoff]
```

This is the branch taken when the (already-slugified) text contains **no
separator** — i.e. it is a single "word" with no dashes. The `else` arm of the
ternary, `len(string) - 1`, subtracts one character in exactly the case where no
truncation should happen at all.

The key observation is the guard four lines above (`slugify.py:49`):

```python
if len(string) < max_length:
    return string
```

This returns early whenever the string is *strictly shorter* than the cap. So by
the time control reaches line 56, we are guaranteed `len(string) >= max_length`.
That makes the ternary's two arms mean:

- `len(string) > max_length` → string is longer than the cap → `cutoff = max_length`. **Correct.**
- otherwise (the only remaining possibility, `len(string) == max_length`) → string is *exactly* the cap and fits perfectly → `cutoff = len(string) - 1`. **Wrong** — it lops off the last character of a string that needed no truncation.

So the `- 1` only ever fires on the boundary case `len(string) == max_length`, and
in that case it is always wrong. That single token is the bug.

## How it produces the symptom

Trace `slugify('newsletter', max_length=10, word_boundary=True)`:

1. The normalization/cleanup pipeline in `slugify` leaves the text as `'newsletter'`
   (10 chars, no dashes — it is one word).
2. `slugify.py:192-193` calls `smart_truncate('newsletter', 10, True, '-', False)`.
3. `string.strip('-')` → `'newsletter'` (unchanged).
4. `max_length` is truthy, so we don't return at line 47.
5. `len(string) < max_length` → `10 < 10` → **False**; the early return at line 49–50 is skipped. *(This is the crux: equality slips past the `<` guard.)*
6. `word_boundary` is `True`, so line 52–53 is skipped.
7. `separator not in string` → `'-' not in 'newsletter'` → **True**, so we enter line 56.
8. `len(string) > max_length` → `10 > 10` → **False**, so the ternary takes the `else`: `cutoff = len(string) - 1 = 9`.
9. `return string[:9]` → `'newslette'` — 9 characters, last letter dropped.

Now compare against the three cases that *behave correctly*, which confirms the
mechanism:

- **`max_length=8`** → `'newsletter'` is length 10. Line 49: `10 < 8` False (skip). Line 56: `10 > 8` **True**, so `cutoff = max_length = 8` → `'newslett'`. The genuine over-length path is fine; only the *equality* path is broken.
- **`'supercalifragilistic'`, `max_length=10`** → length 20. Same as above: `20 > 10` True → `cutoff = 10` → `'supercalif'`. Fine.
- **`word_boundary=False`** → line 52–53 returns `string[:max_length].strip(separator)` = `'newsletter'[:10]` = `'newsletter'`. The no-separator/word-boundary branch at line 56 is never reached, so the `- 1` never applies.

This precisely matches the editor's hunch — it bites *only* when the slug is a
single word (no separators survive) **and** its length equals `max_length`
exactly, with `word_boundary=True`. Any other combination misses the buggy line.

## Minimal fix

Drop the `- 1`. When `len(string) == max_length` the string fits exactly and must
be returned whole.

**Before** (`slugify.py:56`):

```python
cutoff = max_length if len(string) > max_length else len(string) - 1
```

**After:**

```python
cutoff = max_length if len(string) > max_length else len(string)
```

Because the line-49 guard guarantees `len(string) >= max_length` here, the `else`
arm only triggers when `len(string) == max_length`, so `len(string)` and
`max_length` are equal — the expression could equivalently be reduced to just
`cutoff = max_length`. Keeping `len(string)` is the smallest textual change and
preserves the author's original structure.

Verified: with this one-token change, `slugify('newsletter', max_length=10,
word_boundary=True)` returns `'newsletter'`, the other two reproduction cases are
unchanged, and the full shipped suite still passes (82 tests, OK).

[ASSUMPTION] The intended contract is "never exceed `max_length`, and when the
text already fits within it, return it intact." The fix honors that. It does *not*
change the separate `word_boundary` semantics of trimming back to a whole word
when the text genuinely overflows the cap (the loop at lines 59–73), which is a
different code path.

## Why existing tests miss it

The buggy line is guarded by a three-way conjunction, and the test suite never
satisfies all three at once:

1. **No test exercises the "no separator" branch with `word_boundary=True`.**
   `smart_truncate` has a dedicated branch at line 55–57 for input that contains
   no separator. The only tests aimed at this branch are
   `test_smart_truncate_no_max_length` and `test_smart_truncate_no_seperator`
   (`test.py:533-541`). The first passes `max_length=0` (returns at line 47,
   before line 56). The second passes `max_length=100` against a 24-char string,
   so `len(string) < max_length` returns at line 49 — again never reaching line
   56. Neither sets `word_boundary=True`, and neither uses an input near the cap.

2. **Every `word_boundary` / `max_length` test uses multi-word input.** The
   `test_word_boundary`, `test_custom_separator`, `test_save_order`, etc.
   (`test.py:76-118`, and the unicode mirror at 302-362) all slugify strings like
   `'jaja---lol-méméméoo--a'` and `'one two three four five'`. After slugifying,
   these contain dashes, so `separator in string` is **True** and execution goes
   to the word-splitting loop at lines 59–73 — bypassing the buggy line 56
   entirely. No test feeds a *single-word* slug into the word-boundary path.

3. **No test hits the exact-length boundary.** The assertions deliberately pick
   `max_length` values that fall *between* words (9, 12, 13, 15, 17, 18, 19, …),
   probing the word-splitting logic. None choose a `max_length` equal to the
   length of a single, separator-free result, which is the only value that makes
   `len(string) == max_length` true at line 56.

In short, the suite thoroughly covers the multi-word word-boundary loop and the
"plenty of room" early return, but leaves a blind spot at the intersection of
*single-word input* + *word_boundary=True* + *length exactly equal to the cap* —
which is exactly the corner the editor stumbled into. A regression test such as
`self.assertEqual(slugify('newsletter', max_length=10, word_boundary=True),
'newsletter')` (and a direct
`smart_truncate('newsletter', max_length=10, word_boundary=True, separator='-')`)
would lock the fix in.
