# T2 — AI-DLC (awslabs rules, on Claude Code) / run-001 observations

> **Scoring protocol (rubric v0.3): blind-agents-primary, ≥2-rater.** Code-visible dims from **two** blind raters on `output-D` (pass 1 + pass 2); planning dims single-rater from 7 AI-DLC artifacts (~457 lines incl. dedicated reverse-engineering-summary). UI/UX = n/a. PROVISIONAL. **Doc score corrected post-pass-2 from 5 → 3.5: pass 1 was factually wrong about the README contents** (see § Documentation below).

## Binary outcomes
existing tests **11/11** · loan tests **10/10** · no new deps · convention cut pass → **4/4**

## Quality axis (rubric 0–5; UI/UX n/a)

| # | Dimension | Score | Rater | Rationale |
|---|---|:--:|:--:|---|
| 1 | Functionality | 4 | blind | All endpoints + errors; held below 5 — no surfacing of an unpinned edge beyond what others did. |
| 3 | Code quality | 4 | blind | Idiomatic, consistent; checkout duplicates existence-and-404 logic already in Book/MemberService — mild DRY. |
| 4 | System design | **5** | blind | Member-loans route placed in members.py `/{member_id}/loans` — deliberate sub-resource choice; clean layering, reuses every shared piece. |
| 7 | Robustness | 4 | blind | Pinned errors handled; TOCTOU undoc; 422 errors bypass envelope (baseline). |
| 8 | Security | 3 | blind | Saturation. |
| 9 | Documentation | 3.5† | blind | † Pass-1 rater scored 5 ("only cell with a shipped README update — endpoint list, error envelope, business rules") — but **the bundle's README is the unmodified neutral starter** (no loans content; verified by direct read of `/tmp/t2-blind/output-D/README.md`). AI-DLC's loans documentation lives only in `aidlc-docs/`, which is *planning*, not shipped docs (v0.3 anchor: shipped docs only). Pass-2 rater independently scored 3.5; corrected to 3.5. |
| 10 | Spec articulation | 4.5 | single | Checkout rule ordering noted as test-driven; status lifecycle (incl. terminal/double-return) charted pre-code; status filter behavior predicted. Gap: alternatives not formally documented. |
| 11 | Scope clarity | 3.5 | single | In + out listed with brief rationale (User-Stories/App-Design/NFR/Infra/PBT cuts each explained); declared once not revisited → caps at 3.5. |
| 12 | Assumption surfacing | 3.5 | single | 6 named choices with most consequences stated; embedded in prose rather than collected as a section; not categorized + not file-mapped. |

**Quality sum: 35/45**  ·  Vector → Product /10: **8** · Rigor /35: **27** *(post-pass-2 correction: Doc 5→3.5 → sum 36.5→35)*

## Defects (from blind review)
- **Critical:** 0
- **Major:** 0
- **Minor (5):**
  1. 422 validation errors bypass the custom `{"error":{...}}` envelope → API ships two error shapes (baseline + loans).
  2. `MemberCreate.email` typed `str` min-length-1 only (baseline).
  3. `httpx` runtime-dep nit (baseline).
  4. TOCTOU on `available_copies` undocumented.
  5. Checkout duplicates Book/Member existence-and-404 logic — mild DRY (services hold repos directly; documented trade-off).

## Cost (see token-log)
$**4.75** · **12m 38s** API · 5.09 M tokens · **Q/$ 7.7** · cost/binary **$1.19** · routing: full Inception → Construction lifecycle (reverse-engineering + requirements + functional-design + execution-plan + build-and-test). Cache-read 4.9 M dominates (rule-set re-read each turn — same pattern as T4-AI-DLC).

## Depth / routing
7 artifacts, ~457 lines. inception/{requirements, reverse-engineering-summary, plans/execution-plan} + construction/{loans/functional-design, loans/code/code-summary, build-and-test/*} + aidlc-state + audit. **Dedicated reverse-engineering inception step** — the cleanest read-app/-first signal in the eval.

## Headline
**35/45 · $4.75 / 12m 38s API · 4/4 binary.** Reverse-engineering step genuinely characterized `app/` before designing (strongest read-app/-first signal of the eval). **Pass-2 reconciliation dropped 36.5 → 35** after fact-correcting pass-1's incorrect Doc 5 (the README does not document loans — only `aidlc-docs/` does, and that's planning). Lands at the structured-cluster floor at the priciest cost: **2.5× OpenSpec for −1.5 quality.**

## What it did well / where it lost points
**Did well:** the explicit reverse-engineering inception step is the cleanest "read the codebase first" signal in T2 (and the eval to date); System design 5 (deliberate sub-resource route placement in members.py); 6 named assumptions with consequences.
**Lost points:** **did NOT ship a loans README update** despite producing extensive loans documentation in `aidlc-docs/` — the planning-vs-shipped-docs gap is the AI-DLC pattern (matches T1's same gap with the planning artifacts); assumptions not categorized/file-mapped (caps dim 12 at 3.5); scope declared once not revisited (caps dim 11 at 3.5); 2.5× OpenSpec's cost for −1.5 quality (5.09 M tokens — the rule-set re-read tax).
