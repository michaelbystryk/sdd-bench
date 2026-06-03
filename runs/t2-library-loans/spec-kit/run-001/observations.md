# T2 — Spec Kit / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims from blind agent on `output-E`; planning dims single-rater from 8 Spec Kit artifacts (~430 lines: spec + plan + data-model + research + quickstart + tasks + contracts/loans + checklists). UI/UX = n/a. PROVISIONAL.

## Binary outcomes
existing tests **11/11** · loan tests **10/10** · no new deps · convention cut pass → **4/4**

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | **5** | blind | Three endpoints + all named errors + enforces member-existence on list; thoughtful interpretation. |
| 3 | Code quality | **5** | blind | Stylistically indistinguishable from books/members; small surprises (Enum-backed status gives free 422). |
| 4 | System design | **5** | blind | Clean layering; reuses every shared piece; pre-decided checkout precedence documented in plan. |
| 7 | Robustness | 4 | blind | Pinned errors handled; checkout precedence note absent in code (only in plan); TOCTOU undoc. |
| 8 | Security | 3 | blind | Saturation. |
| 9 | Documentation | 4 | blind | Docstrings + `--help` analog; **README omits the loans feature entirely** — no endpoint list, no error envelope mention. Caps at 4. |
| 10 | Spec articulation | 4.5 | single | All 10 pinned behaviors have testable criteria + 6 documented research decisions with rationale + alternatives; foresight on the limit-vs-copies precedence and the no-common-prefix router issue. Gap: didn't predict the defensive book-not-None restock guard. |
| 11 | Scope clarity | 4 | single | In + out scope listed with reasons (due-dates/fines/authz cut, status vocab closed); enforced across all 8 artifacts; no creep to defend against on this task. |
| 12 | Assumption surfacing | 3.5 | single | 11 surfaced (7 in spec + 4 "resolved unknowns"); each names a choice + consequence; not categorized + not mapped to file locations → 3.5. |

**Quality sum: 38/45**  ·  Vector → Product /10: **9** · Rigor /35: **29**

## Defects (from blind review)
- **Critical:** 0
- **Major:** 0
- **Minor (4):**
  1. `MemberCreate.email` accepts any non-empty string (baseline pattern inherited).
  2. Checkout's loan-limit check precedes copies-availability — defensible but undocumented in code (the planning artifacts document it; the *code* doesn't).
  3. TOCTOU on `available_copies` undocumented in code/repo docstrings.
  4. README omits loans feature (no endpoint list, no envelope format, no `MAX_ACTIVE_LOANS` mention).

## Cost (see token-log)
$**3.90** · **10m 30s** API · 3.69 M tokens · **Q/$ 9.7** · cost/binary **$0.98** · routing: full pipeline (`/speckit-specify` → `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`); overhead ratio _pending phase split_.

## Depth / routing
8 planning artifacts, ~430 lines. spec.md + plan.md + data-model.md + research.md + quickstart.md + tasks.md + contracts/loans.md + checklists/requirements.md. plan.md correctly classifies REUSED vs MODIFIED vs NEW files; research.md Decision 1 quotes the exact `services.py` docstring.

## Headline
**38/45 · $3.90 / 10m 30s API · 4/4 binary.** **T2 quality leader + blind code co-leader (26) + enterprise-lens winner.** Same shipped code a $1 Vibe run produces — the ceremony tax exemplar (Q/$ 9.7, ~4× Vibe).

## What it did well / where it lost points
**Did well:** top quality sum (38) + top Rigor (29); blind code tied for top with Vibe; correctly classified file-level impact in plan.md (REUSED/MODIFIED/NEW); status as Enum gave free 422 validation; checkout precedence pre-decided with rationale.
**Lost points:** README doesn't cover loans (planning docs don't count under "shipped docs"); Quality/$ 9.7 (the ceremony tax); assumptions not categorized; checkout-precedence rationale stays in planning, not code comments.
