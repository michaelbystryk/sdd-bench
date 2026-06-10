# Stacklet — Builder Activation Discovery

*Prepared for next week's planning. Goal: understand why new accounts stall before
reaching a tool their team uses, then find out the truth cheaply — before committing
a quarter to onboarding, an editor redesign, or power features.*

---

## Problem framing

The leak is **up-front and pre-money**, and it concentrates at one step. Signup→land-in-app
is healthy (>90%); then under a third of accounts ever connect a data source, and under
half of *those* publish a tool a second person opens. Downstream is fine — accounts that
reach a used tool stick (low single-digit paid churn). So this is an **activation** problem,
not a retention or monetization one.

Sharper than "people poke around and don't build anything": **the typical new account is a
non-technical ops person whose real job is "make a recurring manual pain go away" — and the
job dead-ends at the data-connection step, which is effectively a network-admin task we've
handed to someone without the permissions or vocabulary to do it.** Three independent signals
point the same way and reconcile the conflicting stories:

- **The engineer correlation** — used accounts skew heavily toward having an engineer. Most
  likely this is a *proxy*, not a cause: an engineer is "someone who can read a connection
  string and open a firewall," i.e. the person who can clear the wall. [ASSUMPTION — the
  doc gives correlation, not the mechanism; this is our leading read, not established.]
- **The ~4-day median to first connection** — far too slow to be UI friction. It's the
  round-trip latency of "go ask someone with infra/credential access," which fits the
  cross-functional-blocker story.
- **Support's top ticket category is data connections** — many are customer-side firewall/
  IP-allowlist issues (DB unreachable from Stacklet's cloud); some are genuine SSL/connection-
  string confusion.

**Honest about what we don't know.** We have **no in-session instrumentation**, so *where* and
*why* people stall before they drop is inferred from funnel endpoints, not observed. The ~4-day
median is computed **only over people who eventually connect** — a survivor's clock that hides
how bad it is for the 2/3 who never connect. And the publish→2nd-person drop may be a *distinct*
collaboration/sharing failure we haven't separated from the connection cliff.

This reframing **demotes the loud voices**: an editor redesign polishes a room most users never
reach (they die before the canvas); power features serve the ~20% who already won. Neither is
where the majority leaks.

---

## Hypotheses (ranked)

| # | Hypothesis | Why we rank it here | Confidence |
|---|------------|---------------------|------------|
| 1 | **The connect step is a cross-functional/infrastructure blocker** — non-technical ops users can't make their DB reachable (firewall/IP-allowlist) or decode connection strings/SSL without an engineer. | Explains all three signals at once: 4-day lag, engineer skew, top support ticket. Strongest fit. | Medium-high |
| 2 | **No fast path to value without a production DB** — the majority's data lives in Sheets/Airtable/CSV, but first value is gated behind connecting a "real" database. | Fits the role mix (60% ops/founder) and the connect cliff; testable cheaply. | Medium |
| 3 | **Onboarding/guidance gap** (Sales' wizard theory) — people don't know what to do in session 1. | Plausible but **downstream** of #1–2: a wizard that leads into a closed port is still a wall. Partly real for the SSL/connection-string subset. | Low-medium |
| 4 | **Editor/canvas is the bottleneck** (designer's theory) — drag-and-drop confuses people. | Only bites *after* connecting data; most users never get there. Likely a real-but-secondary problem for activated users. | Low |
| 5 | **Missing power features** (power users' theory) — custom JS, version control, staging. | Serves the already-activated ~20%. An expansion/retention lever, not an activation one. | Very low (wrong funnel stage) |

---

## Riskiest assumptions

The beliefs we'd be *betting on* that would hurt most if wrong:

1. **That the connection failure is a UX/guidance problem solvable by onboarding.** If it's
   actually *infrastructure unreachability* (a closed port we can't open from our side), no
   wizard, template, or copy change moves the number — and Sales' direction burns a quarter.
   *This is the single most expensive belief to get wrong.*
2. **That "get an engineer involved" is the lever.** If "engineer" is just a proxy for
   "someone who can clear the connection," then the fix is removing the obstacle (e.g. an
   outbound agent/tunnel, or managed Sheets/CSV sources), not chasing a more technical buyer.
3. **That a connected production database is required for first value at all.** If the
   majority's job is servable from a Sheet or uploaded CSV, we've been gatekeeping value
   behind the one step they can't do.
4. **That the publish→2nd-person drop is the same problem as connect.** It may be a separate
   sharing/collaboration failure that no connection fix touches.
5. **That templates work.** The "template-starters activate better" signal is unvalidated and
   self-selected (motivated users pick templates); worth ~zero as evidence today.

---

## Discovery plan

Cheap, fast checks — all runnable in the next 1–2 weeks, none requiring a build. Each is
designed to resolve one riskiest assumption, with explicit validate/invalidate criteria.
**Run #1 and #2 first — together they settle the most expensive fork (infra vs. UX).**

| # | Test (cheap & fast) | Targets assumption | ✅ Validates (we're right) | ❌ Invalidates (we're wrong) |
|---|---------------------|--------------------|----------------------------|------------------------------|
| 1 | **Connection-error taxonomy from existing logs.** Bucket every failed connection attempt: TCP timeout/refused (reachability), auth/SSL handshake (config), DNS/host-not-found (wrong target), driver/source mismatch (wrong source). Segment by account role. | #1, #2 | Timeouts/refused dominate **and** skew non-engineer accounts → it's *infrastructure*, fix is architectural (agent/tunnel), not a wizard. | Auth/SSL dominate → it's *UX-confusion*; a better connection form/guidance helps. Spread across sources → wrong-data-source guidance problem. |
| 2 | **5 watch-them-do-it usability sessions** with non-technical ops signups doing a real first-session. | #1, #4 | 3+ stall at credentials/connection *before* reaching the canvas → wall is upstream, editor is not the leak. | They sail through connection and freeze at the canvas → editor redesign earns its place. |
| 3 | **Session-1 exit micro-survey** at drop-off: "What stopped you today?" (free-text + a few buckets). Run ~2 weeks. | #1, #3 | Top answers cluster on "didn't have connection info / needed IT / couldn't connect" → confirms the connection wall. | Top answers are "didn't understand the builder / didn't see how to start" → shifts weight to onboarding/editor. |
| 4 | **Pre-connected sample-data A/B.** Route half of new signups into a path that starts on a pre-connected demo dataset (no connection required to build). | #2, #3, #5 | Treatment activation (publish + opened-by-2nd) jumps materially → value is gated by data-access, not design; a "start without your own DB" path is the unlock. | No lift → first value genuinely needs *their* data; the connection problem must be solved head-on, not bypassed. |
| 5 | **Support-ticket audit, ~30 connection tickets.** Code each as "blocked by firewall/network" vs. "confused by connection string/SSL" vs. "wrong data source," and note emotional state. | #1 | Mostly firewall/network-blocked → reinforces infrastructure read; prioritize an outbound-agent/managed-source direction. | Mostly confusion → prioritize connection-UX and guidance. |
| 6 | **Templates clean read** (de-confound): compare activation of template-starters vs. not, *controlling for* whether they connected data / role. If feasible, randomize which users see templates first. | #5 | Template effect survives controls / randomization → templates genuinely help; invest. | Effect disappears once you control for intent → it was self-selection; don't build the roadmap on it. |

**Decision rule for next week:** don't fund onboarding, editor, or power features yet. Spend
~2 weeks on tests #1–#3 (cheap, fast, low-effort). They will tell you whether the wall is
*infrastructure* (→ rethink the connection architecture: outbound agent/tunnel, or lean on
already-reachable Sheets/Airtable/CSV for first value) or *UX* (→ targeted connection-flow and
onboarding work). Either way you'll be acting on the typical account's real blocker — not the
loudest voice in the room.

---

*Method note: this discovery was pressure-tested by four independent perspectives (Product,
Analysis, UX, Architecture). They converged on the connection-step wall and independently
demoted the editor-redesign and power-feature theories — but deliberately left the
infrastructure-vs-UX fork open, because that is the cheapest, highest-stakes thing to resolve
first.*
