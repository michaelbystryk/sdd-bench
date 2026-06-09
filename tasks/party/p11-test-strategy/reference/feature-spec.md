# Feature spec: Scheduled Exports

**Status:** Approved for build · **Owner:** Reporting squad · **Target:** Q3 release

## 1. Summary

We are adding **Scheduled Exports** to Acme Analytics. Today a user can click
"Export" on any saved report and get a one-off CSV or XLSX download. Customers on
the Business and Enterprise plans have asked to receive these exports
automatically on a recurring schedule, delivered to a destination of their choice
(email link, or pushed to their own cloud storage / webhook), without anyone
having to log in and click the button.

This is the first feature in our product that runs **unattended on the user's
behalf on a recurring timer**. Everything we ship today is request/response,
triggered by a logged-in user in the browser. Scheduled Exports introduces a
background scheduler, an outbound delivery step to third-party systems, and
artifacts that live in object storage. The reporting team owns the report
generation; the platform team owns the scheduler and delivery infrastructure.

## 2. User-facing behavior

From a saved report, a user can create a **schedule** with:

- **Frequency:** Daily, Weekly (pick weekday), or Monthly (pick day-of-month
  1–31, or "last day of month").
- **Run time:** a clock time, e.g. `06:00`, **interpreted in a timezone the user
  picks** (defaults to the workspace's configured timezone).
- **Format:** CSV or XLSX.
- **Date window:** the report's data window relative to the run, e.g. "previous
  full day", "previous full week (Mon–Sun)", "previous calendar month",
  "month-to-date".
- **Delivery destination** (one or more):
  - **Email:** recipients get a notification with a time-limited signed download
    link (link valid 7 days).
  - **Cloud storage:** push the file to a customer-configured Amazon S3 bucket
    (we assume-role into their account) or Google Cloud Storage bucket.
  - **Webhook:** POST a JSON envelope (containing a signed download URL + run
    metadata) to a customer-supplied HTTPS endpoint.

A user can pause, resume, edit, or delete a schedule. Editing a schedule's time
or frequency takes effect from the next run; it never retroactively changes a run
that already fired. Each workspace can have up to 50 active schedules; each
schedule can fan out to up to 5 destinations.

The user sees a **run history** per schedule: timestamp, status
(success / partial / failed), row count, file size, and per-destination delivery
status. Failed runs surface a human-readable reason.

## 3. System design

### 3.1 Scheduler

- A **scheduler** service wakes up every minute and asks: "which schedules are
  due in this minute?" Due-ness is computed by storing, per schedule, a
  `next_run_at` timestamp in UTC. When a schedule fires, we compute the *next*
  `next_run_at` from the schedule's frequency + run-time + timezone and persist
  it.
- `next_run_at` is computed by converting the user's local run-time (e.g. "every
  day at 06:00 America/New_York") into the next matching UTC instant.
- The scheduler does not run the export itself. It enqueues a **run job** onto a
  durable queue (SQS) and moves on. Workers consume run jobs.
- The scheduler is deployed as 2 replicas for availability. A lightweight lease
  (a row lock on the schedule) is intended to keep two replicas from enqueuing
  the same schedule in the same minute.

### 3.2 Run worker

A worker that picks up a run job does the following, in order:

1. Load the schedule + report definition. If the schedule was paused or deleted
   since enqueue, drop the job.
2. Resolve the **date window** for this run (e.g. "previous full day" in the
   schedule's timezone).
3. Run the report query against our analytics store to produce the result set.
4. Serialize to the chosen format and **upload the file to our internal S3
   bucket**; record the artifact (key, size, row count, checksum).
5. For each destination, perform delivery (see 3.3).
6. Write a `run` record with overall status and per-destination status; update
   run history.

Run jobs have an SQS **visibility timeout of 5 minutes**; if a worker doesn't
delete the message within that window, the message becomes visible again and
another worker may pick it up. Large reports occasionally take 3–6 minutes to
generate.

### 3.3 Delivery

- **Email:** generate a signed URL to the internal artifact, send via our
  existing notification service (fire-and-forget; the notification service has
  its own ret/queue).
- **Cloud storage (S3/GCS):** assume the customer role / use the customer's
  configured credentials, then `PutObject` the file to their bucket at a
  templated key. Treat 4xx from their side (bad creds, bucket missing,
  access denied) as a delivery failure for that destination.
- **Webhook:** `POST` the JSON envelope to the customer endpoint. We expect a
  2xx within 10 seconds. On non-2xx or timeout, **retry with backoff** up to 4
  attempts over ~15 minutes. The envelope includes a `delivery_id`; we send the
  same `delivery_id` on every retry of the same delivery.

### 3.4 Data source

The report query runs against our **analytics store**, which is fed by an
ingestion pipeline that lands events with a typical end-to-end lag of a few
minutes, occasionally up to ~30 minutes under load. A "previous full day" export
that fires at 00:05 reads data for a day that may still be receiving late-landing
events from the ingestion pipeline.

## 4. Constraints & non-goals

- **Plans:** Business and Enterprise only. Free/Pro can't create schedules.
- **Volume:** at launch we expect ~2,000 active schedules across all workspaces,
  most clustered at the top of the hour and at `00:00`/`06:00`/`09:00` local.
- A single run produces a single file (no splitting). Reports above 500k rows are
  out of scope for v1 — they're blocked at schedule-creation time.
- We are not building an in-app file browser for past artifacts in v1; access is
  via the delivered link / pushed file only.
- We reuse the existing report-query engine and the existing notification
  service as-is; this feature does not modify them.

## 5. Open implementation questions (team has not decided)

- Whether a run that succeeds in generation but fails *all* deliveries should be
  marked `failed` or `partial`.
- Idempotency key strategy for the run job (we want exactly-one delivered file
  per scheduled occurrence, but the queue is at-least-once).
- How long to retain internal artifacts (the signed-link target) after delivery.

## 6. Rollout

Behind a flag, internal workspaces first, then a staged ramp to Business and
Enterprise. We want to ship in Q3 and would rather defer scope than slip.
