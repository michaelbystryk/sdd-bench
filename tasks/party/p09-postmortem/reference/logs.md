# Log & metric excerpts — payments-api, 2026-05-14

Curated excerpts pulled by oncall during and after the incident. Not exhaustive; these are
the lines people referenced. App logs are from the `payments-api` pods; metrics are from
the platform Prometheus scrape (15 s resolution, values shown are per-minute snapshots).

---

## Pre-deploy baseline (13:50–13:57) — for comparison

```
13:50:02 INFO  payments-api  POST /v1/authorize 200 (118ms) pool_in_use=11/50
13:50:02 WARN  payments-api  redis: connection reset by peer (idempotency-cache); reconnecting
13:50:31 INFO  payments-api  POST /v1/authorize 200 (132ms) pool_in_use=13/50
13:51:14 WARN  payments-api  redis: connection reset by peer (idempotency-cache); reconnecting
13:53:48 INFO  payments-api  POST /v1/authorize 200 (109ms) pool_in_use=12/50
13:55:20 WARN  payments-api  redis: connection reset by peer (idempotency-cache); reconnecting
13:56:39 INFO  payments-api  POST /v1/authorize 200 (151ms) pool_in_use=16/50
```

Config in effect during this window: `cache.failMode=open` for the idempotency cache.

---

## Config change applied by the deploy (from the v2.31.0 release manifest)

```
# diff against v2.30.4, applied 13:58 with deploy a1f4c92
  app.requestTimeoutMs: 30000
- db.pool.maxSize: 50
+ db.pool.maxSize: 20          # "right-size pool to match observed steady-state usage" — PR #4471
  db.pool.acquireTimeoutMs: 10000
  features.inline_enrichment: false -> true
  features.async_receipts: false -> true
  log.level: info
```

Both feature flags in the diff defaulted to on with this release. `async_receipts` moves
receipt emission off the request path onto a background worker. `inline_enrichment` does the
opposite: each `/v1/authorize` now runs an extra `customer-profile` lookup to attach loyalty
tier before the authorize returns, on the same thread, using the same pooled connection it
already holds. The enrichment query is issued through the standard DB client; the release
notes don't mention a dedicated timeout or fallback for it, and none of the per-call timeout
keys (`db.query.timeoutMs`, `enrichment.timeoutMs`) appear in the manifest before or after
this diff.

---

## App errors during the incident (14:02–14:31)

```
14:02:11 INFO  payments-api  POST /v1/authorize 200 (612ms) pool_in_use=20
14:02:55 WARN  payments-api  db.pool: acquire wait 2200ms
14:03:40 WARN  payments-api  redis: connection reset by peer (idempotency-cache); reconnecting
14:04:08 ERROR payments-api  POST /v1/authorize 500 db acquire: timed out after 10000ms
14:04:09 ERROR payments-api  POST /v1/authorize 500 db acquire: timed out after 10000ms
14:05:30 WARN  payments-api  db.pool: acquire wait 9800ms
14:06:02 ERROR payments-api  POST /v1/authorize 500 db acquire: timed out after 10000ms
14:08:12 WARN  payments-api  lb: pod payments-api-7c9 failed readiness (3x), ejecting
14:09:17 WARN  payments-api  redis: connection reset by peer (idempotency-cache); reconnecting
14:11:44 ERROR payments-api  POST /v1/authorize 500 db acquire: timed out after 10000ms
14:25:03 INFO  payments-api  customer-profile lookup SELECT tier FROM profiles WHERE id=$1 returned in 14ms
14:31:50 INFO  payments-api  features.inline_enrichment disabled via flag console
14:33:12 INFO  payments-api  POST /v1/authorize 200 (430ms) pool_in_use=12
```

The 500s are connection-acquire timeouts at the configured 10000ms ceiling; the first one
appears at 14:04. The 14:25 line is notable for what it doesn't show: the profile lookup
itself returns in 14ms — the query is fast, yet the request that issued it still spent 10s
upstream before it ran.

---

## Metrics (per-minute snapshots, key series)

```
time   rps   5xx%   p99_ms  db_pool_in_use  db_pool_wait_ms  db_query_p99_ms  db_cpu_pct  redis_reset_per_min
13:50  610   0.1    138     12/50           0                11               29          1
13:55  790   0.1    151     17/50           0                12               30          1
13:58  920   0.2    165     20/20           40               12               31          1
14:00  990   0.3    240     20/20           180              12               31          1
14:02  1020  0.8    612     20/20           2200             12               30          1
14:04  1050  3.0    1400    20/20           7600             13               31          1
14:06  1048  6.0    4200    20/20           9800             12               30          1
14:10  1040  22.0   10000   20/20           9900             13               32          1
14:20  1010  21.0   10000   20/20           9900             12               31          1
14:31  980   18.0   9800    20/20           9700             12               30          1
14:34  960   6.0    800     9/20            120              12               30          1
14:46  910   0.4    180     8/50            0                11               29          1
14:51  900   0.2    145     9/50            0                11               29          1
```

Column notes: `db_pool_in_use` is shown as `used/max`. `db_pool_wait_ms` is time a request
spends waiting to *acquire* a connection from the pool before its query can run (distinct
from `db_query_p99_ms`, which is how long the query itself takes once it has a connection).
`redis_reset_per_min` counts the `connection reset by peer` WARN lines per minute.
