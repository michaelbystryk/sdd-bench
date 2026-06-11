# Lumen — H2 & FY-Next Product Strategy

## Situation

We do not have a growth problem we can sell our way out of. We have a retention problem, and it has a specific cause.

**The headline number is lying to us.** "1.41M invoices, +34% QoQ" is a vanity metric. One logo (Vantage Retail) is ~38% of volume; self-serve accounts that auto-forward but never approve are another ~22%. Stripped of those, real approved-invoice volume from paying mid-market accounts grew **~6% QoQ**. Combined with NRR sliding from ~108% to ~97%, the honest picture is: new logos roughly replace what we lose, and the bucket is leaking. Any board narrative built on the 34% figure is built on sand — we should retire it from the deck.

**We leak on the back end, not the front end.** This is the strongest, best-corroborated signal in the entire pile, because three independent inputs agree:

- **Churn:** 3 of 5 real churns name ERP re-keying/reconciliation as the deciding factor (Northwind → NetSuite-native competitor; Greenfield → CSV-to-Sage broke during month-end close; Tindall heading the same way). The two non-reconciliation churns were a wrong-fit account (Castle & Pike) and a too-small price-sensitive account (Halcyon) — neither winnable, both discountable.
- **Support:** ERP/reconciliation is the #1 theme at **98 tickets/quarter**, more than routing (61) and OCR (44) combined.
- **Pipeline:** the entire winnable mid-market cluster (Tindall, Dovetail, Pinebrook, Calderon, Bellweather) converges on ERP sync and deeper routing.

The CS lead's summary is exactly right: *"The accounts we lose for product reasons, we lose on the back end — the handoff into the accounting system — not the front end. We almost never lose on OCR or routing."* The market agrees: the category is consolidating around "close the loop into the ERP," and OCR-and-route-only is becoming the front half of a workflow buyers now expect to be whole.

**Routing is our moat, and it is under-invested relative to what it earns us.** Approval routing is the strongest positive retention signal in the usage data — it held across two cohorts and survived controlling for account size. Routing-heavy accounts expand seats; Orsino re-expanded specifically when we shipped conditional approval limits. Accounts that configure a conditional routing rule in their first 14 days retain markedly better at 6 months. Competitively, our closest rival (Synthesis) is *weaker* here — single-level, no conditional rules. We win the front end and lose the back end. Synthesis is the mirror image.

**What we are discounting, and why:**

- **The 34% growth headline** — skew from one logo + self-serve noise (above). Real growth is ~6%.
- **The enterprise pipeline (Atlas, Meridian)** — loudest in every pipeline review, least likely to close. No finance champion, procurement-led, stalled 2+ quarters, and the ~$155k combined ARR is AE projection, not signed. Sales leadership concedes this in writing.
- **The "AI Spend Copilot" panic** — Ledgerly's Copilot serves the FP&A/CFO-analytics buyer and sits on already-categorized spend; it does not touch intake, approval, or the AP workflow. Two demo questions is demo-envy, not lost deals. Wrong buyer, wrong job-to-be-done.
- **CSV-export usage (81%)** — high usage but *negative* retention correlation. People use it because they must; it is the pain surface, not a love surface. High usage here is a churn warning, not a success.
- **Mobile (4%), reporting dashboards (34%, weak correlation)** — real but low-leverage.

## Positioning

**Where we play:** mid-market finance teams (50–500 employees), Controller/AP Manager as buyer. This is ~80% of ARR, ~140 accounts, and the only motion where we have champions, fit, and a repeatable win. We are not an enterprise procure-to-pay suite and not a self-serve SMB tool. We stop pretending otherwise.

**How we win:** *the best-routed invoices, posted clean into your ERP without re-keying.* Today we own the first half of that sentence and abandon the customer at the second. Our durable advantage is approval routing — deeper and more configurable than anyone at our price point. Our fatal gap is the handoff into the accounting system. The strategy is to **defend and extend the routing moat while closing the back-end gap that is bleeding us** — becoming the complete "pile of PDFs → approved → posted" workflow for the mid-market, without becoming a payments rail or an ERP (we remain the layer between the inbox and the ledger).

## Bets

We have capacity for two meaningful bets. These are the two.

### Bet 1 — Native two-way ERP sync (NetSuite, then Sage Intacct). *Defensive: stop the leak.*
**Rationale:** This is the single cause behind the majority of our product-driven churn, our largest support theme, and the convergent blocker on ~$160k of winnable mid-market pipeline. It directly attacks the NRR decline. Scope is deliberately narrow: **two ERPs the data actually names** (NetSuite: Northwind, Pinebrook; Intacct/Sage: Tindall, Dovetail), two-way, with GL coding carried over and reconciliation status flowing back — *not* an "integrations platform" and *not* QuickBooks/Xero yet. The risk is correctness, not connectivity: two-way sync makes us part of the customer's month-end close, so a mis-code or double-post is a financial error, not an annoyance (this is what churned Greenfield). The bet therefore includes a reconciliation/idempotency test harness and a hard rule: never post without a confirmable round-trip.

### Bet 2 — Deeper, easier-to-author approval routing. *Offensive: widen the moat + drive activation/expansion.*
**Rationale:** Routing is our proven retention and expansion lever and our clearest competitive edge. The asks are concrete and convergent: conditional rules (over-$X → second approver, per-vendor routing), per-person approval limits (auditor-driven), and vacation delegation (T-2320 quantified ~$3k/mo in lost early-pay discounts). Crucially, the retention signal is about *successful configuration in the first 14 days*, not feature count — so this bet is scoped around **authoring and maintainability** (role-based rather than brittle person-based rules) as much as new rule types. A meaningful slice already exists in beta (conditional approval limits, validated by Orsino's re-expansion), so it can ship as early quick wins. **Constraint: Slack/email approvals are load-bearing (71% usage; Bellweather stayed only because of them) and must not regress.**

> Two bets, not three. Everything below is what we are explicitly *not* doing so these two get the capacity they need.

## Kill-list

- **Decline the enterprise push (Atlas, Meridian) as a roadmap driver.** No vendor portal, no SCIM, no enterprise procurement surface. *Why:* unsigned projected ARR, no finance champion, procurement-led, stalled 2+ quarters — and building for them forks us away from our ICP into Coupa's weight class. We will keep selling them what we have; we will not build for two maybes. *([ASSUMPTION] we are willing to lose these two deals — the strategy assumes that is acceptable given the odds.)*
- **Decline the AI Spend Copilot.** Wrong buyer (FP&A/CFO), wrong job (post-hoc analytics), away from where we win. Re-evaluate only if it starts appearing in *lost-deal debriefs* rather than demo curiosity.
- **De-prioritize self-serve/SMB as a build target.** Dormant inbox-parsers and price-sensitive light users (Halcyon) are revenue noise that carries support cost. *Nuance:* the *activation mechanism* that retains low-engagement mid-market accounts is the same first-14-day routing-configuration lever in Bet 2 — we keep that, we just don't build self-serve-specific features or chase a cheaper tier.
- **Decline mobile app and reporting-dashboard investment.** 4% and weak-correlation respectively; single-user and CFO-convenience asks, not retention or deal drivers.
- **Treat OCR as "good enough," not a bet.** Misses are "annoying but livable" and uncorrelated with churn. Bug-fix queue only; no major OCR initiative.

**Recorded nuance (defer, not kill): SOC 2 Type II + SAML SSO.** These will become table stakes even in upper-mid-market and are *not* the same as "going enterprise." Hold as a **deferred compliance track**, triggered when they gate real ICP deals — not now, and not to chase Atlas.

## Sequencing

The order is set by one principle: **you cannot fill a leaking bucket. Stop the leak first, but ship the cheap moat-extension in parallel because it's already half-built.**

1. **Q3 — Flagship build: NetSuite two-way sync + routing quick wins (parallel).**
   - NetSuite is first because it is the most-named ERP and sits under the highest at-risk ARR. Build it with the reconciliation test harness from day one.
   - In parallel, graduate the beta routing work (conditional approval limits) to GA and add per-person limits and vacation delegation — small, validated, fast.
   - **Tindall (renews in ~90 days) is the natural NetSuite/Intacct design partner.** *Gate:* we do not ship them anything that could disrupt a close to save the renewal.

2. **Gate → Q3/Q4 — NetSuite GA.** *Hard gate:* NetSuite sync survives at least one real customer's full month-end close (sandbox → production) with **zero mis-posts**. Feature-completeness does not open this gate; close-survival does.

3. **Q4 — Sage Intacct sync + routing authoring depth.**
   - Intacct starts *only after* the NetSuite gate is passed (reuse the proven sync core and harness; don't build two shaky integrations at once).
   - Deepen routing toward role-based authoring and maintainability (the activation lever), informed by Q3 quick-win usage.

4. **Continuously gated checkpoints:**
   - **NRR** is the north-star outcome metric — the bets succeed if NRR climbs back through 100%, not if features ship.
   - **Slack-approval regression suite** must stay green at every routing release.
   - **SOC 2 track** is triggered only if/when it blocks a finance-championed ICP deal.

**Net:** by end of FY-next we are the mid-market AP tool with the best routing *and* a clean two-way close into the two ERPs our customers actually run — defending the moat, plugging the leak, and declining everything loud that doesn't serve that.
