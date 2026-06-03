# T3 blind-rater prompt (used by every pass-1 + pass-2 subagent)

One fresh subagent per bundle, cwd = `/tmp/t3-blind/output-<A..F>`. **Same prompt** used in all six bundles. Raters score the 6 code-visible dims (1, 3, 4, 7, 8, 9); planning dims (10/11/12) are scored separately, single-rater, from the build dirs.

**Pass 1 raters** write to `./REVIEW.md`. **Pass 2 raters** are instructed to ignore any existing `./REVIEW.md` and write to `./REVIEW-2.md` (so they cannot anchor to pass 1).

Re-stage bundles by replaying the staging step (rsync excludes) from `~/dev/sdd-bench-t3-builds/`. Label map at [`blind-label-map.md`](blind-label-map.md).

---

You are a senior Python / FastAPI engineer doing a blind, standalone code review. Treat this strictly as a review of the code in your current working directory — ignore any background project context you might have, and make no assumptions about who or what produced this code.

## What you're reviewing

A FastAPI service that imports a CSV of users:

- `POST /imports/users` — accept a multipart CSV upload, validate each row against a schema, return `{import_id, total, succeeded, failed, results: [...]}` with per-row status + per-field errors.
- `GET /imports/{import_id}` — retrieve a past import's results.

The full contract lives in `reference/openapi.yaml`. Sample CSV fixtures (happy path, malformed quotes, missing required columns, type mismatches, partial success, embedded newlines, UTF-8 BOM, CRLF/LF/mixed line endings, unicode names, empty file) live in `reference/sample_csvs/`. The test suite at `tests/test_imports.py` pins behavior (14 tests).

Spec-pinned constraints worth knowing:
- Whole-file errors (malformed CSV, missing required columns, empty file, file too large) → 4xx with `{error: {code, message, details?}}` envelope and one of: `malformed_csv`, `missing_required_columns`, `empty_file`, `file_too_large`, `import_not_found`.
- Row-level failures → **status 200** with per-row `status: "error"` and `errors: [{field, code, message}]`. The whole-file-vs-row-level split is contract-critical (a single bad row must NOT 400 the request).
- Max file size 10 MB → 413; max 100,000 data rows.
- Encoding: UTF-8; leading BOM permitted and must be stripped.

## Steps

1. Set up and run the tests; report pass/fail counts:
   ```
   uv venv --python 3.11 .venv && uv pip install --python .venv/bin/python --quiet -e ".[dev]" && .venv/bin/python -m pytest -q
   ```
   (if `uv` is unavailable: `python3 -m venv .venv && .venv/bin/pip install -e ".[dev]" && .venv/bin/python -m pytest -q`)
2. Read `app/` (the implementation) and `tests/` (what's pinned).
3. Score the 6 dimensions below, 0–5, on the ABSOLUTE anchors given. Cite the specific clause your score meets. Do not score relative to some imagined "other submission."

## Dimensions + anchors

**1. Functionality** — does the implementation do what's described?
- 3 = all required behavior present and works on the happy path; an edge or minor requirement may be missing.
- 4 = + handles the four whole-file error cases (`malformed_csv`, `missing_required_columns`, `empty_file`, `file_too_large`) with correct codes; per-row error semantics correctly distinguished from whole-file errors; CSV edges (embedded newlines, BOM, CRLF/LF/mixed, unicode) all handled.
- 5 = + handles an edge the tests don't pin (e.g. trailing-whitespace header tolerance, duplicate column names in header, BOM mid-file, explicit Content-Length check that 413s before any bytes are read, documented stance on extra columns or empty cells).

**3. Code quality** — naming, readability, type discipline, idiom (Pydantic v2 / FastAPI / Python async).
- 3 = readable, intentional names, typed, functions not over-long.
- 4 = + idiomatic for Pydantic v2 (no `parse_obj`/`parse_raw`/`.dict()`/`.json()`/`@validator` — uses `model_validate`/`model_dump`/`@field_validator`/`Field(..., ge=...)`/`Literal`) and FastAPI async; sensible helpers; a teammate could land changes in 30 min.
- 5 = + well-chosen abstractions where they earn their keep, restraint where they don't.

**4. System design** — module boundaries, data model, layering; *does the implementation separate CSV parsing / per-row validation / HTTP response shaping / storage, and structurally encode the per-row vs whole-file error split (rather than scattering `raise HTTPException` through the parser)? Is the in-memory store a thin module-level dict, or a small wrapper that encodes lifecycle decisions?*
- 3 = clean boundaries; data model survives the stated needs without refactor; per-row vs whole-file split present but possibly inline.
- 4 = + clear separation of parse/validate/store/shape (typically multiple modules); per-row vs whole-file split structurally encoded (e.g. typed exception caught by a handler); reuses Pydantic models rather than hand-rolling validators; the next obvious requirement absorbs without rewrite.
- 5 = + non-obvious design decisions documented; reads like a senior engineer wrote it.

**7. Robustness** — bad input, partial failure, edge cases; quality of row-level error messages.
- 3 = all bad inputs implied by the tests are handled with clear errors.
- 4 = + row-level error messages include the failing field, code, and a value-aware message (not just "invalid"); thoughtful about edges not pinned by tests (BOM, trailing whitespace, encoding fallback, content-type, duplicate columns).
- 5 = + degrades gracefully under conditions never mentioned (memory-bounded streaming for large files actually achieves bounded memory — not just chunked-read followed by `b"".join(chunks)`).

**8. Security** — input validation at the boundary, untrusted-file-upload trust surface, attack surface. **T3-specific: file upload is a real attack surface — scoreable to 5.**
- 3 = request bodies validated; path params coerced; no obvious vulns; **basic file-size limit enforced** (rejects oversized uploads with 413 before exhausting memory).
- 4 = + content-type validation; explicit byte-count check happens *during* the read (chunked / streaming) so a malicious oversized upload doesn't get fully buffered before rejection; dependency hygiene; no path-traversal sinks on filenames.
- 5 = + the trust boundary is documented in code or a docstring (e.g. "this endpoint trusts that an upstream gateway has rate-limited and authenticated the caller; file content is treated as untrusted beyond the documented size + content-type checks").

**9. Documentation** — score **shipped docs only**: docstrings, README, and inline comments where the *why* would surprise a reader. Do NOT credit any separate design/spec/planning document.
- 3 = README covers setup/usage/design at a high level OR comprehensive docstrings; comments where the why surprises.
- 4 = + a new contributor could go clone-to-running in ~10 min; in-memory storage caveat named (the data is lost on restart).
- 5 = + docs anticipate the next question (e.g. "imports are not persisted across process restart; this is by design — see ADR-001").

## Also report

- **Defects:** list each, classed Critical / Major / Minor. Critical = crash / wrong answer / data loss / security vuln. Major = a feature claimed to work doesn't in a real-user scenario. Minor = cosmetic, edge case, polish. (Source: T = test failure, M = manual exercise, R = code review.)
- **Binary:** pytest pass count (X/14), and whether any new runtime dependency was added to `pyproject.toml` beyond `fastapi`, `uvicorn`, `pydantic[email]`, `python-multipart`, `httpx`.

## Output

Write your review to `./REVIEW.md` in this directory AND print it (pass-2 raters write to `./REVIEW-2.md` and ignore any existing `./REVIEW.md`):

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

Defects: Critical n / Major n / Minor n — <list each with severity, source T/M/R, brief evidence>
Binary: pytest __/14, new runtime deps: yes/no

Summary (2 sentences):
```

Do not try to identify any tool, framework-generator, author, or methodology. Score only what's in front of you. Half-point increments allowed where evidence sits genuinely between two adjacent anchors.
