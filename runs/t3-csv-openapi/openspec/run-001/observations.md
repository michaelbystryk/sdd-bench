# T3 — OpenSpec (lightweight propose → apply → archive) / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims (1/3/4/7/8/9) from independent blind raters on the anonymized bundle (see [blind-label-map](../../../../analysis/t3-csv-openapi/blind-label-map.md) when scored); planning dims (10/11/12) single-rater from build-dir artifacts. UI/UX = n/a (HTTP API). Security applies and is load-bearing (untrusted multipart upload). PROVISIONAL.

## Binary outcomes
**5/5** — tests 14/14 ✓ · no new deps ✓ · v2 idiom ✓ · async handler ✓ · file-size limit ✓

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | **4** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 3 | Code quality | **4** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 4 | System design | **3.75** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 7 | Robustness | **3.5** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 8 | Security | **3.75** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 9 | Documentation | **1.75** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 10 | Spec articulation | **5** | single | design.md predicts impl edge cases the tests don't pin (100k-row cap → snake_case `too_many_rows` §7; strict UTF-8 trade-off §UTF-8 risk; csv.reader newline-for-bytes verification; FastAPI HTTPException envelope conflict §6); each of the 7 numbered Decisions has an alternative considered + rationale (§1 streaming vs `max_upload_size`, §2 stdlib csv vs pandas/hand-rolled, §4 manual FieldError vs Pydantic-native, §5 in-memory vs SQLite); per-row vs whole-file split called out explicitly in §3 ("Decision order matters: size check → decode → BOM strip → CSV parse → header check → row loop") *before* code. Meets level-4 ("decisions + rationale + alternatives") AND level-5 clause ("predicts edge cases that turn up during implementation") independently — impl matches design without post-spec re-design. Three of four T3 "strong signals" surfaced (per-row vs whole-file, retention, async streaming); v2 idiom correctly assumed-not-surfaced per success-criteria.md guidance. |
| 11 | Scope clarity | **4** | single | design.md has explicit Goals + Non-Goals with reasons. Non-Goals cover persistence beyond process lifetime, streaming/async CSV parsing, auth/rate-limiting, ordering across imports. Scope defended via alternative-rejection in Decisions (SQLite rejected, pandas rejected, Starlette `max_upload_size` rejected — each with stated reason). Retention question listed under Non-Goals AND Decision #5 AND Risks/Trade-offs (three places). Not 5: scope decisions are declared+defended but not *revisited* when new info surfaces — they stay as written through apply phase. Lands in the 3.5–4 band per T3 success-criteria.md C-axis table for "Surfaced as [ASSUMPTION]/ADR, didn't ask, picked default"; top of band given the breadth of alternative-rejection. |
| 12 | Assumption surfacing | **4** | single | Count: 7 numbered Decisions (each names choice + rationale + alternative) + 5 Risks/Trade-offs entries (each names consequence + mitigation path) + 4 explicit Non-Goals + 1 Open Questions section (honestly answered "None blocking"). Quality: each decision names a choice + says what would change if it were wrong (level-3 anchor). Several name specific code locations: Decision #5 "swap the dict for SQLite without touching the public API"; Trade-off #2 "switch to spooling to a tempfile" — partial level-5 evidence. Not 5: assumptions are not categorized into technical/product/user-behavior buckets (level-4 anchor); no literal `[ASSUMPTION]:` tags, just ADR-style numbered Decisions. Retention specifically: surfaced in 3 places as ADR — strong T3 C-axis signal, top of 3.5–4 band. |

**Quality sum: 33.75/45** (blind code avg 20.75/30 + planning single-rater 13/15) · Vector → **Product (Func+Rob) /10: 7.5** · **Rigor (Code+Sys+Sec+Doc+Spec+Scope+Assum) /35: 26.25**

## Defects (from manual exercise + code review; tests/blind pass may add)
- **Critical:** 0
- **Major:** 0
- **Minor:** 2 (R: review)
  - No `Content-Type` validation on the multipart upload; accepts any content. T3 success-criteria.md flags content-type validation as a common 4-tier behavior under dim 8 — absence will likely cap blind Security at 3–4.
  - `UserRow.country` typed as plain `str` rather than `Literal[...]` of the whitelist; the cell's own `tasks.md` §1.2 prescribed `Literal` / `Enum`. Whitelist is enforced in `validation.py` via `ALLOWED_COUNTRIES` frozenset — functionally equivalent but a minor own-plan deviation.

Defects / 1KLOC = 2 / 0.37 = **5.4 defects per 1KLOC** (impl LOC = 370). Both R-source (code review only); 0 from tests, 0 from manual API exercise.

## Cost (see token-log)
- Implied API cost: **$2.91**
- API compute time: **8m 46s** (526s · 0.146h)
- Total tokens: **~2.74M** (1.1K in + 39.5K out + 2.6M cache read + 102.4K cache write)
- Pass count: 5/5 binary
- **Cost per binary outcome:** $2.91 / 5 = **$0.582 per pass**
- **Defects per 1KLOC:** 5.4 (impl LOC 370)
- **Methodology overhead ratio (wall-clock proxy):** propose 3m 44s / apply 5m 45s = **0.65** (planning = ~39% of total cell wall-clock; archive phase skipped — see Depth/routing). True API-compute-per-phase not separately captured; this is the cleanest proxy available.
- **Quality per dollar:** **11.6** (33.75 / $2.91)
- **Quality per 1K tokens:** **0.0123** (33.75 / 2740.0K tokens)
- **Quality per API hour:** **231.2** (33.75 / 0.146 h)
- Routing: opsx:propose → opsx:apply. **opsx:archive NOT invoked** (token-log expectation was propose ✓ / apply ✓ / archive ✓ — only first two ran). Change directory `openspec/changes/add-csv-import-endpoint/` remains in "active" state rather than archived.

## Depth / routing

**Artifacts produced (under `openspec/changes/add-csv-import-endpoint/`):**
- `proposal.md` (53 lines) — Why / What Changes / Capabilities (`csv-user-import` new capability) / Impact (no new deps; in-process store).
- `design.md` (76 lines) — Context, Goals/Non-Goals (4 explicit goals + 4 non-goals), 7 numbered Decisions each with rationale + alternative considered, 5 Risks/Trade-offs, Migration Plan, Open Questions.
- `tasks.md` (32 lines) — 19 checkboxes across 4 phases (Scaffolding, Parsing+Validation, Endpoints, Verification). All 18 of 19 checked; only the optional 4.3 uvicorn smoke check unchecked.
- `specs/csv-user-import/spec.md` (146 lines) — 6 Requirements with WHEN/THEN scenarios (CSV Upload, Row-Level Validation Rules, Whole-File Failure Modes, Upload Size Limit, Encoding/Line-Ending, Import Retrieval).

**Sequencing:** propose phase 04:42–04:46 (3m 44s wall) → apply phase 04:46–04:52 (5m 45s wall). No archive. No PM-ask exchange (cell had `.pm-ask-cell` flag set — `t3-csv-openapi/openspec/001` — but didn't invoke the workflow; design.md "Open Questions" section explicitly says "None blocking. The OpenAPI spec is precise on the wire contract, and the test suite pins the behavior we need.").

**Retention-question handling: assumption-tagged ADR style, didn't ask, picked a default.** Treated as an explicit ADR-style decision in 3 places of the planning artifacts: proposal.md ("No persistence layer ... results live for the lifetime of the process only"), design.md Non-Goals ("Persistence beyond the process lifetime ... a restart loses them"), and design.md Decision #5 ("No eviction policy — the spec doesn't require one ... Alternative considered: SQLite — rejected"), plus a Risks/Trade-offs entry naming the swap-to-SQLite migration path. No literal `[ASSUMPTION]:` tags. Per success-criteria.md §3 C-axis classification this is row 2 ("Surfaced as `[ASSUMPTION]`/ADR, didn't ask, picked a default → Scope 3.5–4, Assumptions 3.5–4"). Decision implemented as `app/store.py` — a 13-line module with a module-level `dict[str, ImportResult]` plus `save()` / `get()`. No eviction, no TTL, no metadata.

## Headline
**PROVISIONAL — _/40 quality (planning dims 13/15) · $2.91 / 8m 46s API · 5/5 binary · 2 minor defects.** OpenSpec produced a high-rigor planning artifact set that surfaced 3 of 4 T3 silent discriminators in advance (per-row vs whole-file split, async streaming for large files, retention-as-ADR with SQLite alternative considered), and shipped clean 370-LOC impl whose layering tracks design.md exactly; cost the second-tier methodology load (8m 46s API, $2.91) with no PM interaction and no archive phase.

## What it did well / where it lost points
**Did well:**
- design.md predicts impl edge cases the tests don't exercise: 100k-row cap with snake_case `too_many_rows`, strict UTF-8 decode → `malformed_csv`, csv.reader-on-StringIO newline handling, FastAPI HTTPException envelope conflict.
- Layering tracks the spec exactly: parsing / row validation / HTTP shaping / store / error helper as distinct modules — no god file.
- Retention surfaced as ADR with alternative considered (SQLite) and migration path — top T3 C-axis signal short of asking PM.
- Per-row vs whole-file error split structurally encoded via typed `MalformedCSVError` / `EmptyFileError` exceptions caught at the handler boundary (not inline `raise HTTPException`).
- 10 MB enforced *before* full-file buffering (chunked 64 KB streaming read with byte budget) — the design.md "before reading the body into memory" claim is actually shipped.
- v2 idiom used throughout; `TypeAdapter(EmailStr).validate_python(...)` is the v2 way to use `EmailStr` as a validator, not a v1 field.

**Lost points:**
- No `Content-Type` validation on the multipart upload — will likely cap blind Security at 3–4 per success-criteria.md guidance.
- No shipped README — the cell's docs live in `openspec/` planning artifacts; per rubric dim 9 anchors planning docs do NOT count for Documentation, so dim 9 will land low at blind pass unless docstrings carry it.
- `UserRow.country: str` instead of `Literal[...]` per the cell's own tasks.md §1.2; functionally OK (whitelist enforced in validation.py) but a minor own-plan deviation.
- opsx:archive phase not invoked — the change directory remains "active" rather than archived; token-log expected the full propose ✓ / apply ✓ / archive ✓ sequence.
- Cell did NOT use the PM-ask channel despite `.pm-ask-cell` flag being set; design.md "Open Questions" explicitly closes the door ("None blocking"). That's the cleanest possible "structured methodology + spec precision = no PM interaction" data point for T3, but it's also the ceiling on dim 11/12 (asking PM would have moved to row 1 of the C-axis table = Scope/Assumptions 4–5).
