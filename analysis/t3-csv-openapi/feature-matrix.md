# T3-csv-openapi — Cross-cell feature parity audit

> **Headline.** The 14 pinned tests passed for all 6 cells, so test-coverage doesn't discriminate. The features that discriminate are the **silent traps + the C-axis retention question**. Vibe sidestepped the Pydantic v2 framework entirely; AI-DLC engaged the framework but shipped a god-file; BMAD's internal QA caught the retention finding mid-build and discarded it; only 3 cells (Spec Kit, OpenSpec, AI-DLC) named retention as an explicit assumption in shipped planning artifacts; 5 of 6 cells did the "chunked-read then rebuffer" streaming illusion; 6 of 6 cells failed to validate Content-Type on the multipart upload; 6 of 6 cells failed to document the trust boundary.

Companion to `scoring-matrix.md` (which holds the dim scores). This matrix tracks **which features each methodology built / cut / missed / silently shipped**.

Legend: ✅ built and complete · ⚪ built partially or with caveat · ❌ not built · 🚫 actively cut (named as out of scope in a planning artifact) · — n/a

---

## Pinned-by-tests features (the floor)

All 6 cells shipped these — pinned by the 14-test suite. Non-discriminating; included for completeness.

| Feature | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| POST /imports/users (multipart upload) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| GET /imports/{import_id} (cached lookup) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Per-row validation w/ {field, code, message} | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Response envelope {import_id, total, succeeded, failed, results} | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Whole-file 400 codes (malformed_csv, missing_required_columns, empty_file) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 413 file_too_large | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 404 import_not_found | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Per-row vs whole-file split (single bad row stays 200) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| BOM stripped | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Embedded newlines in quoted fields | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| CRLF / LF / mixed line endings | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Unicode names preserved | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Error envelope {error: {code, message, details?}} | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

**14/14 + 5/5 binary, all six.** Binary doesn't discriminate.

---

## Silent discriminators (the traps the brief deliberately omits)

These are where T3 actually measures methodology. None are in the brief; the spec implies them or the tests pin them indirectly.

| Discriminator | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Pydantic v2 idiom genuinely engaged** (BaseModel + Field constraints + Literal / EmailStr) | ❌ vacuous† | ✅ | ✅ | ✅ | ✅ | ✅ |
| Pydantic v2 *fully replaces* hand-rolled validators | ❌ | ⚪ partial | ⚪ partial | ⚪ partial | ⚪ partial | ⚪ partial |
| Async POST handler | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Async GET handler (consistency) | ✅ | ❌ sync GET | ✅ | ✅ | ✅ | ✅ |
| Multi-file impl (parse / validate / store / shape separation) | ❌ 1 file | ✅ 4 files | ✅ 6 files | ✅ ~7 files | ❌ 1 file | ✅ 4 files |
| **Typed exception caught by handler** (per-row vs whole-file structurally encoded) | ❌ inline | ✅ CSVParseError | ✅ WholeFileError | ✅ WholeFileError | ✅ CSVImportError hierarchy | ✅ |
| Chunked-read 413 enforced before full buffer | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Real streaming** (no `b"".join(chunks)` rebuffer after the chunked check) | ❌ rebuffer | ❌ rebuffer | ❌ rebuffer | ❌ rebuffer | ❌ rebuffer | ⚪ ambiguous |
| Content-Type validation on multipart upload | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Value-aware row-level error messages (echo offending value) | ✅ | ✅ | ⚪ partial | ⚪ field-aware only | ⚪ partial | ✅ |
| Trust boundary documented (in code / docstring) | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Spec-conformant error codes only (no invented codes like `too_many_rows`) | ❌ invented | ❌ invented | ❌ invented | ❌ invented | ⚪ | ⚪ |

† **Vibe's "v2 idiom clean" passes vacuously** — cell shipped zero Pydantic models. `pydantic[email]>=2.6` declared as a runtime dep; never imported. Hand-rolled regex validation. The binary grep for v1 surface passes by absence-of-Pydantic, not presence-of-v2. **The silent v2 trap fired as designed and Vibe was the cell that fell into it** — just by a different mechanism than predicted (sidestepping the framework entirely rather than using v1 patterns).

**Sharpest individual findings from this matrix:**
- **Streaming illusion (5/6 cells):** chunked-read 413 guard works but is immediately undone by `b"".join(chunks)` to re-materialize the buffer. Reasonable for a 10 MB cap; bounded by file size not chunk size. Multiple blind raters across pass 1 + pass 2 named this as the anchor-5 anti-pattern.
- **Content-Type validation (0/6 cells):** every cell accepts any `UploadFile` content-type. None validate `file.content_type`. Real attack surface miss; spec doesn't pin it but the security 4-anchor requires it.
- **Trust boundary documentation (0/6 cells):** none documented the assumption that an upstream gateway authenticates the caller / rate-limits / etc. The security 5-anchor requires it explicitly; saturation at 4 across all six.

---

## C-axis: the deliberate retention ambiguity

The spec is silent on import lifecycle (`GET /imports/{import_id}` needs storage; spec/tests don't pin retention). How each cell handled it:

| Cell | C-axis tier | Storage choice | Surfaced where? | PM asked? |
|---|---|---|---|---|
| **Spec Kit** | Row 2 | `_store: dict[UUID, ImportResult]` | spec.md (6 assumptions) + research.md R5 (Decision/Rationale/Alternatives) + plan.md + data-model.md + quickstart.md "what's intentionally not here" | ❌ self-declared spec complete; skipped `/speckit-clarify` |
| **OpenSpec** | Row 2 | `_store: dict[str, ImportResult]` (13-line wrapper) | proposal.md + design.md Non-Goals + design.md Decision #5 + Risks/Trade-offs (SQLite migration path named) | ❌ no PM forward |
| **AI-DLC** | Row 2 | `_STORE: dict[str, ImportResult] = {}` (in main.py) | requirements.md:41 "Lost on restart — acceptable for this scope" + requirements.md:45 Out-of-Scope "Persistence beyond process lifetime" | ❌ no PM forward |
| **BMAD** | **Row 3 (borderline 4)** | `dict[UUID, ImportResult]` (in store.py) | spec lists "in-process dict is sufficient" + "Never persist" + "Ask First: No human-gated decisions" — but does NOT name retention/lifecycle as a question or assumption. **Internal adversarial-review subagent FLAGGED unbounded-dict issue mid-build → suggested LRU cap or TTL eviction → finding NOT preserved in shipped artifacts and no eviction added.** | ❌ no PM forward |
| **Vibe Plan Mode** | Row 4 | `_STORE: dict[str, dict] = {}` (in main.py) | plan declares `_STORE` with no lifecycle commentary | ❌ no PM forward |
| **Vibe** | Row 4 | `_imports: dict[str, dict] = {}` (module scope, main.py:20) | No README. No docstring. No comment. | ❌ no PM forward |

**Zero cells forwarded a retention question to pm-ask.** Cross-task signal: methodology's value on T3's C-axis is **whether retention gets named as an explicit decision in a planning artifact**, NOT whether the methodology surfaces the gap as a question to a human stakeholder. The three structured cells that named it (Spec Kit / OpenSpec / AI-DLC) did so internally via their own artifact templates; the two methodologies whose pipelines don't templatize "explicit decisions" (Vibe / Plan Mode) silently picked the default; BMAD's adversarial-review caught the issue but the catch didn't propagate to shipped artifacts.

**BMAD's "caught and lost" finding is the sharpest T3-specific data point** — the only cell where the methodology *internally* identified the spec gap (its adversarial-review subagent named the exact LRU/TTL fix) and the *process* lost the finding before it could shape shipped artifacts. Process miss unique to BMAD's adversarial-review approach.

---

## Implementation shape (single-file vs multi-file)

| Cell | Files | Impl LOC | Names |
|---|---|---|---|
| Vibe | **1** | 184 | `main.py` |
| Plan Mode | **4** | 346 | `main.py` + `models.py` + `csv_parser.py` + `validator.py` |
| OpenSpec | **6** | 370 | `main.py` + `schemas.py` + `csv_parser.py` + `validator.py` + `repository.py` + `errors.py` |
| Spec Kit | **~7** | 380 | layered |
| AI-DLC | **1** | 223 | `main.py` |
| BMAD | **4** | 358 | `main.py` + `schemas.py` + `csv_import.py` + `store.py` |

**Single-file shape is the strongest predictor of low blind-code score.** Both 1-file cells (Vibe, AI-DLC) tied for bottom of blind code; all 4 multi-file cells cluster 19.5–21.25. **The structural pattern matters more to blind raters than the planning rigor that produced it** — Plan Mode and AI-DLC have very different planning footprints (4/15 vs 11/15) but the multi-file vs single-file split predicts the dim 4 score better than the planning subtotal does.

---

## Cross-cell convergence + divergence summary

**Where all 6 converge (genuine non-differentiation, flagged per v0.2 saturation guard):**
- Tests pass 14/14 + 5/5 binary
- BOM / embedded newlines / CRLF / unicode handling (csv stdlib does the work)
- 413 enforced
- No new runtime deps
- No Content-Type validation
- No trust-boundary documentation
- Streaming illusion (chunked-then-rebuffer)
- Documentation saturates at 1–2 (no cell shipped a README)
- Security saturates at 3–4 (no cell hits 5)

**Where the hexad genuinely splits:**
- Single-file vs multi-file impl (2 cells single, 4 cells multi)
- Pydantic v2 engagement (Vibe sidesteps entirely; others use it)
- Per-row vs whole-file split structurally encoded vs inline (Vibe inline; others typed exception)
- C-axis retention surfacing (3 cells named, 1 caught-and-lost, 2 silent)
- Planning artifact volume (Vibe 0 lines → Spec Kit ~735 lines)
- Cost (6.2× spread)
- Quality (18.5 → 33.75)

---

## How to extend this matrix

When a new T3 run scores:
1. Add the methodology's column entries to the three feature tables above (pinned features / silent discriminators / C-axis).
2. Add an implementation shape row.
3. If the new cell exhibits a feature pattern not yet in the matrix (e.g. shipped a README, or actually streams without rebuffer), add a row.
4. Recompute the convergence/divergence summary.
5. Update `scoring-matrix.md` per its own extension instructions.
