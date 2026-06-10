# Lumen Analytics — Q3 2026 Roadmap

*Prepared for the Friday planning review. Built by reading the candidate backlog
and the quarter's constraints **together** — not by sorting on the value/effort
columns. Where the two disagree, the constraints win.*

---

## Method

The naive method the head of product was burned by — "sort by value, then by
effort, draw a line" — fails here for one reason: **these 25 items are not
independent.** Several are written against infrastructure that doesn't exist
(no identity service), one is written against infrastructure that's being
demolished mid-quarter (Streamflow), and one is a compliance breach disguised
as a 4-week feature (EU export on the US cluster). A flat ranking treats them as
interchangeable line items you can reorder freely. You can't. So the lens is:

1. **Capacity is the real cut-line, and it's ~44 ew, not 78.** `[ASSUMPTION]`
   Net build capacity after the haircut the constraints describe:
   `78` nominal (6 eng × 13 wk) − `13` on-call drag (2 eng at ~50% throughput on
   backlog) − `9` summer PTO (~1.5 wk × 6) − `11` (20% support/KTLO on the
   remainder) ≈ **44 ew**. Plan to 44; don't commit past 46. The backlog sums to
   ~104 ew — this is a **2.3×** over-subscription, so roughly half the list is cut
   before any item is judged on merit.

2. **The immovable date dominates the calendar.** SOC 2 Type II evidence must be
   frozen and in production by **8 Sep (~week 10)**. Missing it slips the audit a
   full quarter to December, and enterprise deals are *contractually* waiting on
   it. This is sequenced first and given schedule buffer — not fit in around the
   demos.

3. **Resolve chains and landmines before ranking.** Each item was tested for:
   *does it depend on something not on the list?* (identity service, audit
   pipeline), *can it ship as written?* (Streamflow, EU residency), and *is its
   effort estimate honest?* Three "High value" items turned out to be mirages and
   two unglamorous "Med" items turned out to be load-bearing.

4. **Adjudicate stakeholder pressure with evidence, not volume.** Sales (SSO),
   leadership (AI summaries), and growth (Slack + onboarding) each have a
   favorite. They compete for the ~30 ew left after the non-negotiables — and
   there is not room for all three at full scope. Each wins or loses on leverage
   and evidence, documented below so the cut is defensible line-by-line.

The two secretly load-bearing items the naive ranking misses: **BL-11**
(structured audit pipeline — the SOC 2 dashboard is theater without it) and
**BL-03** (identity service — SSO, bulk import, session controls, and a
trustworthy DSAR export all silently assume it). Both are ranked "Med" because no
customer asks for them by name. That is exactly the trap.

---

## Sequenced plan

Committed work ≈ **37 ew**, holding ~7 ew as deadline buffer / swing capacity.
Work runs as three parallel streams (Compliance, Identity, Standalone), not a
single serial stack. "When" is expressed in quarter-thirds; **the only hard date
is the 8 Sep freeze at week 10.**

| Item | When | Why it sits here |
|---|---|---|
| **BL-11** Structured audit-log pipeline (5) | **Wks 1–3** | Front-loaded on purpose. A Type II audit needs structured events accumulated over an *observation window* before the freeze — finishing this at week 10 is too late. Hard prerequisite for BL-02. |
| **BL-16** Slack alerting (4) | Wks 2–5 | Best raw value-per-ew on the board: High value, cheap, fully standalone, no scaffolding. Growth's retention bet. Runs parallel on a freed engineer while the compliance chain builds. |
| **Access-snapshot slice** (~3, part of SOC 2) | Wks 3–6 | A consolidated, point-in-time read view over today's ad-hoc role/team tables, snapshotting daily. Gives BL-02 *defensible* access-control evidence without waiting for full BL-03. Must be in prod snapshotting by ~wk 7. Also a down payment on BL-03's schema. |
| **BL-03** Identity & user-directory service (6) | Wks 3–8 | The spine. Seeded by the access-snapshot schema. Must precede SSO / bulk import / session controls. Ranked "Med" but everything enterprise hangs off it. |
| **BL-08** Query result caching (3) | Wks 4–7 | User-facing p95 win; the one genuinely customer-facing half of the platform lead's pairing. Parallelizable. |
| **BL-02** SOC 2 evidence dashboard (5) | Wks 6–9 · **FROZEN wk 10 / 8 Sep** | The deadline gate. Collates from BL-11 + the access snapshot. ~1 week of buffer before the freeze, deliberately. |
| **BL-04** SAML SSO for enterprise (5) | Wks 8–12 | Sales' loudest ask. Sits on BL-03; the durable version is identity-spine-plus-SSO, not a standalone login. Lands late in the quarter — by design, after the audit is safe. |
| **BL-19** Bulk user import CSV (3) | Wks 10–11 | Enterprise onboarding ask that *rides the identity backbone already built* — the cheap, dependency-aligned onboarding win. |
| **BL-25** Admin SSO session controls (3) | Wks 12–13 | Enterprise security reviewers ask for it alongside SSO; rides BL-04. Completes the enterprise-readiness story. |
| **Buffer / swing** (~7) | Wks 10–13 | Protects the 8 Sep deadline first. If it holds, pull in (in order): **BL-22** GDPR/DSAR export, then **BL-13** onboarding checklist. See risks. |

**The shape of the quarter:** an enterprise-readiness quarter. SOC 2 + identity +
SSO + session controls is one coherent story — "Lumen is safe to buy at
enterprise scale" — and it's the story the contracted deals are actually waiting
on. The splashy items are not in it, on purpose.

---

## Cut-line — what we are explicitly NOT doing, and why

Each cut has a one-sentence defense for the skeptical room.

- **BL-07 Real-time live dashboards (High, 6) — CUT.** Built on Streamflow, which
  stops new channel provisioning 1 Aug and shuts down entirely 30 Sep — *inside
  this quarter.* Every week spent ships a feature that breaks before Q3 closes.
  *"We won't burn six weeks on a feature whose only foundation is demolished
  before the quarter ends — the Q3 item here is scoping the streaming
  replacement, not building on a corpse."* The prospects asked for live
  dashboards, not for Streamflow; that capability returns in Q4 on a new layer.

- **BL-23 AI insight summaries (High, 6) — CUT from commit.** Leadership's splashy
  pick, but LLM summaries over analytics data with no eval harness, no
  hallucination guardrails, and no feedback loop is a liability with a demo skin;
  the "6" is the happy-path estimate. *"Splashy and shippable are different
  words — we can wow a demo or close the SOC 2 deals, not both this quarter."* If
  leadership wants it, fund a timeboxed spike out of buffer, not a committed
  feature.

- **BL-09 EU residency reporting region (Med, 4) — CUT as written.** As specified
  it runs the EU customer-usage export on the us-east cluster, which is a
  **data-residency breach** — a deal-losing event, not a feature. The correct
  version (stand the job up *inside* eu-central) is net-new region infra
  realistically **8–10 ew**, not 4. *"The line item is for the illegal version;
  the legal version is twice the size and doesn't fit a compliance-critical
  quarter — it's a sized Q4 item."* **Hard stop: do not let the us-east version
  ship.**

- **BL-10 Custom metric formulas (High, 7) — CUT / defer to Q4.** Genuinely
  valuable and the only High-value item cut with no infra problem — but 7 ew is
  ~16% of net capacity with no deadline or dependency leverage, in a quarter
  already owned by two non-negotiable chains. *"Real value, wrong quarter — it's
  the strongest Q4 candidate."*

- **BL-21 Legacy v1 chart-renderer rewrite (Low, 8) — CUT.** *"Eight weeks — 18%
  of the quarter — to serve two accounts we should be sunsetting, not
  rebuilding."*

- **BL-20 API rate-limit dashboard (Med, 3) — CUT; unbundled from BL-08.**
  Internal/ops observability, not a customer outcome. *"We kept the customer-
  facing half of the pairing (caching) and cut the internal half."*

- **BL-13 / BL-15 Onboarding checklist + drip (Med, 4+4) — BELOW THE LINE.**
  Softer-evidence retention work; BL-15 also depends on BL-13. BL-13 is the first
  swing item after BL-22 if buffer holds. *"Funded against an activation metric,
  not vibes — and not at the expense of the deadline."*

- **BL-14 Mobile-responsive (Med, 5) — CUT.** *"B2B analytics is a desktop job;
  five weeks for a context our buyers don't work in."*

- **BL-05 Scheduled CSV email (3), BL-12 Audit export/search UI (4), BL-06 Dark
  mode (2), BL-24 High-contrast (2), BL-17 Status page (2), BL-18 i18n (3) —
  CUT.** Real, but none unblock a deal or the deadline. Two watch-items:
  **BL-24** is *not* Low if any deal carries a VPAT/accessibility clause — check
  before final cut; **BL-12** becomes a cheap rider once BL-11 exists and is the
  natural first add in a future quarter.

---

## Dependencies & risks called out

**1. The SOC 2 chain is ~13 ew, not 5 — and it must start in week 1.**
The dashboard (BL-02) is theater without the structured audit pipeline (BL-11):
today's audit events are unstructured stdout logs with no schema and no retention
guarantee, which no Type II auditor will accept. The reconciled cost is
**BL-11 (5) + BL-02 (5) + a ~3 ew access-snapshot slice = ~13 ew.** The
slice — a consolidated, point-in-time read view over the existing ad-hoc
role/team tables — gives defensible "who has access to what" evidence *without*
blocking on the full identity service. **Risk:** BL-11 and the snapshot must be
in production *early* (BL-11 by ~wk 3, snapshot by ~wk 7) so structured evidence
accumulates over a real observation window before the 8 Sep freeze. Treat the
snapshot start date as a hard internal milestone — slipping it quietly degrades
evidence quality and reopens the argument for pulling all of BL-03 forward.

**2. BL-03 identity service is the spine under the whole enterprise story.**
SSO (BL-04) is written as "resolve each login to a Lumen role and team
membership" — against a source of truth that doesn't exist. BL-25 (session
policy), BL-19 (bulk import), and a *trustworthy* BL-22 (DSAR export needs an
authoritative tenant→user map) all silently assume it too.
**Chain: BL-03 → BL-04 → BL-25**, with BL-19 and BL-22 hanging off BL-03.
Skipping BL-03 doesn't save the 6 ew — it spends them building a throwaway
identity shim inside the SSO feature that gets ripped out next quarter. The
honest framing for sales: **"SSO this quarter" means "the identity backbone this
quarter, SSO landing late in it"** (~11 ew combined, not the sticker 5).

**3. Two silent landmines that ship *wrong* if nobody looks.**
- **EU residency (BL-09):** the spec itself is the bug — running EU raw records
  on us-east is a contractual breach. Don't ship the written version at all.
- **Streamflow (BL-07):** building anything new on it is throwing the work away;
  the vendor is gone by quarter-end. The reclaimed 6 ew is the easiest capacity
  on the board.

**4. Honest pairings, honest un-pairings.**
- **BL-08 + BL-20** *was* sensibly paired (shared query-path metering) but only
  BL-08 is customer-facing — keep BL-08, cut BL-20.
- **BL-13 → BL-15** is a true ordering constraint: the drip emails "based on how
  far through setup a user got," a signal *produced by* the checklist. Never
  fund BL-15 without BL-13 first.

**5. The one input that could reopen a cut.** `[ASSUMPTION]` This plan assumes
**no single named, contracted deal dies this quarter without live dashboards
(BL-07) or AI summaries (BL-23).** If such a deal exists, name it and we reopen
*that one item only* — for BL-07 that means a streaming-replacement spike, not
new Streamflow work, since the vendor still goes dark on 30 Sep regardless.

**6. Buffer discipline.** The ~7 ew held back exists to protect the 8 Sep
deadline, which has zero tolerance. It is *not* a place to quietly re-admit BL-07
or commit BL-23. If the compliance chain lands clean, spend it in order:
**BL-22 (DSAR — a real EU obligation, needs BL-03 done first) → BL-13
(onboarding checklist).** `[ASSUMPTION]` EU DSAR demand is a genuine obligation
but not pinned to a hard date this quarter; if a regulator or signed SLA pins it,
it moves above the line and displaces the latest-sequenced swing item.
