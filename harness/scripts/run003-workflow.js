export const meta = {
  name: 't4rich-run003-automated-arm',
  description: 'Drive the 5 structured-methodology cells for T4-rich run-003 (automated arm) headlessly, sequentially, with pm-ask answering clarifying questions',
  phases: [
    { title: 'Cells', detail: 'one operator-agent per methodology, run sequentially (shared Pro quota)' },
  ],
}

// ---------------------------------------------------------------------------
// run-003 = AUTOMATED ARM. Each agent plays the operator: it drives a blind
// headless `claude -p` cell via cell-headless.sh and answers the methodology's
// clarifying questions from the locked PM persona via pm-ask. vibe is run
// separately (no orchestration needed). Cells run SEQUENTIALLY because they
// share one Pro weekly quota — parallel would just rate-limit. If a cell hits a
// usage/rate limit, the loop stops and records partial progress (resumable).
// ---------------------------------------------------------------------------

const TASK = 't4-fitness-app-rich'
const RUN = '003'
const CH = '~/dev/sdd-bench/harness/scripts/cell-headless.sh'
const PMASK = '~/dev/sdd-bench/harness/scripts/pm-ask'

const SCHEMA = {
  type: 'object',
  required: ['meth', 'status', 'end_trigger', 'num_drive_turns', 'pm_questions_forwarded', 'notes'],
  properties: {
    meth: { type: 'string' },
    status: { type: 'string', enum: ['completed', 'partial', 'failed', 'rate_limited', 'install_failed'] },
    end_trigger: { type: 'string', description: 'what ended the cell (declared done / 3x fail / rate limit / stall / install failed)' },
    phases_run: { type: 'array', items: { type: 'string' } },
    final_session_id: { type: 'string' },
    num_drive_turns: { type: 'integer' },
    pm_questions_forwarded: { type: 'integer' },
    total_cost_usd: { type: 'number' },
    total_api_minutes: { type: 'number' },
    files_count: { type: 'integer', description: 'source files produced in the cell dir (excl node_modules/.git)' },
    tests_status: { type: 'string', description: 'tsc/npm test outcome if the cell ran them, else "not run"' },
    notes: { type: 'string', description: 'what happened, surprises, anything the operator should know' },
  },
}

// Shared operator instructions, specialized per methodology by `procedure`.
function prompt(meth, procedure, runbookNotes) {
  return `You are the OPERATOR for one methodology cell in an automated software-methodology comparison. Your job: drive a single blind, headless agent ("the cell") through the **${meth}** methodology to build a mobile fitness app from a product brief, exactly as a human operator would — then report structured results. You are NOT building the app yourself; the cell does that. You only issue methodology commands and relay product answers.

CELL IDENTITY: ${TASK} / ${meth} / run-${RUN}

TOOLS (run via Bash; both are pre-authorized):
- Cell driver:  ${CH} <subcommand> ...
- PM persona:   ${PMASK} --cell ${TASK}/${meth}/${RUN} "<question>"

The cell driver prints, per turn:
  SESSION: <id>   IS_ERROR: <bool>   NUM_TURNS: <n>   API_MS / COST_USD / STOP
  ---RESULT---
  <the cell's text output for that turn>
  TURN_JSON: <path>
Capture the SESSION id from the FIRST turn and reuse it for every resume so the cell keeps one continuous session.

=== BLINDNESS (load-bearing) ===
The cell must never learn it is being evaluated. ONLY ever send it: methodology slash-commands/phase prompts, and verbatim PM answers. NEVER type the words eval, benchmark, score, rubric, methodology-comparison, or similar into any drive/resume prompt. Do not ask the cell meta questions.

=== HANDLING THE CELL'S CLARIFYING QUESTIONS ===
When a turn's RESULT asks product/scope questions (what should the app do, priorities, UX, which programs, success criteria, etc.), DO NOT answer them yourself. For each question, run:
  ${PMASK} --cell ${TASK}/${meth}/${RUN} "<the question, lightly cleaned>"
Collect the persona's answers, then resume the cell feeding the answers back as a normal message. Tooling/process questions ("should I use TypeScript?", "run the next phase?") are NOT for the PM — answer them yourself with sensible defaults that keep the methodology on its canonical path (prefer the cell's own defaults). Count how many questions you forwarded to the PM.

=== SETUP ===
First run:  ${CH} setup ${TASK} ${meth} ${RUN}
Note the printed CELL_DIR and PHASE1_FILE.

=== PROCEDURE (specific to ${meth}) ===
${procedure}

=== STOP CONDITIONS ===
- The methodology declares the work complete  → status "completed".
- A phase errors 3x consecutively              → status "failed".
- A turn shows IS_ERROR: True with a usage/rate-limit message in TURN_JSON's .err, OR the result mentions hitting a usage limit → status "rate_limited", STOP immediately (do not retry — the shared quota is exhausted).
- No forward progress after a couple of resumes → status "partial".

=== WIND-DOWN ===
When done (any stop condition), run:
  ${CH} cost ${TASK} ${meth} ${RUN}        (aggregates cost/tokens/time across turns)
  ls/​find the CELL_DIR to count source files (exclude node_modules, .git, .expo)
Then RETURN the structured result. Put anything notable in notes (e.g. did clarify actually ask questions headlessly? did the methodology cut scope? did install work?).

RUNBOOK NOTES for ${meth}: ${runbookNotes}

Be efficient with turns — each costs real quota. Drive the canonical phases; don't add extra exploratory turns.`
}

const PROC = {
  'spec-kit': `Spec Kit canonical pipeline. Drive each phase by RESUMING the same session.
1. ${CH} drive ${TASK} spec-kit ${RUN} @<PHASE1_FILE>     (this fires /speckit-specify with the brief)
2. ${CH} resume ${TASK} spec-kit ${RUN} <SID> "/speckit-clarify"   — if it asks questions, forward each to pm-ask, then resume with: "<answers>"
3. ${CH} resume ${TASK} spec-kit ${RUN} <SID> "/speckit-plan"
4. ${CH} resume ${TASK} spec-kit ${RUN} <SID> "/speckit-tasks"
5. ${CH} resume ${TASK} spec-kit ${RUN} <SID> "/speckit-implement"   — this is the long build phase; may take many internal turns. Done when it reports all tasks implemented.`,

  'openspec': `OpenSpec three-phase state machine: propose → apply → archive. RESUME the same session.
1. ${CH} drive ${TASK} openspec ${RUN} @<PHASE1_FILE>     (fires /opsx:propose with the brief) — propose often asks clarifying questions; forward them to pm-ask and resume with the answers until the proposal is complete.
2. ${CH} resume ${TASK} openspec ${RUN} <SID> "/opsx:apply"     — the implementation/build phase.
3. ${CH} resume ${TASK} openspec ${RUN} <SID> "/opsx:archive"   — completes the change. Done when archive succeeds.`,

  'ai-dlc': `AI-DLC is heavily approval-gated: it stops with "DO NOT PROCEED until user confirms" at most stages. RESUME the same session.
1. ${CH} drive ${TASK} ai-dlc ${RUN} @<PHASE1_FILE>      (fires "Using AI-DLC, <brief>")
2. Loop: read each turn's RESULT.
   - If it's an approval gate (asks you to confirm/approve to proceed), resume with: "Approved — proceed."
   - If it's a genuine product/scope question, forward to pm-ask and resume with the answer.
   - Keep clearing gates through Inception → Construction until it reaches Build-and-Test and declares the build complete (Operations is a v0.1.8 placeholder — stop at Build-and-Test).
Decline opt-in extensions (security baseline, property-based testing) for parity: if offered, resume with "No thanks, skip that — proceed with the baseline."`,

  'vibe-planmode': `Vibe Plan Mode = plan first (read-only), then implement after approval.
1. ${CH} drive-plan ${TASK} vibe-planmode ${RUN} @<PHASE1_FILE>   (runs the brief in PLAN MODE — the cell researches and produces a plan, no edits)
   - If the plan turn asks product questions, forward to pm-ask and resume (still informational) — but plan-mode resumes also need drive semantics; if you must continue planning, use: ${CH} resume ${TASK} vibe-planmode ${RUN} <SID> "<answers>" (note: resume defaults to build mode; for planning continuation that is acceptable here since we only need the plan text).
2. Approve + implement: ${CH} resume ${TASK} vibe-planmode ${RUN} <SID> "The plan looks good — go ahead and implement it."   (this runs in build mode with edits enabled). Done when the cell declares the implementation complete.`,

  'bmad': `BMAD. FIRST verify the install worked: after setup, check the CELL_DIR for a _bmad/ dir or .claude/skills/bmad-* . If BMAD did NOT install (the installer is interactive and may have failed headlessly), STOP and return status "install_failed" with a note — do not fake it.
If installed: kick off NEUTRALLY so the path is BMAD's choice, not yours.
1. ${CH} drive ${TASK} bmad ${RUN} "/bmad-help"     (or /bmad-agent-analyst) — see what BMAD recommends.
2. Follow BMAD's recommended next step (it may route to full lifecycle OR /bmad-quick-dev — record which; its right-sizing IS the finding). RESUME the same session through the phases it chooses.
3. Forward BOTH product- and UX-shaped questions to pm-ask. Answer "working mode/coaching" questions yourself with the "Fast path" default.
Done when BMAD declares the work complete. If it cannot proceed headlessly, return "partial" with details.`,
}

const NOTES = {
  'spec-kit': 'Spec Kit 0.8.13 installs skills as /speckit-*. clarify forwards to PM. Do not skip phases.',
  'openspec': 'It is /opsx:propose (NOT /opsx:proposal). Ranked #1 in an external eval — drive it faithfully.',
  'ai-dlc': 'Most gated methodology; clear gates as baseline operator-touch, route real product Qs to PM. model claude-opus-4-8.',
  'vibe-planmode': 'Two-phase: plan then implement. Track if planning converged in one pass.',
  'bmad': 'Accept BMAD adaptive routing. Kick off neutrally. Token-heavy on full path. Interactive installer is the main risk.',
}

// Order: cheapest-likely-to-succeed and highest-value first; bmad last (riskiest install).
const ORDER = ['openspec', 'spec-kit', 'ai-dlc', 'vibe-planmode', 'bmad']

phase('Cells')
const results = []
for (const meth of ORDER) {
  log(`Starting ${meth} cell (run-${RUN}) — sequential, shared Pro quota`)
  const r = await agent(prompt(meth, PROC[meth], NOTES[meth]), {
    label: `cell:${meth}`,
    phase: 'Cells',
    schema: SCHEMA,
  })
  results.push(r)
  if (!r) { log(`${meth}: agent returned null (skipped)`); continue }
  log(`${meth}: ${r.status} — ${r.end_trigger} (${r.num_drive_turns} turns, $${r.total_cost_usd ?? '?'}, ${r.pm_questions_forwarded} PM Qs)`)
  if (r.status === 'rate_limited') {
    log(`Pro quota exhausted on ${meth}. Stopping remaining cells — resume when quota refreshes.`)
    break
  }
}
return results
