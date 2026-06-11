# ADR-001: EU data residency via regional cells

**Status:** Accepted · **Date:** 2026-06-10 · **Decision owner:** Tech lead · **Audience:** CEO, engineering team (6)

---

## Context

We signed our largest deal to date: a ~600-location German/French franchise, ~$280k ARR, with a pipeline of similar EU prospects behind it. Procurement made it a non-negotiable, contractual condition that **personal data for EU-resident end customers is stored and processed inside the EU**. Legal confirms the clause is not negotiable, and the deal is contingent on it. We have a **4-month window**. This is the only one of our current pressures with a fixed, externally-imposed deadline, and it is the spine of this decision.

Two other forces arrived the same quarter and are easy to conflate with it:

- **APAC latency.** A reseller's Australia/Singapore book of business (~$190k ARR, renewal in ~7 months) sees p95 booking-page load ~1.9s vs ~600ms in the US, almost all of it round-trips to `us-east`, compounded by the booking page making several *sequential* API calls. The reseller wants a contractual p95 < 1.2s.
- **The monolith-split question.** Whether to break `routable-web` into booking/payments/notifications/calendar services is a long-running internal debate. It became "concrete" only because we're about to stand up infrastructure in a second region anyway.

The trap is treating these as one program. They are not. Residency is a **data-location** problem. Latency is a **read-path performance** problem. The split is a **code-decomposition** want with no external forcing function. Solving residency by rewriting into services would pay the entire distributed-systems tax for zero residency progress — and we are six engineers with no SRE, no DBA, nobody who has run multi-service production, and a hiring freeze for ~8 more months. The system is middle-aged but **not on fire**; deploys are boring and rollback is one click, and the team values that.

This ADR commits to the smallest structural change that satisfies the residency contract, treats latency as a decoupled fast-follow, and explicitly defers the split.

**Scope note (with legal):** The contract covers EU-resident *end-customer* PII (names, emails, phones, appointment notes with occasional health-adjacent detail). Legal's posture is "when in doubt, in scope." We have **no** column-level PII classification across the 140k-line schema, and tagging it is unscoped, sizeable work.

---

## Options considered

### Option A — Column/row-level PII split (one app, PII rows in the EU)

Keep a single logical application; classify which columns/rows are personal data; store those in an EU datastore; keep everything else in `us-east`; join across regions at request time.

- **Pros:** Granular — only true PII crosses the border. One codebase, one deploy pipeline. In principle covers per-end-customer residency, not just per-tenant.
- **Cons:** Requires PII classification across a 140k-line schema that nobody has scoped — almost certainly won't fit the 4-month clock. Legal won't draw a crisp line, so "appointment notes" free text forces conservative, fuzzy boundaries. Worst of all, it puts a **cross-region network hop inside the booking transaction** — the hot path (hold slot → charge deposit → write appointment) — directly worsening the very latency we're also trying to fix. High engineering risk on the part of the system that loses us money when it breaks.

### Option B — Regional cells (tenant-pinned silos) — *chosen*

Stand up a **second full copy of the existing stack** (same Rails monolith, its own managed Postgres, Redis, Sidekiq) in `eu-central`. Each tenant (business) has a **home region**; EU businesses live entirely in the EU cell — config *and* their end-customers' PII in one Frankfurt Postgres. A thin **global control plane** (in `us-east`, holding *no* end-customer PII — only `tenant_id → region` and login routing) resolves which cell a request belongs to and routes it.

- **Pros:** Reuses the system we already operate well — each cell is the boring single-database monolith the team likes, just twice. **No PII tagging required** (the whole tenant lives in-region), which removes the biggest schedule risk. Clean, auditable compliance story: EU tenant data is physically in the EU. Natively serves the EU-*business* growth (15% of signups and rising). The control plane carries no in-scope data, so it stays in `us-east`. The latency work (below) makes both cells faster.
- **Cons:** We now run **two of everything** — two prod Postgres, two app stacks, two Redis/Sidekiq fleets — on a six-person on-call rotation with no SRE, now spanning European hours. **Cross-cell analytics breaks**: today's single analytics read replica can't answer "across all tenants" queries; we must ETL both cells into a separate warehouse, and reporting/admin is degraded on day one. Tenant region-migration is painful. Pins residency by *business* region, so it does **not** cover a US business serving an EU end customer (see Consequences). A new routing layer becomes a critical, must-be-correct component.

### Option C — Microservices split + multi-region

Break booking/payments/notifications/calendar into services and deploy them regionally, using the second-region work as the occasion to decompose.

- **Pros:** Addresses the long-standing decomposition itch and the 4,000-line `Booking` model. Cleaner long-term seams; independent scaling; satisfies the engineers who want it.
- **Cons:** Solves the wrong problem — service boundaries do nothing for *where a row physically lives*. Converts the single-transaction booking hot path into a **distributed transaction** (sagas / 2PC) with a team that has never operated one and no SRE/DBA. Highest risk, longest timeline, and the half-abandoned `notify-svc` extraction is direct evidence of how this goes for us. Will almost certainly miss the 4-month clock; this is the "rewrite" the CEO is skeptical of, and rightly.

---

## Decision

**We will adopt Option B: regional cells, tenant-pinned by home region**, with three accompanying commitments:

1. **Build a thin global control plane** in `us-east` that maps `tenant_id → home_region` and routes/authenticates requests to the correct cell. It stores **no end-customer PII**. Region resolution **fails closed**: an unresolved region refuses the request rather than defaulting to US, because writing one EU customer's PII to `us-east` is the exact breach we are paying to avoid.
2. **Treat APAC latency as a decoupled, parallel fast-follow** — *not* a third residency cell (there is no residency requirement pulling APAC data into APAC). First collapse the booking page's sequential availability calls into a single aggregated endpoint and serve the page shell + static assets via a **CDN**. *Then measure.* Only if APAC p95 still exceeds 1.2s do we add a regional read replica / edge read-cache. This work also speeds up the EU cell.
3. **Explicitly defer the monolith split.** Not on merit — the pain is real — but because adding a new distributed failure domain to the booking hot path, with this team and this clock, is the wrong move this year. We keep the boring, fast-rollback monolith inside each cell.

**Why this over the others:** Option A misses the clock (unscoped PII tagging) and harms the hot path. Option C misses the clock and multiplies operational risk for a team without the operational depth to carry it. Option B is the only path that (a) reuses infrastructure and operational habits the team already executes well, (b) needs no schema-wide PII classification, (c) gives an auditor a physically clean answer, and (d) leaves room to do the latency work in parallel with lower-risk people. We are choosing it knowing its main cost — doubled operational surface — and accepting that consciously.

**Indicative sequencing (4-month clock):**
- *Month 1:* `home_region` tenant attribute + fail-closed routing in the control plane; stand up the `eu-central` cell (app + Postgres + Redis); legal sign-off on tenant-level scoping.
- *Month 2:* migration tooling to move a tenant's data `us-east → eu-central` with auditable evidence; decide the home of genuinely global data (auth directory, billing rollups).
- *Month 3:* migrate/onboard the franchise into the EU cell; compliance dry-run and evidence package.
- *Month 4:* buffer, audit, hardening. **Latency track runs in parallel** (existing team, read-path work — it does not contend for the scarce migration/routing effort) and has ~3 months of additional slack before the SLA renewal.

[ASSUMPTION] The signed franchise is an EU business serving EU customers, so tenant-level pinning satisfies its contract. [ASSUMPTION] "Global" data needing a home is limited to the tenant→region directory, auth/login routing, and billing rollups — none of which contain in-scope end-customer PII; the control plane can therefore remain in `us-east`. [ASSUMPTION] Payment data stays out of scope because tokens already live processor-side, not in our DB.

---

## Consequences

**What this buys us**
- A defensible, auditable residency story within the 4-month window without rewriting the application or classifying PII column-by-column.
- Each cell remains the single-Postgres monolith the team operates confidently, with one-click rollback intact.
- Native support for EU-business growth (15% of signups, trending up) — this is not a one-deal patch.
- A latency fix (API aggregation + CDN) that benefits every region and is independent of the residency critical path.

**What it costs us (accepted)**
- **Doubled operational surface.** Two production databases, two app stacks, two job fleets, on-call now spanning EU hours, on a six-person rotation with no SRE/DBA and a hiring freeze. This is the single largest ongoing cost and the place we are most exposed. We mitigate with cell symmetry (identical stacks), strong runbooks, and keeping cells as similar as possible — but we accept the added toil. Infra spend will rise toward our ~2× ceiling (~$22k/month).
- **Degraded cross-cell analytics/admin from day one.** "Across all tenants" queries no longer hit one replica. We accept a near-term reporting gap and will stand up a separate warehouse fed by ETL from both cells; this is explicitly *not* solved within the 4-month residency build.
- **A new, correctness-critical routing layer** that must fail closed. We accept it as a new component to harden and monitor.

**What we are explicitly deferring**
- **Per-end-customer residency.** Tenant-pinning does not cover a US-homed business with an EU-resident end customer. This satisfies the signed contract and the EU-business pipeline but is a known gap, recorded as a revisit trigger below rather than a silent omission.
- **The monolith decomposition.** Deferred indefinitely pending the triggers below — not cancelled.
- **A dedicated APAC cell.** Deferred unless the cheaper latency levers demonstrably fail to meet the SLA.

**Top program risks (operational, not architectural)**
- **The live data migration** of the franchise from `us-east` to `eu-central` with auditor-grade evidence is the scariest single task. Owned, rehearsed on a copy, and reversible before cutover.
- **Routing correctness on first write.** A new EU tenant or booking must land in the right cell the first time; fail-closed behavior is a hard requirement and a primary test target alongside the booking/payment paths we already cover well.

---

## Revisit triggers

Reopen this decision if any of the following occur:

1. **Legal hardens the line to per-end-customer residency** (not per-tenant) — the tenant-pinning assumption breaks and we must revisit data partitioning.
2. **A single tenant must span regions** (a multinational customer with data-location needs in more than one cell) — the cell model's "one home region per tenant" assumption no longer holds.
3. **Demand for a third region** (e.g., UK post-Brexit, US-gov/regional) — validate that the cell pattern scales operationally before adding the third of everything; the ops cost may force a different model.
4. **EU/cell operational load outpaces the team** — sustained on-call pain, missed boring-deploy cadence, or the tech lead's pager load worsening. If this hits *before* the hiring freeze lifts, escalate; the doubled surface is our known weak point.
5. **The latency levers fall short** — if after API aggregation + CDN, APAC p95 still exceeds 1.2s, authorize the regional read replica / edge read-cache (and only then reconsider a fuller APAC presence).
6. **Genuine signal for the split emerges** — a sustained rise in change-failure rate, deploy contention, or a specific seam (e.g., notifications) blocking delivery — *measured*, not resume-driven. The booking/payment ACID transaction must remain the bar: do not split it across a network without a concrete, demonstrated need.
7. **Cross-cell analytics gap becomes business-critical** before the warehouse exists — prioritize the ETL/warehouse track ahead of its current "fast-follow" standing.
