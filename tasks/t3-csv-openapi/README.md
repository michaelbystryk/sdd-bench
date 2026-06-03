# T3 — CSV import endpoint (harness notes)

⚠️ **`brief.md` is pasted verbatim into every methodology cell**, and
`run-cell.sh` seeds the contents of `starter/` to the cell root and the
contents of `reference/` (the OpenAPI spec + sample CSVs) under `reference/`.
Everything seeded is cell-facing — **no eval/harness framing in any of it.**

**Critical for T3:** the scored discriminators are deliberately NOT enumerated
in `brief.md`. The cell must read `reference/openapi.yaml` + `tests/` to find
them. Listing them in the brief would invalidate the measurement. The four
silent discriminators are:

- **Pydantic v2 idiom** — the silent trap; models trained on v1 patterns can
  produce v1 code (`Config` class, `parse_obj`, `dict()`) that fails subtle
  assertions. The brief and spec must never mention "v2" or contrast with v1.
- **Async correctness** — `async def` handler + non-blocking file handling. The
  brief must not say "use async" or "stream the file"; the spec describes
  behavior + limits, not implementation.
- **Per-row vs whole-file error semantics** — a single bad row is reported in
  `results` with `status: "error"` and the request still returns 200; only
  whole-file problems (malformed CSV, missing columns, empty file, too large)
  return 4xx. This separation is pinned by `test_single_row_type_mismatch_is_row_level_not_whole_file`
  and `test_partial_success_returns_200_with_per_row_results_in_order`. The
  brief must not narrate the distinction.
- **Retention of past imports** — the spec is silent on lifecycle. GET requires
  *something* to remember the data, but no test pins retention behavior. This
  is the deliberate ambiguity that probes whether the cell surfaces the
  question (Scope/Assumptions dims) or just picks a default silently. Never
  hint that this is intentional.

The seeded `starter/` is intentionally minimal: `pyproject.toml`, an empty
`app/__init__.py` (so `pip install -e ".[dev]"` works), and the test suite.
**No `app/main.py`, no application code, no docstrings that enumerate
conventions.** T2's anti-pattern was convention-naming docstrings in `app/`
that handed the discriminator to the cell without it having to read.

**Where the design lives (harness-only, never seeded into a cell):**
- Rationale + behavioral spec + the silent discriminators: this file +
  `PROJECT-BRIEF.md` § Task Set
- Scoring — binary outcomes, dimensions applied, task-specific detail:
  `success-criteria.md`
- Run protocol: `harness/operator-runbook.md`

**Cell-facing surface** (seeded): `brief.md`, `starter/`, `reference/`.
**Harness-only** (not seeded): this README, `success-criteria.md`.
