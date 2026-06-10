# Test Strategy: Scheduled Exports

**Status:** Draft for squad + QA sign-off · **Target:** Q3 · **Owner:** Reporting squad
**Scope:** Test strategy and priorities for the v1 Scheduled Exports feature. This is a planning document, not a test plan — it says *where the effort goes and why*, not which assertions to write.

## Why this feature needs its own strategy

This is the first thing we ship that runs **unattended on a timer** and **reaches into other people's systems**. Our existing instincts are tuned for request/response with a human watching. Here, no one is watching when it fires, the queue is at-least-once, the clock has DST in it, and the data source is eventually consistent. Equal-weight, test-every-field coverage would burn our fixed QA budget on the low-harm surface and under-defend the three places this actually bites. The plan below concentrates effort on the trust-critical failure modes and is explicit about the cuts.

---

## 1. Risk assessment — what can hurt us most, ranked

The unit of harm is what the customer experiences: a **wrong**, **missing**, **duplicate**, or **wrong-moment** file. Two risks sit at the top — one ranked by *likelihood* (duplicate is near-guaranteed by our own numbers), one by *impact* (a silently wrong file is the worst outcome even if rarer). Both are tier-1.

| # | Failure mode | Mechanism | Likelihood | Harm | Tier |
|---|---|---|---|---|---|
| 1 | **Silently wrong file** (plausible but incomplete) | A "previous full day" run at 00:05 reads the analytics store while ingestion still lags (up to ~30 min). File generates, uploads, and delivers cleanly — just undercounts. No error fires on either side. | Medium | **Severe** — customer acts on it (board deck, billing, downstream pipe) without knowing; when discovered, trust in *every* prior export collapses | **1** |
| 2 | **Duplicate file** (redelivery) | SQS visibility timeout is 5 min; large reports take 3–6 min. Worker A is still generating when the message becomes visible; worker B picks up the *same* message → two files, two fan-outs, two webhook POSTs (with different `delivery_id`s), two emails. At-least-once + no idempotency makes this the *steady state* for big reports, not a rare race. | High | Moderate–high — looks sloppy; corrupts append-style ingestion on the customer side | **1** |
| 3 | **Wrong-moment file** (DST / `next_run_at` math) | Converting "06:00 America/New_York" to the next UTC instant across spring-forward (nonexistent local time) and fall-back (ambiguous local time); monthly "last day" and day-31 in short months. A wrong offset silently corrupts a schedule forever. | Medium | Moderate — erodes scheduling trust; plausible enough to slip past review | 2 |
| 4 | **Duplicate via lease race** | Two scheduler replicas; the row-lock lease is "intended" to prevent double-enqueue. If the lease isn't committed before enqueue, both replicas enqueue the same occurrence. | Low–medium | Same symptom as #2 | 2 |
| 5 | **Missing file** (delivery exhausts retries) | Webhook/cloud delivery fails all 4 attempts, or all destinations fail. | Medium | **Low** — self-announcing; the customer notices and recovers (re-run / support). The customer is our backstop here. | 3 |

**Design seams the strategy depends on (must be decided before/with the tests, not after).** These are the open implementation questions from the spec — they are not optional polish; they determine whether the feature is *correct*:

- **Idempotency key = the occurrence**, i.e. `schedule_id + scheduled next_run_at` — *not* the SQS message id. Dedup must be enforced at **delivery commit**, not just at generation start, or a redelivered slow run still double-delivers. This single decision neutralizes both #2 and #4 (lease becomes defense-in-depth, not the primary guard).
- **Data-freshness contract** for #1: define a watermark / late-data threshold and decide whether a run **waits, warns, or stamps** "data-as-of" into the file and email so the customer can self-assess. [ASSUMPTION] we will ship a visible "data-as-of" timestamp in v1 rather than block runs on a watermark, because blocking interacts badly with the fixed run schedule.
- **All-deliveries-failed = `failed` or `partial`?** Pin it — it decides whether the customer is ever told (#5).

---

## 2. Coverage plan by layer

Principle: catch each bug at the **lowest level that catches it deterministically**, and never re-test code we don't own — test it at the **seam** where we call it.

**Unit (deterministic logic — the bulk of the bug-catching budget).**
- `next_run_at` computation: local time + timezone + frequency → next UTC instant. DST spring-forward/fall-back, "last day of month," leap-day, monthly rollover. Pure function, table-driven; this is the one place "test every case" is *right* because the input space is small and the cost of a bug is a forever-wrong schedule. E2E here would be absurd (waiting real minutes for a leap-year case).
- Date-window resolution ("previous full day/week/month," "month-to-date") in the schedule timezone.
- Idempotency-key derivation and the dedup decision function (given a key + dedup record → run or skip).
- Fan-out partial-failure state machine: given 5 destination outcomes → recorded run status + retry classification, including the `failed`-vs-`partial` rule.
- CSV/XLSX serialization: escaping, encoding, row fidelity against known fixtures.

**Integration (real queue / Postgres / localstack — only where concurrency or redelivery *is* the bug).**
- **Redelivery mid-generation** (5-min visibility vs 3–6-min generation): prove a redelivered message produces **exactly one** delivered file. This is the core correctness test and only surfaces against real queue timing. Worth every cent.
- **Lease under 2 replicas:** two schedulers racing the row-lock do not double-enqueue. You cannot unit-test a race.

**Contract (recorded request/response shapes — the honest substitute for live third-party e2e).**
- S3/GCS `PutObject` + assume-role: success and 4xx shapes (bad creds, missing bucket, access denied) map to per-destination delivery failure.
- Webhook envelope: exact JSON shape, 2xx-in-10s, and **same `delivery_id` across all 4 retries**. Pin the shape so any drift fails loudly. Standing up real customer buckets in CI is slow and flaky — don't.

**Seam (not internal re-testing).** The report-query engine and notification service are reused as-is. Test *our invocation* — arguments, error handling, the fire-and-forget contract — not their internals. Re-testing their logic pays twice.

**End-to-end (thin, happy-path only).** One or two: scheduler fires → worker generates → file in S3 → one delivery → run record written. Smokes that the wiring holds. Pushing failure permutations or retry timing through e2e is the trap — slow, flaky, and already proven at the integration/contract layer.

**Production checks (things no pre-release test can catch).** Ingestion-lag completeness, real third-party flakiness, expired customer roles, silently dropped emails, the true clock-distribution of duplicates. These are caught by instrumentation, not tests — see §4.

---

## 3. Explicitly out of scope for v1

Each item is a **risk-accepted decision**, not an oversight. Squad and QA should sign off on this list so nothing here is a surprise later. Where relevant, we name what we monitor *instead*.

- **Exhaustive per-field UI validation** — standard form patterns, low harm. We smoke the create-schedule happy path and the >500k-row block only.
- **Reused query-engine internals** — already in production and tested; we test our call into it, not its correctness. *Monitor:* rowcount sanity vs. prior runs.
- **Every timezone on Earth** — we test UTC edge cases plus the DST-active zones our customers actually use; the long tail is skipped. *Monitor:* `next_run_at` drift alerts.
- **Load/scale beyond ~2× launch volume** — launch is ~2,000 schedules; we test to ~2× headroom, not 100×. *Monitor:* queue depth + lease contention at top-of-hour.
- **Security pen-testing of signed URLs** — we verify link expiry works (7-day window); we do not pen-test the signing scheme in v1. *Flagged* for a dedicated security pass post-launch. *Monitor:* access logs.
- **In-app artifact browser, multi-file splitting, >500k-row reports** — not built in v1 (per spec), so nothing to test.
- **Free/Pro plan paths** — schedules are Business/Enterprise only; we test the gate, not the disabled experience.

---

## 4. Tooling & CI gates

Gates are calibrated to a fixed Q3 date and a **flag-gated, internal-first staged rollout**. The internal phase is itself the load-bearing integration test — *we are our own first customer* — so we don't try to fixture in CI what only real traffic reveals.

**Blocks merge (every PR — fast, deterministic, < ~5 min, zero network):**
- All Unit-layer tests from §2 (`next_run_at`/DST, date windows, idempotency-key + dedup decision, fan-out state machine, serialization).
- Contract/schema tests on the run-history record and the webhook envelope shape.
- Lint + typecheck.

**Runs nightly / pre-release (localstack or staging — too slow/heavy to block a PR):**
- Redelivery-under-visibility-timeout and the two-replica lease race (the §2 integration tests).
- Live-ish S3/GCS/webhook delivery incl. auth-failure and timeout paths.
- A load shape mimicking ~2,000 schedules clustered at `:00`/`06:00`/`09:00`.
- The thin e2e smoke.
- **Gate:** a green nightly is required before bumping the flag to the next ramp tier.

**Not gated — watched in production during the staged ramp:** customer-specific bucket-policy/KMS rejections, real webhook slowness/flakiness, actual ingestion-lag completeness, the real distribution of duplicates. You cannot fixture a customer's misconfigured bucket; gating on it is theater.

**Day-one alerts (live before the internal rollout, tied to the ranked risks):**
1. **Duplicate-run** — same idempotency key delivered > 1×. *Page-worthy; trust-critical (risk #2/#4).*
2. **Missed-run** — a scheduled occurrence with no start within N min of `next_run_at` (catches lease starvation and herd backlog; risk #5).
3. **Generation duration approaching the 5-min visibility timeout** (p95/max) — leading indicator of duplicate risk *before* it bites.
4. **Delivery-failure rate** per destination type, with **partial** fan-out failures broken out from **total** failures.
5. **Queue depth/age at top-of-hour + DLQ count > 0.**
6. **Data-freshness / rowcount anomaly** vs. the same schedule's prior runs — the only signal we'll get for silently-wrong-file (risk #1).

**Ramp gate:** clean duplicate-run and missed-run signal through internal workspaces and the first Business tier before opening Enterprise. The flag remains the kill switch throughout.

---

*Tagged assumptions: data-as-of timestamp shipped in lieu of watermark-blocking (§1); "test the timezones customers actually use" rather than all zones (§3). Both are reversible and should be confirmed at sign-off.*
