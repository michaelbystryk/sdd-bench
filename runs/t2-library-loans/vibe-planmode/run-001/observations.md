# T2 — Vibe Plan Mode / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary.** Code-visible dims (1/3/4/7/8/9) from blind agent on `output-F`; planning dims (10/11/12) single-rater from the in-session Plan Mode plan (transcript-only, ~70 lines, extracted from JSONL). UI/UX = n/a. PROVISIONAL.

## Binary outcomes
existing tests **11/11** · loan tests **10/10** · no new deps · convention cut pass → **4/4**

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | 4 | blind | All three endpoints + every pinned error case; held below 5 by the unknown-member-on-list gap (200 empty instead of 404). |
| 3 | Code quality | 4 | blind | Readable, typed, stylistically consistent with books/members; not 5 — loose `status` typing on service/repo boundary. |
| 4 | System design | 4 | blind | Clean layering, reuses `Page`/`AppError`/`reset_db`; not 5 — non-obvious decisions not documented in code. |
| 7 | Robustness | 4 | blind | Pinned bad inputs handled; concurrency assumption undocumented. |
| 8 | Security | 3 | blind | Saturation across all six (in-memory ceiling). |
| 9 | Documentation | 4 | blind | Docstrings present; no README update for loans. |
| 10 | Spec articulation | **4** | single | The in-session plan **names existing conventions by file** (AppError, Page, `MAX_ACTIVE_LOANS` already in config, "every layer mirrors Book/Member — no new patterns") + testable acceptance criteria + per-file change list + a rationale'd decision (Literal not Enum). Caps at 4: no formal alternatives-considered, no edge-prediction beyond the pinned tests. |
| 11 | Scope clarity | 2.5 | single | In-scope clearly listed (3 endpoints, no new deps); out-of-scope implicit only — no explicit cut-with-reasons section. |
| 12 | Assumption surfacing | 1.5 | single | A couple of choices noted with light rationale (Literal vs Enum, borrowed_at "for a complete record") but no explicit assumption section; no consequence-if-wrong language. |

**Quality sum: 31/45**  ·  Vector → Product /10: **8** · Rigor /35: **23**

## Defects (from blind review)
- **Critical:** 0
- **Major:** 0
- **Minor (5):**
  1. `GET /members/{id}/loans` doesn't check member exists → 200 `{items:[]}` instead of 404 (rater classed Minor — "defensible for a collection endpoint"; OpenSpec's rater classed the same behavior Major — inter-rater severity variance).
  2. Loose status typing (`Loan.status: str`, service/repo accept `status: str | None` while router has `LoanStatus`).
  3. `httpx` runtime dep (baseline).
  4. `MemberCreate.email` unvalidated as email (baseline).
  5. Removed-book restock guard defensive-only with no log/note.

## Cost (see token-log)
$**1.35** · **3m 45s** API · 1.06 M tokens · **Q/$ 23.0** · cost/binary **$0.34** · routing: one in-session Plan Mode plan (transcript-only; no plan file artifact); overhead ratio _pending phase split_.

## Depth / routing
Plan Mode produced one structured plan before implementing (~70 lines, in transcript). Plan correctly read `app/` (named every existing convention by file) and laid out per-file changes; no revisions needed (plan converged on first approval).

## Headline
**31/45 · $1.35 / 3m 45s API · 4/4 binary.** One conventions-grounded plan → +3 quality over Vibe (entirely planning dims) for +$0.34. Shares OpenSpec's member-existence-on-list gap (Minor per its rater). **Highest Quality/API-hour (496) in the hexad.**

## What it did well / where it lost points
**Did well:** plan named every existing pattern by file before designing ("every layer mirrors Book/Member — no new patterns"); per-file change list; cheap upgrade over Vibe; very fast (3m 45s API).
**Lost points:** plan is transient (in-session, no out-of-scope reasons, no formal assumptions); shares the OpenSpec convention gap (member-existence not enforced on list); status typing loose.
