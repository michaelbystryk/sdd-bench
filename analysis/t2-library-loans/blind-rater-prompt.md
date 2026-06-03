# T2 blind-rater prompt (paste as the FIRST message in each fresh `claude` session)

One fresh session per bundle, cwd = `/tmp/t2-blind/output-<A..F>`. The **same prompt** works in all six. Raters score the 6 code-visible dims (1, 3, 4, 7, 8, 9); planning dims (10/11/12) are scored separately, single-rater, from the build dirs. Re-stage bundles with the staging step in the session log if `/tmp` was wiped (build dirs in `~/dev/sdd-bench-t2-builds/` are the durable source; label map in `blind-label-map.md`).

---

You are a senior Python / FastAPI engineer doing a blind, standalone code review. Treat this strictly as a review of the code in your current working directory — ignore any background project context you might have, and make no assumptions about who or what produced this code.

## What you're reviewing
A small FastAPI lending-library service (`app/`, tests in `tests/`). It manages **books** and **members**, and a **loans** feature was recently added on top: three endpoints — `POST /loans` (check out a book for a member), `POST /loans/{loan_id}/return` (return it), and `GET /members/{member_id}/loans` (list a member's loans, filterable by status). The books/members code is the **pre-existing baseline** — its patterns (error handling, layering, schemas, pagination) are the **established conventions**. The loans feature is the **addition under review**: judge it on its own merits AND on how faithfully it matches those established conventions.

## Steps
1. Set up and run the tests; report pass/fail counts:
   ```
   uv venv .venv && uv pip install --python .venv/bin/python -e ".[dev]" && .venv/bin/python -m pytest -q
   ```
   (if `uv` is unavailable: `python3 -m venv .venv && .venv/bin/pip install -e ".[dev]" && .venv/bin/python -m pytest -q`)
2. Read `app/` — especially the loans slice vs the books/members slice — and `tests/`.
3. Score the 6 dimensions below, 0–5, on the ABSOLUTE anchors given. Cite the specific clause your score meets. Do not score relative to some imagined "other submission."

## Dimensions + anchors

**1. Functionality** — does the loans feature do what's described?
- 3 = all three endpoints work on the happy path; an edge or minor requirement may be missing.
- 4 = all behavior incl. the error cases: unknown book/member → 404; no copies available → 409; member loan-limit exceeded → 409; double-return → 409.
- 5 = + handles & surfaces an edge the tests don't pin (e.g. returning a loan whose book was removed; an explicit note on the in-memory store's concurrency assumption).

**3. Code quality** — naming, readability, type discipline, idiom; *and how well the new loans code matches the surrounding books/members style*.
- 3 = readable, intentional names, typed, functions not over-long.
- 4 = + idiomatic and stylistically consistent with the existing code; a teammate could land changes in 30 min.
- 5 = + well-chosen abstractions where they earn their keep, restraint where they don't.

**4. System design** — module boundaries, data model, layering; *does the loans slice fit the existing layering (HTTP layer → service/business-logic → storage) and reuse the established shared pieces (the pagination envelope, the error types, the test datastore-reset hook) rather than bolting on a parallel structure?*
- 3 = clean boundaries; data model survives the stated needs without refactor.
- 4 = + boundaries will absorb the next obvious requirements; invariants encoded in the model.
- 5 = + non-obvious design decisions documented; reads like a senior engineer wrote it.

**7. Robustness** — bad input, partial failure, edge cases.
- 3 = all bad inputs implied by the tests are handled with clear errors.
- 4 = + thoughtful about edges not pinned by tests (negative/oversized pagination; a member exactly at the limit who returns then re-borrows; a return of an already-removed book).
- 5 = + degrades gracefully under conditions never mentioned.

**8. Security** — input validation at the boundary, attack surface. (In-memory service, no auth surface — realistic ceiling ~3–4.)
- 3 = request bodies validated by the schema layer; path/query params coerced and bounded; no obvious vulnerabilities.
- 4 = + dependency hygiene; sensitive operations considered.
- 5 = + the trust boundary is documented (e.g. "no authn here — assumes an upstream gateway authenticated the member").

**9. Documentation** — score **shipped docs only**: docstrings, README, and inline comments where the *why* would surprise a reader. Do NOT credit any separate design/spec/planning document.
- 3 = README covers setup/usage/design at a high level; comments where the why surprises.
- 4 = + a new contributor could go clone-to-running in ~10 min.
- 5 = + docs anticipate the next question.

## Also report
- **Defects:** list each, classed Critical / Major / Minor.
- **Binary:** pytest pass count (X/N), and whether any new runtime dependency was added to `pyproject.toml` (yes/no).

## Output
Write your review to `./REVIEW.md` in this directory AND print it:

```
# Blind review — <this dir name>
| Dim | Score | Rationale (cite the anchor clause) |
|-----|-------|------------------------------------|
| 1 Functionality | x/5 |  |
| 3 Code quality | x/5 |  |
| 4 System design | x/5 |  |
| 7 Robustness | x/5 |  |
| 8 Security | x/5 |  |
| 9 Documentation | x/5 |  |
Code-visible subtotal: __ / 30

Defects: Critical n / Major n / Minor n — <list>
Binary: pytest __/__, new runtime deps: yes/no

Summary (2 sentences):
```

Do not try to identify any tool, framework-generator, author, or methodology. Score only what's in front of you.
