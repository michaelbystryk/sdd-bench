# P1 — Success Criteria (pv0.1)

P1 (security threat model of the Lumen fintech wallet platform — planted-truth
task, objective recall + rubric quality). Applied after a cell completes; used
identically across all four arms (A1 solo / A2 matched-thinking / A3 persona-
prompt / A4 party mode).

Universal P-track rubric (5 anchored dims, objective-recall axis, scrub
protocol): [`harness/party/scoring-rubric.md`](../../../harness/party/scoring-rubric.md).
This file declares P1's objective-recall expectations, which of the 5 dims are
load-bearing, task-specific scoring detail, failure modes, and the headline
contrast. The sealed planted-truth enumeration lives in `answer-key.md`
(harness-only, never seeded).

---

## 1. Objective recall expectations (planted tasks)

`reference/system-description.md` embeds **10 keyed weaknesses (K1–K10)** spread
across the STRIDE categories. None is labeled as a weakness in the substrate;
each is inferable only by reasoning about the design. Full enumeration with
detectability + minimum-credit lines is in the sealed `answer-key.md`. Summary
of the spread (titles only here; mechanism + credit bar are in the key):

| Key | Title | STRIDE | Difficulty |
|---|---|---|---|
| K1 | Admin endpoint gated by authn only, no authz | Elevation | obvious |
| K2 | IDOR on wallet/transaction by path id | Info-disclosure / Elevation | moderate |
| K3 | Inbound webhooks not signature-verified | Spoofing / Tampering | moderate |
| K4 | OTP / PII / tokens written to logs, shipped off-platform | Info-disclosure | obvious |
| K5 | Non-atomic balance check→debit (TOCTOU double-spend) | Tampering | **subtle** |
| K6 | Payouts not idempotent → retry double-pays | Tampering | **subtle** |
| K7 | Over-broad / long-lived token (no scope/aud, 30-day) | Elevation / Info-disclosure | moderate |
| K8 | PII plaintext at rest (disk-only encryption) | Info-disclosure | obvious |
| K9 | No rate limit / lockout on OTP request+verify | Spoofing / DoS | obvious |
| K10 | Internal calls trusted by network position; replayable | Spoofing / Repudiation / Elevation | **subtle** |

Recall is scored **found / partial / missed** per item against the answer key,
citing the deliverable line. The three subtle items (K5, K6, K10) are the
discriminators — they require connecting facts across sections (concurrency on
the per-request balance check→in-place write; redelivery/retry + non-atomic
status mark; network-perimeter trust + replay/SSRF on the internal ledger
interface), not spotting a missing config. As of the hardening pass, the
substrate no longer contains the near-verbatim cues for these three: the words
"race"/"atomic" (K5), the label "at-least-once" (K6), and "no token required /
replayable" (K10) have been removed and replaced with behavior the solver must
reason over. Minimum-credit bars for K5/K6/K10 were tightened correspondingly —
in particular **K10 now requires explicit replay-or-SSRF exploitation reasoning
with a money-movement consequence**; bare "network position isn't enough / use
mTLS" is only partial.

**Precision** is published alongside recall: count confidently-asserted threats
that are *wrong for this system*. The substrate now carries explicit decoy
strengths to penalize shotgun solvers — asserting any of these is a precision
penalty: SQL injection (§ 9 — parameterized ORM only, no string concat, checked
across codebase, schema-validated inputs); "no TLS" / plaintext transport (§ 11
— external HTTPS, LB→service TLS, outbound HTTPS with cert validation);
unsigned/unverified JWT (§ 3/§ 11 — HS256 verified every request); unpatched
platform or no dependency scanning (§ 11 — managed-cadence patching + CI dep
scan); public ingress to internal workloads (§ 11 — none; only the webhook
endpoints are intentionally public, which is the real K3 finding). A
missing-encryption claim that ignores the stated disk encryption is likewise
wrong (the K8 nuance is disk≠field, not "no encryption"). Plausible real
findings not in the key (no admin MFA, guessable document-image URL, missing
negative-balance alerting, OTP code is only 6 digits) are logged as valid
extras, **not** precision penalties. A cell that finds 8/10 keyed items plus 10
phantom criticals did not win.

## 2. Which of the 5 dims are load-bearing for P1, and why

All five dims are scored (sum /25). Three are **load-bearing**:

- **Correctness** — the deliverable must reason soundly about *this* system. The
  failure shape here is asymmetric: a threat model that invents
  vulnerabilities the description rules out (phantom SQLi, phantom plaintext
  transport) misdirects the team and is penalized hard. Correctly handling the
  subtle/contested points (e.g. recognizing the disk encryption exists but is
  insufficient for the threat model that matters; recognizing the IDOR rather
  than asserting a non-existent missing-authn) is the 5 anchor.
- **Insight depth** — the keyed subtle items (K5/K6/K10) are second-order and
  are exactly what separates a competent checklist from real review. A model
  that surfaces the double-spend race and the payout idempotency gap is doing
  the non-obvious work; one that only lists the obvious four is at the 2 anchor.
- **Coverage** — STRIDE breadth is explicitly requested. A model that finds five
  info-disclosure issues but no tampering/elevation/repudiation issue has a
  lopsided model. Coverage tracks against the K-spread AND the implicit
  categories.

The other two still discriminate:

- **Actionability** — Mitigations must be concrete and prioritized (a team could
  start tomorrow), with the severity rating honestly tied to consequence, and
  Residual risk must state what remains after the obvious fixes (the 4/5 anchors).
- **Communication** — a threat model is forwarded to non-security stakeholders
  (the due-diligence partner). Structure, severity legibility, and staying in
  the ~2–4 page band matter. A 9-page STRIDE essay buys no coverage points and
  loses Communication for bloat.

## 3. Task-specific scoring detail (what 4 vs 5 looks like, per load-bearing dim)

### Correctness
- **3**: sound on the obvious items; severity ratings defensible; no fabricated
  vulns. Minor imprecision (e.g. calling K2 "broken authentication" rather than
  "broken object-level authorization") that doesn't change the fix.
- **4**: precise throughout; claims qualified; correctly distinguishes
  authn-vs-authz (K1/K2), names the disk-vs-field encryption gap accurately
  (K8) rather than claiming "no encryption," no fabricated threats.
- **5**: above + correctly handles the genuinely contested calls — e.g. argues
  the balance race (K5) is exploitable *despite* the cached balance and explains
  why the cache doesn't save you; reasons about whether the at-least-once queue
  (K6) actually double-pays and under what failure window. These are points a
  competent reviewer could get wrong; getting them right is the 5.

### Insight depth
- **3**: at least one subtle keyed item (K5/K6/K10) found and correctly
  mechanized.
- **4**: two of the three subtle items found, AND a second-order interaction
  named (e.g. K4 logs feed K7 token theft feed K10 internal replay — the leak
  amplification chain; or K1+K7 = any user reaching admin adjust).
- **5**: all three subtle items, plus a reframe that would change the buyer's
  decision — e.g. observing that several findings collapse into one root cause
  ("identity is authenticated but never authorized, end to end"), or that the
  money-movement invariant should be enforced in the ledger (single source of
  truth) rather than patched per-endpoint.

### Coverage
- **3**: all four substrate-named areas (auth, money movement, PII, integrations)
  get real threats; STRIDE categories mostly represented.
- **4**: above + engages implicit concerns the brief didn't enumerate — e.g.
  the SMS-OTP toll-fraud angle of K9, repudiation/audit gap (§10), backup data
  exposure (§9 nightly backups of plaintext PII).
- **5**: above + a material consideration not hinted at that a senior reviewer
  endorses (e.g. webhook event ordering / replay beyond signature; key
  rotation for the 30-day JWT secret; blast radius of the shared processor API
  key).

### Actionability
- **3**: each threat has a concrete mitigation, severity stated.
- **4**: mitigations prioritized; the cost/effort of each is honest; the
  trade-off of *not* doing each is clear; quick wins (signature verification,
  rate limit) separated from structural fixes (ledger-enforced balance).
- **5**: above + explicit sequencing/decision points and a residual-risk section
  that says what you still carry after the top fixes and what would change the
  recommendation.

## 4. Failure-mode characterization (observable ways a solver underperforms)

1. **Generic STRIDE essay** — recites the six categories with textbook examples
   and never names a Lumen endpoint or flow. Tanks Insight + low recall.
2. **Phantom vulnerabilities** — asserts SQL injection (§9 says parameterized),
   missing TLS (§11 says HTTPS external), or "passwords stored in plaintext"
   (there are no passwords — it's OTP). Precision penalty + Correctness hit.
3. **Only the obvious four** — finds K1, K4, K8, K9, stops. Misses every subtle
   item; recall ~4/10; Insight ≤2.
4. **Authn/authz conflation** — describes K1/K2 as "authentication missing" when
   the system *is* authenticated; the bug is authorization. Correctness slip
   that often hides the real fix.
5. **Misses the balance race (K5)** — treats `POST /transfers` as fine because
   "it checks the balance," not noticing the check-then-act is non-atomic. The
   single most-missed item; requires concurrency reasoning.
6. **Misses payout idempotency (K6)** — sees the retry config as a positive
   ("good, it retries") without connecting at-least-once delivery + non-atomic
   status mark to double-payment.
7. **Misses internal-trust replay (K10)** — accepts "trusted because inside the
   VPC" at face value; doesn't flag network-position-only trust or replay.
8. **Encryption mischaracterized (K8)** — either misses it (sees "encrypted at
   rest" and moves on) or overclaims ("no encryption"). The nuance is
   disk-level ≠ field-level for an insider/query-access threat.
9. **No severity discipline** — everything is "Critical," or severities aren't
   tied to consequence; makes the model unactionable.
10. **Bloat** — 8+ pages, every STRIDE cell filled with filler, conclusions
    unfindable. Length-band violation scored in Communication.
11. **No residual-risk section** — stops at mitigations; never states what
    remains, which the brief explicitly asks for.

## 5. Headline finding (the contrast this task is designed to reveal)

P1 is the security probe of the masquerade question. The obvious four
(K1/K4/K8/K9) are within reach of any one-shot pass — A1 should land most of
them. The discriminators are the three **subtle, cross-section** items
(K5 balance race, K6 payout idempotency, K10 internal replay) and the
**precision** axis (not inventing phantom vulns).

The interesting question is whether a security-persona lens (A3/A4) actually
surfaces the second-order money-movement bugs that a solo pass skims past — i.e.
whether "the security architect at the table" earns its seat by catching the
double-spend race that reads as fine on a first pass. If A4 ≈ A3 > A1/A2 on
recall-of-subtle-items, the lift is persona *framing*; if A4 > A3, the
orchestration is adding something; if A3/A4 also inflate the **precision**
penalty (more personas confidently inventing more phantom vulns), that is the
counter-finding and just as publishable — deliberation that finds 2 more real
bugs but also asserts 6 more false ones is not obviously better for a security
deliverable a partner will read. Read recall-of-subtle and precision together,
per arm.

## calibration

Cold-pass recall: a first cold Opus solo pass found **10/10**, including all
three subtle items — too easy to discriminate. Hardening pass (this revision)
removed the near-verbatim cues for K5/K6/K10 from the substrate (see § scoring
above and the answer key "Where detectable" lines), added five explicit decoy
strengths in § 9/§ 11 to penalize shotgun precision, and raised the K5/K6/K10
minimum-credit bars (K10 now requires explicit replay-or-SSRF reasoning). Intent
is to land a fresh cold solo in the 3–8/10 band with the obvious four reliably
found and at least one subtle item reliably missed; a re-run cold pass should
confirm. If it still finds 10/10 or drops ≤2/10, recalibrate K5/K6/K10 subtlety
again. The obvious four (K1/K4/K8/K9) were deliberately left detectable.

## provenance

N/A — substrate (`reference/system-description.md`) is original synthetic
content authored for this task; no external repo vendored. (Provenance section
required only for P8/P10.)


## Calibration record (2026-06-09) — re-roled: recall=floor, precision=signal



Two cold-pass rounds (Opus 4.8 solo = arm A1 stand-in). Result fed the track-wide
**detection-saturation** re-role: recall is a floor check; the keyed decoys + precision are
the objective discriminator. See `analysis/party-findings/00-detection-saturation.md` and
`harness/party/scoring-rubric.md` § Objective floor + precision axis.
