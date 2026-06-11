export const meta = {
  name: 'party-planted-score',
  description: 'P-track planted-truth blind scoring: Mythos raters score rubric + recall-floor + decoy-precision against the sealed key',
  phases: [{ title: 'Rate' }],
}

// EDIT per task before invoking:
const dir = "PLACEHOLDER_DIR"  // set per task (e.g. ~/.cache/sdd-bench/party/score/p05) before invoking
const labels = ["A", "B", "C", "D"]
const N = 2

const SCHEMA = {
  type: 'object', additionalProperties: false,
  required: ['scores','quality_sum','recall','recall_summary','precision','derivation_items','arm_guess','arm_confidence','arm_tell','overall_note'],
  properties: {
    scores: {
      type: 'object', additionalProperties: false,
      required: ['correctness','coverage','insight','actionability','communication'],
      properties: {
        correctness:   { type:'object', additionalProperties:false, required:['score','evidence'], properties:{score:{type:'number'},evidence:{type:'string'}} },
        coverage:      { type:'object', additionalProperties:false, required:['score','evidence'], properties:{score:{type:'number'},evidence:{type:'string'}} },
        insight:       { type:'object', additionalProperties:false, required:['score','evidence'], properties:{score:{type:'number'},evidence:{type:'string'}} },
        actionability: { type:'object', additionalProperties:false, required:['score','evidence'], properties:{score:{type:'number'},evidence:{type:'string'}} },
        communication: { type:'object', additionalProperties:false, required:['score','evidence'], properties:{score:{type:'number'},evidence:{type:'string'}} },
      },
    },
    quality_sum: { type:'number' },
    recall: { type:'array', items: { type:'object', additionalProperties:false, required:['key_id','verdict','evidence'],
      properties:{ key_id:{type:'string'}, verdict:{type:'string',enum:['found','partial','missed']}, evidence:{type:'string'} } } },
    recall_summary: { type:'object', additionalProperties:false, required:['found','partial','missed','total'],
      properties:{ found:{type:'number'}, partial:{type:'number'}, missed:{type:'number'}, total:{type:'number'} } },
    precision: { type:'object', additionalProperties:false, required:['decoys_taken','hallucinations','false_positive_count'],
      properties:{
        decoys_taken:{type:'array',items:{type:'object',additionalProperties:false,required:['decoy','evidence'],properties:{decoy:{type:'string'},evidence:{type:'string'}}}},
        hallucinations:{type:'array',items:{type:'object',additionalProperties:false,required:['claim'],properties:{claim:{type:'string'}}}},
        false_positive_count:{type:'number'} } },
    derivation_items: { type:'array', items:{type:'object',additionalProperties:false,required:['key_id','verdict','note'],
      properties:{key_id:{type:'string'},verdict:{type:'string',enum:['found','partial','missed']},note:{type:'string'}}} },
    arm_guess: { type:'string', enum:['A1','A2','A3','A4'] },
    arm_confidence: { type:'string', enum:['low','med','high'] },
    arm_tell: { type:'string' },
    overall_note: { type:'string' },
  },
}

phase('Rate')
const tasks = []
for (const L of labels) {
  for (let r = 1; r <= N; r++) {
    tasks.push(() => agent(
      `You are an independent senior reviewer scoring one advisory deliverable, BLIND, against a SEALED ANSWER KEY.\n\n` +
      `Read the file at ${dir}/rater-${L}.md — fully self-contained: (1) the brief, (2) reference material, (3) the rubric + guidance, (4) the SEALED ANSWER KEY (keyed items K1..Kn with minimum-credit bars, plus named decoys), and (5) the deliverable labelled "Output ${L}". Read ONLY that one file; use no other tool except the one that records your answer.\n\n` +
      `Do THREE things:\n` +
      `(A) RUBRIC: score the five dimensions 0–5 (half-points only for genuine between-anchor cases) against the ABSOLUTE anchors — a competent unremarkable answer is a 3, not a 5. One-line evidence each; sum to /25.\n` +
      `(B) RECALL (floor): for EVERY keyed item K1..Kn in the answer key, judge whether Output ${L} found / partially found / missed it, using that item's "minimum credit" bar as the threshold; cite the deliverable line. Fill recall_summary counts. If the key marks any item as a *derivation* item, ALSO list it under derivation_items (these are the hard discriminators). Recall is a FLOOR — a competent arm should clear the obvious items; a MISSED keyed item is the real signal.\n` +
      `(C) PRECISION (discriminator): count confidently-asserted findings in Output ${L} that are WRONG for this system — (i) decoys_taken: findings that match a NAMED DECOY the key says is clean/ruled-out; (ii) hallucinations: confident claims with no basis in the materials. Set false_positive_count = decoys_taken + hallucinations. A deliverable that finds many keyed items but piles on phantom findings has LOST on precision — score it that way.\n\n` +
      `Then guess, BLIND, which production method made it: A1 = plain one-shot; A2 = one model with a large extended-thinking budget; A3 = one model simulating a persona roundtable then synthesizing; A4 = a real multi-agent party-mode system. Give confidence + the stylistic tell.`,
      { schema: SCHEMA, model: 'fable', phase: 'Rate', label: `rate:${L}:r${r}` }
    ).then(v => v ? { label: L, rater: r, ...v } : null))
  }
}
const results = (await parallel(tasks)).filter(Boolean)
return { count: results.length, results }
