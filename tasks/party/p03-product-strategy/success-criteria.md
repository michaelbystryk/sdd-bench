# P3 — Success Criteria (pv0.3) — HARNESS-ONLY, never seeded

P3 (`p03-product-strategy`, profile: product/strategy, **rubric-scored**) scoring
overlay. Applied after a cell completes; identical across all four arms (A1 solo / A2
matched-thinking / A3 persona-prompt / A4 party mode).

Universal advisory rubric (5 dims, anchors, scrub, unblinding):
[`harness/party/scoring-rubric.md`](../../../harness/party/scoring-rubric.md). This file
declares the P3 coverage checklist, which of the 5 dims are load-bearing, task-specific
4-vs-5 detail, failure modes, and the headline contrast.

This is a **rubric task — no `answer-key.md`, no objective-recall axis.** But the signal
pack in `reference/` is engineered with a known signal/noise structure, so § 1 below is a
*coverage + discrimination checklist* the raters apply: it names the real signals a strong
memo must converge on and the deliberate red herrings a strong memo must discount. It is
NOT a planted-truth key (nothing is scored found/partial/missed); it is the rater's map of
what "separated signal from noise" looks like for this specific pack.

---

## 1. Coverage + discrimination checklist (what the signals actually add up to)

The pack is built around one durable strategic truth, one under-valued asset, and three
engineered distractors. A memo's quality on Correctness / Insight / Coverage is largely
its handling of these six items. Raters check each as **converged / partial / missed**
for note-taking (this drives the dim scores; it is not a published recall fraction).

### Real signals (a strong memo converges on these)

- **S1 — The reconciliation / ERP-sync gap is the churn driver and the durable bet.**
  Three of five real churns (Northwind, Greenfield, Tindall-trending) name ERP re-keying
  as the deciding factor (`churn-notes.md`); it's the largest support theme (98 tickets,
  `support-tickets.md`); the mid-market sales cluster converges on it (`sales-asks.md`);
  the competitor who beats us has it and the category is consolidating around "close the
  loop into the ERP" (`competitor-moves.md`). **We lose on the back-end handoff, not the
  front end.** A memo that doesn't center this is reading the pack shallowly.

- **S2 — Approval routing is the actual moat / retention engine and is under-invested.**
  `usage-stats.md`: routing has the strongest positive retention correlation, drives
  expansion (Orsino), survived controlling for account size; it's the #1 reason accounts
  stay and the feature we lead competitors on (`competitor-moves.md`, churn notes). It is
  *under-instrumented and under-invested relative to the retention it drives.* The
  non-obvious move: routing is both a defensive moat to deepen AND the wedge that earns
  the right to win the back-end. A memo that treats routing as "done / fine" misses it.

- **S3 — The CSV-export "usage" is pain, not love (the inverted-metric read).** 81% of
  accounts use CSV export, which looks like an engaged feature — but it correlates
  *negatively* with retention because it's the manual-pain surface, not a value surface
  (`usage-stats.md`). High usage here is a churn predictor, not a strength. A memo that
  cites the 81% as a positive, or proposes "improve CSV export" as the fix instead of
  killing the need for it (native sync), has misread the signal.

### Red herrings (a strong memo explicitly discounts these — naming WHY is the insight)

- **R1 — The enterprise cluster (Atlas/Meridian) is loud-but-tiny and off-strategy.**
  Loudest in pipeline meetings, biggest projected ARR, heaviest requirements (SOC 2,
  SSO, SCIM, vendor portal). But: projected (not signed), procurement-led with **no
  finance champion**, stalled 2+ quarters, two maybes (`sales-asks.md`, VP annotation;
  tickets T-2295/96/2331). Building the enterprise feature set for them pulls eng away
  from the mid-market ICP where the money actually is. A memo that prioritizes
  SSO/SOC2/vendor-portal for H2 has been captured by volume. **Strong handling: name it,
  put it on the kill-list / explicitly decline or defer, and say why (no champion,
  unsigned, off-ICP).** (Subtle nuance: SOC 2 may be defensibly worth doing as a low-cost
  trust/table-stakes item for the *mid-market* too — a sophisticated memo can distinguish
  "do SOC 2 cheaply for ICP trust" from "build the enterprise portal/SCIM stack." Either
  a clean decline or that nuanced split scores well; uncritically chasing the enterprise
  deals does not.)

- **R2 — "Total invoices processed +34% QoQ" is a vanity metric.** `usage-stats.md`
  states plainly that ~38% is one whale (Vantage) auto-importing and ~22% is free-tier
  accounts where no human approves; real paying-mid-market approved volume grew ~6%, not
  34%. A memo that leads with or celebrates the 34% (or treats volume growth as evidence
  the strategy is working) has swallowed the vanity metric. **Strong handling: explicitly
  discount it and use the ~6% real figure / the flat NRR as the true state.**

- **R3 — Competitor B's "AI Spend Copilot" is a buzzy off-persona distraction.**
  Loud launch, TechCrunch, sales is nervous, two prospects asked about it — but it serves
  **FP&A / CFO-office analytics buyers, not AP operations**, sits on already-categorized
  data, and doesn't touch invoice intake/approval (`competitor-moves.md`). Chasing it is a
  late feature race for a different buyer and job-to-be-done, away from where Lumen wins.
  A memo that adds "AI spend copilot / AI categorization" as a bet to keep up with
  Competitor B has chased the shiny thing. **Strong handling: name the temptation and
  decline it on buyer/JTBD grounds (kill-list).** (Note: a *small*, on-AP-workflow AI
  assist — e.g. AI to suggest GL coding to feed the ERP sync, or smarter OCR — can be
  legitimate and is NOT the red herring; the red herring is the FP&A-analytics copilot
  race. Reward memos that draw that line.)

### Implicit considerations a senior reviewer expects (lift toward Coverage 4–5)

- The **two-bets capacity constraint** is real and binding (`context.md`): a memo
  proposing 4–5 fully-resourced bets violates it; the strong move is ≤2 *meaningful* eng
  bets with smaller items sequenced behind or done cheaply.
- The **routing→sync sequencing logic**: routing is the retained wedge that should be
  deepened first/in-parallel to defend the base while the (larger) sync bet lands; doing
  sync alone while a competitor matches our Slack approvals (Bellweather risk) is exposed.
- **Activation insight** (`usage-stats.md`): conditional-routing-rule setup in first 14
  days predicts 6-month retention — an onboarding/activation lever distinct from net-new
  features. Surfacing it is a Coverage-5 / Insight signal.
- **Which ERP first?** NetSuite vs. Sage Intacct vs. QuickBooks — the pack names all;
  a strong memo picks a sequence with a reason (NetSuite + Intacct appear most in
  churn/asks) rather than hand-waving "integrate with ERPs."

---

## 2. Load-bearing dimensions for P3 (and why)

All five are scored. Three are **load-bearing** — they carry the signal this task exists
to measure:

- **Insight depth (dim 3) — PRIMARY.** The whole task is signal-vs-noise separation under
  contradictory inputs. The discriminating moves are non-obvious: reading CSV-export usage
  as *negative* (S3), discounting the +34% vanity metric (R2), declining the loud
  enterprise pipeline (R1), refusing the off-persona AI race (R3), and seeing routing as
  both moat and wedge (S2). A memo can be well-written and well-organized and still score
  2 here if it takes every loud signal at face value. This is where the arms should
  separate most.

- **Actionability / decision quality (dim 4) — PRIMARY.** The brief explicitly demands
  named bets, an explicit kill-list, and sequencing under a hard two-bet constraint. "Be
  willing to say no" is the request. A memo with no real kill-list, or one that lists 5+
  bets, fails the decision the brief asked for regardless of prose quality.

- **Correctness (dim 1) — load-bearing.** Strategy memos are "wrong" mostly by misreading
  the evidence: citing the 34% as growth, calling CSV export a strength, treating the
  enterprise ARR as real money. A factually-careful memo qualifies these correctly.

**Coverage (dim 2)** and **Communication (dim 5)** are scored but secondary: the brief
fixes the sections and a competent solver will hit them; they discriminate at the top end
(does it surface the activation lever, the ERP-ordering question, the Bellweather/Slack
exposure — Coverage 4–5; is it tight and director-forwardable — Comms 4–5) and punish
bloat (a 6-page memo that exceeds the ~2–3pp band loses Communication, not Coverage).

## 3. Task-specific 4-vs-5 detail (per load-bearing dim)

**Insight depth.** 3 = converges on the reconciliation bet (S1) and isn't fooled by at
least one red herring. 4 = handles most of S1–S3 correctly AND explicitly discounts ≥2 of
R1–R3 *with the right reason* (not just omitting them — naming why they're noise). 5 = all
of the above PLUS at least one genuine reframe: e.g. routing-as-wedge-into-sync (S2), or
the activation insight as a retention lever, or seeing that "close the loop into the ERP"
reframes Lumen from an OCR/routing tool into the AP-record-of-truth — a framing that would
change where the company invests.

**Actionability.** 3 = concrete bets, a kill-list exists, some sequencing. 4 = ≤2
meaningful eng bets (honors the constraint), kill-list has reasons, sequencing names what
gates each step, costs/risks of the bets stated. 5 = above + explicit success measures
(e.g. "NRR back above 105%", "reconciliation-driven churn → 0 over 2 quarters"),
decision/kill points, and what-would-change-my-mind conditions (e.g. "if a signed
enterprise deal with a finance champion appears, revisit the portal").

**Correctness.** 3 = no claim contradicts the pack; conclusions sound. 4 = the
evidence-traps (34% vanity, CSV-as-pain, projected vs signed ARR) are all handled
correctly and claims are appropriately qualified. 5 = above + correctly handles the
contested calls a competent strategist could get wrong — e.g. distinguishing "SOC 2 cheap
for ICP trust" from "the enterprise portal stack," or "small on-workflow AI" from "the
FP&A copilot race," rather than treating each as all-or-nothing.

## 4. Failure-mode characterization (concrete, observable; for observations.md)

1. **Pipeline capture.** Prioritizes the enterprise asks (SSO/SOC2/vendor portal) because
   they're the loudest / biggest projected ARR — misses that they're unsigned,
   champion-less, off-ICP (R1). The dominant "took the loud signal at face value" failure.
2. **Vanity-metric swallow.** Cites "+34% invoices processed" as evidence of momentum or
   strategy working; doesn't strip the whale + free-tier noise to the real ~6% (R2).
3. **Shiny-object chase.** Adds an "AI spend copilot / AI categorization" bet to keep pace
   with Competitor B, ignoring that it's a different buyer and JTBD (R3).
4. **CSV-export misread.** Treats 81% CSV-export usage as engagement/strength, or proposes
   "make CSV export better" rather than removing the need via native sync (S3 inverted).
5. **No real kill-list.** "Kill-list" section is empty, hedged ("monitor enterprise
   demand"), or just repeats lower-priority bets. Fails the brief's explicit ask.
6. **Five-bet sprawl.** Lists 5–7 bets with no acknowledgment of the two-bet capacity
   constraint; "a list of seven priorities is the same as no strategy" (brief's own line).
7. **Summary-not-strategy.** Restates each reference file in turn (a tour of the inputs)
   instead of synthesizing what they add up to — the brief explicitly says "I don't want a
   summary." Scores low on Insight even if Coverage looks full.
8. **Routing treated as done.** Centers only the sync bet; misses that routing is the
   retention moat to deepen and the wedge (S2), and the Bellweather/Slack-approval
   competitive exposure if a rival matches it.
9. **Hand-wavy sequencing.** "First do X, then Y" with no gates, no ERP-ordering choice
   (NetSuite/Intacct/QuickBooks), no success measure — Actionability stalls at 3.
10. **Bloat.** Exceeds the ~2–3pp band with a long files-walkthrough preamble; loses
    Communication and often buries the actual recommendation past where a director reads.
11. **False precision / hallucinated data.** Invents numbers not in the pack (a TAM, a
    churn % we didn't give) and reasons from them — a Correctness hit; note any such
    invented figures in observations.md as the rubric-task analog of a precision miss.

## 5. Headline finding for P3

P3 is the cleanest **insight-under-noise** test in the product profile. The pack is built
so that the *loud* signals (enterprise pipeline, +34% volume, the AI-copilot buzz) all
point the wrong way, and the *durable* signal (reconciliation gap + routing moat) is
quieter and must be assembled across four files. The contrast this task is designed to
reveal:

> Does multi-persona deliberation (A4 party mode) actually *discount the loud-and-wrong
> signals better* than a solo pass (A1)? A skeptical "wait, is that 34% real / is that
> enterprise ARR signed / is that copilot even our buyer?" is exactly the kind of
> challenge a roundtable claims to add. If party mode's personas surface the red herrings
> and a solo pass swallows one or more, that's a real point for the machinery on strategy
> tasks. If A1 (or the A3 masquerade) catches them just as well, the personas are theater
> here. The reverse risk is also live: a roundtable may *over-deliberate* — produce five
> bets to satisfy every persona's pet concern, violating the two-bet constraint and the
> kill-list ask, where a solo pass stays decisive. Both outcomes are publishable; the
> kill-list + bet-count is the sharpest single per-cell discriminator.

## calibration

Cold-pass recall: TBD — filled during calibration. (Target a 3–8 spread on the six
checklist items S1–S3 / R1–R3 converged-or-discounted for a cold solo Opus 4.8 pass; if a
cold pass nails all six or misses all six, re-tune the loudness of the red herrings vs.
the discoverability of S1–S3. Suspected easiest: S1 reconciliation. Suspected hardest: S3
CSV-export-as-negative and the nuanced R1/R3 splits.)

## provenance

N/A — P3 is rubric-scored with a fully synthetic signal pack (no vendored repo/source).
The Lumen company, accounts, numbers, tickets, and competitors are invented for this task;
any resemblance to a real AP-automation vendor is coincidental.
