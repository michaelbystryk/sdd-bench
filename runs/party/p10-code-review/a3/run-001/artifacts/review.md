# Code review: `cachetools.persistent` (disk-backed + thread-safe wrappers)

## Summary / verdict

**Request changes.**

The PR is well-scoped and the building blocks are the right ones — these are genuinely
patterns people re-implement on top of `cachetools`. The problem is that the *single
headline behavior* of each of the three components is currently broken:
`SyncedCache.incr` is not atomic, `PersistentCache`'s `maxfiles` cap deletes nothing in
the common case (directory grows unbounded), and `Cache.to_persistent(...)` returns a
cache that silently never touches disk. On top of that, the underlying cache's own
evictions are never propagated to disk, so a long-running process accumulates stale files
and *resurrects evicted values on restart* — exactly the "long-running cache + restart"
scenario the review brief calls out. None of these are deep design problems; they're
concrete, fixable bugs, but each one defeats the purpose of the feature it lives in, so
they block merge. There is also one unrelated core-behavior regression riding along in
`Cache.get` that should be reverted. The pickle-based load path is an inherent
trust-boundary tradeoff that is acceptable *if* documented loudly. Once the blockers below
are addressed (ideally with the concurrency and restart tests that would have caught
them), this is mergeable.

Severity legend: **Blocker** = wrong under normal use, must fix before merge ·
**Major** = correctness/behavior issue, fix before merge or document as a known limitation ·
**Minor** = worth fixing, not merge-blocking.

---

## Findings

### 1. `SyncedCache.incr` is not atomic — **Blocker**
`persistent.py:149–159`

`incr` takes the lock, reads, **releases the lock**, computes `value + amount`, then
re-acquires the lock to write:

```python
with self.__lock:
    value = self.__cache.get(key, 0)
value = value + amount
with self.__lock:
    self.__cache[key] = value
```

Two threads can both read `5` and both write `6`; one increment is lost. This is the one
method whose entire reason for existing is atomicity. **Fix:** hold the lock across the
whole read-modify-write:

```python
def incr(self, key, amount=1):
    with self.__lock:
        value = self.__cache.get(key, 0) + amount
        self.__cache[key] = value
        return value
```

### 2. `_prune` does not enforce `maxfiles`; directory grows unbounded — **Blocker**
`persistent.py:93`

```python
for name in names[1:excess]:
    os.remove(...)
```

After sorting oldest-first, removing `excess` files requires `names[:excess]`. As written:
in the steady-state case (`excess == 1`, i.e. one file over the cap on each write),
`names[1:1]` is **empty** and nothing is deleted — the cap is never enforced and the
directory grows without bound. The slice also always skips index `0`, so the genuinely
oldest file is never removed. **Fix:** `for name in names[:excess]:`. Consider excluding
`*.tmp` from `names` so in-flight writes aren't counted toward the cap (see Finding 7).

### 3. `Cache.to_persistent` defaults to `sync=False` → silently non-persistent — **Blocker**
`__init__.py` (`to_persistent`, the `sync=False` default) and `persistent.py:42–48`

`PersistentCache.__init__` defaults `sync=True`, but `to_persistent` passes `sync=False`.
With `sync=False`, `__setitem__` skips `_write` *and* `__init__` skips `_load`, so the
object never reads or writes disk. The result is that the headline example from the PR
description —

```python
LRUCache(...).to_persistent("/var/cache/app")
```

— returns a cache that does **not** persist anything, with no error. **Fix:** make the
`to_persistent` default match the constructor (`sync=True`). Separately, `sync` currently
conflates two independent concerns — *write-through on set* and *load-on-construction*.
Consider splitting them (e.g. `write_through=True`, `load=True`) so callers can opt into
each; the single flag makes "persist but don't reload" and "reload but don't write"
unexpressible.

### 4. Underlying-cache evictions are never removed from disk → stale resurrection — **Blocker**
`persistent.py:70–73` (`__setitem__`) interacting with the wrapped cache's `popitem`

`PersistentCache.__setitem__` does `self.__cache[key] = value`. When the wrapped cache
(e.g. `LRUCache`) overflows `maxsize`, it evicts internally via its own `popitem()` →
`__delitem__`. That eviction path **never goes through `PersistentCache.__delitem__`**, so
the evicted key's file stays on disk indefinitely. Consequences, all hitting the exact
"long-running cache + restart" case the brief flags:

- Disk grows with dead entries independent of `maxsize` (only the broken `maxfiles` prune
  ever touches them — see Finding 2).
- The on-disk eviction policy (`_prune` by mtime) is fully decoupled from the in-memory
  policy (LRU/FIFO); the two sets diverge.
- On restart, `_load` reads the stale files back and **resurrects values the cache had
  already evicted**, in arbitrary `os.listdir` order.

**Fix:** route evictions through the persistence layer. The clean version is to make
`PersistentCache` a real `MutableMapping` and either subscribe to the wrapped cache's
eviction or override `popitem`/`__delitem__` so file deletion happens whenever a key
leaves the cache. At minimum, if this is deferred, it must be documented as a known
limitation, because stale-resurrection-after-restart is a production surprise.

### 5. Unrelated regression: `Cache.get` no longer touches LRU / bypasses `__missing__` — **Major**
`__init__.py` (`get` method, changed to `return self.__data.get(key, default)`)

The PR rewrites `Cache.get` from `return self[key]` to a direct backing-dict read. For
`LRUCache`, the old path went through `__getitem__`, which marks the key as recently used;
the new path reads `__data` directly and **skips the recency touch**, so `LRUCache.get()`
no longer counts as a use. It also bypasses `__missing__` for any subclass that relies on
it. This is a silent behavior change in the core class, unrelated to the PR's stated
purpose. **Fix:** revert this hunk. If there's an independent motivation (e.g. avoiding a
double lookup), make it its own PR with tests asserting LRU recency is preserved.

### 6. `_load`: leaked file handles + over-broad exception swallowing — **Major**
`persistent.py:55–65`

```python
f = open(path, "rb")
try:
    key, value = pickle.load(f)
except Exception:
    continue          # <-- f is never closed on this path
self.__cache[key] = value
f.close()
```

On the `continue` path the file handle is never closed (one leaked FD per unreadable
file), and `except Exception: continue` silently hides corruption or malformed data from
the operator. **Fix:** use a `with` block and, at minimum, log the skipped file:

```python
for name in os.listdir(self.__directory):
    path = os.path.join(self.__directory, name)
    try:
        with open(path, "rb") as f:
            key, value = pickle.load(f)
    except Exception:
        # log + skip corrupt/foreign file
        continue
    self.__cache[key] = value
```

### 7. Key→filename derivation is not collision-free or stable — **Major**
`persistent.py:28` (`_key_filename = md5(repr(key))`)

`repr(key)` is neither injective nor stable: two distinct keys with equal repr collide to
the same file (silent overwrite / data loss on reload), and objects using the default
`repr` embed their memory address, so the filename changes every run and the entry can
never be reloaded. For a persistence layer this is a fidelity bug. **Fix:** derive the
filename from a serialization of the key (e.g. `hashlib.sha256(pickle.dumps(key))`), and
document that keys must be picklable. At minimum, document that keys must have stable,
distinct reprs. (`pickle.dump` already stores the real key in the file, so reload fidelity
of the *value* is fine — the issue is purely the filename mapping.)

### 8. `pickle.load` over a directory = code execution on untrusted input — **Major (must document)**
`persistent.py:59–60`

`_load` unpickles every file in `directory`. If anything untrusted can write there (shared
`/var/cache`, world-writable temp, a co-tenant), the **next process start executes
arbitrary code**. This is the standard `shelve`/pickle trust-boundary property and is
arguably acceptable for an opt-in disk cache — but it must be stated in unmissable terms.
**Fix:** add a prominent security warning to the `PersistentCache` docstring and README
("the cache directory is a trust boundary; never point this at a directory writable by
untrusted parties"), and create the directory with restrictive permissions
(e.g. `os.makedirs(directory, mode=0o700, exist_ok=True)` — see Finding 9).

### 9. `os.makedirs` race / TOCTOU — **Minor**
`persistent.py:47–48`

`if not os.path.exists(directory): os.makedirs(directory)` races two processes starting
together (and has a check-then-act gap), raising `FileExistsError`. **Fix:**
`os.makedirs(directory, exist_ok=True)`.

### 10. `get_or_set` swallows all factory exceptions; "called once" doesn't hold under threads — **Minor/Major**
`persistent.py:178–179`

`except Exception: return default` makes a *bug in the factory* indistinguishable from a
miss that returns `None`, with nothing logged or stored — a hard-to-diagnose silent
failure. The PR description's "called once on a miss" guarantee also only holds
single-threaded: concurrent callers race and run the factory multiple times. **Fix:**
don't catch (let factory errors propagate), or narrow the `except` to a documented set;
and document that the helper is not atomic across threads (wrap with `SyncedCache`'s lock
for exactly-once).

---

## Nits

- **`SyncedCache.__contains__` (`persistent.py:142–143`)** doesn't take the lock, contradicting
  the class docstring ("reads return a snapshot under the lock"). Harmless under the GIL,
  but inconsistent — guard it for uniformity.
- **`SyncedCache` uses a plain `Lock` while exposing `self.lock`** (`persistent.py:151, 161–162`).
  A caller who does `with synced.lock:` and then calls another `SyncedCache` method
  deadlocks. Prefer `threading.RLock()` given the lock is part of the public surface.
- **`SyncedCache` "snapshot" wording** (docstring, `persistent.py:120`): reads return the same
  object reference, not a copy — callers mutating it bypass the lock. Reword to avoid
  implying isolation.
- **`md5(...)` under FIPS** (`persistent.py:28`): raises in FIPS-mode environments. Pass
  `usedforsecurity=False` (3.9+) or switch to `sha256`. [ASSUMPTION] supported Pythons are
  ≥3.9, so `usedforsecurity=False` is available; if older versions are still supported,
  prefer `sha256`.
- **`.tmp` files share the cache directory** (`persistent.py:77–79`): they're counted by
  `_prune` and fed to `pickle.load` in `_load`. Either write temp files outside the scanned
  set or filter `*.tmp` in both `_load` and `_prune`.
- **`PersistentCache` is not a full `MutableMapping`**: no `__iter__`, `keys/items`, `pop`,
  `setdefault`, `update`, and no `maxsize`/`currsize` passthrough, despite claiming to "wrap
  any of our caches." `for k in pcache` raises. Making it subclass `MutableMapping` would
  also be the natural place to fix Finding 4. Not a merge blocker on its own, but the
  intended end state.
- **Missing tests.** A concurrency test for `incr`, a "fill past `maxfiles`" test for
  `_prune`, and a "set → restart → read" round-trip test for `PersistentCache` would each
  have caught a blocker above; please add them with the fixes.
