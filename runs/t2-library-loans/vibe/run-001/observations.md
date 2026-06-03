# T2 — Vibe (vanilla Claude Code — control) / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims (1/3/4/7/8/9) from a single blind fresh agent on the anonymized bundle `output-C` ([blind-label-map](../../../../analysis/t2-library-loans/blind-label-map.md)); planning dims (10/11/12) single-rater from code-comments/commits (no planning artifact — per T2 success-criteria Vibe rule). UI/UX = n/a (HTTP API). PROVISIONAL.

## Binary outcomes
existing tests **11/11** · loan tests **10/10** · no new deps · convention cut pass → **4/4**

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | **5** | blind | Three endpoints + every named error case + enforces member-existence on the list endpoint (unlike OpenSpec/Plan Mode); rater cited level-5 thoughtful-interpretation clause. |
| 3 | Code quality | **5** | blind | Idiomatic, fully-typed, mirrors `BookService`/`MemberService` shape exactly; `LoanService` reuses `Depends`, `model_validate`, envelope build; named choices (well-chosen abstractions, restraint where appropriate). |
| 4 | System design | **5** | blind | Clean HTTP→service→repository; reuses `Page`/`paginate`/`AppError`/`reset_db`/`deps.py` — no parallel structure; non-obvious choices documented across docstrings (Create/Read split, AppError-over-HTTPException, handler-MRO, repo swap path). |
| 7 | Robustness | 4 | blind | All pinned error cases handled; defends an unreachable book-removed edge (restock guard); concurrency assumption undocumented — caps at 4. |
| 8 | Security | 3 | blind | Schema-validated bodies; path/query coerced; no obvious vulns; trust boundary not documented (saturation across all 6 cells). |
| 9 | Documentation | 4 | blind | Strong docstrings explaining rationale; no README update for loans → caps at 4. |
| 10 | Spec articulation | 1 | single | No planning artifact; the "spec" is code-comments + (no) commits — minimal articulation (per T2 Vibe rule). |
| 11 | Scope clarity | 1 | single | Scope is implicit only (just the three endpoints); no in/out list. |
| 12 | Assumption surfacing | 0 | single | No explicit assumption tags; concurrency assumption documented nowhere. |

**Quality sum: 28/45**  ·  Vector → Product /10: **9** · Rigor /35: **19**

## Defects (from blind review)
- **Critical:** 0
- **Major:** 0
- **Minor (5):**
  1. `Loan.status` typed `str` in `models.py` while `schemas.py` defines a `LoanStatus` Literal — invariant not encoded at the model entity.
  2. TOCTOU on `available_copies` (check-then-decrement); undocumented single-threaded assumption.
  3. Restock guard `if book is not None` uncommented; defends an unreachable state with no rationale.
  4. `httpx` in runtime deps (baseline starter issue, not introduced).
  5. `LoanService.list_member_loans` & `LoanRepository.list` accept `status: str | None` while router supplies validated `LoanStatus` — mild type-discipline looseness at the service/repo boundary.

## Cost (see token-log)
$**1.01** · **3m 27s** API · 804.3 K tokens · **Q/$ 27.7** · cost/binary **$0.25** · routing: single straight pass, no planning phase, n/a overhead.

## Depth / routing
Vibe wrote loan code in one pass; no planning artifact produced. Per the T2 success-criteria Vibe rule, the "spec" is code-comments + commits — the loan docstrings express some intent (rationale for design choices, AppError usage) but no acceptance criteria, no scope list, no explicit assumptions.

## Headline
**28/45 · $1.01 / 3m 27s API · 4/4 binary.** Blind code co-leader (26/30, tied with Spec Kit) at the lowest cost in the eval — correct, idiomatic, full-convention-adherent loans extension for a dollar. Near-zero planning dims (1/1/0) drag the sum down. **Quality/$ champion (27.7) + indie-lens winner.**

## What it did well / where it lost points
**Did well:** blind code tied for top with Spec Kit; full convention adherence (AppError, layering, `Page` reuse, `reset_db` extension, `MAX_ACTIVE_LOANS` reused — *without a plan asking it to*); 21/21 tests on first pass; cheapest cell in the hexad.
**Lost points:** planning dims 2/15 (no spec/scope/assumptions); concurrency undocumented; `Loan.status` looser than the schema layer.
