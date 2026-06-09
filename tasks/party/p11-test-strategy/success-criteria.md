# P11 — Success Criteria (pv0.3)

P11 (QA / test strategy for a scheduled-export feature; **rubric-scored**, no
planted answer key). Profile: quality. The discriminator is whether the
deliverable is a **risk-based** plan that finds the scary integration seams, says
what NOT to test and why, and picks proportionate tooling/CI gates — versus a
generic "happy path + some edges, tested at every layer" checklist that treats all
of the feature as uniformly risky.

Universal P-track rubric (anchors, scoring discipline, scrub protocol):
[`harness/party/scoring-rubric.md`](../../../harness/party/scoring-rubric.md).
This file declares the coverage checklist, which of the 5 dims are load-bearing,
P11-specific scoring detail, failure modes, and the headline contrast.

---

## 1. Coverage checklist (rubric task — no planted key)

The feature spec (`reference/feature-spec.md`) contains a small number of
**high-risk integration seams** that a generic test plan misses. A strong strategy
identifies these as the top of its risk ranking, tests them at the *right* layer,
and reasons about them — not just lists them. This checklist is the rater's
detector for whether the seams were found. Items are **not** seeded to the solver
and are **not** scored as objective recall; they feed the Coverage and Insight
dimensions. Mark each: addressed-well / mentioned / missed.

**Tier-A seams (the scary ones — a risk-based plan should surface most of these):**

- **A1 — Timezone / DST correctness in `next_run_at`.** Run-time is a local clock
  time in a user-chosen tz, stored as a UTC instant (spec §3.1). A strategy must
  call out DST transitions: a `02:30` run on a spring-forward day (nonexistent
  local time) and a `01:30` run on a fall-back day (ambiguous, occurs twice). Bonus
  for "last day of month" / day-of-month-31 edge cases and the
  recompute-next-run-after-fire logic. *Detectable from §2 (tz-picked run time,
  monthly day 1–31 / last-day) + §3.1 (UTC conversion + recompute).*

- **A2 — At-least-once delivery → duplicate runs / duplicate files.** SQS is
  at-least-once; the run-job visibility timeout is 5 min but large reports take 3–6
  min (spec §3.2), so a job can be redelivered *while still being processed* →
  two workers generate and deliver the same occurrence. Also the 2-replica
  scheduler with only a "lightweight lease" (§3.1) can double-enqueue. A strong
  strategy ties these to the spec's own open question on idempotency (§5) and tests
  the dedup/idempotency path, not just "the queue works." *Detectable from §3.1
  (2 replicas + lease), §3.2 (visibility timeout 5 min vs 3–6 min runtime), §5
  (idempotency open question).*

- **A3 — Eventual-consistency window on the data source.** Ingestion lag is
  minutes, up to ~30 min (spec §3.4); a "previous full day" export firing at 00:05
  reads a day still receiving late events → silently incomplete files that *look*
  successful. This is the subtle one: the run succeeds, the file is wrong. A strong
  strategy proposes a guard (firing offset / completeness check / watermark) and a
  test for "data not yet settled." *Detectable from §3.4 + §2 (00:05-style
  windows / "previous full day").*

- **A4 — Webhook / cloud-storage delivery: retries, partial failure, idempotency
  across destinations.** Up to 5 destinations per schedule; webhook retries 4× over
  15 min with a stable `delivery_id` (§3.3); customer S3/GCS can 4xx. A strong plan
  tests *partial* delivery (3 of 5 succeed), retry-without-duplicate (receiver
  sees same `delivery_id`), and the success-but-all-deliveries-fail status question
  (§5). Contract tests against the third-party seams rather than full e2e.
  *Detectable from §3.3 + §2 (fan-out to 5) + §5 (partial vs failed status).*

**Tier-B (should appear, lower weight):**

- **B1 — Generation/delivery partial-failure & run-status semantics** (the §5
  partial-vs-failed open question reasoned about, not just restated).
- **B2 — Signed-link expiry / authz** (7-day link, plan-gating Business/Enterprise
  only, customer-bucket assume-role boundary).
- **B3 — Schedule lifecycle vs in-flight runs** (edit/pause/delete after a job is
  enqueued; spec §3.2 step 1 drop-if-paused — race between edit and fire).
- **B4 — Scale/clustering** (~2,000 schedules clustered at top-of-hour /
  00:00/06:00/09:00 local — thundering herd; §4). Worth a load/soak note, not a
  unit test.

A 4–5 Coverage score requires most Tier-A seams **addressed well** (tested at a
named layer with reasoning), not merely listed.

## 2. Which of the 5 dims are load-bearing for P11, and why

All five are scored. **Insight depth, Coverage, and Actionability are
load-bearing**; Correctness gates; Communication guards against checklist-bloat.

- **Insight depth (load-bearing).** The whole task. A generic plan ("test happy
  paths, add edge cases, do some e2e") scores 2 regardless of length. The signal is
  whether the solver *discovered the seams the spec embeds but never labels as
  risky* — the DST ambiguity, the redelivery-during-processing window, the
  consistency-lag silent-wrong-file. These are second-order and require reading the
  spec as an adversary. Connecting two facts (5-min visibility timeout *and* 3–6-min
  runtime → redelivery) is the canonical insight-depth move here.

- **Coverage (load-bearing).** Did it cover all four required sections *and* the
  Tier-A seams *and* the right-layer reasoning? But note the length-band rule: an
  exhaustive 200-item checklist does **not** buy coverage points — it costs
  Communication. Coverage here means the *risk surface* is covered, not that every
  field has a row.

- **Actionability (load-bearing).** A test strategy a squad can act on tomorrow:
  named layers, named tooling, concrete CI gates (what blocks merge vs nightly vs
  prod-watch), and an honest out-of-scope list that reads as a *decision* with
  rationale. Vague "we should test the scheduler thoroughly" is a 1–2.

- **Correctness (gates).** Test-level choices must be technically sound: don't
  propose flaky wall-clock-sleep tests for DST (use injected clock / frozen time);
  don't propose hitting real customer S3 in CI; don't claim a unit test can prove an
  at-least-once dedup property. A plan that misroutes effort (full e2e for
  everything, or unit tests for the consistency window) takes Correctness hits.

- **Communication (guards bloat).** ~2 pages, four sections, ranked risk,
  conclusions findable in one pass. The masquerade this task hunts is *volume sold
  as value* — a 9-page test matrix is a Communication failure, not a Coverage win.

## 3. P11-specific scoring detail (what 4 vs 5 looks like per load-bearing dim)

### Insight depth
- **3:** identifies at least one Tier-A seam as a genuine, non-obvious risk and
  explains the mechanism (e.g. "DST spring-forward makes 02:30 nonexistent").
- **4:** surfaces several Tier-A seams with mechanisms *and* engages a second-order
  interaction — e.g. ties the 5-min visibility timeout to the 3–6-min runtime to
  explain redelivery-during-processing, or notes the consistency-lag failure is
  invisible because the run reports success.
- **5:** above + a reframe that would change the build plan — e.g. "the idempotency
  key isn't a test concern, it's an unmade design decision (spec §5); the strategy
  should block the build until it's decided, because no test can compensate for an
  at-least-once pipeline with no dedup key," or proposes a single
  occurrence-identity key that simultaneously closes the duplicate-run, retry, and
  partial-delivery questions.

### Coverage
- **3:** all four sections present; most Tier-A seams at least mentioned.
- **4:** all four sections; most Tier-A seams *addressed at a named, appropriate
  layer with reasoning*; out-of-scope section is real (not "everything is in
  scope").
- **5:** above + surfaces a material seam the checklist here didn't pre-name that a
  senior QA lead would agree belongs (e.g. clock-skew between scheduler replicas,
  XLSX-vs-CSV serialization fidelity on large/locale data, "last day of month"
  interacting with DST, signed-URL leakage via webhook envelope logging).

### Actionability
- **3:** concrete layered plan a team could start from; CI gates named.
- **4:** above + the layer choice is *justified by risk* (cheap test where cheap
  suffices, contract/integration only where the seam demands it), and out-of-scope
  items state the trade-off of skipping them.
- **5:** above + explicit gates with thresholds (what blocks merge, what's a nightly
  soak, what's a prod alert), and "what would change this plan" conditions (e.g.
  "if we exceed ~10k schedules, revisit the top-of-hour clustering with a load
  test").

## 4. Failure-mode characterization (observable ways a solver underperforms)

1. **The uniform checklist.** Every field, every format, every destination gets an
   equal-weight test bullet; no ranking; no risk concentration. The dominant
   weak-plan shape. Scores Insight 1–2, Communication ≤2 if long.
2. **Happy-path-plus-edges framing.** "Test the happy path, then add edge cases for
   empty data, big files, bad input." Misses every Tier-A seam because they're not
   surface-level edges — they're integration-timing problems.
3. **DST hand-wave.** Mentions "test timezones" but never names the
   nonexistent/ambiguous local-time cases or proposes a frozen-clock approach;
   proposes wall-clock `sleep` tests that would be flaky. Insight + Correctness hit.
4. **"Test the queue" without the redelivery window.** Notes SQS is used, maybe
   "test retries," but never connects 5-min visibility timeout to 3–6-min runtime →
   misses the duplicate-file mechanism entirely.
5. **Consistency-lag missed.** Treats the report query as deterministic; no notion
   that a "successful" run can ship an incomplete file. The subtlest miss; most
   solvers miss it.
6. **No out-of-scope section, or a fake one.** Section present but says "we will
   test everything" or lists trivia ("won't test the logo"). The brief explicitly
   asks for honest, reasoned exclusions; absence is a direct Coverage +
   Actionability hit.
7. **Wrong-layer routing.** Proposes full browser e2e for scheduler timing logic
   (should be unit with injected clock), or proposes hitting real customer
   S3/webhooks in CI (should be contract tests / local fakes). Correctness +
   Actionability hit.
8. **CI gates undifferentiated.** "Run all tests on every PR" with no notion of what
   blocks merge vs nightly vs prod-watch; no acknowledgment that DST/consistency/
   soak tests can't all be merge-blocking. Actionability hit.
9. **Restates the spec's open questions (§5) as findings** without resolving or
   testing them — names idempotency/partial-status but offers no plan. Insight 1.
10. **Bloat masquerade.** 8+ pages, exhaustive matrices, reads as thorough but
    buries the four real risks among 150 trivial ones. Coverage does *not* rise with
    volume (length-band rule); Communication ≤2.

## 5. Headline finding for P11

P11 is built to separate **risk-based testing judgment** from **checklist
completeness**. The feature spec is deliberately constructed so the dangerous parts
are *integration-timing seams that never announce themselves as risky*: a UTC
conversion that hides a DST bug, a visibility timeout that's shorter than the job it
guards, an ingestion lag that makes a successful run ship a wrong file, a fan-out
delivery with retries and no stated idempotency key. A generic "thorough" plan —
the kind that tests every field at every layer — will look longer and *feel* more
complete while scoring lower on Insight and Actionability, because it spends QA
budget uniformly across a non-uniform risk surface and never names what not to test.

The arm contrast this is designed to reveal: does multi-persona deliberation (A4) —
which seats an explicit QA persona — actually surface more Tier-A seams and route
them to the right layer than a solo pass (A1), or does the QA persona mostly produce
a *longer, more confident-sounding checklist* (bloat masquerade) that a single
prompt (A3) or matched thinking budget (A2) matches? If A4's QA lens earns its seat
anywhere, a risk-based test strategy is where it should — the discriminator is seam
discovery + proportionate layering, not test-case count.

## calibration

Cold-pass recall: TBD — filled during calibration. (Target a 3–8 spread on the four
Tier-A seams for a cold solo Opus 4.8 pass: most plans should find DST and the
webhook/partial-delivery seam; the redelivery-during-processing window and the
consistency-lag silent-wrong-file are the discriminating subtle seams expected to be
missed by weaker passes.)
