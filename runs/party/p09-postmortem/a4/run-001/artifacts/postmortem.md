# Postmortem — payments-api 5xx surge (2026-05-14)

**Service:** `payments-api` (authorizes checkout for the web + mobile storefronts)
**Date / duration:** 2026-05-14, ~14:01–14:51 UTC (~50 minutes of degradation)
**Severity:** Customer-facing — failed checkout authorizations during a high-traffic sale window
**Data loss:** None
**Author audience:** payments-api engineering team + director · **Tone:** blameless

---

## Summary

During the early afternoon of 2026-05-14, `payments-api` returned 5xx errors on checkout
authorization, peaking at roughly **22% of requests** (about one in five) for ~50 minutes
during the "Summer Sale" traffic surge. Customers experienced failed checkouts.

The failures were **not** a database outage, a cache problem, or simply sale load. They were
**connection-pool exhaustion** caused by the `v2.31.0` release (deployed 13:58 UTC), which
shipped two interacting changes in the same PR (#4471):

1. **`db.pool.maxSize` was cut from 50 → 20** ("right-size pool to match observed
   steady-state usage"), and
2. **the `inline_enrichment` feature flag was flipped on by default**, adding a *synchronous*
   `customer-profile` lookup to every `/v1/authorize` request — run on the same thread,
   reusing the same pooled DB connection the request already holds, with **no dedicated
   timeout and no fallback**.

Each authorize now held a pooled connection across **two** sequential DB round-trips instead
of one, roughly doubling per-request connection hold-time — against a pool that had
simultaneously been shrunk by 60%. Under the sale surge (~1,050 rps peak), the pool pinned at
`20/20`, requests queued for a connection, and they failed at the 10s acquire-timeout ceiling.
Every 5xx in the logs is `db acquire: timed out after 10000ms` — a *connection-acquisition*
failure, not a query failure. The database itself stayed healthy throughout (query p99 ~12ms,
CPU ~30%).

Oncall mitigated in two steps: **disabling `inline_enrichment` via the flag console (14:31)**
dropped 5xx from 22% → 6%, and **restoring `db.pool.maxSize` to 50 (14:38, rolling restart)**
completed recovery by 14:51. The database was never modified.

---

## Timeline (UTC)

| Time | Event |
|---|---|
| 13:40 | Steady state: ~620 rps, p99 140 ms, 5xx ~0.1%. |
| 13:50 | Marketing sends "Summer Sale" email blast to the full list. Heads-up posted to **#general, not #oncall**. |
| 13:55 | Request rate climbing on sale traffic (620 → 980 rps). p99 still ~150 ms, 5xx 0.1% — **service healthy as load rises.** |
| **13:58** | **Deploy `v2.31.0` starts** (rolling, 6 pods; commit `a1f4c92`). Config/flag changes per PR #4471. Pool in-use immediately reads `20/20`. |
| 14:01 | Deploy completes; all 6 pods pass readiness. |
| 14:02 | p99 rising (150 → 600 ms), 5xx 0.1% → 0.8%, acquire wait ~2,200 ms. |
| 14:04 | Sale peak ~1,050 rps. **First `500 db acquire: timed out after 10000ms`.** p99 1,400 ms, 5xx 3%. |
| 14:06 | **PagerDuty: `5xx rate > 5%`** — acked 14:07. *The only alert that fired.* |
| 14:08 | Load balancer ejects pod `payments-api-7c9` after 3 failed readiness checks (re-added 14:35). |
| 14:09 | 5xx ~22%; p99 pinned at ~10 s (timeout ceiling). |
| 14:11–14:14 | Oncall investigates: sale-load theory raised; `redis: connection reset` warnings noticed; cache owner paged. |
| 14:23 | **No pool dashboard or alert exists** — oncall opens the pool view by hand: `db_pool_in_use` at its ceiling, acquire waits maxed. |
| 14:25 | Reviews the `v2.31.0` diff (PR #4471). Notes `customer-profile` lookup returns in **14 ms** while the issuing request waited 10 s. |
| **14:31** | **Disables `inline_enrichment`** via flag console (no deploy needed). |
| 14:34 | `db_pool_in_use` drops to ~9/20; **5xx 22% → 6%**, p99 800 ms. |
| 14:36 | Cache owner confirms Redis resets are long-standing, fail-open — **not implicated.** |
| **14:38** | **Raises `db.pool.maxSize` back to 50** via config + rolling restart. DB itself untouched. |
| 14:46 | Config rollout complete: p99 180 ms, 5xx 0.4%. |
| 14:51 | **Recovered:** 5xx < 0.2%, p99 145 ms, traffic still elevated (~900 rps) and stable. |
| 15:30 | Sale traffic tapers; service nominal. |

---

## Root cause vs. contributing factors

### Root cause

**The interaction of two changes in `v2.31.0` (PR #4471): the `inline_enrichment` flag adding a
synchronous DB call on the held connection, combined with the pool being shrunk from 50 to 20.**
Neither change alone would have produced a 22% outage; coupled and shipped into a known traffic
surge, they were sufficient.

The mechanism is connection-hold-time × concurrency exceeding pool capacity:

- `inline_enrichment` added a second, serialized DB round-trip per authorize, executed on the
  **same pooled connection the request already holds** — extending how long every request keeps
  a connection.
- `db.pool.maxSize: 50 → 20` removed 60% of the pool's capacity at the same moment.
- Sale concurrency pushed in-use connections to the new ceiling. The pool pinned at `20/20` from
  13:58 onward; `db_pool_wait_ms` ran away (`0 → 2,200 → 7,600 → 9,800 → 9,900 ms`) and requests
  failed at the 10s `acquireTimeoutMs` ceiling.

**The evidence that isolates the pool from the database:**

- Every 5xx is `db acquire: timed out after 10000ms` — failure to *acquire* a connection, not a
  query failure.
- `db_query_p99_ms` stayed flat at ~12 ms and `db_cpu_pct` flat at ~30% for the entire incident.
- The 14:25 log line is decisive: the `customer-profile` query returned in **14 ms**, yet its
  request had spent ~10 s upstream — all of it waiting for a connection.
- The recovery is a confirming experiment: disabling the flag (which removes the second
  round-trip) dropped 5xx 22% → 6% **with the DB untouched**; restoring the pool closed the rest.

### Relative weight of the two changes

The two changes are not cleanly separable (they were mitigated in sequence, not isolation), but
the recovery data shows their relative roles:

- **`inline_enrichment` was the dominant lever.** Disabling it alone produced the large drop
  (22% → 6%) — it was the added work that tipped a tight-but-surviving pool into exhaustion.
- **The `50 → 20` pool cut was the amplifier.** The residual 6% 5xx that persisted at
  `maxSize=20` (until restored to 50) shows the shrunk pool was itself unsafe under surge — it
  removed the headroom that would otherwise have absorbed the added work.

[ASSUMPTION] The "roughly doubled hold-time" mechanism is inferred from the design of the change
(an extra synchronous lookup on the same held connection) plus the flag-disable result; we do not
have a directly measured per-request connection-hold-time metric. Exact percentage attribution
between the two changes is therefore not available.

### Contributing factors (real, but not the root cause)

- **Sale traffic** — the load that *exposed* the regression, not its cause. The service was
  healthy as rps rose from 620 to 980 before the deploy; it failed only once `v2.31.0` landed.
- **No per-call timeout or fallback on enrichment** — there are no `db.query.timeoutMs` or
  `enrichment.timeoutMs` keys anywhere in the manifest. An optional, decorative loyalty-tier
  lookup was given the power to block (and fail) a payment authorization.
- **No load-shedding / early-bail** — stalled requests sat on the acquire queue until the full
  10 s timeout instead of fast-failing or skipping the optional work, so one slow dependency
  dragged the whole pool down.
- **Pool sized to steady-state with no burst headroom** — `20` was already the steady-state
  ceiling (`20/20` before any trouble), leaving nothing for a *scheduled, known* traffic event.
- **Observability blind to the failure mode** — no alert and no dashboard for pool health;
  oncall built the pool view by hand at 14:23, ~17 minutes after the page. The only alert that
  fired was the lagging downstream 5xx symptom.
- **Change + load context were invisible to responders** — the flag default-flip was not in any
  deploy notes that were read, and the marketing blast heads-up went to #general, not #oncall.

---

## What we ruled out & why

Each theory below was raised during the incident. We grade it against a falsification test: *if
this were the root cause, what would the data show — and does it?*

| Theory | If it were the cause… | What the data shows | Verdict |
|---|---|---|---|
| **"It's just sale traffic / 1k rps"** | 5xx tracks load; curve turns at the 13:50 blast | rps climbed from 13:55 with 5xx at 0.1% through 13:57; the curve broke at **13:58, the deploy boundary.** The spring promo sustained 1k+ rps with no failure. | **Coincidental** — load exposed the regression; it isn't the cause. |
| **Redis "connection reset" flood** | resets rise into the incident; 500s are cache errors | `redis_reset_per_min` flat at **1/min** before, during, and in baseline; cache fails open; 100% of 500s are `db acquire` timeouts (zero redis errors). | **Ruled out** — constant background signal noticed under stress. |
| **`customer-profile` DB is the choke point / "scale the DB"** | DB saturation: high CPU, rising query latency; recovery needs a DB change | `db_query_p99` ~12 ms, `db_cpu` ~30% flat throughout; the 14:25 query ran in 14 ms; recovery achieved with **the DB never touched.** | **Ruled out** — the bottleneck is the app-side pool, *in front of* the DB. The `db acquire` string misleadingly *sounds* like a DB fault. |
| **LB ejecting pods (health-check flapping)** | flapping precedes and originates the failures | ejection at 14:08 came *after* 5xx was already climbing (14:02–14:06); restoring the pool fixed it. | **Symptom, not cause** — pods failed readiness because the request path was already saturated. |
| **`async_receipts` flag (the other flag in the diff)** | adds work to the request path | it moves receipt emission **off** the request path to a background worker — reduces per-request work. | **Not implicated** — guilt by association only; if anything it was mildly protective. |

**The cleanest evidence is the natural experiment:** the spring promo and the 5/14 sale both ran
~1,000 rps, with opposite outcomes. Identical load → traffic is not the differentiating variable.
What differed was exactly `v2.31.0`: spring ran `pool=50` with one round-trip per authorize; the
sale ran `pool=20` with two synchronous round-trips. Per-connection demand roughly doubled while
supply was cut 60%.

[ASSUMPTION] The pod-flapping ordering rests on oncall's real-time judgment plus the recovery
evidence; we did not reconstruct an independent per-pod health-check timeline.

---

## Remediations (owners + sequencing)

Each item maps to a specific gap this incident exposed. Roles, not individuals.

### Today — before the next sale or deploy

| Action | Gap it closes | Owner |
|---|---|---|
| **Restore `db.pool.maxSize` to 50** and treat `20` as steady-state-only until load-tested. No sale runs on `20`. | No burst headroom | payments-api tech lead |
| **Add a connection-pool-saturation alert** → page **#oncall** when `in-use / max > 80%` for 60 s **or** acquire-wait p95 > 1 s. This was the actual signal on 5/14 and nothing surfaced it. | No pool alert (found by hand at 14:23) | payments-api tech lead + platform/observability |
| **Bound the enrichment call: add a ~150 ms per-call timeout with skip-on-timeout fallback — or default `inline_enrichment` OFF until that exists.** Authorize must never block on optional enrichment. (Quick win: the flag flip was the proven mitigation, 22% → 6%.) | No timeout / no fallback; no load-shedding | payments-api tech lead |
| **Route traffic-driving marketing blasts to #oncall** with timing (standing rule). | Load context invisible to responders | EM + marketing counterpart |

### This week

| Action | Gap it closes | Owner |
|---|---|---|
| **Pool-health dashboard**: in-use vs. max, acquire-wait p50/p95/p99, acquire timeouts/min — paired with the alert above. | Failure mode uninstrumented | platform/observability team |
| **Establish per-query timeout config keys as a standard** (`db.query.timeoutMs` / per-call budgets); enrichment is the first consumer. | No per-query timeouts exist at all | payments-api tech lead |
| **Deploy-freeze window around scheduled traffic events** (no payments-api deploys from blast time through peak). `v2.31.0` shipped 13:58 into a ramp that began 13:50. | Deploy into a known traffic ramp | release manager |
| **Load-test the pool size at projected sale peak** before any pool reduction is allowed to stick. | "Right-sized to steady-state" trap | payments-api tech lead |

### This quarter — structural

| Action | Gap it closes | Owner |
|---|---|---|
| **Release-coupling guardrail:** at most one behavioral-flag change per release; do not co-ship unrelated pool/infra-capacity changes. Enforced at release review (split the deploy if both are present). | Two coupled changes made the failure hard to attribute | release manager |
| **Flag-risk review gate:** any flag that adds a synchronous dependency on a hot path and/or defaults ON must declare a timeout + fallback before it ships. `inline_enrichment` would have failed this gate. | Risky default-ON dependency, no safeguards | payments-api tech lead (sign-off), release manager (gate) |
| **Auto-post changed flags to #oncall on every deploy** — the default-flip wasn't in any notes that were read. | Change invisible to responders | release manager |
| **Load-shedding / early-bail on the authorize path:** shed or skip optional work when acquire-wait crosses a threshold, instead of every request burning the full 10 s timeout. | No load-shedding turned a slowdown into 22% 5xx | payments-api tech lead |

**Three quick wins to grab first**, each removing a distinct leg of the 5/14 failure: the
`inline_enrichment` default-OFF flip (one config line, proven mitigation), the pool restore to 50,
and the #oncall blast-routing rule. **The single highest-leverage structural change** is the
release-coupling guardrail — it attacks the thing that made this incident hard to *reason about*,
not merely a bad config value.
