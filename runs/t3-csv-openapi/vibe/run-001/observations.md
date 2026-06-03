# T3 — Vibe (vanilla Claude Code — control) / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims (1/3/4/7/8/9) from independent blind raters on the anonymized bundle (see [blind-label-map](../../../../analysis/t3-csv-openapi/blind-label-map.md) when scored); planning dims (10/11/12) single-rater from build-dir artifacts. UI/UX = n/a (HTTP API). Security applies and is load-bearing (untrusted multipart upload). PROVISIONAL.

## Binary outcomes
14/14 tests · no new deps · v2-idiom (vacuous — zero Pydantic models) · async handler · 413 enforced → **5/5**

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | **4** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 3 | Code quality | **3** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 4 | System design | **3** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 7 | Robustness | **3.5** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 8 | Security | **3** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 9 | Documentation | **1** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 10 | Spec articulation | **0** | single | No spec artifact exists (Vibe). The "spec" surrogates the rubric allows for Vibe (code comments / README / commits) are essentially absent: exactly one inline comment (main.py:105, `# utf-8-sig strips a leading BOM if present.`), no README, no docstrings on either endpoint, no commits (no git init). Constants at module top (`REQUIRED_COLUMNS`, `ALLOWED_COUNTRIES`, `MAX_FILE_BYTES`, `MAX_DATA_ROWS`) encode the spec implicitly but add no decisions beyond a literal restatement of openapi.yaml. Meets anchor 0: "No spec produced. Or spec is a restatement of the brief with no decisions added." (Per rubric §10 Vibe footnote: "if there's no spec artifact, score 0 honestly — that's the data.") |
| 11 | Scope clarity | **1** | single | No in/out scope statement anywhere — no README, no docstrings, no decision log. **Implicit** scope choices exist: hand-rolled validation (in scope) vs Pydantic models (out — deps unused), in-memory dict (in scope) vs persistence (out — no mention), per-row vs whole-file split on column-count mismatch chose whole-file (no rationale). None of these are *named*. The C-axis retention question is silently picked, not surfaced. Sits between anchor 0 ("No statement of what's in or out of scope. Implicit only.") and anchor 1 ("Mentions scope but doesn't explain choices.") — leaning to 1 because the *limits constants* (`MAX_FILE_BYTES`, `MAX_DATA_ROWS`) are nominally a "in-scope boundaries" statement, even if just transcribed from the spec. |
| 12 | Assumption surfacing | **0** (count: 0) | single | Zero `[ASSUMPTION]` tags, zero ADRs, zero decision-log lines, zero docstrings. The single inline comment (BOM) is a what-it-does note, not an assumption. Multiple silent assumptions ship in code: in-memory storage with no eviction (retention), hand-rolled email regex deemed sufficient over `pydantic[email]`, whole-file 400 on column-count mismatch, country enum hardcoded in app code, no rate limiting / auth. None are named. Meets anchor 0: "No assumptions surfaced." |

**Quality sum: 18.5/45** (blind code avg 17.5/30 + planning single-rater 1/15) · Vector → **Product (Func+Rob) /10: 7.5** · **Rigor (Code+Sys+Sec+Doc+Spec+Scope+Assum) /35: 11**

## Defects (from manual review — no manual exercise run beyond pytest)

- **Critical:** 0
- **Major:** 0
- **Minor:** 1
  - Country-validation error message exposes Python list repr to the API consumer: `f"country must be one of {sorted(ALLOWED_COUNTRIES)}"` → `country must be one of ['AU', 'CA', 'DE', 'FR', 'JP', 'UK', 'US']` (main.py:81). Cosmetic / minor UX.

Latent / judgment-call items (not counted, flagged for blind raters):
- Streaming chunk-reader correctly trips 413 at 10 MB *before* materializing the full file, then the next line `body = b"".join(chunks)` re-materializes anyway, defeating the "stream to avoid OOM" intent on accepted files. Whole CSV is then re-buffered via `list(reader)`. (Robustness / Security.)
- Whole-file 400 on row-level column-count mismatch — spec is silent; defensible but not surfaced as a decision. (System design / Scope.)
- Hand-rolled email regex while `pydantic[email]>=2.6` sits unused in deps — inverse of the v2 idiom the spec was probing. (Code quality / System design.)

Format: `Critical: 0 | Major: 0 | Minor: 1 (T: 0 / M: 0 / R: 1)`
Defect density: 1 / (183 LOC / 1000) = **5.5 defects/1KLOC**

## Cost (see token-log)

$0.93 implied API cost · **3m 36s API compute** · 689.7 K tokens · 183 LOC (app/main.py only; app/__init__.py is empty)

| Ratio | Value | Notes |
|---|---|---|
| Quality per 1K tokens | **0.0268** | 18.5 / 689.7K tokens (per 1K tokens) |
| Quality per API hour | **308.3** | 18.5 / 0.060 h |
| Defects per 1KLOC | **5.5** | 1 minor / 0.183 KLOC |
| Methodology overhead ratio | **n/a** | Vibe has no explicit planning phase |
| Cost per binary outcome | **$0.186** | $0.93 / 5 |
| Quality per dollar | **19.89** | 18.5 / $0.93 |

## Depth / routing

**Artifacts produced:** none. No `openspec/`, no `.specify/`, no `_bmad-output/`, no `aidlc-docs/`, no `CLAUDE.md`, no README, no ADRs, no decision log. One shipped file: `app/main.py` (183 LOC). One module top-level inline comment.

**Sequencing:** straight implementation — no planning phase. API compute 3m 36s, wall 4m 42s; near-zero operator-touch (Vibe trait, confirmed by /status delta).

**Retention-question handling (C-axis classification):** **silently picked / no mention anywhere** — bottom row of success-criteria §3 table.
- **Did the cell ask the PM?** No. `pm-convo.md` contains exactly one exchange: a stray "j" (operator typo, treated by PM persona as "did you mean to send something?"). No retention question raised.
- **Is retention mentioned in code / docstrings / README / planning artifacts?** No. `grep -rni 'retention|persist|TTL|eviction|in.memory|lifecycle|restart'` returns zero hits in `app/`. No README. No docstrings. No assumption tags.
- **What did it pick?** Module-scope `_imports: dict[str, dict] = {}` (main.py:20). Unbounded growth, lost on restart, no eviction, no comment acknowledging any of that. The classic Vibe default.
- **Per the success-criteria §3 table:** "Didn't surface; in-memory dict; no mention anywhere" → Scope (dim 11) 1–2, Assumptions (dim 12) 0–1. Scored 1 / 0 per the dim rationales above.

## Headline

**TBD/45 (planning 1/15) · $0.93 / 3m 36s API · 5/5 binary · 14/14 tests · Critical 0 / Major 0 / Minor 1.** PROVISIONAL. *Vibe shipped a working, all-green 183-LOC implementation in under four minutes of API compute with zero artifacts, zero documentation, and the C-axis retention question silently picked — the dominant Vibe failure mode for T3, exactly as the success criteria predicted.*

## What it did well / where it lost points

**Did well:**
- All 14 tests green on first attempt. All five binary outcomes pass.
- Correct CSV-edge handling: BOM stripped (`utf-8-sig`), embedded newlines preserved (default `csv.reader` semantics, `strict=True`), CRLF/mixed line endings handled by `io.StringIO(text, newline="")`, Unicode names round-trip.
- Async handler on both POST and GET. Chunked-read with running byte accumulator correctly trips 413 at 10 MB *before* allocating the whole body.
- Error envelope shape is consistent (`{"error": {"code": ..., "message": ..., "details": ...}}`) for all non-2xx, matching the openapi.yaml `ErrorResponse` schema.
- Per-row vs whole-file error split structurally cleaner than the "single bad row → 400 everything" anti-pattern flagged in success-criteria.md §4. Row-level errors carry stable `code` values from the FieldError enum (`missing`, `invalid_type`, `out_of_range`, `invalid_format`).
- Bounded `MAX_DATA_ROWS = 100_000` matches the spec.

**Lost points (planning dims, single-rater here; code-visible dims pending blind pass):**
- **Zero artifact production.** No README, no spec, no ADRs, no docstrings on either endpoint, exactly one inline comment in 183 LOC. Drives dims 10/11/12 to the floor of the rubric — this is the Vibe data point.
- **C-axis retention silently picked.** Module-scope `dict`, no eviction, no mention. PM was reachable (`.pm-ask-cell` marker present, `pm-convo.md` reachable) — Vibe just didn't ask, didn't tag, didn't comment.
- **`pydantic[email]` declared in deps, unused in code.** Hand-rolled regex validator does not benefit from the standard library's wider acceptance behavior, and the cell's `EMAIL_RE` will reject some valid addresses pydantic accepts. Quietly sidesteps the v2-idiom check rather than engaging with it — the binary `grep` passes vacuously. Likely surfaces in the blind Code quality / System design ratings, not here.
- **Streaming gesture without follow-through.** Chunked read for the size check, then full re-materialization for parse. Correct on the spec, suboptimal on the implied attack surface.

**Flagged for the blind pass (not pre-scored here):** functionality (does spirit-of-brief use the available deps?), system design (single 183-line module with everything in `main.py`; no separation of parse / validate / store / shape), security (trust boundary not documented per success-criteria §3 dim 8 anchor), documentation (zero shipped docs beyond one comment).
