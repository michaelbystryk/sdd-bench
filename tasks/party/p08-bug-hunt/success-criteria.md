# P8 — Success Criteria (pv0.1)

P8 (bug hunt — engineering profile, **fully objective key**). Deliverable:
`root-cause.md`. Applied after a cell completes; used identically across the four
P-track arms (A1 solo / A2 solo+thinking / A3 persona-prompt / A4 party mode).

Universal P-track rubric (5 anchored dims + objective-recall axis + scrub list):
[`harness/party/scoring-rubric.md`](../../../harness/party/scoring-rubric.md). This
file declares P8's objective-recall expectation, which of the 5 dimensions are
load-bearing here, task-specific scoring detail, failure modes, the headline
contrast, and provenance.

This is the track's **fully-objective anchor**: there is exactly one injected bug,
and the answer key (`answer-key.md`, sealed) is binary — right root cause or not.
The rubric dims still apply to the *quality of the writeup*, but the recall axis is
not a matter of rater judgment.

---

## 1. Objective recall expectation (planted bug)

One keyed item, scored mechanically against the sealed key:

| Item | What | Where | Found requires |
|---|---|---|---|
| **K1** | Boundary off-by-one in `smart_truncate`'s no-separator word-boundary branch | `reference/slugify/slugify.py:56-57` — `cutoff = ... else len(string) - 1` feeding `string[:cutoff]` | (a) locates the responsible code as the `separator not in string` branch in `smart_truncate` — the `cutoff` computation / its `else len(string) - 1` arm; (b) states the mechanism AND its exact trigger (slices `len(string) - 1` instead of `len(string)` only when the no-separator input has `len(string) == max_length` and `word_boundary=True`; correct for any over-length input); (c) minimal fix restores the full-length slice (collapse `cutoff` back to `string[:max_length]`). A vague "off-by-one somewhere" without the boundary condition is not "found." |

Score K1 **found / partial / missed** per the answer key's minimum-credit rule,
citing the deliverable line. "Partial" = right surface (names `smart_truncate` /
the truncation logic / an off-by-one) but mislocates the line, muddles the
mechanism, or omits the boundary trigger (e.g. blames line 53, line 49, or the
per-word loop; or says "one short" without pinning the `len == max_length` condition). "Missed" = wrong
root cause, or a "fix" that changes behavior the tests pin.

**Precision note (this task's main false-positive risk).** The vendored source is
otherwise unmodified upstream and is full of *plausible-looking but correct* code
that invites phantom findings:
- `if len(string) < max_length:` (line 49) — looks like it "should" be `<=`, and is
  an especially seductive decoy now that the real bug is boundary-gated: a solver
  chasing "the symptom is at `len == max_length`" may finger this line. It is
  upstream-correct and does NOT cause the symptom (it would only change which branch
  an exactly-equal string takes, both of which a *correct* program handles the same).
  Asserting it is the bug is a **precision miss**.
- the `next_len < max_length` / `elif next_len == max_length` boundary logic in the
  per-word loop (lines 62-66) — correct, test-pinned, not reached by the repro.
- `truncated = string[:max_length]` (line 72) fallback — correct, not reached by
  the repro (the function returns at the no-separator `cutoff` line first).
- the double `QUOTE_PATTERN.sub` pre/post-process in `slugify` — intentional, not
  a bug.
Count any confidently-asserted "the bug is X" that is wrong-for-this-symptom as a
precision defect, published alongside recall. A writeup that fingers two or three
candidate lines without committing — or that "fixes" a correct line — has not found
K1 even if line 56 appears in a list.

## 2. Which of the 5 dimensions are load-bearing for P8 — and why

All five apply; three are load-bearing:

- **Correctness (load-bearing).** This is the spine of the task. The writeup is
  correct iff it pins line 56 with the right mechanism and a fix that leaves the 82
  vendored tests passing. A confident wrong root cause is a 0–1 here, regardless of
  prose quality — it would misdirect the team. This dim is tightly coupled to the
  K1 recall result.
- **Insight depth (load-bearing).** The "why did the tests miss it" section is the
  non-obvious part. A 4–5 connects the symptom to an *uncovered branch* (no-
  separator + `word_boundary=True` + over-length input) and explains the test
  suite's structural gap, not just "tests are incomplete." The `word_boundary=False`
  contrast in the brief is a planted clue that a sharp solver uses to localize the
  bug to the word-boundary path before reading any code.
- **Actionability (load-bearing).** The minimal-fix section must be a concrete,
  apply-able diff (one-line change), not "adjust the truncation." A 4–5 also names
  a regression test the team should add (a no-separator over-length word-boundary
  case) so the gap can't reopen.

Supporting (apply, not load-bearing):
- **Coverage.** The four required sections must all be substantively present. The
  "why tests miss it" section is the one most likely to be skimped.
- **Communication.** ~1–2 pages, conclusions findable in one pass. Bloat (dumping
  the whole function, re-deriving unicode handling that's irrelevant) is penalized
  here, not rewarded as coverage.

## 3. Task-specific scoring detail (4 vs 5 per load-bearing dim)

### Correctness
- **3:** Identifies `smart_truncate` and an off-by-one truncation, fix roughly
  right, but imprecise on which branch / why only the word-boundary path.
- **4:** Pins the `cutoff` line (56-57, the `else len(string) - 1` arm), correct
  mechanism, correct fix, no incorrect claims about the rest of the file.
- **5:** Above + correctly explains the full trigger cluster — `word_boundary=False`
  returns at line 53 (un-bugged `string[:max_length]`); an over-length token (e.g.
  `max_length=8` on `'newsletter'`, or `'supercalifragilistic'` at 10) takes the
  `len(string) > max_length` arm and is correct; only the no-separator,
  `word_boundary=True`, `len(string) == max_length` case fires — i.e. nails the
  subtle "it only happens when the title is right at the limit" the editor reported.

### Insight depth
- **3:** Says the tests don't cover this case.
- **4:** Names the specific uncovered branch and shows that the suite's
  `word_boundary=True` inputs all contain a separator (so they never reach the
  no-separator branch), and the two direct `smart_truncate` tests both return early
  (`max_length=0` and `max_length=100`).
- **5:** Above + generalizes: the bug is an uncovered *boundary value*, not just an
  uncovered branch — even a test reaching the no-separator branch passes unless it
  uses an input whose length is exactly `max_length` (no separator, word-boundary on).
  A property/boundary test sweeping lengths around the cap would have caught it — a
  reframing the team can act on.

### Actionability
- **3:** Gives the corrected line.
- **4:** Corrected line as a before/after diff + states it leaves all tests green.
- **5:** Above + supplies the exact regression test to add (asserting
  `slugify('newsletter', max_length=10, word_boundary=True) == 'newsletter'`, or the
  `smart_truncate` equivalent — a no-separator token whose length equals the cap) and
  notes it would currently fail, closing the loop.

## 4. Failure-mode characterization (observable ways a solver underperforms)

1. **Wrong line, confident.** Fingers line 49 (`len < max_length`, "should be
   `<=`") as the bug. Upstream-correct; does not cause the symptom. Precision miss
   + Correctness 0–1.
2. **Right function, wrong branch.** Blames the per-word loop boundary
   (`next_len < max_length` vs `<=`) or the line-71 fallback. Those aren't reached
   by the repro input (the function returns at line 56 first). Partial recall.
3. **Symptom restated as diagnosis.** "The word-boundary path truncates too
   aggressively" without locating the `- 1`. Reads plausible, isn't a root cause.
   K1 not found.
4. **Hedged shotgun.** Lists three candidate lines and "any of these could be it."
   The objective key requires commitment; a list containing line 56 among decoys is
   not "found."
5. **Fix changes pinned behavior.** "Fixes" by removing the `separator not in
   string` branch, or by changing the non-word-boundary path, breaking the 82 tests
   or other documented behavior. Actionability + Correctness hit.
6. **No "why tests miss it" content.** Skips or hand-waves section four ("the tests
   are just incomplete"). Coverage + Insight hit — this is the section that
   separates a 3 from a 5.
7. **Over-length dump.** Pastes the entire `slugify` function and walks every line
   including irrelevant unicode/HTML-entity handling; conclusion buried. Length-band
   violation → Communication penalty, not coverage credit.
8. **Phantom precision loss.** Asserts unrelated "bugs" (the double quote-sub, the
   `< vs <=` on line 49, an imagined unicode edge) as additional defects. Each
   wrong-for-this-code claim is a precision defect.
9. **Reproduces but mis-explains the contrast.** Notes `word_boundary=False` works
   but attributes it to the wrong reason (e.g. "False skips truncation"), getting
   the symptom right but the mechanism wrong. Caps Correctness at 3.
10. **Asserts the bug without running anything.** Plausible from the brief's repro
    alone, but if the mechanism is hand-waved it tends to land on a decoy line —
    overlaps modes 1–3.

## 5. Headline finding for P8

P8 is the fully-objective anchor and the cleanest test of the masquerade question
on an *engineering* task. The bug is a single off-by-one in a cold, narrow branch;
finding it rewards (a) using the brief's `word_boundary=True`-vs-`False` contrast
to localize before reading code, and (b) actually tracing the repro input through
`smart_truncate` rather than pattern-matching "off-by-one near a slice." The
expected contrasts:

- **Does multi-persona deliberation help a single-bug hunt at all?** A bug hunt has
  one right answer and a small search surface; it is the profile where party-mode's
  diverse-perspectives claim is *least* obviously applicable. If A4 ≈ A1 here while
  A4 > A1 on the strategy/UX tasks, that's a clean per-profile read: personas earn
  their seat on open-ended advisory work, not on convergent debugging.
- **Precision under temptation.** The vendored file is salted with upstream-correct
  code that looks suspicious (the `< vs <=` on line 49 especially). The interesting
  per-arm signal is whether the extra deliberation tokens (A2) or the roundtable
  (A3/A4) *increase* phantom findings — more voices proposing more "candidate bugs"
  — or sharpen the commit to the one real line. A roundtable that surfaces the right
  line but also three decoys "for completeness" has a worse precision profile than a
  terse solo pass that names line 56 and stops.
- **The tests-miss-it section as the depth discriminator.** Recall (K1) may saturate
  across arms on a bug this localizable; if so, the differentiation moves to the
  "why did tests miss it" section — connecting the symptom to a specific uncovered
  branch — which is where deliberation *could* legitimately pay off. That section is
  the one to watch.

If recall saturates at 1/1 across all four arms and the arms separate only on
precision + the tests-miss-it insight, **that is the P8 finding: on a convergent
engineering bug hunt, the machinery doesn't change whether the bug is found, only
how much surrounding noise the writeup carries** — publishable either way.

## calibration

Cold-pass recall: an initial cold pass found the bug instantly because the injection
was a literal `string[:max_length - 1]` on a single signposted line — too easy to
discriminate methodologies. The injection was therefore hardened: the bare `- 1` was
removed and replaced by a boundary-gated `cutoff` computation
(`cutoff = max_length if len(string) > max_length else len(string) - 1`) that is
wrong ONLY when a no-separator string has `len(string) == max_length` under
`word_boundary=True`. The brief's repro was changed to `'newsletter'`/`max_length=10`
(a token whose length equals the cap) and now ships two clean contrast/decoy cases
(`max_length=8`, and the long `'supercalifragilistic'` token) that both behave
correctly, so a solver must triangulate the exact triggering condition rather than
read a near-verbatim cue. Minimum credit now requires naming that condition
(no-separator + `word_boundary=True` + `len == max_length`); a vague "off-by-one
somewhere" no longer earns K1. (Expectation to verify on a fresh cold pass: K1 is
still *findable* by tracing the repro through `smart_truncate`, but no longer
free — the differentiator is precision + the tests-miss-it boundary-value insight.
If a cold pass misses K1 entirely the brief is now too hard; if it nails the
boundary-value reasoning unprompted the depth ceiling may be too easy.)

## provenance

- **Repo:** https://github.com/un33k/python-slugify
- **License:** MIT (`reference/LICENSE`, unmodified upstream copyright).
- **Commit:** `7b6d5d96c1995e6dccb39a19a13ba78d7d0a3ee4` (version 8.0.4).
- **Vendored subset (under `reference/`):** `slugify/__init__.py`,
  `slugify/__main__.py`, `slugify/__version__.py`, `slugify/slugify.py`,
  `slugify/special.py`, `test.py`, `LICENSE`. All unmodified upstream **except** the
  single injection below.
- **Injection** — `reference/slugify/slugify.py`, line 56, inside `smart_truncate`:
  - before (upstream, one line): `        return string[:max_length]`
  - after (injected, two lines): `        cutoff = max_length if len(string) > max_length else len(string) - 1`
    then `        return string[:cutoff]` (the `else len(string) - 1` arm fires only when `len(string) == max_length`)
- **Verification:** `cd reference && python3 -m unittest test` → 82 tests OK *with
  the bug present* (requires `text-unidecode` or `unidecode` installed). Symptom:
  `slugify('newsletter', max_length=10, word_boundary=True)` →
  `'newslette'` (one short); the same call with `word_boundary=False` → `'supercalif'`.
- **What changed vs upstream:** the one-line `return string[:max_length]` was replaced
  by a two-line `cutoff` computation whose `else` arm subtracts one, firing only at
  `len(string) == max_length` (line 56). No tests were modified, removed, or added — the suite is the genuine
  upstream suite, which is why its pass-with-bug status is a real answer to "why did
  the tests miss it."


## Calibration record (2026-06-09) — re-roled: recall=floor, precision=signal



Two cold-pass rounds (Opus 4.8 solo = arm A1 stand-in). Result fed the track-wide
**detection-saturation** re-role: recall is a floor check; the keyed decoys + precision are
the objective discriminator. See `analysis/party-findings/00-detection-saturation.md` and
`harness/party/scoring-rubric.md` § Objective floor + precision axis.
