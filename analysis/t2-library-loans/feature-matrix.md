# T2-library-loans — Cross-cell feature & design-choice matrix

Companion to [`scoring-matrix.md`](scoring-matrix.md). Tracks *what* each cell decided (route placement, status typing, validation order, cuts, edge cases) — not how the rubric scored it.

**Headline:** *"All six produce near-identical shipped loan code (21/21 tests, convention cut passed, `LoanCreate`/`LoanRead`, `Page[LoanRead]`, `LoanRepository` wired into `reset_db`); the design choices that differ are tiny preferences (status as `str` vs `Literal` vs `Enum`; route in `loans.py` vs `members.py /{member_id}/loans`; checkout precedence order) — and one shared convention gap belongs to OpenSpec + Plan Mode (member-existence not enforced on the list endpoint), not the no-planning control."*

Legend: ✅ done · ⚪ done differently / partial · ❌ missing · 🚫 deliberately cut/deferred (with stated reason).

---

## A. Required (test-pinned) — all six pass

| Required behavior | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| `POST /loans` → 201 active loan, decrements copies | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `POST /loans/{id}/return` → 200 returned, restocks | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `GET /members/{id}/loans` → Page envelope + status filter | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Unknown book/member on checkout → 404 `not_found` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| No copies available → 409 `no_copies_available` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Member at `MAX_ACTIVE_LOANS` → 409 `loan_limit_exceeded` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Double-return → 409 `already_returned` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Pytest 21/21 + no new deps + convention cut** | **4/4** | **4/4** | **4/4** | **4/4** | **4/4** | **4/4** |

## B. Convention adherence — *the T2 discriminator*

| Established convention | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| `AppError` (never `HTTPException`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Logic in service (not router) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `LoanCreate` / `LoanRead` split | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `Page[LoanRead]` reused for list | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `LoanRepository` wired into `database.py` `reset_db()` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `config.MAX_ACTIVE_LOANS` (not hardcoded `3`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `ConflictError(code=...)` reused (no new subclass) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Member-existence check on `/members/{id}/loans`** | ✅ | **❌** | **❌** | ✅ | ✅ | ✅ |

**The only convention break, both with explicit design intent:** OpenSpec & Plan Mode skip the member-existence 404 on the list endpoint — OpenSpec's design.md surfaces it as "beyond what tests require"; Plan Mode's in-session plan accepts the same. Vibe (no plan) and the other three structured cells enforce it without being asked. Blind rater severity: OpenSpec **Major**, Plan Mode **Minor** (inter-rater disagreement on the same behavior).

## C. Design choices — small but visible variation

| Choice | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| `Loan.status` model typing | `str` | `str` | `str` (Literal at schema) | Enum (str-backed) | Literal | Enum (in models.py) |
| Status filter validation (invalid → 422) | ⚪ string | ⚪ string | ⚪ string (empty result) | ✅ Enum 422 | ✅ Literal 422 | ✅ Enum 422 |
| `borrowed_at` / `loaned_at` field | ✅ | ✅ | ⚪ (only `returned_at`) | ✅ | ✅ | ✅ |
| Member-loans route placement | `loans.py` | `loans.py` | `members.py /{id}/loans` | `loans.py` | `members.py /{id}/loans` | `members.py /{id}/loans` |
| Checkout precedence (limit vs copies) — documented | ⚪ undoc | ⚪ undoc | ✅ documented | ✅ documented | ✅ documented | ✅ documented |
| Concurrency / TOCTOU assumption documented | ❌ | ❌ | ✅ | ❌ | ⚪ implicit | ✅ (deferred-work) |
| README updated to mention loans | ❌ | ❌ | ❌ | ❌ | ❌† | ❌ |

† Pass-1 blind rater for AI-DLC claimed README update for loans (Doc 5). Pass-2 + direct file read showed the README is the unmodified neutral starter. AI-DLC produced loans docs only in `aidlc-docs/` (planning, not shipped). **No cell shipped a loans README update.**

## D. What was explicitly cut / deferred (planning artifacts only)

| Cut / deferred | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Persistence beyond in-memory | (implicit) | (implicit) | 🚫 reasoned | 🚫 reasoned | 🚫 reasoned | (implicit) |
| Due dates / overdue / fines | (implicit) | (implicit) | 🚫 reasoned | 🚫 reasoned | (n/a) | (implicit) |
| Authn / authz | (implicit) | (implicit) | (implicit) | 🚫 reasoned | (n/a) | (implicit) |
| Member-existence on list endpoint | — | ❌ (not surfaced) | 🚫 reasoned | (n/a, enforced) | (n/a, enforced) | (n/a, enforced) |
| Concurrency / locking | (implicit) | (implicit) | 🚫 reasoned | (implicit) | (implicit) | 🚫 `deferred-work.md` |
| Property-based testing | — | — | — | — | 🚫 (would add `hypothesis`) | — |

## E. Edge cases predicted in planning *before* code (foresight signal — dim 10's level-5 clause)

| Predicted-pre-code edge | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Checkout precedence (limit vs copies — order is unobservable from tests) | ❌ | ❌ | ✅ | ✅ | ⚪ partial | ✅ |
| `available_copies` drift if checkout/return asymmetric | ❌ | ❌ | ✅ | ⚪ partial | ❌ | ⚪ |
| Status-filter invalid-value behavior (silent empty vs 422) | ❌ | ❌ | ✅ | ✅ | ✅ | ✅ |
| In-memory live-reference semantics (mutate-in-place is safe) | ❌ | ⚪ partial | ❌ | ✅ | ❌ | ✅ |
| `loaned_at` / `borrowed_at` for a complete record | ⚪ shipped it | ✅ noted | ❌ omitted | ✅ | ✅ | ✅ |
| Member-existence on list endpoint (the actual ship gap) | ✅ (enforced) | ❌ | ❌ (cut) | ✅ | ✅ | ✅ |

## F. Planning-artifact volume (single-rater dims 10/11/12 source)

| Methodology | Planning files | ~Total lines | Read-app/-first evidence |
|---|:--:|:--:|---|
| Vibe | 0 | 0 | n/a (no artifact; code-comment articulation only) |
| Plan Mode | 1 (in-session plan, transcript-only) | ~70 lines | **Strong** — plan names AppError/Page/MAX_ACTIVE_LOANS by file and asserts "every layer mirrors existing Book/Member shape — no new patterns" |
| OpenSpec | 4 (proposal + design + tasks + spec) | ~160 | **Strong** — verbatim cites every existing pattern + filename; rejects "store loans on member" with named reason |
| Spec Kit | 8 (spec + plan + data-model + research + quickstart + tasks + contracts + checklist) | ~430 | **Strong** — quotes `services.py` docstring; correctly classifies REUSED vs MODIFIED vs NEW files |
| AI-DLC | 7 (incl. dedicated reverse-engineering summary) | ~457 | **Strong** — explicit reverse-engineering inception step names every convention before designing |
| BMAD | 3 (1 unified spec + diff + deferred-work — **quick-dev**) | ~379 | **Strong** — code-map cites each existing file by line; reuses `ConflictError(code=)` rather than new subclass |

**All four structured cells genuinely read `app/` first.** Zero phantom planning detected. The differentiator across structured cells is artifact *depth and shape* (BMAD's single tight spec at one extreme; AI-DLC's 7-doc lifecycle at the other) — not whether they grounded.

---

## Writeup-ready takeaways

1. **The shipped code converges.** All six pass the binary cut; blind code-only review compresses the six to **23–26/30 with Vibe tied at the top**. Methodology-blind, the no-planning control is indistinguishable from the heaviest planner — replicating the T1 finding on a brownfield task.

2. **Planning *did* read the codebase — uniformly.** All four structured cells (and even Plan Mode's transient plan) genuinely characterized the existing conventions before designing. **No phantom planning.** The T2 success-criteria failure mode (planning that doesn't reflect reading `app/`) didn't manifest.

3. **But grounding the spec ≠ a more faithful diff.** The one Major convention gap (member-existence skipped on the list) belongs to **OpenSpec + Plan Mode** — both of which *explicitly designed* that gap. Vibe (no plan) and the other three structured cells enforce it. **The plan documents the choice; it doesn't guarantee a better choice.**

4. **No cell shipped a loans README update — including AI-DLC.** Pass-1 blind rater for AI-DLC claimed it had one (Doc 5); pass-2 + direct file read showed otherwise (the README is the unmodified neutral starter). AI-DLC produced extensive loans docs but only in `aidlc-docs/` (planning, not shipped, doesn't count under v0.3's Documentation = shipped-docs-only anchor). Everyone's Doc averages 3–3.5 across the two blind passes.

5. **Adaptive routing replicates from T1.** BMAD self-routed to **quick-dev** (1 spec + 1 diff + 1 deferred-work note) on the same task where AI-DLC ran its **full Inception→Construction lifecycle** ($4.75, 5.09 M tokens) — opposite right-sizing instincts, both legitimate per their own rules.

*v0.1 — HEXAD COMPLETE. Compiled 2026-05-27 from the 6 blind REVIEW.md files + 4 structured-planning subagent reports + the Plan Mode transcript plan.*
