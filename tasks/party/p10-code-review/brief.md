# Review request: disk-backed and thread-safe cache wrappers

We maintain `cachetools`, a small Python caching library: a handful of in-memory
cache classes (`LRUCache`, `FIFOCache`, etc.) plus memoizing decorators. A
contributor has opened a PR adding persistence and thread-safety wrappers, and
I'd like a thorough code review before we merge.

The diff is in `reference/pr.diff`. The files it touches are vendored at their
pre-PR state under `reference/src/` so you can read the change in context (the
new `persistent.py` module is in the diff itself). Please review the diff as you
would any incoming PR.

## What the PR is meant to do (the contributor's description)

> **Add `cachetools.persistent`: write-through disk persistence + thread safety**
>
> This adds a small module with three building blocks that people keep
> re-implementing on top of cachetools:
>
> - **`PersistentCache(cache, directory, maxfiles=1024, sync=True)`** — wraps any
>   of our caches and mirrors every write to a directory on disk as a file, so a
>   warm cache survives a process restart. On construction it loads whatever is
>   already in the directory back into the underlying cache. A `maxfiles` cap
>   keeps the directory from growing without bound by trimming the oldest files.
> - **`SyncedCache(cache, lock=None)`** — wraps a cache with a lock so it can be
>   shared across threads. Includes an `incr(key, amount=1)` helper for the
>   common "atomic counter in a cache" pattern.
> - **`get_or_set(cache, key, factory, default=None)`** — the usual
>   compute-if-absent helper: return the cached value, or call `factory()` once
>   on a miss, store it, and return it.
>
> Also adds a `Cache.to_persistent(directory, ...)` convenience method so callers
> can write `LRUCache(...).to_persistent("/var/cache/app")`, and re-exports the
> three new names from the package root.
>
> Targets our existing supported Python versions; no new dependencies (stdlib
> `pickle`, `hashlib`, `os`, `threading` only).

## What I want from the review

This is going into a library a lot of people depend on, so I care about
correctness under real usage — concurrency, restarts, large/long-running caches,
and untrusted inputs — not just whether the happy path works. Tell me what you'd
want fixed before this merges, what's a blocker vs. a nit, and for anything you
flag, where it is and what you'd change. If a part looks fine, you don't need to
pad the review by commenting on it.

The contributor is competent and the PR is generally reasonable; assume good
faith and be specific. I'd rather have a short review that's right than a long
one that cries wolf.

## Deliverable

Produce `review.md` as a standalone Markdown document with these sections:
**Summary/verdict** (merge / merge-with-changes / request-changes, plus a
one-paragraph overall read); **Findings** (each with: severity, `file:line`,
the problem, and a suggested fix); **Nits** (optional — minor/style points kept
out of Findings). Target length: ~2 pages.

## A note on ambiguity

If anything is ambiguous, make a reasonable assumption and tag it [ASSUMPTION].
