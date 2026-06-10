# Postmortem — `payments-api` 5xx surge

**Date of incident:** 2026-05-14 (all times UTC)
**Duration:** ~13:58 onset → 14:51 recovered (~50 min of impact; ~28 min above 5xx alert threshold)
**Severity:** Customer-facing. Checkout authorization for web + mobile degraded, peaking at ~22% of `/v1/authorize` requests returning 5xx during a Summer Sale traffic window.
**Data loss:** None. Failed checkouts were rejected cleanly at the API; no corrupted or lost orders.
**Status:** Resolved. Service nominal since ~14:51.
**Audience:** `payments-api` service team + director. Blameless — this writeup names decisions and gaps, not individuals.

---

## Summary

At 13:58 the `payments-api` service shipped release **v2.31.0**, which coupled two changes that were each individually defensible but jointly dangerous:

1. It turned on `inline_enrichment`, adding a **synchronous `customer-profile` lookup onto the authorize hot path** — each `/v1/authorize` now holds its pooled DB connection longer, for a second query, before returning.
2. In the same manifest it **cut the DB connection pool from 50 to 20** (`db.pool.maxSize`), described as "right-size pool to match observed steady-state usage."

The pool was right-sized against the *old* behavior. With each request now holding a connection roughly 2–2.5× longer, and with a Summer Sale email blast pushing traffic from ~620 to ~1,050 rps, connection **demand outran the shrunken pool within one minute of the deploy**. The pool pinned at 20/20, requests queued for a connection and gave up at the 10 s acquire timeout, and those acquire-timeouts surfaced as 5xx.

The database itself was never the bottleneck — CPU and query latency stayed flat throughout, and the enrichment query returned in 14 ms. The failure was connection-pool starvation, not DB capacity. Oncall mitigated by disabling `inline_enrichment` (which alone drained the pool and cut 5xx from 22% → 6%), then restored `db.pool.maxSize` to 50 to recover fully. The DB was never modified.

---

## Timeline (UTC)

| Time | Event |
|---|---|
| 13:40 | Steady state: ~620 rps, p99 140 ms, 5xx ~0.1%, pool ~12/50. |
| 13:50 | Marketing sends the "Summer Sale" blast to the full list. Heads-up posted to **#general, not #oncall**. |
| 13:55 | Sale traffic ramping (620 → 980 rps). p99 still ~150 ms, 5xx 0.1%, pool 17/50 — **healthy under rising load**. |
| **13:58** | **Deploy v2.31.0 starts** (commit `a1f4c92`). Same minute, pool jumps to **20/20** and acquire-waits begin. |
| 14:01 | Deploy completes, all 6 pods healthy on readiness. |
| 14:02 | p99 600 ms, 5xx 0.8%, acquire-wait 2.2 s. First `db.pool: acquire wait` warnings. |
| 14:04 | First `500 db acquire: timed out after 10000ms`. 5xx 3%, p99 1.4 s. |
| 14:06 | **PagerDuty: `5xx rate > 5%`** — the only alert that fired. Acked 14:07. |
| 14:08 | LB ejects pod `payments-api-7c9` after failed readiness checks (symptom of queue backup; re-added 14:35). |
| 14:09 | Oncall on dashboards. 5xx ~22%, p99 pinned at the 10 s timeout ceiling. |
| 14:12–14:18 | Theories raised: sale load; a "wall" of Redis resets; `customer-profile` DB hot. Cache owner paged. |
| 14:23 | **No pool alert or dashboard existed** — oncall opens the pool view by hand. `db_pool_in_use` at ceiling, acquire-waits maxed. |
| 14:25 | Pool max found to be 20; oncall pulls the v2.31.0 diff (PR #4471). |
| **14:31** | **`inline_enrichment` disabled via flag console** (instant, no deploy). |
| 14:34 | Pool drains to **9/20**; 5xx 22% → 6%, p99 800 ms. |
| 14:36 | Cache owner confirms Redis resets are weeks-old, fail-open — **not implicated**. |
| 14:38 | `db.pool.maxSize` raised back to 50 via config + rolling restart. **DB itself never modified.** |
| 14:46 | Rollout complete. p99 180 ms, 5xx 0.4%. |
| 14:51 | Declared recovered. Traffic still elevated (~900 rps) but stable. |

---

## Root cause vs contributing factors

### Root cause

**Release v2.31.0 added a synchronous, un-isolated `customer-profile` enrichment query to the authorize hot path (`inline_enrichment`) at the same time it halved-plus the DB connection pool (50 → 20).** Each request held a pooled connection long enough to do a second query, so per-request connection-hold time rose sharply; the simultaneously shrunken pool removed the headroom that would have absorbed it; sale-peak load then pushed connection demand past the 20-connection ceiling. Requests queued for a connection and failed at the 10 s acquire timeout — those timeouts are the 5xx.

The evidence chain that fixes this as the cause and not a theory:

- **The inflection tracks the deploy, not the traffic.** Traffic was already climbing from 13:55 (620 → 980 rps) with p99 and 5xx flat. The graphs turn at **13:58**, the deploy minute — the pool moves from 17/50 to 20/20 in the same snapshot.
- **It was connection *acquisition*, not query execution, that failed.** Every 500 is `db acquire: timed out after 10000ms`. The 14:25 log is decisive: the enrichment query itself returned in **14 ms**, yet the request that issued it had already spent ~10 s upstream — it died waiting for a connection, not running a query.
- **Disabling `inline_enrichment` alone fixed most of it, with the pool still at 20.** After the 14:31 flag flip, the pool drained to **9/20** and 5xx fell 22% → 6%. That isolates enrichment as the dominant driver of connection demand, and shows a pool of 20 had ample headroom *without* the extra hot-path query. [ASSUMPTION] From the 20/20-pinned → 9/20 shift at roughly constant rps, enrichment was adding on the order of ~2–2.5× to per-request connection-hold time; the exact multiple is inferred, not measured.
- **Restoring the pool to 50 completed recovery without touching the DB**, confirming a supply/demand problem in the pool rather than a database problem.

A sharper way to state the defect: `inline_enrichment` placed an **external dependency with no per-call timeout and no fallback on the payment hot path**, while each request that calls it holds a scarce pooled connection for the whole call. The release manifest contains no `db.query.timeoutMs` or `enrichment.timeoutMs` and no skip-on-slow path. The 50 → 20 pool change is what converted that latent risk into an immediate outage at this traffic level — but even at pool 50, a genuinely slow `customer-profile` would now be able to starve checkout. The pool size set the threshold; the un-isolated hot-path dependency is the mechanism.

### Contributing factors (real, but not the cause)

- **Pool downsizing 50 → 20.** The necessary enabling condition. Sized against steady-state usage that predated the new enrichment query, so it removed exactly the margin the new query consumed. Without this change, demand (~22 connections at peak) would have stayed under a pool of 50.
- **Coupling two changes in one release.** The capacity change and the behavior change shipped together, so neither was evaluated against the other. Either shipped alone would not have caused an outage.
- **No per-call timeout / load-shedding on the authorize path.** Why the failure was severe rather than graceful: a request with no connection sits for the full **10 s acquire timeout** holding nothing useful — nothing sheds it early or skips enrichment. One slow/contended dependency drags the whole pool down. A 10 s acquire ceiling turns "slow" into "total outage."
- **Sale traffic (the trigger, not the cause).** The blast raised the load that crossed the threshold, but the service had handled comparable rps before this release. Load was the multiplier; the release was the change.
- **Observability gap on pool health.** No alert or dashboard existed for `db_pool_in_use` / acquire-wait. Oncall found the real signal **by hand at 14:23, ~15 min into impact** (chat 14:23). Detection lag, not a cause of the failure.
- **Comms gap.** The marketing heads-up went to **#general, not #oncall**, and the `inline_enrichment` default flip "wasn't in the deploy notes anyone read" (chat 14:53). Both delayed correlation of cause to effect.

---

## What we ruled out & why

- **Sale traffic as the root cause.** Ruled out as *sole* cause. The service had run 1k+ rps before without falling over (chat 14:12), and the metrics show load rising cleanly from 13:55 with flat error/latency until the deploy. Load was the trigger that crossed the threshold the release created — not the failure itself.
- **Redis `connection reset by peer` flood.** Ruled out. `redis_reset_per_min` is flat at ~1/min **before, during, and after** the incident — identical to the pre-deploy baseline. The cache fails open and the resets are weeks old (confirmed by the cache owner, 14:36). The log line is visually alarming and high-frequency in the stream, but the *rate* never changed. Coincidental red herring; alarm-fatigue risk.
- **`customer-profile` database being hot / capacity-bound.** Ruled out. `db_cpu_pct` held ~29–32% and `db_query_p99_ms` held ~11–13 ms throughout; the enrichment query returned in 14 ms at the height of the incident. Recovery happened **without touching the DB** (chat 14:46), disproving the capacity theory directly. The DB was a healthy resource being starved of *access*, not an overloaded one.
- **Pod health-check flapping / LB ejection.** Ruled out as a cause. The ejection at 14:08 *followed* pool saturation at 13:58; pods went unhealthy because the request queue backed up behind the starved pool (chat 14:21). Symptom, downstream.
- **`async_receipts` (the other flag in the same release).** Not implicated. It moves receipt emission *off* the request path onto a background worker — it reduces hot-path work if anything. Worth distinguishing explicitly from `inline_enrichment`, which does the opposite.

---

## Remediations

Owners are given as **roles** [ASSUMPTION — mapped to roles, not named individuals or confirmed team boundaries]. Sequencing is **Today / This week / This quarter**.

### Today
- **Keep `inline_enrichment` off and ratify pool `maxSize=50` in config** until enrichment can be re-shipped safely. Make the current (recovered) state the committed baseline, not a live hotfix. — *Service oncall / eng lead.*
- **Add a per-call timeout + fallback for the enrichment query**: if `customer-profile` is slow or unavailable, skip enrichment and return the authorize without loyalty tier. Checkout must never block on enrichment. Directly closes the "no `enrichment.timeoutMs`, no fallback" gap. — *payments-api engineer.*
- **Add a pool-health alert + dashboard** on `db_pool_in_use` (fraction of max) and acquire-wait time. This incident had no pool signal; oncall found it by hand 15 min in. — *Service team / oncall.*

### This week
- **Stop coupling capacity changes with behavior changes in one release.** Require a load/perf review when either `db.pool.*` or any hot-path flag changes; never ship both unreviewed in the same manifest. Add to the release checklist. — *Eng lead / release owner.*
- **Re-derive the pool size from hold-time × peak concurrency, not steady-state usage**, and document why the number is what it is. The 50 → 20 "right-size" was correct arithmetic against the wrong (pre-enrichment) baseline. — *Service team.*
- **Add load-shedding / fast-fail and shorten the 10 s acquire timeout.** When acquire-wait exceeds a threshold, fail fast (or shed) rather than holding a request for 10 s. A 10 s ceiling converts a slow dependency into a full outage. — *payments-api engineer.*
- **Surface flag-default flips in deploy notes and #oncall.** `inline_enrichment` defaulted on via the release but wasn't in any notes anyone read. — *Eng lead.*

### This quarter
- **Isolate external lookups on the authorize path** — a dedicated connection pool / bulkhead for enrichment, or make enrichment truly asynchronous (the `async_receipts` pattern). Goal: a slow `customer-profile` can never starve checkout's connections, independent of pool size. — *payments-api engineer / service architect.*
- **Pre-deploy load test against projected peak (sale) traffic** for any release touching the hot path or pool config. Would have caught this before customers did. — *Service team.*
- **Establish deploy-freeze / coordination around known traffic events.** v2.31.0 went out at 13:58, minutes into a marketing blast that drove a 70% traffic spike. Marketing traffic events should notify #oncall and gate against concurrent risky deploys. — *Eng lead + marketing liaison; director to sponsor cross-team agreement.*
- **Reduce Redis-reset WARN noise** (fail-open resets logged at WARN ~1/min). It's a standing red herring that consumed incident attention; lower severity or fix the reconnect. — *Cache owner.*

---

*Prepared for the `payments-api` team and director. Conclusions are drawn from the metric/log excerpts and timeline in `reference/`; chat-channel theories were treated as claims and checked against the data rather than taken as settled. Items inferred beyond the recorded evidence are tagged [ASSUMPTION].*
