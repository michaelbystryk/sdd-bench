export const meta = {
  name: 'p-track-calibrate',
  description: 'Cold-pass calibration of the 6 planted-truth P-track tasks: solo attempt (Opus 4.8) then recall-score vs sealed key',
  phases: [
    { title: 'ColdPass', detail: 'a plain solo attempt of each task from brief+reference only', model: 'opus' },
    { title: 'Score', detail: 'grade the attempt against the sealed answer key', model: 'opus' },
  ],
}

// Invoke with args: {root: "/abs/path/to/sdd-bench"} — workflow scripts have no process/env access.
const ROOT = args?.root
if (!ROOT) throw new Error('pass the repo checkout path via args: {root: "/abs/path/to/sdd-bench"}')
const TASKS = `${ROOT}/tasks/party`
const COLD = '/tmp/ptrack-cold'

// id, slug, deliverable filename, keyed-item count, whether the spread rule applies
const ITEMS = [
  { id: 'P1', slug: 'p01-threat-model', deliverable: 'threat-model.md', total: 10, spread: true },
  { id: 'P5', slug: 'p05-prioritization', deliverable: 'roadmap.md', total: 9, spread: true },
  { id: 'P7', slug: 'p07-ux-critique', deliverable: 'ux-critique.md', total: 10, spread: true },
  { id: 'P8', slug: 'p08-bug-hunt', deliverable: 'root-cause.md', total: 1, spread: false },
  { id: 'P9', slug: 'p09-postmortem', deliverable: 'postmortem.md', total: 4, spread: false },
  { id: 'P10', slug: 'p10-code-review', deliverable: 'review.md', total: 8, spread: true },
]

const SCORE_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['id', 'found', 'partial', 'missed', 'total', 'foundKeys', 'falsePositives', 'verdict', 'tuningNote'],
  properties: {
    id: { type: 'string' },
    found: { type: 'integer' },
    partial: { type: 'integer' },
    missed: { type: 'integer' },
    total: { type: 'integer' },
    foundKeys: { type: 'array', items: { type: 'string' }, description: 'K-ids credited as found' },
    falsePositives: { type: 'integer', description: 'confident claims that are wrong for the given materials (precision)' },
    verdict: { type: 'string', enum: ['in-band', 'too-easy', 'too-hard'], description: 'in-band = ~3-8/10 spread (or, for binary P8/few-item tasks, neither trivially-always nor never found)' },
    tuningNote: { type: 'string', description: 'if not in-band: what to change in materials/key to fix difficulty; else short confirmation' },
  },
}

phase('ColdPass')
log(`Calibrating ${ITEMS.length} planted-truth tasks (cold solo pass on Opus 4.8)…`)

const results = await pipeline(
  ITEMS,
  // Stage 1 — cold solo attempt. Sealed dir: brief + reference only, NO key.
  (item) => agent(
    `You are a competent professional asked to do a single piece of work. Read ONLY these files:\n` +
    `  ${COLD}/${item.slug}/brief.md\n  ${COLD}/${item.slug}/reference/  (all files)\n` +
    `Do the task ONCE, at a normal professional effort level — no exhaustive multi-pass review, ` +
    `just a solid single attempt like a smart practitioner would deliver on a first pass. ` +
    `Follow the brief's Deliverable spec exactly. Write your deliverable to ` +
    `${COLD}/${item.slug}/attempt.md and nothing else. Do not look for any answer key or scoring ` +
    `file — none exists here. Return only the literal string "done".`,
    { label: `cold:${item.id}`, phase: 'ColdPass', model: 'opus' }
  ),
  // Stage 2 — score the attempt against the real sealed key.
  (_done, item) => agent(
    `You are grading a cold solo attempt against a sealed answer key, to calibrate task difficulty.\n` +
    `Answer key (ground truth): ${TASKS}/${item.slug}/answer-key.md\n` +
    `The attempt to grade:        ${COLD}/${item.slug}/attempt.md\n\n` +
    `For each keyed item K1..K${item.total}, decide found / partial / missed using the key's ` +
    `"Minimum credit" line as the bar. Be strict: a vague gesture near the area is "partial", not ` +
    `"found". Also count falsePositives = confident claims in the attempt that are WRONG for the ` +
    `given materials (hallucinated findings). Then set verdict:\n` +
    `  - "in-band" if found is in the discriminating middle (roughly 3-8 of 10-scale tasks; for the ` +
    `1-item bug-hunt P8, in-band means the cold pass result is informative — note whether it found ` +
    `the single bug; for 4-item P9, in-band ~1-3 of 4).\n` +
    `  - "too-easy" if the cold pass found essentially everything (no headroom for the arms to differ).\n` +
    `  - "too-hard" if it found ~none (items not actually detectable from the materials).\n` +
    `Give a concrete tuningNote when not in-band (what to add/remove/soften in reference/ or the key). ` +
    `Total items = ${item.total}. Return the structured result.`,
    { label: `score:${item.id}`, phase: 'Score', model: 'opus', schema: SCORE_SCHEMA }
  )
)

const scored = results.filter(Boolean)
log(`Calibration complete: ${scored.length}/${ITEMS.length} scored.`)
for (const s of scored) {
  log(`${s.id}: ${s.found}/${s.total} found (+${s.partial} partial, ${s.falsePositives} FP) → ${s.verdict}`)
}
return {
  scored,
  needsTuning: scored.filter((s) => s.verdict !== 'in-band').map((s) => ({ id: s.id, verdict: s.verdict, note: s.tuningNote })),
}
