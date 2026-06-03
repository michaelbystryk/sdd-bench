# T2 — Success Criteria (v0.1)

T2 (Library API extension, brownfield-additive-small) scoring. Applied after a cell completes; used identically across methodologies.

Universal rubric (anchors, defect-count protocol, blinding): [`harness/scoring-rubric.md`](../../harness/scoring-rubric.md). This file declares T2-specific binary outcomes, which dimensions apply, and task-specific scoring detail.

---

## 1. Binary outcomes (pass/fail, reported as a list)

| Outcome | Pass condition |
|---|---|
| **Existing tests still pass** | All of `tests/test_books.py` + `tests/test_members.py` (11 tests) still pass after the change. Zero regressions. |
| **Loan tests pass** | All 10 tests in `tests/test_loans.py` pass. Report partial pass count if not all (e.g., 7/10). |
| **No new dependencies** | No additions to `pyproject.toml` dependencies. The task is solvable with the existing stack. |
| **Convention adherence (binary cut)** | Errors via `AppError` (not inline `HTTPException`); business logic in a service (not the router); Pydantic v2 `*Create`/`*Read` split; `Page` envelope reused for the loans list. (For 0–5 nuance, see dim 3 + dim 4.) |

A cell that fails "Loan tests pass" still gets scored on all dimensions — partial implementation is data. Note the pass count.

## 2. Dimensions applied

10 of the 12 dimensions. **UI (dim 5) and UX (dim 6) are `n/a`** — no end-user UI surface (pure HTTP API). Security (dim 8) **applies** — there is an untrusted-input/network surface (request bodies, path/query params).

Two dimensions are **load-bearing for T2**:

- **Dim 3 (Code quality)** — idiom-matching is the core of a brownfield extension. A correct implementation written in a style alien to `app/` (inline `HTTPException`, logic in the router, no schema split) scores low here even if tests pass.
- **Dim 4 (System design)** — how well the new loan slice fits the existing router→service→repository layering and reuses the established patterns (`Page`, `AppError`, the datastore reset hook), rather than bolting on a parallel structure.

## 3. T2-specific scoring detail

### Functionality — does the extension do what the brief asked

To score 4+: all three endpoints work including the error cases (unknown book/member, no copies, loan limit, double return). Score 5 only if the implementation also handles an edge case not pinned by the tests and surfaces it (e.g., rejects a self-inconsistent request, or documents the concurrency assumption of the in-memory store).

### Code quality + System design — fits the existing codebase

The bar is brownfield, higher than greenfield T1/T3. The new code should be indistinguishable in style from the existing `app/` modules. Score dim 3 at 0–1 if the implementation reaches for patterns the codebase deliberately avoids (raising `HTTPException` in routers, putting business logic in the route handler, skipping the `*Create`/`*Read` split). Score dim 4 low if loans are wired through a parallel structure that ignores `deps.py` / the repository pattern.

### Robustness — the pinned error cases plus the unpinned ones

All four documented 409/404 paths handled with the correct envelope and code. For 4+: thoughtful about an edge the tests don't pin (returning a loan whose book was deleted; negative/oversized pagination; a member at exactly the limit who returns one then re-borrows).

### Security — boundary validation

Input validated at the boundary (Pydantic handles body validation; path/query coerced and bounded). No obvious injection or unvalidated-path surface in an in-memory service, so the realistic ceiling is ~3–4; score 5 only if the methodology documents the trust boundary (e.g., "no authn — assumes an upstream gateway authenticates the member").

### Spec articulation (planning artifact quality)

For methodologies that produce planning artifacts (OpenSpec, Spec Kit, AI-DLC, BMAD): does the artifact correctly characterize the *existing* conventions before extending them — i.e., is there evidence the methodology read `app/` rather than designing in a vacuum? A spec that re-derives a data model the codebase already has (instead of reusing it) scores low.

For Vibe (no methodology layer): the "spec" is commit messages + code comments. Score these as the methodology's articulation.

## 4. Failure-mode characterization (qualitative, for observations.md)

T2 has known failure modes worth flagging:

- **Convention drift** — correct behavior, alien style (inline `HTTPException`, router-resident logic, no schema split). The headline failure mode for this task.
- **Parallel structure** — builds a fresh loan store/layer that ignores `database.py`, `deps.py`, the repository pattern.
- **Dependency creep** — pulls in SQLAlchemy / an ORM / a new lib for a task the existing stack already covers.
- **Test overfitting** — hardcodes to pass the visible tests (e.g., literal `3` for the loan limit instead of reading `MAX_ACTIVE_LOANS`) in a way that wouldn't survive a config change.
- **Regression** — breaks an existing book/member test while wiring loans (e.g., mutating shared state, breaking the reset hook).
- **Phantom planning** — extensive planning artifacts that don't reflect actual reading of `app/`.

## 5. Headline finding for T2

Expected interesting contrasts:

- Vibe expected to implement fast; risk of convention drift (reaching for `HTTPException` out of habit) since it has no step that forces reading the conventions first.
- Spec Kit / OpenSpec expected to inspect before extending; the question is whether their planning step actually grounds in the existing code or re-specs from scratch.
- AI-DLC / BMAD expected to over-formalize a ~3-endpoint addition; watch the methodology-overhead ratio.

If a structured methodology's "read the codebase" step produces materially higher convention adherence (dim 3 + dim 4) than Vibe at comparable functionality, that's the T2 finding: **on small brownfield extensions, the value of methodology is convention-grounding, not feature-discovery.** If Vibe matches them at a fraction of the cost, that's the opposite finding and just as publishable.

---

*v0.1 locked structure. Refine when methodology runs produce real failure data. Base service test state at lock: 11 passing, 10 failing (the task).*
