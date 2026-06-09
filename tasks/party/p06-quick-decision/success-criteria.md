# P6 — Success Criteria (pv0.3)

P6 (Quick decision — **the over-ceremony control**) scoring. Applied after a cell
completes; used identically across all four arms. Rubric-scored (no planted-truth
answer key), **cost-weighted** per the § overlay below.

Universal P-track rubric (5 anchored dims, scrub protocol, blinding):
[`harness/party/scoring-rubric.md`](../../../harness/party/scoring-rubric.md).
This file declares P6's coverage checklist, which of the 5 dims are load-bearing,
the task-specific 4-vs-5 detail, the failure modes, the headline contrast, and —
uniquely for P6 — the **cost-weighted composite overlay** that operationalizes
"a fast right-sized answer should win; an elaborate multi-page treatment should
lose."

P6 is deliberately the cheapest task in the set to author and the one most likely
to differentiate the arms. The whole point: this is a $50 question. Any arm that
spends $30 of deliberation answering it loses on the composite *even if* its prose
is marginally better.

---

## 1. Coverage checklist (rubric task — no planted-truth key)

A complete `decision.md` substantively covers all four required sections, each
*grounded in the specifics of `reference/situation.md`* (not generic pagination
advice):

| # | Area | Substantively covered means… |
|---|---|---|
| C1 | **Recommendation** | A single concrete default value in `[1, 200]`, stated up front, unambiguous. Not a range, not "it depends", not two co-equal options. |
| C2 | **Top 3 reasons** | At most three reasons, each tied to a *specific fact in the situation* (the ~15-row viewport, the 1-in-5 second-page rate, the flat DB cost curve, the ~0.3 ms/item serialization, the single internal client, the low ~30 req/min load). |
| C3 | **Key risk** | One concrete, situation-specific way the pick could be wrong — not a boilerplate "performance might degrade." |
| C4 | **Reversal condition** | A concrete, observable trigger (a metric, a usage-pattern change, a new client) that should prompt changing the constant — exploiting that the brief explicitly says it's a one-line reversible change. |

Coverage here is *binary-ish and shallow by design*: all four sections present
and grounded = checklist met. There is no credit for additional sections. Extra
sections (cost-benefit matrices, stakeholder analysis, appendices, "options
considered" tables running half a page each) are **ceremony tax** — see overlay.

## 2. Which of the 5 dims are load-bearing for P6, and why

All five dims are scored 0–5 per the universal rubric. For P6 the load-bearing
dims are **Communication**, **Actionability**, and **Insight depth** — in that
priority order — with **Correctness** as a gate and **Coverage** mostly saturated.

- **Communication (load-bearing, primary).** This task is *about* right-sizing.
  The brief asks for a thirty-second standup-ready call and caps length at one
  page. Communication is where over-length is penalized (the length-band rule)
  AND where the ceremony tax is most visible. A crisp half-page memo that lands
  the call is the target; a multi-page treatise is a Communication failure even
  if every sentence is true.
- **Actionability (load-bearing).** The deliverable lives or dies on giving a
  *single committed number* plus a *concrete reversal condition*. Hedging ("20 or
  50, depending…"), or a reversal condition that's just "monitor and reassess,"
  caps this dim.
- **Insight depth (load-bearing, but capped fast).** One genuinely
  situation-specific observation (e.g. connecting the 1-in-5 second-page rate and
  the ~15-row viewport to argue the default should comfortably exceed one viewport
  but needn't chase the rare second page; or noting the DB cost is flat so the
  real cost knob is serialization CPU, not query time) lifts this to 3–4. But
  there is a hard ceiling: this is a small reversible call, and *manufacturing*
  depth (scenario-modeling traffic growth, TCO analysis) is over-ceremony, not
  insight. See § 3 for the cap.
- **Correctness (gate, not differentiator).** Easy to get right; mainly a floor.
  The two ways to actually be *wrong* here: (a) recommending a value outside the
  enforced bounds or contradicting a locked constraint (e.g. proposing a config
  flag the situation explicitly ruled out, or a value > 200), or (b) a reason
  built on a misread fact (claiming the DB is the bottleneck when the situation
  says the curve is flat and serialization dominates). Either is a Correctness hit.
- **Coverage (mostly saturated).** Four required sections; most competent attempts
  hit all four. Coverage is *not* where length is rewarded — a longer document
  does not earn Coverage points (universal length-band rule). Coverage 3 = all
  four sections grounded; 4+ requires engaging an implicit concern (e.g. that the
  console's lack of "jump to page N" means deep pagination cost is irrelevant, so
  the default only needs to serve first-page lookups well) WITHOUT inflating length.

## 3. Task-specific scoring detail (4 vs 5 on the load-bearing dims)

**Communication.**
- **5** — Half a page or less. Recommendation visible in the first line. Reads
  like a decision a competent engineer made in five minutes and is confident in.
  A director would forward it unedited. Zero filler sections.
- **4** — One page or less, tight, conclusion findable in one pass, but carries a
  little extra (a short "options considered" aside, slightly long reasons).
- **3** — At/near the one-page cap, structured but somewhat padded; still readable.
- **≤2** — Over one page, OR structured by process (roundtable transcript, "first
  the architect raised…", multi-section deliberation) rather than by the reader's
  need for a fast answer. **Any deliverable materially over one page is capped at
  Communication 2** and additionally incurs the ceremony-tax flag (overlay § B).

**Actionability.**
- **5** — One committed number; reversal condition is a *named observable signal
  with an implied threshold* ("if the next-page fetch rate climbs past ~1 in 2
  sessions, or a second client needs bulk export, bump it"). What-would-change-
  my-mind is explicit and measurable.
- **4** — One committed number; reversal condition concrete but threshold left
  fuzzy.
- **3** — Committed number, but reversal condition vague ("revisit if usage
  changes") or risk stated generically.
- **≤2** — No single committed number (hedged/co-equal options), or no usable
  reversal trigger.

**Insight depth (with the over-ceremony cap).**
- **4** — Two+ situation-specific observations that correctly weigh the trade-off
  (viewport vs second-page rate; flat DB cost shifting the real cost to
  serialization CPU; single-client/low-load meaning future-proofing is premature).
- **3** — One such observation.
- **Cap:** Depth above 4 is **not** awarded for *more* analysis. A cell that
  reaches for traffic-growth modeling, multi-year projections, or a weighted
  decision matrix on a one-line reversible constant is **not** showing insight —
  it is mis-sizing the problem, and that is penalized in Communication and flagged
  as ceremony tax. The senior-engineer move here is recognizing the question is
  small and answering it fast; a cell that *says so* (e.g. "this is a cheap,
  reversible call; not worth more than a paragraph of analysis") demonstrates the
  highest insight available on this task.

## § OVERLAY — Cost-weighted composite (P6 only)

P6's headline number is **not** the /25 quality sum. It is a cost-weighted
composite that encodes the over-ceremony thesis: *quality saturates fast and is
capped; cost and length penalties are steep.* The composite exists to make
"a $30 roundtable on a $50 question loses by design" a measured outcome, not a
vibe.

### A. Quality is capped quickly

- Take the raw quality sum `Q` = the five anchored dims summed, /25.
- Apply a **right-sizing cap**: `Q_capped = min(Q, 20)`. On a quick reversible
  decision there is no meaningful difference between a 21/25 and a 25/25 answer —
  both are "a competent fast call." Points above 20 reward polish the buyer didn't
  ask for and would not pay for. The cap removes the incentive to grind quality.
- Floor gate: if Correctness ≤ 2 (wrong value, violated constraint, or misread
  fact), the composite is reported as a fail regardless of cost — a cheap wrong
  answer is still wrong.

### B. Length / ceremony tax (steep, two-pronged)

Length is penalized **twice on purpose** — once inside Communication (the
universal length-band rule) and once as an explicit composite penalty — because
over-length here is the *primary symptom* of the failure mode this task hunts.

- Measure the deliverable length `L` (rendered, body only — exclude the four
  section headers).
- **Within band** (≤ ~1 page; operationally ≤ ~450 words): tax = 0.
- **Over band**: `ceremony_tax = 0.5 × ceil((L − 450 words) / 250 words)` points,
  subtracted from `Q_capped`, capped at −6. So ~1.5 pages ≈ −1, ~2.5 pages ≈ −2,
  a sprawling multi-page treatment bleeds steadily. This is *in addition to* the
  Communication-dim cap of 2 for over-length deliverables.
- **Ceremony-tax flag (qualitative, published with the cell):** raise it when the
  deliverable shows any of — sections beyond the four required; an "options
  considered" or decision-matrix table; a stakeholder/risk register; visible
  roundtable/deliberation structure; multi-year or traffic-growth modeling on a
  reversible constant; or any framing that treats this $50 question as needing a
  committee. The flag is the human-legible companion to the numeric tax.

### C. Cost axis (steep weighting for P6)

Per the universal cost axis (implied USD + API time + operator-intervention
count), but for P6 cost is **weighted into the composite**, not just reported
alongside it:

- Record implied USD `$` and wall/API time per the main-track instrumentation
  protocol (same as every cell).
- **Cost penalty:** `cost_tax = round($ / $0.05)` × 0.25 points subtracted from
  `Q_capped`, capped at −8. Calibrate the divisor at calibration time so a lean
  one-shot answer (A1's expected spend) incurs ≈ 0 and a heavy multi-agent
  roundtable incurs a visible hit. The intent, not the exact divisor, is locked:
  **a 6× cost difference for a <1-point quality difference must flip the
  composite.** Tune the divisor during calibration to honor that intent and record
  the locked value here.
- Operator interventions (A4's neutral continuations) are reported but not taxed —
  they're a machinery cost, surfaced in the cost triple, not the composite.

### D. Composite

```
P6_composite = max(0, Q_capped − ceremony_tax − cost_tax)   # fail if Correctness ≤ 2
```

Published per cell as the triple **(P6_composite, raw quality vector, cost
triple + ceremony-tax flag)** — never collapsed to the composite alone, so a
reader can see *why* an arm lost: was it quality, length, or spend. The composite
is the headline because it is the only number that makes the over-ceremony tax
visible.

## 4. Failure-mode characterization (observable ways a solver underperforms)

1. **Over-length treatise.** Multi-page answer with extra sections (cost-benefit
   matrix, full "options considered", appendix). Caps Communication at 2, takes
   the ceremony tax, raises the flag. *The signature failure this task hunts.*
2. **Visible deliberation structure.** The deliverable reads as a roundtable
   transcript or "the architect noted… the PM countered…" synthesis instead of a
   clean decision memo. Process-shaped, not reader-shaped — Communication ≤ 2.
   (Note: scrubbing strips persona names, but the *structure* survives and is the
   tell that drives the score down.)
3. **Hedged non-decision.** "I'd go with 20 or 50 depending on…" — fails C1 and
   caps Actionability at 2. The brief explicitly asked for one number.
4. **Generic, ungrounded reasons.** Top-3 reasons are textbook pagination advice
   ("smaller pages reduce payload, larger pages reduce round trips") that never
   touch the situation's specifics (15-row viewport, 1-in-5 second page, flat DB
   curve). Caps Insight depth at 2 and weakens Coverage C2.
5. **Misread-fact reason.** A reason built on a fact the situation contradicts —
   e.g. "default high to reduce DB load" when the situation says the DB curve is
   flat and serialization dominates; or "go small for mobile" when mobile is
   explicitly out of scope. Correctness hit.
6. **Constraint violation.** Recommends a value > 200, or proposes adding a config
   flag / making it per-client configurable, both of which the situation
   explicitly rules out. Correctness gate → composite fail.
7. **Vacuous reversal condition.** "Monitor and revisit if needed" — no observable
   signal, no threshold. Caps Actionability at 3. Misses that the brief handed the
   solver an easy win by stating the change is a one-line PR.
8. **Manufactured depth / mis-sizing.** Traffic-growth scenarios, multi-year TCO,
   or a weighted scoring matrix for a reversible constant. Reads as rigor but is
   over-ceremony: penalized in Communication, flagged, and explicitly *not*
   rewarded in Insight depth (§ 3 cap).
9. **Burying the recommendation.** The number doesn't appear until paragraph
   three or is hidden inside prose. Fails the "first line" bar; Communication ≤ 3.
10. **Future-proofing as the lead reason.** Picking 100/200 primarily "to be
    future-proof" when there is one low-traffic internal client — premature
    generalization sold as foresight. Insight-depth and Correctness soft hit.

## 5. Headline finding for P6

P6 is the over-ceremony control. The hypothesis ladder (PARTY-TRACK-BRIEF § Design)
names the P6-specific outcome explicitly: **A4 < A1 on P6 → over-ceremony tax,
measurable.** This task is engineered to surface exactly that.

The expected contrast: the cheaper arms (A1 solo, and likely A3's single-pass
roundtable if it stays disciplined) produce a tight half-page call and win the
composite. The expensive machinery (A4 party mode, and A2 if its matched thinking
budget gets spent on a small question) is *structurally tempted* to convene a
roundtable, enumerate options, and produce a multi-page deliberation — which on
this task is pure cost with capped quality upside, so it **loses the composite
even if its prose scores a point higher on the raw vector.**

The clean finding: if A4's raw quality vector is within ~1 point of A1's but A4
costs 4–6× more and runs longer, the cost-weighted composite flips the ranking and
P6 demonstrates the over-ceremony tax as a number. The *opposite* finding is just
as publishable — if party mode recognizes the question is small, stays terse, and
matches A1's cost, that's evidence the machinery has a working right-sizing
instinct, and it's worth reporting that it did *not* over-ceremony where the design
predicted it would. Either way the discriminator is **cost-to-quality ratio on a
deliberately small question**, which no other task in the set isolates.

## § calibration

Cold-pass recall: TBD — filled during calibration.

Cold-pass notes to capture during calibration (rubric task, so "recall" = the
sanity checks below, not planted-item recall):
- A cold solo Opus 4.8 pass should land a single committed value, four sections,
  and stay ≤ 1 page. If the solo pass *also* over-ceremonies (multi-page), the
  brief's "don't overthink it / thirty-second standup" framing is too weak —
  strengthen it. If the solo pass omits a section, the deliverable spec is unclear.
- Record A4's observed length and implied USD first (it sets A2's thinking budget
  per protocol) — these two numbers also calibrate the cost-tax divisor and the
  ceremony-tax word thresholds in the overlay. **Lock the cost-tax divisor here
  after the first A1 and A4 runs** so the "6× cost for <1-pt quality flips the
  composite" intent holds; record the locked divisor and the A1/A4 reference
  spends.
- Target spread: this task should produce a *cost/length* spread across arms even
  if the quality vectors cluster — that clustering-with-cost-spread is the
  intended signal, not a calibration failure.

## § provenance

Not applicable — P6 uses no vendored repo or external code. `reference/situation.md`
is an original synthetic scenario authored for this task (a fictional internal
`GET /v1/orders` endpoint); all figures (payload size, query latency,
serialization cost, traffic, usage rates) are invented to be internally consistent
and sufficient to decide without being sufficient to justify a committee. No
license or upstream SHA to record.
