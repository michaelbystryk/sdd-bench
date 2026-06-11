# Engineering context — Routable (appointment-scheduling SaaS)

This is a working brain-dump of where our platform stands and the decision in
front of us. It's written for an architect joining the conversation cold, so it
includes more background than the decision strictly needs. Take what's useful.

## What Routable is

We sell online appointment scheduling to small service businesses — salons,
clinics, tutors, repair shops. A business configures its services, staff, and
availability; their customers book slots through a hosted booking page or an
embedded widget. We send confirmations and reminders, sync to staff calendars,
and take a deposit or full payment at booking time through a payment processor.

We're 4 years old. ~9,000 paying businesses, ~$4.1M ARR. The booking widget does
the volume that matters: at peak (Monday mornings, and the first business day
after a holiday) we serve roughly **2,500 booking-page loads/minute** and around
**220 completed bookings/minute**. A booking write touches availability, holds
a slot, charges the deposit, and writes the appointment — it is the hot path.

## The team

- 6 engineers total. One is the de-facto tech lead (also does ~40% management).
  Two seniors, two mid, one junior who joined 3 months ago.
- Nobody on the team has run a multi-service production system before. Two have
  used Kubernetes at past jobs; one of those had a bad experience with it.
- We have no dedicated SRE, no platform team, and no DBA. On-call is the 6 of us
  on a weekly rotation. The tech lead carries the pager more than the rotation
  implies.
- **Hiring is frozen** through at least the end of the fiscal year (8 months
  out) — the board tied headcount to a revenue milestone we haven't hit.

## The current system

- One Rails monolith (`routable-web`), ~140k lines, deployed on a PaaS
  (Heroku-style: `git push`, managed Postgres, a worker dyno tier). One
  Postgres database, currently ~280 GB, single primary with a read replica we
  use for analytics.
- Background jobs (reminders, calendar sync, webhook delivery, payment-status
  reconciliation) run on Sidekiq against a managed Redis.
- Deploys are a few times a day, low ceremony, generally boring. Rollback is a
  one-click affair on the PaaS. The team likes this and says so often.
- Test suite is decent on the booking and payment paths (the parts that lose us
  money when they break), thin everywhere else. CI is ~14 minutes.
- The monolith has the usual middle-age problems: a 4,000-line `Booking` model,
  some N+1s we've papered over with caching, and a couple of modules only one
  person really understands. It is not elegant. It is also not on fire.

## What's forcing a decision

Three things landed in the same quarter.

### 1. A data-residency requirement (the hard deadline)

We just signed our first enterprise-ish deal: a franchise group with ~600
locations across Germany and France, and a pipeline of similar EU prospects
behind them. Their procurement made it a contractual condition that **personal
data for EU-resident end customers is stored and processed inside the EU.**
Our single Postgres lives in `us-east`. The signed contract gives us **a
4-month window** to be compliant; the legal team has confirmed the clause is
not negotiable and the deal (~$280k ARR, our largest) is contingent on it.

Note what the requirement actually covers: end-customer PII (names, emails,
phone numbers, appointment notes that sometimes contain health-adjacent detail
for the clinics). It does **not** obviously cover the business's own config
(services, staff names, availability rules), though legal hasn't given us a
crisp line and "when in doubt, treat it as in-scope" is their current posture.

### 2. A latency complaint from our biggest existing customers

Our US customers are happy with page speed. But we've onboarded a cluster of
businesses in Australia and Singapore through a reseller, and their booking
pages are slow — p95 page load around 1.9s for them vs ~600ms for US traffic,
almost all of it network round-trips to `us-east`. The reseller has made noise
about an **SLA: p95 booking-page load < 1.2s** for their region as a condition
of renewing (~$190k ARR across that book of business, renewal in ~7 months).
The booking page makes several sequential calls to our API to render available
slots; latency compounds.

### 3. The "should we have split this up already" anxiety

Every time the monolith creaks, someone on the team raises whether we should be
breaking it into services — booking, payments, notifications, calendar-sync are
the usual proposed seams. Two of the engineers are quietly keen (resume, and a
genuine belief it'd help); the tech lead is skeptical given the team size. It
has never been more than a hallway argument. The EU requirement has made it
concrete: *if* we're standing up infrastructure in a second region anyway, is
that the moment to also pull the system apart?

## Constraints, money, and other facts on the table

- **Budget:** infra spend can roughly double (we're at ~$11k/month now) without
  a fight. A net-new platform investment beyond that needs the CEO, who is
  supportive of "whatever keeps the EU deal" and skeptical of "rewrite."
- The PaaS we're on **does offer EU regions** (we'd stand up a second app +
  managed Postgres in `eu-central`). It does **not** offer a managed
  multi-region single database; cross-region data sync would be on us.
- Our payment processor is global and supports both regions; payment tokens are
  already stored processor-side, not in our DB. Good news, that part.
- About **15%** of new signups this quarter were EU; the trend is up. This is
  not a one-customer problem that goes away if the deal falls through.
- Calendar sync and reminders are tolerant of a few seconds of delay. Booking
  and deposit-charge are not — a customer is staring at the page.
- We have no feature flags infrastructure beyond environment checks, and no
  formal data-classification of which columns are PII. Tagging PII across a
  140k-line schema is itself nontrivial work nobody has scoped.
- A previous attempt to extract the notifications code into a separate service
  (18 months ago) was abandoned half-done; there's a dormant `notify-svc`
  repo and some shared code that still reaches across the boundary.

## What we need

A decision we can take to the CEO this week and start executing, with the
trade-offs we're accepting stated plainly — not a maybe. The EU clock is the
thing that doesn't move.
