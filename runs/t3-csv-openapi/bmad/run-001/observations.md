# T3 — BMAD v6.8.0 (multi-agent lifecycle, adaptive routing) / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims (1/3/4/7/8/9) from independent blind raters on the anonymized bundle (see [blind-label-map](../../../../analysis/t3-csv-openapi/blind-label-map.md) when scored); planning dims (10/11/12) single-rater from build-dir artifacts. UI/UX = n/a (HTTP API). Security applies and is load-bearing (untrusted multipart upload). PROVISIONAL.

## Binary outcomes
Tests **14/14** · No new deps **yes** · Pydantic v2 idiom **yes** · Async POST handler **yes** · 413 enforced **yes (streamed early-abort)** → **5/5**

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | **4** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 3 | Code quality | **4.25** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 4 | System design | **4** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 7 | Robustness | **3.75** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 8 | Security | **3.5** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 9 | Documentation | **1.25** | blind p1+p2 avg | Blind ≥2-rater avg (pass 1 + pass 2). See [blind-pass-audit](../../../../analysis/t3-csv-openapi/blind-pass-audit.md). |
| 10 | Spec articulation | **4** | single | Anchor 4 met: BMAD `spec-csv-import-users.md` covers every major behavior with testable acceptance criteria (4 AC clauses + 14-scenario I/O & Edge-Case matrix that correctly enumerates each of the 14 shipped tests) AND documents key impl decisions with rationale (`csv.reader(strict=True)` for parse-error detection, BOM strip on decode, `EmptyFile` vs `Malformed` distinction, v2 error-type → `FieldError.code` mapping table). Falls short of 5: alternatives are not explored explicitly (e.g. async streaming was *rejected* in the spec — "We don't stream because the cap is small" — yet shipped code *does* stream; the spec did not predict its own correction). Retention/lifecycle of stored imports — the T3 silent C-axis discriminator — is not engaged as a question (see dim 12). |
| 11 | Scope clarity | **3** | single | Anchor 3 met: `## Boundaries & Constraints` has explicit `Always` (8 items), `Never` (no disk/DB persistence, no auth, no rate-limit, no background processing, no pagination, no input mutation), and `Ask First: No human-gated decisions`. Brief reasons given for the cuts ("in-process dict is sufficient", "v1"). Does not reach 4: scope was not actively defended in any exchange (the `Ask First: None` declaration is a *foreclosure*, not a defense). Retention is silently picked under "Never persist to disk" — the in-memory dict is named as a storage choice, but lifecycle ("imports lost on restart; no eviction") is never stated as a level-3 scope clause. |
| 12 | Assumption surfacing | **2** | single | Count: **0** explicit `[ASSUMPTION]` tags / ADR entries / decision-log lines in shipped artifacts. The spec explicitly declares `Ask First: No human-gated decisions` — actively forecloses the assumption-surfacing surface. Anchor 2 met: real choices are named with rationale (csv.reader strict mode, BOM strip strategy, in-memory dict, "we don't stream") but framed as decisions, not assumptions, and don't say what would change if the choice were wrong. Notable internal contradiction: BMAD's own adversarial-review subagent flagged `app/store.py:7` ("Unbounded in-memory dict accumulates forever … LRU cap or TTL eviction") during the cell, but the finding was not preserved as a shipped `[ASSUMPTION]`, README caveat, or code comment — it survives only in the JSONL transcript. |

**Quality sum: 29.75/45** (blind code avg 20.75/30 + planning single-rater 9/15) · Vector → **Product (Func+Rob) /10: 7.75** · **Rigor (Code+Sys+Sec+Doc+Spec+Scope+Assum) /35: 22**

## Defects (counted, not 0–5 scored)
- **Critical: 0 | Major: 0 | Minor: 0 (T: 0 / M: n/a / R: 0)**
- Per 1 KLOC: **0.0** (358 LOC `app/`).
- Notes: 14/14 tests pass; static checks all green; manual code review surfaced no latent bugs. The bare `except Exception` in `main.py:54` (annotated `# pragma: no cover - defensive`) is a controlled fallback, not a defect. The unbounded in-memory dict and lack of locking are *known limitations* (named in the BMAD spec under "Never persist to disk … in-process dict is sufficient") rather than defects.

## Cost (see token-log)
$4.67 · 12m 1s API compute (0.200 h) · ~4.56 M tokens · LOC 358 (`app/`) / 521 net (incl. spec)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | **0.0065** | 29.75 / 4560.0K tokens |
| Quality per API hour | **148.8** | 29.75 / 0.200 h |
| Defects per 1 KLOC | **0.0** |
| Methodology overhead ratio | **n/a** (BMAD chose **quick-dev** path; no separate planning vs implementation phase timestamps in session-log) |
| Cost per binary outcome | **$0.934** ($4.67 / 5) |
| Quality per dollar | **6.37** | 29.75 / $4.67 |

vs Vibe ratio for T3: **5.0×** (Vibe T3 = $0.93; BMAD T3 = $4.67). Replicates the T1 (6.8×) and T2 (4.3×) BMAD-vs-Vibe-on-clear-brief pattern.

## Depth / routing

**BMAD adaptive routing chose quick-dev** (single implementation artifact: `_bmad-output/implementation-artifacts/spec-csv-import-users.md`; `planning-artifacts/` directory is empty — no PRD, architecture, epics, or stories produced). Replicates the T1 + T2 BMAD-on-clear-brief routing pattern; right-sizes the methodology for a spec-bound greenfield task with a published OpenAPI contract.

**Artifacts produced:**
- 1× implementation spec (`spec-csv-import-users.md`, ~210 LOC frozen-after-approval intent + boundaries + edge-case matrix + code map + tasks + design notes + verification + suggested review order). Marked `status: 'done'`.
- 4× shipped app files (`main.py`, `csv_import.py`, `schemas.py`, `store.py`) — **multi-file named-by-concern separation** is the headline shape contrast vs Vibe (god-file `main.py`, 184 LOC) and AI-DLC (god-file `main.py`, 223 LOC); BMAD is the first T3 cell so far to factor by concern.
- 0× README. `docs/` directory is empty.

**Sequencing:** spec drafted → adversarial-review subagent run → code edits applied → declared done. The adversarial review surfaced two High and several Medium findings; the streaming-413 (initially spec'd as "read fully") was **changed in implementation** to a streaming early-abort, surpassing the spec.

**Retention handling — C-axis classification:** Row 3 (borderline Row 4). Did NOT surface the question, did NOT ask PM (`Ask First: No human-gated decisions` is an explicit foreclosure), picked an unbounded module-level `dict[UUID, ImportResult]`, mentioned the storage choice ("in-process dict is sufficient") in the BMAD spec under the `Never persist` constraint but did NOT name retention/lifecycle as a question and did NOT preserve the adversarial review's "unbounded dict … LRU cap or TTL eviction" finding in any shipped artifact. No README, no docstring caveat.

## Headline
**PROVISIONAL — 9/15 on planning dims · $4.67 / 0.200 h API · 5/5 binary.** BMAD's adaptive routing chose quick-dev again on T3, shipped 14/14 tests passing with multi-file named-by-concern separation, a streaming-413 that surpassed its own spec — but actively foreclosed the C-axis retention question (`Ask First: No human-gated decisions`) and lost its own adversarial-review finding about the unbounded dict.

## What it did well / where it lost points

**Did well:**
- All 5 binary outcomes pass; 14/14 tests pass.
- **Multi-file separation of concerns** (HTTP / CSV-parse / Pydantic models / store) where T3-Vibe and T3-AI-DLC shipped god-files.
- **Spec/impl convergence in the right direction**: spec said "we don't stream"; impl shipped streaming with early-abort 413, which is the security-correct choice for an untrusted upload.
- Typed `CSVImportError` hierarchy (`MalformedCSVError`, `MissingColumnsError`, `EmptyFileError`, `TooManyRowsError`) — per-row vs whole-file split is *structurally encoded*, not scattered as inline `raise HTTPException`.
- Pydantic v2 idiom clean throughout (`ConfigDict`, `model_validate`, `model_dump(mode="json")`, `EmailStr`); no v1 surface.
- Pydantic-error-type → `FieldError.code` mapping table is documented in the spec **and** implemented as a classifier function — not magic strings scattered.
- BMAD's adversarial-review subagent surfaced real impl risks (streaming, error-leak in 400 envelope, unbounded dict, duplicate-column handling) — at least one was acted on before declaring done.

**Lost points:**
- `Ask First: No human-gated decisions` is the methodology actively *foreclosing* the surface where ambiguity should be surfaced. T3's silent C-axis discriminator (retention) was missed at the spec stage.
- Adversarial-review finding ("unbounded in-memory dict … LRU cap or TTL eviction") was NOT preserved into a shipped `[ASSUMPTION]`, README caveat, or code comment. It exists only in the cell's JSONL transcript. The methodology generated the right signal then dropped it.
- 0 `[ASSUMPTION]` tags / 0 ADRs / 0 decision-log lines — assumption-surfacing surface is structurally absent from BMAD's quick-dev artifact.
- No README shipped (`docs/` empty). Documentation rests on the planning spec, which the dim-9 anchor explicitly *does not credit* (dim 9 = shipped docs only).
- The bare `except Exception` in `main.py:54` masks programmer bugs as `malformed_csv` (raised in the adversarial review as High; not changed). Acceptable as a final fallback but leaks the chance to surface real bugs.
