# Builder Activation — Discovery

## Problem framing

The funnel, in round numbers: of every 100 accounts that land in the app, under a
third (~30) connect a data source, and well under half of those (~12) publish a
tool a second person opens. That is **two unequal leaks**, and the distinction
matters because the competing internal theories each aim at a different one:

- **Leak 1 — land → connect:** ~70 of every 100 accounts die here. This is the
  dominant bleed.
- **Leak 2 — connect → used tool:** ~18 of every 100 die here. Real, but smaller.

The sharper framing: **our majority persona hits a minority-skill gate at the
front door.** ~65% of signups are non-technical (ops + founders); only ~20% are
engineers. Yet activation correlates heavily with having an engineer on the team.
The first required step — connecting a data source — is the one genuinely
engineering-shaped task in the product: credentials, host/port, SSL, and a
customer-side firewall/IP-allowlist so their database is reachable from our cloud.
The ~4-day median to first connect (for accounts that succeed at all) is the tell:
that is not a UX-friction number measured in clicks — it is the signature of an
**off-platform hand-off** ("I had to ask IT for credentials / to open the
firewall"). Most accounts never complete that hand-off.

So the problem is probably not "the editor is confusing" or "we lack power
features." It is more likely that **the typical new account is a non-technical
person asked to perform a technical, often cross-team task before experiencing any
value.**

**What we genuinely don't know:** we have *no in-session instrumentation*. "Loss
happens at connect" is inferred from funnel totals, not observed. We can't yet
distinguish *can't connect* (no credentials/network access — a capability gate)
from *won't connect* (never saw why it's worth chasing IT — a value gate), and we
can't rule out that some users bounce off an empty editor *before* reaching the
connect step. Every theory below is narration over that blind spot, and the plan's
first job is to remove it. [ASSUMPTION] The "used by a 2nd person" metric is a
collaboration/value proxy; we treat reaching it as the activation goal.

## Hypotheses (ranked)

| # | Hypothesis | Why this rank |
|---|------------|---------------|
| H1 | **Connection is a technical gate the non-technical majority can't clear alone** (credentials, firewall/allowlist, SSL — needs IT/engineering). | Strongest evidence: activation ↔ engineer presence; top support tickets are connections/firewall; 4-day median implies a cross-team hand-off. Explains the biggest leak. |
| H2 | **No value is experienced before the gate**, so users won't push through it (or wait on IT). Value is locked behind connecting *production* data. | 4-day gap means the first session isn't about connecting — yet nothing else delivers a "win." Templates *may* help but are untested. Overlaps H1; distinct fix (sample data / decouple value from the gate). |
| H3 | **Generic onboarding/orientation gap** (Sales' "too hard to start") — people land, don't know what to do, bounce before attempting anything. | Plausible and cheap to test, but less specific; the engineer-correlation points at a *technical* gate, not a generic wizard gap. Partly subsumed by H2. |
| H4 | **The editor canvas confuses people and they bounce off it** (designer's redesign). | Most loss is at connect, *before* meaningful editor use; if the editor were the wall, activation wouldn't track engineer-presence (engineers aren't better at drag-and-drop). Can't rule out pre-connect bounce without replay — but unlikely to be the primary leak. |
| H5 | **Users need more power features** (custom JS, version control, staging). | Least credible for activation. The voices are *survivors* — larger companies with engineers, already activated. Survivorship bias; this serves retention/expansion of the activated minority, not the up-front bleed. Building it optimizes for the loudest, least representative users. |

## Riskiest assumptions

These are the beliefs underneath the favored direction (H1/H2) that would hurt most
if wrong — ordered by damage:

- **A1 — Accounts die *at* connect, not *before* it.** We infer this from funnel
  totals. If they actually bounce off an empty editor in the first minute,
  H1/H2 are aimed at the wrong step. *Highest-stakes bet.*
- **A2 — Failures are mostly *can't* (capability/permissions/network), not *won't*
  (motivation/understanding).** The two demand opposite fixes: provisioning help
  vs. value/orientation. Building for the wrong one wastes the quarter.
- **A3 — The gate is *capability*, not *copy*.** If the connection form is merely
  confusingly worded, a two-day rewrite fixes it and there's no strategy to debate.
- **A4 — The 4-day gap is an off-platform hand-off** (waiting on IT/credentials),
  not procrastination by people who could connect in 5 minutes.
- **A5 — The templates "lift" is causal**, not selection bias from motivated users
  self-selecting into templates.

## Discovery plan

All runnable in the next 1–2 weeks; none is a quarter-long build. Sequenced so the
cheapest, highest-leverage diagnostics come first.

| Test (for assumption) | What to do | Validates → | Invalidates → |
|---|---|---|---|
| **1. Watch the first session** (A1, A3) | Add basic connect-flow event tracking + a session-replay tool (PostHog/FullStory). Watch 20–30 sessions of accounts that landed and never connected. ~3 days to instrument, days to watch. | If they reach the connect modal, attempt, and error/abandon → connect is the wall (H1). | If they bounce *before* the modal → orientation/editor (H3/H4) comes back into play. |
| **2. Slice the funnel + error telemetry** (A2) | Split the existing connect funnel by role (ops/founder/engineer). Log whether a connection *attempt* errored (SSL/timeout/auth) vs. was never opened. Uses data we already capture. | Engineers connect far higher; non-engineer attempts error out → technical-capability gate (H1). | Similar connect rates across roles → not a capability gate; reweight toward H2/H3. |
| **3. Interview stalled accounts** (A2, A4) | Categorize the last ~100 connection support tickets (firewall vs. credentials vs. SSL-confusion vs. UX). Call/email 6–8 stalled non-technical accounts: "you connected nothing — what happened?" | Majority cite "needed IT / DB unreachable / no credentials" → *can't* + hand-off confirmed (H1, A4). | Majority cite "didn't see the point / couldn't figure out the app" → *won't*; shift to H2/H3. |
| **4. "Try with sample data" fake-door** (H2) | Add a path to build a tool on demo/sample data with no connection required — start as a fake-door button measuring click-through, then a lightweight real version. | A meaningful share choose it and go on to build/return → value-before-gate works; decouple value from connect (H2). | Few click, or click but don't return → value isn't gated by the connection; problem is elsewhere. |
| **5. Connection concierge (Wizard-of-Oz)** (A1, A2) | For ~15–20 new non-technical signups, offer live human help connecting (call/async: allowlist instructions, credential checklist, IT-invite). No product build. | Concierged accounts activate far higher → connection gate confirmed; productize *assistance*, not editor. | Even hand-held, they don't build/return → fit/value problem deeper than connection. |
| **6. Clean templates A/B** (A5) | Randomize new accounts into template-prominent vs. blank-canvas first run; compare activation at equal motivation. | Template arm activates higher → templates are causal; invest in them. | No difference → prior "lift" was selection bias; stop crediting templates. |

**Decision logic.** Run tests 1–3 first (pure diagnostics, ~1 week, mostly data we
already have). If they confirm A1+A2 (die at connect, mostly *can't*), tests 4–5
tell you whether to invest in **value-before-the-gate** (sample data/templates) or
**provisioning assistance** (guided allowlist, credential checklist, an
"invite your engineer/IT" hand-off flow) — neither of which is the wizard, editor
redesign, or power features the loudest voices are asking for. If test 1 instead
shows pre-connect bounce, reopen H3/H4 before committing anything.
