export const meta = {
  name: 'party-planted-score-multi',
  description: 'P-track planted-truth blind scoring across P7/P9/P10 (Mythos raters; rubric + recall + decoy-precision)',
  phases: [{ title: 'Rate' }],
}
const TASKS = [
  { key:'p07', dir:'/Users/miby/.cache/sdd-bench/party/score/p07' },
  { key:'p09', dir:'/Users/miby/.cache/sdd-bench/party/score/p09' },
  { key:'p10', dir:'/Users/miby/.cache/sdd-bench/party/score/p10' },
]
const labels = ['A','B','C','D']; const N = 2
const SCHEMA = {
  type:'object', additionalProperties:false,
  required:['scores','quality_sum','recall','recall_summary','precision','derivation_items','arm_guess','arm_confidence','arm_tell','overall_note'],
  properties:{
    scores:{type:'object',additionalProperties:false,required:['correctness','coverage','insight','actionability','communication'],
      properties:{
        correctness:{type:'object',additionalProperties:false,required:['score','evidence'],properties:{score:{type:'number'},evidence:{type:'string'}}},
        coverage:{type:'object',additionalProperties:false,required:['score','evidence'],properties:{score:{type:'number'},evidence:{type:'string'}}},
        insight:{type:'object',additionalProperties:false,required:['score','evidence'],properties:{score:{type:'number'},evidence:{type:'string'}}},
        actionability:{type:'object',additionalProperties:false,required:['score','evidence'],properties:{score:{type:'number'},evidence:{type:'string'}}},
        communication:{type:'object',additionalProperties:false,required:['score','evidence'],properties:{score:{type:'number'},evidence:{type:'string'}}},
      }},
    quality_sum:{type:'number'},
    recall:{type:'array',items:{type:'object',additionalProperties:false,required:['key_id','verdict','evidence'],
      properties:{key_id:{type:'string'},verdict:{type:'string',enum:['found','partial','missed']},evidence:{type:'string'}}}},
    recall_summary:{type:'object',additionalProperties:false,required:['found','partial','missed','total'],
      properties:{found:{type:'number'},partial:{type:'number'},missed:{type:'number'},total:{type:'number'}}},
    precision:{type:'object',additionalProperties:false,required:['decoys_taken','hallucinations','false_positive_count'],
      properties:{
        decoys_taken:{type:'array',items:{type:'object',additionalProperties:false,required:['decoy','evidence'],properties:{decoy:{type:'string'},evidence:{type:'string'}}}},
        hallucinations:{type:'array',items:{type:'object',additionalProperties:false,required:['claim'],properties:{claim:{type:'string'}}}},
        false_positive_count:{type:'number'}}},
    derivation_items:{type:'array',items:{type:'object',additionalProperties:false,required:['key_id','verdict','note'],
      properties:{key_id:{type:'string'},verdict:{type:'string',enum:['found','partial','missed']},note:{type:'string'}}}},
    arm_guess:{type:'string',enum:['A1','A2','A3','A4']},
    arm_confidence:{type:'string',enum:['low','med','high']},
    arm_tell:{type:'string'},
    overall_note:{type:'string'},
  },
}
phase('Rate')
const jobs = []
for (const t of TASKS) for (const L of labels) for (let r=1;r<=N;r++){
  jobs.push(()=>agent(
    `You are an independent senior reviewer scoring one advisory deliverable, BLIND, against a SEALED ANSWER KEY.\n\nRead the file at ${t.dir}/rater-${L}.md — fully self-contained: (1) brief, (2) reference, (3) rubric+guidance, (4) the SEALED ANSWER KEY (keyed items K1..Kn with minimum-credit bars + named decoys), (5) the deliverable "Output ${L}". Read ONLY that one file; no other tool except the one recording your answer.\n\n(A) RUBRIC: score 5 dims 0-5 (halves only for genuine between-anchor), absolute anchors (competent=3 not 5), one-line evidence each, sum /25.\n(B) RECALL (floor): for EVERY keyed item, found/partial/missed per its minimum-credit bar, cite the deliverable line; fill recall_summary; list any derivation items separately. A MISSED keyed item is the signal.\n(C) PRECISION (discriminator): count confident findings that match a NAMED DECOY (decoys_taken) or have no basis (hallucinations); false_positive_count = their sum.\n\nThen guess BLIND which made it: A1 plain one-shot / A2 large extended-thinking / A3 simulated persona roundtable / A4 real multi-agent party-mode; + confidence + tell.`,
    {schema:SCHEMA, model:'fable', phase:'Rate', label:`${t.key}:${L}:r${r}`}
  ).then(v=>v?{task:t.key,label:L,rater:r,...v}:null))
}
const results=(await parallel(jobs)).filter(Boolean)
return {count:results.length, results}
