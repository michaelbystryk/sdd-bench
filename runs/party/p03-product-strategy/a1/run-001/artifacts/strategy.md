# Lumen H2 Strategy

*Point of view for H2 and FY-next. Built from the `reference/` pile. Opinionated by design.*

---

## Situation — what the signals actually add up to

Strip the noise and six independent inputs tell **one story**: Lumen wins at the front of the
workflow (OCR + especially approval routing) and **loses at the back** (the handoff into the
customer's accounting system). We are leaking good-fit customers out the back door we never built.

The evidence converges from sources that don't talk to each other:

- **Churn is a back-end story, not a product-quality story.** Of five real churns, three name
  ERP re-keying / reconciliation as the deciding factor (Northwind −$42k, Greenfield −$36k, and
  Tindall −$44k heading the same way). The CS lead's own summary: *"The accounts we lose for
  product reasons, we lose on the back end… We almost never lose on OCR quality or routing;
  routing is usually why they stayed as long as they did."*
- **Support volume agrees.** ERP / reconciliation is the #1 theme by a wide margin — **98 tickets
  this quarter** vs. 61 for routing and 44 for OCR. The pain is "re-key into NetSuite/Intacct" and
  "CSV export is not an integration."
- **The market is consolidating around exactly this.** Competitor A (Synthesis) shipped native
  NetSuite + Intacct two-way sync and is winning our lost deals on it — while losing on routing,
  where they're single-level and weak. The two products are mirror images. Buyers now expect
  *invoice → approved → posted to the ERP without re-keying* as the default workflow.
- **Usage data names the moat.** Approval routing is the **strongest positive retention signal**
  (held across two cohorts, survived controlling for account size); routing-heavy accounts expand
  seats. Conversely, heavy CSV-export usage correlates *negatively* with retention — it's the
  pain surface, used because they have to, not because they love it. OCR is 100% used and **flat**
  on retention: table stakes, predicts nothing.
- **Sales' real pipeline points the same way.** Past the enterprise theater, the mid-market
  cluster — Tindall, Dovetail, Pinebrook, Calderon, Bellweather — is five finance-led deals worth
  ~$160k, all winnable this half, all asking for variants of **two things: ERP sync and deeper
  routing.** The VP Sales says it plainly: *"the enterprise deals suck up the most airtime and are
  least likely to close; the mid-market asks are boring and they're where the money is."*

**Inputs I'm discounting (and why):**

- **The "1.41M invoices, +34% QoQ" headline.** Vanity. The data team's own caveat: ~38% is one
  logo (Vantage) auto-importing, ~22% is self-serve accounts using us as an inbox parser with *no
  human approval*. Real approved volume from paying mid-market grew **~6%**, not 34%. Do not put
  34% in the board deck as growth. (It also surfaces a real risk — see Vantage note below.)
- **The enterprise pipeline cluster (Atlas $70k, Meridian $85k).** Loudest in the building — drives
  the SOC 2 / SSO / SCIM / vendor-portal / SIEM tickets too. But the ARR is *projected AE optimism,
  not signed*, both are procurement-led with **no finance champion**, both have stalled 2+ quarters,
  and they're in Coupa's weight class, not ours. This is the most over-weighted input we have.
- **Ledgerly's "AI Spend Copilot" buzz.** Loud (TechCrunch, two demo questions) relative to its
  relevance. It serves an FP&A/CFO-office analytics buyer and a different job-to-be-done; it never
  touches invoice intake, approval, or the AP workflow. Loudness ≠ relevance.
- **Mobile (4% usage, 7 tickets) and the self-serve long tail** (cheaper tier, more OCR languages).
  Immaterial to revenue and to our buyer.

**Two internal beliefs I think are wrong, from the signals:**

1. *"We grew 34% — volume is healthy."* No. Real mid-market growth is ~6% and flat NRR (<100%) is
   the truth. The headline is Vantage + self-serve noise.
2. *"Keep investing in OCR accuracy / it's our core."* OCR is table stakes. It's 100% adopted, flat
   on retention, and customers call its misses *"annoying but livable."* Nobody churns on it.
   Further OCR spend is polishing the one thing that doesn't move the needle.

---

## Positioning — where we play and how we win

**Where we play:** mid-market finance teams (50–500 employees), buyer = Controller / AP Manager.
That is ~80% of ARR, it's where our champions are, and it's the segment both big competitors are
weak in (Synthesis on routing, Coupa on price/speed/fit). We do **not** play enterprise and we do
**not** play self-serve SMB as a growth motion.

**How we win:** own the *complete* mid-market AP workflow — **"from invoice to posted: extracted,
intelligently approved, and synced into your ERP without re-keying"** — with the **deepest approval
routing on the market** as the durable differentiator.

Today we're positioned as "OCR-and-route." That's becoming the *front half* of what buyers expect —
table stakes. We win by (a) extending to the back half everyone now expects (ERP sync), so we stop
losing good-fit accounts, and (b) pressing our one genuine moat (routing) harder, where the data
says retention and expansion actually live and where Synthesis can't follow quickly. Sync neutralizes
their advantage; routing extends ours. We become the product that's strong at *both* ends while each
competitor is strong at one.

---

## Bets

We have eng capacity for ~two meaningful builds. Bets 1 and 2 are those builds. Bet 3 is a cheap,
high-leverage process change, not an eng project — included because it compounds the other two.

### Bet 1 — Close the loop: native ERP sync (the leak fix) — **highest priority**
Two-way native sync starting with **one ERP, then the second** — approved invoices post into the ERP
with GL coding carried over, reconciliation status flows back. **Begin with whichever of NetSuite or
Sage Intacct has the larger installed base among current paying accounts** — measure it from CSV-export
destinations before committing. [ASSUMPTION] NetSuite first (named by Northwind, Pinebrook, T-2231),
Intacct second (Tindall, T-2240/2255), pending that measurement.
- **Rationale:** This is the cause of the leak. NRR slipped below 100% on back-end churn; this is the
  single change that plugs the bucket. It directly addresses 98 tickets/quarter, three of our last
  five churns, and the live at-risk renewal (Tindall, 90 days). It converts the negatively-correlated
  CSV-export pain surface into a retention surface, and it neutralizes Synthesis's only real edge. It
  also unblocks ~$160k of finance-led mid-market pipeline (Dovetail, Pinebrook, Tindall).

### Bet 2 — Press the moat: deepen approval routing (the expansion engine)
Productionize and extend conditional routing: per-person **approval limits**, **per-vendor auto-routing**,
**conditional multi-approver rules** (e.g. >$10k → second approver), and **delegation / out-of-office**
so invoices don't pile up and miss early-pay discounts.
- **Rationale:** Routing is our *proven* moat — the strongest retention signal, the driver of seat
  expansion (Orsino re-expanded the moment we shipped conditional approval limits in beta), the reason
  customers stay through other pain, and exactly where Synthesis is weak. Much of this is already in
  beta, so it's **cheaper and faster than Bet 1** and ships as an early win. It unblocks Calderon,
  Bellweather, and part of Pinebrook. Under-instrumented and under-invested relative to the retention it
  drives — the data team flagged this directly.

### Bet 3 — Activate on routing in the first 14 days (cheap, compounding)
Make first-run onboarding push every new account to set up at least one conditional routing rule within
14 days. Not an eng tentpole — onboarding flow + CS playbook.
- **Rationale:** The data shows accounts that set up a conditional rule in their first 14 days retain
  markedly better at 6 months; accounts that only do OCR + manual approval lapse like self-serve dabblers.
  This is the cheapest available lever on the NRR leak, and it directly monetizes the Bet 2 investment by
  turning new logos into routing-anchored (sticky, expanding) accounts.

---

## Kill-list — what we explicitly stop, decline, or de-prioritize

- **Decline the enterprise build-out** (vendor self-service portal, SCIM, SAML SSO, SIEM audit-log
  export) for Atlas / Meridian. *Why:* unsigned projected ARR, procurement-led with no finance champion,
  stalled 2+ quarters, Coupa's weight class. Building an enterprise feature set for two maybes who'll then
  want custom-everything is the fastest way to warp the roadmap away from where we win. **Gate to revisit:
  one enterprise deal signs with a finance champion.** (Carve-out: **SOC 2 Type II** is worth pursuing as
  a low-cost trust credential on its own track — it's compliance work, not an eng tentpole, and it helps
  mid-market too. The *product* enterprise feature set stays dead.)
- **Decline the "AI Spend Copilot" race.** *Why:* different buyer (FP&A/CFO office), different
  job-to-be-done, doesn't touch the AP workflow, and we'd enter late against our positioning. Don't build
  it — **arm sales with a talk-track** ("that's an analytics layer for the CFO's office; we own the AP
  operations workflow that feeds clean, approved data into whatever analytics you run"). Revisit only if
  it starts showing up as a *decision* factor in lost-deal debriefs, not demo curiosity.
- **De-prioritize OCR-accuracy investment** beyond routine maintenance. *Why:* table stakes, flat on
  retention, "annoying but livable." Fix egregious misses reactively; do not staff a project.
- **De-prioritize reporting/dashboards.** *Why:* 34% adoption, weak retention correlation, near-zero
  traffic. The one real ask (spend-by-vendor export, T-2309) is a small templated report, not a program.
- **Decline mobile-native and the self-serve long tail** (cheaper tier, more OCR languages, mobile app).
  *Why:* 4% mobile usage; Slack/email approvals already serve "approve from my phone" for 71% of accounts.
  Self-serve is ~900 dormant-ish accounts and near-zero revenue — not a growth motion. Don't build down-market.
- **Watch, don't bet: Vantage concentration.** A single $190k logo is ~38% of processed volume. Not a
  product bet, but name it as a risk and have CS treat that renewal as a top-priority account.

---

## Sequencing — order and gates

The leak (NRR <100%) is the board's stated wound, so **Bet 1 (ERP sync) is the half's marquee build.**
But Bet 2 is partly built and cheap, so it ships *first* as a quick win and a hedge while sync cooks.

**Step 0 — Week 1 (decision gate):** Measure current CSV-export destinations to pick ERP #1. Confirm the
beta routing work is GA-ready. Reassign any OCR/reporting/enterprise eng time onto Bets 1–2.

**Step 1 — Weeks 1–4 (quick win):** GA the beta conditional routing + approval limits (Bet 2, phase 1).
Low cost, partly done, immediate retention/expansion value. Land Bellweather expansion and Calderon as
proof. Ship Bet 3 onboarding change alongside it.
*Gate:* beta is already validated with Orsino → harden and ship, don't re-litigate scope.

**Step 2 — Q3 (the build):** Start ERP sync v1 (Bet 1) on the chosen ERP, with a **design-partner set**
(Tindall, Dovetail, plus one Greenfield-profile account) rather than a blind GA. In parallel, extend
routing with delegation/out-of-office and per-vendor auto-routing (Bet 2, phase 2 — addresses T-2261,
T-2320).
*Gate before broad ERP GA:* design partners complete a real month-end close through native sync with no
re-keying and no broken step (Greenfield churned on exactly this failure — don't repeat it).

**Step 3 — Q4 (prove and extend):** GA ERP sync #1. **Use the Tindall renewal as the public proof point**
that reconciliation is solved. Then build ERP #2. Re-measure NRR.
*Gate to keep going on a 3rd ERP / further sync depth:* NRR back above 100% and measurable migration of
heavy-CSV-export accounts onto native sync.

**Standing gate (all half):** No enterprise feature work begins until a finance-championed enterprise deal
signs. If pipeline pressure mounts, the answer is the talk-track, not the roadmap.

**What success looks like by end of H2:** NRR back above 100% (driven by sync stopping back-end churn +
routing-led expansion), the ~$160k mid-market cluster largely closed, and a defensible "strong at both
ends" position while Synthesis is still strong at only one.
