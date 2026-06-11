# P10 — Success criteria (v0.1, harness-only)

P10 (code review of a feature-add PR; engineering profile; planted key — recall
**and precision**) scoring. Applied after a cell completes; identical across all
four arms.

Universal P-track rubric (5 anchored dims + objective-recall axis + scrub +
cost): [`harness/party/scoring-rubric.md`](../../../harness/party/scoring-rubric.md).
This file declares P10's objective-recall expectations, which of the 5 dims are
load-bearing, task-specific scoring detail, failure modes, and the headline
contrast. The sealed planted-truth list is in `answer-key.md` (never seeded to a
cell).

---

## 1. Objective-recall expectations (planted defects)

Eight defects are planted in `reference/pr.diff`, keyed K1–K8 in `answer-key.md`,
spanning the requested taxonomy: insecure deserialization (K1), resource leak
(K2), concurrency race (K3), swallowed error (K4), off-by-one (K5), wrong default
(K6), behavior regression (K7), and one subtle second-order logic error (K8).
Score each **found / partial / missed** per the answer key's "minimum credit"
line, citing the deliverable line. Recall is published as the raw fraction (e.g.
6/8); it is never folded into the /25 quality sum.

**Precision is co-equal for this task.** P10 is the track's precision probe: the
diff contains deliberate *clean* hunks (B1–B5 in `answer-key.md`) engineered to
look like defects — md5-for-filenames, a temp-file+`os.replace` atomic write, an
`exists`-before-`remove`, a correct `except KeyError`, a correctly-locked `get`.
Count every finding asserted **with confidence as a defect** that is wrong for
this code (a bait hunk flagged as a bug, or a hallucinated mechanism) in the
precision note. Per the rubric: a cell that finds 8/8 plus 6 phantom defects did
not win. Publish recall and precision together (e.g. `recall 7/8, precision: 1
false positive (md5)`).

- Calm *nits* on the "additional valid findings" list (answer-key § Additional
  valid findings) cost neither recall nor precision. Escalating one of those to a
  *blocker* with a wrong mechanism does cost precision.
- A solver may legitimately find a real issue we didn't key. Before scoring it as
  a false positive, the operator confirms against the code that it is in fact
  wrong; genuine novel-but-correct findings are noted, not penalized.

## 2. Which of the 5 dims are load-bearing, and why

All five apply. **Load-bearing for P10: Correctness, Insight depth,
Actionability.**

- **Correctness (load-bearing).** A review's value collapses if its findings are
  wrong. This is where false positives (bait hunks flagged as bugs, invented
  mechanisms) and mis-stated severities are scored on the quality axis, in
  parallel with the mechanical precision note. A review that calls the
  temp-file write a race, or md5 a vulnerability here, takes a Correctness hit.
- **Insight depth (load-bearing).** The obvious defects (pickle, leak, wrong
  default, off-by-one) are first-pass finds. The discriminating findings are the
  subtle ones — the non-atomic `incr` whose lock is dropped mid read-modify-write
  (K3, with no "atomic" docstring cue to flag it), the `get` regression that must
  be inferred by cross-referencing the rewritten body against `LRUCache`'s
  `__getitem__` (K7, with no advertising comment), and especially the
  eviction/disk divergence (K8) that requires reasoning about the
  *backing* cache's eviction, which is not in the diff. Depth is where catching
  those is rewarded.
- **Actionability (load-bearing).** The deliverable is a review someone merges or
  blocks on. Findings must carry severity, a precise `file:line`, and a concrete
  fix; the verdict (merge / changes / block) must follow from the findings.

Coverage and Communication are scored but not the primary discriminators:

- **Coverage** — did the review consider the axes the brief flagged (concurrency,
  restart, large/long-running, untrusted input) rather than only the happy path?
  Reflected mostly through which keyed items are found; tracked here so a review
  that ignores an entire axis (e.g. says nothing about thread-safety) is marked
  down even if its in-scope findings are correct.
- **Communication** — blocker-vs-nit separation, scannability, and respecting the
  ~2-page band. The brief explicitly asks for a short-and-right review over a
  long one; bloat and wolf-crying are Communication (and Correctness) costs, not
  Coverage credit.

## 3. Task-specific scoring detail (4 vs 5 on the load-bearing dims)

**Correctness.**
- 3: findings mostly right; at most one minor mis-statement; no bait hunk flagged
  as a blocker.
- 4: every asserted defect is real and correctly explained; severities are
  defensible; no false positives among Findings (bait correctly left alone or
  explicitly dismissed).
- 5: above, **and** it correctly navigates the contested calls — e.g. explicitly
  notes that md5-here is *not* a vulnerability, or that the temp-file write is
  correct — i.e. it demonstrates it considered the bait and reasoned past it,
  rather than merely not mentioning it.

**Insight depth.**
- 3: at least one of the three subtle defects (K3 / K7 / K8) found.
- 4: two of the three subtle defects found, with the mechanism correctly stated
  (not just "looks racy").
- 5: all three subtle defects found, **including K8** (eviction/disk divergence),
  with its second-order consequence named (unbounded disk growth and/or
  evicted-key resurrection on reload) — the finding that requires reading past
  the diff into the backing cache's eviction behavior.

**Actionability.**
- 3: findings have severity and a location; fixes are gestured at.
- 4: every finding has a precise `file:line` and a concrete, correct fix; the
  verdict follows from the blocker set.
- 5: above, **and** blockers vs. non-blockers are cleanly separated with an
  explicit merge condition ("blocks on K1, K3, K7; the rest can be follow-ups"),
  so the maintainer can act without re-deriving priority.

## 4. Failure-mode characterization (observable underperformance)

1. **Pickle missed or under-rated.** Treats `pickle.load` as a portability/perf
   choice rather than an arbitrary-code-execution trust-boundary defect (K1) —
   or doesn't mention it at all.
2. **`incr` accepted as atomic.** Sees the per-block `with self.__lock` on the
   counter helper and concludes it's fine, missing that the lock is *dropped
   between* the read and the write (the two separate locked blocks bracket an
   unlocked `value = value + amount`) (K3). The dominant subtle miss.
3. **`get` regression unnoticed.** Reads `self.__data.get` as a harmless direct
   read and never cross-references it against `LRUCache.__getitem__`/`__touch` in
   `reference/src/`, so it misses that `get` no longer bypasses subclass logic —
   breaking LRU recency-on-get and `__missing__` (K7).
4. **K8 never surfaced.** Reviews only the lines in the diff and never reasons
   about what the *backing* cache does on overflow, so the eviction/disk
   divergence and reload-resurrection are missed entirely.
5. **md5 false positive.** Flags `hashlib.md5` as a security vulnerability (B1) —
   the signature P10 precision-tests for. Costs precision and Correctness.
6. **Atomic-write false positive.** Flags the `tmp` + `os.replace` write (B2) as a
   race or partial-write risk; or flags the `exists`-before-`remove` (B3) as a
   TOCTOU bug.
7. **Off-by-one mis-read.** Notices `_prune` is suspicious but mis-states the
   mechanism (e.g. "removes too many files") instead of the actual `names[1:excess]`
   skip-the-oldest / removes-too-few (K5) — partial credit at best.
8. **Wolf-crying / bloat.** Produces a long review that flags many low-value or
   incorrect items, burying the real blockers; or exceeds the ~2-page band with
   line-by-line narration. Communication + precision cost.
9. **No verdict / unprioritized.** Lists problems without a merge/block call, or
   without severities, so a maintainer can't act (Actionability).
10. **Vague fixes.** "Improve thread safety", "handle errors better" with no
    concrete change or location (Actionability floor).

## 5. Headline finding (the contrast this task is designed to reveal)

P10 asks whether a multi-persona roundtable reviews code better than a single
model — on a task with a sealed key, so rater circularity can't hide the answer.
Two specific contrasts:

- **Recall on the subtle three (K3/K7/K8) vs. precision on the bait (B1/B2).**
  The cheap defects (pickle, leak, wrong default, off-by-one) should fall to any
  arm. The interesting question is whether persona deliberation (a "security"
  voice, a "concurrency" voice) raises subtle-defect recall — and whether it does
  so *without* also inflating false positives. A plausible failure of the
  machinery is that more voices flag *more* things, helping recall but hurting
  precision (more wolf-crying on the bait). If A4 finds more real defects but also
  flags md5/temp-write, the recall-precision trade is the finding.
- **Does ceremony help or just lengthen?** A reviewer that is "right and short"
  scores well here by design (the brief asks for it). If party mode produces a
  longer review with the same true-positive set plus extra noise, that's the
  over-production signature this track exists to detect — directly comparable to
  A1/A2/A3 on the same key.

Read per-arm recall, precision (false-positive count), and length together. The
publishable result is the (recall, precision, length, cost) shape per arm, not a
single score.

## Calibration

Cold-pass recall: an initial cold solo Opus 4.8 pass caught 7/8 (missing only K8)
and ate one precision bait (B1, md5) — too easy to discriminate. Hardened by
removing the two in-diff cues that let the cheap reads land: the advertising
comment that announced `get` "skips the probe" (K7) and the "Atomically"
docstring on `incr` (K3). Target spread after hardening: 4–6/8 for a cold solo
pass. Expectation: K1/K2/K6 reliably found, K5 usually, K4 sometimes, K3/K7/K8
rarely without prompting now that their self-incriminating cues are gone; watch
whether B1 (md5) still gets flagged.

## Provenance

- Repo: `cachetools` — https://github.com/tkem/cachetools
- License: MIT (Copyright (c) 2014-2026 Thomas Kemmer).
- Base commit SHA: `48284d73d0a8834c9c50f8d41bb99e6f93b2dfed`.
- Vendored: `reference/src/cachetools/__init__.py` at pre-PR state, trimmed to
  `Cache` / `FIFOCache` / `LRUCache` (the classes the PR touches or that a keyed
  finding depends on — K7 and K8 reference `LRUCache` eviction). Untouched
  classes (`LFUCache`, `RRCache`, `TTLCache`, `TLRUCache`) and the decorators were
  removed to keep the review surface focused; this is the only change to upstream
  beyond the injected diff.
- Authored here: `reference/pr.diff` (a real `git diff` that applies cleanly to
  the vendored base and parses; new file `persistent.py` plus an `__init__.py`
  edit). All eight planted defects were verified to manifest at runtime against
  the applied tree, and the five bait hunks were verified correct.


## Calibration record (2026-06-09) — re-roled: recall=floor, precision=signal



Two cold-pass rounds (Opus 4.8 solo = arm A1 stand-in). Result fed the track-wide
**detection-saturation** re-role: recall is a floor check; the keyed decoys + precision are
the objective discriminator. See `analysis/party-findings/00-detection-saturation.md` and
`harness/party/scoring-rubric.md` § Objective floor + precision axis.
