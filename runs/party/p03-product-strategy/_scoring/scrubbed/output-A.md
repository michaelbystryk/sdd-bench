# Lumen — H2 / FY-Next Product Strategy

*Where to play, where to win, what to build, and what to refuse. Two bets, in order.*

---

## Situation — what the signals actually say

The inputs look contradictory, but once you discount the loud-and-irrelevant, five independent sources — churn notes, support volume, usage correlation, competitive moves, and live pipeline — all point at the **same wall**. That convergence is the finding. Sources this different rarely agree this cleanly; when they do, it's a diagnosis, not a theme.

**The diagnosis: we lose on the back end, not the front.** The handoff out of Lumen into the customer's accounting system — the re-keying of approved invoices into NetSuite/Intacct — is where revenue leaks. Three of five real churns named ERP re-keying/reconciliation as the deciding factor (Northwind left for Competitor A's native NetSuite sync; Greenfield's CSV-to-Sage broke at month-end close; Tindall, $44k, is at-risk on the same complaint). It is the single largest support theme (98 tickets/quarter). And CSV export — used by 81% of accounts — *correlates with more churn*, because it isn't a feature, it's the pain surface people touch daily until they leave. The market is consolidating around "close the loop into the ERP"; OCR-and-route is becoming the front half of an expected workflow, not the whole product.

**The moat: approval routing.** It's the strongest positive retention signal in the data, held across two cohorts controlling for account size. Routing-heavy accounts expand seats. Orsino re-expanded the moment we shipped conditional approval limits in beta. Setting one conditional routing rule in the first 14 days is the best predictor of 6-month retention we have. Competitor A — the rival actually beating us on the back end — has *weaker* routing than us. We are mirror images: they closed their loop and can't match our workflow; we own the workflow and haven't closed our loop. **Whoever covers their gap first wins mid-market.**

### Inputs I'm discounting, and why

- **The "+34% invoices QoQ" headline.** Vanity. ~38% is one auto-importing logo (Vantage); ~22% is free-tier inbox-parsing with *no human approval*. Strip both and real paying mid-market volume grew **~6%** — consistent with flat ARR and 97% NRR. Stop putting 34% in the board deck; a director will do this subtraction and the credibility hit is worse than the flat number. We are flat and leaking. That is the honest baseline.
- **The enterprise demand signal.** The entire SOC2/SAML/SCIM/SIEM "requirement" is **9 tickets from 2 unsigned eval prospects** (Atlas, Meridian) — procurement-led, no finance champion, stalled 2+ quarters, ARR projected by AEs, not signed. This is the loudest thing in pipeline review and the least likely to close; our own VP Sales says so. Loud ≠ real. Discounted.
- **Competitor B's "AI Spend Copilot."** Impressive and buzzy, but it serves an FP&A/CFO-office *analytics* buyer and never touches invoice intake or approval. Two nervous prospect questions is curiosity, not displacement. It tells us where *not* to go, not what to build.
- **Mobile** (4% usage, 7 tickets, literally one user) and **reporting dashboards** (weak usage, not a churn or expansion driver) — noise.
- **Castle & Pike** (never our fit — wanted matter-level cost allocation we never claimed) and **Halcyon** (too-small, price-sensitive, should never have been on a mid-market plan) churns — unaddressable, excluded from the churn read.

---

## Positioning — where to play, how to win

**Where we play:** Mid-market finance teams (50–500 employees). Buyer: Controller / AP Manager. Finance-led, champion-backed deals — not procurement-led enterprise evaluations.

**How we win:** *We own AP approval routing **and** close the loop into the ERP — so an approved invoice lands in NetSuite/Intacct correctly coded, without re-keying, and survives month-end close.* Routing is why customers stay and expand; ERP close-the-loop is why they stop leaving. One sentence, two halves, and the mid-market pipeline is asking for both in the same breath (~$160k of finance-led, winnable-this-half deals converging on exactly these two asks). That convergence is the ICP telling us the shape of the product.

We explicitly do **not** reposition up-market (enterprise procure-to-pay) or sideways (FP&A spend analytics). Both are different buyers, different jobs, and away from where we win.

---

## Bets — the two we're making (and why only two)

We have capacity for ~two meaningful bets over two quarters. These are them. They are mutually reinforcing: one stops the bleed, one compounds expansion, and the same customers want both.

### Bet 1 — Deepen approval routing (the moat; ships first)

Build a **single rules engine** (conditions → actions) and express conditional rules, per-person approval limits, per-vendor auto-routing, and vacation/delegation as rule types on top of it. Pair it with an **activation play**: infer a new account's likely routing from its first week of invoices and *propose* the rules ("Dana approves everything under $5k for Marketing — make that a rule?"), so the customer accepts/edits instead of authoring from a blank canvas.

**Why:** This is our strongest retention signal and our only real differentiation, and Competitor A can't follow us here. It directly answers the second-largest support theme (61 tickets). The activation angle attacks the root cause of the NRR slide — accounts that never reach the "routing rule in 14 days" moment look like dabblers and lapse; today a high-friction blank-canvas editor self-selects our survivors. Vacation delegation alone is CFO-legible: accounts quantified ~$3k/mo in lost early-pay discounts from invoices piling up behind one approver. It is bounded, low-risk, and lives entirely inside our own data model — buildable in roughly a quarter.

**Non-negotiable constraint:** Every routing state change (delegation, limits, vacation cover) must round-trip through **Slack** flawlessly. Half our active approvers never log into Lumen and approve from Slack — "don't ever break that." Model routing changes as Slack-native events, not web config that happens to notify Slack. If a new feature forces the Slack approver to log in, it's a regression, not a feature.

### Bet 2 — Close the loop into the ERP: native NetSuite sync (the bleed-stopper)

Native two-way sync with NetSuite: approved invoices post in with GL coding carried over; reconciliation/posting status flows back. **Scope to one ERP — NetSuite — for the half**, behind a connector abstraction so the second ERP is a plug-in, not a rewrite.

**Why NetSuite first:** it's where we're actively bleeding (Northwind → Competitor A's native NetSuite sync), it's where Competitor A set the bar, and it's the convergent ask of the winnable mid-market cluster. It defends NRR, drains the largest support theme, neutralizes Competitor A's only advantage, and unlocks ~$160k of champion-backed pipeline.

**What this bet actually is — read carefully.** "Two-way sync" hides three very different cost tiers, and the third is the product:
1. **Outbound post** (approved invoice → ERP, with GL/vendor/dimension mapping) — hard but bounded.
2. **Inbound reconciliation status** (posting/payment status flows back) — the part you own forever: drift, "the ERP changed it underneath you," polling/webhook reconciliation.
3. **Idempotency + close-window reliability** — Greenfield didn't churn because CSV lacked features; they churned because it **broke twice during month-end close**. The deliverable is *reliability under the worst possible timing*: idempotent posting (no double-posts on retry), a reconciliation ledger, replayable failed posts, and a status surface a controller trusts at 11pm on close day. Ship glamorous sync without this substrate and you reproduce Greenfield with extra steps.

**[ASSUMPTION]** Intacct is a *committed fast-follow* (next half), enabled by the connector abstraction — not in-scope for this half. Tindall ($44k, Intacct, at-risk) is held by bringing them in as a design partner with a **committed date**, not by widening scope now. Trying to do NetSuite *and* Intacct natively this half blows the two-bet budget and starves Bet 1.

**[ASSUMPTION] Build vs. partner is an open question, gated below.** Native two-way sync against two-plus moving ERP API targets is a large, permanent maintenance surface. We may get to "no re-keying" faster by embedding a third-party integration layer for the connector plumbing while we build the reliability/reconciliation substrate and the routing moat natively. Default lean: **buy the commodity plumbing, build the substrate and the moat** — but only if a spike proves it hits the bar in materially less time. We do not hand-roll a commodity and starve the thing only we can win.

---

## Kill-list — what we stop, decline, or de-prioritize

Saying no to these is what *funds* the two bets. A seven-item roadmap is the same as no strategy.

- **Enterprise (Atlas, Meridian — SSO, SCIM, SOC 2, vendor portal): decline this half.** No finance champion, procurement-led, stalled 2+ quarters, zero signed dollars. This is a third bet wearing a trenchcoat, with a different buyer and a heavier feature set. Revisit *only* when a finance champion is pulling, not when procurement is filtering. **Cost of saying yes: we'd spend a full bet chasing two maybes and orphan the $160k of finance-led pipeline that's actually closing.**
- **"AI Spend Copilot" reaction: decline.** Different buyer (FP&A/CFO), different job, away from where we win. Two nervous prospects is sales anxiety, not a market. Entering this race late, off-persona, is how we lose focus on AP.
- **Mobile native app: stop.** 4% usage, one-user demand. Our mobile users are already served — in Slack, where they live and which they love. A native app rebuilds a worse version of that. Remove it from the roadmap conversation.
- **Reporting / dashboards: defer.** Weak usage, not a churn or expansion driver. Our users are AP operators clearing a queue, not analysts mining trends. Don't get baited toward Competitor B's buyer.
- **OCR investment: hold (lights-on only).** 100% usage but flat — it predicts nothing and "annoying but livable" at 44 tickets. It's becoming table stakes. Maintain quality; invest nothing net-new.
- **Multi-ERP breadth (QuickBooks, Xero, Sage) and native Intacct *this half*: defer behind NetSuite.** Real, but going wide before going deep dilutes Bet 2. The connector abstraction makes them cheap *next* half — that's the payoff for scoping to one ERP now.
- **CSV export polish: stop.** It's the pain surface we're making obsolete. Don't improve the thing we're trying to retire.

---

## Sequencing — the order, and the gates

The principle: **ERP sync done wrong (a close-day failure) is worse than ERP sync done late.** So we ship the bounded moat work first and bank retention while we architect the heavy, must-be-reliable ERP bet properly — rather than rushing a happy-path demo that breaks at month-end and reproduces Greenfield.

**Q3 — Routing depth ships; ERP architecture is designed in parallel.**
- *Build:* Bet 1 — the rules engine + the propose-rules activation flow, Slack round-trip as a hard requirement.
- *In parallel (design only):* the ERP connector abstraction, idempotency model, and reconciliation ledger. This design decision determines whether ERP #2 later is a week or a quarter.
- *Gate 0 (Week 1, before any ERP build):* a one-week build-vs-partner spike. Decision: native vs. embedded integration layer for the connector plumbing. Commit a path before writing connector code.
- *Customer motion:* pull Tindall, Dovetail, Pinebrook, and Greenfield-profile accounts in as design partners now; give Tindall a committed Intacct date to hold the $44k renewal.
- *Gate 1 (exit Q3):* routing depth in GA; activation metric instrumented (target: conditional routing rule set within 14 days for new accounts). **Do not start ERP build until the connector abstraction + reliability substrate are committed as the deliverable** — not a happy-path post.

**Q4 — NetSuite close-the-loop ships.**
- *Phase 2a:* posting pipeline + idempotency + reconciliation ledger + close-day status surface (NetSuite outbound). This is the spine. **Gate 2:** if 2a slips, we've still killed the Greenfield month-end failure mode — that's the floor, and it's shippable on its own.
- *Phase 2b:* inbound reconciliation status read-back (matches Competitor A's "status flows back"). **Gate 3 (GA):** validated through a real month-end close with design-partner accounts — no double-posts, reconciliation trusted at close. Reliability is the acceptance test, not a follow-up.

**End of half — re-evaluate with real signal, not speculation.**
- Once sync exists and NRR has turned, the *next* bet is decided by data: **wider** (Intacct, then QuickBooks/Xero via the connector abstraction) or **up-market** (enterprise — but only if a finance champion is now pulling). We do not pre-commit that bet today.

**The one-line version for the board:** We are not a volume story and not an enterprise story this half. We are a *close-the-loop-and-own-the-workflow* story for mid-market finance — we stop the churn by syncing into NetSuite, we compound expansion by deepening routing, and we decline everything that doesn't serve those two, because that's the only way two bets beat seven.
