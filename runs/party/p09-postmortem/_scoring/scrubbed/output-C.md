# Postmortem: payments-api 5xx surge — 2026-05-14

**Service:** `payments-api` (checkout authorization for web + mobile storefronts)
**Impact window:** ~14:02–14:51 UTC (~50 min), 5xx peaking ~22% of authorize requests
**Severity:** Customer-facing checkout failures during a marketing-driven sale peak
**Status:** Recovered; no data loss
**Audience:** payments-api team + engineering director · **Tone:** blameless

---

## Summary

During a Summer Sale traffic peak, `payments-api` began returning 5xx errors on checkout
authorization, rising from a 0.1% baseline to ~22% over roughly eight minutes and staying
elevated for ~50 minutes before oncall mitigated and recovered the service.

Every failing request hit the same wall: it could not acquire a database connection from
the pool and timed out after 10 s (`db acquire: timed out after 10000ms`). The pool sat
pinned at its ceiling for the duration.

The root cause was a release-config interaction, not load and not the database. Release
`v2.31.0` (deployed 13:58, four minutes before symptoms began) did two things at once that
worked against each other:

1. It turned on `inline_enrichment`, which adds a synchronous `customer-profile` lookup to
   the authorize path — the request now holds its pooled DB connection longer because it
   does a second query before returning, with no per-call timeout or fallback.
2. It cut `db.pool.maxSize` from 50 to 20 — a 60% reduction in connection supply.

More demand for connections, less supply, applied at the same moment sale traffic pushed
request rate to ~1,050 rps. The pool exhausted, requests queued for connections and gave up
at the 10 s acquire timeout, and those timeouts surfaced as 5xx. Disabling
`inline_enrichment` drained the pool within three minutes; restoring the pool to 50
completed recovery.

---

## Timeline (UTC)

| Time | Event |
|---|---|
| 13:40 | Steady state: ~620 rps, p99 140 ms, 5xx ~0.1%, pool ~12/50. |
| 13:50 | Marketing sends "Summer Sale" blast to the full list. Heads-up posted to **#general**, not #oncall. |
| 13:55 | Sale traffic climbing: 620 → 980 rps. p99 still ~150 ms, pool 17/50. Healthy. |
| 13:58 | **Deploy `v2.31.0` (commit `a1f4c92`, PR #4471)** starts. Config + flag changes: pool 50→20; `inline_enrichment` on; `async_receipts` on. |
| 14:01 | Deploy completes, all 6 pods healthy on readiness. |
| 14:02 | p99 begins climbing 150→600 ms; 5xx 0.1→0.8%. Pool already **20/20**; acquire wait 2,200 ms. |
| 14:04 | First `db acquire: timed out after 10000ms` 500s. Pool saturated, acquire wait 7,600 ms. |
| 14:06 | **PagerDuty: 5xx > 5%.** Acked 14:07. This was the *only* alert that fired all incident. |
| 14:08 | Load balancer ejects pod `payments-api-7c9` after failed readiness checks (symptom of queue backup). |
| 14:09 | Oncall on dashboards; 5xx ~22%, p99 pinned at the 10 s timeout ceiling. |
| 14:12–14:18 | Hypotheses raised and chased: sale load; Redis resets; `customer-profile` DB hot; pod flapping. Cache owner paged. |
| 14:23 | **No alert or dashboard exists for pool health.** Oncall opens the pool view manually: `db_pool_in_use` at max, acquire waits maxed. |
| 14:25–14:28 | Oncall correlates with the 13:58 deploy, pulls the PR #4471 diff for a second reader. |
| 14:31 | **`inline_enrichment` disabled via flag console** (no deploy needed). |
| 14:34 | Pool drops to **9/20**; 5xx 22%→6%; p99 800 ms. The flag flip moved it. |
| 14:36 | Cache owner confirms Redis resets are weeks-old, fail-open — not implicated. |
| 14:38–14:46 | `db.pool.maxSize` raised back to 50 via config + rolling restart. p99 180 ms, 5xx 0.4%. DB never modified. |
| 14:51 | Declared recovered: 5xx < 0.2%, p99 145 ms, traffic still ~900 rps and stable. |

---

## Root cause vs. contributing factors

### Root cause: a synchronous, unbounded enrichment query was added to the connection-holding path in the same release that cut the pool

`inline_enrichment` makes each `/v1/authorize` run an extra `customer-profile` lookup, on
the same thread, **using the same pooled connection it already holds**, before the authorize
returns. There is no dedicated timeout or fallback for it — none of `db.query.timeoutMs` or
`enrichment.timeoutMs` exist in the manifest. So every authorize now holds its DB connection
for two queries' worth of time instead of one.

The mechanism is connection-pool arithmetic, not a slow database. Concurrent connections in
use ≈ request rate × how long each request holds a connection:

- **Before the deploy (13:55):** 790 rps × ~21 ms hold ≈ 17 connections in use, against a
  pool of 50. Comfortable.
- **After enrichment was disabled (14:34):** 960 rps used only **9 of 20** connections —
  *more* traffic, *fewer* connections, because each request again did less work on its
  connection. [ASSUMPTION] The drop below the pre-deploy figure is consistent with
  `async_receipts` (also enabled in v2.31.0) moving receipt emission *off* the request path,
  shortening hold-time.
- **At the peak (14:10):** 1,040 rps with enrichment adding a second query per request drove
  required concurrency above 20, the pool saturated, and requests queued. Once queued, they
  waited the full 10 s `acquireTimeoutMs` and failed as 5xx.

The 14:25 log line is the tell: the profile lookup itself returned in **14 ms**, yet the
request that issued it spent 10 s upstream before it ran. The query was fast; the *contention
for connections* was the problem.

The single most load-bearing fault is enrichment-on-the-hot-path with no bound on the
connection it holds. The clearest proof is the mitigation: disabling that one flag — with the
pool still at 20 — drained it to 9/20 and cut 5xx from 22% to 6% within three minutes.

### Primary contributing factor: the 60% pool cut removed the headroom that would have absorbed it

The same release reduced `db.pool.maxSize` from 50 to 20, described in PR #4471 as
"right-size pool to match observed steady-state usage." [ASSUMPTION] That observed baseline
predated `inline_enrichment` — it measured a workload that no longer existed once enrichment
shipped in the same release. With the pool still at 50, the peak demand (~24 connections by
the arithmetic above) would likely have stayed under the ceiling and the incident may not
have fired. The cut didn't create the extra demand, but it deleted the margin that made the
extra demand survivable. Shipping the demand increase and the supply cut together, untested
under load, is what tipped the system over.

### Contributing factor: no early shedding or per-call timeout

When a request stalled on the pool, nothing shed it or skipped the slow step — it sat on the
acquire queue until the 10 s timeout fired. One contended dependency was therefore able to
drag the entire pool down and pin user-visible latency at the timeout ceiling. This is a
latent design weakness the release exposed rather than created.

### Trigger (not root cause): sale traffic

The marketing blast raised request rate from ~620 to ~1,050 rps and is what pushed demand
across the now-lowered ceiling. But the service had handled 1,000+ rps cleanly during the
spring promo, and DB CPU (~30%) and query latency (~12 ms p99) stayed flat throughout. The
traffic was the trigger that exposed the config change, not the cause of the failure.

---

## What we ruled out & why

- **Sale traffic as root cause.** Ruled out. The service ran 1,000+ rps fine during the
  spring promo; the difference on 2026-05-14 was the v2.31.0 config, not the load. Traffic
  was the trigger, not the cause.
- **`customer-profile` database capacity / "the DB is hot".** Ruled out. `db_cpu_pct` held
  at 29–32% and `db_query_p99_ms` at ~11–13 ms for the entire incident, and the enrichment
  query returned in 14 ms. The DB was never the bottleneck — the bottleneck was *getting a
  connection from the pool*, upstream of the DB. Confirmed by recovery: the DB was never
  scaled or modified, yet the service recovered fully.
- **Redis `connection reset by peer` flood.** Ruled out. `redis_reset_per_min` was a flat
  **1/min before and during** the incident — identical to baseline, not a surge. The
  idempotency cache fails open, the resets are weeks old, and the cache owner confirmed they
  are not implicated. This was visible noise in the logs that drew attention, not a factor.
- **Pod flapping / LB ejections.** Ruled out as a cause; this was a symptom. Pods failed
  readiness because the request queue backed up behind the exhausted pool; the LB ejecting
  and later re-adding them is downstream of the saturation.
- **`async_receipts` (the other flag in the release).** Not implicated, and likely helpful —
  it moved receipt emission off the request path, *reducing* per-request connection hold-time.
  It was a confounder in the diff, not a contributor.

---

## Remediations

Each item maps to a specific gap this incident exposed. Owners are roles, not individuals.

### Today

- **Keep `inline_enrichment` disabled until the bounds below land.** Gate any re-enable on
  the timeout/fallback and load-test work. *Owner: payments-api tech lead.*
- **Codify `db.pool.maxSize = 50` in the manifest** so the mitigation isn't silently reverted
  by a future "right-sizing." *Owner: payments-api oncall/tech lead.*

### This week

- **Add pool-saturation alerting and a dashboard** — page on `db_pool_in_use` sustained at
  ≥ ~85% of max and on `db_pool_wait_ms` p99 over a small budget (e.g. > 500 ms). Oncall had
  to discover the pool view by hand at 14:23; this is the single change that would have cut
  time-to-diagnosis most. *Owner: payments-api team + SRE/observability.*
- **Add a per-call timeout and fallback for the enrichment lookup** — a short
  `enrichment.timeoutMs`, and on timeout skip enrichment and return the authorize rather than
  holding the connection. Directly closes the "no dedicated timeout or fallback" gap.
  *Owner: payments-api eng.*
- **Stop enrichment from holding the authorize's pooled connection** — make it best-effort or
  move it off the connection the authorize is holding, so a slow profile lookup can't consume
  authorize-path pool capacity. *Owner: payments-api eng.*
- **Split risky workload changes from resource-sizing changes across releases**, and require
  perf review for any change that alters per-request resource usage or pool sizing. v2.31.0
  bundled a new on-path dependency with a 60% pool cut; either alone would have been easier to
  reason about and revert. *Owner: payments-api tech lead / EM.*

### This quarter

- **Load-test the request path and pool config at sale-peak rps (1,000+).** Establish a
  simple capacity model (required connections ≈ rps × hold-time vs. pool size) and run it in
  staging/CI for changes touching the authorize path or pool. This incident was predictable
  from arithmetic; nothing checked it. *Owner: payments-api team + SRE.*
- **Add load-shedding / fast-fail on pool acquisition.** When acquire waits exceed a budget,
  shed or fail fast instead of blocking every request for 10 s, so one contended dependency
  can't pin the whole pool at the timeout ceiling. Consider lowering `acquireTimeoutMs` from
  10 s in tandem. *Owner: payments-api eng / platform.*
- **Govern default-on feature flags that change the hot path** — surface them in deploy notes
  and to oncall, and roll them out progressively rather than 0→100% on by default. The flag
  flip "wasn't in the deploy notes anyone read." *Owner: EM / release process.*
- **Route traffic-event heads-ups to oncall.** Marketing's blast notice went to #general;
  oncall correlating a load event with a deploy should not depend on having seen the right
  channel. A feed into #oncall or a shared launch calendar suffices. *Owner: EM / marketing
  liaison.*

---

*Prepared for the payments-api team and director. Estimates of per-request connection
hold-time are derived from the published rps and `db_pool_in_use` series via Little's Law and
are approximate; the qualitative conclusion (pool exhaustion driven by added on-path work
plus a reduced ceiling, not DB or cache capacity) is robust to the exact numbers.*
