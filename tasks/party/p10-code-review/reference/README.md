# Review materials

- `pr.diff` — the pull request as a unified diff (`git diff`). This is what you
  are reviewing.
- `src/cachetools/` — the relevant source at its **pre-PR** state, so you can
  read the diff in context. `__init__.py` here is the file the PR modifies;
  `persistent.py` is **new** in the PR, so it appears only inside `pr.diff`, not
  under `src/`.

`cachetools` is a small, widely-used Python caching library (in-memory caches
plus memoizing decorators). The PR adds disk-backed and thread-safe wrappers on
top of the existing in-memory caches. To apply the diff locally if you want a
working tree:

```
cd src/..            # a dir whose child is src/
git init && git add -A && git commit -m base
git apply pr.diff
```
