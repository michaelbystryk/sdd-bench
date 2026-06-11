# Test strategy: Scheduled Exports

This plan concentrates QA effort where this feature can actually deliver a wrong,
missing, duplicate, or mistimed file — and names what we are deliberately not
testing for v1. It assumes a competent squad and a normal per-PR CI suite.

A note before the ranking: three of the spec's open implementation questions
(§5 — partial-vs-failed semantics, the run-job idempotency key, artifact
retention) are not test problems, they are *design* problems that gate the tests
below. **Resolve them before the squad writes the affected code.** Testing cannot
paper over an undecided dedup strategy.

## Risk assessment (ranked)

| # | Failure mode | How it bites the customer | Why it's likely | Severity |
|---|---|---|---|---|
| 1 | **Duplicate run / duplicate delivery** | Same report delivered twice (worse: webhook fired twice, file written twice to their bucket) | SQS is at-least-once; visibility timeout is 5 min but large reports take 3–6 min, so the message *re-appears mid-run by design*. Two scheduler replicas can also double-enqueue if the lease is weak. Idempotency key is undecided (§5). | **Critical** |
| 2 | **Wrong-moment / missed run** | Report fires at the wrong local time, or never fires | `next_run_at` is timezone + DST + calendar math: spring-forward/fall-back, "31st" in a 30-day month, "last day of month", weekday rollover. Pure logic, silent when wrong, hits every schedule. | **Critical** |
| 3 | **Silently wrong contents** | File looks fine but undercounts or covers the wrong window | Two causes: (a) date-window resolution ("previous full day" in *which* tz?) off-by-one at boundaries; (b) ingestion lag up to ~30 min means a 00:05 "previous day" run reads an incomplete day. The customer can't tell. | **High** |
| 4 | **Missing file / silent failure** | Customer expects a file, none arrives, and we may not know either | Email delivery is fire-and-forget; a delivery failure (bad customer creds, dead webhook) may not surface; a job can be lost to a crash without DLQ/redrive. | **High** |
| 5 | **Cross-tenant / link leakage / SSRF** | Workspace A receives B's data; signed link over-scoped or long-lived (7 days); webhook POST aimed at an internal address | First outbound-to-third-party feature; signed URLs, assume-role into customer accounts, and customer-supplied URLs are all new attack surface. Low probability, high blast radius. | **High** |
| 6 | Wrong-destination fan-out / format defects | Right data, wrong recipient, or broken CSV/XLSX (escaping, unicode, CSV-injection) | Fan-out to ≤5 destinations + templated keys invites mix-ups; delivered files reaching third parties make CSV formula-injection a real concern. | **Medium** |
| 7 | UI/CRUD, run-history display, limits | Annoyance, not data harm | Standard request/response paths we already know how to build. | **Low** |

The ordering reflects one judgment: **the queue/timing/data risks (1–4) are
structural and silent**, so they get the bulk of the effort; security (5) gets
targeted depth; everything below gets light touch.

## Coverage plan by layer

**Risk 2 (timing) and Risk 3a (window) → exhaustive unit tests with a frozen
clock.** This is the highest-leverage spend: the logic is pure, deterministic,
and cheap to cover densely. Build a parametrized table of `next_run_at` cases —
every frequency × a year of DST transitions in a few representative zones (US,
EU, a half-hour offset like India, a no-DST zone), Feb-29/30/31 day-of-month,
last-day-of-month, weekday rollover, and the workspace-default-tz fallback. Same
treatment for date-window resolution at day/week/month boundaries. If a bug here
can be caught by a unit test, it must *never* be the job of an e2e test.

**Risk 1 (duplicates) → integration tests against a real queue
(LocalStack SQS), not unit mocks.** A race condition cannot be unit-tested.
Once the team picks a dedup key (recommend a logical *occurrence id* =
`schedule_id + scheduled_instant`, so re-delivery is detectable end-to-end),
write integration tests that: redeliver the same message, simulate a worker that
exceeds the visibility timeout, run two scheduler replicas against one due
schedule, and assert **exactly one delivered artifact per occurrence**. Also
explicitly test the visibility-timeout-vs-generation-time case from the spec —
that's the smoking gun.

**Risk 4 (silent failure) and Risk 6 (delivery) → contract tests per adapter +
a thin integration layer.** Each delivery adapter (S3, GCS, webhook) gets
contract tests against an emulator/mock asserting the failure contract: 4xx →
that destination marked failed (not the whole run), webhook non-2xx/timeout →
backoff retry up to 4 over ~15 min with a *stable* `delivery_id`, and partial
failure produces the agreed run status. Use a virtual clock for the backoff
timing so these stay fast and deterministic. Verify every failure path writes a
visible run-history record — the "missing file we don't know about" case is the
one to hunt.

**Risk 5 (security) → a small, specific suite, reviewed by security.** Signed-URL
scope and expiry (can't be edited to reach another artifact; honors 7-day TTL);
a cross-tenant authz test on artifact retrieval; SSRF guard on webhook *and*
cloud-storage targets (reject internal/link-local addresses, validate at
create-time and re-validate at delivery); CSV-injection neutralization in
serialized output. These are few but non-negotiable for launch.

**E2E → deliberately thin.** Two scripted scenarios in staging only: one full
happy path (schedule → fire → generate → deliver via email link, download works)
and one partial-failure path (one good destination + one failing destination →
correct per-destination status). E2E exists to prove the wiring, not to re-cover
logic the lower layers already own.

## Explicitly out of scope for v1

These are decisions, not oversights:

- **The existing report-query engine and notification service.** Spec §4 says we
  reuse them unmodified. We test *our* call into them and our handling of their
  responses — not their internals.
- **Load/throughput testing.** ~2,000 schedules is modest. We will run a single
  *thundering-herd smoke* (a cluster of schedules at `:00`) to confirm the
  scheduler/queue don't fall over, but no sustained load suite. [ASSUMPTION]
  2,000 at launch is comfortably within normal infra headroom.
- **Reports >500k rows and file-splitting** — blocked at creation (§4).
- **Free/Pro tier paths** — they can't create schedules; one negative authz test,
  no further coverage.
- **Exhaustive XLSX formatting/locale matrix** — verify it opens, headers, types,
  unicode, and injection-safety on a representative file; we don't fuzz every cell
  format.
- **In-app artifact browser** — not built in v1 (§4).
- **Cross-browser coverage of the schedule-builder form** — smoke on the primary
  supported browser; the form is low-risk CRUD.
- **Cloud providers' own durability/availability** — not ours to test.

## Tooling & CI gates

**Blocks merge (every PR, fast):** unit suites for `next_run_at` and date-window
(frozen clock); adapter contract tests; lint + types; the core idempotency
integration test against LocalStack. A **coverage floor on the scheduling and
window modules specifically** (e.g. ≥90%) — not a global percentage, which just
rewards testing easy code.

**Nightly (slower, integration):** full DST matrix over a simulated year; the
race/redelivery/two-replica suite; DLQ-and-redrive behavior; GCS emulator and
webhook backoff-timing tests (virtual clock); thundering-herd smoke.

**Pre-release (staging gate):** the two e2e scenarios + sign-off on the security
suite. Manual sanity-check of a real delivered file to each destination type.

**Watch in production, don't gate on (these can't be honestly tested
pre-release):**
- **Reconciliation:** expected occurrences vs actual runs per minute — catches
  missed and duplicate runs in the wild. This is the single most valuable signal.
- **Duplicate-delivery detector:** deliveries counted per occurrence id; alert on
  >1.
- Delivery success rate broken out per destination type; DLQ depth; scheduler
  liveness / clock skew; signed-link 4xx (expiry/leak) rate.
- **Data-freshness monitor** for the late-landing risk (Risk 3b) — flag runs
  whose window closed while ingestion lag was high; consider a small built-in
  read delay as a product mitigation.
- A **synthetic canary schedule** running every few minutes in prod, asserting it
  fired on time and delivered exactly once — continuous proof of risks 1, 2, 4.

The through-line: spend hard on the silent, structural risks (1–4) at the
cheapest layer that can catch each, keep security tight and specific, and lean on
production reconciliation for the failure modes that only show up at real scale.
