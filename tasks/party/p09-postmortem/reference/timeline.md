# Incident timeline — payments-api 5xx surge

Service: `payments-api` (handles checkout authorization for the web + mobile storefronts).
Date: 2026-05-14. All times UTC. Reconstructed from PagerDuty, the deploy bot, and oncall
notes. Times are when the event was recorded, not necessarily when it began.

| Time (UTC) | Source | Event |
|---|---|---|
| 13:40 | metrics | Steady state. Request rate ~620 rps. p99 latency 140 ms. 5xx ~0.1%. |
| 13:52 | marketing (Slack) | "Summer Sale" email blast went out to the full list at 13:50 — heads up, expect traffic." (posted to #general, not #oncall) |
| 13:55 | metrics | Request rate begins climbing: 620 → 980 rps over the next 6 min. p99 still ~150 ms. |
| 13:58 | deploy-bot | Deploy started: `payments-api v2.31.0` (rolling, 6 pods). Commit `a1f4c92`. Config + flag changes per the v2.31.0 manifest (see logs). |
| 14:01 | deploy-bot | Deploy `v2.31.0` completed. All 6 pods healthy on readiness probe. |
| 14:02 | metrics | p99 latency starts rising: 150 → 600 ms. 5xx rate 0.1% → 0.8%. |
| 14:04 | metrics | Request rate ~1,050 rps (sale traffic peak). p99 1,400 ms. 5xx 3%. |
| 14:06 | PagerDuty | **PAGE**: `payments-api 5xx rate > 5% (3m)` — primary oncall acked at 14:07. This was the only alert that fired during the incident. |
| 14:08 | platform | Load balancer ejected pod `payments-api-7c9` after 3 failed readiness checks; re-added at 14:35. |
| 14:09 | oncall | Oncall opens dashboards. 5xx now ~22%. Latency p99 pinned at ~10 s (timeout ceiling). |
| 14:12 | oncall | Checks `customer-profile` DB dashboard (CPU, query latency). Pulls request-rate graphs against the sale blast. |
| 14:14 | oncall | `redis: connection reset` warnings prominent in the log stream. Cache owner paged. |
| 14:23 | oncall | No dashboard or page exists for pool health; oncall opens the pool view manually. `db_pool_in_use` at its max; acquire waits maxed. |
| 14:25 | oncall | Reviews the `v2.31.0` diff (PR #4471). Pastes it into the channel for a second reader. |
| 14:31 | oncall | Disables `inline_enrichment` via flag console (no deploy needed). |
| 14:34 | metrics | `db_pool_in_use` drops to ~9/20. 5xx falling: 22% → 6%. p99 800 ms. |
| 14:36 | cache owner | Replies re: Redis: resets are long-standing, cache fails open, not implicated. |
| 14:38 | oncall | Raises `db.pool.maxSize` back to 50 via config + rolling restart. DB itself was not modified. |
| 14:46 | deploy-bot | Config rollout complete. p99 180 ms. 5xx 0.4%. |
| 14:51 | oncall | 5xx < 0.2%, p99 145 ms. Declared recovered. Traffic still elevated (~900 rps) and stable. |
| 15:30 | — | Sale traffic tapers. Service nominal. Incident channel closed pending postmortem. |
