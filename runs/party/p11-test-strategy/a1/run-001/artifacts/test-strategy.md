# Test Strategy: Scheduled Exports

**Scope:** the new scheduler, run worker, and delivery paths described in
`reference/feature-spec.md`. We reuse the report-query engine and notification
service unchanged — they are out of scope here. The guiding principle: spend QA
effort where a failure is **silent, customer-visible, or hard to reverse**, and
deliberately under-invest everywhere a cheap unit test or a runtime alert is the
better tool.

[ASSUMPTION] The stack uses AWS SQS + S3 as the spec implies, IANA tz data for
time math, and we can run localstack / fake-gcs-server / an httptest endpoint in
CI. Time can be injected via a frozen clock. If any of these are false, the
*levels* below still hold but the tooling names change.

---

## 1. Risk assessment (ranked)

Every failure here maps to one of the four outcomes you named — **wrong**,
**missing**, **duplicate**, or **mistimed** file. Ranked by *blast radius ×
likelihood-without-explicit-design*, not by how much code it touches.

| # | Failure mode | Outcome | Why it's high | Likelihood |
|---|---|---|---|---|
| 1 | **Duplicate delivery.** SQS is at-least-once; the 5-min visibility timeout is *shorter* than the 3–6 min some reports take, so a still-running job gets redelivered. Plus 2 scheduler replicas can both enqueue. Idempotency strategy is an open question (§5). | Duplicate | A customer's bucket/inbox gets two files for one occurrence — or two *different* files if the data window shifted. Erodes trust instantly. | High — it happens by default unless we design against it |
| 2 | **Wrong-moment firing.** `next_run_at` is computed from local-time → UTC across DST transitions, "last day of month", day-of-month 29–31 in short months. | Mistimed / Missing | A run that fires an hour off, twice, or never around a DST boundary or month-end. Pure logic, many edge cases, easy to get subtly wrong. | High |
| 3 | **Silently wrong data.** "Previous full day" fires at 00:05 against an analytics store with up to ~30 min ingestion lag → the file is short rows and *looks* complete. | Wrong | The worst kind: no error, no alert, customer makes decisions on a truncated number. Cannot be "tested away" — it's a design choice (delay the window or the run). | High |
| 4 | **Lost / never-recovered run.** `next_run_at` fails to advance (run never fires again) or advances past a slot (run skipped); a job dropped as "paused/deleted" when it wasn't. | Missing | Silent until a customer asks "where's my Monday file?" Weeks later. | Medium |
| 5 | **Partial-delivery mislabelled.** One of 5 destinations fails; run marked `success`, or all-fail marked `partial`. Semantics undecided (§5). | Missing (perceived success) | Customer thinks they got the file on a channel that silently failed. | Medium |
| 6 | **Signed-URL / authz leak.** A 7-day link resolves to the wrong workspace's artifact, or doesn't expire. | Wrong (security) | Cross-tenant data exposure. Low likelihood, severe if it happens. | Low / severe |
| 7 | **Thundering herd.** Most schedules cluster at top-of-hour and 00:00/06:00. | Mistimed | Backlog pushes runs late; interacts with #1 (timeouts). | Low at 2k scale, worth watching |

---

## 2. Coverage plan by layer

The rule: push each risk to the **cheapest level that can actually exercise its
failure mode**. Time math is deterministic → unit. Concurrency and at-least-once
delivery cannot be reproduced in a unit test → integration with a real queue.

| Risk | Primary level | What we actually test |
|---|---|---|
| #2 Time math | **Unit (heavy, table-driven)** | `next_run_at` and date-window resolution as pure functions over a frozen clock and real tz data. Exhaustive cases: spring-forward / fall-back in a DST zone, the non-existent and doubled local hour, `06:00` on both sides of a transition, monthly day-31 in Feb/Apr, "last day of month" across leap years, weekly weekday rollover. This is where exhaustive *is* cheap — invest here. |
| #1 Duplicate | **Integration (real queue)** + unit | Localstack SQS. Force the three real failure paths: (a) worker exceeds visibility timeout → redelivery while running; (b) both scheduler replicas race the lease in one minute; (c) message delivered twice. Assert **exactly one delivered artifact per occurrence**. Unit-test the idempotency-key derivation and the lease in isolation. This is the single most important non-unit investment. |
| #5 Partial status | **Unit** | Once §5 semantics are decided, the status reducer (per-destination results → overall status) is a pure function. Table-test all-success / some-fail / all-fail. |
| Delivery adapters | **Contract** | S3 → localstack, GCS → fake-gcs-server, webhook → local httptest server. Per adapter: success path, 4xx-from-customer = destination failure (not run failure), 5xx/timeout handling. Webhook specifically: 2xx-within-10s, retry with backoff up to 4 attempts, and **the same `delivery_id` on every retry** (this is the customer's dedup contract — verify it explicitly). |
| #4 Lifecycle | **Integration** | Pause/resume/edit/delete; edit takes effect *next* run and never rewrites a fired run; job enqueued-then-paused is correctly dropped; `next_run_at` always advances exactly once per fire. |
| #6 Authz | **Integration + one security test** | Signed URL resolves only its own artifact; expiry enforced at 7 days; a second workspace's token cannot fetch. |
| #3 Data freshness | **Not a pre-release test — a production check** (see §4) | We can't unit-test ingestion lag honestly. We decide a policy (e.g. delay "previous full day" runs, or accept and document the window) and *monitor* row-count anomalies in prod. |
| Happy path E2E | **End-to-end (thin)** | One or two flows in an ephemeral/staging env: schedule fires → generates → delivers to a test bucket **and** a test webhook → run history shows correct status, row count, size. A smoke gate, not a matrix — combinatorial frequency × format × destination coverage lives at the unit/contract layers, not here. |

---

## 3. Explicitly out of scope for v1

These are *decisions*, not gaps:

- **Field-by-field form validation** of the schedule editor. Standard input
  validation, covered by ordinary dev unit tests — not worth dedicated QA time.
- **Cross-browser UI matrix.** The editor is a normal form; normal coverage only.
- **The report-query engine and notification service.** Reused as-is and tested
  elsewhere (spec §4). We test our *call* into them, not them.
- **Reports > 500k rows.** Blocked at creation. We test the guard rejects them;
  we do **not** build large-file generation/streaming test paths.
- **Exhaustive customer-side error codes.** We test the *class* (any 4xx =
  destination failure, any 5xx/timeout = retry), not every status code or every
  way a customer can misconfigure a bucket.
- **Full load / scale testing.** At ~2,000 schedules the system isn't volume-
  stressed. We do *not* build a load rig. (Thundering-herd, risk #7, is covered
  by a single backlog/latency alert in prod rather than a pre-release test.)
- **Free/Pro plan gating** beyond one permission test — it's a single check.

---

## 4. Tooling & CI gates

Proportionate to where each risk actually surfaces:

**Blocks merge (every PR — fast, deterministic):**
- Unit suite incl. the full time-math / date-window table tests and the
  partial-status reducer.
- Contract tests for all three delivery adapters against emulators.
- Lint + type check.
These must stay under a few minutes so they gate every PR without friction.

**Nightly (slower, environment-heavy):**
- Integration suite on localstack SQS: the duplicate-delivery / redelivery /
  lease-race scenarios (risk #1) and lifecycle scenarios (#4).
- Time-math run pinned against a **specific tz-data version**, plus a job that
  re-runs it when tz data updates — DST rule changes are a real-world regression
  source.
- The thin E2E smoke in an ephemeral env.

**Pre-release gate:**
- Feature flag on; internal workspaces only; a **canary schedule** that fires
  every hour to a test bucket + webhook and is asserted green before each ramp
  step. Staged ramp to Business then Enterprise per spec §6.

**Watch in production (not tested before release):**
- **Duplicate detector:** count delivered artifacts per occurrence — alert on >1
  (risk #1's last line of defense).
- **Missed-run detector:** scheduled-vs-fired reconciliation per schedule
  (risk #4).
- **Data-freshness check:** row count vs. a rolling expectation per report;
  anomaly = likely late-landing-data truncation (risk #3).
- Delivery success rate split by destination type; run latency vs. the 5-min
  visibility timeout (early warning for #1); scheduler backlog at top-of-hour (#7).

**Net:** exhaustive cheap unit tests for time math, a focused real-queue
integration suite for duplication and lifecycle, contract tests for the three
delivery surfaces, a thin E2E smoke — and we accept that data-freshness and
herd behavior are *operated*, not *tested*, because that's where the honest
signal lives.
