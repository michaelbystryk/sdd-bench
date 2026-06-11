# P10 — Answer key (SEALED, harness-only)

Code review of a feature-add PR to `cachetools` (a small MIT-licensed Python
caching library). The PR adds a `cachetools.persistent` module
(`PersistentCache`, `SyncedCache`, `get_or_set`) and wires it into the package
`__init__.py`. Eight defects of graded subtlety are injected into the diff,
alongside clean hunks that invite false positives.

Line references are to **`reference/pr.diff`** (the unified diff line number as
it appears in that file). The same code also lives, post-PR, in the build the
diff was generated from; reviewers see only `reference/`.

**This task is scored on RECALL *and* PRECISION.** A solver that flags the
precision-bait hunks (§ Precision bait) as defects loses precision. Count
confident wrong findings against the precision note per the rubric.

---

## Provenance

- Repo: `cachetools` — https://github.com/tkem/cachetools
- License: MIT (Copyright (c) 2014-2026 Thomas Kemmer)
- Base commit SHA: `48284d73d0a8834c9c50f8d41bb99e6f93b2dfed`
- Vendored at pre-PR state in `reference/src/cachetools/__init__.py` (trimmed to
  `Cache`, `FIFOCache`, `LRUCache` for a reviewable surface; `LFUCache`,
  `RRCache`, `TTLCache`, `TLRUCache`, decorators removed — they are not touched
  by the PR and would only add noise). `persistent.py` is **new** in the PR and
  therefore does not exist in the pre-PR `reference/src/`.
- The diff (`reference/pr.diff`) is a real `git diff` and applies cleanly to the
  vendored base. Defects were authored by us; the upstream code is unmodified
  apart from the trim and the injected diff.

---

## Keyed defects (8)

### K1 — Insecure deserialization: `pickle.load` of untrusted on-disk files  [severity: high / subtlety: moderate]
- What it is: `PersistentCache._load` calls `pickle.load(f)` on every file in
  the cache directory at construction time. Any attacker (or any other process)
  that can write a file into that directory achieves arbitrary code execution
  when the cache is next loaded. Pickle is not a safe format for data that
  crosses a trust boundary.
- Where detectable: `reference/pr.diff` line 99 (`key, value = pickle.load(f)`);
  the directory is attacker-influenceable per `_load` iterating `os.listdir`
  (line 95) over a caller-supplied `directory`.
- Minimum credit: identifies that loading pickled files from the cache directory
  is an arbitrary-code-execution / insecure-deserialization risk (not merely
  "pickle is slow" or "use json for portability"). Naming the fix direction
  (signed/validated payloads, a safe serializer, or restricting/owning the
  directory) is a plus but not required for credit.

### K2 — Resource leak: file handle not closed on the exception path  [severity: medium / subtlety: moderate]
- What it is: in `_load`, `f = open(path, "rb")` is opened outside a `with`
  block. On a successful load `f.close()` runs (line 105), but when
  `pickle.load` raises, the `except Exception: continue` (lines 100–101) skips
  the `close()`, leaking the file descriptor for every unreadable/corrupt file.
  Over a directory with many bad files this exhausts file descriptors.
- Where detectable: `reference/pr.diff` lines 97–103 (`open` at 97, `continue`
  at 101 bypassing `close` at 103).
- Minimum credit: identifies that the file handle leaks when load fails (the
  `open` is not context-managed and `close` is unreachable on the `except`
  path). Recommending a `with` block counts.

### K3 — Race condition: `SyncedCache.incr` is not atomic  [severity: high / subtlety: subtle]
- What it is: `incr` reads the current value under the lock, then **releases the
  lock**, computes `value + amount`, then **re-acquires** the lock to store.
  The read-modify-write is split across two separate `with self.__lock` blocks,
  so two threads can read the same starting value and one update is lost — a
  classic lost-update race. The method is the cache's "atomic counter" helper
  (the brief advertises it for "the common atomic counter in a cache" pattern),
  so callers reasonably expect it to be safe under concurrency — making the split
  a correctness bug, not just a missing nicety. Note the docstring no longer uses
  the word "atomic"; the reviewer must spot the dropped lock from the code shape,
  not from a self-incriminating comment.
- Where detectable: `reference/pr.diff` lines 192–196 — the read happens in one
  `with self.__lock:` block (line 192, `value = self.__cache.get(key, 0)`), the
  arithmetic `value = value + amount` happens *outside* any lock (line 194), and
  the store happens in a *second* `with self.__lock:` block (lines 195–196). The
  tell is the two distinct lock-acquisitions bracketing an unlocked computation.
- Minimum credit: states that `incr` is not actually atomic because the lock is
  released between the read and the write, allowing two concurrent increments to
  read the same starting value and clobber each other (lost update). Must
  identify the two-separate-locks structure (the lock dropped mid read-modify-
  write), not merely "this could be racy" or "threads are involved" — a vague
  concurrency worry without the dropped-lock mechanism does not earn credit.

### K4 — Swallowed error: `get_or_set` masks all factory failures  [severity: medium / subtlety: moderate]
- What it is: `get_or_set` wraps `value = factory()` in a bare
  `except Exception: return default`. Any error in the user's factory — a bug, a
  transient I/O failure, a `KeyError` from inside the factory — is silently
  swallowed and turned into the default value, with nothing stored and no signal
  to the caller. The cache miss is indistinguishable from a real failure, and
  bugs in `factory` become invisible. (Distinct from the docstring's documented
  "returns default on raise"; the defect is the *bare* catch-all swallowing
  genuine errors, e.g. programming bugs, with no logging or re-raise.)
- Where detectable: `reference/pr.diff` lines 214–217
  (`except Exception: return default`).
- Minimum credit: flags that catching bare `Exception` around the factory and
  returning the default hides real errors / makes failures silent. Suggesting a
  narrower catch, logging, or re-raise counts.

### K5 — Off-by-one in `_prune`: directory cap not enforced  [severity: medium / subtlety: moderate]
- What it is: `_prune` is meant to keep "at most `maxfiles`" files. It computes
  `excess = len(names) - maxfiles` but then removes `names[1:excess]` — the
  slice starts at index **1**, skipping the oldest file, so it deletes one fewer
  file than intended and never trims the directory down to the cap. Worse, when
  `excess == 1` (one file over the limit), `names[1:1]` is empty and nothing is
  removed at all, so the directory grows without bound past `maxfiles`.
- Where detectable: `reference/pr.diff` line 131 (`for name in names[1:excess]`;
  correct slice is `names[:excess]`). Supporting context: guard at line 127,
  `excess` at line 130.
- Minimum credit: identifies the slice starts at index 1 (or otherwise removes
  one too few files), so the directory exceeds `maxfiles` / the cap is not
  enforced. Pointing at `names[1:excess]` vs `names[:excess]` is the clean catch.

### K6 — Wrong default: `Cache.to_persistent(..., sync=False)` silently doesn't persist  [severity: medium / subtlety: moderate]
- What it is: the new convenience method `Cache.to_persistent` defaults
  `sync=False`. With `sync=False`, `PersistentCache` neither loads from disk on
  construction nor writes entries through to disk — i.e. the object named
  "persistent" persists nothing by default. A caller writing
  `cache.to_persistent("/var/cache/app")` reasonably expects durability and
  gets a no-op wrapper. The default contradicts the method's purpose.
- Where detectable: `reference/pr.diff` line 25
  (`def to_persistent(self, directory, maxfiles=1024, sync=False)`); behavior
  follows from `PersistentCache.__init__` gating `_load` (line 87) and
  `__setitem__` gating `_write` (line 110) on `sync`.
- Minimum credit: flags that the persistence helper defaults to `sync=False`,
  so it does not persist unless the caller opts in — a surprising/unsafe default
  for a method called `to_persistent`. (Catching that this disables BOTH load
  and write is a plus.)

### K7 — Behavior regression: `Cache.get` rewritten to bypass `__getitem__`  [severity: high / subtlety: subtle]
- What it is: the PR "optimizes" `Cache.get` from the
  `if key in self: return self[key]` form to
  `return self.__data.get(key, default)`, reading the raw backing dict directly.
  This bypasses each subclass's overridden `__getitem__`. Concretely it breaks
  `LRUCache`: `get()` used to mark the key as recently used (via `self[key]` →
  `LRUCache.__getitem__` → `__touch`); after the change a `get()` on an
  `LRUCache` no longer updates recency, so the LRU eviction order is silently
  wrong. It also bypasses any `__missing__` side effects a subclass relies on.
  This is a regression to existing, previously-correct behavior.
- Where detectable: `reference/pr.diff` lines 18–23 (the `-`/`+` rewrite of
  `get`: `+ return self.__data.get(key, default)` replacing the old
  `if key in self: return self[key]`). The change carries no explanatory comment,
  so the regression must be inferred from what `self[key]` did that `self.__data.get`
  no longer does. The pre-PR `get` is visible in
  `reference/src/cachetools/__init__.py`, and `LRUCache.__getitem__`/`__touch`
  are in that same file — the reviewer has to cross-reference the diff against
  the subclass override to see the breakage.
- Minimum credit: identifies that reading `self.__data` directly bypasses the
  overridden `__getitem__`, changing existing behavior, **and** names a concrete
  consequence — specifically that `LRUCache.get` no longer marks the key recently
  used (recency-on-get is lost), or that a subclass `__missing__` side effect is
  no longer triggered. A generic "this reads the dict directly, might skip
  subclass logic" with no named behavioral consequence is at most partial; merely
  describing it as a fast path is a miss.

### K8 — Subtle logic: evictions in the backing cache are never mirrored to disk  [severity: medium / subtlety: subtle]
- What it is: `PersistentCache.__setitem__` writes the *new* key's file but the
  backing cache (which may be a bounded `LRUCache`/`FIFOCache`) silently evicts a
  *different* key via `popitem` when it overflows. That eviction is never
  reflected on disk: the evicted key's file is left behind. Consequences are
  second-order and compounding — (a) the on-disk set diverges from memory and
  grows unbounded with the backing cache's churn (the `maxfiles` prune is the
  only bound, and it's broken — see K5); and (b) on the next restart `_load`
  resurrects keys that were evicted from memory, so a bounded cache silently
  comes back over capacity / with stale entries it had already dropped.
- Where detectable: `reference/pr.diff` lines 108–111 (`__setitem__` writes only
  `key`'s file, with no hook for the cache's eviction); the eviction path is
  `Cache.__setitem__` → `popitem` in
  `reference/src/cachetools/__init__.py`, which `PersistentCache` wraps but does
  not observe. The reload-resurrects-evicted behavior follows from `_load`
  (diff lines 93–103).
- Minimum credit: states that when the backing cache evicts an entry on
  overflow, `PersistentCache` does not delete that entry's file, so disk and
  memory diverge (orphaned files and/or evicted keys resurrected on reload).
  Catching either the unbounded-disk-growth or the resurrection-on-restart
  consequence counts; a generic "what if the cache is full?" without the
  disk/memory divergence does not.

---

## Precision bait (CLEAN — flagging these as defects costs precision)

These hunks look suspicious to a fast reviewer but are correct for this code.
A confident finding asserting any of them is a defect counts against precision.

- **B1 — md5 for filenames.** `_key_filename` uses `hashlib.md5` (diff line 66).
  md5 is broken *as a security hash*, but here it is only used to derive a stable
  on-disk filename from a key; collision resistance and preimage resistance are
  not security-relevant for that use. "md5 is insecure, use sha256" is a false
  positive. (A *correctness* nit about md5 collisions causing two distinct keys
  to share a file is technically defensible but astronomically unlikely and not
  a planted defect; treat a calm mention as a nit, not a finding, and do not
  award recall for it.)
- **B2 — temp-file + `os.replace` write.** `_write` (diff lines 113–119) writes
  to `path + ".tmp"` then `os.replace(tmp, path)`. This is the *correct* atomic
  write-then-rename pattern; `os.replace` is atomic on the same filesystem.
  Flagging it as a race or partial-write risk is a false positive.
- **B3 — `os.path.exists` before `os.remove` in `__delitem__`.** Diff lines
  136–137. Looks like a TOCTOU, but there is no security decision hanging on the
  check and a benign race just means the file is already gone. Not a defect.
- **B4 — `except KeyError: pass` in `get_or_set`.** Diff lines 212–213. Looks
  like a swallowed error, but catching `KeyError` from `cache[key]` is exactly
  how a cache miss is detected here (the `Cache` base raises `KeyError` via
  `__missing__`). This catch is correct; the swallowed-error defect is the
  *factory* catch (K4), not this one.
- **B5 — `SyncedCache.get` delegates to `self.__cache.get` under the lock.**
  Diff lines 183–185. Correct: it holds the lock for the delegated read. (Note:
  `SyncedCache.__contains__`, diff lines 180–181, reads *without* the lock,
  which is a genuine minor inconsistency — see "Additional valid findings". The
  `get` itself is fine.)

---

## Additional valid findings (correct; do NOT penalize, do NOT require)

Real but minor issues a strong reviewer may surface. They are NOT among the 8
keyed items, so missing them costs no recall; raising them (calmly, correctly)
costs no precision and may be credited as nits under the rubric. Asserting any
of them as a *severe* defect, or inventing a wrong mechanism, still counts
against precision.

- `SyncedCache.__contains__` (diff 180–181) reads without taking the lock while
  every other operation locks — an inconsistency, though `in` on a dict is
  effectively atomic in CPython so impact is low. A reviewer noting the
  inconsistency is correct.
- `PersistentCache._load` ignores `maxfiles`, so a directory that already
  contains more than `maxfiles` files is loaded wholesale (related to K5/K8).
- `clear()` (diff 148–151) `os.remove`s *every* name in the directory, including
  any unrelated/`.tmp` files a crash left behind — acceptable but worth a note.
- No locking integration between `PersistentCache` and `SyncedCache`; composing
  them (`PersistentCache(SyncedCache(...))`) still does unguarded disk I/O.

---

## Difficulty spread

- Obvious/moderate: K1 (pickle), K2 (leak), K6 (wrong default), K5 (off-by-one),
  K4 (swallowed error).
- Subtle: K3 (lock dropped mid read-modify-write — the two-separate-locks shape
  is now the only tell; the "Atomically" docstring cue was removed during
  hardening, so the reviewer must read the lock structure), K7 (regression that
  must be inferred by cross-referencing the rewritten `get` against
  `LRUCache.__getitem__`/`__touch` in `reference/src/`; the advertising "fast
  path" comment was removed during hardening), K8 (second-order eviction/disk
  divergence — requires reasoning about the *backing* cache's eviction, which is
  not in the diff but is in `reference/src/`).

A cold solo pass is expected to reliably catch K1, K2, K6 and probably K5; to
sometimes catch K4; and to rarely catch K3, K7, and K8 now that their in-diff
cues are gone — and to be tempted by B1 (md5) and B2 (temp-file write).
