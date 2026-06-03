# T6 — Success Criteria (v0.1)

T6 (OSS bug-fix, brownfield-surgical) scoring. Applied after a cell completes; used identically across methodologies.

Universal rubric (anchors, defect-count protocol, blinding): [`harness/scoring-rubric.md`](../../harness/scoring-rubric.md). This file declares T6-specific binary outcomes, which dimensions apply, and task-specific scoring detail.

---

## 1. Binary outcomes (pass/fail, reported as a list)

| Outcome | Pass condition |
|---|---|
| **Existing test suite still passes** | All previously-passing tests in the repo's CI suite still pass after the fix. Zero regressions. |
| **Regression test added** | A new test exists that (a) fails on the pre-fix code, (b) passes on the post-fix code. Methodology must produce both proof points. |
| **Diff scope minimal** | Net LOC change ≤ 100. Files touched ≤ 5 (excluding tests). Excess = failure mode, captured in scoring notes. |
| **Convention adherence (binary cut)** | Linter passes. No new lint warnings. File organization matches repo conventions. (For 0–5 nuance, see dim 4 + dim 11 in rubric.) |
| **Root cause identified** | Methodology's planning artifacts (or commit messages, in Vibe's case) name the actual root cause — not "added a try/catch" or "checked for null without explanation." |
| **PR-readiness** | The diff would be accepted with light-or-no review by a maintainer. (For 0–5 nuance, see dim 4 + dim 9.) |

A cell that fails "Existing test suite still passes" still gets scored on remaining dimensions — broken-CI fix is data.

## 2. Dimensions applied

All 12 dimensions per the rubric. Two are particularly load-bearing for T6:

- **Dim 4 (System design)** — applies with the caveat "limited — small fixes." Score reflects how well the fix fits the existing architecture, not whether the methodology designed a new system.
- **Dim 11 (Scope clarity)** — **load-bearing for T6.** A methodology that produces a 200-LOC diff for a 10-LOC bug scores low on scope clarity regardless of whether the fix works.

## 3. T6-specific scoring detail

### Functionality — does the fix actually fix the bug

To score 4+ on Functionality, the fix must:
- Address the root cause described in the issue, not just the symptom.
- Not introduce new bugs in the same area (verified by adjacent test coverage).
- Handle edge cases mentioned in the issue thread (if any).

Score 5 only if the fix also addresses a related-but-unmentioned edge case the methodology surfaced during investigation.

### Code quality + System design — fits the existing codebase

The bar is higher than greenfield T1–T4. The fix should be indistinguishable in style from existing code in the same module. Score 0 if the fix uses imports/patterns/style the repo doesn't use elsewhere.

### Robustness — defensive without overreach

T6-specific: a fix that adds defensive code (try/catch, null checks) far beyond what the bug requires scores low on Scope clarity. A surgical fix scores high.

### Documentation — commit messages + code comments

- Commit messages: do they follow the repo's convention (conventional commits, etc.)? Do they explain *why*, not just *what*?
- Code comments: any comments added are about non-obvious decisions or workarounds (not "this checks for null").

### Spec articulation (planning artifact quality)

For methodologies that produce planning artifacts (OpenSpec, Spec Kit, AI-DLC, BMAD): does the artifact correctly characterize the bug? Did they form a hypothesis before changing code, or did they pattern-match a fix from similar issues elsewhere?

For Vibe (no methodology layer): the "spec" is the commit messages + code comments. Score these as the methodology's articulation.

## 4. Failure-mode characterization (qualitative, for observations.md)

T6 has known failure modes worth flagging:

- **Symptom-patching** instead of root-cause fixing (e.g., adding `try: ... except: pass` around the failing call)
- **Over-scoping** — refactoring adjacent code that wasn't broken
- **Under-scoping** — fix works in the reported case but misses obvious related cases
- **Test theater** — adding a regression test that doesn't actually exercise the bug, or that would pass regardless of the fix
- **Convention drift** — fix is correct but written in a style alien to the codebase
- **Phantom planning** — methodology generates extensive planning artifacts that don't reflect actual code investigation

Score each in observations.md if observed.

## 5. Headline finding for T6

Expected interesting contrasts in v0.8 results:

- Vibe expected to dive into code quickly; risk of symptom-patching
- Spec Kit expected to spec-then-investigate (might over-plan a small fix)
- AI-DLC expected to run its full gated Inception→Construction workflow (its dense approval gates may over-formalize a one-off bug)
- BMAD expected to produce a story + architecture analysis (likely massively over-engineered for a bug fix)

If Vibe wins T6 while structured methodologies dominate T4/T5, that's the second headline finding: **methodology fitness depends on task type — planning helps features, hurts surgical fixes.**

---

*v0.1 locked structure. Refine when repo + issue are picked and methodology runs produce real failure data.*
