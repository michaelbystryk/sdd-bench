# ADR-001: EU Data Residency via Regional Cells

- **Status:** Proposed (for CEO sign-off this week)
- **Date:** 2026-06-10
- **Owner:** Engineering (tech lead + team of 6)
- **Decision driver:** Contractual EU data-residency deadline, ~4 months out.

---

## Context

Three forces hit us in the same quarter. They look related, so it's tempting to
solve them with one big move. Only one of them is actually load-bearing on a
clock we don't control, and being clear about that is the whole decision.

1. **EU data residency — the hard deadline.** Our largest deal (~$280k ARR, a
   ~600-location German/French franchise group, with a similar EU pipeline
   behind it) is contractually contingent on EU-resident end-customer personal
   data being **stored and processed inside the EU**. Legal says the clause is
   non-negotiable and "when in doubt, treat data as in-scope." Our single
   Postgres lives in `us-east`. We have ~4 months. EU is also ~15% of new
   signups and rising — this is a market direction, not a one-off.

2. **APAC latency — a softer deadline.** A reseller's AU/SG book (~$190k ARR,
   renewal in ~7 months) sees booking-page p95 ~1.9s vs ~600ms in the US,
   almost entirely round-trips to `us-east`. Their renewal carries an SLA of
   p95 < 1.2s. The booking page makes several *sequential* availability calls,
   so the round-trip cost compounds.

3. **The monolith-split argument.** The standing question of whether to break
   `routable-web` (Rails, ~140k LOC, ~280 GB Postgres, Sidekiq/Redis on a
   Heroku-style PaaS) into services — booking, payments, notifications,
   calendar-sync. The EU work makes it concrete: if we're standing up a second
   region anyway, is now the moment to pull it apart?

**The constraints that actually decide this:** 6 engineers, **hiring frozen**
for ~8 months, no SRE/DBA/platform team, on-call is all of us, and *nobody has
run a multi-service production system*. A previous attempt to extract one
service (`notify-svc`, 18 months ago) was abandoned half-done. The team values
its boring `git push` deploys and one-click rollback, and says so often.
Budget can roughly double (~$11k → ~$22k/mo) without a fight; "rewrite" will
not get CEO support, "whatever keeps the EU deal" will. The PaaS offers EU
regions but **no managed multi-region database** — cross-region data is on us.
Our payment processor is global and stores tokens processor-side, so the money
path carries no residency burden. We have **no PII column classification** and
tagging it across the schema is unscoped, nontrivial work nobody owns.

We need a decision we can execute next week. The EU clock is the thing that
doesn't move.

---

## Options considered

### Option A — Regional cells: stamp the monolith per region (recommended)

Deploy the **same** monolith as an independent "cell" per region — each cell is
a full app + its own Postgres + its own Redis/Sidekiq on the PaaS we already
use. Every tenant (business) is pinned to a **home region**. A thin, global,
**PII-free** directory maps `tenant → home cell` and routes booking-page/widget
and login traffic to the right cell. Stand up `eu-central` first for the
deadline; reuse the identical pattern for an APAC cell later to solve latency.

- **Pros**
  - **Residency by construction.** An EU tenant's *entire* dataset lives only
    in the EU cell, processed by EU compute. We never have to classify which
    columns are PII — the unscoped schema-tagging problem disappears, and
    legal's "when in doubt, in-scope" posture is satisfied trivially. The audit
    story is one sentence: "EU data is in `eu-central`, full stop."
  - **One mechanism solves residency *and* latency.** The same cell pattern
    that satisfies the contract also puts compute near APAC users later.
  - **Keeps the monolith** — the team's actual strength. Same deploy artifact,
    same boring `git push`, same one-click rollback, in every cell. No new
    distributed-systems competency required to ship the deadline.
  - **Hot path stays local.** A booking write (availability → hold → deposit →
    appointment) is a single in-cell transaction. No cross-region hops on the
    money path.
  - **Blast-radius isolation** — an incident in one cell doesn't touch the
    others. This is the resilience benefit people actually want from a split,
    without the distributed-transaction cost.
  - Fits budget; defers, but does not foreclose, a future service split.
- **Cons**
  - **Operational multiplication** is the real tax: 2 (soon 3) production
    environments, N× deploys, N× schema migrations, N× on-call surface — for 6
    people with no SRE. This is the cost we are most consciously taking on.
  - New code to build and operate: the routing directory and a
    region-aware tenant-provisioning flow (a new failure mode if it's down).
  - We must decide what, if anything, is "global." We keep that surface
    minimal (routing metadata only). Cross-cell analytics and any
    cross-region tenant move become real, if rare, work.

### Option B — Single global app, partition PII into an EU data store

Keep one deployment in `us-east`, classify PII columns, and route PII
reads/writes for EU end customers to an EU database while non-PII stays global.

- **Pros**
  - Conceptually "one system" — one codebase running once, no fleet to operate.
- **Cons**
  - Forces the **PII classification across a 140k-line schema** — the exact
    unscoped, owner-less work we'd rather not bet a 4-month deadline on.
  - Splits the **hot path across regions**: a single booking transaction now
    spans a US app and an EU PII store — cross-region latency and effectively a
    distributed transaction on the path that charges money, owned by a team
    with no distributed-systems experience. High risk, slowest to certainty.
  - **Does nothing for APAC latency** — still one app in `us-east`.
  - "When in doubt, in-scope" makes the PII boundary keep growing under us.

### Option C — Split into services *and* regionalize (the big-bang)

Use the forced infra spend to extract booking/payments/notifications/
calendar-sync and deploy them regionally.

- **Pros**
  - Settles the long-running argument; the two engineers keen on it get their
    wish; genuine learning and résumé value.
  - In theory, services can scale and deploy per-region independently.
- **Cons**
  - This is the "rewrite" the CEO won't fund, on the one clock we can't slip.
  - Demands a capability the team has **never had and cannot hire for** during
    the freeze; the abandoned `notify-svc` is direct evidence we don't finish
    extractions under load.
  - Turns the booking hot path into cross-service transactions exactly when we
    have the least slack — *adds* deadline risk instead of reducing it.
  - Conflates an irreversible org/architecture bet with a compliance task that
    has a fixed due date. Two different decisions wearing one trench coat.

*(Rejected sub-option: a one-off single-tenant EU instance just for the
franchise. Fastest to ship, but it's a snowflake that doesn't serve the 15%-and-
rising EU signup trend and we'd rebuild it within a year. Not worth the detour.)*

---

## Decision

**Adopt regional cells (Option A). Stand up an `eu-central` cell to meet the
data-residency deadline, pin tenants to a home region behind a thin global
router, and keep the monolith intact. Sequence an APAC cell *after* EU ships to
satisfy the latency SLA. Do not split the monolith now.**

Concretely:

1. **A cell = the current monolith + its own Postgres + Redis**, identical
   artifact everywhere, deployed by one pipeline that fans out to all cells.
2. **A global, PII-free directory** maps `tenant → home cell` and routes
   widget/booking-page and login traffic. [ASSUMPTION] The global plane holds
   only non-personal routing metadata; *all* personal data — end-customer and
   business — stays in-cell, which keeps the global layer out of residency
   scope entirely.
3. **Residency is at tenant granularity.** [ASSUMPTION] We treat a business's
   home region as the residency boundary (an EU business's end-customer data
   lives in the EU cell). This covers the contractual case (an all-EU franchise)
   and the overwhelming majority of reality (a business's customers are local
   to it). Truly cross-border end customers — a US business's occasional EU
   walk-in — are a rare edge we flag to legal and accept for now.
4. **Rough sequence (fits ~4 months with buffer):** weeks 1–2, build the router
   + home-region provisioning; weeks 2–8, stand up and harden the `eu-central`
   cell with fan-out CI/CD and runbooks; weeks 6–12, migrate the franchise and
   existing EU tenants and cut over, defaulting new EU signups to EU; weeks
   12–16, audit evidence for procurement and slack.
5. **APAC, after EU:** stamp an `ap-southeast` cell for the reseller's tenants.
   As a cheap interim latency win that helps every region, **collapse the
   sequential availability calls into one round-trip** — that attacks the
   "latency compounds" problem directly, independent of geography.

**Why this over the others:** Option B puts a distributed transaction on the
money path and still owes us the PII-tagging work and the APAC fix — more risk,
less coverage. Option C bets the deadline on a competency we can't staff. Option
A is the only path that hits the fixed clock with tools the team already
operates, satisfies legal without a schema audit, and reuses one mechanism for
both the residency and latency problems.

---

## Consequences

**What it buys us**
- A credible, auditable path to the 4-month deadline and the $280k deal, using
  the deploy/rollback workflow the team already trusts.
- A residency story that needs no PII classification and no cross-region hot
  path.
- A reusable answer to APAC latency (the same cell), plus a round-trip
  reduction that helps all regions immediately.
- Regional blast-radius isolation, and a clean substrate if we *ever* choose to
  extract a service later — per cell, on our terms.

**What it costs us**
- **We are now a fleet operator with a 6-person team and no SRE.** N× deploys,
  migrations, and on-call surface. We pay this down with a single fan-out
  pipeline, deliberately identical cells, strict backward-compatible
  migrations, and per-cell runbooks. This is the line item to watch.
- New, load-bearing infra we didn't have: the router and provisioning flow.
- Cross-cell analytics now needs an offline rollup (today's read-replica
  analytics no longer sees one database); cross-region tenant moves become a
  data-migration task. Both real, both infrequent.
- Infra spend roughly doubles toward the ~$22k/mo ceiling as cells come online.

**What we are explicitly accepting or deferring**
- **Deferring the APAC cell** until EU ships. We accept SLA-breach risk for the
  first ~3 months of a 7-month renewal window, partially mitigated by the
  round-trip collapse. EU's fixed clock wins the contention.
- **Deferring the monolith split, indefinitely.** We accept that the two
  engineers who want it are disappointed; we redirect that energy into the
  router, the cell tooling, and the booking-endpoint consolidation — which is
  real distributed-systems-adjacent work, not a consolation prize.
- **Deferring full PII data-classification.** Cells make it unnecessary for
  residency; we may still want it later for other reasons.
- **Accepting tenant-granularity residency** and the cross-border end-customer
  edge case, pending a crisp line from legal.

---

## Revisit triggers

Reopen this decision if any of these fire:

- **Global surface creeps.** Standing up `eu-central` reveals materially more
  shared/entangled state than routing metadata — the "keep the global plane
  thin" assumption breaks, and we should re-scope before adding more cells.
- **Operations outrun the team.** On-call pain, failed cross-cell migrations,
  or deploy toil from the fleet become chronic — pause the APAC cell, invest in
  tooling, and take headcount back to the board with evidence.
- **Residency regimes multiply or diverge.** A second regime appears (UK,
  India, etc.), or one with semantics that *tenant-pinning can't satisfy* — at
  that point the router/provisioning layer must be promoted to a first-class,
  productized concern.
- **EU share crosses a structural threshold** (say >30–40% of revenue), making
  cell management central enough to justify dedicated investment or rethinking
  the topology.
- **APAC SLA is unmet even with a cell** — the bottleneck is the booking-page
  call pattern, not geography; revisit that page's architecture specifically.
- **Constraints loosen** — the freeze lifts or we hire an SRE — giving us the
  capacity to reconsider a more ambitious path (including a deliberate, *non*-
  deadline-driven service extraction, with cells as the substrate).
