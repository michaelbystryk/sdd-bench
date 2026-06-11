# P9 — Success Criteria (pv0.3) — HARNESS-ONLY

P9 (incident postmortem; profile: incident/ops; **planted-truth task** — objective recall
against the sealed `answer-key.md`). Applied after a cell completes; identical across all
four arms.

Universal P-track rubric (5 anchored dims + objective-recall axis + scrub protocol):
[`harness/party/scoring-rubric.md`](../../../harness/party/scoring-rubric.md). This file
declares P9's keyed items, which of the 5 dims are load-bearing, task-specific scoring
detail, failure modes, and the headline contrast.

Deliverable under test: `postmortem.md` — sections Summary; Timeline; Root cause vs
contributing factors; What we ruled out & why; Remediations (with owners/sequencing);
~2–3 pages.

---

## 1. Objective recall expectations (planted items)

Four keyed items in `answer-key.md` (SEALED). Score each **found / partial / missed**
citing the deliverable line, then a precision note. Summary of the spread:

| Item | What | Subtlety | Notes on scoring |
|---|---|---|---|
| **K1** | True root cause: pool exhaustion from `maxSize` 50→20 **combined with** the new synchronous `inline_enrichment` query, under sale load | subtle (correlate 3 artifacts) | PARTIAL if only "the deploy" or only one of the two coupled changes is named. Blaming DB capacity = not found (K4 leakage). |
| **K2** | Contributing: no alert on pool saturation / acquire-wait; only the lagging 5xx page fired | moderate | Found if the missing pool/wait alert (vs only 5xx) is named as a diagnosis-delaying gap. |
| **K3** | Contributing: enrichment call has no timeout / no circuit breaker, so it holds connections instead of failing fast | moderate | Found if missing timeout/breaker/fallback on the enrichment (or DB) path is named as an amplifier, distinct from K1. |
| **K4** | Decoy: blaming the pre-existing Redis resets OR "the database is overloaded/slow" | decoy / precision trap | **Found only if actively DISMISSED with evidence.** Silence = missed. Endorsing it = phantom finding (precision penalty). |

**Recall is published as the raw fraction (n/4) plus the precision note.** Never folded
into the /25 quality sum. A postmortem that fingers K1, cites K2+K3, and rules out K4 with
evidence is the 4/4 target.

**Precision note guidance:** common phantom findings to count against precision — "Redis
outage caused the failures" (K4 endorsed; the materials now foreground the Redis WARNs with
no early rebuttal, so this is the most likely trap), "database ran out of capacity / needs
scaling" (K4 endorsed; the in-channel rebuttal was removed, so the solver must catch the flat
DB metrics themselves), "the sale traffic alone caused it" (load was necessary but not
sufficient; the service had handled 1k+ rps before per chat — load with no config change = no
incident), "the `async_receipts` flag caused it" (clean decoy added to the diff — it moves
work OFF the request path and is harmless), "the load balancer ejecting pods caused it" (clean
decoy — the pod ejection at 14:08 is a symptom of the request queue backing up, not a cause;
chat explicitly parks it), "a memory leak / GC pause" (nothing in materials supports it),
"the deploy itself failed / bad code shipped" (deploy was healthy on readiness; the harm was
config + flag, not a code defect).

## 2. Which of the 5 dims are load-bearing for P9, and why

All five are blind-rated (per track rule). **Load-bearing for P9:**

- **Correctness** — the whole task is getting the causal chain right and *not* asserting a
  phantom cause. The K4 decoy plus the necessary-but-not-sufficient role of load make this
  the dimension most able to separate a careful from a hasty postmortem. A writeup that
  endorses the Redis or DB-capacity story is wrong at the center, not imprecise at the edge.
- **Insight depth** — the root cause is only visible by correlating three artifacts (config
  diff + flag + the pool-wait-vs-DB-query-time split in metrics). Naming the *interaction*
  of two individually-safe changes, and reading that DB-server health was flat while
  client-side pool wait blew up, are the non-obvious findings. Restating "we got a 5xx
  spike after a deploy" is the floor.
- **Actionability** — remediations must have owner roles + sequencing and map to the
  specific gaps (K2 alert, K3 timeout/breaker, the coupled-release process gap), not
  generic "improve monitoring." The brief asks for this explicitly.

**Supporting (still rated, less discriminating here):**

- **Coverage** — all five required sections present and substantive, including an explicit
  "What we ruled out & why" that engages the decoys. Timeline reconstruction faithful.
- **Communication** — blameless tone, director-readable summary, within the 2–3pp band.
  Bloat (a 6-page log dump) is scored down here, not rewarded as coverage.

## 3. Task-specific scoring detail (4 vs 5 on the load-bearing dims)

**Correctness.** 3 = identifies pool exhaustion as the mechanism, no major false claim. 4
= pool exhaustion correctly attributed to the *combination* of maxSize 50→20 and the new
synchronous enrichment query under load, with no endorsed decoy. 5 = above + correctly
handles the subtle point that load was necessary-but-not-sufficient (the same config would
have been fine at baseline rps; the same load would have been fine at maxSize 50) and that
DB-server health was never the constraint — i.e. gets right exactly where a competent
reader would slip.

**Insight depth.** 3 = at least the interaction of the two coupled changes is named. 4 =
above + reads the metrics split (flat `db_query_p99_ms`/`db_cpu_pct` vs blown-up
`db_pool_wait_ms`) as the discriminator that exonerates the DB, and notes the two changes
were each individually justified. 5 = above + a reframe that would change a decision —
e.g. that the real systemic failure is shipping a capacity-reducing config change coupled
with a load-increasing feature flag in one release with no canary on pool metrics; or that
"right-sizing the pool to steady-state" is the wrong target because pools exist for the
tail, not the mean.

**Actionability.** 3 = concrete, prioritized remediations a team could start. 4 = above +
each names an owner role and today/this-week/this-quarter sequencing, and maps to a
specific exposed gap (add pool-saturation + acquire-wait alerts → K2; add enrichment
timeout + circuit breaker/fallback → K3; decouple config-capacity changes from feature
flags / canary on pool metrics → K1 systemic; revert or re-justify maxSize). 5 = above +
states what each remediation costs / the risk of NOT doing it, and a success measure (e.g.
"alert must fire before 5xx crosses 1%").

## 4. Failure-mode characterization (observable underperformance)

1. **Blames "the deploy" generically** without naming the two coupled changes or the
   mechanism — K1 partial at best.
2. **Endorses the Redis red herring** as a cause or contributor — K4 missed AND a precision
   hit. The materials make Redis loud AND leave it unrebutted until after mitigation on
   purpose; a top-down reader is baited.
3. **"Scale up / the database was overloaded"** — endorses K4; ignores the flat DB CPU and
   query-p99 series and the fact that recovery touched no DB. The in-channel "DB is fine"
   rebuttal was removed, so this requires reading the metrics. Precision hit.
3a. **Endorses a clean decoy** — fingers `async_receipts` (harmless, moves work off the path)
   or the LB pod ejection (a symptom, not a cause) as causal/contributing. Precision hit;
   these were added to penalize shotgun solvers.
4. **Blames sale traffic alone** — treats load as the root cause without noting the service
   had handled ~1k rps before and that the config/flag change is what made this load fatal.
5. **Finds only one of the two coupled changes** (e.g. names the pool cut but misses the
   enrichment query, or vice versa) — K1 partial.
6. **Misses K2 (alerting gap)** — writes a clean RCA but never notes the team had no
   leading signal and only the lagging 5xx page fired.
7. **Misses K3 (no timeout/breaker)** — names the cause but not the amplifier that turned
   saturation into a full outage instead of slow responses.
8. **Generic remediations** — "improve monitoring," "add more tests," no owners, no
   sequencing, not mapped to the specific gaps. Actionability ceiling 2.
9. **No "ruled out" section, or a hollow one** — omits the decoy discussion entirely, so
   K4 cannot score found; the section exists but only restates the cause.
10. **Bloat / log-dumping** — pastes the metrics table wholesale and narrates every line
    instead of synthesizing; over the length band. Communication hit, not coverage credit.
11. **Blame-y tone** — fingers the PR #4471 author or the person who flipped the flag by
    name/role instead of the process gap. Communication hit.
12. **Timeline distortion** — asserts the DB or Redis as cause in the timeline section,
    contradicting its own later analysis, or gets the deploy/load ordering wrong.

## 5. Headline finding (the contrast this task is designed to reveal)

P9 is built so the *loudest* signal (Redis resets, flooding the logs) and the *most
available* explanation ("DB slow / scale it up", "the sale did it") are both wrong, and the
true cause is only visible by correlating a quiet config diff, a flag flip, and the
pool-wait-vs-query-time split in the metrics. The question the task probes: **does
multi-persona deliberation (A4) actually correlate the three artifacts and actively dismiss
the decoy better than a single careful pass (A1)** — or does the roundtable, like the
incident channel it mirrors, get anchored by the loudest error line and the first plausible
theory? An ops/SRE persona that earns its seat should be the one to say "DB CPU is flat,
it's the pool, not the database" and "those Redis errors predate the incident." If A4's
deliberation surfaces and rules out K4 with evidence while A1 quietly omits it (scoring
neither found nor a precision hit, just a thinner postmortem), that's a point for the
machinery. If A1 nails K1–K4 in one pass and A4 spends tokens re-litigating the red
herrings the chat already raised, that's the masquerade read — and just as publishable.

## calibration

Cold-pass recall: first calibration pass scored 4/4 and dismissed both decoys unprompted —
verdict TOO EASY (materials over-signposted; the chat transcribed the entire RCA and the
error string pre-correlated the pool saturation). Hardened (see answer-key HARDENING NOTE):
(a) error string de-correlated — solver must JOIN `db acquire: timed out` to the config max
and the metrics pool series for K1; (b) Redis/DB dismissals removed from the chat so the loud
Redis WARNs stand unrebutted, making K4 a live trap; (c) K3's "no timeout/no breaker"
phrasing removed — now inferable from behavior; (d) clean decoys (`async_receipts`, LB pod
ejection) added. Target after hardening: a 2–3/4 cold solo Opus 4.8 pass (≈3–8 on the
10-scale), with K4 the item most likely to be endorsed-as-cause (precision hit) or left
as a bare unsupported assertion (partial). Re-run a cold pass to confirm; if it still lands
4/4 with both decoys cleanly dismissed, bury the config diff further or add a third decoy.

## provenance

N/A for P9 — incident artifacts in `reference/` are fully fabricated (no upstream repo,
no real logs). No vendored material; no license. Service name, timestamps, commit SHAs,
PR numbers, and metric values are invented and internally consistent only within this task.


## Calibration record (2026-06-09) — re-roled: recall=floor, precision=signal



Two cold-pass rounds (Opus 4.8 solo = arm A1 stand-in). Result fed the track-wide
**detection-saturation** re-role: recall is a floor check; the keyed decoys + precision are
the objective discriminator. See `analysis/party-findings/00-detection-saturation.md` and
`harness/party/scoring-rubric.md` § Objective floor + precision axis.
