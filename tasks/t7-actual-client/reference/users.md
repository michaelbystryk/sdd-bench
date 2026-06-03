# Users — Actual Budget's user base + the three personas v1 is for

Context for the engineering team building the Actual web client. This is the user base v1 is shipping to, the three personas the intent doc is designed around, and the research data behind both. Treat this as the user-truth source; build for these moments, not for hypothetical edge users.

---

## 1. The user base, at a glance

As of April 2026:

- **~42,000 monthly active users** across deployment shapes (self-hosted, hosted offering, dev/local-only)
- **~7,400 paid seats** on the hosted offering, growing 28% QoQ
- **~31,000 self-hosters** on personal VPSes, home labs, Synology NASes, Raspberry Pis, Fly.io free tiers
- **Long tail of dev/local-only** we can't count (probably 3–5K)
- **~140 active community contributors** (have merged at least one PR in the last 12 months)
- **~1,200 active community members** (Discord + GitHub Discussions, monthly)
- Median user has been on Actual for **18 months** and is on their **second budget** (typical churn-and-restart-of-categories pattern)

### Geographic + currency mix

- **~55% North America** (US + Canada), mostly USD with a meaningful CAD slice
- **~30% Europe** (UK, Germany, Netherlands, France leading), GBP / EUR
- **~10% AU/NZ**, AUD/NZD
- **~5% rest of world**
- Currency support in v1: whatever the budget config declares. Symbols come from the budget, not the client.

### Deployment mix

- Self-hosters dominate by count; hosted offering dominates by revenue and our ability to measure anything.
- Most self-hosters run on **Docker** (62% per the Q1 survey), then **bare Node** (18%), then **PikaPods** (8%), then **Fly.io** (7%), then long-tail.

## 2. The three personas v1 is for

These are the personas we tested with in Q1 research. They're not arbitrary — they came out of the survey clustering. v1 is designed around all three; we don't expect to build persona-specific flows.

### 2a. The Household Couple

**Largest segment by far.** Roughly two-thirds of active users by activity volume. Often the original onboarder is one partner, the second partner is a "view + occasional write" collaborator, and both treat the budget as a household decision.

**Demographics:** late-20s to mid-40s, dual-income, one-to-three accounts, often with kids, usually post-YNAB or post-spreadsheet. Self-hosted: ~70%; hosted: ~30%.

**The defining moment:** the **monthly budget meeting**. One partner runs the desktop app, the other sits next to them, and they walk down the envelope list for the new month, allocating amounts. This is a *ritual* for them — they value it. It's how they have the money conversation without it becoming an argument.

**Friction today:** the desktop app is on one person's laptop, in one room. The meeting either happens in that room (often not the room they actually relax in) or one person reads numbers while the other types. The mobile app is read-only; you can't do the meeting on the iPad in the living room. They've been asking for "real web" for years.

**What they want in v1:**
- The envelope view on a tablet/laptop they bring to the couch
- Inline allocation that feels fast and doesn't require modals
- Mid-cycle "did we overspend?" glances from any device

**What they're not asking for in v1:** reports (they have a sense; charts are a nice-to-have not a need), schedules (they already set them up), account CRUD.

### 2b. The Solo Self-Hoster

**~25% of the base.** One person, often technical, runs Actual themselves. Frequently the kind of person who'd run their own Vaultwarden, a Pi-hole, an Immich instance. Cares deeply about data ownership.

**Demographics:** typically male, 25–45, software/IT professional or hobbyist. Predominantly self-hosted (~95%) on a home lab or personal VPS. Single-tenant by definition.

**The defining moment:** the **post-purchase quick log**. Just left the store, just paid for a meal, just got an Amazon delivery — they want to log the transaction *now* before they forget. Currently they either wait for nightly OFX import (and many transactions slip through), or they open the mobile companion (read-mostly, and writing is awkward).

**Friction today:** mobile companion is too limited; opening a laptop is too slow. They want a web client that loads fast on a phone in the kitchen.

**What they want in v1:**
- A "+transaction" flow that's 4 taps or fewer
- Fast cold start on phone Safari/Chrome
- Bookmark on the home screen, treat it like a PWA even without a real install

**What they're not asking for in v1:** anything multi-user, anything fancy. Boring is good. Fast is better.

### 2c. The Side-Business Operator

**~8% of the base but disproportionately on hosted offering** (skew: ~40% hosted vs the base's ~17%). Pay for hosted because they're running business finances on it and want SLA-ish reliability without DIY operational burden.

**Demographics:** sole proprietors, two-person consultancies, freelancers, indie SaaS founders. They picked Actual over QuickBooks because they're tech-comfortable, value envelope budgeting for cash management, and don't need QuickBooks' tax-prep features (or they use a separate tool for that).

**The defining moment:** the **mid-cycle category check**. "Do I have budget for this hire / this conference / this contractor?" — answered in seconds, from whatever device is in front of them.

**Friction today:** the desktop app means they have to switch contexts and open Actual on their main laptop. They want the answer faster, often from a tablet or another laptop.

**What they want in v1:**
- The envelopes view, accessible quickly, accurate at-a-glance
- Quick transaction entry when a contractor invoice or one-off purchase happens
- Cents accuracy (their numbers feed their accountant)

**What they're not asking for in v1:** multi-user, audit trail, role-based access. They're solo or close to it. (Those are real v2+ asks; not now.)

### Persona segments that v1 is NOT designed around

To clarify what's deliberately outside the v1 frame:

- **The fully-mobile single user** who wants Actual to be a mobile-first product. We have the React Native mobile companion; v1 web is a different product.
- **The reports power user** who wants charts + trends. v1.5 conversation.
- **The reconciler** who wants OFX import / Plaid setup on the web. Desktop owns it; ops cost of bringing it to web isn't justified in v1.
- **Teams of 5+ on a shared budget.** Out of scope. We don't model multi-user in the data layer; not changing that for v1.

## 3. The survey data (Q1 2026)

Full report at `internal/research/2026-q1-survey-summary.md`. Highlights below.

**n = 812** active users (mix of hosted + self-hosted; oversampled hosted for measurability).

### Top requested features

| # | Feature | % of respondents | Notes |
|---|---|---:|---|
| 1 | **Real web client** | 73% | The headline finding |
| 2 | Better reports | 54% | v1.5 candidate |
| 3 | Plaid integration parity (web/desktop) | 38% | Desktop-side |
| 4 | CSV improvements | 31% | Desktop-side |
| 5 | Multi-user / household accounts | 24% | Not v1 |
| 6 | Native mobile app (replacing companion) | 22% | Separate roadmap |
| 7 | Recurring-transactions UI improvements | 20% | Desktop-side |
| 8 | Goals / debt-payoff views | 18% | v2+ |

**73% wanted "real web"** — the strongest single signal we've ever had from a community survey. Free-text responses converged on three themes:

1. "I can't do the budget meeting on the iPad / TV / couch where we actually have it" (Household Couple)
2. "I want to log transactions on my phone without the mobile companion's read-only feel" (Solo Self-Hoster)
3. "I run my business on this, I need it not chained to one laptop" (Side-Business)

These three themes seeded the three personas in §2.

### What they DON'T want

Open-text responses on "what's important Actual NOT do":

- Don't add telemetry / analytics (mentioned ~280 times, often unprompted)
- Don't move to a hosted-only model (mentioned ~180 times)
- Don't break self-host compatibility (mentioned ~150 times)
- Don't pivot away from local-first principles (mentioned ~110 times)

These shape the constraints in `brief.md` §8.

## 4. The "Web Client" GitHub Discussion

github.com/actualbudget/actual/discussions/1247 — open since July 2024, top-voted Discussion on the repo for 22 consecutive months, **+847 reactions** (the next-highest open discussion has ~310).

Highest-reaction comments cluster around three asks, mirroring the personas:

- "Please let me allocate envelopes on my iPad without screen-sharing my partner's laptop" (Household)
- "Please give me a real web app I can bookmark on my phone for transactions" (Self-Hoster)
- "I'd pay for hosted just to have web" (Side-Business — and many actually have)

We're not building this discussion's full wish list. We're building the **headline ask** (a real web client) with the five features that make the moments people described actually work. Closing this discussion at launch is part of the success picture (§4 of `brief.md`).

## 5. Hosted-offering context

The hosted offering's growth is what's funding this build:

- 7,400 paid seats as of April, growing 28% QoQ
- Mix: ~$8/seat/month (annual) and ~$12/seat/month (monthly)
- Churn drivers per exit-survey (rank-ordered):
  1. "Stopped using budgeting altogether" — life event, not our problem
  2. **"Went back to YNAB because Actual doesn't have a web app"** — the #1 *addressable* reason
  3. "Hit a sync bug" — desktop issue, separate roadmap
  4. "Wanted features we don't have (Goals, advanced reports)" — v2+

Reason #2 is the one this web client is directly meant to remove. Closing the gap is a churn-reduction lever, not just a feature add.

## 6. What to build for, in one paragraph

If you forget everything else in this file, remember this:

> Two-thirds of our users do envelope budgeting as a household ritual and they want to do it on the couch, not at a desk. One-quarter want to log transactions from their phone in the kitchen without feeling like they're using a read-only mobile companion. The remaining ~8% are running small businesses on this and want category checks in seconds from any device. The same five features (`brief.md` §5) serve all three. If you build the envelope view and the inline allocation so well that the Household Couple does the budget meeting on an iPad in seven minutes, you've shipped v1.
