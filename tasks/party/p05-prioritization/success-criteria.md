# P5 — Success criteria (harness-only)

P5 (product / prioritization — semi-objective key). Deliverable: `roadmap.md`.
This is a **planted-truth task**: the sealed `answer-key.md` enumerates 9
trap-insights a good roadmap must reflect. Score against the universal P-track
rubric — `harness/party/scoring-rubric.md` — on the 5 quality dimensions PLUS the
objective-recall axis. This file declares the recall expectations, which
dimensions are load-bearing, task-specific scoring detail, failure modes, and the
headline contrast.

---

## 1. Objective recall expectations (planted traps)

The 9 keyed items live in `answer-key.md` (sealed). Summary for scoring:

| Key | Trap | Type | Subtlety |
|---|---|---|---|
| K1 | BL-04 SSO depends on BL-03 identity service | dependency edge | moderate |
| K2 | BL-12 audit export depends on BL-11 audit pipeline | dependency edge | moderate |
| K3 | BL-07 live dashboards invalidated by Streamflow sunset | invalidation | moderate |
| K4 | BL-13 + BL-15 share the setup-state layer — cheaper together | synergy pair | subtle |
| K5 | BL-02 SOC 2 evidence is deadline-gated (~week 10) | deadline gating | moderate |
| K6 | BL-09 EU export on primary (us-east) cluster violates residency rule | invalidation | subtle |
| K7 | Real capacity well below the 78 nominal — naive top-of-list overcommits | capacity | moderate |
| K8 | BL-21 legacy rewrite is the obvious expensive cut | cut | obvious |
| K9 | BL-06/17/18/24 cosmetic cluster is the cut tier | cut | obvious |

Recall is published as the raw fraction found/9 per cell, plus a precision note
(fabricated dependencies or phantom blockers asserted with confidence). Credit
rules — found vs partial vs missed, and the "ordering-as-credit" rule (correctly
sequencing A before B counts for a dependency even if unstated, but only when the
ordering is unambiguous) — are specified per item in `answer-key.md`. Never folded
into the /25 quality sum.

**Detectability guarantee.** Every keyed item is derivable from
`backlog.md` + `constraints.md` together and from nothing else. None is inferable
from the value/effort columns alone — that's the point: the naive sort misses all
9. None requires outside knowledge (no real vendor named "Streamflow" to look up;
the EOL is stated; the residency rule is stated; the team-state facts are stated).
After hardening, several items deliberately require *inference or cross-reference*
rather than transcription: BL-09 no longer names a region (the solver must chain
"primary analytics cluster" → us-east → "EU data only in-EU" across two constraint
sections for K6); the dependency edges K1/K2 are no longer restated in item text
(the prerequisite must be inferred from the current-state platform facts); K4's
shared layer is no longer flagged with the word "same" (inferred from two
behaviors); and the capacity number (K7) is no longer printed — it must be derived
from "6 engineers × 13 weeks" minus the prose-described PTO/on-call/interrupt
drains. The evidence is present in all cases; it is no longer quotable verbatim.

## 2. Load-bearing dimensions for P5 (and why)

All 5 rubric dimensions apply. Three are load-bearing:

- **Insight depth (dim 3)** — THE load-bearing dimension. The whole task is
  whether the solver sees past a value/effort sort to the second-order structure:
  hidden dependency chains, a constraint that invalidates a flashy item, a synergy
  pair, and a deadline that re-ranks an unglamorous item. K1–K6 are insight-depth
  findings. A roadmap that ranks well but misses the entanglements is exactly the
  "looked great on a slide, fell apart in execution" failure the buyer named.
- **Correctness (dim 1)** — a prioritization is only as good as its facts. Asserting
  a dependency that isn't real, scheduling BL-07 to build on a dying vendor, or
  shipping BL-09 into a non-compliant region are correctness failures that would
  misdirect the team. Precision (no fabricated edges) lives here too.
- **Actionability (dim 4)** — the buyer explicitly wants a sequence with reasons,
  an honest cut-line, and risks called out *before* commit. A plan a skeptical
  planning review can't poke holes in requires stated rationale per item, the
  capacity budget made explicit, and trade-offs of each cut named.

Coverage (dim 2) and Communication (dim 5) are scored but not the differentiators:
all four arms will produce the required sections. Communication's length-band rule
bites if a cell pads to many pages — volume is not coverage; an over-long roadmap
loses Communication points, not gains Coverage ones.

## 3. Task-specific scoring detail (4 vs 5 on the load-bearing dims)

### Insight depth
- **3:** catches the obvious traps (K7 capacity, K8/K9 cuts) and at least one
  dependency or the Streamflow invalidation, but treats most items as flat.
- **4:** catches both dependency edges (K1, K2) AND the Streamflow invalidation
  (K3) AND the deadline gating (K5); engages the *interaction* between them (e.g.
  notes that BL-03 must land early because BL-04 needs it AND the quarter is
  capacity-tight, so BL-03's 6 ew has to be paid before the SSO value lands).
- **5:** all of 4 PLUS surfaces at least one of the genuinely subtle traps — the
  K4 setup-state synergy (and ideally that combined effort < 8 ew) OR the K6
  residency violation — and would change the buyer's plan: e.g. reframes BL-02 as
  the quarter's anchor commitment that everything else schedules around because the
  date doesn't move, or shows that cutting BL-07 frees the 6 ew that makes the
  dependency-blocked work fit.

### Correctness
- **4:** every asserted dependency/constraint is real for these materials; no
  phantom edges; the capacity math is consistent (committed ew ≤ ~60); BL-07 and
  BL-09 are not scheduled to ship as written.
- **5:** above, plus correctly handles the contested points — e.g. recognizes that
  BL-09 isn't simply "cut" but re-scopable to eu-central (a feasibility change, not
  a value change), and that BL-07's cut is about the vendor sunset, not its value
  (it's High-value; the constraint is what kills it this quarter).

### Actionability
- **4:** sequenced table with a "why" per item; explicit ~60 ew budget; cut-line
  with a defensible reason per cut; dependencies stated as ordering constraints the
  team can act on.
- **5:** above, plus decision points / what-would-change-this (e.g. "if the
  Streamflow replacement gets funded, BL-07 comes back in Q4"; "BL-02 is the
  non-negotiable — if it slips, re-cut everything else"), and the cut-line states
  the cost of NOT doing each cut item.

## 4. Failure-mode characterization (observable underperformance)

1. **Pure value/effort sort.** Ranks by value desc then effort asc, draws a line at
   ~capacity, ships BL-07 and BL-04 high — misses every dependency and invalidation.
   The baseline this task is built to expose.
2. **BL-04 scheduled before/without BL-03.** SSO sequenced early for sales reasons
   with no identity service in front of it (misses K1).
3. **BL-12 scheduled before/without BL-11.** Audit export UI with nothing structured
   to query (misses K2).
4. **BL-07 kept as a flagship.** "Demoes incredibly well," scheduled for build —
   ignores the Streamflow EOL entirely (misses K3). The most seductive miss.
5. **BL-13 and BL-15 split or only one taken.** Treated as two independent Med/4ew
   items; the shared setup-state layer is paid for twice or the synergy is unseen
   (misses K4). The subtlest common miss.
6. **BL-02 buried mid/late or cut.** Treated as just another High/5 with no time
   pressure; no recognition that the audit date is the hardest constraint in the
   quarter (misses K5).
7. **BL-09 scheduled as-written on the primary cluster.** The residency violation is
   read past because the item phrases the primary analytics cluster as a convenient
   existing-infra reuse and never names a region — the solver fails to chain it to
   the us-east platform fact and the EU-only compliance note (misses K6).
8. **Plans to ~78 ew (nominal) or no budget at all.** Ignores the capacity haircut;
   overcommits the quarter (misses K7). Now also: takes the haircut qualitatively
   but never derives a number and still commits ~70+ ew (partial on K7).
9. **Fabricated dependencies / phantom blockers / decoy-chasing.** Asserts
   entanglements that aren't in the materials, OR bites on a planted PM-note decoy
   (treats BL-08+BL-20 as a real synergy pair like K4, calls BL-16 or BL-19
   "load-bearing" because the notes hyped them) — inflating apparent insight while
   actually losing precision, dinged on Correctness and in the precision note.
10. **Volume masquerade.** Many pages, every item lovingly described, no cut-line
    spine — bloat scored down in Communication; coverage of the *traps* still thin.
11. **Cut-line without reasons.** Lists what's out but can't defend it ("lower
    priority") — fails the buyer's explicit "defend each cut" ask (Actionability).

## 5. Headline finding for P5

P5 is built to reveal whether a method surfaces **second-order roadmap structure**
that a value/effort sort cannot. The naive sort is a strong, plausible-looking
attractor — and it walks into all 9 traps. The interesting contrast: does the
multi-persona deliberation (A4) catch more of the *subtle* traps (K4 synergy, K6
residency) than a solo pass (A1), and does it do so more than just a persona
prompt (A3) or extra thinking tokens (A2)? A roadmap profile is exactly where the
"PM + architect + security/compliance lens" pitch should pay off if it pays off
anywhere: the dependency edges read like a PM/architect catch, K6 reads like a
compliance catch, K3 like a platform catch. If party mode earns its seat anywhere
on this track, P5's subtle items (K4, K6) are where it should show — and if A3 or
A1 catch them just as often, that's the masquerade read for the prioritization
profile. Precision is the counter-check: a roundtable that "finds" 9/9 by also
inventing four phantom dependencies has not won.

## calibration

Cold-pass recall (pre-hardening): **8 found + 1 partial / 9 — ceiling, too easy
to discriminate.** The traps were near-verbatim cues. Hardened in
`reference/backlog.md` + `reference/constraints.md`: K6's "us-east" pulled out of
the BL-09 item and the residency rule moved to a separate Compliance section (now
needs primary-cluster→us-east→EU-only cross-referencing); K4's "same" removed from
BL-15 (synergy now inferred from behavior); K1/K2 prerequisites no longer restated
in item text (inferred from current-state platform facts); K7's literal "60 not
78" replaced by a prose haircut the solver must compute. Three clean decoys added
to the PM notes (BL-16 hype, BL-08+BL-20 false pairing, BL-19 ask) to cost a
shotgun solver precision.

Predicted post-hardening cold solo (A1) recall ~3–6/9 (likely K3, K5, K8, K9 and
one of K1/K2; likely misses or only-partials K4, K6, and the K7 derivation; may
forfeit precision on the decoys). Target for a strong/deliberative pass: 6–8/9
with clean precision. If a re-calibrated cold pass scores ≥8/9 again or ≤2/9,
re-tune phrasing salience and re-log here before any cell runs.

## provenance

N/A — P5 is fully synthetic. The backlog, constraints, company (Lumen), and vendor
(Streamflow) are invented for this task; no external repo, dataset, or real product
was vendored. No license obligations. The three precision decoys (BL-16 hype,
BL-08+BL-20 false pairing, BL-19 ask) are likewise invented and carry no real
constraint — they exist only to test a shotgun solver's precision and are not
keyed items.


## Calibration record (2026-06-09) — re-roled: recall=floor, precision=signal



Two cold-pass rounds (Opus 4.8 solo = arm A1 stand-in). Result fed the track-wide
**detection-saturation** re-role: recall is a floor check; the keyed decoys + precision are
the objective discriminator. See `analysis/party-findings/00-detection-saturation.md` and
`harness/party/scoring-rubric.md` § Objective floor + precision axis.
