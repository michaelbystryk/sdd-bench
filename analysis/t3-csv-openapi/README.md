# analysis/t3-csv-openapi/

T3 — CSV import endpoint to OpenAPI spec: build a `POST /imports/users` (CSV
upload → per-row validation → summary + per-row results) plus
`GET /imports/{import_id}` (cached lookup) against a fully-specified contract
(medium complexity / LOW ambiguity — *the workhorse*). Spec-bound greenfield;
the OpenAPI spec + the 14 pytest tests are the discovery surface (no `app/`
to extend).

## Status

**Task BUILT 2026-05-27** (no cells run yet). The cell-facing surface is
locked and leak-scanned blind:

- `../../tasks/t3-csv-openapi/brief.md` — 9-line cell-facing brief (silent
  on v2-vs-v1, async, partial-success-vs-malformed, retention)
- `../../tasks/t3-csv-openapi/reference/openapi.yaml` — the contract (2
  endpoints, locked error envelope `{error: {code, message, details?}}`,
  pinned error codes, file-size + row limits)
- `../../tasks/t3-csv-openapi/reference/sample_csvs/` — 11 fixtures (happy,
  partial_success, malformed_quotes, missing_email_column,
  type_mismatch_age, embedded_newlines, utf8_bom, crlf, mixed_endings,
  unicode_names, empty)
- `../../tasks/t3-csv-openapi/starter/` — `pyproject.toml` (FastAPI,
  pydantic[email]>=2.6, uvicorn, python-multipart, httpx; pytest dev) +
  empty `app/__init__.py` + `tests/test_imports.py` (14 tests; verified
  coherent against a throwaway reference impl — impl was deleted, not
  shipped, per the T1 pattern)
- Run folders scaffolded:
  `../../runs/t3-csv-openapi/{vibe,vibe-planmode,openspec,spec-kit,ai-dlc,bmad}/run-001/`
  with session-log + token-log + test-result + observations + artifacts/

**Silent discriminators** (deliberately NOT in the brief; cell must derive
from spec+tests):

1. **Pydantic v2 idiom** — the locked trap; v1 patterns (`Config`,
   `parse_obj`, `.dict()`) silently fail subtle assertions. Static
   `grep` is the binary check.
2. **Async correctness** — `async def` handler + non-blocking file handling.
3. **Per-row vs whole-file error semantics** — one bad row stays 200 + per-row
   error; only whole-file problems return 4xx. Pinned by tests; cells
   missing the split tend to 400 on first bad row.
4. **CSV edges** — BOM, embedded newlines, mixed line endings, unicode, file
   size 413, missing columns 400. Real-world traps if a cell rolls its own
   `.split(",")` parser instead of using `csv`.
5. **Retention of past imports (the C-axis ambiguity)** — GET requires
   *something* to remember the data; spec is silent on lifecycle. Did the
   cell ask the PM? Tag it as an assumption? Pick a default silently? This
   is the single sharpest per-cell discriminator T3 will produce.

## Inputs (when scoring begins)

- Task brief: `../../tasks/t3-csv-openapi/brief.md`
- OpenAPI contract: `../../tasks/t3-csv-openapi/reference/openapi.yaml`
- Test suite (objective scorer): `../../tasks/t3-csv-openapi/starter/tests/test_imports.py`
- Success criteria: `../../tasks/t3-csv-openapi/success-criteria.md`
- Per-cell observations: `../../runs/t3-csv-openapi/<methodology>/run-NNN/observations.md`
- Cell artifacts (post-save): `../../runs/t3-csv-openapi/<methodology>/run-NNN/artifacts/`

## Blind scoring plan (v0.3 protocol, applied from the start per T2 precedent)

When cells complete (operator runs them via
`run-cell.sh t3-csv-openapi <meth> 001`):

1. Stage 6 anonymized **code+tests-only** bundles at `/tmp/t3-blind/output-{A..F}`:
   each contains `app/` + `tests/` + `pyproject.toml` only. **Strip every
   methodology tell**: planning dirs (`openspec/`, `.specify/`,
   `_bmad-output/`, `aidlc-docs/`, `CLAUDE.md`, `.aidlc-rule-details/`), all
   planning docs, identifying strings, BMAD/Spec-Kit/AI-DLC vocabulary in
   comments. Re-scan clean.
2. Randomized label map → `blind-label-map.md` (compile-time key; reveal only
   after both passes score).
3. Rater prompt → `blind-rater-prompt.md` (adapted from T2's: 6 code-visible
   dims, absolute anchors, "treat this strictly as a review of the code in
   your cwd").
4. **Pass 1:** operator runs 6 fresh `claude` sessions, one per bundle.
5. **Pass 2 — run alongside pass 1, NOT as an afterthought:** 6 fresh sonnet
   subagents from the orchestrator session, instructed to ignore any
   `REVIEW.md` and write `REVIEW-2.md`. (T2's pattern of pass-2-as-followup
   left the audit with stale headlines for hours — don't repeat.)
6. Operator single-rates planning dims (10/11/12) from un-anonymized build
   dirs.
7. Compile `scoring-matrix.md` + `feature-matrix.md` + `blind-pass-audit.md`
   mirroring T2's structure.
8. Update `analysis/README.md` and `analysis/handoff.md`.

## Template (use when starting feature-matrix.md)

Copy `../t2-library-loans/feature-matrix.md`'s structure. For T3 the rows
are: each of the 14 tests (pass/fail per cell), the 4 silent discriminators
(v2 idiom / async / per-row split / retention surfacing), error-envelope
consistency, CSV-edge handling depth.
