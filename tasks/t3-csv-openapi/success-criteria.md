# T3 — Success Criteria (v0.1)

T3 (CSV import endpoint to OpenAPI spec, spec-bound greenfield, medium
complexity / low ambiguity — *the workhorse*) scoring. Applied after a cell
completes; used identically across methodologies.

Universal rubric (anchors, defect-count protocol, blinding):
[`harness/scoring-rubric.md`](../../harness/scoring-rubric.md). This file
declares T3-specific binary outcomes, which dimensions apply, and
task-specific scoring detail.

---

## 1. Binary outcomes (pass/fail, reported as a list)

| Outcome | Pass condition |
|---|---|
| **Tests pass** | All 14 tests in `tests/test_imports.py` pass. Report partial pass count if not all (e.g., 11/14). |
| **No new dependencies** | No additions to `pyproject.toml` runtime dependencies beyond the pinned set (`fastapi`, `uvicorn`, `pydantic[email]`, `python-multipart`, `httpx`). The task is solvable on the existing stack. |
| **Pydantic v2 idiom** | No v1 surface used in shipped code: no `from pydantic import Config`-style nested `class Config`, no `parse_obj`/`parse_raw`, no `.dict()` (use `.model_dump()`), no `.json()` (use `.model_dump_json()`), no `@validator` (use `@field_validator`). Static check: `grep -nE 'parse_obj|parse_raw|\.dict\(\)|\.json\(\)|@validator\b' app/` returns nothing in cell code. |
| **Async handler** | The POST handler is `async def`, not sync `def`. |
| **File-size limit enforced** | `test_file_too_large_returns_413` passes — implementation enforces the documented 10 MB limit (whether by `Content-Length`, accumulated bytes during read, or starlette/FastAPI config). |

A cell that fails some tests still gets scored on every dimension — partial
implementation is data. Note the pass count.

## 2. Dimensions applied

10 of the 12 dimensions. **UI (dim 5) and UX (dim 6) are `n/a`** — no
end-user UI surface (pure HTTP API). **Security (dim 8) applies and is
load-bearing** — untrusted multipart upload is a real attack surface.

Three dimensions are **load-bearing for T3**:

- **Dim 4 (System design)** — endpoint layering, separation of validation /
  storage / response shaping, in-memory store design (lifecycle decisions),
  and whether the per-row vs whole-file error split is structurally encoded
  rather than scattered.
- **Dim 7 (Robustness)** — the CSV-edge handling (BOM, embedded newlines,
  mixed line endings, large files, missing columns, type/range mismatches)
  is the primary surface; the per-row partial-success semantics are pinned by
  tests but the *quality* of the row-level error messages and edge handling
  is scored here.
- **Dim 8 (Security)** — file-size limit, content-type validation, defending
  the trust boundary on an untrusted upload. A 5 requires documenting the
  trust boundary explicitly (see anchor).

Two dimensions carry the **C-axis ambiguity-surfacing** signal:

- **Dim 11 (Scope clarity)** — did the cell name what's in/out for the
  retention question? "Imports held in-memory for the process lifetime, lost
  on restart, no eviction" is a level-3 scope statement.
- **Dim 12 (Assumption surfacing)** — did the cell flag the retention
  decision as an assumption (e.g. `[ASSUMPTION: imports persist until process
  restart; no TTL or eviction]`), or pick a default silently?

## 3. T3-specific scoring detail

### Functionality — does the endpoint do what the brief asked

To score 4+: all 14 tests pass AND row-level error messages are useful (not
"Validation error" with no field, no code). Score 5 only if the
implementation handles an edge category not pinned by the tests — e.g.
trailing-whitespace tolerance in headers, an explicit `Content-Length` check
that 413s before any bytes are read, or a documented response on extra
columns (ignore vs error).

### System design — how the API is built

The bar:
- A clear separation between **CSV parsing**, **per-row validation**, and
  **HTTP response shaping**. A single 200-line endpoint handler that does
  all three scores 2; a clean layering scores 4+.
- In-memory store design: a `dict[UUID, ImportResult]` in module scope is
  serviceable (3). A small wrapper that encodes lifecycle decisions
  (eviction, TTL — even just `# no eviction` is enough to encode "we made a
  choice") scores 4. A documented trade-off scores 5.
- Per-row vs whole-file error split structurally encoded (e.g. raises
  `WholeFileError` subclasses caught by an exception handler that emits the
  envelope) scores 4+. Inline `raise HTTPException` scattered through the
  parser scores 3.

### Robustness — CSV edge handling + error message quality

For 3: tests pass. For 4: row-level error messages include the failing
field, the offending value, and a stable `code`; not just "invalid" or "see
above". For 5: the implementation handles an edge the tests don't exercise
— e.g. duplicate column names in the header, BOM in mid-file (not just
leading), or a documented stance on null/empty cells (`,,` → missing vs
empty string).

### Security — the trust-boundary

In-memory service, no auth in scope, but a real attack surface (untrusted
file upload). Realistic ceiling for an unauthn'd in-memory service is **4**;
score 5 only if the cell explicitly documents the trust boundary in code or
a docstring (e.g. "this endpoint trusts that an upstream gateway has rate-
limited and authenticated the caller; file content is treated as untrusted
beyond the documented size + content-type checks"). Bonus credit doesn't
require it, but the 5 anchor does. Common 4-tier behaviors: explicit
Content-Length and/or accumulated-byte check before reading the whole file;
content-type validation; ensuring no path-traversal sink exists for the
filename.

### Documentation

Score **shipped docs only**: docstrings, README, inline comments where the
*why* would surprise a reader. Do NOT credit planning artifacts here (those
go to dim 10). A README that explains how to run + how to test + names the
in-memory storage caveat scores 4. A README that anticipates the retention
question ("imports are not persisted across process restart; this is by
design for v1 — see ADR-001") scores 5.

### Spec articulation (planning artifact quality)

For methodologies that produce planning artifacts (OpenSpec, Spec Kit,
AI-DLC, BMAD): does the artifact correctly characterize the **silent
discriminators**?
- Per-row vs whole-file separation called out before code is a strong signal.
- Pydantic v2 idiom assumed (not surfaced for decision) is fine — it's the
  obvious choice from `pydantic[email]>=2.6` in pyproject; flagging it as a
  decision wastes signal.
- Retention/lifecycle of stored imports is the C-axis: surfacing it (asked
  or assumption-tagged) is a strong signal; designing the GET endpoint
  without acknowledging it is a weak signal.
- Async streaming for the large-file case named in advance is a strong
  signal.

For Vibe (no methodology layer): the "spec" is commit messages + code
comments. Score these as the methodology's articulation.

### Scope clarity + Assumption surfacing — the C-axis discriminator

The deliberate ambiguity is **retention of past imports**. There are four
observable behaviors per cell:

| Behavior | Scope (dim 11) | Assumptions (dim 12) |
|---|---|---|
| Surfaced the question, asked PM, documented the answer | 4–5 | 4–5 |
| Surfaced as `[ASSUMPTION]` / ADR, didn't ask, picked a default | 3.5–4 | 3.5–4 |
| Didn't surface; in-memory dict; mentioned in README/docstring as caveat | 2.5–3 | 2–3 |
| Didn't surface; in-memory dict; no mention anywhere | 1–2 | 0–1 |

This is the cleanest single signal of "did the methodology force the cell
to notice spec gaps."

## 4. Failure-mode characterization (qualitative, for observations.md)

T3 has known failure modes worth flagging:

- **Pydantic v1 surface in shipped code** — `parse_obj`, `.dict()`,
  `@validator`, nested `Config` class. The static-grep binary catches the
  egregious case; subtler ones (using `.copy()` instead of `.model_copy()`)
  are caught in code review.
- **Sync handler** — `def` instead of `async def` on the POST. Blocks the
  event loop for the duration of CSV parsing.
- **Whole-file load** — `await file.read()` then `csv.reader` on the bytes.
  Works on small files; would not survive a real 10 MB upload under load.
  Often paired with sync handler. Score under Robustness + Security (the
  413 limit might happen *after* loading the whole file into memory, which
  defeats the purpose).
- **Partial-success treated as 4xx** — a single bad row causes the whole
  request to 400. Caught by `test_single_row_type_mismatch_is_row_level_not_whole_file`.
- **Inconsistent error envelope** — different shapes per error type
  (`{detail: ...}` for 422, `{error: ...}` for 400, raw string for 413).
  The spec locks the envelope; deviation is a Major.
- **Retention silently picked** — GET works, but no comment / no PM
  question / no assumption tag about how long imports live or what happens
  on restart. The dominant failure mode for the C-axis; expected for Vibe,
  surprising for structured cells.
- **Hardcoded delimiter / encoding** — `csv.reader(... delimiter=",")` with
  no consideration for the BOM or non-comma separators. The BOM case is
  test-pinned (defect if test fails); non-comma is out of scope but a
  comment noting it scores Robustness +0.5.
- **Custom validation instead of Pydantic** — building a hand-rolled
  validator that bypasses the model. Loses the v2 idiom + halves the value
  of `pydantic[email]`. Score under Code quality + System design.

## 5. Headline finding for T3

Expected interesting contrasts:

- **The silent v2 trap.** The brief and spec describe behavior, not
  implementation. `pydantic[email]>=2.6` is in pyproject — Opus 4.7 should
  pick v2 idiom by default, but a cell anchoring on stale v1 patterns
  (especially under heavy planning that references training data instead
  of reading the deps) could regress. T3's binary v2-idiom check is the
  trap test.
- **The C-axis retention question.** Will Vibe silently pick `dict` in
  module scope, ship it, and never mention it? Will Spec Kit's
  `/speckit-clarify` ask? Will BMAD's PRD list it as a deferred decision?
  Will OpenSpec's design.md surface it? This is the cleanest single
  per-cell discriminator T3 will produce.
- **Per-row vs whole-file split.** Cells that frame the problem as "validate
  the file" will tend to 400 the whole request on the first bad row; cells
  that frame it as "validate each row" will partial-success cleanly. The
  spec is explicit ("Status 200 is returned even when some or all rows fail
  row-level validation"); a cell that misses this is reading the spec
  shallowly.
- **CSV edges.** Embedded newlines + BOM + mixed line endings are real-
  world traps for hand-rolled parsers; Python's `csv` module handles them
  correctly when used correctly. The discriminator is whether the cell
  uses `csv` or rolls its own with `.split(",")` / `.splitlines()`.

If a structured methodology surfaces the retention ambiguity (via
clarifying question OR assumption tag) and Vibe doesn't, **that's the
T3 finding: on a spec-bound greenfield task, the value of methodology is
forcing the cell to notice what the spec leaves silent.** If Vibe also
surfaces it (or if no structured methodology does), that's the opposite
finding and just as publishable.

---

*v0.1 locked structure. Refine when methodology runs produce real failure
data. Base state at lock: no `app/main.py` shipped → tests fail at collection
on `ModuleNotFoundError: No module named 'app.main'` (the expected baseline).*
