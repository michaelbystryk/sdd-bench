# T3-csv-openapi — Cross-cell scoring matrix

> **TL;DR.** All six clear the floor — **14/14 tests, 5/5 binary, no new deps, Pydantic v2 idiom clean, async POST, 413 enforced**. Quality /45: **OpenSpec 33.75 > Spec Kit 33 > BMAD 29.75 > AI-DLC 28.25 > Plan Mode 25.25 >> Vibe 18.5**. **The T1/T2 headline REVERSES on T3:** across two independent blind code-only panels, **Vibe is at the BOTTOM of the blind code band (17.5/30), tied with AI-DLC (17.25)** — first task where the no-methodology control loses on shipped code. **The silent Pydantic v2 trap discriminated** — Vibe sidestepped the framework entirely (no models, hand-rolled regex), blind raters consistently docked Code (3/3) and System (3/3). AI-DLC's full Inception+Construction lifecycle produced a 223-LOC single-file `main.py` — the heaviest planning the methodology supports + same god-file shape as Vibe. **Vibe Plan Mode TOPS blind code (21.25)** but its 4/15 planning subtotal drags total to mid-pack. **OpenSpec is the four-task cost-efficiency frontier** (T1+T2+T3+T4): 33.75 quality at $2.91, Q/$ 11.6, lowest structured cost. Spec Kit ties OpenSpec on quality at ~2× cost. BMAD self-routed to **quick-dev for the 3rd code task in a row** ($4.67) and tied OpenSpec on blind code (20.75 each). Cost spread 6.2× ($0.93 → $5.72). *Provisional, ≥2-rater blind on code dims (pass 1 + pass 2 BOTH from the start, 0/36 >1pt disagreements — strongest agreement so far); planning dims single-rater.*

Single source of truth for T3 cell scores (CSV import endpoint to OpenAPI spec — build POST + GET against a fully-specified contract; spec-bound greenfield, medium complexity / low ambiguity — *the workhorse*). One row per dimension/metric, one column per methodology. Each cell owns its `runs/.../observations.md`; this is the cross-cell snapshot.

**Status (2026-05-27):** ✅ **HEXAD COMPLETE — all 6 scored, ≥2-rater blind from the start.** Both blind passes spawned in parallel from the orchestrator session (12 independent subagents on the same anonymized bundles, different venvs to avoid collision). Planning dims (10/11/12) single-rater from build-dir artifacts. Rubric: [`harness/scoring-rubric.md`](../../harness/scoring-rubric.md) v0.3; T3 overlay: [`tasks/t3-csv-openapi/success-criteria.md`](../../tasks/t3-csv-openapi/success-criteria.md); blind-pass detail: [`blind-pass-audit.md`](blind-pass-audit.md); label key: [`blind-label-map.md`](blind-label-map.md).

> **Provisional, ≥2-rater blind on code dims.** Code-visible dims (1/3/4/7/8/9) carry **two independent blind ratings** (pass 1 + pass 2). **0 of 36 dim-pairs disagree by >1 pt** — strongest inter-rater agreement of the eval so far (T1 retrofit had several disagreements; T2 had one factual error). The protocol's rescore rule does not trigger. Per v0.3, code-visible dims sit in an **inter-rater band** and small score deltas are not separable half-point ranks. Planning dims (10/11/12) single-rater by necessity (artifacts = the methodology tell).

T3 applies **9 scored dimensions** (UI 5, UX 6 are `—` for a pure HTTP API; Security 8 **applies and is load-bearing** — file upload is a real attack surface, scoreable to 5 unlike T2's in-memory saturation at 3); Correctness scored separately as defects. Max numeric = **/45**.

---

## Quality axis — 9 dimensions × 6 methodologies

Bold = highest in row (ties bolded together). Code-visible dims (1/3/4/7/8/9) are **blind, averaged across pass 1 + pass 2**; planning dims (10/11/12) **single-rater**.

| # | Dimension | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|:--:|:--:|:--:|:--:|:--:|:--:|
| 1 | Functionality | 4 | 4 | 4 | 4 | 4 | 4 |
| 3 | Code quality | 3 | 4.25 | 4 | 4 | 3 | **4.25** |
| 4 | System design | 3 | **4.25** | 3.75 | 4 | 2.75 | 4 |
| 7 | Robustness | 3.5 | 3.5 | 3.5 | 3 | 3.5 | **3.75** |
| 8 | Security | 3 | 3.5 | **3.75** | 3.5 | 3 | 3.5 |
| 9 | Documentation | 1 | **1.75** | **1.75** | 1 | 1 | 1.25 |
| 10 | Spec articulation | 0 | 3 | **5** | **5** | 4 | 4 |
| 11 | Scope clarity | 1 | 1 | 4 | **4.5** | 4 | 3 |
| 12 | Assumption surfacing | 0 | 0 | 4 | **4** | 3 | 2 |
| | **Quality sum / 45** | **18.5** | **25.25** | **33.75** | **33** | **28.25** | **29.75** |

**Rank by quality:** OpenSpec 33.75 ≈ Spec Kit 33 > BMAD 29.75 > AI-DLC 28.25 > Plan Mode 25.25 >> Vibe 18.5.

Per v0.3 (cells within ~1.5 → cluster, not separable): **OpenSpec + Spec Kit (33–33.75)** are co-leaders; **BMAD + AI-DLC (28.25–29.75)** are a mid cluster; **Vibe Plan Mode (25.25)** is alone in its tier; **Vibe (18.5)** is alone at the bottom.

### Quality as a vector — Product vs Rigor

Product = Functionality + Robustness (/10 — **UI/UX `n/a` for an API**); Rigor = Code + System + Security + Documentation + Spec + Scope + Assumptions (/35).

| Sub-axis | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Product /10** | 7.5 | 7.5 | 7.5 | 7 | 7.5 | **7.75** |
| **Rigor /35** | 11 | 17.75 | **26.25** | 26 | 20.75 | 22 |

**Product is flat at 7–7.75** (everyone ships a working API that handles the test-pinned edges; no UI/UX surface). **Rigor spreads 2.4× (11 → 26.25)**. Inside Rigor, the planning cluster (Spec+Scope+Assum) spreads even more: Vibe **1/15** vs OpenSpec **13/15** and Spec Kit **13.5/15** = **13.5× spread on planning artifacts.** On the code-visible Rigor sub-cluster (Code+System+Security+Doc, /20), the spread is 10 → 13.25 (much tighter). **Planning rigor drives 80% of the cross-cell separation; shipped-code rigor drives the rest.**

### Blind code-only pass (the load-bearing result — ≥2-rater per v0.3)

Two independent blind panels on the same anonymized bundles (`app/` + `tests/` + `pyproject.toml` + `reference/`; planning artifacts + methodology dirs stripped). Pass 1 + pass 2 spawned in parallel as 12 fresh subagents from the orchestrator session, different venvs to avoid collision. **0 of 36 dim-pairs disagree by >1 pt** — strongest agreement of the eval so far. Code-visible subtotal (Func + Code + System + Robust + Security + Doc, /30):

| /30 | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Pass 1 | 17 | 21 | **21** | 19.5 | 17.5 | 20 |
| Pass 2 | 18 | **21.5** | 20.5 | 19.5 | 17 | **21.5** |
| **Average** | 17.5 | **21.25** | 20.75 | 19.5 | 17.25 | 20.75 |

**Reading.** Across **both** blind panels the code-visible cluster sits at **17.0–21.5/30 (range 4.5)** — wider than T2's 2.5-pt range. T3's larger surface (Pydantic v2 idiom, multi-file separation, content-type validation, streaming intent) gave the blind raters more to discriminate on.

**Vibe Plan Mode tops blind code (21.25)** — its structured plan led to multi-file impl with idiomatic Pydantic v2. **OpenSpec + BMAD tie for second on blind code (20.75 each).** **Spec Kit at 19.5.** **Vibe (17.5) and AI-DLC (17.25) are at the bottom — tied.**

**HEADLINE SHIFT FROM T1+T2:** the no-methodology control loses on shipped code for the first time across all three small-task hexads. Why: the silent v2-idiom trap discriminated under blind review (Vibe shipped zero Pydantic models — hand-rolled regex validation — and the multi-file structured cells all engaged Pydantic v2 properly). AI-DLC fell to the bottom for the opposite reason — used Pydantic, but shipped a 223-LOC single-file `main.py` (same god-file shape as Vibe). **Heavy planning, structurally identical to no-planning output.**

### Persona lenses (provisional)

Same architecture as T1/T2/T4 (Product% / Rigor% weighting; cost as efficiency divisor). Because **Product is near-flat** (UI/UX n/a), the lenses are driven by **Rigor + Cost**:

- **Indie (cost-weighted, ships it, Q/$ + product floor) → OpenSpec wins.** Vibe ($0.93, Q/$ 19.89) and Vibe Plan Mode ($1.41, Q/$ 17.91) have the best raw Q/$ ratios — but Vibe at 18.5/45 doesn't clear any reasonable quality bar (planning dims 1/15; god-file impl; framework sidestep). **OpenSpec at 33.75 quality / $2.91 / Q/$ 11.6 wins on quality-with-floor.** Replicates T1+T2 indie lens.
- **Enterprise (rigor-weighted, cost-blind) → Spec Kit + OpenSpec co-lead** (Rigor 26 + 26.25; quality 33 + 33.75). Spec Kit's defect-free record + richer planning artifact set (8 cohesive docs) edges enterprise rigor; OpenSpec is the closest cost-efficient alternative at ~½ the cost.
- **OpenSpec is the cost-efficiency frontier AGAIN — now corroborated across 4 tasks** (T1: best Q/$ + co-leader; T2: best Q/$ at $1.89; T3: best Q/$ at $2.91 among methodologies clearing 30 quality; T4: outright winner on persona composite). **Strongest single methodology-level finding of the eval.**

### Defect counts (correctness, scored separately)

| Severity × Source | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Critical | 0 | 0 | 0 | 0 | 0 | 0 |
| Major | 0 | 0 | 0 | 0 | 0 | 0 |
| Minor | 1 | 2 | 2 | 0 | 0 | 0 |

**0 critical / 0 major across all six. Spec Kit, AI-DLC, BMAD ship defect-free.**

Minor defects flagged by per-cell scoring agents (not blind raters' larger lists; only confirmed defects):
- **Vibe (1)**: country error message exposes Python list repr.
- **Plan Mode (2)**: GET handler sync (inconsistent with async POST); no shipped doc of in-memory storage lifecycle.
- **OpenSpec (2)**: no Content-Type validation; UserRow.country typed as plain str instead of Literal (cell's own tasks.md prescribed Literal).
- **Spec Kit, AI-DLC, BMAD**: zero defects.

**Blind raters surfaced additional latent items across all cells** (streaming illusion via `b"".join(chunks)` in 5/6; no Content-Type validation in 5/6; in-memory storage caveat undocumented in shipped code in 6/6; non-spec error codes `too_many_rows` in 4/6) — pattern findings kept in `blind-pass-audit.md`, not counted as per-cell defects.

### Binary outcomes (per [`success-criteria.md`](../../tasks/t3-csv-openapi/success-criteria.md))

| Binary outcome | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Tests pass (14) | 14/14 | 14/14 | 14/14 | 14/14 | 14/14 | 14/14 |
| No new dependencies | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Pydantic v2 idiom clean | ✓ vacuously† | ✓ | ✓ | ✓ | ✓ | ✓ |
| Async POST handler | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| File-size 413 enforced | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Pass count** | **5/5** | **5/5** | **5/5** | **5/5** | **5/5** | **5/5** |

† **Vibe's v2-idiom binary passes vacuously**: cell shipped zero Pydantic models. `pydantic[email]>=2.6` sits unused in deps; hand-rolled regex validation. The static grep for v1 surface passes by absence-of-Pydantic, not presence-of-v2. Success-criteria §4 anticipated this failure mode ("Custom validation instead of Pydantic"); design hole in the binary check, not a finding-invalidator (blind raters caught it on dims 3+4).

**14/14 tests + 5/5 binary — all six.** Binary doesn't discriminate (T3 design: floor-competence gate). The v2-trap discrimination lives in blind dims 3+4; the C-axis (retention) discrimination lives in planning dims 11+12.

### C-axis retention behavior (T3-specific discriminator)

The deliberate spec ambiguity (retention of past imports — spec silent on lifecycle). Per success-criteria §3:

| Behavior tier | Cells | Scope / Assum scores |
|---|---|---|
| **Row 1** (surfaced + asked PM + documented) | none | 4–5 / 4–5 |
| **Row 2** (surfaced as [ASSUMPTION] / ADR, picked default) | Spec Kit, OpenSpec, AI-DLC | 3.5–4 / 3.5–4 |
| **Row 3** (silent w/ caught-and-lost internal QA) | **BMAD** | 2.5–3 / 2–3 |
| **Row 4** (silent, no mention anywhere) | Vibe, Vibe Plan Mode | 1–2 / 0–1 |

**Zero cells forwarded a clarifying question to pm-ask.** Only entry in any pm-convo.md across the hexad is the operator's "j" preflight typo before Vibe ran. The C-axis discriminates via *artifact surfacing*, not PM dialogue: 3 cells (Spec Kit, OpenSpec, AI-DLC) named retention as an explicit decision/assumption in their planning artifacts; 1 cell (BMAD) had its own adversarial-review subagent catch the unbounded-dict issue mid-build but discarded the finding from shipped artifacts (**sharpest T3-specific finding** — internal QA caught what shipped code lost); 2 cells (Vibe, Vibe Plan Mode) silently picked module-scope dict with no mention.

---

## Cost axis

| Metric | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Implied cost** | **$0.93** | $1.41 | $2.91 | **$5.72** | $2.73 | $4.67 |
| API compute time | 3m36s | 4m10s | 8m46s | 15m9s | 7m29s | 12m1s |
| Wall-clock | 4m42s | 9m45s | 10m9s | 19m10s | 8m13s | 13m31s |
| Total tokens | 690 K | 1.28 M | 2.74 M | **6.24 M** | 2.73 M | 4.56 M |
| Code added/removed | 184/0 | 528/0 | 678/19 | 1277/162 | 461/0 | 545/24 |
| Shipped impl LOC | 184 | 346 | 370 | 380 | 223 | 358 |
| Impl files | 1 | 4 | 6 | ~7 | 1 | 4 |
| Operator interventions | 0 | 0 | 0 | 0† | 0 | 0 |
| PM questions forwarded | 0 | 0 | 0 | 0 | 0 | 0 |

† Spec Kit had one operator note (mistakenly read `/speckit-specify` `/status` as cell-end; continued pipeline in same session — not a methodology intervention).

**Cost spread: 6.2× ($0.93 → $5.72).** Tighter than T4 (13×), wider than T2 (4.7×). **Vibe Plan Mode adds $0.48 (+52%) over Vibe** for substantial quality lift (+6.75 points). **OpenSpec adds $1.50 (+106%) over Plan Mode** for the largest single-step quality jump (+8.5 points; ~5.7 pts/$). **Spec Kit adds $2.81 (+96%) over OpenSpec** for ~equal quality (−0.75 points). **The Spec Kit → OpenSpec arbitrage is steeper on T3 than on any prior task.**

### Derived ratios

| Ratio | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| Quality / 1K tokens | 26.8 | 19.7 | 12.3 | 5.3 | 10.3 | 6.5 |
| Quality / API hour | 308 | 364 | 231 | 131 | 227 | 149 |
| Defects / 1KLOC | 5.43 | 5.78 | 5.41 | 0.0 | 0.0 | 0.0 |
| Methodology overhead | n/a | ~0.11 | ~? | ~? | ~? | ~? |
| Cost / binary outcome | $0.186 | $0.282 | $0.582 | $1.144 | $0.546 | $0.934 |
| **Quality / dollar** | **19.89** | **17.91** | **11.60** | 5.77 | 10.35 | 6.37 |

**Quality / dollar headline:** Vibe wins raw Q/$ (19.89) but its 18.5 quality may not clear product floors. **OpenSpec (11.60) wins Q/$ among cells clearing 30 quality** — the practical Q/$ champion on T3. Spec Kit at 5.77 pays 2× OpenSpec's per-quality cost. **BMAD's quick-dev path (6.37) is mid-pack** — adaptive routing right-sized but Q/$ is below OpenSpec.

---

## Headline finding per cell

| Cell | Quality / $ / API / Binary | One-line verdict |
|---|---|---|
| **Vibe** | 18.5 / $0.93 / 3m36s / 5/5 | **Sidestepped the v2 trap by skipping Pydantic entirely.** Hand-rolled regex validation passes binary by absence; blind raters caught it (dims 3+4 = 3/3). Single-file god-file shape. Lowest quality in hexad. |
| **Vibe Plan Mode** | 25.25 / $1.41 / 4m10s / 5/5 | **Tops blind code (21.25/30)** with multi-file impl + idiomatic Pydantic v2 + typed CSVParseError. **Plan caught the v2/async/streaming traps but missed the C-axis (retention silent).** Planning dims 4/15 drag total. |
| **OpenSpec** | 33.75 / $2.91 / 8m46s / 5/5 | **Quality + cost-efficiency frontier.** ADR-tagged retention across 3+ planning artifacts; surfaced 3 of 4 silent discriminators; tight 6-module impl with typed WholeFileError. 4-task cost-efficiency replicates. |
| **Spec Kit** | 33 / $5.72 / 15m9s / 5/5 | **Highest planning rigor (13.5/15)** + **zero defects** + 8 cohesive planning artifacts (~24 explicit assumptions). Same quality tier as OpenSpec at ~2× cost. Skipped `/speckit-clarify` (self-declared spec complete). |
| **AI-DLC** | 28.25 / $2.73 / 7m29s / 5/5 | **Sharp cost-drop on T3** ($4.57→$4.75→$2.73; explicit spec collapsed construction iterations). **Bottom of blind code (17.25)** tied with Vibe — 223-LOC single-file `main.py` despite full Inception+Construction. Heaviest planning, no structural payoff. |
| **BMAD** | 29.75 / $4.67 / 12m1s / 5/5 | **Quick-dev for 3rd code task in a row** (T1+T2+T3 quick-dev; T4 vague full lifecycle). Multi-file impl (4 modules with named separation). **Internal adversarial-review subagent caught the unbounded-dict issue mid-build and lost the finding** — sharpest T3 process miss. |

---

## How to extend this matrix

When a new T3 run scores (e.g. run-002 of any methodology, or a 7th methodology added to the eval):

1. Add a row for the new run to `runs/t3-csv-openapi/<methodology>/run-NNN/observations.md`.
2. Re-run the blind-pass protocol (see `blind-pass-audit.md` for the staging step) — restage all 6 cells fresh (label map regenerated with new seed); run pass 1 + pass 2 in parallel; record reconciliation.
3. Update this matrix:
   - Replace the methodology's quality dim entries (1/3/4/7/8/9 from new blind avg; 10/11/12 from new single-rater)
   - Update cost axis row
   - Recompute derived ratios
   - Re-bold any rows where the new score tied/beat the prior best
   - Add a row to "Headline finding per cell" with the new verdict
4. Update `blind-pass-audit.md` with the new label map + dim-pair reconciliation.
5. If the new score reorders the persona-lens winners, update that section.
6. Commit + push.
