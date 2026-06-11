# ADR-001: EU Data Residency via Regional Cells — Defer the Split, Decouple APAC

- **Status:** Proposed (for CEO sign-off this week)
- **Date:** 2026-06-10
- **Owners:** Engineering (tech lead + 6)
- **Decision driver:** Signed EU contract with a non-negotiable 4-month residency clause

---

## Context

Three forces landed on us in the same quarter, and they are easy to confuse for one problem. They are not.

1. **EU data residency — the only hard deadline.** We signed a ~600-location German/French franchise group (~$280k ARR, our largest deal) with a contractual, non-negotiable requirement that **EU-resident end-customer personal data be stored *and processed* in the EU**. Our single Postgres lives in `us-east`. We have **4 months**, the deal is contingent, and legal's posture on scope is "when in doubt, treat it as in-scope." This is not a one-off: ~15% of new signups this quarter were EU and the share is rising. EU is becoming a *segment*, not a customer.

2. **APAC latency — a real SLA, but a softer one.** AU/Singapore businesses (via a reseller, ~$190k ARR, renewal in ~7 months) see p95 booking-page loads of ~1.9s vs ~600ms in the US, almost all of it network round-trips to `us-east`. The booking page makes several *sequential* API calls to render slots, so latency compounds. The reseller wants p95 < 1.2s to renew.

3. **The monolith-split argument — an internal one, with no customer attached.** Every time the 140k-line Rails monolith creaks, someone proposes breaking it into services. The EU need for second-region infrastructure made the argument concrete: if we're standing up another region anyway, is this the moment to pull the system apart?

The hard facts that constrain us: **6 engineers, hiring frozen ~8 months, no SRE/DBA/platform team, on-call is the six of us, and nobody here has run a multi-service production system before.** Our PaaS offers EU regions but **no managed multi-region single database** — any cross-region data sync is on us. We have no PII column classification across the schema, and a prior service-extraction attempt (`notify-svc`, 18 months ago) was abandoned half-done. What we are genuinely good at is operating one boring monolith with low-ceremony, one-click-rollback deploys.

The forcing function is residency. APAC and the split are passengers riding in the same quarter, and the central risk is letting a real 4-month deadline smuggle in speculative work that makes us miss it.

---

## Options considered

### Option A — Regional cells (silo the whole stack per region) **[CHOSEN]**

Stand up a **full second copy of the monolith** — app + managed Postgres + Redis/Sidekiq — in `eu-central`. EU businesses and their end-customers live **entirely** in the EU cell; US tenants stay in `us-east`. A tenant is **pinned to a region at signup**. There is **no cross-region sync of customer data** and no shared database on the hot path. A thin shared control plane handles signup routing and billing roll-up across cells.

- **Pros:** Each cell *is* the system we already run and trust — same deploy flow, same rollback, same on-call muscle memory. Sidesteps the cross-region sync problem entirely (the part the PaaS won't do for us). Legal's "when in doubt, in-scope" posture becomes an *asset* rather than a tax: the whole tenant — PII and business config alike — lives in-region, so we never have to litigate per-column scope. The booking transaction stays local, so residency adds **zero latency to the hot path**. The same pattern extends to an APAC cell later if write-locality is ever needed.
- **Cons:** Duplicated infrastructure cost and operational surface — six people now own two regions on the same pager. A new routing/control-plane seam we now own and must keep correct. Risk of **config/schema drift** between cells (mitigated by deploying identical code to both from one pipeline). **Cross-region reporting and admin tooling that assumes one database will break** and must be rebuilt against two.

### Option B — Narrow PII-only carve-out (keep one app, move only PII)

Keep the single `us-east` application; push only EU end-customer **PII columns** to a separate EU datastore, joined back at read/write time.

- **Pros:** Smallest possible data boundary; one application to operate; US-centric reporting largely intact.
- **Cons:** Requires **classifying PII across an unclassified 140k-line schema** — unscoped work that becomes the critical-path long pole, and if it runs long, the *deadline* eats it. Adds a **cross-region call into the booking write** — importing network latency into the one path the customer is staring at. "Processed in the EU" is hard to defend when the application doing the processing runs in `us-east`. High compliance ambiguity against a non-negotiable clause.

### Option C — Split the monolith into services, regionalized as we go

Use the EU work as the occasion to extract booking / payments / notifications / calendar-sync into services and deploy them regionally.

- **Pros:** Clean module boundaries long-term; satisfies the engineers who (genuinely) believe in it; in principle lets us place only the relevant services in-region.
- **Cons:** Converts a compliance deadline into a **distributed-systems rewrite** on a team that has never run multi-service prod, with no SRE and a hiring freeze. Every sequential booking call becomes a network hop with its own failure mode — a **distributed-transaction problem** on the hot path. The dead `notify-svc` repo is direct evidence we don't finish these. Near-certain to miss the 4-month window *and* deliver a fragile system. No customer is asking for it.

---

## Decision

**We will deliver EU data residency as a regional cell (Option A): a full second copy of the monolith in `eu-central`, with tenants pinned to a region at signup, no cross-region customer-data sync, and a thin shared control plane for signup routing and billing. We are deferring the monolith split and decoupling the APAC latency work from this effort.**

Why this one:

- **It hits the deadline with technology we already operate.** A cell is our current monolith, redeployed. We are multiplying a known-good system, not transforming into an unknown one — the only realistic way six people clear a fixed 4-month bar.
- **It dodges the two traps the team identified.** No cross-region sync (which the PaaS won't manage and which would be a correctness nightmare on a transactional booking path), and no PII-tagging audit on the critical path (Option B's long pole). Whole-tenant residency means legal's conservative scope posture costs us nothing extra.
- **It keeps residency off the hot path.** Bookings execute against an in-region database, so we satisfy "stored and processed in the EU" *and* protect the p95 the customer sees.
- **It refuses to let a real deadline carry a speculative rewrite.** The split serves a résumé and a belief, not a customer (Option C). The cell model still hands the keen engineers a clean, real region/tenant boundary to learn on — *after* EU ships.

**APAC is decoupled and sequenced after EU.** [ASSUMPTION] We believe most of the 700ms gap is front-end round-trip compounding, not data distance — so the first move is a **measured latency spike** (parallelize/batch the sequential slot-render calls, add an edge/read cache for availability) against the 7-month renewal clock. We commit infra to APAC only if measurement proves data distance is the residual cause. The cell pattern gives us a Singapore cell as the fallback if it does.

---

## Consequences

**What this buys us**
- A defensible, contractually-compliant EU story within the 4-month window, protecting ~$280k ARR now and the rising EU signup pipeline behind it.
- A reusable **regional-cell pattern** that also answers APAC write-locality later if needed — one pattern, two payoffs.
- Preservation of the low-ceremony deploy/rollback workflow and on-call model the team relies on. No new orchestration platform, no Kubernetes, no distributed transactions.
- Residency adds no latency to the booking hot path.

**What it costs us (including the parts that hurt)**
- **Doubled operational surface on the same pager.** Six people now run two regions. Infra spend roughly doubles — within the "can double without a fight" budget, but real. [ASSUMPTION] This stays within budget; if a third region (APAC) lands, we revisit cost with the CEO.
- **Partitioned customer data.** EU and US end-customer data no longer share a database. **Cross-region reporting, support tooling, and any admin view that assumed one DB will break** and must be rebuilt against two. Product and analytics must absorb this.
- **A control-plane seam we now own** for signup region-routing and billing roll-up — new code that must be correct and is itself a single point of failure if done carelessly.
- **Config/schema-drift risk** between cells, requiring discipline to deploy identical code to both from one pipeline.

**What we are explicitly accepting**
- We accept whole-tenant residency (PII *and* business config in-region) rather than the theoretically minimal PII-only boundary — trading some storage duplication for compliance certainty and a smaller blast radius of work.
- We accept that a tenant's region is **fixed at signup**; cross-region tenant migration is not a v1 capability.

**What we are explicitly deferring**
- **The monolith split** — not killed, parked. Revisited only if a concrete constraint (not appetite) surfaces after EU ships.
- **PII column classification** across the schema — unnecessary under the cell model; deferred until a future need (e.g., a PII-only carve-out) demands it.
- **APAC infrastructure** — gated behind measurement; front-end latency work comes first.
- **An APAC cell** — held in reserve as the fallback if latency work proves insufficient.

---

## Revisit triggers

Reopen this decision if any of the following occurs:

1. **The PII/residency scope shifts under us** — e.g., legal or a regulator requires cross-tenant EU data joins, EU-resident data for *US-based* businesses, or in-region tenant migration. The cell model assumes clean per-tenant regional ownership; break that assumption and Option B or a hybrid comes back on the table.
2. **The 4-month build slips at the midpoint checkpoint** — if by **~2026-08-10** the EU cell is not on track to be production-ready, escalate to the CEO immediately; the deal is contingent and the clause is non-negotiable.
3. **APAC measurement disproves the assumption** — if the front-end latency spike does *not* bring p95 below 1.2s and the residual is provably data-distance, trigger the APAC-cell decision well ahead of the ~7-month renewal.
4. **Operational load exceeds what six people on one pager can carry** — sustained two-region incident load, or on-call burnout, is the signal that we have under-invested in platform/tooling and must either get the hiring freeze relaxed or simplify.
5. **The cell count grows past ~2–3, or cross-cell consistency becomes a recurring product need** — at that point the duplicated-monolith model stops scaling and a genuine service-extraction (the deferred split) earns a real, customer-backed justification.
6. **A real customer-driven need for the split appears** — a constraint that the monolith provably cannot meet (not "two engineers are keen"). That, and only that, reopens Option C.

---

*Note: the close call was the EU mechanism — whole-region **cell** vs. narrow **PII carve-out**. This document resolves it in favor of the cell, primarily because the carve-out puts an unscoped 140k-line PII-tagging audit on the critical path of a fixed, non-negotiable deadline.*
