# T3 — Blind code-only pass (6 dimensions, ≥2 raters)

**Date:** 2026-05-27. **Protocol:** scoring-rubric v0.3 (blind-agents-primary). T3 is the second task scored **blind from the start** with **both** the primary blind pass AND a second blind panel (≥2 raters per bundle, the protocol's full requirement) — matches T2's pattern. Both passes spawned in parallel from the orchestrator session.

## Method

- Staged 6 anonymized **code-only-plus-spec** bundles at `/tmp/t3-blind/output-{A..F}`: each contained `app/` + `tests/` + `pyproject.toml` + `reference/` (openapi.yaml + sample_csvs needed to run the tests). **All methodology tells stripped** — no `openspec/`, `.specify/`, `specs/`, `_bmad-output/`, `_bmad`, `CLAUDE.md`, `aidlc-docs/`, `.aidlc-rule-details/`, `docs/`, no planning artifacts. Plus venvs (`.venv*`), caches (`.pytest_cache/`, `__pycache__/`, `*.egg-info`), lockfiles (`uv.lock`), git metadata (`.git/`), OS cruft (`.DS_Store`), and `.pm-ask-cell` markers. Re-scanned clean of identifying strings (`openspec | spec.kit | speckit | bmad | ai.dlc | aidlc | claude.code | methodology | FR-N | EARS | inception | construction | PRD | story | epic | spec.md`). Seed = `20260527`.
- Randomized label map (compile-time key, [`blind-label-map.md`](blind-label-map.md), revealed only here): **A = AI-DLC · B = OpenSpec · C = Spec Kit · D = Vibe Plan Mode · E = BMAD · F = Vibe.**
- **12 independent fresh subagent raters** spawned from the orchestrator session in parallel: 6 for pass 1 (write `REVIEW.md`, use `.venv-p1`), 6 for pass 2 (instructed to ignore any existing `REVIEW.md`, write `REVIEW-2.md`, use `.venv-p2` to avoid collision). Each ran `uv venv --python 3.11 && pytest`, read the code, scored on the rubric's absolute anchors.
- **Scope: the 6 code-visible dimensions** — Functionality (1), Code quality (3), System design (4), Robustness (7), Security (8 — load-bearing for T3 because the file-upload trust boundary is a real attack surface, scoreable to 5 unlike T2's saturated-at-3 in-memory service), Documentation (9 — *shipped* docs only). Spec articulation / Scope / Assumptions cannot be blind-rated (they live in the planning artifacts = the methodology tell) → single-rater, disclosed; see `scoring-matrix.md`.

## Pass 1 — blind scores per dim (the 6 code-visible dims)

| Methodology | Func | Code | System | Robust | Security | Docs | **Code-visible /30** |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **OpenSpec** (B) | 4 | 4 | 3.5 | 3.5 | 4 | 2 | **21** |
| **Vibe Plan Mode** (D) | 4 | 4 | 4 | 3.5 | 3.5 | 2 | **21** |
| BMAD (E) | 4 | 4 | 4 | 3.5 | 3.5 | 1 | 20 |
| Spec Kit (C) | 4 | 4 | 4 | 3 | 3.5 | 1 | 19.5 |
| AI-DLC (A) | 4 | 3 | 3 | 3.5 | 3 | 1 | 17.5 |
| Vibe (F) | 4 | 3 | 3 | 3 | 3 | 1 | 17 |

## Pass 2 — second blind panel + reconciliation

Six fresh subagents, same anonymized bundles, instructed to ignore any existing `REVIEW.md` and write `REVIEW-2.md`. Per-dim comparison (P1 → P2; ! = >0.5pt, !!! = >1pt disagreement triggering protocol review):

| Cell | Func | Code | Sys | Rob | Sec | Doc | P1 /30 | P2 /30 | Avg |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| Vibe Plan Mode (D) | 4→4 | 4→4.5 | 4→4.5 | 3.5→3.5 | 3.5→3.5 | 2→1.5 | 21 | 21.5 | **21.25** |
| OpenSpec (B) | 4→4 | 4→4 | 3.5→4 | 3.5→3.5 | 4→3.5 | 2→1.5 | 21 | 20.5 | **20.75** |
| BMAD (E) | 4→4 | 4→4.5 | 4→4 | 3.5→4 | 3.5→3.5 | 1→1.5 | 20 | 21.5 | **20.75** |
| Spec Kit (C) | 4→4 | 4→4 | 4→4 | 3→3 | 3.5→3.5 | 1→1 | 19.5 | 19.5 | **19.5** |
| Vibe (F) | 4→4 | 3→3 | 3→3 | 3→4 | 3→3 | 1→1 | 17 | 18 | **17.5** |
| AI-DLC (A) | 4→4 | 3→3 | 3→2.5 | 3.5→3.5 | 3→3 | 1→1 | 17.5 | 17 | **17.25** |

**Reconciliation (v0.3 rule: same-condition >1 → rescore together with anchor discussion).**

**Zero genuine >1 disagreements, all 36 dim-pairs.** Pass 1 and pass 2 agree within 1 pt on every single dim, every cell — strongest inter-rater agreement of the eval so far (T2 had 1 disagreement; T1's retrofit blind pass had several). The protocol's rescore rule does not trigger; no anchor discussion needed.

**Observations on the ≤1pt drift between passes** (kept separate per v0.3, not averaged into the "official" pass-1 history; reported here for transparency):

- **Pass 2 was slightly harder on Doc** for cells D and B (vibe-planmode 2→1.5; openspec 2→1.5) — interpretable as anchor-2-vs-anchor-1 boundary on "minimal one-liner docstrings vs zero docs" (1pt range, kept separate).
- **Pass 2 was slightly easier on Code + System** for cells D and E (vibe-planmode 4/4 → 4.5/4.5; bmad 4/4 → 4.5/4) — both raters credited the multi-file separation more generously on second look.
- **Pass 2 was slightly easier on Robustness** for cells E and F (bmad 3.5→4; vibe 3→4) — both at the 0.5-1pt threshold; reflects different reads on whether row-error messages are "value-aware" (anchor 4 clause).
- **AI-DLC dropped 0.5 on System** in pass 2 (3→2.5) — second rater more strict on "no separation of parse/validate/store/shape" given the 223-LOC single-file shape.

| Binary | all six |
|---|---|
| pytest | **14/14** (every bundle) |
| new runtime deps | **none** added to `pyproject.toml` |

## Findings

1. **Across both passes, the code-visible dims sit in a 17.0–21.5/30 band (range 4.5).** Per-cell averages: **Vibe Plan Mode 21.25 > OpenSpec 20.75 ≈ BMAD 20.75 > Spec Kit 19.5 >> Vibe 17.5 ≈ AI-DLC 17.25.** This is a **wider blind-code spread than T2** (T2's range was 2.5: 23.5–26/30). T3's larger surface (Pydantic v2 idiom, separate parse/validate/store/shape modules, content-type validation, streaming intent) gave the blind raters more to discriminate on.

2. **HEADLINE SHIFT FROM T1+T2: Vibe is at the BOTTOM of the blind code band on T3, not the top.** T1: Vibe co-led blind code. T2: Vibe was the only cell at the top of both passes. **T3: Vibe is tied for last (17.5) with AI-DLC (17.25).** Why: the silent v2-idiom trap discriminated under blind review, just not via the binary check. Vibe sidestepped Pydantic entirely (hand-rolled regex validation); blind raters consistently docked dims 3+4 for this — Code quality 3/3 (vs structured cells' 4–4.5), System design 3/3 (vs structured 4/4–4.5/4.5). Multiple raters wrote phrases like *"not idiomatic Pydantic v2 — `UserRow` is declared as a `BaseModel` but used purely as a dumb data container"* and *"no Pydantic models at all"*. **The framework-discrimination trap fired exactly as designed — and Vibe was the cell that fell into it.**

3. **AI-DLC is ALSO at the bottom of blind code (17.25)** — same band as Vibe. **The full Inception+Construction lifecycle (the heaviest planning AI-DLC supports) produced a 223-LOC single-file `main.py` — same god-file shape as Vibe's 184 LOC.** Multiple raters cited the single-file structure as failing the system-design anchor-4 "clear separation of parse/validate/store/shape (typically multiple modules)" clause. **Methodology that surfaces the retention question in requirements docs but ships a structurally identical implementation to the no-planning control.** Sharpest "planning didn't change the output shape" data point in T3.

4. **Vibe Plan Mode TOPS blind code (21.25).** Plan Mode's structured pre-build plan led to multi-file impl (`csv_parser.py` + `validator.py` + `models.py` + `main.py`) with idiomatic Pydantic v2 (`TypeAdapter`, `Field`, `Literal`, `EmailStr`). On the **code-only dimension** this is the highest-scoring T3 cell — but its planning subtotal (4/15) drags total /45 to 25.25 (5th of 6).

5. **OpenSpec + BMAD tie for second on blind code (20.75 each).** OpenSpec's quality is paired with the smallest single-file design (parse/validate/store/shape split across 6 modules including a typed `WholeFileError` caught by handler — multiple raters cited this approvingly). BMAD's quick-dev path shipped a 4-file impl (`csv_import.py` + `main.py` + `schemas.py` + `store.py`) that the blind raters consistently rated similarly to OpenSpec's heavier-planning output. **BMAD's quick-dev right-sizing reached the same blind code band as full structured methodologies at lower planning cost.**

6. **Spec Kit at 19.5 blind code** — the dock came mostly from Robustness (3 vs others' 3.5–4): the streaming claim re-buffers via `b"".join(chunks)` and value-aware error messages are partially absent. Multiple raters flagged the same `_read_with_size_cap` pattern. **Spec Kit's richer planning (13.5/15) does not translate to higher blind code than OpenSpec's leaner planning (13/15).** The marginal value of Spec Kit's full pipeline over OpenSpec is planning-artifact volume, not shipped code quality.

7. **Documentation saturates at 1–2 across all six** — same pattern as T2. No cell shipped a README. Single-line docstrings in some cells (the highest, OpenSpec + Vibe Plan Mode, hit 2). **Genuine non-differentiation**, flagged per the v0.2 saturation guard. The in-memory storage caveat (the C-axis ambiguity) is named in shipped code by zero cells; only planning artifacts surface it.

8. **Security saturates at 3–4 across all six** — file-upload trust boundary made dim 8 scoreable to 5 (unlike T2's in-memory-saturate-at-3), but no cell documented the trust boundary explicitly in code/docstring. OpenSpec topped at 3.75 avg (pass 1 had it at 4 for explicit chunked-read 413; pass 2 docked to 3.5 for missing content-type check). All cells failed the 5-anchor "trust boundary documented in code or docstring" clause.

9. **The "streaming illusion" pattern fired across 5/6 cells** — every cell except possibly OpenSpec (debated by raters) did chunked-read for the 413 guard followed by `b"".join(chunks)` to re-materialize the full buffer. Multiple raters across both passes named this the anchor-5 disqualifying anti-pattern for Robustness. **Genuine non-differentiation that captures a real-world failure mode** (chunked-read-then-rebuffer is so common it's the default mental model; streaming end-to-end requires more deliberate design).

## Implication

T3's code-visible scores are backed by **two independent blind passes** (the v0.3 protocol's ≥2-rater requirement met, from the start). **Zero >1pt disagreements across 36 dim-pairs — strongest inter-rater agreement so far.** Both passes' per-dim scores stand as committed history.

**The headline reverses the T1/T2 pattern:** on small, fully-specified work where the framework matters (Pydantic v2 + FastAPI streaming), **the no-planning control falls behind on shipped code, tied with the heaviest-planning methodology that shipped a single-file impl.** The reproducible cluster is the multi-file structured cells (OpenSpec / BMAD / Vibe Plan Mode / Spec Kit, 19.5–21.25 blind code). The cost-sensitive + rigor-maximalist buyers now have different answers:

- **Indie / cost-sensitive (Q/$ + product floor):** OpenSpec wins again (33.75 quality + 11.6 Q/$ + lowest structured cost). Replicates from T4, T1, T2. **Four-task cost-efficiency frontier.**
- **Enterprise / rigor-weighted:** Spec Kit (33 + 13.5/15 planning rigor + 0 defects) and OpenSpec (33.75 + 13/15 planning + 2 minor defects) are co-leaders; Spec Kit's defect-free record + richer artifact set wins the rigor lens at ~2× the cost.
- **Quality-floor:** Both OpenSpec (33.75) and Spec Kit (33) clear any reasonable quality bar. BMAD (29.75) and AI-DLC (28.25) trail. Vibe Plan Mode (25.25) and Vibe (18.5) below.

**Cross-task pattern, now corroborated 4×:** OpenSpec is the cost-efficiency frontier on T1 + T2 + T3 + T4.

*Pass 1 + pass 2 both run 2026-05-27 from this orchestrator session (12 parallel subagents). Reviews preserved at `/tmp/t3-blind/output-{A..F}/{REVIEW,REVIEW-2}.md`. Reproducible: re-stage from `~/dev/sdd-bench-t3-builds/<meth>/` per the staging step (rsync excludes documented in `blind-label-map.md`), apply the label map, re-review with the locked prompt in `blind-rater-prompt.md`.*
