# T3 — Vibe Plan Mode (vanilla CC + Plan Mode toggled on) / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims (1/3/4/7/8/9) from independent blind raters on the anonymized bundle (see [blind-label-map](../../../../analysis/t3-csv-openapi/blind-label-map.md) when scored); planning dims (10/11/12) single-rater from build-dir artifacts. UI/UX = n/a (HTTP API). Security applies and is load-bearing (untrusted multipart upload). PROVISIONAL.

## Binary outcomes
**5/5** — tests 14/14 · no new deps · Pydantic v2 idiom clean · async POST handler · 413 enforced *during* chunked read (1 MB chunks + accumulated-byte check), not after a full buffer load. See [test-result.md](test-result.md) for the static-check outputs.

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | **4** | blind p1+p2 avg | All 14 tests pass; for the 4+/5 distinction the blind rater will judge whether row-level error messages and any out-of-test-band edge handling (e.g. trailing-whitespace header tolerance, ignored extra columns, explicit Content-Length check) earn the upgrade. **Blind ≥2-rater avg = 4** (pass 1 + pass 2; see [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md)). |
| 3 | Code quality | **4.25** | blind p1+p2 avg | Type-annotated throughout, idiomatic Pydantic v2 (`TypeAdapter`, `model_dump(mode="json")`, `Field` constraints, `Literal` enums), `from __future__ import annotations` used, helpers cleanly named. Blind-pass call. **Blind ≥2-rater avg = 4.25** (pass 1 + pass 2; see [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md)). |
| 4 | System design | **4.25** | blind p1+p2 avg | 4 modules cleanly split — main (route + storage) / models / csv_parser / validator. Per-row vs whole-file error split is **structurally encoded** via typed `CSVParseError(code, message, status_code, details)` exception caught at the handler. In-memory store is a bare module-scope `dict` with no wrapper, no eviction, no comment. Blind-pass call. **Blind ≥2-rater avg = 4.25** (pass 1 + pass 2; see [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md)). |
| 7 | Robustness | **3.5** | blind p1+p2 avg | csv module used correctly (`io.StringIO(text, newline="")`, `strict=True`, `utf-8-sig` for BOM), CSV-edge tests all pass, `MAX_DATA_ROWS = 100_000` enforced even though no test pins it, column-count mismatch handled. Error messages include field name + code + value-aware message ("age must be an integer", "row N has X fields but header has Y"). Blind-pass call. **Blind ≥2-rater avg = 3.5** (pass 1 + pass 2; see [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md)). |
| 8 | Security | **3.5** | blind p1+p2 avg | 10 MB cap enforced during chunked read (not after full buffer — passes the trap), no path-traversal sink, no eval/exec, no auth in scope (consistent with spec). No explicit trust-boundary docstring → realistic ceiling 4 per T3 success-criteria; 5 requires explicit threat-boundary doc, which is absent. Blind-pass call. **Blind ≥2-rater avg = 3.5** (pass 1 + pass 2; see [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md)). |
| 9 | Documentation | **1.75** | blind p1+p2 avg | **No README.** No docstrings except a one-liner on `parse_csv`. No comment on `_STORE` lifetime. Inline comment on `_CHUNK_SIZE = 1 << 20  # 1 MB`. Shipped-docs-only basis per rubric — expected to score low. Blind-pass call. **Blind ≥2-rater avg = 1.75** (pass 1 + pass 2; see [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md)). |
| 10 | Spec articulation | **3** | single | Plan Mode produced a concrete pre-build plan (extracted from CC JSONL, ~160 lines): file layout, per-module responsibilities, model definitions, parser steps numbered 1–8, validator field-by-field flow, route handler skeleton, and a **test-mapping table** showing how each test is satisfied. Calls out Pydantic v2, async POST, BOM strategy (`utf-8-sig`), and the per-row-vs-whole-file split structurally (typed `CSVParseError`) — 3 of the 4 silent discriminators surfaced. Misses the C-axis retention question entirely (just declares `_STORE: dict[str, dict] = {}  # import_id -> serialized ImportResult dict` with no lifecycle commentary). Test-mapping table off-by-one — says "All 13 tests should pass" when there are 14. Meets the anchor-3 clause "covers the major behaviors with testable acceptance criteria; a different engineer could build to this spec and produce something similar." Does not meet 4 ("decisions documented with rationale; alternatives considered explicitly") — rationale appears inline a few times ("makes the test trivially true", "covers `malformed_quotes.csv` where the unclosed quote …") but no alternatives are weighed. |
| 11 | Scope clarity | **1** | single | Plan implicitly defines scope by listing the four modules and the test-mapping table. **No explicit in/out list, no explicit out-of-scope items, no rationale for cuts.** Retention is not listed as in or out of scope — it's silently inside scope as a module-scope dict. Meets anchor-1 ("mentions scope but doesn't explain choices") via the file layout; does not meet anchor-3 ("both in and out of scope listed explicitly with brief reasons for the cuts"). |
| 12 | Assumption surfacing | **0** | single | Zero `[ASSUMPTION]` tags. Zero ADR entries. Zero decision-log lines. Grep across `app/`, `tests/`, `pyproject.toml`, and the plan text for `ASSUMPTION\|TODO\|FIXME\|retention\|TTL\|eviction\|in-memory\|restart\|persist\|lifetime\|lifecycle` returns nothing in the cell's shipped code; the plan text similarly contains zero conditional-decision flags. The Pydantic v2 choice is made silently (defensible per rubric — v2 is the obvious choice and flagging it would waste signal). The **retention choice is also made silently** — that's the C-axis miss. Meets anchor-0 literally ("no assumptions surfaced"). |

**Quality sum: 25.25/45** (blind code avg 21.25/30 + planning single-rater 4/15) · Vector → **Product (Func+Rob) /10: 7.5** · **Rigor (Code+Sys+Sec+Doc+Spec+Scope+Assum) /35: 17.75**

## Defects (from automated + review; no manual exercise this pass)

- **Critical:** 0
- **Major:** 0
- **Minor:** 2
  - GET handler is sync `def get_user_import` (app/main.py:74) while POST is `async def`. The lookup is O(1) so practical impact is negligible, but it's inconsistent with the POST and blocks the event loop briefly. (R: review)
  - No README / no docstring / no comment anywhere documents that `_STORE` is in-memory, lost on restart, with no eviction. Operationally a real-user surprise on first deploy restart. (R: review)

`critical: 0, major: 0, minor: 2 (T: 0 / M: 0 / R: 2)`
**Defect density: 2 / 0.346 KLOC ≈ 5.78 defects per 1KLOC** (shipped 346 LOC across `app/*.py`; token-log notes "528 lines added" from Claude Code's session summary — uses Claude's add-not-net counter, not the wc-l shipped state).

## Cost (see token-log.md)

| Metric | Value |
|---|---|
| Implied API cost | **$1.41** |
| Total tokens | ~1.28 M (542 in / 18.1 K out / 1.2 M cache read / 60.1 K cache write) |
| API compute time | **4m 10s** (250 s) |
| Wall (per token-log) | 9m 45s |
| Wall (per JSONL first-event → last-event) | 25m 53s (gap suggests operator-idle stretches; the token-log "9m 45s" is the active-session figure) |
| Operator interventions | 0 (single plan-approval tap; no redirects in the JSONL) |
| Plan-Mode revisions | 0 (plan accepted on first presentation) |
| PM-ask questions | 0 (.pm-ask-cell is just the routing tag `t3-csv-openapi/vibe-planmode/001`; transcript shows zero PM-ask exchanges) |

**Derived ratios:**

| Ratio | Value |
|---|---|
| Quality per 1K tokens | **0.0197** | 25.25 / 1280.0K tokens (per 1K tokens) |
| Quality per API hour | **365.9** | 25.25 / 0.069 h |
| Defects per 1KLOC | **5.78** |
| Methodology overhead ratio | **~0.11** (planning wall 159 s / implementation wall 1394 s, applied to 250 s total API → planning ≈ 26 s, implementation ≈ 224 s; per-phase API not directly reported by `/status`, so wall-proportion is a proxy) |
| Cost per binary outcome | **$0.282** ($1.41 / 5) |
| Quality per dollar | **17.91** | 25.25 / $1.41 |

## Depth / routing

Methodology layer = **Claude Code with Plan Mode toggled on**. Single planning pass → ExitPlanMode → uninterrupted implementation. The plan lives in the CC JSONL transcript (`9e1f7d09-…jsonl`, line 47, ~160 lines of markdown), not on disk. **No on-disk planning artifacts** (no `openspec/`, `.specify/`, `_bmad-output/`, `aidlc-docs/`, `CLAUDE.md`, ADRs, design docs, or README). No git repo in the cell dir. The cell did NOT use the pm-ask channel.

Retention-question handling: **silently picked** the default (module-scope dict, no eviction, lost on restart). No `[ASSUMPTION]` tag in the plan, no comment in the code, no docstring, no README mention. This is the bottom row of the T3 C-axis matrix.

## Headline

**PROVISIONAL · _/45 quality (planning portion 4/15) · $1.41 / 4m10s API · 5/5 binary · 0 critical / 0 major / 2 minor defects (5.78/KLOC).** Plan Mode produced a tight, test-mapped implementation plan that satisfied every binary outcome including the silent v2/async/per-row traps — but folded under the C-axis the same way Vibe-pure does: retention picked silently, not surfaced as a question or an assumption.

## What it did well / where it lost points

**Did well:**
- Hit 5/5 binary outcomes — including the three "silent traps" (Pydantic v2 idiom, async POST handler, 413-during-read not 413-after-buffer) that the brief deliberately withholds.
- Per-row vs whole-file split is structurally encoded (typed `CSVParseError` with `status_code` + `details`, caught at the handler) rather than scattered as inline `raise HTTPException` calls.
- Plan included a test-mapping table that traces each test to its mechanism — strong signal of "I read the tests before coding."
- Validator's "treat empty as missing before invoking field validators" handles the spec's `code: missing` semantics that `EmailStr` alone would misclassify as `invalid_format`.
- `MAX_DATA_ROWS = 100_000` cap enforced even though no test pins it — read the spec, not just the tests.

**Lost points:**
- **C-axis miss.** Retention silently picked. No question to PM, no `[ASSUMPTION]` tag in plan, no comment in code, no README. Cost 4 points of Scope (1 vs achievable 5) and 5 points of Assumptions (0 vs achievable 5) under the absolute anchors.
- **No README, no shipped docs.** Will hurt dim 9 in the blind pass — `_STORE` lifecycle, run instructions, and storage caveat all undocumented.
- **GET handler is sync `def`**, inconsistent with the async POST. Negligible practical impact (dict lookup is O(1)) but a small consistency ding.
- Plan said "All 13 tests should pass" when there are 14 — cosmetic, but tells you the plan was drafted from a quick scan rather than a count.
- No alternatives weighed in the plan (e.g. raw Pydantic-only validation vs the hand-rolled per-field flow; sync-vs-async GET; single-file vs 4-module split). Caps Spec articulation at 3.
