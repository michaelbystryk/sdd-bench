# Slug truncation is one character short — root-cause writeup

**Symptom.** With `word_boundary=True`, a single-word title whose length is *exactly* `max_length` comes out one character short, with the final character chopped:

```python
slugify('newsletter', max_length=10, word_boundary=True)  # -> 'newslette' (9), expected 'newsletter' (10)
```

It is situational because it fires only at a precise corner of the input space (see below). All four observations in the report reproduce against the code in `reference/` as shipped.

---

## Root cause

**`reference/slugify/slugify.py:56`**, inside `smart_truncate`:

```python
55  if separator not in string:
56      cutoff = max_length if len(string) > max_length else len(string) - 1
57      return string[:cutoff]
```

The `else len(string) - 1` arm is the defect. It is reached only when a string contains **no separator** (a single token) **and** `len(string) == max_length`, and in that case it deliberately subtracts one character from a word that already fits the cap exactly.

The mechanism is an off-by-one at a boundary that no comparison owns. The early-return guard at **line 49** is *strict*:

```python
49  if len(string) < max_length:
50      return string
```

So by the time execution reaches line 56, the invariant `len(string) >= max_length` always holds. The ternary on line 56 then splits that surviving domain with another *strict* comparison, `len(string) > max_length`. The two strict comparisons (`<` and `>`) leave the `==` case orphaned: it falls into the `else` arm, which was evidently written to handle "string shorter than the cap" (where `len(string) - 1` looks vaguely plausible) — but the line-49 guard already amputated that case. What remains wired to `len(string) - 1` is exactly the one input where it is wrong: the perfect fit.

The correct answer at `len(string) == max_length` follows from the function's own contract. The docstring describes `word_boundary` as: *"truncates to complete word even if length ends up shorter than max_length."* That is **permission** to come up short *only when honoring a word boundary forces it* — not an instruction to always shorten. When a single word fits the cap exactly, the boundary to honor is the end of the string; nothing forces a trim, so the whole word must be returned.

---

## How it produces the symptom

Trace `slugify('newsletter', max_length=10, word_boundary=True)`. The slug pipeline leaves `text = 'newsletter'` unchanged, then calls `smart_truncate('newsletter', 10, True, '-', False)`:

| Line | Check | Result |
|------|-------|--------|
| 44 | `'newsletter'.strip('-')` | `'newsletter'` |
| 46 | `not max_length` | False (10) |
| 49 | `len < max_length` → `10 < 10` | **False** — no early return |
| 52 | `not word_boundary` | False |
| 55 | `separator not in string` → `'-' not in 'newsletter'` | **True** — enter single-token branch |
| 56 | `len > max_length` → `10 > 10` | **False** → `cutoff = len(string) - 1 = 9` |
| 57 | `return string[:9]` | **`'newslette'`** |

Now the three cases that "behave," confirming the corner is the `==` boundary:

- **Cap below the word length** — `slugify('newsletter', max_length=8, word_boundary=True)`. Line 49: `10 < 8` False. Line 56: `10 > 8` **True** → `cutoff = max_length = 8` → `'newslett'`. Correct.
- **Word longer than the cap** — `slugify('supercalifragilistic', max_length=10, word_boundary=True)`. Line 56: `20 > 10` **True** → `cutoff = 10` → `'supercalif'`. Correct.
- **Word-boundary off** — `slugify('newsletter', max_length=10)`. Line 52: `not word_boundary` True → `return string[:10].strip('-')` → `'newsletter'`. The buggy branch is never entered.

So the bug requires the simultaneous conjunction of three conditions, which is why it is rare: `word_boundary=True` **and** the (post-slugify) string contains **no separator** **and** its length **equals** `max_length` exactly. Any deviation — a multi-word title, a cap above or below the word length — routes around line 56's `else` arm. [ASSUMPTION] "Right at the length limit," the editor's hunch, corresponds precisely to the `len == max_length` equality; their inability to pin it down further is the missing "single word / no separator" half of the condition.

---

## Minimal fix

Make the comparison on line 56 non-strict so the `==` case joins the `> max_length` side, where `cutoff` is the cap:

**Before** (`reference/slugify/slugify.py:56`):
```python
        cutoff = max_length if len(string) > max_length else len(string) - 1
```

**After:**
```python
        cutoff = max_length if len(string) >= max_length else len(string) - 1
```

At `len == max_length` this now yields `cutoff = max_length` (`== len`), returning the full `'newsletter'`. The `else` arm becomes unreachable (the line-49 guard already excludes `len < max_length`), and is harmless if ever reached, since `len(string)` would then be the whole string.

This is a one-character diff and cannot move the bug:

- `len < max_length` — never reaches line 56 (early return at line 49). Unchanged.
- `len == max_length` — was `len - 1`, now `max_length`. **The fix.**
- `len > max_length` — was `max_length`, still `max_length`. Identical; longer-word and below-cap cases unaffected.

**Recommended alternative (clarity).** Because the line-49 guard makes `len(string) >= max_length` invariant at line 56, the ternary is dead logic — both arms collapse to the cap in every reachable case. The roundtable (Amelia, Winston) preferred replacing it outright:

```python
        cutoff = max_length
        return string[:cutoff]
```

Behaviorally identical to the `>=` fix, but it removes the misleading branch instead of pacifying it, so a future reader cannot misread the `else` arm as live logic. Either change is correct; choose the `>=` edit for the smallest possible diff, or the constant for the cleaner invariant.

---

## Why existing tests miss it

The shipped suite passes because its `word_boundary=True` fixtures never vary the two input dimensions that the bug depends on — they hold both at the *safe* value.

**Every word-boundary fixture is multi-word**, so it always contains a separator and is therefore routed into the word-splitting *loop* branch (lines 59–73), never the single-token branch at line 55:

- `test_word_boundary` / `test_custom_separator` / `test_multi_character_separator` — fixture `'jaja---lol-méméméoo--a'`, separators throughout, truncated at interior word boundaries (max_length 15/17/18/19/20).
- `test_save_order` — `'one two three four five'`, separators throughout.

**The two `smart_truncate` unit tests never reach the truncation branch at an equal length:**

- `test_smart_truncate_no_max_length` — no `max_length`, so it exits at line 46/47.
- `test_smart_truncate_no_seperator` — despite its name, it uses `max_length=100` against a ~24-char string, so it exits at the line-49 `len < max_length` guard *before* any truncation runs. Its name advertises coverage of the separatorless case, but its oversized cap means the assertion never exercises it — the most deceptive kind of gap, because a reviewer reads the name and believes the case is covered.

The bug lives at the intersection of two boundary conditions that must hold simultaneously: **(1) no separator in the string** and **(2) `len(string) == max_length`**. No fixture lets both land on the dangerous value at once, so that cell of the input matrix is simply never executed. Example-based tests are written to demonstrate *features*, not to probe *boundaries*, and this is a boundary corner.

**The test that would have caught it** (and should be added):

```python
def test_word_boundary_exact_length_single_word(self):
    self.assertEqual(
        slugify('newsletter', max_length=10, word_boundary=True),
        'newsletter',
    )
```

To lock the boundary on both sides rather than pass for the wrong reason, add the neighbors `max_length=9` (one under — expect `'newslette'`, a hard cut to the cap since a single over-cap word can't honor a boundary) and `max_length=11` (one over — expect `'newsletter'` via the line-49 early return). That trio turns a single point assertion into a sweep across the `==` edge — precisely the dimension the shipped suite never covers.
