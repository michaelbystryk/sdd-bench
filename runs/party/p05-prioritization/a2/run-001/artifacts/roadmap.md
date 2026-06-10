# Lumen Q3 2026 Roadmap

A sequenced quarter plan with an explicit cut-line. The short version: two
non-negotiable commitments — the **SOC 2 audit** and **enterprise SSO** — eat the
spine of the quarter, and both have hidden infrastructure prerequisites that the
raw value/effort columns hide. Sequence around those, fund a few high-leverage
wins in the gaps, and cut hard everywhere else.

---

## Method

**The lens.** I did not sort by value, then effort, then draw a line. I sorted by
a different question: *what does this quarter actually have to be true at the end
of it, and what has to happen first for each of those things to be deliverable?*
Three rules, applied in order:

1. **Deadlines and undeliverables outrank value.** A High-value item that can't
   physically ship this quarter is worth zero this quarter. A Med-value item that
   gates a hard external date is worth more than its rating. So the first pass was
   not "what's valuable" but "what's *forced* (a fixed date) and what's
   *impossible* (the platform won't support it)." Those two categories set the
   skeleton before value enters the conversation.
2. **Buy the foundation before the feature.** Several backlog items are written as
   if infrastructure exists that doesn't. Where a headline feature sits on missing
   plumbing, I cost the plumbing into the feature and sequence it first. A naive
   ranking double-counts capacity it doesn't have, because it schedules the
   feature and silently assumes the foundation is free.
3. **Value/effort breaks ties, not commitments.** Only *after* the forced and
   foundational work is placed does the value-per-engineer-week sort decide what
   fills the remaining capacity.

**The capacity number I planned against.** Headline is 6 engineers × 13 weeks =
78 ew. That number is a trap. Netting out the haircuts the constraints spell out —
~20% of every week lost to on-call, support escalations, and keeping-the-lights-on
work, plus a real summer-PTO bite across Q3 — leaves meaningfully less.
**[ASSUMPTION]** I planned against **~50 ew of realistic build capacity**
(78 → ~62 after the 20% operational haircut → ~50 after ~12 ew of summer PTO
across the squad). I then **committed only ~40 ew** and held the remaining ~10 ew
as a ranked stretch tier and incident buffer — because the haircut is a range, not
a guarantee, and the one thing I will not do is over-commit a quarter that has an
immovable audit date in it.

This produces a plan in tiers: a non-negotiable **compliance spine**, an
**enterprise-unlock chain**, a set of **high-value independent wins**, an
**onboarding pair**, and a ranked **stretch tail** that flexes with the real
haircut.

---

## Sequenced plan

Capacity is run as ~2–3 parallel tracks, not one queue. "When" is the phase in
the quarter the work lands in; the ordering *within* a track is driven by the
dependencies in the last section. Effort is the backlog's own ew estimate.

| Item | Title | When | ew | Why here |
|---|---|---|---|---|
| **BL-11** | Structured audit-log pipeline | **Early** (start wk 1) | 5 | The load-bearing item on the whole board. The SOC 2 evidence dashboard cannot be built on today's unstructured stdout logs. This is the foundation under the one date that doesn't move; it starts week 1. |
| **BL-03** | Identity & user-directory service | **Early→Mid** (start wk 1) | 6 | The foundation under SAML SSO and three other items. Nothing today authoritatively knows a user's role or team. Start week 1 in parallel so SSO isn't blocked in the back half. Also strengthens the access-control evidence for the audit. |
| **BL-16** | Slack alerting integration | **Early** (wks 1–4) | 4 | Highest-leverage retention bet on the list (growth PM), High value, no dependencies. Ship a customer-visible win early while the foundations bake. |
| **BL-02** | SOC 2 evidence dashboard | **Mid** (wks 4–8) | 5 | The audit deliverable. Built on BL-11. **Must be in production by ~wk 10 (8 Sep).** Front-loaded with a 2-week margin before the freeze — deliberately, because missing it slips the audit a full quarter. |
| **BL-04** | SAML SSO for enterprise tenants | **Mid** (wks 5–9) | 5 | The sales-loud, deal-gating feature. High value. Starts as BL-03 lands so logins have a real role/team to resolve to. |
| **BL-08** | Query result caching | **Mid** (wks 4–7) | 3 | Cheap, broad p95 win that benefits every dashboard — including the new ones we're shipping. Platform lead wants it. |
| **BL-01** | Saved-view sharing | **Mid** (wks 5–9) | 4 | High value, modest effort. "Share with teammates" needs the team-membership model from BL-03, so it starts once that's near-done. |
| **BL-13** | Onboarding checklist (in-app) | **Late** (wks 9–12) | 4 | Growth bet. Builds the first-run completion-state signal that the email drip then consumes — so it ships first. |
| **BL-15** | Onboarding email drip | **Late** (wks 11–13) | 4 | Growth bet. Nudges users through unfinished setup *based on BL-13's progress data.* Designated release valve: if the haircut bites harder than planned, this slips to early Q4 without breaking any commitment. |
| | **— Committed total —** | | **40** | |
| *BL-25* | *Admin SSO session controls* | *Stretch (late)* | *3* | *Rounds out the enterprise-security story the same deals ask for; sits on BL-03/BL-04.* |
| *BL-20* | *API rate-limit dashboard* | *Stretch (mid)* | *3* | *Pairs with BL-08 per the platform lead; customer-facing transparency on performance.* |
| *BL-19* | *Bulk user import (CSV)* | *Stretch (late)* | *3* | *Small, frequent enterprise-onboarding ask; sits cleanly on BL-03 once it exists.* |

**Stretch tier (~9 ew):** committed *in this ranked order* only as the real PTO/
incident picture confirms capacity above 40 ew. They are genuine intentions, not
filler — but I will not promise them on Friday.

---

## Cut-line

Everything below is explicitly **not** in the Q3 commitment. Each cut is
defensible on its own terms.

**Cut because it cannot ship as written this quarter (not a priority call — a
feasibility one):**

- **BL-07 Real-time live dashboards (High, 6).** This is the painful one. It
  demoes beautifully and prospects asked for it by name — and it is built on
  **Streamflow, which stops provisioning new channels on 1 Aug and shuts down
  entirely on 30 Sep.** Anything we build on it this quarter is dead before the
  quarter ends, and the replacement streaming layer isn't chosen, isn't built, and
  isn't on this backlog. **Recommendation:** pull it now, scope "choose + build the
  streaming replacement" as a separate Q3/Q4 initiative, and revisit the feature in
  Q4. Committing it would be committing throwaway work.
- **BL-09 EU residency reporting (Med, 4) — cut *as written*.** The description
  runs the EU export job on the **us-east** primary cluster. EU personal data must
  be stored and processed **only in eu-central**, and there is deliberately no
  cross-region replication — so the data isn't even reachable from us-east, and
  running it there would be a deal-losing compliance breach. The title says
  "residency"; the description does the opposite. **[ASSUMPTION]** The honest
  version — standing the job up *inside* eu-central, where the plumbing doesn't yet
  exist — is materially more than the 4 ew estimate (which assumed reusing us-east).
  **Recommendation:** send back for re-scope and re-estimate; do not schedule the
  4-ew version.

**Cut on value-vs-capacity (defensible priority calls):**

- **BL-23 AI insight summaries (High, 6) — defer to Q4, recommend as the Q4
  headline.** Leadership's favorite, and I'm cutting it anyway: it has *no deadline
  and no dependency forcing it into Q3*, while the two things that do (the audit and
  SSO) are both contractually gating deals. AI summaries are the strongest thing to
  *lead* Q4 with — fresh capacity, no spine work competing. Holding it is the
  opinionated call the planning review should hear out loud.
- **BL-10 Custom metric formulas (High, 7).** Genuinely valuable, but 7 ew (the
  largest discretionary item) and a formula mini-language carries real scope risk.
  Nothing forces it into a quarter already dominated by two hard commitments. Q4.
- **BL-14 Mobile-responsive layout (Med, 5).** Med value at high effort, no
  dependency, no deadline. Doesn't clear the bar this quarter.
- **BL-22 Per-tenant data export / GDPR (Med, 4).** Compliance-flavored but **not**
  tied to the 8 Sep audit, and for EU tenants it inherits the same eu-central
  residency constraint as BL-09 (flagged below). Q4, after the residency question
  is settled.
- **BL-12 Audit-log export & search UI (Med, 4).** Becomes a cheap, natural
  fast-follow once BL-11 exists, but it's customer-facing admin search — **not**
  audit-critical. First thing to pull forward in Q4.
- **BL-05 Scheduled CSV report email (Med, 3).** Fine, independent, unforced. Below
  the line.

**Cut as clear low-value / easy calls:**

- **BL-21 Legacy v1 chart-renderer rewrite (Low, 8).** The worst value/effort on
  the board — 8 ew to serve **two** remaining customers. Migrate those two off v1;
  don't rewrite the engine. Hard cut.
- **BL-06 Dark mode (2), BL-24 High-contrast (2), BL-17 Status page (2),
  BL-18 i18n number/date formats (3).** Low value, unforced. Cut. *(One caveat:
  BL-24's accessibility angle can surface in public-sector/enterprise procurement —
  pull it forward the moment a specific deal names it.)*

---

## Dependencies & risks called out

**The two load-bearing items the value column hides.** Both are rated Med and both
would sink below a naive value sort — and both would take a High-value commitment
down with them:

1. **BL-11 → BL-02 (the audit spine).** The SOC 2 evidence dashboard collates
   access/control evidence the auditor needs. Today those events are unstructured
   stdout log lines — you can grep them, but you can't query, filter, or *retain*
   them as records, which is exactly what an evidence artifact has to be.
   **[ASSUMPTION]** BL-02 therefore cannot ship on the current substrate; it
   requires BL-11's retained, indexed event store first. Treat these as **one
   10-ew deliverable, not two**, and treat the 8 Sep freeze as its hard gate. This
   is the single most important sequencing fact in the plan: if BL-11 slips, BL-02
   slips, the audit slips a full quarter, and the deals waiting on it slip with it.
   It starts week 1.

2. **BL-03 → BL-04 (the enterprise unlock).** SAML SSO is written as "resolve each
   login to a Lumen role and team membership" — but nothing today authoritatively
   stores roles or team membership; it's ad hoc, per feature. **[ASSUMPTION]** SSO
   can't ship correctly without BL-03 first. The trap a value sort sets is
   scheduling the High-value BL-04 and assuming its foundation is free; the real
   cost of "SSO this quarter" is **11 ew (BL-03 + BL-04), not 5.** Worth paying,
   because BL-03 also de-risks BL-01, BL-19, and BL-25 — but it has to be costed and
   sequenced honestly.

**The other ordering chains (don't reorder these):**

- **BL-03 → BL-01.** "Share a saved view with teammates" needs a notion of who a
  teammate *is* — the team-membership model in BL-03. **[ASSUMPTION]** BL-01 starts
  once BL-03 is near-done, not before.
- **BL-13 → BL-15.** The email drip nudges users "based on how far they've gotten
  through first-run setup." That progress signal — which steps are done — is
  precisely what the BL-13 checklist builds. **[ASSUMPTION]** Shipping the drip
  first, or alone, leaves it with no data to decide whom to nudge about what. Order
  is fixed.
- **BL-03 → BL-19, BL-25.** Bulk user import creates users, and session controls
  govern SSO'd users — both sit naturally on the real identity store. Sequenced
  into the stretch tail *after* BL-03/BL-04.
- **BL-08 + BL-20 pairing.** Independent, but the platform lead wants them shipped
  together (both fire on performance complaints). Kept adjacent.

**Cross-cutting risks to name in the review:**

- **The immovable date has zero give.** 8 Sep / week 10 doesn't slip a week — it
  slips a quarter, to the December Type II window, which enterprise deals are
  contractually waiting on. That's why the audit spine is front-loaded with margin
  rather than optimized to finish "just in time." Protect this above all else.
- **Streamflow is a mid-quarter cliff, not just a BL-07 problem.** Provisioning
  dies 1 Aug, the platform dies 30 Sep. Confirm nothing *else* we ship quietly
  reaches for Streamflow, and get the replacement-streaming initiative scoped now —
  it's a Q4 prerequisite, not a someday-item.
- **EU residency is a latent landmine across multiple items.** It's not unique to
  BL-09. Any export/analytics/batch job touching raw EU records — including
  **BL-22**'s GDPR export for EU tenants — must execute in eu-central, where the
  plumbing doesn't yet exist. Before *any* EU-data export work is committed (this
  quarter or next), the eu-central execution gap needs its own estimate. Assume
  "reuse the us-east pipeline" is never the answer for EU data.
- **The committed plan is 40 ew against a ~50-ew estimate with a soft floor.** If
  summer PTO or incident load runs hot, the stretch tier (BL-25, BL-20, BL-19)
  comes off first, and **BL-15 (onboarding drip) is the designated release valve**
  inside the committed set — it can slip to early Q4 without breaking a single
  external commitment. The audit spine and the SSO chain do not flex.
