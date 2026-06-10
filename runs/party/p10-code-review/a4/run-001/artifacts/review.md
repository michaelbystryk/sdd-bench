# Code review: `cachetools.persistent` — disk persistence + thread-safety wrappers

## Summary / verdict

**Request changes.**

The PR is well-scoped and the building blocks are ones people genuinely
re-implement, so the direction is right. But it does not yet hold up under the
four conditions you flagged — concurrency, restarts, large/long-running caches,
and untrusted inputs — and several of the failures are silent (wrong data, not a
crash). The headline blocker is that `PersistentCache` deserializes **pickle**
from every file in its directory on startup, which is arbitrary code execution
if anything else can write to that directory. Underneath that sit a broken prune
(the `maxfiles` cap never actually bounds the directory), a `SyncedCache.incr`
that loses updates under exactly the concurrency it advertises, and a one-line
change to `Cache.get` that regresses `LRUCache`/`TTLCache` semantics for the
*whole existing library*. There is also a deeper design issue: memory and disk
run two independent eviction policies that diverge within minutes of real load,
so a key evicted from memory resurrects on the next restart. Most of these are
small to fix individually, but the persistence model needs one design decision
pinned first — *which tier is authoritative, and what is the durability
guarantee across a restart?* — before the line-level patches add up to something
coherent.

---

## Findings

### F1 — `_load` runs `pickle.load` on untrusted directory contents (RCE) — BLOCKER
**`persistent.py:59-65`** (round-tripped from `_write`, `persistent.py:78`)

`_load` opens every file in `directory` and feeds it to `pickle.load`. Pickle is
not a data format; unpickling executes arbitrary code via `__reduce__`. Any
process that can write a `*.cache` file into that directory — a co-tenant, a
compromised adjacent process, or an app path populated from network input —
gets code execution in this process the moment the cache restarts. The
`except Exception: continue` does **not** protect you: it catches a
deserialization *error*, but a malicious payload runs *successfully* before any
exception could fire. [ASSUMPTION] the threat model includes a directory not
exclusively owned by this process; if the directory were guaranteed private the
risk drops, but a general-purpose library cannot assume that.

*Fix:* Treat the directory as a trust boundary. Prefer a non-executing codec
(JSON for simple values, or an explicit typed serializer). If pickle must stay,
require the directory to be process-private (`os.makedirs(directory, mode=0o700)`)
and authenticate each file with an HMAC over a caller-supplied key, rejecting any
file that fails verification *before* unpickling. Document the guarantee loudly
either way.

### F2 — `_prune` deletes the wrong files and the wrong count; `maxfiles` never bounds the directory — BLOCKER
**`persistent.py:93`**

```python
names.sort(key=mtime)            # oldest first
excess = len(names) - self.__maxfiles
for name in names[1:excess]:     # bug
    os.remove(...)
```

`names[1:excess]` is a slice *bound*, not a count, and it starts at index 1.
Two defects: (a) `names[0]`, the oldest file — the one the mtime sort exists to
evict — is **never** removed; (b) it deletes `excess-1` files, not `excess`.
Worked example: `maxfiles=10`, 13 files → `excess=3`, slice `names[1:3]` removes
2 files, leaving 11 — still over the cap. With the cap exceeded by exactly one,
`excess==1` and `names[1:1]` is empty, so it never prunes at all. Under sustained
writes the directory grows without bound, defeating the feature and eventually
filling the disk on a long-running cache.

*Fix:* `for name in names[:excess]:` (index from the front; the sort is
oldest-first). See also F5 — once eviction is reconciled, pruning by mtime is the
wrong axis entirely.

### F3 — `Cache.get` bypasses overridden `__getitem__`, regressing LRU/TTL semantics — BLOCKER
**`__init__.py:89-92`**

The change from `return self[key] if key in self else default` to
`return self.__data.get(key, default)` reads the name-mangled backing dict
directly, skipping any subclass `__getitem__`. Consequences in the *existing*
library, not just the new module:

- `LRUCache.get(k)` no longer marks the key as recently used, so a hot key
  accessed only via `get` looks cold and becomes wrongly evictable.
- `TTLCache.get(k)` returns **expired** values (it bypasses the expiry
  enforcement that lives in `__getitem__`/`__contains__`) — stale data returned
  silently. [ASSUMPTION] real `cachetools` ships `TTLCache`; even if not, the LRU
  regression alone is a behavior change to a widely-used method.

*Fix:* Preserve the protocol:
```python
def get(self, key, default=None):
    try:
        return self[key]
    except KeyError:
        return default
```
This also avoids the double lookup the old `key in self` form did, so it's
strictly better than both.

### F4 — `SyncedCache.incr` is not atomic; lost updates — BLOCKER
**`persistent.py:154-158`**

```python
with self.__lock:
    value = self.__cache.get(key, 0)
value = value + amount           # lock released here
with self.__lock:
    self.__cache[key] = value
```

The lock is dropped between the read and the write across two separate critical
sections. Two threads each read `5`, each compute `6`, each store `6` — one
increment vanishes. The single method that justifies `SyncedCache`'s existence
is the one that isn't thread-safe, and it fails under exactly the concurrency
its docstring promises.

*Fix:* one critical section:
```python
def incr(self, key, amount=1):
    with self.__lock:
        value = self.__cache.get(key, 0) + amount
        self.__cache[key] = value
        return value
```

### F5 — Memory and disk eviction diverge; evicted keys resurrect on restart — BLOCKER (design)
**`persistent.py:70-80`** + `Cache.__setitem__` eviction path

When the underlying cache crosses `maxsize`, it evicts via `popitem()`. That
eviction does **not** route through `PersistentCache.__delitem__`, so the disk
file for the evicted key survives. Disk is then trimmed only by `_prune` on
mtime, which has no knowledge of what memory holds. The result is two
independent eviction authorities — size/LRU in memory, oldest-file on disk —
that drift apart under load. The user-visible failure: a key evicted from
memory but still on disk is **resurrected by `_load` on the next restart**, so
eviction is not durable but writes are. That is the inverse of what you want
from a cache, and it directly undermines the "warm cache survives restart"
promise for any long-running process.

*Fix (pick one authority):* (a) hook eviction — give `Cache` an eviction
callback, or override `popitem`/`__delitem__` in `PersistentCache`, so disk
deletes follow memory deletes; or (b) make disk the source of truth and treat
memory as a pure read-through layer with no independent eviction. Don't ship two
sources of truth. Resolving this also subsumes F2's "prune by mtime" question.

### F6 — File-descriptor leak in `_load` on corrupt/malicious files — MAJOR
**`persistent.py:59-65`**

`open()` is outside the `try`, and `f.close()` sits *after* `except: continue`,
so every file that fails to unpickle leaks its descriptor (the `continue` jumps
past the close). A directory full of bad files — post-crash truncation, or a
hostile drop — exhausts the process fd table on startup. Combined with F1 it's a
cheap denial-of-service on restart.

*Fix:* `with open(path, "rb") as f:` and move the `pickle.load` + assignment
inside the `with`, keeping `except Exception: continue` within it.

### F7 — `to_persistent` defaults to `sync=False`, silently producing a non-persistent cache — MAJOR
**`__init__.py:94`** vs **`persistent.py:42`**

`PersistentCache.__init__` defaults `sync=True`, but the advertised entry point
`Cache.to_persistent(directory, ...)` passes `sync=False`. With `sync=False`,
`_load` is skipped (`:49`) and `__setitem__` never writes through (`:72`). So
`LRUCache(...).to_persistent("/var/cache/app")` — the exact call in the PR
description — neither loads on startup nor saves anything. The user points it at
a directory, sees the directory exist, and trusts it; nothing is persisted.

*Fix:* Align the defaults and make the safe behavior the default
(`sync=True`). If `sync` is meant as a performance knob, name and document it as
such; don't let the headline API default to a no-op.

### F8 — `get_or_set` swallows all exceptions and races on miss — MAJOR
**`persistent.py:166-179`**

Two problems: (1) `except Exception: return default` (`:178`) hides genuine
factory failures — a DB timeout or a real bug surfaces as a silent default and a
cache miss, a debugging nightmare; and it provides no negative caching, so a
persistently-failing factory is re-invoked on every call (thundering herd). (2)
The miss→`factory()`→store sequence is check-then-act: under concurrency two
threads both miss and both run `factory()`. `SyncedCache` gives per-operation
safety but offers no atomic compound op except via the exposed `.lock`.

*Fix:* Don't blanket-swallow — let factory errors propagate (or narrow to an
expected type). For atomicity, acquire the cache's lock around the
double-checked miss→factory→set when one is available, or document `get_or_set`
as non-atomic. Also decide the contract for a factory that legitimately returns
`None` (currently cached and indistinguishable from absent).

### F9 — `PersistentCache` / `SyncedCache` are not `MutableMapping`s — MAJOR
**`persistent.py:32`** and **`persistent.py:119`**

Neither subclasses anything, and `PersistentCache` has no `__iter__`/`keys()`
(`SyncedCache` is missing `__len__`/`__iter__`/`pop`/`clear` too). So
`to_persistent` returns an object that quacks like a dict until you iterate it,
then doesn't — and the memoizing decorators (`@cached`) that expect the mapping
protocol will break on these wrappers.

*Fix:* Subclass `collections.abc.MutableMapping` and implement `__iter__` (you
inherit `keys/items/values/pop/...` for free), or document them explicitly as
restricted facades, not caches.

---

## Nits

- **`md5(repr(key))` filenames are non-injective** — `persistent.py:28`. Two
  distinct keys with equal `repr()` collide onto one file (last writer wins, the
  other value is silently wrong after restart), and `repr()` of dicts/sets/custom
  objects isn't stable across runs or Python versions. MD5 collision resistance
  is irrelevant; `repr`-as-identity is the hole. Derive the name from a stable
  serialization and store the key in-file to detect collisions on load. (Borderline
  MAJOR if your keys are anything other than small immutables.)
- **TOCTOU in prune sort** — `persistent.py:91`. `os.path.getmtime` raises
  `FileNotFoundError` if a file vanishes between `listdir` and `getmtime`; guard
  the key function (treat missing as `0`/skip).
- **TOCTOU on delete/clear** — `persistent.py:99-100`, `:112`. Drop the
  `os.path.exists` check and wrap `os.remove` in `try/except FileNotFoundError`.
- **`SyncedCache.__contains__` is unlocked** — `persistent.py:142`. Benign on
  CPython for a dict-backed `in`, but the class docstring claims all reads take
  the lock. Lock it or correct the docstring.
- **`PersistentCache` file ops take no lock** — wrapping it inside `SyncedCache`
  does *not* protect the disk side; document that `PersistentCache` must be the
  inner layer, or give it its own lock.
- **`os.makedirs` TOCTOU** — `persistent.py:47-48`. Use
  `os.makedirs(directory, exist_ok=True)`.
- **`_prune` cost** — `persistent.py:83`. It re-lists, stats, and sorts the
  whole directory on *every* `_write` — O(n log n) per set, O(n² log n) over a
  fill. Track a count and prune in batches.
- **Style** — semicolon-packed multi-statement lines in `__init__`/`_write`;
  one statement per line per PEP 8 for diffability.
