# P4 — Success Criteria (pv0.3) — Product discovery

P4 (`p04-product-discovery`, profile: **product / discovery**, **rubric-scored**,
no planted answer key). The deliverable is `discovery.md`: a discovery plan that
frames a vague activation problem, ranks hypotheses, names the riskiest
assumptions, and proposes the cheapest test for each.

Universal advisory rubric (anchors, scoring discipline, scrub protocol):
[`harness/party/scoring-rubric.md`](../../../harness/party/scoring-rubric.md).
This file declares P4's coverage checklist, which of the 5 dimensions are
load-bearing, task-specific 4-vs-5 detail, failure modes, and the headline
contrast. **Harness-only — never seeded into a cell.**

The substrate lives in `reference/problem.md`: a deliberately messy,
under-instrumented activation problem for "Stacklet," a no-code internal-tools
builder. It contains conflicting stakeholder theories (sales/support/power-users/
designer), a few trustworthy numbers, several explicitly-flagged unknowns, and
planted decoys. There is **no clean answer** — the quality signal is the reasoning
discipline, not a specific verdict.

---

## 1. Coverage checklist (rubric task — substantive treatment of each)

A competent `discovery.md` substantively covers all of the following. "Covered"
means engaged with reasoning, not name-dropped. Several map to traps in the
substrate (see § 3 / § 4).

- [ ] **C1 — Reframes the problem as activation, not signup or churn.** Locates the
  leak *after* signup and *before* paid (signup→app is >90%, paid churn is low
  single digits). A doc that treats this as a churn or top-of-funnel problem has
  misread the substrate.
- [ ] **C2 — Picks an apex/north-star metric for the problem.** Names the real
  outcome — a published tool *opened by a second person at the account* (a tool
  the team uses), not just "connected a data source" or "published anything."
- [ ] **C3 — Generates multiple distinct hypotheses and *ranks* them.** Not one pet
  theory; a ranked set with explicit reasoning for the ordering.
- [ ] **C4 — Engages all four stakeholder theories** (sales = onboarding/wizard;
  support = data-connection friction; power users = more power; designer = editor
  redesign) — and does not simply adopt the loudest. Treats the power-user "want
  more power" signal as a likely non-representative voice given the audience mix.
- [ ] **C5 — Separates the riskiest *assumptions* from the hypotheses.** A riskiest
  assumption is a belief the recommended direction *depends on* and that would hurt
  most if false — distinct from "which hypothesis is right."
- [ ] **C6 — Proposes a cheap, fast test per assumption** (days–two weeks, not a
  quarter build), with **explicit (in)validation criteria**: what result confirms
  vs. disconfirms.
- [ ] **C7 — Calls out the instrumentation gap** (no in-session event data) and
  treats "add lightweight analytics / watch real sessions" as a prerequisite or an
  early cheap step, not an afterthought.
- [ ] **C8 — Names at least one decoy correctly** (template selection-vs-causation
  confound; firewall/IP-allowlist tickets being a customer-side environment issue
  not a pure UX fix; the 4-day median meaning first session ≠ connection moment).

## 2. Which of the 5 dims are load-bearing for P4, and why

All five are scored 0–5 per the universal rubric. For P4 the **load-bearing** dims
— where the arms are expected to separate and where raters should spend attention —
are **Insight depth**, **Actionability**, and **Correctness**, in that order.

- **Insight depth (primary).** Discovery *is* the insight task. The substrate is
  engineered so the obvious reading (the loudest stakeholder is right) is probably
  wrong. A strong doc reframes the problem, spots the selection-vs-causation
  confounds, distinguishes assumptions from hypotheses, and weighs the
  "engineer-on-team correlates with success" signal without naively concluding
  "ship more engineer features." This is where a generic plan and a sharp one
  diverge most.
- **Actionability (primary).** The deliverable's whole point is a runnable cheap-
  test plan. Tests must be genuinely cheap and fast, each tied to an assumption,
  each with a falsification condition. Vague "do user research" fails here.
- **Correctness (load-bearing).** Discovery reasoning can be *wrong*: confusing
  correlation with causation, proposing a test that can't actually discriminate the
  hypotheses, mis-locating the funnel leak, or treating the template confound as
  settled evidence. Errors here are scored in Correctness even though there's no
  single right answer.
- **Coverage (supporting).** The checklist in § 1 is the coverage bar; engaging all
  four stakeholder theories and the named unknowns matters, but breadth without the
  reasoning discipline doesn't carry this task.
- **Communication (supporting).** Length band is ~2 pp; ranked hypotheses and an
  assumptions/test mapping should be scannable in one pass. Bloat (a 6-page
  research-ops plan) is penalized here per the length-band rule, not rewarded as
  coverage.

## 3. Task-specific scoring detail (4 vs 5 on the load-bearing dims)

### Insight depth
- **3:** At least one non-obvious move — e.g. correctly refuses to back the loudest
  stakeholder, or notes the template result is confounded.
- **4:** Several: reframes to the right apex metric (tool used by a 2nd person);
  catches that the 4-day-to-connect median means the *first session* is spent on
  something other than connecting (so "wizard to a quick win" may target the wrong
  moment); reads the engineer-correlation as "engineers route around our gaps," not
  "build for engineers"; cleanly separates assumption from hypothesis.
- **5:** A reframe that would plausibly change Priya's quarter — e.g. argues the
  real question is *which job the typical non-technical ops user is even hiring
  Stacklet for in that first session* and that the team is about to optimize a
  funnel for a user it hasn't characterized; or shows the four stakeholder theories
  are testable against *each other* with one or two shared cheap probes rather than
  four separate builds.

### Actionability
- **3:** A cheap test per assumption exists; mostly fast; some invalidation
  criteria present.
- **4:** Above + each test names what result validates vs. invalidates, rough effort/
  time, and what decision it unblocks; tests are ordered (instrument first, then the
  cheap qualitative probe, then the riskier bets).
- **5:** Above + explicit decision points and "what would change my mind" thresholds
  (e.g. "if ≥X of 8 watched sessions stall before the connect step, kill the editor-
  redesign hypothesis"); sequences tests so the cheapest disconfirming one runs
  first.

### Correctness
- **4:** No causal-inference errors; the proposed tests can actually discriminate
  the hypotheses they target; funnel leak correctly located; decoys not asserted as
  fact.
- **5:** Above + correctly handles the contested points — names the template
  selection bias *and* says how to de-confound it (e.g. hold-out / randomized
  template prompt), distinguishes the customer-side firewall issue from in-product
  UX, and qualifies the engineer-correlation as correlational.

## 4. Failure-mode characterization (observable ways a solver underperforms)

1. **Backs the loudest voice.** Adopts sales' "build a guided onboarding wizard" (or
   the designer's editor redesign) as the conclusion without testing it — the
   substrate is built to punish exactly this.
2. **Feature list, not discovery.** Produces a roadmap of features to build instead
   of hypotheses + cheap tests; ignores the explicit "I don't want a feature list."
3. **Hypotheses = assumptions conflated.** Treats "riskiest assumptions" as a
   restatement of the hypotheses rather than the load-bearing beliefs the chosen
   direction depends on. Collapses § Hypotheses and § Riskiest assumptions into one.
4. **No falsification criteria.** Tests are listed ("run user interviews," "look at
   the data") with no statement of what result would prove the hypothesis wrong.
5. **Expensive tests dressed as cheap.** Proposes a multi-week instrumentation
   build, a full redesign A/B, or a 30-person research study and calls it cheap.
   Misses same-week probes (watch 8–10 session recordings, 5 user interviews, a
   concierge/manual onboarding for 10 accounts, a fake-door / message test).
6. **Swallows the template confound.** Cites "template-starters activate better" as
   evidence that templates work, missing the selection-effect the doc explicitly
   flags, and proposing no way to de-confound it.
7. **Mis-locates the leak.** Frames it as a churn problem (paid churn is fine) or a
   top-of-funnel/marketing problem (signup→app is >90%), wasting the analysis on the
   wrong stage.
8. **Ignores the instrumentation gap.** Builds an elaborate hypothesis tree on data
   the doc says doesn't exist, without proposing to close the gap or noting the plan
   depends on data not yet collected.
9. **Treats firewall tickets as a pure UX fix.** Proposes redesigning the connection
   UI for what the doc flags as customer-side network/allowlist problems, without
   distinguishing the two failure types.
10. **Naive engineer-correlation read.** Concludes "successful accounts have
    engineers, therefore build engineer features" — inverting the likely causation
    (engineers succeed *despite* the product's gaps; the non-technical majority is
    the actual problem to solve).
11. **Wrong apex metric.** Optimizes "connected a data source" or "published a tool"
    rather than "a tool a second person at the account opens," over-counting vanity
    activation.
12. **Bloat.** A 5–6 page research-ops document that buries the ranked hypotheses and
    the one-week test plan — volume sold as rigor (penalized in Communication).

## 5. Headline finding (the contrast this task is designed to reveal)

P4 tests whether multi-persona deliberation produces sharper *discovery reasoning*
than a solo pass — specifically the discipline to (a) refuse the loudest stakeholder,
(b) separate riskiest assumptions from hypotheses, and (c) propose cheap,
falsifiable tests. The plausible party-mode story is that an explicit PM/analyst/
designer roundtable surfaces the selection-vs-causation confounds and the
"non-technical-majority vs engineer-minority" reframe that a one-shot might glide
past — i.e. the personas earn their seat by adversarially checking each other's
pet theory. The plausible masquerade story is that a single Opus pass, *or* a
one-prompt roleplay roundtable (A3), already does all of this and the machinery
adds tokens and persona dialogue but no new insight. Watch especially whether the
party-mode transcript's designer persona simply *re-asserts* the editor-redesign
theory (mirroring the substrate's designer) versus whether the roundtable
disciplines it into a testable, rankable hypothesis. If A4 reliably catches the
template confound and the engineer-correlation inversion while A1 does not, that's
a real per-profile win for discovery; if A1/A2/A3 match it, discovery is another
profile where personas are theater.

## calibration

Cold-pass recall: TBD — filled during calibration. (Rubric task: log a cold solo
Opus 4.8 pass's per-dimension scores and, in particular, whether it backs the
loudest stakeholder, separates assumptions from hypotheses, and catches the
template + engineer-correlation decoys. If the cold solo pass nails all of § 1 and
all decoys, P4 is under-discriminating and the substrate needs a subtler trap; if it
misses the basic reframe, it may be over-hard. Target a mid-band solo pass that
leaves visible headroom on Insight depth and Actionability.)

## provenance

N/A — substrate is original, fully synthetic ("Stacklet" is fictional). No vendored
repo, no external corpus, no third-party material. No license obligations.
