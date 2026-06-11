# Review: `cachetools.persistent` — disk persistence + thread safety

## Summary / verdict

**Request changes.**

The shape of the API is good and the module is small and readable, but several
of the load-bearing pieces are incorrect in exactly the situations this PR
exists to handle: the thread-safe counter loses updates under contention, the
disk-eviction cap never reaches its target (and never evicts the oldest file),
the headline convenience method writes nothing to disk by default, and a
seemingly unrelated change to `Cache.get` silently breaks `LRUCache` recency for
the *entire* library. None of these are deep design problems — they're all
small, local fixes — but each one defeats a promise the PR makes, so I wouldn't
merge until they're addressed. I verified the four blockers below by running the
applied diff (see notes inline).

---

## Findings

### 1. [BLOCKER] `SyncedCache.incr` is not atomic — lost updates under contention
`persistent.py:152–159` (the `incr` body)

The read and the write happen under **two separate** lock acquisitions, with the
`value + amount` computed in between while no lock is held:

```python
with self.__lock:
    value = self.__cache.get(key, 0)
value = value + amount          # <-- gap: another thread can read the same value
with self.__lock:
    self.__cache[key] = value
```

Two threads can both read `n`, both compute `n+1`, and both store `n+1`, losing
an increment. This is the one operation in the module whose entire reason for
existing is atomicity, so it's a true defeat-of-purpose bug. I confirmed it: with
8 threads × 50 increments (expected 400) I measured **51**.

**Fix:** do the whole read-modify-write under a single lock:

```python
def incr(self, key, amount=1):
    with self.__lock:
        value = self.__cache.get(key, 0) + amount
        self.__cache[key] = value
        return value
```

### 2. [BLOCKER] `_prune` never enforces `maxfiles` and never evicts the oldest file
`persistent.py:94` — `for name in names[1:excess]:`

The slice is wrong twice over. After sorting ascending by mtime, to drop the
`excess` oldest files you want `names[:excess]`. `names[1:excess]` (a) skips
index 0, so the single oldest file is *never* removed, and (b) removes only
`excess − 1` files. I confirmed that with `maxfiles=4` the directory stabilizes
at **5** files regardless of how far over it goes, and the oldest entry lives
forever. So the "keeps the directory from growing without bound" guarantee is
off by one permanently, and a stale entry is pinned indefinitely.

**Fix:**

```python
for name in names[:excess]:
    os.remove(os.path.join(self.__directory, name))
```

(Consider tolerating concurrent removal with `try/except FileNotFoundError`.)

### 3. [BLOCKER] `Cache.to_persistent` defaults to `sync=False` → persistence is a silent no-op
`__init__.py` — `def to_persistent(self, directory, maxfiles=1024, sync=False)`

`PersistentCache.__init__` defaults `sync=True` (and the PR description documents
`sync=True`), but the convenience method overrides it to `sync=False`. With
`sync=False`, `_load()` is skipped *and* `_write()` is skipped, so the exact call
the PR advertises —

```python
LRUCache(...).to_persistent("/var/cache/app")
```

— produces an object that never loads existing data and never writes anything to
disk. I confirmed: after `to_persistent(d); p['x'] = 42`, the directory is empty.
This makes the flagship feature inert by default.

**Fix:** make the default `sync=True` to match `PersistentCache` and the docs.

### 4. [BLOCKER] `Cache.get` rewrite drops `LRUCache`/subclass recency
`__init__.py` — `def get(self, key, default=None): return self.__data.get(key, default)`

The old `get` did `if key in self: return self[key]`, routing through
`__getitem__`. `LRUCache.__getitem__` is what marks a key as recently used, so
under the old code `get()` counted as a use. The new `get` reads `self.__data`
directly and bypasses `__getitem__` entirely, so **`LRUCache.get()` no longer
updates recency** — and any subclass that does work in `__getitem__` (stats,
TTL refresh, etc.) is now bypassed by `get`. This is a library-wide behavioral
regression buried in a persistence PR. Verified: `get('a')` no longer protects
`'a'` from eviction.

**Fix:** leave `Cache.get` as it was, or if the optimization is wanted, override
it only where the no-touch semantics are actually correct. At minimum this
shouldn't ride along silently in this PR.

### 5. [MEDIUM] `_load` leaks a file descriptor and aborts construction on a bad entry
`persistent.py:60–66`

```python
f = open(path, "rb")        # outside the try
try:
    key, value = pickle.load(f)
except Exception:
    continue                # <-- f is never closed
self.__cache[key] = value
f.close()
```

Two problems: (a) on the `except: continue` path `f` is never closed (FD leak,
one per corrupt/partial file — including the `.tmp` files a crashed write leaves
behind); (b) `open()` is *outside* the `try`, so any unreadable file or a
subdirectory in the cache dir raises and aborts `__init__`. Verified: a
subdirectory in the cache dir makes construction die with `IsADirectoryError`.

**Fix:** use a context manager and guard the open:

```python
for name in os.listdir(self.__directory):
    path = os.path.join(self.__directory, name)
    try:
        with open(path, "rb") as f:
            key, value = pickle.load(f)
    except Exception:
        continue
    self.__cache[key] = value
```

### 6. [MEDIUM] Untrusted-input / RCE surface: `pickle.load` over every file in the directory
`persistent.py:60–64` and the module's trust model generally

On construction the cache unpickles every file in `directory`. `pickle.load` on
attacker-controlled bytes is arbitrary code execution. A path like
`/var/cache/app` is plausibly group- or world-writable, or shared between
services, which makes "warm-start a cache from disk" a code-execution vector.
The `except Exception` does **not** help — the payload runs *during*
`pickle.load`, before any exception. This deserves at least a prominent doc
warning that the directory must be trusted, and ideally a safer default
serializer (e.g. JSON for the common str/number cases) with pickle opt-in.

### 7. [MEDIUM] Disk and memory diverge; mtime pruning ignores cache policy
`persistent.py` — `_write`/`_prune` vs. the underlying cache's eviction

When the underlying cache evicts a key (LRU/FIFO `popitem` on overflow), the
corresponding disk file is **not** removed — only `__delitem__` removes files,
and eviction doesn't go through it. Conversely `_prune` removes files purely by
mtime, independent of which keys are hot in memory. Net effect: the disk set and
the in-memory set drift apart, and on restart `_load` can resurrect keys that
were evicted from memory long ago (capped only by `maxfiles`, not `maxsize`). At
minimum document that disk retention is governed by `maxfiles` and is independent
of the cache's eviction policy; better, hook eviction so dropped keys are also
unlinked.

### 8. [MEDIUM] `_prune` runs an O(n) `listdir` + `getmtime`-per-file scan on every write
`persistent.py:84–94` (`_write` calls `_prune` unconditionally)

Every `__setitem__` does a full directory listing plus a `getmtime` stat on every
file. For a cache near `maxfiles` (default 1024) that's ~1024 stat calls per set,
which will dominate write cost on a busy cache. Prune lazily (e.g. only every N
writes, or only when `len(names) > maxfiles` is already known cheaply) rather
than on every single write.

---

## Nits

- **`PersistentCache` isn't a `MutableMapping`** (`persistent.py:70`). It
  implements `__getitem__/__setitem__/__delitem__/__contains__/get/clear/__len__`
  but lacks `__iter__`, `keys`/`items`, `pop`, `setdefault`, `popitem`, and the
  `maxsize`/`currsize` properties. So it isn't a drop-in for a `Cache` and won't
  iterate or work with code (or memoizing decorators) that expects the full
  mapping API. Worth subclassing `collections.abc.MutableMapping` and delegating.
- **`SyncedCache.__contains__` (`persistent.py:143`) and the exposed `lock`
  (`persistent.py:162`) are inconsistent.** `__contains__` reads without the lock
  while every other accessor takes it; and `lock` is a plain non-reentrant
  `threading.Lock`, so a caller doing `with synced.lock:` and then calling any
  `SyncedCache` method deadlocks. Lock `__contains__` too, and consider
  `threading.RLock` (or document the constraint). `SyncedCache` is also missing
  `__len__`/`__iter__`.
- **`get_or_set` swallows all exceptions** (`persistent.py:179`,
  `except Exception: return default`). A genuine bug in `factory` is silently
  masked as a cache miss returning `default`. Consider narrowing what's caught,
  or letting it propagate.
- **`makedirs` TOCTOU** (`persistent.py` `__init__`): `if not os.path.exists:
  os.makedirs(...)` races; use `os.makedirs(directory, exist_ok=True)`.
- **Key filename derivation** (`persistent.py:29`): `md5(repr(key))` trips FIPS
  builds (use `usedforsecurity=False`) and `repr` collisions map distinct keys to
  one file (last writer wins on disk). Minor, but worth a comment on the
  assumption that `repr` is injective enough for the keys in use.
- **`sync` conflates two concerns** — load-on-construct *and* write-through are
  both gated on the one flag, so you can't load-but-don't-write or vice versa.
  Fine to keep, but the name suggests fsync durability, which isn't provided
  (`os.replace` is atomic per-file but there's no fsync of file or directory).
