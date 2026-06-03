# analysis/t2-library-loans/

t2 — Library API extension: add 3 loan endpoints to an existing FastAPI service (low complexity / LOW ambiguity — the brownfield workhorse). Retasked from the retired "better search" cell on 2026-05-27; see `harness/scoring-rubric-changelog.md` v0.2.1.

## Status

No cells scored yet. This folder will contain:
- `feature-matrix.md` — cross-cell feature audit (once 2+ methodology cells are scored on this task)
- Other task-specific cross-cell analyses as they become useful

## Inputs (when scoring begins)

- Task brief: `../../tasks/t2-library-loans/brief.md`
- Base service (the reference): `../../tasks/t2-library-loans/starter/`
- Per-cell observations: `../../runs/t2-library-loans/<methodology>/run-NNN/observations.md`
- Cell artifacts: `../../runs/t2-library-loans/<methodology>/run-NNN/artifacts/`

## Template (use when starting feature-matrix.md)

Copy the structure of `../t4-fitness-app/feature-matrix.md` — it's the canonical model. Per-task feature rows will differ; the legend, layout, "How to extend" section, and 6-column methodology layout (Vibe / Plan Mode / OpenSpec / Spec Kit / AI-DLC / BMAD) stay the same. For T2 the rows are the convention-adherence signals (error envelope, service layer, schema split, Page reuse) + the 10 loan-test pass/fail + correctness defects.
