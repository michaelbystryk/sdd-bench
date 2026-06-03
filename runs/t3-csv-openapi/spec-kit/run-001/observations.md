# T3 — Spec Kit (slash-command pipeline) / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims (1/3/4/7/8/9) from independent blind raters on the anonymized bundle (see [blind-label-map](../../../../analysis/t3-csv-openapi/blind-label-map.md) when scored); planning dims (10/11/12) single-rater from build-dir artifacts. UI/UX = n/a (HTTP API). Security applies and is load-bearing (untrusted multipart upload). PROVISIONAL.

## Binary outcomes
14/14 tests · no new deps · no v1 idiom · async POST handler · 413 size cap enforced (streaming) → **5/5** ✅

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | **4** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 3 | Code quality | **4** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 4 | System design | **4** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 7 | Robustness | **3** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 8 | Security | **3.5** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 9 | Documentation | **1** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 10 | Spec articulation | **5** | single | Hits level-4 anchor in full (decisions documented with rationale + alternatives considered explicitly — research.md has 13 ADR-style entries R1–R13 each in Decision/Rationale/Alternatives format). Hits level-5 anchor (the spec correctly predicts implementation edge cases): R1 predicts the streaming size-cap before code; R3 calls out BOM handling; R4 picks Pydantic v2 idiom explicitly with the error-code mapping table; R10 names the explicit-null `data`/`errors` requirement; R12 predicts the empty-vs-header-only distinction; tasks.md notes during implementation that an unterminated-quote case wasn't covered by `csv.Error` (real foresight enriched during impl). Spec also surfaces the C-axis retention question as an explicit Assumption + research §R5 + plan storage section + data-model persistence layer. The artifact set across spec/plan/research/data-model/contracts/checklists/tasks/quickstart is unusually cohesive. |
| 11 | Scope clarity | **4.5** | single | Level-3 met (in + out scope both explicit: spec.md Assumptions lists 6 explicit boundaries — auth out, ephemeral storage, light concurrency, no new deps, fixed schema, OpenAPI authoritative; quickstart.md has a dedicated "What's intentionally *not* here" section: no DB, no Alembic, no auth, no background jobs, no new deps, no CLI front-end). Level-4 met (active defense in research alternatives sections — pandas rejected as "would add a heavy dep ... out of scope"; SQLite rejected as "would satisfy durability we don't need"; row-cap impl explicitly added beyond test-minimum because OpenAPI mandates it — R6 "PR-ready code should match the documented contract, not the test minimum"). Partial level-5 (decisions explicitly conditional with named revisit triggers: spec "if a deployment needs durability, that is a follow-on concern"; R5 "We'd revisit only if the deployment story changes (multi-process, persistent store)") — short of full 5 because revisits are stated triggers in writing rather than triggered-by-external-info events. |
| 12 | Assumption surfacing | **4** · count ≈ 24 | single | Count: 6 in spec.md Assumptions + 13 in research.md R1–R13 (each Decision/Rationale/Alternatives) + ~5 in data-model.md (preprocessing rule, `age` special case, RowResult nullability rationale, persistence layer caveats) ≈ 24 explicit decisions documented. Level-3 met across the board (each assumption names a real choice + says what would change if revisited — e.g. R5 "We'd revisit only if the deployment story changes"). Partial level-4 (assumptions are categorized by topic — R1=size, R2=parsing lib, R5=persistence, R8=envelope, R11=concurrency — but not labeled with type tags technical/product/user-behavior as the anchor strictly requires). Partial level-5 (assumption-to-code mapping exists via tasks.md cross-refs like T006 "No locking; no eviction (per research §R5, §R11)" → `app/repository.py`; data-model.md "Persistence Layer (in-memory)" block maps directly to `_store` shape). Final integer: 4. |

**Quality sum: 33/45** (blind code avg 19.5/30 + planning single-rater 13.5/15) · Vector → **Product (Func+Rob) /10: 7** · **Rigor (Code+Sys+Sec+Doc+Spec+Scope+Assum) /35: 26**
_(Full /45 sum reported after blind code-visible pass — PROVISIONAL until then.)_

## Defects (from manual code review + test outcomes; blind review will refresh)

- **Critical:** 0
- **Major:** 0
- **Minor:** 0

Format: `Critical: 0 | Major: 0 | Minor: 0 (T: 0 / M: 0 / R: 0)` · Defects/1KLOC: **0.0** (380 LOC impl).

Latent code-review note (not a defect, flagged for blind pass to weigh under Code quality / System design): the validator's two-pass pattern in `app/validator.py:69–87` (try `model_validate` once, then if preprocessing errors existed try it again to harvest format errors for non-missing fields, deduping by field name) is correct but subtle — a teammate scanning the file may need a beat to see why the second `try` exists. The dedup `if err.field not in {e.field for e in field_errors}` is correct given preprocessing errors are always `missing`-coded.

## Cost (see token-log.md)

| Metric | Value |
|---|---|
| Implied API cost | **$5.72** |
| API compute time (scored) | **15m 9s** = 0.2525 h |
| Total tokens | ~6.24 M |
| Wall-clock (context) | 19m 10s |
| LOC (app/) | 380 |
| Binary passes | 5/5 |

**Derived ratios:**
- **Defects per 1KLOC:** 0.0
- **Cost per binary outcome:** $5.72 / 5 = **$1.144**
- **Quality per 1K tokens:** **0.0053** (33 / 6240.0K tokens)
- **Quality per API hour:** **130.4** (33 / 0.253 h)
- **Quality per dollar:** **5.77** (33 / $5.72)
- **Methodology overhead ratio (planning API / impl API, est. from transcript wall-clock):** specify 3m22s + plan 6m46s + tasks 2m25s = **12m 33s planning** vs **6m 31s implement** → **~1.93** (planning ~66% of pipeline). API-compute breakdown not captured per phase; this is the wall-clock proxy assuming uniform API/wall ratio of 15m9s / 19m4s ≈ 0.79. `/speckit-clarify` was skipped — model declared no open clarifications.

**Cost-band cross-cell:**

| Cell | LOC | Cost | Cost/LOC | API time | binary |
|---|---|---|---|---|---|
| Vibe | 184 | $0.93 | $0.0051 | _ | _ |
| Plan Mode | 528 | $1.41 | $0.0027 | _ | _ |
| OpenSpec | 659 | $2.91 | $0.0044 | _ | _ |
| **Spec Kit** | **1115** (incl. planning docs) / 380 (app/) | **$5.72** | $0.0051 / $0.0150 (app/) | **15m 9s** | **5/5** |

Spec Kit produced the largest artifact set + cost in T3, ~4× the API spend of Vibe and ~2× OpenSpec. Per-LOC cost matches Vibe's because planning artifacts grow LOC proportionally.

## Depth / routing

Spec Kit ran the canonical 5-phase pipeline: **specify → (clarify skipped) → plan → tasks → implement.** Artifacts produced:

- `specs/001-csv-import/spec.md` — 4 prioritized user stories (US1/US2 P1, US3/US4 P2), 22 FRs, 6 SCs, edge cases, key entities, 6 explicit assumptions
- `specs/001-csv-import/checklists/requirements.md` — quality-gate checklist, all items pass
- `specs/001-csv-import/plan.md` — Technical Context + Constitution Check + Project Structure + Complexity Tracking (no violations)
- `specs/001-csv-import/research.md` — 13 ADR-style entries (R1 size cap, R2 csv lib, R3 BOM, R4 Pydantic v2, R5 persistence, R6 row cap, R7 embedded newlines, R8 envelope, R9 row numbers, R10 null fields, R11 concurrency, R12 empty-vs-header, R13 test runner)
- `specs/001-csv-import/data-model.md` — Pydantic v2 model + Pydantic-error → `code` mapping table + persistence layer
- `specs/001-csv-import/contracts/openapi.yaml` — copy of binding contract
- `specs/001-csv-import/quickstart.md` — install / test / run / curl examples + "What's intentionally not here"
- `specs/001-csv-import/tasks.md` — 24 tasks across 7 phases, all marked [X] with implementation notes

**`/speckit-clarify` was skipped** — model self-declared in the `/speckit-specify` completion report: "Spec written and validated. No `[NEEDS CLARIFICATION]` markers needed — the OpenAPI contract and pinned tests answered every otherwise-ambiguous question." This means the C-axis retention question was **never escalated to the PM**; it was instead surfaced and resolved internally in the spec's Assumptions section.

**C-axis retention handling (classification per success-criteria.md §3):** **Row 2 — "Surfaced as `[ASSUMPTION]` / ADR, didn't ask, picked a default."** Evidence:
- `spec.md` Assumptions: "Storage is in-process and ephemeral. Persisted `ImportResult` payloads live for the lifetime of the running service process. Cross-process or restart-durable persistence is not required... if a deployment needs durability, that is a follow-on concern."
- `research.md` §R5 ("Persistence strategy"): full Decision/Rationale/Alternatives entry — picked module-level dict, rejected SQLite ("would satisfy durability we don't need") and `lru_cache` ("wrong abstraction").
- `research.md` §R11 ("Concurrency / thread safety"): "Adding `asyncio.Lock` would mask, not protect against, scenarios the contract doesn't require. We'd revisit only if the deployment story changes (multi-process, persistent store)."
- `plan.md` Storage block: "In-process Python dict keyed by `import_id` (UUID4). Process-lifetime persistence only — restart-durable storage is out of scope (see spec Assumptions)."
- `data-model.md` Persistence Layer: explicit "No eviction, no TTL, no locking. Lifetime = process lifetime."
- `tasks.md` T006: "No locking; no eviction (per research §R5, §R11)."
- `quickstart.md` "What's intentionally not here": "No database, no Alembic, no migrations."
- `app/repository.py` (shipped): `_store: dict[UUID, ImportResult] = {}` — module-level singleton, no eviction/TTL/locking.

Confirms classification cleanly: cell did NOT ask the PM (no `pm-convo.md` artifact; `/speckit-clarify` skipped), did surface the retention question prominently across 5+ planning artifacts AND in shipped code references, picked the in-process-dict default with documented revisit triggers. → Per the table: Scope = 3.5–4, Assumptions = 3.5–4. My scored 11=4.5 / 12=4 fits.

## Headline

**Planning-dims subtotal 13.5/15** (single-rater, PROVISIONAL) · code-visible 6 dims TBD (blind) · **$5.72 · 15m 9s API · 5/5 binary.** Spec Kit ran the full specify→plan→tasks→implement pipeline (clarify self-declared unneeded), produced 8 cohesive planning artifacts, and shipped a clean 380-LOC layered impl that passes 14/14 with no defects observed; the C-axis retention question was assumption-tagged across 5+ artifacts and a default picked, with the planning footprint costing ~2× OpenSpec and ~4× Plan Mode in API spend.

## What it did well / where it lost points

**Did well:**
- Caught every silent discriminator in advance: Pydantic v2 idiom (R4 explicit, mapping table provided), streaming size cap (R1 — "Do not buffer the full body before the check"), per-row vs whole-file split (US1 vs US2 structural separation in spec + a single `WholeFileError` class + FastAPI exception handler in code), async correctness (async handler + chunked `await file.read()`).
- C-axis retention question surfaced in 5+ artifacts (spec Assumptions, research R5/R11, plan storage block, data-model persistence layer, tasks.md cross-refs, quickstart "What's intentionally not here") with explicit revisit triggers.
- Layered impl (parser / validator / schemas / repository / errors / main) matches the planned structure file-for-file.
- Implemented `too_many_rows` (100k cap) beyond test minimum because OpenAPI mandates it (R6 reasoning: "PR-ready code should match the documented contract, not the test minimum") — scope-conscious without scope creep.
- Tasks.md includes implementation-time enrichments (e.g. "Also enforced field-count match against the header to catch unterminated quotes (Python's csv.reader consumes such input to EOF rather than raising)") — real foresight added during execution, not just pre-stated.

**Lost points / friction:**
- `/speckit-clarify` was skipped → the C-axis retention question never went to the PM. This is the cleanest evidence for the T3 finding: even a methodology with a dedicated clarify phase may self-declare it unneeded when the contract appears tight, which costs the cleanest assumption-surfacing signal (full 5 on dim 12 likely needs the PM exchange the cell didn't make).
- Validator dedup logic (`app/validator.py:69–87`) is subtle two-pass — correct but a small cognitive cost.
- Planning footprint is large (~735 lines of `.md` across spec/plan/research/data-model/quickstart/tasks/checklists vs 380 LOC of app code) — 4× the API spend of Vibe for a contract this tight. The "SDD tax" is real here: ~66% of wall-clock pipeline was planning vs implementation. Whether that pays off shows up in dim 10/12 scores (where it does) and in defect density (where Vibe's 184-LOC ship has yet to be compared).
- The Constitution Check passes "trivially" because `.specify/memory/constitution.md` is unfilled template placeholders — a known Spec Kit no-op when the project has no real constitution. Not a defect; an observation about the methodology surface.
