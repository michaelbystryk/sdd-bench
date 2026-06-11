# Slug truncation is one character short

We vendor a small Python slug library (the `slugify` package under `reference/`)
to generate URL slugs for user-submitted titles. We cap slug length with the
library's `max_length` argument, and because we don't want slugs cut off in the
middle of a word, we pass `word_boundary=True`.

A content editor opened a bug against us this week. A handful of generated slugs
are coming out one character shorter than the limit we ask for, with the final
character of the word chopped off. It only bites on a narrow set of titles —
the overwhelming majority of slugs look fine, which is why it slipped past us for
a while. The editor's hunch was "it's the ones where the title is right at the
length limit," but they couldn't pin it down further.

Here is the smallest reproduction we've been able to isolate, run against the
code exactly as it sits in `reference/`:

```python
from slugify import slugify

# A single-word title, no spaces; the word happens to be exactly as long as the cap
slugify('newsletter', max_length=10, word_boundary=True)
# we get:      'newslette'      (9 characters)
# we expected: 'newsletter'     (10 characters)
```

The frustrating part is how situational it is. Drop the cap below the word's
length and it behaves:

```python
slugify('newsletter', max_length=8, word_boundary=True)
# 'newslett'  (8 characters, exactly the cap — fine)
```

Feed it a word longer than the cap and it also behaves:

```python
slugify('supercalifragilistic', max_length=10, word_boundary=True)
# 'supercalif'  (10 characters, exactly the cap — fine)
```

And turning the word-boundary option off makes even the failing case correct:

```python
slugify('newsletter', max_length=10)
# 'newsletter'  (10 characters, as expected)
```

So the cap itself works in the general case; something about the word-boundary
path shaves a character off only in this specific situation. We need to
understand exactly why — and exactly when — before we patch it ourselves, because
we've been bitten before by "fixes" that just moved the problem somewhere else.

The full library source and its test suite are in `reference/` (the package is
under `reference/slugify/`, the tests are `reference/test.py`). What we want from
you is a clear root-cause writeup: pin down the exact line responsible and the
mechanism, explain precisely how that line produces the symptom above, give us
the minimal change that fixes it, and — this is the part that's nagging us — tell
us why the library's own test suite didn't catch this, since the tests all pass
as shipped.

## Deliverable

Produce `root-cause.md` as a standalone Markdown document with these sections:
**Root cause** (the responsible `file:line` and the mechanism); **How it produces
the symptom** (trace the reproduction above through the code); **Minimal fix**
(the smallest change that corrects it, with before/after); **Why existing tests
miss it** (what the shipped test suite does and doesn't exercise). Target length:
~1–2 pages.

## A note on ambiguity

If anything is ambiguous, make a reasonable assumption and tag it [ASSUMPTION].
