# P9 — Answer Key (SEALED, harness-only)

**Never seed this file into a cell directory. Never readable from a cell-discoverable path.**

Incident: API 5xx surge on the `payments-api` service, 2026-05-14, ~14:02–14:51 UTC.

The materials (`reference/timeline.md`, `reference/logs.md`, `reference/chat.md`) are
engineered so the true root cause is reconstructable ONLY by correlating three threads:
(a) what the 13:58 deploy actually changed (config diff in logs.md — now buried among clean
decoy entries), (b) the load condition that started ~13:55, (c) the connection-pool
saturation signal in the metrics block (which the solver must read out of the `used/max`
notation and the pool-wait-vs-query-time split, with no narration pointing at it). A reader
who stops at the loud Redis WARNs will finger the decoy (K4).

HARDENING NOTE (post-calibration; cold pass had scored 4/4 and dismissed both decoys
unprompted because the materials over-signposted): the cell-facing files were revised so
(i) the error string no longer pre-correlates "pool 20/20 in use"/"PoolTimeoutError" — the
solver must JOIN the generic `db acquire: timed out` line to the config max and the metrics
pool series; (ii) the chat no longer verbalizes the Redis/DB dismissal up front (the loud
Redis WARNs stand unrebutted until after mitigation), so endorsing the decoy is now an easy
mistake; (iii) the "no timeout / no circuit breaker" phrasing for K3 was removed — it is now
inferable from behavior (fast query, full-10s wait, no per-call timeout key in the manifest);
(iv) clean decoys were added (`async_receipts` flag, LB pod ejection) so a shotgun solver
loses precision.

Target spread: K1 findable-once-correlated but easy to half-find (many will blame "the
database", "the deploy", "the sale traffic", or only one of the two coupled changes). K2/K3
are moderate-to-subtle (K3 now requires inferring the absence of a fail-fast path). K4 is the
precision trap — credit is awarded for actively DISMISSING it WITH cited evidence, not merely
omitting it, and the trap is now baited harder.

---

### K1 — True root cause: pool exhaustion from a halved pool max + a new per-request synchronous DB call, under elevated load  [subtlety: subtle — requires correlating 3 artifacts]
- What it is: The 13:58 deploy of `payments-api v2.31.0` shipped TWO coupled changes: (1) a config edit lowering `db.pool.maxSize` from 50 to 20 (logs.md config-change line), and (2) enabling feature flag `inline_enrichment`, which adds a *synchronous* per-request call to the `customer-profile` DB on the hot path (timeline + chat). Neither is harmful alone. Together, under the traffic that began rising at 13:55 (timeline + metrics), each in-flight request now holds a pooled connection for the duration of an extra blocking query, so the 20-connection pool saturates within ~4 minutes. `db.pool.acquire` waits climb to the 10s timeout, requests fail with `PoolTimeoutError`, and 5xx rate spikes. The DB itself is healthy (CPU/query-time metrics are flat — see K4).
- Where detectable: NO single line states the mechanism — it must be assembled across three artifacts. (1) `reference/logs.md` config block: `db.pool.maxSize: 50 -> 20` AND `inline_enrichment false -> true` (both buried in a 6-line diff that also contains two clean decoy/no-op entries — `async_receipts`, `app.requestTimeoutMs`, `log.level`), plus the prose that inline_enrichment adds a per-request `customer-profile` query holding the already-held pooled connection. (2) `reference/logs.md` metrics block: `db_pool_in_use` jumps to its `20/20` ceiling at the 13:58 deploy and stays pinned, `db_pool_wait_ms` climbs to the 10s ceiling, while `db_query_p99_ms` (~12ms) and `db_cpu_pct` (~30%) stay flat — the solver must read the `used/max` notation and the wait-vs-query-time split themselves (no narration points it out). (3) The error string is now generic (`db acquire: timed out after 10000ms`) and does NOT name "pool" or "20/20" — the solver must connect it to the metrics pool series and the config max. `reference/timeline.md` gives 13:58 deploy + 13:55 load rise but no longer spells out the two changes (points to the manifest). `reference/chat.md` 14:26–14:29 gestures at "added work on that path" + "I want a second pair of eyes on the diff" but does NOT state the combined mechanism.
- Minimum credit: Names pool/connection exhaustion as the mechanism AND attributes it to the *combination* of the lowered pool max (50→20) and the new inline/synchronous enrichment query enabled in v2.31.0, triggered under elevated load. Must show it correlated the config diff with the metrics pool-saturation series (not just restated a log line — no log line hands this over anymore). Naming only "the deploy", only the pool cut, only the enrichment flag, or "the sale traffic" = PARTIAL. Fingering `async_receipts` or the pod ejection as causal = phantom (precision hit). Naming pool exhaustion but blaming DB capacity = not found (K4 leakage).

---

### K2 — Contributing factor: no alerting on pool saturation / connection-wait; the team was blind to the real signal  [subtlety: moderate]
- What it is: The only alert that fired was the lagging `5xx rate > 5%` page at 14:06 — eight minutes after the pool started saturating. There is no alert on `db_pool_in_use`, `db_pool_wait_ms`, or acquire timeouts, so oncall had no leading indicator and spent the first ~15 minutes chasing the wrong layer. The saturation was visible in metrics the whole time; nothing surfaced it.
- Where detectable: `reference/timeline.md` 14:06 ("This was the only alert that fired during the incident") + 14:23 ("No dashboard or page exists for pool health; oncall opens the pool view manually"); `reference/chat.md` 14:23 ("pulled up the pool dashboard by hand — nothing paged us on it, I had to go find it"). The metrics block shows the saturation was visible the whole time but no alert referenced it.
- Minimum credit: Identifies the absence of an alert/monitor on pool saturation or connection-acquire wait (as opposed to only the lagging 5xx alert) as a contributing factor that delayed diagnosis. Must frame it as a gap that cost time, not merely note "an alert fired."

---

### K3 — Contributing factor: the inline-enrichment call has no timeout / no circuit breaker, so it holds connections instead of failing fast  [subtlety: moderate]
- What it is: The new `inline_enrichment` query is issued with no per-call timeout and no fallback/circuit breaker. Once the pool is contended, requests block waiting on the connection for the full 10s acquire timeout rather than shedding load or degrading gracefully, which amplifies the saturation into a full outage instead of slow responses. A bounded timeout or a breaker that disabled enrichment under contention would have contained blast radius.
- Where detectable: NO line says "no timeout" or "no circuit breaker" anymore — it must be inferred. `reference/logs.md` config prose: "the release notes don't mention a dedicated timeout or fallback for it, and none of the per-call timeout keys (`db.query.timeoutMs`, `enrichment.timeoutMs`) appear in the manifest"; plus the 14:25 log observation that the profile lookup *itself* returns in 14ms yet the request still burned the full 10s upstream (i.e. it queued rather than shedding/skipping). `reference/chat.md` 14:28–14:29: requests "don't bail — they just sit on the connection until the acquire timeout fires 10s later. nothing sheds them early or skips the slow part." `reference/timeline.md`: recovery comes only from disabling the flag + raising the pool, never from the call failing fast on its own.
- Minimum credit: Identifies that the enrichment (or DB) call path has no bounded per-call timeout, fallback, or circuit-breaker, so contended requests hold connections until the 10s acquire timeout instead of shedding load or degrading — naming this as an amplifier distinct from K1's pool-config cause. Must articulate the fail-fast/shed-load gap as a mechanism, not merely say "add a timeout" in remediations without identifying the absence as a contributing factor. Restating K1 without the hold-vs-fail-fast distinction = not found.

---

### K4 — Tempting-but-wrong decoy: blaming the pre-existing Redis connection-reset warnings (or "the database was overloaded")  [subtlety: decoy / precision trap]
- What it is: Two red herrings sit in the materials, and they are now LOUD AND LARGELY UNREBUTTED in the chat — the in-channel dismissals were removed/delayed precisely so a hasty solver is tempted to endorse them. (1) `redis: connection reset by peer` WARN lines appear throughout logs.md and the chat foregrounds them ("a wall of them", "that can't be helping") with no early rebuttal — but the evidence to dismiss them is still present: they appear at the SAME ~1/min cadence in the pre-deploy 13:50 baseline window as during the incident (`redis_reset_per_min` is flat at 1 the whole table), and the idempotency cache is configured `cache.failMode=open`. The solver must assemble this themselves; the cache owner's "ignore them" reply only lands at 14:36, AFTER the flag was already killed. (2) "The database is overloaded / slow / scale it up" — raised in chat at 14:36 and never crisply rebutted in-channel; the disproof is in the data: `db_cpu_pct` (~30%) and `db_query_p99_ms` (~12ms) are flat across the entire window, and recovery happened without ever modifying the DB (only the client-side `db.pool.maxSize` and the flag). A hasty postmortem blames the noisy Redis errors or recommends "scale up the database."
- Where detectable: `reference/logs.md` Redis WARN lines in BOTH the 13:50 baseline block and the incident block, plus `redis_reset_per_min` flat at 1/min across the metrics table (the comparison is left for the reader — no line states "unchanged from baseline" anymore); `cache.failMode=open` noted without commentary. `reference/logs.md` metrics block: flat `db_cpu_pct` and flat `db_query_p99_ms` throughout (no narration calls this out). `reference/chat.md` 14:13 (Redis foregrounded, unrebutted), 14:36 (DB-scale question raised), 14:46 ("we never touched the DB ... so much for the capacity theory" — the only soft hint). `reference/timeline.md` 14:38 ("DB itself was not modified") + 14:36 (late Redis dismissal).
- Minimum credit (to score "found" on this item, the solver must ACTIVELY rule it out WITH cited evidence): Explicitly names at least one of the decoys (Redis resets OR DB-capacity/overload) as NOT the cause AND cites the specific disproving evidence — for Redis: the resets run at the same cadence in the pre-deploy baseline as during the incident AND/OR the cache fails open; for DB: `db_cpu_pct`/`db_query_p99_ms` flat throughout AND/OR recovery required no DB change, only the client-side pool config. A bare assertion "it wasn't Redis/the DB" without the evidence = PARTIAL (not full found). Merely not mentioning the decoy = missed (no credit). Endorsing either decoy as a cause/contributor = precision penalty (phantom finding). Note: with the in-channel rebuttals removed, silently-correct omission is now even less likely to be confused with active dismissal — require the cited disproof.
</content>
</invoke>
