# Lumen H2 / FY-next Strategy

*One page of conclusion up front, then the reasoning.*

**The bet in one sentence:** We win on the front of the workflow (routing) and we're
bleeding on the back of it (the ERP handoff). So we close the loop into the ERP to stop
the leak, and we deepen routing to widen the moat — and we say no to everything else,
including the loud stuff.

The two bets, in order:

1. **Close the loop into the ERP** — native two-way sync, NetSuite first, then Sage
   Intacct. This is the retention fix.
2. **Turn routing from a feature into a moat** — conditional/per-vendor rules, approval
   limits, delegation, and routing-led onboarding. This is the expansion engine.

Everything else is on the kill-list.

---

## Situation — what the signals actually say

**The problem is the back end, not the front end.** Every product-driven loss happens at
the handoff into the customer's accounting system, never at OCR or routing. Of the five
real churns, three name ERP re-keying as the deciding factor (Northwind, Greenfield, and
Tindall is heading there). The CS lead says it outright: "The accounts we lose for
product reasons, we lose on the back end." Support backs it — ERP/reconciliation is the
single largest theme at 98 tickets/quarter, more than routing (61) and OCR (44) combined.
This is also where the market is moving: the category is consolidating around "invoice in
→ approved → *posted to the ERP* without re-keying," and Competitor A has already shipped
native NetSuite + Intacct two-way sync — the exact thing Northwind and the multi-entity
group (T-2314) left us for. NRR slipping 108% → 97% is this leak. We fill the bucket with
new logos and drain it out the back.

**Routing is the moat, and it's under-invested.** It's the strongest retention signal in
the data — held across two cohorts and survived controlling for account size. It's why
customers stay as long as they do, why they pick us over Competitor A (whose routing is
single-level and weaker), and it drives expansion: Orsino re-expanded the moment we gave
them conditional approval limits in beta. Activation confirms it — accounts that set a
conditional routing rule in their first 14 days retain far better at 6 months; accounts
that only do OCR + manual approval look like self-serve dabblers and lapse. We lead here
and we're treating it like a finished feature.

**These two facts fit together.** Lumen and Competitor A are mirror images: we win on the
front-end routing they're weak at, they win on the back-end sync we lack. The strategy
writes itself — protect the half we win, fix the half we lose.

### Inputs I'm discounting, and why

- **The 1.41M invoices / "+34% QoQ" headline.** Vanity. 38% is one logo (Vantage)
  auto-importing, 22% is self-serve accounts where no human ever approves. Strip those and
  real approved volume from paying mid-market grew ~6%. **Stop putting 34% in the board
  deck** — it's hiding the flat growth that's the actual reason we're having this
  conversation.
- **The enterprise pipeline (Atlas, Meridian).** Loudest in every pipeline review, least
  likely to close. Both procurement-led, neither has a finance champion, both stalled 2+
  quarters, and the ARR is AE projection, not signed. They'd have us build an entire
  enterprise stack (vendor portal, SCIM, SOC 2, SIEM export) for two maybes who'd then
  want custom everything. Discounting the *volume* of these asks — one loud prospect filed
  three of our "enterprise security" tickets.
- **Ledgerly's "AI Spend Copilot."** Loud (TechCrunch, LinkedIn) and irrelevant to us. It
  serves the FP&A/CFO-office persona and sits on already-categorized spend — it doesn't
  touch invoice intake, approval, or the AP workflow. Two prospects asked; that's FOMO,
  not demand. Chasing it enters a feature race late, against a different buyer, away from
  where we win.
- **Mobile, reporting dashboards, OCR-as-a-bet.** Mobile is 7 tickets and 4% usage.
  Reporting is 34% usage with weak retention correlation and near-zero dashboard traffic.
  OCR is "annoying but livable" and we almost never lose on it. All real, none strategic.
- **Heavy CSV-export usage (81%).** Looks like engagement; it's the opposite. CSV-export
  power users churn *more* — the export is the pain surface, the thing they do because
  they have to. High usage here is a symptom of the disease, not a feature to celebrate.

**The popular internal belief that's wrong:** that the enterprise logos are the growth
story. They're a time sink. The VP Sales has this right — the boring mid-market cluster
(Tindall, Dovetail, Pinebrook, Calderon, + Bellweather), ~$160k combined, finance-led,
with champions, all asking for variants of the same two things (ERP sync, deeper routing),
is where the money actually is. The enterprise deals get the most airtime and close the
least.

---

## Positioning — where we play and how we win

**Where we play:** mid-market finance teams (50–500 employees), bought by the Controller
or AP Manager. That's ~80% of ARR and every healthy signal we have. We do not move
up-market to enterprise and we do not chase self-serve. We are the AP workflow layer
between the invoice inbox and the ERP.

**How we win:** *the best-routed, cleanest handoff in mid-market AP.* We own the workflow
from invoice intake through approval through a clean, posted record in the customer's
accounting system — no re-keying, no CSV dance. Today we own the first two-thirds of that
sentence and abandon the customer at the third. Owning the whole sentence is the win.

The positioning shift is from **"OCR-and-route"** (now table stakes, the front half of a
longer expected job) to **"approve-and-post"** — we don't just get the invoice approved,
we land it correctly in NetSuite/Intacct with the GL coding carried over. Routing is how
we're *differentiated*; closing the loop is how we become *complete*. We need both: sync
without routing makes us a worse Competitor A; routing without sync keeps us leaking.

---

## Bets (two real ones, plus one cheap protect)

### Bet 1 — Close the loop into the ERP *(the retention fix)*
Native two-way sync: approved invoices post into the ERP with GL coding carried over, and
reconciliation status flows back. NetSuite first, Sage Intacct second. [ASSUMPTION:
NetSuite leads Intacct in our install base — Northwind, Tindall, Pinebrook all point that
way; verify against the account list before locking sequence.]

**Why:** This is the only thing that fixes NRR. It directly addresses the largest churn
driver, the largest support theme, the market's table-stakes shift, and Competitor A's one
real advantage — simultaneously. It converts the negative CSV-export surface into a love
surface. It unblocks the mid-market sales cluster (Tindall's at-risk renewal in 90 days,
Dovetail, Pinebrook) without building anything speculative. Highest cost of the bets and
worth it: this is the leak.

### Bet 2 — Turn routing from a feature into a moat *(the expansion engine)*
Ship the routing depth customers keep asking for: conditional rules (e.g. >$10k needs a
second approver), per-vendor auto-routing, per-person approval limits, and
delegation/out-of-office. Instrument routing properly (it's under-measured for how much
retention it drives), and push conditional-rule setup into first-14-day onboarding.

**Why:** Routing is our proven moat and our best activation and expansion lever — Orsino
expanded on it, the activation data ties first-rule setup to 6-month retention, and the
asks are concrete (T-2261, T-2266, T-2320, Calderon, Pinebrook). It's cheaper and faster
than Bet 1, it compounds the one thing competitors can't easily match, and routing-led
onboarding attacks the dabbler-lapse pattern at the source. While Bet 1 stops the bleeding,
this is how we get NRR back above 100% through expansion.

### Protect (not a bet — a small, non-negotiable maintenance line) — Keep Slack approvals bulletproof
71% of accounts use Slack/email approvals; Bellweather downgraded 40→18 seats in a
Slack-only reorg and stayed only because we support it ("please don't ever break that,"
T-2270). This is a known at-risk surface if a competitor matches it. No new bet — just
guard it and don't let it regress.

---

## Kill-list — what we stop, decline, or de-prioritize

- **Decline the enterprise build (vendor portal, SCIM, SAML, SIEM export) and stop
  chasing Atlas/Meridian as roadmap drivers.** Two unsigned, procurement-led, championless
  maybes are not worth an enterprise stack that pulls us off ICP. We don't say no to the
  logos — we say no to letting them set the roadmap. *(One caveat: **SOC 2 Type II** and
  basic **SAML SSO** are creeping into mid-market table stakes too. Run SOC 2 as a
  background trust/compliance track — not counted against our two eng bets — and treat SSO
  as a small fast-follow, not an enterprise project. [ASSUMPTION: SOC 2 can be progressed
  via process/audit spend without consuming a core eng bet.])*
- **Decline the AI Spend Copilot race.** Wrong buyer (FP&A, not AP ops), wrong job, and
  we'd enter late. Arm sales with a talk-track instead of a roadmap item.
- **Kill the mobile app.** 7 tickets, 4% web usage. Slack approvals already are the phone
  experience.
- **De-prioritize reporting/analytics dashboards.** Weak signal, near-zero traffic. At
  most, ship the single spend-by-vendor export a few controllers asked for (T-2309) as a
  cheap nicety — not a workstream.
- **Hold OCR at maintenance.** Fix the worst targeted misses (PO-number, multi-page
  totals) opportunistically; it's "livable" and not a loss driver. No OCR bet.
- **Stop investing in self-serve growth.** 900 accounts, negligible revenue, many dormant,
  and some (Halcyon) churn was correctly *losing* a misfit. Keep it as a cheap top-of-
  funnel; don't build for it, and consider repricing so it stops cross-subsidizing.
- **Stop reporting the 34% headline.** Report real approved mid-market volume (~6%). The
  vanity metric is actively hiding the problem.

---

## Sequencing — order and gates

**Quarter 1 (H2-Q1): start both bets; routing wins land first.**

1. **Bet 2 (routing depth) ships early and continuously** — it's the smaller, faster work
   and produces visible wins while Bet 1 is still in build. Ship conditional/per-vendor
   rules + approval limits, then delegation. *Gate to onboarding:* once rules ship, wire
   conditional-rule setup into the first-14-day flow and instrument it.
2. **Bet 1 (NetSuite two-way sync) starts in parallel as the half's headline effort.**
   Design-partner with **Tindall** (at-risk, 90-day renewal — this gates whether we save
   that logo) and **Dovetail** (late-stage new, ERP sync is the dealbreaker). *Gate:* do
   not broaden to GA until two design partners are posting real invoices through a real
   month-end close. Greenfield churned because the handoff broke *during* close — sync that
   isn't close-proof is worse than no sync.

**Quarter 2 (H2-Q2): finish the loop, monetize the moat.**

3. **NetSuite sync to GA**, then **Sage Intacct sync** (Bellweather/Tindall/Dovetail span
   both). *Gate:* GA only after the close-cycle reliability bar is met.
4. **Routing as an expansion/pricing lever.** With depth shipped and instrumented, package
   advanced routing into the tier that drives seat expansion (Orsino is the proof). *Gate:*
   pricing change waits on instrumentation showing the retention/expansion lift.

**What gates the whole thing:** Bet 1 is sequenced first-among-equals because NRR < 100%
is the board's stated concern and the leak compounds every quarter we don't plug it. But
Bet 2 ships *sooner* because it's cheaper and de-risks the half with early wins. If
capacity forces a true either/or mid-quarter, **ERP sync wins** — you can't expand a
bucket that's draining out the back.
