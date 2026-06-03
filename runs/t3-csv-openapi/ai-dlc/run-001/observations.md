# T3 — AI-DLC (AWS rules-driven lifecycle on Claude Code) / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims (1/3/4/7/8/9) from independent blind raters on the anonymized bundle (see [blind-label-map](../../../../analysis/t3-csv-openapi/blind-label-map.md) when scored); planning dims (10/11/12) single-rater from build-dir artifacts. UI/UX = n/a (HTTP API). Security applies and is load-bearing (untrusted multipart upload). PROVISIONAL.

## Binary outcomes
14/14 tests · no new deps · pydantic v2-clean · async POST handler · 413 enforced via streaming cap → **5 / 5**

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | **4** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 3 | Code quality | **3** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 4 | System design | **2.75** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 7 | Robustness | **3.5** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 8 | Security | **3** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 9 | Documentation | **1** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 10 | Spec articulation | **4** | single | Anchor 4: "decisions documented with rationale; alternatives considered explicitly." `requirements.md` characterizes every behavior with testable acceptance criteria (POST + GET + error codes + per-field validation table). Decisions are documented with rationale — storage line names the retention choice + consequence ("Lost on restart — acceptable for this scope"); skipped phases each carry explicit rationale (`workflow-plan.md` § Rationale for Skips); extensions opt-out logged with reason (`aidlc-state.md` Extension Configuration). Per-row vs whole-file split correctly characterized in advance ("rows are reported with status: success\|error … Response is 200 even if every row fails"). NFR section flags "enforce file-size and row-count limits before doing expensive per-row work where possible" — a partial cue toward the streaming/async silent discriminator. Not 5: doesn't predict edge categories beyond what's spec-pinned; no foresight surfacing genuinely new edges. |
| 11 | Scope clarity | **4** | single | Anchor 3 met outright (explicit Out-of-Scope list with reasons: persistence, AuthN, rate limiting, streaming, async background); anchor 4 met via active scope defense — every skipped AI-DLC stage in `aidlc-state.md` and `workflow-plan.md` carries a 1-sentence rationale; PoC-grade extension opt-outs defended in the audit log. Not 5: scope not revisited mid-run when new info surfaced (single linear sweep). |
| 12 | Assumption surfacing | **3** | single | Count: ~5 explicit decision-equivalent statements (Out-of-Scope list + storage-lifecycle line + "PoC-grade compliance per opt-in defaults" + tech-stack constraint + 100 k limit). Quality anchor 3: each names a choice + (implicitly) what depends on it ("Lost on restart — acceptable for this scope" → consequence stated). Not 4: not categorized (technical/product/user-behavior), no `[ASSUMPTION:]` tags, no ADR-style alternatives-considered table. Retention is documented in prose, not tagged as an assumption per se. |

**Quality sum: 28.25/45** (blind code avg 17.25/30 + planning single-rater 11/15) · Vector → **Product (Func+Rob) /10: 7.5** · **Rigor (Code+Sys+Sec+Doc+Spec+Scope+Assum) /35: 20.75**

## Defects (from review)
- **Critical:** 0
- **Major:** 0
- **Minor:** 0

`Critical: 0 | Major: 0 | Minor: 0 (T: 0 / M: 0 / R: 0)` · **0.0 / 1 KLOC** (impl 223 LOC).

## Cost (see token-log)
$2.73 (Opus 4.7 API rates; Pro flat $20/mo) · 7m 29s API compute · ~2.73 M tokens (2.6 M cache read, 102 K cache write, 30.7 K output, 54 input) · **Q/$ 10.35** · **Q/1Ktok 0.0103** · **Q/API hour 226.0** · **cost/binary $0.546** · **defects/KLOC 0.0** · routing: AI-DLC Inception (Workspace Detection + Requirements minimal + Workflow Planning) → Construction (single unit `csv-import` direct to Code Generation → Build & Test). Skipped: Reverse Engineering (greenfield), User Stories, Application Design, Units Generation, Functional Design, NFR Requirements, NFR Design, Infrastructure Design — all under Auto Mode minimal-depth rationale.

**Methodology overhead ratio:** not directly computable from `/status` (per-phase API time not split out). LOC proxy: planning artifacts ~238 LOC vs implementation 223 LOC → ~1.07 planning : impl by lines. Disclose as proxy, not measurement.

## Depth / routing
**Artifacts produced** (under `aidlc-docs/`):
- `aidlc-state.md` — stage tracker, extension config table, unit list (1 unit: `csv-import`).
- `audit.md` — ISO-timestamped log of each stage's input/response (autonomous, no PM exchange).
- `inception/requirements/requirements.md` — functional spec derived from `openapi.yaml` + `test_imports.py`; per-field validation table; in-scope/out-of-scope.
- `inception/plans/workflow-plan.md` — execution path + rationale-for-skips.
- `construction/csv-import/code/summary.md` — implementation summary (components, behavior decisions).
- `construction/build-and-test/build-and-test-summary.md` — pytest results + coverage-of-pinned-behaviors table.

**Routing decision:** AI-DLC at "Minimal depth" under Auto Mode. Skipped 8 conditional stages with reasons. Treated `openapi.yaml` + `test_imports.py` as the design — went straight from Requirements to Code Generation. Extensions (Security Baseline, Property-Based Testing) explicitly opted-out with rationale.

**Retention-question handling:** **surfaced** in the requirements doc (NFR section + Out-of-Scope) **but not tagged as `[ASSUMPTION]`, no PM ask, default picked silently in code (module-level `_STORE: dict[str, ImportResult] = {}`).** Classification: row 2 of T3 success-criteria.md § 3 ("Surfaced as `[ASSUMPTION]` / ADR, didn't ask, picked a default") → Scope 3.5–4, Assumptions 3.5–4. Scored at 4 / 3 respectively because surfacing is in prose rather than tagged, and assumption articulation lacks categorization or alternatives-considered structure.

## Headline
**TBD/45 · $2.73 / 7m 29s API · 5/5 binary.** PROVISIONAL — AI-DLC at minimal depth shipped a v2-clean, async, single-file FastAPI service that nails every binary outcome and surfaces the retention question in the requirements doc; cost dropped sharply vs T2 ($2.73 vs $4.75, ratio 2.9× vs Vibe — lowest yet) because the pinned spec collapsed inception. Single-file shape (`app/main.py` only, 223 LOC) likely caps the system-design dim in the blind pass.

## What it did well / where it lost points
**Did well:**
- Hit every binary outcome on first run (5/5).
- Streaming 64 KB cap (`_read_capped`) enforces the 413 before a full-buffer load — matches success-criteria intent, not just the literal test.
- Consistent error envelope across 400/404/413 (`{"error": {code, message, [details]}}`) — matches `ErrorResponse` schema exactly.
- Surfaced the retention ambiguity in the requirements doc (`Storage: in-memory dict … Lost on restart — acceptable for this scope.` + Out-of-Scope: `Persistence beyond process lifetime.`) — separates AI-DLC from a pure Vibe baseline on the C-axis.
- Aggressive minimal-depth routing under Auto Mode: skipped 8 conditional inception/construction stages with explicit per-skip rationale → 41 % cost drop vs T2.
- Bonus: 100 k-row cap (`too_many_rows`) implemented even though no test exercises it.

**Lost points (provisional, ahead of blind pass):**
- Single-file implementation (`app/main.py` only, 223 LOC) — no parser/validator/store module split. T3 success-criteria flags this as load-bearing for dim 4 (System design); the in-memory `_STORE = {}` at module scope with no wrapper or lifecycle hook is the 3-tier system-design pattern, not 4.
- Custom field-by-field validation in `_validate_row` rather than Pydantic v2 `@field_validator` annotations — gives precise error-code control but spends the v2-idiom advantage from the pinned `pydantic[email]>=2.6` dep.
- Retention surfacing is in prose, not tagged `[ASSUMPTION:]` and not raised to the PM — caps the C-axis classification one row below "surfaced + asked PM + documented answer."
- No README or docstrings beyond a one-liner on `_read_capped`; documentation (dim 9) will lean on the `aidlc-docs/` set, which the v0.3 rubric explicitly excludes from dim 9 (shipped docs only).
- 100 k row cap not exercised by any test — bonus implementation but no proof of correctness beyond the static path.
