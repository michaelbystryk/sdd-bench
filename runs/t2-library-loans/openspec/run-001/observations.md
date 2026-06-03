# T2 — OpenSpec / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims from blind agent on `output-A`; planning dims single-rater from 4 OpenSpec artifacts (~160 lines: proposal + design + tasks + spec). UI/UX = n/a. PROVISIONAL.

## Binary outcomes
existing tests **11/11** · loan tests **10/10** · no new deps · convention cut pass → **4/4**

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | 4 | blind | All endpoints + named errors; held below 5 by Major (below) — listing unknown member returns 200 not 404, breaking the id-not-found convention. |
| 3 | Code quality | 4 | blind | Mirrors `BookService`/`MemberService`; not 5 — `status` is stringly-typed where a `Literal` is the cheap abstraction. |
| 4 | System design | 4 | blind | Clean layering + reuses shared pieces; not 5 — `Loan` only partly encodes invariants (free-string status, no `loaned_at`). |
| 7 | Robustness | 4 | blind | Pinned bad inputs handled; the unpinned edge it guards (book-removed restock) is unreachable + uncommented; concurrency undoc. |
| 8 | Security | 3 | blind | Saturation. |
| 9 | Documentation | 4 | blind | Docstrings present; no shipped README update. |
| 10 | Spec articulation | **5** | single | The spec has BDD-style scenarios with HTTP statuses + error codes + field assertions for every branch. The design.md **predicts non-obvious edges before code**: the limit-vs-availability check-order ambiguity, and the `available_copies` drift risk if checkout/return are asymmetric. The proposal cites every existing pattern verbatim (rejecting "store loans on member" with named reason). Strong foresight = the level-5 clause. |
| 11 | Scope clarity | 4 | single | Goals + Non-Goals listed with reasons (no persistence/due-dates/fines/renewals; member-existence-on-list explicitly deferred "beyond what tests require"); scope actively defended (rejects route-placement alternative). Caps at 4: not revisited after new info. |
| 12 | Assumption surfacing | **4.5** | single | 7 explicit assumptions (status as plain str, in-memory only, route split, validation order, `returned_at` shape, copies-drift risk, member-existence deferred). Each names the choice + consequence-if-wrong; not categorized → caps just under 5. |

**Quality sum: 36.5/45**  ·  Vector → Product /10: **8** · Rigor /35: **28.5**

## Defects (from blind review)
- **Critical:** 0
- **Major (1):** `GET /members/{member_id}/loans` skips member-existence check → returns `200 {items:[],total:0}` for an unknown member, breaking the `get_member`/`get_book` id-not-found convention; design.md explicitly cuts this as "beyond what tests require" → a planning-level convention gap.
- **Minor (4):**
  1. `status` is unvalidated free string on query param + `LoanRead` (invalid values silently return empty page, not 422).
  2. Restock guard `if book is not None` defends an unreachable state without comment.
  3. `Loan` records `returned_at` but no `loaned_at`/`created_at` — checkout time unrecoverable.
  4. TOCTOU on `available_copies` undocumented.

## Cost (see token-log)
$**1.89** · **5m 19s** API · 2.08 M tokens · **Q/$ 19.3** · cost/binary **$0.47** · routing: full `/opsx:propose → /opsx:apply` (archive not run); overhead ratio _pending phase split_.

## Failure-mode check
- Phantom planning: **No** — every existing pattern cited verbatim.
- Convention drift: **partial** — the member-existence convention break is explicit (not accidental).

## Depth / routing
4 planning artifacts (~160 lines, by far the most compact of the structured cells). proposal.md + design.md + tasks.md + specs/loans/spec.md. `/opsx:archive` not run (consistent with T4-OpenSpec pattern).

## Headline
**36.5/45 · $1.89 / 5m 19s API · 4/4 binary.** **Cost-efficiency frontier of T2** (36.5 quality at <half Spec Kit's cost). Best spec in the hexad (predicted the check-order + drift edges pre-code). One Major: list endpoint skips member-existence check — explicit design-level cut, not a code lapse.

## What it did well / where it lost points
**Did well:** dim 10 = 5 (genuine foresight: predicted the limit-vs-copies check-order ambiguity and the `available_copies` drift risk before code); 7 explicit assumptions with consequences; cost-efficiency frontier (Q/$ 19.3); cited every existing convention verbatim — strongest read-app/-first signal in the eval.
**Lost points:** the one Major convention gap was a *planning-level* choice (cut explicitly in design.md); status as plain str accepts invalid filter values silently; no `loaned_at` field.
