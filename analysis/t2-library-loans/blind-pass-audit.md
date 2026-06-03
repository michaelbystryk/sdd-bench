# T2 — Blind code-only pass (6 dimensions, ≥2 raters)

**Date:** 2026-05-27. **Protocol:** scoring-rubric v0.3 (blind-agents-primary). T2 is the first task scored **blind from the start** with **both** the primary blind pass AND a second blind panel (≥2 raters per bundle, the protocol's full requirement).

## Method

- Staged 6 anonymized **code-only** bundles at `/tmp/t2-blind/output-{A..F}`: each contained `app/` + `tests/` + `pyproject.toml` + `README.md` only. **All methodology tells stripped** — no `openspec/`, `specs/`, `.specify/`, `_bmad-output/`, `aidlc-docs/`, `CLAUDE.md`, `.aidlc-rule-details/`, `library_api.egg-info`, `uv.lock`, no planning artifacts. Re-scanned clean of identifying strings (FR-N, EARS, tool names, "story", "spec.md", etc.).
- Randomized label map (compile-time key, [`blind-label-map.md`](blind-label-map.md), revealed only here): **A = OpenSpec · B = BMAD · C = Vibe · D = AI-DLC · E = Spec Kit · F = Vibe Plan Mode.**
- 6 independent fresh reviewer agents (separate Claude Code sessions launched by the operator, cwd = each bundle dir → no sdd-bench project context loaded from `/tmp`). Each ran `uv venv && pytest`, read the code, scored on the rubric's absolute anchors.
- **Scope: the 6 code-visible dimensions** — Functionality (1), Code quality (3), System design (4), Robustness (7), Security (8), Documentation (9 — *shipped* docs only). Spec articulation / Scope / Assumptions cannot be blind-rated (they live in the planning artifacts = the methodology tell) → single-rater, disclosed; see `scoring-matrix.md`.
- **Second blind panel run 2026-05-27** (≥2-rater requirement met): 6 fresh sonnet subagents on the same anonymized bundles, written to `REVIEW-2.md`; raters instructed to ignore any existing `REVIEW.md` (so they could not anchor to pass 1). Used to confirm pass-1 dims and surface any genuine same-condition disagreements (>1 pt → rescore per v0.3).

## Pass 1 — blind scores per dim (the 6 code-visible dims)

| Methodology | Func | Code | System | Robust | Security | Docs | **Code-visible /30** |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| **Vibe** (C) | 5 | 5 | 5 | 4 | 3 | 4 | **26** |
| **Spec Kit** (E) | 5 | 5 | 5 | 4 | 3 | 4 | **26** |
| AI-DLC (D) | 4 | 4 | 5 | 4 | 3 | ~~5~~ **3.5** | ~~25~~ **23.5** |
| BMAD (B) | 4 | 5 | 4 | 4 | 3 | 4 | 24 |
| OpenSpec (A) | 4 | 4 | 4 | 4 | 3 | 4 | 23 |
| Plan Mode (F) | 4 | 4 | 4 | 4 | 3 | 4 | 23 |

**AI-DLC Doc strikethrough = factual correction from pass 2** (see "Pass 2 reconciliation" below). Pass-1 rater claimed "only cell with a shipped README update for the loans feature — endpoint list, error envelope, business rules" — but the bundle's README is the unmodified neutral starter (no loans content). Verified by reading `/tmp/t2-blind/output-D/README.md` directly. Doc 5 → **3.5**; AI-DLC subtotal 25 → **23.5**; total quality 36.5 → **35**.

| Binary | all six |
|---|---|
| pytest | **21/21** (11 books+members existing, 10 loans) |
| new runtime deps | **none** added to `pyproject.toml` |

## Pass 2 — second blind panel + reconciliation

Six fresh sonnet subagents, same anonymized bundles, instructed to ignore any existing `REVIEW.md` and write `REVIEW-2.md`. Per-dim comparison (P1 → P2; ! = >1-pt disagreement triggering protocol review):

| Cell | Func | Code | Sys | Rob | Sec | Doc | P1 /30 | P2 /30 | Avg |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| Vibe (C) | 5→5 | 5→5 | 5→5 | 4→4 | 3→3.5 | 4→3.5 | 26 | 26.0 | **26.0** |
| Spec Kit (E) | 5→4.5 | 5→5 | 5→4.5 | 4→4 | 3→3 | 4→3.5 | 26 | 24.5 | **25.25** |
| AI-DLC (D) | 4→4.5 | 4→5 | 5→5 | 4→4 | 3→3.5 | **5→3.5 !** | 25→23.5 | 25.5 | **24.5** |
| BMAD (B) | 4→4.5 | 5→5 | 4→5 | 4→4 | 3→3 | 4→3 | 24 | 24.5 | **24.25** |
| Plan Mode (F) | 4→5 | 4→5 | 4→5 | 4→4 | 3→3 | 4→3 | 23 | 25.0 | **24.0** |
| OpenSpec (A) | 4→4.5 | 4→5 | 4→4.5 | 4→3.5 | 3→3.5 | 4→3 | 23 | 24.0 | **23.5** |

**Reconciliation (v0.3 rule: same-condition >1 → rescore together with anchor discussion).**

**One genuine >1 disagreement, all 36 dim-pairs:** AI-DLC Documentation. Pass 1 = 5/5 ("only cell with a shipped README update — endpoint list, error envelope, business rules"); Pass 2 = 3.5/5 ("README does not document the API surface; minimal"). I read `/tmp/t2-blind/output-D/README.md` directly to adjudicate: **the README is the unmodified neutral starter** (title + run + test + plain layout, no loans content, no endpoint list, no error-envelope mention). **Pass 1 was a factual error** — the planning artifacts under `aidlc-docs/` (which contained loans documentation) were correctly stripped during bundle staging, so pass 1's claim cannot be sourced from the bundle the rater actually saw. **Corrected to Doc 3.5.** This is a factual fix, not an anchor re-interpretation — the rescoring rule doesn't strictly apply, but the correction does.

**The other 35 dim-pairs all agree within 1 point** = within inter-rater noise per v0.3. Pass 2 was systematically slightly harder on Doc (3 vs pass-1's 4 across A/B/F) — interpretable as anchor 3 vs anchor 4 boundary (does "neutral starter README + good docstrings" meet anchor-4 "new contributor onboarding flow in 10 min"? Pass 1 = yes; pass 2 = no). 1-point inter-rater diff = expected per v0.3, kept separate.

**Pass 2 surfaced new Major defects pass 1 classed differently:**
- **TOCTOU on `checkout` (vibe, ai-dlc, plan-mode, spec-kit)**: pass 1 classed Minor / undocumented; pass 2 classed **Major** ("the in-memory store has no locking — two concurrent checkouts of the last copy can both pass the guard"). Same observation, different severity. Per v0.3 keep-separate: pass 1's classification stands as committed, pass 2's flagged in the audit.
- **`loaned_at` missing on `Loan` (spec-kit)**: pass 2 classed Major ("a lending system that records `returned_at` but not `loaned_at` is incomplete"); pass 1 didn't flag.
- **`LoanCreate` lacks `ge=1` on `book_id`/`member_id` (multiple cells)**: pass 2 flagged across bundles; pass 1 didn't.

These severity divergences mirror T1's "first-pass and blind not reconciled — both stand as separate measurements" rule. Defect counts in the scoring matrix retain pass 1's classification (single-rater committed history); pass 2's additional findings are recorded here.

## Findings

1. **Across both passes, the code-visible dims sit in a 23.5–26/30 band (range 2.5).** Per-cell averages: Vibe 26 ≥ Spec Kit 25.25 > AI-DLC 24.5 ≈ BMAD 24.25 ≈ Plan Mode 24 > OpenSpec 23.5. The structured spread is **within inter-rater noise** (most pairs ≤1 pt apart). The reproducible separation is the *planning* dims (single-rater, where Vibe = 2/15 and structured cells = 11.5–13.5/15).

2. **Vibe is consistently at the top of the blind code band (26 + 26 across both passes) — only cell with no pass-to-pass variance at the top.** Pass 1 had Vibe tied with Spec Kit at 26; pass 2 dropped Spec Kit to 24.5 and held Vibe at 26 → on the average Vibe is *alone* at the top. The T1 headline reinforces on a brownfield task **more strongly with two independent blind panels**: methodology-blind, you cannot distinguish the no-planning control from the heaviest planner — and across two passes, the control's code is the most *consistently* clean.

3. **Security saturates at 3–3.5 across all six.** Realistic ceiling for an in-memory service with no auth surface (per T2 success-criteria); a 5 requires documenting the trust boundary, which no cell did. **Genuine non-differentiation**, flagged per the v0.2 saturation guard.

4. **Convention adherence (dims 3+4) does NOT track planning rigor.** Vibe (no plan) and Spec Kit (8 planning docs, ~430 lines) both score 5/5/5 on Functionality/Code/System in pass 1; pass 2 puts Vibe at 5/5/5 again but Spec Kit at 4.5/5/4.5. AI-DLC (the heaviest planner, with a dedicated reverse-engineering step) averages 4.25/4.5/5. BMAD averages 4.25/5/4.5. The Code+System distribution is essentially random with respect to ceremony invested — **grounding the spec didn't produce a more convention-faithful diff than no spec at all**.

5. **The 1 Major defect lives in OpenSpec, not Vibe.** OpenSpec ships `GET /members/{member_id}/loans` without checking the member exists → returns `200 {items:[]}` instead of `404` (breaks the id-not-found convention the rest of the codebase uses). **Plan Mode ships the identical behavior.** Both pass-1 raters and pass-2 raters surfaced it; the classification varied (pass 1: openspec Major, planmode Minor; pass 2: openspec Major, planmode Minor — same severity split). Both cells *explicitly designed* this gap (OpenSpec's design.md surfaces it as "beyond what tests require"); a planning-level convention choice, not a code-quality lapse. Pass 2 ALSO flagged it as a Major against OpenSpec independently — a same-condition cross-rater **confirmation** of the only Major across two blind panels.

6. **No cell shipped a loans README update — pass 1's "AI-DLC only cell with README update" claim was a factual error, corrected post-pass-2.** Direct read of `/tmp/t2-blind/output-D/README.md`: it is the unmodified neutral starter (title + run + test + plain layout). AI-DLC produced its loans documentation in the planning artifacts (`aidlc-docs/`), which were correctly stripped from the bundle. AI-DLC Doc 5 → **3.5**; cell subtotal 25 → 23.5; total quality 36.5 → **35**. **All six cells' Documentation rests on docstrings + the neutral README**, varying 3 to 3.5 across the two passes — not 5.

7. **Pass 2 raised more Major-class concerns than pass 1**, especially:
   - **TOCTOU on `checkout`** (concurrent decrement of `available_copies`): pass 2 classed Major across vibe / ai-dlc / spec-kit / plan-mode; pass 1 classed Minor / undocumented-assumption. Same observation, different severity call. *Kept separate per v0.3 — pass 1's classification stands as committed history; pass 2's flagged here.*
   - **`loaned_at` missing on `Loan`** (spec-kit): pass 2 classed Major; pass 1 didn't surface.
   - **`LoanCreate` missing `ge=1` on ID fields**: pass 2 flagged across multiple bundles; pass 1 didn't.

8. **Common minors are mostly inherited from the starter, not introduced by the methodologies.** `httpx` declared as a runtime (not dev) dep, `MemberCreate.email` validated only as a non-empty string, the in-memory concurrency assumption undocumented — flagged by both passes but baseline issues.

9. **`pytest` 21/21 + zero new deps independently confirmed on every bundle in BOTH passes.** Binary outcomes objective and uniform across 12 independent runs.

## Implication

T2's code-visible scores are now backed by **two independent blind passes** (the v0.3 protocol's ≥2-rater requirement met). The **one >1 disagreement** (AI-DLC Doc) was a factual error in pass 1, corrected post-hoc against the actual README content; the other 35 dim-pairs all agreed within 1 pt = inter-rater noise. Pass 1's per-dim scores stand as committed history; pass 2 confirms within tolerance and surfaces stricter severity calls on the same observations (kept separate, not reconciled).

**The headline is unchanged from T1 and reinforced — more strongly on T2 with the second blind panel:** on small, fully-specified work — greenfield CLI (T1) and brownfield API extension (T2) alike — methodology buys planning-artifact rigor, not a better or more convention-faithful diff. Across two blind panels, the no-planning control is **consistently at the top of the blind code band** (26 + 26). The cost-sensitive and rigor-maximalist buyers want opposite cells.

*Pass 1 (operator-run, 6 fresh `claude` sessions) + pass 2 (6 fresh sonnet subagents on the same anonymized bundles, instructed to ignore pass-1 reviews) both run 2026-05-27. Reviews preserved at `/tmp/t2-blind/output-{A..F}/{REVIEW,REVIEW-2}.md`. Reproducible: re-stage from `~/dev/sdd-bench-t2-builds/<meth>/` (app/ + tests/ + pyproject + README only, strip planning dirs), apply the label map, re-review with the locked prompt.*
