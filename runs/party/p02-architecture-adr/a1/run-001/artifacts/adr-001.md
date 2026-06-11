# ADR-001: EU Data Residency via Regional Cells of the Monolith

- **Status:** Proposed (for CEO sign-off this week)
- **Date:** 2026-06-10
- **Owners:** Engineering (tech lead + 5)
- **Decision driver with a fixed clock:** EU data-residency clause, ~4 months to comply

---

## Context

Three forces landed in the same quarter, and they are pulling in different
directions. We have to move deliberately, not let one of them drag the other two
along by accident.

1. **EU data residency (hard deadline, ~4 months).** Our largest deal to date
   (~$280k ARR, a 600-location DE/FR franchise group, with a real EU pipeline
   behind it) is contingent on a non-negotiable clause: EU-resident end-customer
   personal data must be stored and processed in the EU. Our single Postgres
   lives in `us-east`. This is not a one-customer problem — ~15% of new signups
   this quarter were EU and rising — so whatever we build has to generalize, not
   just patch one tenant.

2. **APAC latency (SLA, ~7 months).** A reseller's AU/SG book (~$190k ARR) sees
   p95 booking-page load ~1.9s vs ~600ms in the US, almost all of it round-trips
   to `us-east`. Renewal requires p95 < 1.2s. The booking page makes several
   *sequential* API calls, so each round-trip compounds.

3. **The "should we have split the monolith already" argument.** The EU work
   means standing up infrastructure in a second region anyway, which has made a
   long-running hallway debate concrete: is this the moment to pull booking /
   payments / notifications / calendar into services?

The facts that constrain the answer: 6 engineers, **hiring frozen ~8 months**,
no SRE / no DBA, nobody has run a multi-service production system, on-call is the
6 of us. The team values its boring PaaS deploys and one-click rollback. We have
no feature-flag infrastructure and **no column-level PII classification** across
a 140k-line schema (a real, unscoped chunk of work). A prior service extraction
(`notify-svc`, 18 months ago) was abandoned half-done. Infra spend can roughly
double (~$11k → ~$22k/month) without a fight; anything beyond needs the CEO, who
backs "whatever keeps the EU deal" and is skeptical of "rewrite."

The reframe that drives this decision: **residency is a data-locality and
tenant-routing problem, not a decomposition problem.** Conflating it with
microservices is the most expensive mistake available to us right now.

> [ASSUMPTION] We treat residency at the **tenant (business) level**, not the
> individual end-customer level. The signed customer and the EU pipeline are
> EU-based businesses serving EU customers; a US salon with an occasional German
> walk-in is a rounding error we accept. This lets us route by tenant home
> region instead of classifying every row.

> [ASSUMPTION] Budget: an EU cell duplicates app + Postgres + Redis for a
> fraction of total traffic, ~+$5–8k/month — inside the "double" headroom.

---

## Options considered

### Option A — Minimal residency patch (split PII out of the single app)

Keep one app in `us-east`. Stand up an EU Postgres and move *only* EU
end-customer PII into it, either by classifying PII columns schema-wide or by
having the US app reach across the Atlantic for EU PII reads/writes.

- **Pros:** Smallest conceptual change. One codebase, one deploy pipeline, no
  routing layer. Cheapest line item.
- **Cons:** Requires exactly the work nobody has scoped — tagging PII across a
  140k-line schema — or it puts a transatlantic round-trip on the EU **booking
  hot path**, which is the one path a customer is staring at. Compliance becomes
  fragile and column-by-column, which is the worst posture to defend when legal's
  own line is "when in doubt, in-scope." It does nothing for APAC and doesn't
  generalize to 15%-and-rising EU growth. This is a hack that looks cheap and
  isn't.

### Option B — Regional cells of the same monolith *(chosen)*

Deploy the **same codebase** as an independent cell per region (`us-east`,
`eu-central`), each with its own Postgres / Redis / Sidekiq. Every tenant has a
**home region**; *all* of that tenant's data — config **and** PII — lives in its
home cell. A thin **global directory** (tenant → home region) plus the
auth/landing path resolves which cell a request belongs to; booking traffic then
stays entirely within one cell.

- **Pros:** Clean, defensible residency — EU tenants' data simply *is* in the EU,
  end to end, with no per-column argument. Sidesteps the PII-classification
  project entirely by keeping whole tenants local. Generalizes to EU growth and
  gives a **reusable template** for an APAC cell later. Keeps the monolith the
  team trusts and the boring per-cell deploy/rollback. No new distributed-systems
  failure modes inside the request path.
- **Cons:** Introduces a tenant-routing layer and a global directory — a new
  critical-path component we must design not to be a fragile SPOF. We now operate
  2 (eventually 3) environments with a frozen 6-person team: migrations run per
  cell, on-call surface grows, cells can drift. Cross-region analytics breaks the
  single-read-replica model — reporting must aggregate across cells. A few
  genuinely global tables (billing, identity, the directory itself) need a home
  region and become cross-region reads for the far cell. A tenant's home region
  is sticky and painful to change after the fact.

### Option C — Microservices split + multi-region

Pull booking / payments / notifications / calendar into separate services and
deploy them regionally.

- **Pros:** Delivers the seams two engineers want; independent scaling of the
  booking write path; the "right" long-horizon shape if we were a bigger org.
- **Cons:** Does not actually satisfy residency any better than Option B — and
  residency doesn't require it. It is a multi-quarter program for a team that has
  **never run multi-service production**, has **no SRE**, is under a **hiring
  freeze**, and already has **one failed extraction** on the books. It introduces
  distributed failure modes (partial failure, data consistency across services)
  to the booking hot path during a 4-month compliance crunch. High chance of
  blowing the deadline and the deal. Wrong tool, wrong time.

---

## Decision

**We are building Option B: regional cells of the existing monolith, partitioned
by tenant home region, with a thin global routing/identity layer. We are
explicitly *not* splitting into microservices now, and we are sequencing the
three forces rather than bundling them.**

Why this one:

- It is the **only option that makes the 4-month deadline credible** while
  producing a residency story we can defend without the unscoped PII-tagging
  project.
- It **decouples** the three forces. Residency gets solved properly; APAC gets
  the right-sized fix on its own (longer) clock; the microservices question is
  parked behind real triggers instead of being smuggled in under a deadline.
- It **fits the team we actually have** — same language, same framework, same
  deploy model, same rollback — instead of the team we'd need to hire and can't.

**Sequencing:**

1. **EU cell first (the only fixed clock).** Stand up the EU cell from the same
   codebase on the PaaS's EU region. Add a `home_region` to tenants and a global
   directory; route auth and tenant traffic by it. Onboard the franchise group
   into the EU cell as the pilot. Keep all booking traffic in-cell.
2. **APAC second, app-level fix first.** The primary SLA fix is **collapsing the
   booking page's sequential API calls** into far fewer round-trips (batch /
   server-render the slot view) plus short-TTL edge caching of availability
   reads — this helps every region and needs no new region. Stand up a full APAC
   cell *only if* that measurably falls short, reusing the EU template. The
   7-month renewal gives us that runway.
3. **Microservices: declined now, gated behind triggers below.** If a single,
   measured seam (most likely the booking write path) ever can't scale inside the
   monolith, we revisit extracting *that one service* — not a wholesale split.

**First-week execution** (so we start Monday): pick `eu-central`; add
`home_region` and the tenant directory; decide the short list of genuinely global
tables (billing, identity, directory) and give them a home in `us-east`; stand up
an empty EU cell from the current codebase; build signup → home-region assignment
+ routing. In parallel, a small track instruments and collapses the APAC
booking-page round-trips.

---

## Consequences

**What this buys us**

- A residency posture that is whole-tenant and easy to defend, satisfying the
  contract and the EU pipeline, with no per-column classification.
- A pattern that scales with EU growth and **templatizes the APAC cell** if we
  need it.
- The monolith, the boring deploys, and one-click rollback survive — inside each
  cell, day-to-day engineering barely changes.
- The microservices debate gets a real, honest answer ("not now, here's when")
  instead of festering or hijacking the deadline.

**What it costs us**

- A new critical-path **routing layer + global directory** to build, harden, and
  keep available. If it's down, login routing is down.
- **Operating N cells with 6 frozen people:** migrations and deploys run per
  cell, cells can drift, on-call surface grows. This is the real ongoing tax.
- **Cross-region analytics/reporting** must be rebuilt to aggregate across cells;
  the single analytics read replica no longer sees everything.
- Cross-region reads for global tables from the far cell; a tenant's home region
  is sticky.
- Roughly +$5–8k/month [ASSUMPTION], within the approved envelope.

**What we are explicitly accepting**

- Residency granularity at the **tenant**, not end-customer, level [ASSUMPTION].
- Some latency and friction for **internal/admin/analytics** cross-region paths —
  we are optimizing the customer booking path, not the back office.
- APAC SLA addressed by **application round-trip reduction first**, full APAC cell
  deferred and conditional.

**What we are explicitly deferring**

- Microservices decomposition (parked behind triggers).
- Column-level PII classification (made unnecessary by whole-tenant locality).
- A dedicated APAC cell (only if app-level fixes miss the SLA in testing).

---

## Revisit triggers

Reopen this decision if any of these fire:

- **APAC app-level fixes miss the target.** If collapsing round-trips + edge
  caching can't get APAC p95 under ~1.2s in test → commit to a full APAC cell.
- **EU concentration or a new jurisdiction.** EU signups cross ~30–35% of new
  business, or a second localization regime appears (UK, India, etc.) → reassess
  whether the cell model scales as-is or needs platform investment / a hire.
- **The directory/routing layer becomes an incident source.** If it causes
  availability events or behaves like a SPOF → harden it or rethink the approach.
- **Cell operations exceed team capacity.** Migration drift between cells,
  per-cell deploy pain, or on-call burnout under the freeze → invest in tooling or
  pause regional expansion before adding a third cell.
- **A real, measured scaling bottleneck in one seam.** The booking write path (or
  another single seam) demonstrably can't scale inside the monolith → revisit
  extracting *that one service* — still not a wholesale split.
- **The constraints change.** Hiring freeze lifts / revenue milestone hit, or
  legal sharpens the PII line such that whole-tenant locality is over- or
  under-compliant → re-evaluate the build-vs-defer calculus.
