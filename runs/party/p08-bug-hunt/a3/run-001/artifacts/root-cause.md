# Slug truncation one character short — root-cause analysis

`slugify(..., max_length=N, word_boundary=True)` returns a slug of `N-1`
characters, with the last character of the word dropped, whenever the slug is a
**single word containing no separator** whose length is **exactly** `N`. All
other inputs are correct, which is why the defect went unnoticed.

## Root cause

**`reference/slugify/slugify.py:56`**, inside `smart_truncate`:

```python
cutoff = max_length if len(string) > max_length else len(string) - 1
```

When the string contains no separator, this line decides how many characters to
keep. The `else` arm — `len(string) - 1` — is the culprit.

By the time control reaches line 56, two earlier guards have already run:

- Line 49–50: `if len(string) < max_length: return string` — so any string
  *shorter* than the cap has already returned.
- Line 55: this branch is only entered when `separator not in string`.

Therefore, at line 56, `len(string) >= max_length` always holds. That leaves
only two possibilities:

| Condition | `len(string) > max_length`? | `cutoff` | Result |
|---|---|---|---|
| String longer than cap | True | `max_length` | correct |
| String length **equals** cap | False → `else` | `len(string) - 1` | **off by one** |

The `else` branch can fire *only* when `len(string) == max_length`, and in that
case it is always wrong by exactly one character. It was evidently written to
mean "the string is shorter than the cap, return it whole," but the upstream
guard at line 49 makes that case impossible to reach here. The branch is
effectively dead code that exists solely to produce the bug.

## How it produces the symptom

Trace `slugify('newsletter', max_length=10, word_boundary=True)`:

1. By line 193 of `slugify`, normalization/cleanup leaves `text = 'newsletter'`
   (10 characters), and `smart_truncate('newsletter', 10, True, '-', False)` is
   called.
2. `string.strip('-')` → `'newsletter'`. `max_length` is truthy.
3. Line 49: `len('newsletter') < 10` → `10 < 10` → **False**. No early return.
4. Line 52: `not word_boundary` → False. Skipped.
5. Line 55: `'-' not in 'newsletter'` → **True** (a single word has no
   separator). Enter the branch.
6. Line 56: `len('newsletter') > 10` → `10 > 10` → **False**, so
   `cutoff = len('newsletter') - 1 = 9`.
7. Line 57: `return 'newsletter'[:9]` → **`'newslette'`** (9 characters).

The three "behaves fine" cases confirm the trigger is the exact-equality `else`:

- `slugify('newsletter', max_length=8, word_boundary=True)` → `len 10 > 8` is
  **True**, so `cutoff = 8` → `'newslett'`. The `else` never runs.
- `slugify('supercalifragilistic', max_length=10, word_boundary=True)` →
  `len 20 > 10` is **True**, so `cutoff = 10` → `'supercalif'`. The `else` never
  runs.
- `slugify('newsletter', max_length=10)` (no `word_boundary`) → line 52 returns
  `string[:10]` and line 55–57 are never reached → `'newsletter'`.

The content editor's hunch — "it's the ones where the title is right at the
length limit" — is exactly the trigger condition: a separator-free slug whose
length equals `max_length`.

## Minimal fix

Change the comparison on line 56 from `>` to `>=`:

**Before** (`slugify.py:56`)
```python
cutoff = max_length if len(string) > max_length else len(string) - 1
```

**After**
```python
cutoff = max_length if len(string) >= max_length else len(string) - 1
```

Now the exact-equality case takes the `max_length` arm, yielding
`'newsletter'[:10]` → `'newsletter'`.

This is the smallest possible change and cannot move the problem elsewhere:

- The `len(string) > max_length` cases (e.g. the `supercalifragilistic` and
  `max_length=8` examples) already took the `max_length` arm and are unchanged.
- The multi-word path (lines 59–73) never reaches line 56 and is untouched.
- The only behavior that changes is the exact-equality, separator-free case —
  precisely the bug.

Because `len(string) >= max_length` is an invariant at this point, the `else`
arm is now provably unreachable, so an equivalent and arguably clearer form is
`cutoff = max_length`. The `>=` change is preferred here as the minimal,
lowest-risk diff; collapsing to `cutoff = max_length` is an optional cleanup
that carries the same behavior. [ASSUMPTION] We favor the one-character diff to
honor the stated preference for fixes that don't reshape surrounding code.

Verified after the change:

```python
slugify('newsletter',           max_length=10, word_boundary=True)  # 'newsletter'
slugify('newsletter',           max_length=8,  word_boundary=True)  # 'newslett'
slugify('supercalifragilistic', max_length=10, word_boundary=True)  # 'supercalif'
```

## Why existing tests miss it

The shipped suite passes because **line 56 has no test coverage at all**, and
the bug requires a specific boundary value on top of reaching that line. Two
gaps stack precisely over the defect:

1. **Every `word_boundary=True` test uses multi-word input.**
   `test_word_boundary`, `test_save_order`, `test_custom_separator`,
   `test_multi_character_separator` (and their `allow_unicode` twins) all
   operate on strings like `'jaja-lol-mememeoo-a'` or `'one two three four
   five'`. These always contain the separator, so line 55 is False and
   execution goes into the word-accumulation loop (lines 59–73). No test ever
   sends a **separator-free, single-word** string through the `word_boundary`
   path, so the `if separator not in string:` branch — and line 56 — is never
   executed at the slugify level.

2. **The only direct `smart_truncate` tests sidestep the branch.** In
   `TestUtils`, `test_smart_truncate_no_max_length` returns at line 47
   (no `max_length`). `test_smart_truncate_no_seperator` looks targeted at this
   branch but calls `smart_truncate(txt, max_length=100, separator='_')` with
   `word_boundary` left at its **default of `False`** and a 24-char string
   against a cap of 100 — so it exits at line 49 (`len < max_length`) and never
   reaches line 52, let alone 55–57.

Even if a test had entered the branch, exposing the `- 1` additionally requires
the input length to **exactly equal** the cap. The suite exercises caps smaller
than the content (truncation occurs) and caps larger than the content (no
truncation), but never a cap that lands precisely on a separator-free string's
length — the single boundary value where the `else` arm fires.

**Recommended regression tests** (one per gap):

```python
# single word, length exactly equal to the cap — the reported failure
self.assertEqual(slugify('newsletter', max_length=10, word_boundary=True),
                 'newsletter')

# smart_truncate directly, no separator, word_boundary on, length == cap
self.assertEqual(smart_truncate('newsletter', max_length=10,
                                 word_boundary=True, separator='-'),
                 'newsletter')
```

The broader takeaway: line-coverage tooling would have flagged line 56 as
unexecuted. Gating the suite on branch coverage of `smart_truncate` would have
surfaced this dead-but-buggy arm before it shipped.
