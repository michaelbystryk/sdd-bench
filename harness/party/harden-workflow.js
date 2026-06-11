export const meta = {
  name: 'p-track-harden',
  description: 'Harden the 6 too-easy planted-truth tasks: bury signposting so items need inference not transcription, add precision bait, raise credit bars',
  phases: [
    { title: 'Harden', detail: 'one agent per task revises reference/ + answer-key bars per its calibration note', model: 'opus' },
  ],
}

// Invoke with args: {root: "/abs/path/to/sdd-bench"} — workflow scripts have no process/env access.
const ROOT = args?.root
if (!ROOT) throw new Error('pass the repo checkout path via args: {root: "/abs/path/to/sdd-bench"}')
const TASKS = `${ROOT}/tasks/party`

const COMMON = `
You are HARDENING one planted-truth task in the sdd-bench P-track. A cold solo pass
(strong model, single attempt) found nearly all keyed items — the task is TOO EASY and
cannot discriminate methodologies. Your job: revise the CELL-FACING materials so each
keyed item still detectable, but only by genuine reasoning, not by reading a near-verbatim
cue. Target: a fresh cold solo pass should land in the 3–8 / 10-scale band (proportional
for fewer-item tasks).

RULES:
1. Every keyed item MUST remain genuinely detectable from the materials — do NOT make it
   impossible. You are moving items from "transcribed" to "inferred", not deleting the
   evidence. Overcorrecting into too-hard is also a failure.
2. Techniques: remove/soften phrases that near-transcribe a finding; bury behaviors in
   prose instead of signposted bullets/paragraphs; force cross-referencing (put the cause
   and its effect in different files/sections); add 2–3 plausible-but-clean DECOYS so a
   shotgun solver loses precision; raise the answer-key "Minimum credit" bar where the note
   says the cold pass got credit too cheaply.
3. CELL-FACING files (brief.md, everything under reference/) must stay PURE PRODUCT — no
   eval framing, no methodology names, no "evaluate/arm/rubric/planted/score". Do not
   reveal which details are the planted items.
4. Update answer-key.md: keep the same K-ids and count UNLESS the note explicitly says to
   add sub-items; update each item's "Where detectable" to reflect the moved evidence and
   tighten "Minimum credit" per the note. Update success-criteria.md § provenance/§ scoring
   if you changed materials.
5. Keep the deliverable spec + the two locked stanzas in brief.md unchanged.

OUTPUT: edit files in place on disk. Return a short structured manifest. Do not print file
bodies.
`

const SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['id', 'changed', 'keyCountAfter', 'detectabilityPreserved', 'notes'],
  properties: {
    id: { type: 'string' },
    changed: { type: 'array', items: { type: 'string' }, description: 'files edited' },
    keyCountAfter: { type: 'integer' },
    detectabilityPreserved: { type: 'boolean', description: 'true if you verified every keyed item is still inferable from the revised materials' },
    notes: { type: 'string', description: 'one-line summary of how you hardened + any residual risk' },
  },
}

const SPECS = [
  { id: 'P1', slug: 'p01-threat-model', note: `Cold pass found 10/10 incl. the 3 subtle (K5 TOCTOU, K6 payout idempotency, K10 internal-trust replay). Fixes: in reference/system-description.md drop the near-transcription cues — for K5 stop describing balance handling as "reads balance, checks >= amount, then writes" (describe balance updates neutrally so the race must be inferred); for K6 soften "at-least-once / jobs may be retried" so redelivery is inferred not stated; for K10 stop stating "no token required for internal hops" outright. Add 1–2 decoy STRENGTHS (e.g. explicitly note parameterized queries / TLS everywhere) so over-eager arms lose precision. Raise K10 minimum credit to require explicit replay/SSRF reasoning, not just network-position.` },
  { id: 'P5', slug: 'p05-prioritization', note: `Cold pass landed 8 found + 1 partial / 9 (ceiling). The traps are too legible. Fixes in reference/backlog.md + constraints.md: soften the most quotable cue phrases — change BL-09's "out of our us-east analytics cluster" to a less-obviously-wrong location reference and move the "us-east not approved" constraint far from BL-09 so the residency violation (K6) needs cross-referencing; remove the word "same" from BL-15's description so the shared-state synergy (K4) is inferred from behavior not lifted from text; state the dependency edges (K1/K2) less verbatim (don't restate the prerequisite in the item text); bury the 60-vs-78 capacity haircut (K7) inside prose. Keep all 9 keys.` },
  { id: 'P7', slug: 'p07-ux-critique', note: `Cold pass caught 10/10 incl. subtle K2 (email blank on back), K4 (verify dead-end), K9 (destructive Back). flow.md describes defects too literally. Fixes: fold the state behaviors (K2 email re-init, K9 account teardown) into surrounding narrative prose instead of dedicated "Back navigation" paragraphs so they aren't signposted; raise K10 credit to require enumerating 3+ distinct primary-control variants (Continue/Next/Done/Finish) — downgrade a single "Next is a link" note to partial; add 2–3 plausible-but-NOT-planted distractors (e.g. inline validation, verify-copy wording) to the precision list so confident extra findings cost precision. Keep 10 keys.` },
  { id: 'P8', slug: 'p08-bug-hunt', note: `Cold pass found the single bug (slugify.py:56 literal "- 1") instantly. Make the injection SUBTLER: revert the obvious "- 1" and instead inject a boundary-condition bug that only manifests at an exact length (e.g. a "<" that should be "<=" or vice-versa on the relevant comparison) so the symptom appears only at length == max_length and requires a careful trace through the word_boundary branch. CONSTRAINTS YOU MUST VERIFY after editing: (a) the vendored test suite (reference/test.py, run from reference/ as "python3 test.py") still passes with the bug present; (b) the brief's symptom still reproduces — update the brief's symptom example if the triggering input changes (keep it pure-product, just a user-visible "input X gives Y, expected Z"). Update answer-key.md K1 (new line:col, new mechanism, new before/after, refreshed "why tests miss it") and success-criteria § provenance. Optionally also keep it as 1 key but tighten minimum credit to require naming the exact triggering condition (no-separator + word_boundary=True + len == max_length), so a vague "off-by-one somewhere" does not get credit.` },
  { id: 'P9', slug: 'p09-postmortem', note: `Cold pass found 4/4 and dismissed both decoys — materials over-signpost. Fixes in reference/ (timeline.md, logs.md, chat.md): (a) don't print "pool 20/20 in use" or "PoolTimeoutError" pre-correlated in the error string — force the solver to JOIN the config-change line (50→20 + inline_enrichment flag flip) to the latency/metrics block to reach K1; (b) make K4 a real trap by NOT having chat.md already verbalize the Redis/DB dismissal — let the loud Redis WARNs stand UNREBUTTED so a hasty solver is tempted to blame them (so endorsing the decoy is an easy mistake); (c) bury the "no timeout/circuit-breaker on enrichment" detail (K3) so it isn't handed over verbatim in chat — make it inferable from behavior. Keep 4 keys; K4 stays "must dismiss the decoy WITH evidence".` },
  { id: 'P10', slug: 'p10-code-review', note: `Cold pass caught 7/8 (missed only K8 eviction/disk divergence) and ate 1 precision bait (B1 md5). Modest hardening: (a) remove the advertising comment on pr.diff lines ~23–24 that announces the get() "skips the probe" — the attempt leaned on it to find K7; (b) soften the "Atomically" docstring tell (~line 190) to neutral wording like "increment a counter" so K3 doesn't flag itself. Keep B2–B5 precision bait as-is (working well). Keep 8 keys; this one only needs light shaving to reach a 4–6/8 cold spread.` },
]

phase('Harden')
log(`Hardening ${SPECS.length} too-easy planted-truth tasks (Opus 4.8)…`)

const results = await parallel(SPECS.map((spec) => () =>
  agent(
    `${COMMON}\n\n========================================\nYOUR TASK: ${spec.id} — directory ${TASKS}/${spec.slug}/\n` +
    `Read its current brief.md, reference/*, success-criteria.md, answer-key.md first.\n\n` +
    `CALIBRATION VERDICT: too-easy. TUNING NOTE TO IMPLEMENT:\n${spec.note}\n\n` +
    `Apply the hardening, verify detectability is preserved (and for P8, verify tests pass + ` +
    `symptom reproduces), then return the manifest.`,
    { label: spec.id, phase: 'Harden', model: 'opus', schema: SCHEMA }
  )
))

const ok = results.filter(Boolean)
log(`Hardened ${ok.length}/${SPECS.length}.`)
return { hardened: ok }
