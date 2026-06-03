# T4-fitness-app — Cross-cell scoring matrix

> **TL;DR.** All six ship the brief (7/7 binary). Four structured methods cluster in the high-40s/55 (**provisional 49.5 each — the exact tie is single-rater scoring noise**, see [tie-audit](rigor-pass-tie-audit.md)); cost spans **13×** ($5.84→$75.85). Per the persona composite, **OpenSpec wins both lenses** (indie + enterprise); AI-DLC its quality-twin at ~2.7× cost; BMAD the expensive rigor corner; Plan Mode the value runner-up; Vibe the prototype floor (29/55). Report the (Product, Rigor, Cost) vector — never a bare tie.

Single source of truth for T4 cell scores. One row per dimension / metric, one column per methodology. Each cell still owns its own `runs/.../observations.md` with rationale + defect detail; this file is the cross-cell snapshot.

**Status (as of 2026-05-27):** ✅ **HEXAD COMPLETE — all 6 methodologies scored** on T4 (Vibe, Vibe Plan Mode, OpenSpec, Spec Kit, AI-DLC, BMAD). AI-DLC (awslabs) runs on Claude Code.

**Companion:** [`feature-matrix.md`](feature-matrix.md) (per-feature parity audit — what each methodology built/cut/missed, not scores).

**Rubric:** [`harness/scoring-rubric.md`](../../harness/scoring-rubric.md) — scores produced under v0.1.2 (0.5 increments); **reporting now follows v0.2** (vector + provisional labels + anti-tie discipline, added 2026-05-27 after the tie audit — no anchor text changed, so no numeric re-score forced). Updated after each cell per [`harness/operator-runbook.md`](../../harness/operator-runbook.md) § Scoring step 12-15.

---

## Quality axis — 12 dimensions × 6 methodologies

Scores per `harness/scoring-rubric.md` v0.1.2 (0.5 increments). Bold = highest in row (ties bolded together).

> ⚠️ **PROVISIONAL (single-rater, unblinded).** All cells were scored by one reviewer, same-day, with methodology labels visible — the rubric's blinding + double-rating protocol was not run, so these carry an unmeasured **±~1 per cell**. A de-biased re-anchoring (see [`rigor-pass-tie-audit.md`](rigor-pass-tie-audit.md)) shows the **4-way 49.5 "tie" is false precision** — it dissolves into a ~48–50 cluster once contested half-points are re-read against absolute anchors (e.g., AI-DLC's Code 4.5 was a reviewer-coverage dock, not an observed weakness). **Always report quality as the (Product, Rigor) vector + cost composite below — never as a bare "4-way tie."** Totals retained as committed history, labeled provisional.

| # | Dimension | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|---|---|---|---|---|---|
| 1 | Functionality | 3 | 3.5 | **4.5** | **4.5** | **4.5** | **4.5** |
| 2 | Correctness (defects) | (see defect block) | (see defect block) | (see defect block) | (see defect block) | (see defect block) | (see defect block) |
| 3 | Code quality | 4 | 4.5 | **5** | **5** | 4.5 | **5** |
| 4 | System design | 3.5 | 4.5 | **5** | **5** | **5** | **5** |
| 5 | UI design | **4.5** | **5** | 4.5 | 4.5 | 4.5 | 4 |
| 6 | UX | 3.5 | **4.5** | 4 | 4 | 4 | 3.5 |
| 7 | Robustness | 4 | **4.5** | **4.5** | 4 | **4.5** | 3.5 |
| 8 | Security | 3 | 3 | 3 | 3 | 3 | **4** |
| 9 | Documentation | 2.5 | 3.5 | 4.5 | **5** | **5** | **5** |
| 10 | Spec articulation | 0 | 4.5 | **5** | **5** | **5** | **5** |
| 11 | Scope clarity | 1 | 3.5 | **5** | **5** | **5** | **5** |
| 12 | Assumption surfacing | 0 | 3 | 4.5 | 4.5 | 4.5 | **5** |
| | **Quality sum / 55** | **29** | **43.5** | **49.5** | **49.5** | **49.5** | **49.5** |

### Quality as a vector — Product polish vs Engineering rigor

The equal-weight sum hides the real structure: anti-correlated profiles collapse to the same scalar. Split the 11 scored dims into **Product polish** (Functionality + UI + UX + Robustness, /20) and **Engineering rigor** (Code + System + Security + Docs + Spec + Scope + Assumptions, /35):

| Sub-axis | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|:--:|:--:|:--:|:--:|:--:|:--:|
| **Product polish /20** | 15.0 (75%) | 17.5 (87.5%) | **17.5 (87.5%)** | 17.0 (85%) | **17.5 (87.5%)** | 15.5 (77.5%) |
| **Engineering rigor /35** | 14.0 (40%) | 26.5 (75.7%) | 32.0 (91.4%) | 32.5 (92.9%) | 32.0 (91.4%) | **34.0 (97.1%)** |

The four "tied" cells differ in *shape*: **BMAD is lowest on product polish, highest on rigor; OpenSpec/AI-DLC are the inverse; Spec Kit sits between.** That's the finding the 49.5 tie erased.

### Final composite — persona lenses (headline + vector)

Per the locked scoring architecture: persona-weighted quality (0–100) = wP·Product% + wR·Rigor%; cost enters as an efficiency ratio (÷ $) for the cost-sensitive lens; time folded into cost. Two primary lenses:

- **Indie-dev** (ships a product, pays the bill): **0.70 Product / 0.30 Rigor**; rank by **Q/$**; product bar ~80/100 weighted (below it isn't shippable to users — for *this* buyer).
- **Enterprise** (maintains for years, cost ≈ rounding error): **0.40 Product / 0.60 Rigor**; rank by **weighted quality**; no cost bar.

| Cell         | Indie WQ | **Indie eff. (Q/$)** | Enterprise WQ | **Ent. rank** | Vector (P% · R% · $) |
| ------------ | :------: | :------------------: | :-----------: | :-----------: | -------------------- |
| **OpenSpec** |   88.7   |    **12.4 · #1**     |     89.9      |    **#1**     | 87.5 · 91.4 · $7.16  |
| Plan Mode    |   84.0   |      10.8 · #2       |     80.4      |      #5       | 87.5 · 75.7 · $7.78  |
| Spec Kit     |   87.4   |       6.6 · #3       |     89.7      |      #3       | 85.0 · 92.9 · $13.21 |
| AI-DLC       |   88.7   |       4.6 · #4       |     89.9      |      #2       | 87.5 · 91.4 · $19.15 |
| BMAD         |   83.4   |       1.1 · #5       |     89.3      |      #4       | 77.5 · 97.1 · $75.85 |
| Vibe         |   64.5   |  below product bar†  |     54.0      |      #6       | 75.0 · 40.0 · $5.84  |

**OpenSpec wins both lenses.** AI-DLC is its quality-twin at 2.7× cost (premium buys the property-based-testing robustness edge); Spec Kit is the safe middle; **BMAD wins only if rigor weight exceeds ~0.75 *and* cost is ignored** (regulated / safety-critical niche); Plan Mode is the indie value runner-up. Full derivation in [`rigor-pass-tie-audit.md`](rigor-pass-tie-audit.md).

† Vibe is below the *indie* product bar (WQ 64.5 < ~80): an indie shipping to users wants more than a throwaway, and the bar stops its cheapness (raw Q/$ 11.0) from masquerading as product quality. **The bar is per-lens, not a global disqualification** (see prototyper note).

> **Secondary note — the prototyper / "ship something today" buyer.** Ranking the 7/7-binary builds by pure cost makes **Vibe the floor** ($5.84, ~20m) — but it's a knife-edge "win," not a real recommendation. For **+$1.32 / +~6m** OpenSpec delivers **49.5 vs 29** quality, and Plan Mode gives 43.5 for +$1.94 (the highest-ROI step in the eval). So Vibe wins *only* if you value ~$1–2 and a few minutes above **any** quality at all; for almost any real "quick build" OpenSpec or Plan Mode is the better pick. The prototyper view has no quality floor (only the binary gate), which is exactly why it crowns the cheapest build even when a near-free upgrade is far better.

### Defect counts (correctness, scored separately)

| Severity × Source | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|---|---|---|---|---|
| Critical | 0 | 0 | 0 | 0 | 0 | 0 |
| Major | 1 | 1 | 0 | 0 | 0 | 1 |
| Minor | 5 | 2 | 4 | 2 | 1 | 3 |
| LOC (approx) | ~2,020 | ~2,580 | ~2,000 | ~2,500 | ~2,350 | ~2,300 |
| **Defects / 1KLOC** | 2.97 | 1.16 | ~2.0 | **0.80** | ~0.4† | 1.74 |

† AI-DLC's ~0.4 is a *floor* from a thorough happy-path walkthrough (build / logging / persistence / switch / progression-math all verified); deload, PR-on-finish, and edit-of-logged-set weren't exhaustively exercised. Not bolded as "best" given the lighter hunt.

### Binary outcomes (per [`tasks/t4-fitness-app/success-criteria.md`](../../tasks/t4-fitness-app/success-criteria.md))

| Binary outcome | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|---|---|---|---|---|
| Builds in Expo Go | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Four lifts present | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Today's workout on open | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Set logging works | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Persistence (kill + reopen) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Program selection works | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Configuration toggles work | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Pass count** | **7/7** | **7/7** | **7/7** | **7/7** | **7/7** | **7/7** |

---

## Cost axis

| Metric | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|---|---|---|---|---|
| Total tokens | ~7.0 M | ~7.7 M | **~5.8 M** | ~16.2 M | ~21.3 M | ~96.1 M |
| **Implied API $ (Opus 4.7)** | **$5.84** | **$7.78** | **$7.16** | **$13.21** | **$19.15** | **$75.85** |
| Active wall-clock | 19m 45s | ~27m | 25m 42s | 30m 4s | 38m 30s | 1h 42m |
| Operator-touch time | n/a | _ | ~0 | _ | ~0 (autonomous) | _ |
| Operator interventions | 0 | 0 | 0 | 1 (slash-prefix) | ~0 (autonomous) | 0 |
| Clarifying Qs to PM | 0 | 3 | 0 (docs-instead) | 0 (docs-instead) | 6 surfaced ("all recs") | ≥3 (batched) |
| Methodology overhead ratio | n/a | 0.31 | ~0.95 (archive n/a) | ~1.0–1.3 | ~1.0 (not stopwatched) | ~0.55 |

Note: AI-DLC active time (38m 30s) and cost are from the operator `/status` (wall-clock 2h 33m incl. idle). Ran in autonomous mode (gates pre-authorized), so its signature dense gating isn't reflected in operator-touch. † **AI-DLC's API compute time was not separately captured** (no `/status` screenshot or paste survived). Its session transcript was recovered from `~/.claude` and committed to `artifacts/cdfe9adc-…jsonl`; the 5 turn-durations sum to **34m 53s active**, the tightest available denominator. Since active ≥ API compute, Quality / API hour is a *lower bound* of **≥85** (49.5 / 0.581h). Per rubric v0.2.2 migration.

### Derived ratios

| Ratio | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|---|---|---|---|---|
| Quality / 1K tok | 0.00414 | ~0.0056 | **0.00852** | 0.0031 | 0.0023 | 0.000515 |
| Quality / API hour | 99.7 | **114.9** | **115.5** | 98.8 | ≥85† | 34.1 |
| Defects / 1KLOC | 2.97 | 1.16 | ~2.0 | **0.80** | ~0.4† | 1.74 |
| Methodology overhead | n/a | 0.31 | ~0.95 (archive n/a) | ~1.0–1.3 | ~1.0 | ~0.55 |
| Cost / binary outcome | **$0.83** | $1.11 | $1.02 | $1.89 | $2.74 | $10.84 |
| **Quality / dollar** | 4.97 | 5.59 | **6.91** | 3.75 | 2.59 | 0.65 |

---

## Headline finding per cell

| Cell | Quality | Cost | API time | Binary | One-line verdict |
|---|---|---|---|---|---|
| **Vibe** | 29 / 55 | $5.84 | 17m 27s | 7/7 | Working app, no planning, no documented scope — builds the plate calculator from intuition the structured methodologies cut. |
| **Plan Mode** | 43.5 / 55 | $7.78 | 22m 43s | 7/7 | +14.5 quality for +$1.94 over Vibe — single planning step delivers most of the methodology value at minimal cost; builds the rest timer the others miss. |
| **OpenSpec** | 49.5 / 55 | $7.16 | 25m 42s | 7/7 | Ties the quality leaders (49.5 = Spec Kit = BMAD) at the lowest cost & token count in the eval — best quality-per-dollar (6.91) and per-token (0.0085); co-leads quality-per-API-hour (~115.5, ~tied with Plan Mode 114.9); used me.md numbers + picked 5/3/1; dinged for **leaving plate-loading math to the user** (no per-side display, despite me.md's "no math mid-workout"), silent-rotate post-finish, ~2.0/1KLOC defects (4 minor), and an archive phase that never ran. **Corroborates ranthebuilder's #1 — as cost-efficiency champion + quality co-leader, not the product-polish or defect-density one.** |
| **Spec Kit** | 49.5 / 55 | $13.21 | 30m 4s | 7/7 | Ties BMAD on quality at 17% the cost; best end-of-workout UX in the eval; defect density best (0.80 / 1KLOC). |
| **AI-DLC** | 49.5 / 55 | $19.15 | ~34m 53s active (API n/a) | 7/7 | Ties the quality leaders (now a 4-way tie at 49.5) at **mid-pack cost** — pricier than Spec Kit ($13.21), far cheaper than BMAD ($75.85). OpenSpec still ships the same 49.5 for ~40% the cost (**~2.7× gap**), so it's not the value pick, but nowhere near BMAD's tail (quality/$ 2.59). Dense rule-loading + multi-stage gated workflow + 1,842 doc lines (~21.3 M tokens, mostly cache reads) on Claude Code. Honored me.md (pre-filled 315/225/405/145, picked 5/3/1); **only structured cell to even write the per-side plate calculator — but left it unwired** (lifter still does plate math). Its robustness edge (property-based testing) is a genuine AI-DLC feature — the only methodology that scaffolds it; scored as earned, not an asterisk. |
| **BMAD** | 49.5 / 55 | $75.85 | 1h 32m | 7/7 | Multi-agent ceremony produces equal quality to Spec Kit at 6× the cost; the marginal $62 buys engineering rigor (more unit tests, per-story Build Log) that's invisible to users. |

---

## Cross-cell findings (HEXAD COMPLETE — all 6 methodologies scored on T4)

1. **Four structured methodologies cluster tightly in the high-40s (provisionally 49.5 each); cost varies 13×.** The four landed at the same provisional 49.5/55 — **but that exact equality is a single-rater/unblinded artifact, not real convergence** (see PROVISIONAL note above + the vector table). De-biased against absolute anchors they spread to a ~48–50 cluster; and even at the committed scores they differ in *shape*: BMAD trades product polish (15.5/20) for rigor (34/35), while OpenSpec/AI-DLC do the inverse (17.5/20 product, 32/35 rigor). So the honest claim is *"structure reliably buys high-40s quality on this task with distinct quality shapes; the methodology you pick sets the cost and the polish-vs-rigor balance, not a precise scalar."* What cleanly separates them is **spend: OpenSpec $7.16 < Spec Kit $13.21 < AI-DLC $19.15 < BMAD $75.85** (Vibe $5.84 / Plan Mode $7.78 trail on quality at 29 / 43.5). Per the persona composite below, **OpenSpec wins both primary lenses (indie-dev + enterprise); AI-DLC is its quality-twin at ~2.7× cost; BMAD is the lone expensive tail** (quality/$ 0.65) that wins only the rigor-maximalist / cost-no-object corner. (Secondary note: **Vibe wins the cheapest/fastest-working-prototype use-case** — a real buyer the two primary lenses don't model.) AI-DLC's spend is dominated by its dense rule-set being re-read every turn (20.4 M cache-read tokens of ~21.3 M total) across a long multi-stage gated workflow.

2. **OpenSpec is the new cost-efficiency frontier.** It takes Spec Kit's old "sweet spot" crown: same quality at ~half the cost — **#1 outright on quality-per-dollar (6.91) and quality-per-token (0.0085)**. On the time metric (now raw **API compute time**, per rubric v0.2.2) it's a **co-leader, not the sole winner**: quality-per-API-hour ~115.5 essentially ties Plan Mode (114.9), and on raw speed Plan Mode (22m 43s) and Vibe (17m 27s) both beat OpenSpec's 25m 42s. So the cost-efficiency case rests on **dollars and tokens**, where OpenSpec is unambiguously first. Spec Kit's edge over OpenSpec is narrow — better defect density (0.80 vs ~2.0) and a polished post-finish state. The "delta specs stay compact" thesis showed up directly in the token bill.

3. **BMAD's marginal $62–69 over the cheaper structured cells buys nothing user-visible.** Extra unit tests + per-story Build Log + per-artifact decision logs are engineering rigor a few teams will value; most will pick OpenSpec or Spec Kit and not notice.

4. **Planning narrows feature insight — and OpenSpec is the cleanest proof.** Vibe-pure invented the plate calculator from nothing; Plan Mode + OpenSpec missed it; Spec Kit explicitly cut it; BMAD missed it. So the "structure anchors on the literal brief and trades away feature insight" pattern holds across all four structured/planned cells. **OpenSpec sharpens it to the point of irony:** it was the *only* structured cell to demonstrably *ingest* me.md (it pre-filled the exact maxes 315/225/405/145 and picked the profile-appropriate 5/3/1 — Spec Kit ignored the same context) — and yet it *still* didn't build the plate-per-side display that me.md's own explicit line ("I don't want to think about math mid-workout") most directly calls for. It eliminated *progression* math but not *plate-loading* math. So the planning didn't fail to see the user; it saw the user's numbers and still anchored on the literal feature list. "Structure narrows feature insight" isn't about missing context — OpenSpec had the context — it's about planning treating the brief's enumerated capabilities as the boundary.
   **AI-DLC complicates this (the closest near-miss):** it's the *only* structured cell that actually *wrote* the per-side plate calculator (`platesPerSide`, with a property-based round-trip test) — so its feature insight wasn't fully narrowed — **but it never wired the function into a screen**, so the lifter still does plate math. The pattern shifts from "structured planning doesn't see the feature" to "structured planning can *reach* the feature in the domain layer but doesn't *surface* it." Across the hexad: only Vibe-pure (no planning) shipped a plate breakdown the user can see; every structured cell either cut it, missed it, or (AI-DLC) built it and left it unsurfaced.

5. **Plan Mode delivers most of the structured-methodology value at minimal cost.** +14.5 quality over Vibe for +$1.94 — the highest-ROI single step in the structure spectrum; still the only cell that built the rest timer.

6. **OpenSpec corroborates ranthebuilder.cloud's April 2026 #1 ranking — on a different domain, under anchored rigor.** On Expo mobile (vs their Python serverless), with anchored scales + cost axis + PM-persona control, OpenSpec lands as quality co-leader and outright cost-efficiency champion. The nuance their single-reviewer/single-task setup couldn't surface: it *ties* rather than strictly beats Spec Kit on quality. So "OpenSpec is #1" becomes "OpenSpec is a quality co-leader and the cost-efficiency leader" — a reinforcement of the signal, not a refutation. (One process caveat: OpenSpec's own three-phase discipline didn't fully complete here — the `/opsx:archive` phase never finalized.)

---

## How to extend this matrix

When a new cell is scored:

1. Replace `_TBD_` cells in that methodology's column with the actual values from `runs/t4-fitness-app/<methodology>/run-001/observations.md`.
2. Re-bold any rows where the new cell tied or beat the previous best.
3. Add the cell's one-line verdict to the "Headline finding per cell" table.
4. If a cross-cell finding shifts (e.g., a new cell changes the story), add or revise an item in "Cross-cell findings."
5. Update Status banner at top + status line in [`analysis/README.md`](../README.md).
6. Update [`analysis/handoff.md`](../handoff.md) decisions log + TL;DR.

Defect / cost numbers come from the cell's `observations.md`; rationale lives there. This file is a snapshot, not a duplicate — keep cells as the source of truth for *why* a score; matrix as source of truth for *what* the score is.
