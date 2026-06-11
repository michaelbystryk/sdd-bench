# Test Strategy: Scheduled Exports

**Status:** Draft for squad + QA review · **Scope:** v1, Q3 release

This is a risk-weighted plan, not a coverage checklist. Scheduled Exports is our first
feature that runs unattended on a timer and reaches into other people's systems, so the
strategy concentrates effort on the few places where the *design itself* makes a bad
outcome likely, and is explicit about what we are choosing not to test and why.

It depends on three product decisions that the spec left open (Section 5). We assume them
here so the testing is concrete; if they change, the affected tests change with them:

- **Idempotency boundary** — exactly-one *delivered file per destination per scheduled
  occurrence*, keyed on `(schedule_id, occurrence_instant)`. [ASSUMPTION]
- **All deliveries failed → run status = `failed`.** `partial` is reserved for genuinely
  mixed outcomes. [ASSUMPTION]
- **Data-freshness buffer** — day/week/month windows do not run until a fixed buffer
  (e.g. 60 min) after the window closes, plus a "data as of" watermark in run metadata.
  [ASSUMPTION]

## Risk assessment (what can hurt us most, ranked)

| # | Failure mode | Customer harm | Why it's likely | Severity |
|---|--------------|---------------|-----------------|----------|
| 1 | **Duplicate file delivered** | Same file twice into their bucket/webhook/inbox; duplicate downstream loads | At-least-once queue; SQS visibility timeout (5 min) is *shorter* than worst-case report runtime (3–6 min) → redelivery mid-run by design. Two scheduler replicas + a lease "intended to" prevent double-enqueue | **Critical** |
| 2 | **File at the wrong moment / missed or doubled run** | Late, early, skipped, or double-fired run; often *also* the wrong data window | `next_run_at` is timezone + calendar math: DST spring-forward (nonexistent time), fall-back (time occurs twice), "last day of month," day-of-month 31 in short months | **High** |
| 3 | **Silently wrong numbers** | A file that looks right but is built on incomplete data; decisions made on it, never caught | "Previous full day" firing at 00:05 reads a day still receiving late-landing events (lag up to ~30 min). The code is "correct"; the data isn't | **High** |
| 4 | **Missing file, no clear signal** | Customer never receives it and/or run history misleads them | Delivery failures (S3 4xx, webhook retry exhaustion), worker crash mid-run, scheduler skips a minute; all-fail run mislabeled `partial` reads as success | **High** |
| 5 | **Data leak / wrong destination** | One customer's data exposed via mis-scoped signed link or assume-role/key-template error | Lower likelihood, but assume-role into customer AWS accounts + 7-day signed URLs make the blast radius a breach | **Med-likelihood / Critical-impact** |
| 6 | Format/limit/CRUD edge cases | Minor: malformed CSV/XLSX, limits not enforced, edit affects in-flight run | Standard, well-understood surface | **Low–Med** |

Risks 1–2 are structural — they are the expected behavior of the system as drawn unless
explicitly defended. They get the most test effort. Risk 3 is mostly a *product rule* plus
a *production monitor*, not an offline correctness test (you cannot test away someone
else's ingestion lag).

## Coverage plan by layer

The principle: push logic down to the cheapest deterministic level, and reserve
infrastructure-heavy tests for behavior that only emerges from real components.

**Unit (fast, deterministic, the bulk of our cases).** This is where most of the
high-value testing lives because most of the risk is in pure functions.
- *Scheduler math* (Risk 2): `next_run_at` and date-window resolution as table-driven
  tests — DST both directions, last-day-of-month, day 31 in Feb/30-day months, week
  boundaries, user-tz vs workspace-default-tz. Plus a **fake-clock year simulation**:
  drive a year of minute-ticks for a schedule and assert the *exact* set of occurrences —
  none skipped, none doubled.
- *Idempotency-key derivation* (Risk 1): same occurrence → same key; DST fall-back's
  repeated wall-clock time → two distinct correct keys; edited schedule → next occurrence
  gets a fresh key.
- *Status derivation* (Risk 4): per-destination outcomes → overall status + human-readable
  reason, covering all-success / all-fail / mixed.
- *Security primitives* (Risk 5): URL signing and expiry, destination key templating.
- *Freshness rule* (Risk 3): "window cannot run until buffer elapsed."

**Contract (against emulated/recorded third parties).** Each destination is a contract
with a system we don't own.
- S3 (LocalStack) and GCS (stub): writes land at the configured bucket/prefix and *never*
  outside it; 4xx from the customer = that-destination-failed, not a worker crash.
- Webhook (local HTTP server): retry with backoff up to 4 attempts over ~15 min, carrying
  a **stable `delivery_id`** across retries so the customer can dedup; 2xx within 10s
  succeeds; non-2xx/timeout retries; partial fan-out (3 of 5 succeed) reported correctly.

**Integration (real queue + worker + dedup store — the one expensive test we insist on).**
- **Forced-redelivery test** (Risk 1): worker A runs past the visibility timeout, worker B
  receives the same message → assert exactly **one** artifact and **one** delivered file
  *per destination*, and one `run` record. This mirrors the production failure exactly.
- **Double-enqueue test**: two scheduler replicas contend on the lease for one due
  schedule in one minute → exactly one job enqueued.
- These may run on the merge queue rather than every PR if too slow, but they block release.

**End-to-end (thin, deliberately).** One happy-path smoke per destination type (due →
job → generate → deliver → run record) against **fakes** in CI. It proves wiring, not
logic — the layers below already prove the logic. One **real-credential canary** in
staging exercises actual assume-role + a real webhook once per build.

**Production checks (what we watch instead of pre-testing).** A continuously-running
**synthetic canary schedule**; alerts on missed runs (a due schedule with no run record),
duplicate detection, delivery success rate per destination type, and a **data-freshness
watermark** (alarm on suspiciously thin row counts) — the real backstop for Risk 3.

## Explicitly out of scope for v1

These are decisions, not oversights:

- **The reused report-query engine and notification service.** The spec does not modify
  them. We test our *use* of them at the boundary (correct query params, correct handoff),
  not their internals. Re-testing them spends budget on code we didn't touch.
- **Reports > 500k rows.** Blocked at schedule creation, so this is *one* validation test,
  not a large-report generation/stress suite.
- **In-app artifact browser.** Not built in v1; nothing to test.
- **Asserting exported data matches the source store.** Non-deterministic against a
  lagging pipeline and tests the pipeline, not us. Replaced by the freshness *rule* (unit)
  and *watermark monitor* (prod).
- **Exhaustive schedule-form field validation.** One parameterized unit test, not a case
  per field.
- **Standing load/performance gate.** 2,000 schedules clustered on the hour is well within
  queue capacity [ASSUMPTION]; verified once with a throughput smoke, not a recurring gate.
- **Cross-browser/visual testing of the schedule UI.** Standard CRUD forms covered by
  existing component tests.

## Tooling & CI gates

| When | Runs | Rationale |
|------|------|-----------|
| **Blocks every PR** | All unit tests; all contract tests (against fixtures/LocalStack) | Fast, deterministic, and guard Risks 2/3/4/5 where the logic lives |
| **Blocks merge/release** (merge queue if slow per-PR) | Forced-redelivery + double-enqueue integration tests on LocalStack | Guard the #1 risk; behavior only emerges from real queue + worker |
| **Nightly** | Full integration matrix; E2E smokes against fakes | Broader coverage without slowing the PR loop |
| **Staging only** | Real-credential canary (real assume-role + real webhook) | Exercises third-party reality that fakes can't |
| **Production (watch, don't pre-test)** | Synthetic canary schedule; alerts on missed runs, duplicates, per-destination delivery rate, freshness watermark | Catches what is environmental, time-dependent, or third-party — untestable offline |

**Hard line:** the forced-redelivery integration test may not be flaky-skipped. If it
flakes there are only two explanations — a broken test or a real duplicate-delivery bug —
and both must be fixed, not muted.

**Where the effort goes, in one sentence:** heavy, cheap unit coverage of the scheduling
and idempotency math; one insisted-upon integration test for redelivery; lightweight
contracts per destination; a thin E2E and a production canary instead of a full e2e suite.
