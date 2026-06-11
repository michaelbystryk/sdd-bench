# Review: `cachetools.persistent` — disk persistence + thread-safety wrappers

## Summary / verdict

**Request changes.**

The PR is well-organized and the three building blocks are sensible additions. But
several of the bugs are in exactly the areas you flagged as load-bearing —
concurrency, restarts, and unbounded growth — and two of them defeat the stated
purpose of the feature they live in. Specifically: `SyncedCache.incr` is not
atomic (it drops the lock mid-increment), so the "atomic counter" use case it
exists for is racy; `PersistentCache._prune` has an off-by-one that pins the
oldest file forever and lets the directory exceed `maxfiles`; the `to_persistent`
convenience method defaults to `sync=False`, which silently disables both
persistence and reload; and the drive-by rewrite of `Cache.get` changes
`LRUCache` recency semantics for all existing users. There's also an
unauthenticated `pickle.load` over directory contents to think through. None of
this is hard to fix, but it shouldn't merge as-is.

---

## Findings

### 1. [Blocker] `SyncedCache.incr` is not atomic — `persistent.py:187`

`incr` takes the lock to read, **releases it**, computes, then re-takes it to
write:

```python
with self.__lock:
    value = self.__cache.get(key, 0)
value = value + amount
with self.__lock:
    self.__cache[key] = value
```

Two threads can both read `0`, both write `1`; one increment is lost. This is the
exact race the method exists to prevent. Fix — hold the lock across the whole
read-modify-write:

```python
def incr(self, key, amount=1):
    with self.__lock:
        value = self.__cache.get(key, 0) + amount
        self.__cache[key] = value
        return value
```

### 2. [Blocker] `_prune` off-by-one — never evicts oldest, exceeds `maxfiles` — `persistent.py:131`

```python
excess = len(names) - self.__maxfiles
for name in names[1:excess]:
    os.remove(...)
```

After sorting ascending by mtime, removing `excess` oldest files should be
`names[:excess]`. As written, `names[1:excess]` (a) skips index 0 — the oldest
file is **never** deleted — and (b) removes only `excess - 1` files. Worked
example, `maxfiles=2`, files oldest→newest `[a,b,c,d,e]`, `excess=3`: it deletes
`[b,c]`, leaving `[a,d,e]` (3 files, and `a` pinned forever). In steady
incremental use the directory stabilizes at `maxfiles + 1` and the oldest entry
is immortal, so stale data can resurrect on restart. Fix: `for name in
names[:excess]:`.

### 3. [Blocker / Bug] `Cache.to_persistent(...)` is a no-op by default — `__init__.py:25`

`to_persistent` defaults `sync=False`, but `sync` gates **both** writing
(`__setitem__`) and loading (`_load`). So `LRUCache(...).to_persistent("/var/cache/app")`
— the headline example from the PR description — returns a wrapper that neither
mirrors writes to disk nor loads existing files; it's a pure in-memory
passthrough. This also contradicts `PersistentCache.__init__`'s own default of
`sync=True`. Fix: default `to_persistent(..., sync=True)` to match, or drop the
`sync` knob's double duty (see #8).

### 4. [High] Drive-by `Cache.get` rewrite changes `LRUCache` recency semantics — `__init__.py:18`

```python
def get(self, key, default=None):
    return self.__data.get(key, default)
```

`self.__data` is the base `_Cache__data` dict, so this bypasses the subclass
`__getitem__`. Previously `get` called `self[key]`, which for `LRUCache` runs
`__touch` and marks the key recently used. After this change, `LRUCache.get()`
no longer counts as an access, which silently changes eviction behavior for
every existing caller — unrelated to the persistence feature. Either revert this
to the original `if key in self: return self[key]` form, or split it into a
separate, clearly-described change with its own rationale and test.

### 5. [High] `_load` leaks file handles on every corrupt file — `persistent.py:96`

```python
f = open(path, "rb")
try:
    key, value = pickle.load(f)
except Exception:
    continue          # <-- f.close() is skipped
self.__cache[key] = value
f.close()
```

The `continue` on unpickle failure skips `f.close()`, so each corrupt or partial
file (including leftover `.tmp` files from a crash mid-write) leaks a descriptor.
On a warm directory after a few crashes this can exhaust the fd limit at startup.
Fix with a context manager:

```python
for name in os.listdir(self.__directory):
    try:
        with open(os.path.join(self.__directory, name), "rb") as f:
            key, value = pickle.load(f)
    except Exception:
        continue
    self.__cache[key] = value
```

### 6. [High / Security] Unauthenticated `pickle.load` over directory contents — `persistent.py:99`

`_load` unpickles every file in `directory`. Anyone who can write to that
directory gets arbitrary code execution in the loading process — and cache dirs
often live in shared/world-readable locations (`/tmp`, `/var/cache`). The
`except Exception: continue` does **not** mitigate this, because the malicious
payload executes during `pickle.load`, before any exception. At minimum this
needs a prominent docstring/README warning that the directory is a trust boundary
and must be private to the owning user. Better: gate it behind an explicit opt-in,
or use a non-executing format for the value (e.g. JSON) where the value type
allows. [ASSUMPTION] I'm treating this as "library used by trusted local
processes," which keeps it High rather than Critical — but it must be called out
because users will point this at world-writable paths.

### 7. [Medium] Disk mirror and in-memory eviction are uncoordinated — `persistent.py:108`

When the underlying cache evicts on `__setitem__` (LRU/FIFO `popitem`), the
evicted key's file is **not** removed from disk — only explicit `__delitem__`
deletes files. Consequences: (a) the directory accumulates files for keys no
longer in memory; (b) on restart, `_load` reads *all* files in arbitrary
`os.listdir` order and re-inserts them, so which `maxsize` entries survive is
determined by filesystem order, not recency — a restart can resurrect long-evicted
keys and drop live ones. If `PersistentCache` is meant to mirror the cache, it
should observe evictions (e.g. reconcile in `__setitem__` after the underlying
write, or load in a deterministic order and cap to `maxsize`). At minimum,
document that disk is a superset of memory and reload order is undefined.

### 8. [Medium] `SyncedCache` uses a non-reentrant `Lock` but invites compound use via `.lock` — `persistent.py:164`

The `lock` property exists so callers can do compound operations under the same
lock — but the natural usage deadlocks:

```python
with synced.lock:
    synced[key] = synced.get(key, 0) + 1   # __setitem__ re-acquires the same Lock -> deadlock
```

Because the methods re-acquire `self.__lock`, any method call while holding the
exposed lock hangs. Use `threading.RLock()` as the default (and document that a
caller-supplied lock must be reentrant if they intend to use `.lock`).

### 9. [Medium] `PersistentCache` assumes exclusive ownership of `directory` and deletes indiscriminately — `persistent.py:95, 126, 148`

`_load` tries to unpickle *every* file, `_prune` removes the oldest files
*regardless of name*, and `clear()` removes *everything* in the directory. If a
user points this at a directory that contains anything else (a shared cache dir,
a misconfigured path), their unrelated files get deleted. Scope all operations to
the suffix the module owns — only `listdir`-filter and delete `*.cache` files —
and document that the directory must be dedicated.

---

## Nits / minor

- **`_prune` cost** (`persistent.py:119/121`): `_prune` runs on every `__setitem__`,
  doing a full `listdir` + `getmtime` per file each time — O(n log n) per write.
  For large `maxfiles` on a hot cache this is a real tax; consider pruning
  periodically (e.g. every N writes) or tracking count in memory.
- **Incomplete mapping protocol**: neither `PersistentCache` nor `SyncedCache`
  subclasses `MutableMapping` or implements `__iter__` / `keys` / `items` / `pop` /
  `popitem` / `setdefault` / `update`. They aren't drop-in replacements, and
  `popitem`/`__iter__` gaps mean they likely can't back the memoize decorators.
  Subclassing `MutableMapping` and forwarding `__iter__`/`__len__` gets most of
  this for free (note: `update`/`pop` would then route through your
  `__setitem__`/`__delitem__`, which is what you want).
- **`repr(key)` filenames** (`persistent.py:66`): keys whose `repr` is
  address-based (default objects) won't survive a restart, and `1` / `1.0` / `True`
  produce different files for equal dict keys. Fine for string/tuple memo keys;
  worth a docstring note about key requirements.
- **`SyncedCache.__contains__`** (`persistent.py:180`) is not taken under the lock,
  inconsistent with the "reads under the lock" docstring. Harmless on CPython but
  cheap to make consistent.
- **`os.makedirs(directory)`** (`persistent.py:86`) without `exist_ok=True` has a
  TOCTOU race against the preceding `os.path.exists`; two processes starting
  together can raise. Use `os.makedirs(directory, exist_ok=True)` and drop the
  `exists` check.
- **MD5** (`persistent.py:66`): fails on FIPS-restricted builds; pass
  `usedforsecurity=False` or use `hashlib.sha256` to be safe.
- **`get_or_set` swallows every `Exception`** (`persistent.py:216`) and returns
  `default` silently — it's documented, but it will mask real bugs in `factory`.
  Consider narrowing, or at least letting it be configurable.
