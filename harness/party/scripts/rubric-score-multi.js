export const meta = {
  name: 'party-rubric-score-multi',
  description: 'P-track rubric-only blind scoring across multiple tasks (Mythos raters; 5 dims + arm guess)',
  phases: [{ title: 'Rate' }],
}
// Invoke with args: {scoreRoot: "/abs/path/to/blind-score-bundles"} (e.g. ~/.cache/sdd-bench/party/score).
const SCORE = args?.scoreRoot
if (!SCORE) throw new Error('pass the blind-bundle dir via args: {scoreRoot: "/abs/path/to/score-bundles"}')
const TASKS = [
  { key: 'p02', dir: `${SCORE}/p02` },
  { key: 'p03', dir: `${SCORE}/p03` },
  { key: 'p11', dir: `${SCORE}/p11` },
]
const labels = ['A','B','C','D']; const N = 2
const SCHEMA = {
  type:'object', additionalProperties:false,
  required:['scores','quality_sum','arm_guess','arm_confidence','arm_tell','overall_note'],
  properties:{
    scores:{ type:'object', additionalProperties:false,
      required:['correctness','coverage','insight','actionability','communication'],
      properties:{
        correctness:{type:'object',additionalProperties:false,required:['score','evidence'],properties:{score:{type:'number'},evidence:{type:'string'}}},
        coverage:{type:'object',additionalProperties:false,required:['score','evidence'],properties:{score:{type:'number'},evidence:{type:'string'}}},
        insight:{type:'object',additionalProperties:false,required:['score','evidence'],properties:{score:{type:'number'},evidence:{type:'string'}}},
        actionability:{type:'object',additionalProperties:false,required:['score','evidence'],properties:{score:{type:'number'},evidence:{type:'string'}}},
        communication:{type:'object',additionalProperties:false,required:['score','evidence'],properties:{score:{type:'number'},evidence:{type:'string'}}},
      }},
    quality_sum:{type:'number'},
    arm_guess:{type:'string',enum:['A1','A2','A3','A4']},
    arm_confidence:{type:'string',enum:['low','med','high']},
    arm_tell:{type:'string'},
    overall_note:{type:'string'},
  },
}
phase('Rate')
const jobs = []
for (const t of TASKS) for (const L of labels) for (let r=1;r<=N;r++) {
  jobs.push(() => agent(
    `You are an independent senior reviewer scoring one advisory deliverable, BLIND. Read the file at ${t.dir}/rater-${L}.md — self-contained (brief, reference, rubric, and the deliverable labelled "Output ${L}"). Read ONLY that file; use no other tool except the one that records your answer.\n\n`+
    `Score the five rubric dimensions 0–5 (half-points only for genuine between-anchor cases) against the ABSOLUTE anchors — a competent unremarkable answer is a 3, not a 5. One-line evidence each; sum to /25. Then guess, BLIND, which made it: A1 plain one-shot / A2 one model with a large extended-thinking budget / A3 one model simulating a persona roundtable then synthesizing / A4 a real multi-agent party-mode system; give confidence + the stylistic tell.`,
    { schema: SCHEMA, model:'fable', phase:'Rate', label:`${t.key}:${L}:r${r}` }
  ).then(v => v ? { task:t.key, label:L, rater:r, ...v } : null))
}
const results = (await parallel(jobs)).filter(Boolean)
return { count: results.length, results }
