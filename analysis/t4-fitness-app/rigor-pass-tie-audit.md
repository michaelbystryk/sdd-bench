# T4 rigor pass — auditing the 4-way 49.5 tie + final-score architecture

**Status:** PROPOSAL for operator review. Does **not** overwrite the committed scores in `scoring-matrix.md`. Triggered by the operator's challenge: *"how is it possible all 4 tied… they all have perfect code quality?"*

**Author:** Claude (unblinded — same limitation as the original scoring; see §1). **Date:** 2026-05-27.

Scope: (1) blinding audit, (2) de-biased re-score of the contested half-points against *absolute* anchors, (3) Product/Rigor decomposition, (4) persona composite — two primary lenses (indie-dev, enterprise) with the efficiency-ratio headline + a per-lens quality bar, plus a secondary "prototyper" note, (5) rubric top-end fixes.

---

## 0. The premise check

"They all have perfect code quality" — **false.** AI-DLC's Code quality is 4.5, BMAD's UI is 4, UX 3.5, Robustness 3.5. The four cells do **not** share a per-dimension profile; they share a *total*. Here is the actual grid:

| # | Dimension | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---|:--:|:--:|:--:|:--:|
| 1 | Functionality | 4.5 | 4.5 | 4.5 | 4.5 |
| 3 | Code quality | 5 | 5 | 4.5 | 5 |
| 4 | System design | 5 | 5 | 5 | 5 |
| 5 | UI design | 4.5 | 4.5 | 4.5 | 4 |
| 6 | UX | 4 | 4 | 4 | 3.5 |
| 7 | Robustness | 4.5 | 4 | 4.5 | 3.5 |
| 8 | Security | 3 | 3 | 3 | 4 |
| 9 | Documentation | 4.5 | 5 | 5 | 5 |
| 10 | Spec articulation | 5 | 5 | 5 | 5 |
| 11 | Scope clarity | 5 | 5 | 5 | 5 |
| 12 | Assumption surfacing | 4.5 | 4.5 | 4.5 | 5 |
| | **Sum / 55** | **49.5** | **49.5** | **49.5** | **49.5** |

The totals coincide; the *shapes* don't. The job below is to test whether the coincidence is real convergence or a scoring artifact.

---

## 1. Blinding audit

**Finding: the tie is scored under conditions the rubric itself says invalidate precision.**

The rubric (`harness/scoring-rubric.md`) prescribes:
> "Blinding: strip methodology labels from outputs before scoring. Identify as 'Output A through D'… Double-rate where a second reviewer is available; if raters disagree by more than 1, both rescore."
> "Design goal: …so two independent reviewers scoring the same artifact land within 1 point on every dimension."

What actually happened (from the cell headers):

| Cell | Reviewer | Blind? | Scored | Note |
|---|---|---|---|---|
| OpenSpec | Operator | **No** | 2026-05-26 same-day | "unblinded — bias acknowledged" |
| Spec Kit | Operator | **No** | 2026-05-26 same-day | "unblinded — bias acknowledged" |
| AI-DLC | Operator | **No** | 2026-05-27 same-day | "unblinded — bias acknowledged" |
| BMAD | Operator | **No** | 2026-05-25 same-day | "unblinded — bias acknowledged" |

- **Single rater, never blind, no double-rating.** The within-1-point reproducibility goal was never tested. So the half-point precision the matrix reports is unverified.
- **Sequential scoring with knowledge of prior totals.** BMAD scored first (and was even revised *down* from 52.5→49.5 after an operator review). Then Spec Kit, OpenSpec, AI-DLC each scored later — with BMAD's 49.5 as a visible reference point. AI-DLC's own observation says the quiet part out loud: *"A clean 4-way tie at the top (OpenSpec = Spec Kit = BMAD = AI-DLC = 49.5)."* Landing on the established number was an explicit frame, not an independent result.
- **Relative anchoring pervades the rationales.** Direct quotes: "Held at 4.5 **vs Spec Kit**"; "Ties **BMAD's PRD**"; "**below BMAD** (4, explicit threat docs)"; "Nets even with **Spec Kit / OpenSpec**." Many half-points are justified by another cell's score, not by the anchor clause. This is anchoring-to-the-cluster — the exact bias that produces artificial ties.

**Verdict:** the *direction* (all four are strong, high-40s) is trustworthy. The *exact equality at 49.5* is not — it carries an unmeasured ±~1 per cell and shows fingerprints of convergence-to-prior-total.

**Exposure ranking (whose number is least safe):** Spec Kit and OpenSpec (scored after BMAD, heaviest relative-anchoring language) > AI-DLC (scored last, explicitly framed as completing the tie) > BMAD (scored first + independently revised, so least reference-anchored — though still unblinded).

---

## 2. De-biased re-score (against absolute anchors only)

Method: for each *contested* half-point, ignore other cells and ignore methodology reputation; cite the anchor clause; decide if the evidence in the observation meets it. Saturated dims (System=5, Functionality=4.5 across all) left alone — they're genuinely uniform. Confidence + direction noted. **These are proposed alternatives to show the tie's fragility, not a new gospel.**

### 2a. Ceiling-inflation (applies roughly equally — shifts level, not rank)

- **Scope clarity (all four = 5).** Anchor 5 = *"scope decisions are revisited when new information surfaces (conditional, not just declared)."* Anchor 4 = *"scope was actively defended."* The rationales describe anchor-4 behavior ("explicit non-goals," "scope actively defended," "scope is the 5 capabilities") — **none show conditional revisiting.** Defensible re-score: OpenSpec/Spec Kit/AI-DLC → **4.5**; BMAD → **5** (its "variances documented" is the only hint of revisiting). *Effect: −0.5 to three cells.*
- **Spec articulation (all four = 5).** Anchor 5 = *"the spec correctly predicts the edge cases that turn up during implementation."* Only **BMAD's** observation actually evidences this ("predicted AMRAP-feeds-e1RM, deload trigger, FR-16"). The others evidence anchor-4 ("decisions documented, alternatives considered"). Defensible: BMAD → **5**; OpenSpec/Spec Kit/AI-DLC → **4.5**. *Effect: −0.5 to three cells.* (Low confidence — all three specs are excellent; this is a strict reading.)

These two corrections lower OpenSpec/Spec Kit/AI-DLC by up to 1.0 each and leave BMAD ~unchanged — which would actually make BMAD the *highest*, not break the tie symmetrically. Flagged, low-to-medium confidence.

### 2b. Differentiating corrections (these change the rank order)

| Cell · Dim | Now | Proposed | Anchor-based reason | Conf. |
|---|:--:|:--:|---|---|
| **AI-DLC · Code** | 4.5 | **5** | The 0.5 dock was explicitly *"did not line-read all of db/repositories/services"* — i.e., it penalizes **reviewer coverage, not the artifact**. On observed evidence (pure PBT-tested progression engine, clean layering) it meets anchor 5 "small surprises of skill." Either finish the read or score what was seen. | High |
| **Spec Kit · Code** | 5 | **4.5** | Anchor 5 = "small surprises of skill (well-chosen abstractions, restraint)." Spec Kit's rationale cites anchor-4 evidence only ("clean separation, named functions, idiomatic") — **no specific skill-surprise named**, unlike OpenSpec (compactness) / BMAD (memoized-init race fix) / AI-DLC (PBT engine). | Med |
| **BMAD · Robustness** | 3.5 | **4** | The 3.5 is driven by the post-finish "no session-complete state" — but that is a **UX/design** gap (already counted in UX 3.5 and as the Major defect), **not** a Robustness one. Robustness anchor is bad-input/partial-failure/edge-cases; BMAD's real robustness (migration race *found + fixed*, append-only migrations, validation, data model absorbs future reqs) is a clean anchor-4. The post-finish issue is being **triple-counted** (UI, UX, Robustness) for one root cause. | Med-High |
| **BMAD · Security** | 4 | **3.5** | All four cells have the **identical** posture: local-only SQLite, parameterized, no network/secrets. Anchor 4 needs "dep audit visible (lockfile, no stale CVEs), sensitive ops logged." BMAD's 4 rests on "threat boundaries *implicit*" + NFR-1 wording — i.e., **documentation of posture**, not a materially stronger posture. If the others are 3, BMAD is ~3.5, not 4. | Med |
| **BMAD · Assumptions** | 5 | **4.5** | Anchor 5 = "assumptions mapped to specific code locations that would need to change if revisited." BMAD's FR-N build-log traceability is the closest in the eval but maps *requirements* to code, not *assumptions* → anchor 4 ("categorized") + partial 5. | Low-Med |
| **OpenSpec · Docs** | 4.5 | 4.5 (hold) | The 0.5 dock is volume/onboarding-based (no quickstart artifact), which is legitimate (anchor 4 = "onboarding flow, 10 min clone-to-running"). Hold, but note design.md's reasoning *does* meet anchor-5 quality — genuine ±0.5 uncertainty. | — |

### 2c. What happens to the tie

Applying §2b only (the rank-changing, higher-confidence corrections) and leaving §2a aside:

| Cell | Committed | De-biased (§2b) | Δ |
|---|:--:|:--:|:--:|
| AI-DLC | 49.5 | **50.0** | +0.5 (Code) |
| OpenSpec | 49.5 | **49.5** | — |
| BMAD | 49.5 | **49.0** | +0.5 Robust −0.5 Security −0.5 Assume |
| Spec Kit | 49.5 | **49.0** | −0.5 (Code) |

Add the §2a ceiling corrections (−0.5 Scope and/or −0.5 Spec to the three non-BMAD cells) and the band widens to roughly **AI-DLC 49–50 · OpenSpec 48.5–49.5 · Spec Kit 48–49 · BMAD 48.5–49.5**.

**Conclusion:** the exact 4-way 49.5 does not survive a defensible absolute-anchor re-read. It dissolves into a **~2-point cluster (≈48–50) with overlapping ±1 error bars**. The honest claim is *"four structured cells cluster in the high-40s, not separable at half-point precision"* — **not** *"four methodologies produced identically-good apps."* The original tie was real *clustering* dressed up as false *precision* by ceiling saturation + relative anchoring.

---

## 3. Quality as a vector: Product polish vs Engineering rigor

The scalar sum hid a clean, real structure. Split the 11 scored dims:

- **Product polish (P, /20):** Functionality + UI + UX + Robustness — what a user touches.
- **Engineering rigor (R, /35):** Code + System + Security + Docs + Spec + Scope + Assumptions — craft + process/governance.

Using the **committed** scores (so this is independent of §2's proposals):

| Cell | Product /20 | Product % | Rigor /35 | Rigor % | Total /55 |
|---|:--:|:--:|:--:|:--:|:--:|
| OpenSpec | 17.5 | 87.5 | 32.0 | 91.4 | 49.5 |
| Spec Kit | 17.0 | 85.0 | 32.5 | 92.9 | 49.5 |
| AI-DLC | 17.5 | 87.5 | 32.0 | 91.4 | 49.5 |
| BMAD | 15.5 | 77.5 | 34.0 | 97.1 | 49.5 |

**This is the finding the tie erased:** BMAD is *lowest* on product polish and *highest* on engineering rigor; OpenSpec and AI-DLC are the inverse; Spec Kit sits between. The four "identical" cells trade product polish against governance rigor along a clean front. Equal-weight summing makes anti-correlated profiles collapse to the same scalar.

---

## 4. Final-score architecture (per operator decisions)

Decisions locked: **headline scalar + visible vector**; cost enters as an **efficiency ratio (Quality ÷ Cost) with a quality floor**; **two primary persona lenses** (indie-dev vs enterprise); **time folded into cost**. The floor is reframed as a **persona-specific bar, not a global disqualification** — and a **secondary "prototyper" note** (§4b) records the cheapest-working-build buyer the operator flagged, without promoting it to a third main lens.

### 4a. Persona weightings

| Lens | Product weight | Rigor weight | Cost sensitivity | Rationale |
|---|:--:|:--:|---|---|
| **Indie-dev** | 0.70 | 0.30 | High (divide by $) | Ships a product; pays the bill personally; governance is overhead. |
| **Enterprise** | 0.40 | 0.60 | Low (cost as tiebreak) | Maintains for years across a team; audit/rigor matters; $ is rounding error. |

The "quality floor" is **persona-specific, not a global disqualification.** The Indie bar is "a product I'd ship to users" (~80/100 weighted); the Enterprise lens has no cost bar (it ranks by quality directly). A cell can fall below one lens's bar and still serve another buyer (see the prototyper note) — that's the model working, not a cell being "bad."

Weighted quality (0–100) = wP·Product% + wR·Rigor%.

| Cell | Indie WQ | Enterprise WQ |
|---|:--:|:--:|
| OpenSpec | **88.7** | **89.9** |
| Spec Kit | 87.4 | 89.7 |
| AI-DLC | **88.7** | **89.9** |
| BMAD | 83.4 | 89.3 |

Note: even the **enterprise** lens barely separates them (89.3–89.9) because rigor is saturated-high for all four. The **indie** lens separates more (83.4–88.7) because product polish has the real variance — and **BMAD lands last**.

### 4b. Headline scalar = persona efficiency

**Indie headline = Indie WQ ÷ $** (quality-per-dollar), with the indie product bar (≈80/100 weighted): an indie ships to users, so a throwaway doesn't count *for this buyer*.

| Cell | Indie WQ | Cost | **Indie efficiency (Q/$)** | Clears indie bar? |
|---|:--:|:--:|:--:|:--:|
| **OpenSpec** | 88.7 | $7.16 | **12.4** | ✅ #1 |
| Plan Mode | 84.0 | $7.78 | 10.8 | ✅ #2 |
| Spec Kit | 87.4 | $13.21 | 6.6 | ✅ #3 |
| AI-DLC | 88.7 | $19.15 | 4.6 | ✅ #4 |
| BMAD | 83.4 | $75.85 | 1.1 | ✅ #5 |
| Vibe | 64.5 | $5.84 | 11.0 | ❌ below bar |

The bar matters: Vibe's raw Q/$ (11.0) would rank #2 on price alone despite a 64.5/100 product — but *for the indie buyer* that's not a shippable product, so it's below their bar (it still wins the prototyper use-case — see the secondary note below). **Plan Mode is the indie value runner-up** (cheap *and* clears the bar). OpenSpec wins the indie lens.

**Enterprise headline = Enterprise WQ, cost as tiebreak** (cost-insensitive persona):

| Rank | Cell | Enterprise WQ | Cost (tiebreak) |
|---|---|:--:|:--:|
| 1 | OpenSpec | 89.9 | $7.16 |
| 2 | AI-DLC | 89.9 | $19.15 |
| 3 | Spec Kit | 89.7 | $13.21 |
| 4 | BMAD | 89.3 | $75.85 |
| 5 | *Plan Mode (ref)* | *80.4* | *$7.78* |
| 6 | *Vibe (ref)* | *54.0* | *$5.84* |

The enterprise lens applies **no quality floor** — it ranks by weighted quality directly (cost-insensitive), so all six cells get a rank; the controls (Vibe 54.0, Plan Mode 80.4) just trail the structured cluster (89.3–89.9). (The floor only applies to the cost-sensitive indie lens, to stop a cheap-but-weak build winning on price.)

**BMAD only becomes the winner if rigor weight exceeds ~0.75 AND cost is fully ignored** — i.e., a rigor-maximalist, cost-no-object niche (regulated/safety-critical). At any normal enterprise weighting it's dominated, because its product deficit (77.5%) outweighs its rigor edge (97.1%) in the blend, and OpenSpec matches its quality-shape at 1/10 the cost.

> **Secondary note — the prototyper / "ship something today" buyer.** Not a primary lens, but a real use-case the operator flagged. Ranking the 7/7-binary builds by pure cost makes **Vibe the floor** ($5.84, ~20m, 7/7) — but this is a knife-edge result, not a recommendation. Vibe beats Plan Mode on *nothing but cost+speed* (−$1.94, ~7m) while losing quality 29 vs 43.5; and for just **+$1.32 / +~6m** OpenSpec jumps to **49.5** quality. So Vibe wins only if you value ~$1–2 / a few minutes over **any** quality whatsoever — for almost any real quick build, OpenSpec or Plan Mode dominates (Plan Mode = +14.5 quality for +$1.94, the eval's highest-ROI step). The prototyper view has no quality floor (only the binary gate), which is *why* it crowns the cheapest build even when a near-free upgrade is far better — the same failure mode as the indie lens without its floor. Vibe falling below the indie bar isn't "Vibe is bad," it's "Vibe is a prototype, not a shippable product."

### 4c. Headline scalar + vector, per cell (the deliverable format)

```
                Indie · Ent   ▕ Product% · Rigor% · $ ▏
OpenSpec        #1    · #1    ▕ 87.5 · 91.4 · $7.16  ▏  ← wins both lenses
Spec Kit        #3    · #3    ▕ 85.0 · 92.9 · $13.21 ▏  ← safe middle
AI-DLC          #4    · #2    ▕ 87.5 · 91.4 · $19.15 ▏  ← OpenSpec's twin at 2.7× cost (buys PBT robustness)
BMAD            #5    · #4    ▕ 77.5 · 97.1 · $75.85 ▏  ← rigor-max, cost-no-object only
Plan Mode       #2    · #5    ▕ 87.5 · 75.7 · $7.78  ▏  ← indie value runner-up
Vibe            bar   · #6    ▕ 75.0 · 40.0 · $5.84  ▏  ← cost/time floor only; near-free upgrade beats it (§4b)
```

**Net:** the composite turns a meaningless 4-way tie into a real *per-buyer* decision. **Indie-dev → OpenSpec** (best product-per-dollar; Plan Mode strong #2). **Enterprise → OpenSpec** (BMAD only the rigor-maximalist / cost-no-object corner; AI-DLC its quality-twin at 2.7× cost). OpenSpec wins both primary lenses. (Secondary note: **Vibe is the pure cost/time floor**, but a near-free upgrade to OpenSpec (+$1.32 → 49.5 quality) or Plan Mode (+$1.94 → 43.5) beats it — so it "wins" only the no-quality-floor prototyper view.)

---

## 5. Rubric fixes (root cause of the tie)

Proposed edits to `harness/scoring-rubric.md` (would bump to v0.2; re-score note required):

1. **Anti-ceiling-inflation clause.** "Do not award 5 unless the level-5 clause is *independently evidenced*. 'Thorough / excellent' that meets level 4 is a 4, not a 5." Especially Scope (5 needs *conditional revisiting*) and Spec (5 needs *predicted impl edge cases*).
2. **Saturation guard.** "If ≥3 cells in a comparison receive the identical score on a dimension, the reviewer must either (a) write a one-line justification that non-differentiation is real, or (b) spread them." Forces the rater to defend every tie.
3. **Absolute-not-relative rule.** "Justify each score by citing the anchor clause, not by reference to another cell ('ties X', 'below Y' are insufficient)." Directly targets the §1 anchoring evidence.
4. **Blinding enforcement / provisional flag.** "Scores produced unblinded and single-rater are PROVISIONAL until a blind pass or a second rater confirms within 1 point." Marks the current hexad provisional.
5. **Vector reporting.** "Report quality as the (Product /20, Rigor /35) pair *and* the total. Never publish the total alone." Institutionalizes §3.
6. **No false precision.** "When cells fall within ~1.5 points, report the band/cluster, not separable half-point ranks."

---

## 6. Recommendation

- The 49.5×4 **stands as committed history** (it's what the unblinded single-rater pass produced) but should be **labeled provisional** and **always shown as the (Product, Rigor) vector + cost**, never as a bare "4-way tie."
- Adopt the **persona-composite** (§4) as the headline framing: it's honest about the cluster *and* gives a usable ranking — OpenSpec frontier, AI-DLC its costlier twin, Spec Kit safe middle, BMAD rigor-corner.
- **Open question for operator:** do we (a) keep 49.5 as provisional-with-vector + adopt the composite framing (lowest-churn, recommended), or (b) actually apply the §2b de-biased re-scores (AI-DLC 50 / OpenSpec 49.5 / Spec Kit 49 / BMAD 49) as the new official numbers (breaks the tie but requires re-scoring the other 2 cells for parity and a rubric-version bump)?
