# T2-library-loans — Cross-cell scoring matrix

> **TL;DR.** All six clear the floor — **21/21 tests, no new deps, convention cut passed, 4/4 binary**. Quality /45: **Spec Kit 38 > OpenSpec 36.5 > BMAD 36 > AI-DLC 35 >> Plan Mode 31 > Vibe 28** — a **~35–38 structured cluster** trailed by Plan Mode and Vibe. (**Pass-2 reconciliation 2026-05-27** dropped AI-DLC from 36.5 → 35 after fact-correcting one Doc score; see [blind-pass-audit](blind-pass-audit.md).) As on T1, the spread is **almost entirely the planning dims**: across **two independent blind code-only panels** the six compress to a **23.5–26/30 band — and Vibe is the only cell at the top of *both* passes (26 + 26)**, with Spec Kit dropping to 24.5 in pass 2 (avg 25.25). Product (Func+Robust, /10; UI/UX n/a) is flat at 8–9; Rigor (/35) carries everything. Cost 4.7× ($1.01→$4.75). Persona lenses split again: **Vibe wins indie (Q/$ 27.7 AND most-consistent blind code leader); Spec Kit wins enterprise (top rigor).** OpenSpec the cost-efficiency all-rounder. *Provisional but ≥2-rater on code dims (pass 1 + pass 2); planning dims single-rater.*

Single source of truth for T2 cell scores (library API extension — add 3 loan endpoints to an existing FastAPI books/members service; brownfield-additive-small, low/low). One row per dimension/metric, one column per methodology. Each cell owns its `runs/.../observations.md`; this is the cross-cell snapshot.

**Status (2026-05-27):** ✅ **HEXAD COMPLETE — all 6 scored, ≥2-rater blind on code dims.** Pass 1: 6 fresh operator-run `claude` sessions on anonymized bundles. Pass 2: 6 fresh sonnet subagents on the same bundles, instructed to ignore pass-1 reviews — the v0.3 ≥2-rater requirement met. Planning dims (10/11/12) single-rater from build-dir artifacts. Rubric: [`harness/scoring-rubric.md`](../../harness/scoring-rubric.md) v0.3; T2 overlay: [`tasks/t2-library-loans/success-criteria.md`](../../tasks/t2-library-loans/success-criteria.md); blind-pass detail: [`blind-pass-audit.md`](blind-pass-audit.md); label key: [`blind-label-map.md`](blind-label-map.md).

> **Provisional, ≥2-rater blind on code dims.** Code-visible dims (1/3/4/7/8/9) carry **two independent blind ratings** (pass 1 + pass 2); 35 of 36 dim-pairs agree within 1 pt (= inter-rater noise per v0.3). **One >1 disagreement (AI-DLC Doc) was a factual error in pass 1** (claimed shipped-README content the bundle didn't contain) — corrected post-pass-2 against the actual file: 5 → 3.5, dropping AI-DLC's total 36.5 → 35. Planning dims (10/11/12) single-rater by necessity (artifacts = the methodology tell). Per v0.3, code-visible dims are a **cluster, not separable half-point ranks** within the inter-rater band.

T2 applies **9 scored dimensions** (UI 5, UX 6 are `—` for a pure HTTP API; Security 8 **applies**); Correctness scored separately as defects. Max numeric = **/45**.

---

## Quality axis — 9 dimensions × 6 methodologies

Bold = highest in row (ties bolded together). Code-visible dims (1/3/4/7/8/9) are **blind**; planning dims (10/11/12) **single-rater**.

| # | Dimension | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|:--:|:--:|:--:|:--:|:--:|:--:|
| 1 | Functionality | **5** | 4 | 4 | **5** | 4 | 4 |
| 3 | Code quality | **5** | 4 | 4 | **5** | 4 | **5** |
| 4 | System design | **5** | 4 | 4 | **5** | **5** | 4 |
| 7 | Robustness | 4 | 4 | 4 | 4 | 4 | 4 |
| 8 | Security | 3 | 3 | 3 | 3 | 3 | 3 |
| 9 | Documentation | 4 | 4 | 4 | 4 | 3.5† | 4 |
| 10 | Spec articulation | 1 | 4 | **5** | 4.5 | 4.5 | 4.5 |
| 11 | Scope clarity | 1 | 2.5 | **4** | **4** | 3.5 | **4** |
| 12 | Assumption surfacing | 0 | 1.5 | **4.5** | 3.5 | 3.5 | 3.5 |
| | **Quality sum / 45** | **28** | **31** | **36.5** | **38** | **35** | **36** |

† AI-DLC Doc corrected post-pass-2 from 5 → 3.5: pass 1 rater claimed the bundle's README documented loans (endpoints, error envelope) — but the bundle README is the unmodified neutral starter (verified). No cell shipped a loans README update.

**Rank by quality:** Spec Kit 38 > OpenSpec 36.5 > BMAD 36 > AI-DLC 35 >> Plan Mode 31 > Vibe 28. Per v0.3 (cells within ~1.5 → report the band): the four structured cells are a **~35–38 cluster**, not separable half-point ranks; Plan Mode (31) and Vibe (28) trail clearly.

### Quality as a vector — Product vs Rigor

Product = Functionality + Robustness (/10 — **UI/UX `n/a` for an API**); Rigor = Code + System + Security + Documentation + Spec + Scope + Assumptions (/35).

| Sub-axis | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Product /10** | **9** | 8 | 8 | **9** | 8 | 8 |
| **Rigor /35** | 19 | 23 | 28.5 | **29** | 27 | 28 |

**This is the T2 headline in one table — and it echoes T1.** Product is flat (8–9): everyone ships a correct, robust API (UI/UX don't apply, so there's almost no product-polish surface to separate on). Rigor spreads **1.5×** (19 → 29), and within Rigor the separation is **entirely the planning cluster** (Spec+Scope+Assum): Vibe scores **2/15** there, the structured cells **11.5–13.5/15**. **On a small, fully-specified brownfield extension, ceremony buys planning-artifact rigor — not better or more convention-faithful shipped code.**

### Blind code-only pass (the load-bearing result — ≥2-rater per v0.3)

Two independent blind panels on the same anonymized bundles (app/ + tests/ + pyproject + README; planning artifacts + methodology dirs stripped). Pass 1 = 6 fresh operator-run sessions; pass 2 = 6 fresh sonnet subagents on the same bundles instructed to ignore pass-1 reviews. 35 of 36 dim-pairs agree within 1 pt; the one >1 disagreement (AI-DLC Doc) was a pass-1 factual error, corrected. Code-visible subtotal (Func + Code + System + Robust + Security + Doc, /30):

| /30 | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Pass 1 (corrected) | **26** | 23 | 23 | **26** | 23.5† | 24 |
| Pass 2 | **26** | 25 | 24 | 24.5 | 25.5 | 24.5 |
| **Average** | **26.0** | 24.0 | 23.5 | 25.25 | 24.5 | 24.25 |

† AI-DLC pass-1 corrected from 25 (Doc 5 wrong about README contents) to 23.5 (Doc 3.5 matching pass 2 + the actual file).

**Reading.** Across **both** blind panels the code-visible cluster sits at **23.5–26/30 (range 2.5)** — within inter-rater noise per v0.3. **Vibe is the only cell at the top of both passes (26 + 26) → Vibe alone leads the averaged code band.** Spec Kit dropped 26→24.5 between passes; every other cell moved <1.5 between passes. Security saturates at 3–3.5 across all six (in-memory, no auth surface — realistic ceiling; saturation noted, genuine non-differentiation). **This replicates the central T1 finding on a brownfield task — *more strongly* with the second blind panel: the shipped code converges; the reproducible separation is the planning dims** (single-rater by necessity, where Vibe = 2/15 and the structured cells 11.5–13.5/15). Per v0.3 the two passes are not reconciled; both stand as separate measurements.

### Persona lenses (provisional)

Same architecture as T1/T4 (Product% / Rigor% weighting; cost as an efficiency divisor). Because **Product is near-flat** (UI/UX n/a), the lenses are driven by **Rigor + Cost**:

- **Indie (cost-weighted, ships it) → Vibe wins outright.** It is *simultaneously* the cheapest ($1.01, Q/$ 27.7) **and** a blind code co-leader (26/30) — a correct, idiomatic, convention-matching extension for a dollar. There is no product-quality bar an API floor that stops it (tests + convention cut pass).
- **Enterprise (rigor-weighted, cost-blind) → Spec Kit** (top Rigor 29, top quality 38), with **OpenSpec** the close all-rounder at ⅓ the cost.
- **OpenSpec is the cost-efficiency frontier again** — 36.5 quality at $1.89 (Q/$ 19.3), best rigor-per-dollar of the structured cells; corroborates T1 + T4.

### Defect counts (correctness, scored separately)

| Severity × Source | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Critical | 0 | 0 | 0 | 0 | 0 | 0 |
| Major | 0 | 0 | **1** | 0 | 0 | 0 |
| Minor | 5 | 5 | 4 | 4 | 5 | 4 |

**0 critical across all six.** OpenSpec's lone **Major**: `GET /members/{member_id}/loans` doesn't check the member exists → returns `200 {items:[]}` instead of the `404` the codebase uses elsewhere (breaks the id-not-found convention). **Plan Mode ships the identical behavior** but its blind rater classed it **Minor** ("defensible for a collection endpoint") — a genuine convention gap shared by exactly those two cells, with an inter-rater **severity** disagreement (Major vs Minor) on the same root cause. Recurring minors are mostly **inherited from the starter** (`httpx` under runtime not dev deps; `email` unvalidated; in-memory concurrency assumption undocumented) — flagged by raters but not methodology-differentiating. Defect density is noisy at ~150–250 loan-code LOC (the structured cells' larger `/status` line counts include planning docs); **not bolded**.

### Binary outcomes (per [`success-criteria.md`](../../tasks/t2-library-loans/success-criteria.md))

| Binary outcome | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Existing tests pass (11) | 11/11 | 11/11 | 11/11 | 11/11 | 11/11 | 11/11 |
| Loan tests pass (10) | 10/10 | 10/10 | 10/10 | 10/10 | 10/10 | 10/10 |
| No new dependencies | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Convention-adherence cut | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Pass count** | **4/4** | **4/4** | **4/4** | **4/4** | **4/4** | **4/4** |

**21/21 tests, no new deps, convention cut passed — all six.** The binary axis doesn't discriminate (T2 design: it gates floor competence; convention *depth* is the dim 3/4 + planning signal). All six added a `loans` router, wired `LoanRepository` into `reset_db()`, used the `LoanCreate`/`LoanRead` split, and reused `Page[LoanRead]`.

---

## Cost axis

| Metric | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Implied cost** | **$1.01** | $1.35 | $1.89 | $3.90 | **$4.75** | $4.33 |
| API compute time | 3m27s | 3m45s | 5m19s | 10m30s | 12m38s | 14m11s |
| Total tokens | 804 K | 1.06 M | 2.08 M | 3.69 M | **5.09 M** | 3.33 M (+1.0 M Haiku) |
| Code changes (/status) | 180/−12 | 266/−8 | 322/−10 | 959/−100 | 1054/−26 | 565/−25 |
| Routing / depth | 1 pass | 1 plan | propose→apply | full pipeline | full (Inception→Construction) | **quick-dev (self-routed)** |

(BMAD's Haiku is real subagent dispatch, $0.22 — counted in its $4.33; the others' Haiku is negligible title-gen. Spec Kit / AI-DLC `/status` "code changes" include planning `.md` they authored.)

### Derived ratios

| Ratio | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Quality / $** | **27.7** | 23.0 | 19.3 | 9.7 | 7.7 | 8.3 |
| Quality / 1K tok | **0.035** | 0.029 | 0.018 | 0.010 | 0.007 | 0.011 |
| Quality / API hr | 487 | **496** | 412 | 217 | 173 | 152 |
| Cost per binary (÷4) | **$0.25** | $0.34 | $0.47 | $0.98 | $1.19 | $1.08 |

**Cost spread 4.7×** ($1.01 → $4.75). Quality/$ tiers exactly as on T1: **Vibe (27.7) > Plan Mode (23.0) > OpenSpec (19.3) >> Spec Kit (9.7) ≈ BMAD (8.3) ≈ AI-DLC (7.7).** The lightweight trio gets most of the rigor at <$2; the heavy trio costs 2–4× for the top ~2 quality points. AI-DLC is the priciest again (5.09 M tokens — the rule-set re-read each turn).

---

## Headline finding per cell

| Cell | Quality | Cost | API time | Binary | One-line verdict |
|---|:--:|:--:|:--:|:--:|---|
| **Vibe** | 28/45 | $1.01 | 3m27s | 4/4 | **Only cell at the top of both blind passes (26 + 26)** — a correct, idiomatic, convention-matching extension for $1; near-zero planning dims (1/1/0). **Quality/$ champion (27.7) + indie-lens winner + most consistent blind code leader.** |
| **Plan Mode** | 31/45 | $1.35 | 3m45s | 4/4 | One conventions-grounded plan → +3 over Vibe (all planning dims) for +$0.34. Shares OpenSpec's unknown-member-not-404 gap. Highest quality-per-API-hour (496). |
| **OpenSpec** | 36.5/45 | $1.89 | 5m19s | 4/4 | Best spec (5/5: predicted the check-order ambiguity + copy-drift risk pre-code) + most assumptions (7). **Cost-efficiency frontier** (36.5 @ $1.89). One Major: list endpoint skips member-existence check. |
| **Spec Kit** | 38/45 | $3.90 | 10m30s | 4/4 | **T2 quality leader + enterprise-lens winner.** Blind code co-leader with Vibe in pass 1 (26); pass 2 dropped to 24.5 (avg 25.25). 8 planning artifacts (~430 lines); top Rigor (29). The ceremony-tax exemplar — averaged blind code on par with the $1 Vibe run. |
| **AI-DLC** | 35/45 | $4.75 | 12m38s | 4/4 | Dedicated reverse-engineering step genuinely characterized app/ before designing (strongest read-app/-first signal of the eval). Originally tied OpenSpec at 36.5 — corrected to **35** after pass-2 caught a factual error: the bundle's README does NOT mention loans (pass-1 Doc 5 → 3.5). Drops to the structured cluster floor at the priciest cost (**2.5× OpenSpec** for −1.5 quality). |
| **BMAD** | 36/45 | $4.33 | 14m11s | 4/4 | **Self-routed to quick-dev** (neutral kickoff) — one tight spec + diff + deferred-work log, no full lifecycle. Right-sized vs its $75.85 T4 blowout; lands in the structured cluster at high cost (Q/$ 8.3). |

---

## Cross-cell findings (HEXAD COMPLETE — all 6 on T2)

1. **Every methodology clears the floor; the binary axis doesn't discriminate.** All six: 21/21 tests, no new deps, convention cut passed. By design for the brownfield-small entry point.

2. **The quality spread (28→38) is *almost entirely* the planning dims — T1 replicates on brownfield.** Product (Func+Robust, /10) is flat at 8–9; Rigor's spread is dominated by Spec+Scope+Assum (Vibe 2/15 vs structured 11.5–13.5/15). **On small, fully-specified work, methodology buys documented intent, not a better or more convention-faithful program.**

3. **Blind, the control is indistinguishable — and across two passes it's *uniquely* at the top.** Code-only blind review (≥2 raters) compresses the six to **23.5–26/30**. **Vibe scored 26 in *both* passes** — only cell with no pass-to-pass drop at the top; Spec Kit scored 26/24.5 (avg 25.25); the others all moved <1.5. The no-planning control's loan code reads as clean, idiomatic, and convention-matching as any structured cell's. The structured cells' advantage lives in the artifacts, not the code.

4. **All four structured cells genuinely read `app/` first — no phantom planning.** Every structured artifact set names the existing conventions verbatim (`AppError`/`ConflictError(code=)`, `Page`/`paginate`, `*Create`/`*Read`, `MAX_ACTIVE_LOANS=3` reused from config) before designing. The T2 spec-articulation discriminator (did it read the codebase?) came back **strong for all four** — the methodologies' "read the codebase" step works. The differentiator is artifact *depth*, not whether they grounded.

5. **The convention-grounding finding cuts both ways.** Structured planning *correctly characterized* the conventions (dim 10 high) — but it did **not** produce more convention-faithful shipped code than Vibe: blind, Vibe's code matches them, and the one Major convention gap (member-existence on the list endpoint) belongs to **OpenSpec + Plan Mode**, not the no-planning control. **Grounding the spec ≠ a more faithful diff.**

6. **Persona lenses split (as on T1).** Indie (cost) → **Vibe** (Q/$ 27.7, blind code co-leader, $1). Enterprise (rigor, cost-blind) → **Spec Kit** (38, top rigor); **OpenSpec** the all-rounder (36.5 @ $1.89). The cost-sensitive and rigor-maximalist buyers want opposite cells.

7. **Adaptive routing, opposite instincts — replicated.** Given a neutral kickoff, **BMAD self-routed to quick-dev** (one spec + diff, no PRD/architecture/stories) while **AI-DLC ran its full Inception→Construction lifecycle** on the same 3-endpoint task — at $4.75, the priciest cell. Same split as T1.

**Bottom line:** T2 carries the T1 ceremony-tax finding into brownfield. The methodologies *do* read and respect the existing conventions (no phantom planning) — but on a small extension that grounding shows up as planning-artifact rigor, not as shipped code a blind reviewer can distinguish from the $1 control. Structure buys documented, convention-aware intent; it doesn't buy a better diff here.

---

## How to extend this matrix

Per-cell scoring → this matrix is a post-scoring compile (operator-runbook § Scoring). Code dims from the blind pass ([`blind-pass-audit.md`](blind-pass-audit.md)); planning dims single-rater from `runs/.../artifacts/planning/`. Re-bold rows where a newly-scored cell ties/beats the prior best; keep defect/binary/cost rows in sync.

*v0.2 — HEXAD COMPLETE (all 6 on T2). Code dims **blind ≥2-rater** (pass 1 + pass 2, both on anonymized bundles); one factual error in pass 1 (AI-DLC Doc) corrected. Planning dims single-rater. Compiled 2026-05-27.*
