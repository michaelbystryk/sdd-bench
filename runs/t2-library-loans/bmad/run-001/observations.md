# T2 — BMAD / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims from blind agent on `output-B`; planning dims single-rater from 3 BMAD artifacts (~379 lines: 1 unified spec + 1 diff + 1 deferred-work). UI/UX = n/a. PROVISIONAL.

## Binary outcomes
existing tests **11/11** · loan tests **10/10** · no new deps · convention cut pass → **4/4**

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | 4 | blind | All endpoints + all named errors; not 5 — no thoughtful unpinned-edge surfacing. |
| 3 | Code quality | **5** | blind | Idiomatic, well-named, restraint where appropriate; `LoanStatus` owned by `models.py` (avoids cycle with schemas). |
| 4 | System design | 4 | blind | Clean layering; member-loans route in members.py; not 5 — design rationale stays in spec, not code comments. |
| 7 | Robustness | 4 | blind | Pinned cases handled; concurrency-undocumented-in-code (deferred-work.md formally captures it though). |
| 8 | Security | 3 | blind | Saturation. |
| 9 | Documentation | 4 | blind | Docstrings + design notes; no README update. |
| 10 | Spec articulation | 4.5 | single | Single spec covers all 10 I/O scenarios + acceptance criteria + decisions with rationale ("limit wins", "no copy decremented on rejection") + predicts the precedence edge before code. Gap: I/O matrix omits the unknown-member-on-list case. |
| 11 | Scope clarity | 4 | single | Boundaries section lists in (3 endpoints, layered stack) + out (no deps/persistence/envelope changes); "Ask First" gate for existing book/member; one formal deferral (concurrency) with named resolution condition. |
| 12 | Assumption surfacing | 3.5 | single | 4 surfaced assumptions, each names choice + dependency (MAX_ACTIVE_LOANS reuse, ConflictError code= kwarg, live-entity mutation, concurrency deferred); not categorized + not file-mapped → 3.5. |

**Quality sum: 36/45**  ·  Vector → Product /10: **8** · Rigor /35: **28**

## Defects (from blind review)
- **Critical:** 0
- **Major:** 0
- **Minor (4):**
  1. `return_loan` calls `BookService.get_book()` which raises `NotFoundError` if the book is gone — confusing surface on a *return* (latent; no delete endpoint reachable today).
  2. `httpx` declared runtime not dev (baseline).
  3. In-memory store mutates `Book.available_copies` with no concurrency guard / no documented single-process assumption (the deferred-work.md captures the deferral but code-level comments don't).
  4. Checkout precedence: limit check before copies → member at limit checking out unavailable book gets `loan_limit_exceeded` not `no_copies_available` (defensible, undocumented in code).

## Cost (see token-log)
$**4.33** · **14m 11s** API · 3.33 M opus + 1.0 M Haiku tokens · **Q/$ 8.3** · cost/binary **$1.08** · routing: **quick-dev (self-routed)** — one tight spec + diff + deferred-work, no analyst→PM→architect→stories pipeline. Haiku non-negligible ($0.22) — BMAD's subagent dispatch.

## Depth / routing
3 artifacts, ~379 lines. spec-loans-api.md (130 lines: intent + boundaries + I/O matrix + code map + tasks + acceptance criteria + design notes + verification) + deferred-work.md + loans-api.diff. **Self-routed to quick-dev** (right-sized for a small fully-specified task) — `_bmad-output/planning-artifacts/` empty, no PRD, no architecture, no stories. **Per the BMAD accept-adaptive policy this is the finding, not a failure.**

## Headline
**36/45 · $4.33 / 14m 11s API · 4/4 binary.** **Self-routed to quick-dev** on a neutral kickoff — right-sized vs the $75.85 T4 blowout. Lands in the structured cluster at high cost (Q/$ 8.3); Code quality 5 blind.

## What it did well / where it lost points
**Did well:** code-map cited each existing file by line before designing; reused `ConflictError(code=)` rather than new subclass; deliberate `LoanStatus` placement in `models.py` to avoid cycle; one tight spec + diff is genuinely lighter than the other structured cells; Code quality 5 blind.
**Lost points:** spec I/O matrix omits the unknown-member-on-list case (didn't surface as a concern even though loans was in members.py); concurrency deferred in deferred-work.md but not commented in code; Haiku subagent dispatch adds non-negligible cost (extra ~$0.22 + 1 M tokens).
