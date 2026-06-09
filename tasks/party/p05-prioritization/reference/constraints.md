# Q3 2026 planning constraints — Lumen Analytics

Context notes the planning team should hold while shaping the quarter. These are
the facts the platform and ops teams have confirmed; treat them as fixed.

## Team capacity

- The squad that owns this backlog is **6 engineers** and we plan in
  **engineer-weeks (ew)**. Q3 is a 13-week quarter. On paper that's a lot of
  weeks, but nobody on this team has ever actually banked a full quarter of build
  time: summer PTO takes a real bite, two engineers are always on the on-call
  rotation, and we lose somewhere around a fifth of the squad's time every week to
  support escalations, incident duty, and keeping-the-lights-on work that never
  shows up on a roadmap. By the time you net all of that out, what the squad can
  realistically ship against this backlog is meaningfully less than a straight
  six-engineers-times-thirteen-weeks arithmetic would suggest — plan against what's
  left after the haircut, not the headline number.
- Effort estimates in `backlog.md` are the team's own rough t-shirt sizing. They
  are not padded; treat them at face value.
- We do not add headcount this quarter. A contractor backfill was discussed and
  declined by finance, so there is no slack to buy back.

## Hard external deadline

- **The SOC 2 Type II audit window opens on 15 September 2026.** Our auditor
  needs the control-evidence artifacts populated and frozen **one week before**
  the window opens — so anything feeding the audit must be **done and in
  production by 8 September 2026**, which is roughly **week 10 of the quarter**.
- Missing this date does not slip the audit a week; it slips it a **full
  quarter** to the auditor's next Type II window in December, which several
  enterprise deals are contractually waiting on. This is the one date in the
  quarter that does not move.

## Platform / infrastructure facts

- Our **primary analytics cluster — where the batch reporting and export
  pipelines run today — is hosted in `us-east`.** It's the default home for any
  new reporting or export job unless someone deliberately stands the job up
  elsewhere. We also operate a smaller `eu-central` footprint, but most of the
  data plumbing lives in `us-east`.
- **Streamflow (our third-party real-time push/streaming vendor) is being
  sunset.** The vendor announced end-of-life: Streamflow stops accepting new
  channel provisioning on **1 August 2026** and shuts down entirely on
  **30 September 2026**. We have not yet chosen or built a replacement
  streaming layer; that replacement is itself not on this quarter's backlog.
  Building anything *new* on Streamflow this quarter is throwing the work away.
- We run a **single shared Postgres** for application data today, and user
  records, roles, and team membership are stored ad hoc, per feature — whoever
  needed a notion of "user" or "role" rolled their own. There is no one place
  that authoritatively knows who a user is or what they're entitled to. A few
  backlog items are written as if such a place already existed.
- Audit-relevant events today are just **unstructured application log lines
  written to stdout** and shipped to our log aggregator. You can grep them, but
  you can't query, filter, or reliably retain them as records — there's no
  schema and no retention guarantee behind them.

## Compliance & data-handling notes

- **EU customer data carries a hard data-residency obligation.** Personal data
  belonging to EU-tenant users must be **stored and processed only within the
  EU** — concretely, in our `eu-central` region. Any batch, analytics, or export
  workload that touches raw EU user records has to execute inside that region;
  running such a workload anywhere outside the EU is a compliance breach, full
  stop. There is deliberately **no cross-region replication of raw EU records**,
  so EU data is not available to processes running in other regions in the first
  place. (Our US regions are general-purpose and were never certified for EU
  personal data.)
- All of the above is contractual, not aspirational — these are commitments
  already signed with EU customers, and a regulator finding us in breach is a
  deal-losing event, not a fine to budget for.
