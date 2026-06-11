# Builder activation — discovery

*Prepared for Priya ahead of planning. Goal: frame the problem honestly, rank why
new accounts stall, name the beliefs we'd be betting on, and lay out cheap checks
to run in the next 1–2 weeks.*

## Problem framing

Your framing — "people sign up, poke around, never build anything real; the leak
is somewhere in the middle" — is right but blurry in two ways worth sharpening.

**There are two leaks, not one, and they differ in kind.** Of 100 accounts that
land in the app, ~30 ever connect a data source and ~12–14 reach a tool a second
person opens. *(Figures inferred from your "a bit under a third" / "well under half
of those." [ASSUMPTION])* The dominant leak is **land → connect a source** (we lose
~70). The secondary leak is **connect → published, used tool** (we lose more than
half of the survivors). These almost certainly have different causes, and most of
the debate in the doc is aimed at the *second* leak (editor, power features) while
the bigger one is the *first*.

**The first leak looks like an access problem, not a usability problem.** Four
independent signals point at the data-connection step specifically: (1) it's the
largest single drop; (2) it's Support's top ticket category, dominated by
firewall/IP-allowlist and credential issues — i.e. things outside our UI; (3)
median time-to-connect is ~4 days, not minutes, which is the signature of an
*out-of-app dependency* (waiting on credentials, on IT to open a port), not of
in-session UI confusion; (4) accounts that succeed skew toward having an engineer —
the person who can produce a connection string, hold DB credentials, and change a
firewall rule. Meanwhile ~80% of signups are non-technical (ops/founder).

So the honest reframing: **we put a task that requires database access, credentials,
and network reachability in front of a mostly non-technical audience — before
we've delivered any value — and the people who clear it are the ones who happen to
have an engineer.** "Too hard to get started" (Sales) is the right symptom; "needs
a wizard" is probably the wrong cure, because a wizard doesn't open a firewall port
or grant someone DB access.

**What we genuinely don't know:** in-session behavior (no instrumentation); whether
non-connectors have a real job-to-be-done or are tire-kicking; whether removing the
data gate reveals a *second* wall in the editor; and whether templates cause
activation or just attract motivated users. The plan below is built to resolve
exactly these unknowns cheaply.

## Hypotheses (ranked)

| # | Hypothesis | Why this rank |
|---|-----------|---------------|
| H1 | **Connecting real data is gated behind credentials / network access the typical signup can't self-clear.** The engineer, not the editor, is the unlock. | Strongest: 4 converging signals (largest drop, top ticket = firewall/creds, 4-day median, engineer-correlation). Explains the data better than any single-team theory. |
| H2 | **Value is sequenced behind the hard step — no early win before connecting real data.** Motivation has to survive a multi-day technical setup with nothing delivered yet. | Adjacent to H1; explains why a 4-day gap kills accounts even when connection is technically possible. Templates are a partial, unproven probe at this. |
| H3 | **Audience/ICP mismatch** — marketing attracts ops/founders the product can't yet serve self-serve without an engineer. | Plausible and partly a restatement of the engineer-correlation, but less directly actionable than H1/H2 and harder to fix fast. |
| H4 | **Editor/canvas usability** (designer's theory). | Real, but affects the *second* leak (connect → publish), not the dominant one. Most non-activators never reach the editor in earnest. No instrumentation, so not ruled out — just not where the signals point. |
| H5 | **Missing power features** (power users' theory). | Lowest for activation. These users are already activated, at companies *with engineers* — classic survivorship bias. Relevant to expansion, but paid retention is already fine. |

I'm deliberately disagreeing with two of the loudest voices: the power users are
the wrong sample for an activation question, and the designer's editor redesign
targets the smaller, downstream leak. Sales is closest to the truth but likely
prescribing the wrong remedy.

## Riskiest assumptions

If H1 is the direction we pursue, these are the beliefs that would hurt most if
they're wrong — roughly in order of damage:

- **A1 — The land→connect drop is mostly access/credentials/network, not in-app
  connection-string/SSL confusion.** If it's actually UI confusion, the fix is
  better connection UX, not an access workaround.
- **A3 — Non-technical users would reach value *if the data gate were removed.*** If
  ops users stall in the editor even with data connected, fixing connection just
  moves the cliff downstream (and H4 matters more than I ranked it).
- **A2 — The 4-day median reflects an out-of-app dependency, not just low urgency.**
  If it's weak motivation/forgetting, the lever is activation nudges, not removing a
  technical gate.
- **A4 — A meaningful share of non-connectors are "stuck wanters" with a real
  job-to-be-done**, not tire-kickers. If most are just browsing, activation work has
  a low ceiling and the real lever is top-of-funnel qualification.

## Discovery plan

Cheapest first; each maps to an assumption with explicit validate/invalidate
criteria. All runnable inside two weeks. *(Assumes we have basic product analytics,
can email/in-app-survey stalled accounts, and can run a simple A/B. [ASSUMPTION])*

**0. Re-cut the existing funnel by role at each step — ~1 day, query only.**
*Tests:* where each segment falls off. *Validates H1/H3* if non-engineer accounts
drop disproportionately at the **connect** step specifically. *Invalidates* if they
drop at the **editor** step instead (→ H4 rises). Costs nothing; do it first.

**1. Tag the last ~60–100 connection tickets + server-side connection-attempt error
logs — 2–3 days.** Classify each as network/firewall vs. credentials/permission vs.
connection-string/SSL-UI vs. other (timeout/refused = network; auth-failed = creds).
*Tests A1.* *Validates H1* if the majority are network/access/credentials.
*Invalidates* if the majority are in-app UI confusion (string format, SSL toggle) →
this becomes a UX fix.

**2. One-question survey to stalled non-connectors — set up in a day, read after a
week.** "What's stopping you from connecting your data?" → don't have credentials /
our database isn't reachable / didn't know how / no time / just exploring. *Tests
A2 + A4.* *Validates* if credentials/reachability dominate. *Invalidates* if "just
exploring / no time" dominates (→ motivation/ICP problem, different fix).

**3. 5–8 interviews with stalled ops/founder accounts — 1 week.** Depth on the why
and whether there's a concrete tool they wanted to build. *Tests A4.* *Validates* if
most name a specific real team need they couldn't reach. *Invalidates* if most were
casually evaluating with no job-to-be-done.

**4. Concierge / sandbox test — 1 week, no build.** Take 5–10 fresh non-technical
signups; hand-hold them past the data gate (do the technical part for them, or drop
them into a pre-connected dataset) and watch whether they then build and publish a
useful tool. *Tests A3 — the single most important and most-overlooked bet.*
*Validates H1/H2* if, once past the gate, ops users build something real.
*Invalidates* if they connect but still stall in the editor (→ H4 is the real wall).

**5. Templates A/B — 1–2 weeks, if plumbing allows.** Randomize new signups to
templates-first vs. blank-canvas-first; compare connect & publish rates. *Resolves
the selection-bias question you flagged.* *Validates H2* if the randomized
template-first cohort activates more. *Invalidates* if rates are equal (templates
were just attracting motivated users).

**Decision rule:** if Steps 0–2 confirm access/credentials as the dominant blocker
and Step 4 shows ops users build once past it, the quarter goes to *removing or
deferring the data gate* (sample-data path, an "invite your engineer to connect"
flow, network-reachability diagnostics) — not to a wizard, an editor redesign, or
power features.
