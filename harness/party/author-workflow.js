export const meta = {
  name: 'p-track-author',
  description: 'Author all 11 P-track advisory tasks (brief + reference + success-criteria + sealed answer-keys) in parallel',
  phases: [
    { title: 'Author', detail: 'one agent per task (P1–P11) writes its full file package to disk', model: 'opus' },
  ],
}

const ROOT = '/Users/miby/dev/sdd-bench'
const TASKS_DIR = `${ROOT}/tasks/party`

// Shared house-style + rubric context every author agent must obey.
const PREAMBLE = `
You are authoring ONE task package for the "P-track" of the sdd-bench evaluation harness
at ${ROOT}. The P-track compares BMAD party mode vs. plain Claude on ADVISORY tasks
(the deliverable is a document, not code). You are NOT running the task — you are writing
the task definition that others will later attempt.

READ FIRST (for house style and the rubric you must align to):
- ${ROOT}/tasks/party/README.md  (the registry + the file-class rules + authoring rules)
- ${ROOT}/harness/party/scoring-rubric.md  (the 5-dim advisory rubric + objective-recall axis + scrub list)
- ${ROOT}/PARTY-TRACK-BRIEF.md  (track design; skim § Design and § Scoring)
- One existing main-track task for tone: ${ROOT}/tasks/t3-csv-openapi/  (brief.md + success-criteria.md)

HARD HOUSE RULES (violating these breaks the eval):
1. brief.md and everything under reference/ are CELL-FACING. They must read as a PURE
   PRODUCT request from a real stakeholder. NO eval framing whatsoever: no methodology
   names (BMAD/party mode/OpenSpec…), no words like "evaluate"/"arm"/"rubric"/"benchmark"/
   "score"/"planted", no mention this is a test. A reader must not be able to tell it's
   part of an evaluation.
2. The scored discriminators must NOT be enumerated in brief.md. The whole point is the
   solver discovers them. (e.g. don't list the vulnerabilities in a threat-model brief.)
3. success-criteria.md and answer-key.md are HARNESS-ONLY (never seeded to a solver). The
   answer-key is additionally SEALED. They MAY use eval language freely.
4. brief.md MUST END with these two stanzas verbatim (after the product content):

   ## Deliverable
   Produce <FILENAME> as a standalone Markdown document with these sections: <SECTIONS>.
   Target length: <LENGTH BAND>.

   ## A note on ambiguity
   If anything is ambiguous, make a reasonable assumption and tag it [ASSUMPTION].

THE 5 QUALITY DIMENSIONS (success-criteria.md must reference these by name):
Correctness, Coverage, Insight depth, Actionability, Communication. Each 0–5. See the
rubric file for anchors. success-criteria.md structure (mirror the main track):
  § 1. Objective recall expectations (planted tasks) OR coverage checklist (rubric tasks)
  § 2. Which of the 5 dims are load-bearing for THIS task and why
  § 3. Task-specific scoring detail (what a 4 vs 5 looks like here, per load-bearing dim)
  § 4. Failure-mode characterization (8+ concrete, observable ways a solver underperforms)
  § 5. Headline finding (what contrast this task is designed to reveal between the arms)
  § calibration  (leave a stub: "Cold-pass recall: TBD — filled during calibration")
  § provenance  (P8/P10 only: repo URL, license, commit SHA, what you vendored/changed)

PLANTED-TRUTH TASKS (write answer-key.md FIRST, then build reference/ so each item is
genuinely detectable from the materials AND ONLY from them — not guessable without them,
not impossible to find). answer-key.md format — one block per item:
  ### K<n> — <short title>  [severity/subtlety: obvious|moderate|subtle]
  - What it is: <one sentence>
  - Where detectable: <file:line / which material / which part of the description>
  - Minimum credit: <the least a solver must say to count as "found">
Aim for the item count named in your task spec, with a difficulty spread (some obvious,
2–3 subtle). Subtle items should be logic/authz/second-order, not just config typos.

OUTPUT: Write all files directly to disk under your task directory. Do NOT print file
bodies back to me. Your returned text is consumed by a script — return ONLY the required
structured fields.
`

const SPECS = [
  {
    id: 'P1', dir: 'p01-threat-model', planted: 10,
    detail: `Task P1 — Security threat model. PROFILE: security.
SUBSTRATE: Write reference/system-description.md — a realistic architecture description of
a small fintech system (e.g. a money-movement / wallet API with auth, a ledger, webhooks,
an admin panel, a third-party KYC integration, background payout jobs). Describe it
NEUTRALLY as documentation a security reviewer would receive — components, data flows,
trust boundaries, auth model, storage, external integrations. Embed ~10 discoverable
weaknesses across STRIDE (spoofing/tampering/repudiation/info-disclosure/DoS/elevation):
mostly design-level (missing authz check on an admin endpoint, IDOR on an account
resource, webhook without signature verification, secret in a logged field, race in
balance update / double-spend, missing idempotency on payouts, over-broad token scope,
PII in plaintext, no rate limit on OTP, replayable request). 2–3 must be SUBTLE
(logic/authz/second-order), not config. Do NOT label any of them as weaknesses in the
description — they must be inferable only by reasoning about the design.
DELIVERABLE: threat-model.md — sections: Assets & trust boundaries; Threats (enumerated,
each with STRIDE category + severity); Mitigations; Residual risk. Length: ~2–4 pages.`,
  },
  {
    id: 'P2', dir: 'p02-architecture-adr', planted: 0,
    detail: `Task P2 — Architecture decision. PROFILE: architecture (rubric-scored, no key).
SUBSTRATE: Write reference/context.md describing a REAL TENSION with no single right
answer: a concrete decision a team faces (e.g. "should our 6-person team split the
monolith into services now, given a latency SLA, a looming compliance/data-residency
requirement, and a hiring freeze?" — or a build-vs-buy, or sync-vs-event-driven choice).
Give enough constraints (team size/skills, traffic, SLAs, deadlines, existing stack,
compliance, budget) that 2–3 options are each defensible and the trade-offs genuinely
conflict. The quality signal is how well a solver surfaces and weighs the trade-offs, not
which option they pick.
DELIVERABLE: adr-001.md — sections: Context; Options considered (≥3, each with pros/cons);
Decision; Consequences (incl. what we're accepting/deferring); Revisit triggers. ~2–3 pp.`,
  },
  {
    id: 'P3', dir: 'p03-product-strategy', planted: 0,
    detail: `Task P3 — Product strategy. PROFILE: product/strategy (rubric-scored).
SUBSTRATE: Write a MESSY SIGNAL PACK under reference/ (multiple small files: e.g.
support-tickets.md, churn-notes.md, usage-stats.md, competitor-moves.md, sales-asks.md).
Include genuine signal AND deliberate red herrings (a loud-but-tiny segment, a vanity
metric, a competitor feature that doesn't fit the strategy). The product: pick a plausible
B2B SaaS at an inflection point. A good strategy memo should separate signal from noise,
name explicit bets AND an explicit kill-list, and sequence.
DELIVERABLE: strategy.md — sections: Situation (what the signals actually say);
Positioning/where to play; Bets (3–5, with rationale); Kill-list (what to stop/decline);
Sequencing. ~2–3 pp.`,
  },
  {
    id: 'P4', dir: 'p04-product-discovery', planted: 0,
    detail: `Task P4 — Product discovery. PROFILE: product/discovery (rubric-scored).
SUBSTRATE: Write reference/problem.md — a VAGUE but real problem statement from a
stakeholder (e.g. "users churn after onboarding but we don't know why" or "enterprise
deals stall in security review"). Provide a little ambiguous context, no clean answer. The
quality signal is framing the problem, generating ranked hypotheses, naming the RISKIEST
ASSUMPTIONS, and proposing the cheapest test for each.
DELIVERABLE: discovery.md — sections: Problem framing; Hypotheses (ranked); Riskiest
assumptions; Discovery plan (cheapest test per assumption, with what would (in)validate
it). ~2 pp.`,
  },
  {
    id: 'P5', dir: 'p05-prioritization', planted: 9,
    detail: `Task P5 — Prioritization. PROFILE: product/prioritization (semi-objective key).
SUBSTRATE: Write reference/backlog.md — a ~25-item backlog (id, title, 1-line desc, rough
value + effort) PLUS reference/constraints.md (team capacity for the quarter, a hard
external deadline, a platform/infra fact). Plant TRAPS that a naive value/effort sort
misses, and key them:
- a HIDDEN DEPENDENCY CHAIN (item B silently requires item A first; sequencing them out of
  order is the error);
- a CONSTRAINT THAT INVALIDATES a high-scoring item (e.g. it needs a service that's being
  deprecated per constraints.md, or it violates the data-residency rule);
- a PAIR CHEAPER TOGETHER (two items share 80% of the work; doing them adjacently saves a
  lot — splitting them across quarters is the error);
- at least one item that LOOKS high-value but is gated by the external deadline.
Aim ~9 keyed insights total (dependency edges + the invalidation + the synergy + the
deadline-gating + a couple of "obvious cut" items). The deliverable is a roadmap; the key
is the set of trap-insights a good roadmap must reflect.
DELIVERABLE: roadmap.md — sections: Method (how you prioritized); Sequenced plan (table:
item, when, why); Cut-line (what's out and why); Dependencies & risks called out. ~2 pp +
table.`,
  },
  {
    id: 'P6', dir: 'p06-quick-decision', planted: 0,
    detail: `Task P6 — Quick decision (the OVER-CEREMONY CONTROL). PROFILE: rubric-scored,
COST-WEIGHTED. SUBSTRATE: Write reference/situation.md — a small, genuinely low-stakes,
reversible decision that a competent person should answer in a few minutes (e.g. "pick the
default page size for our new list endpoint" or "should this internal cron run hourly or
every 15 min" or "which of two libraries for parsing dates"). Enough context to decide,
not enough to justify a committee. The point: a fast right-sized answer should WIN; an
elaborate multi-page treatment should lose on the cost-weighted composite.
success-criteria.md MUST include a § overlay defining the cost-weighted composite (quality
is capped quickly; cost/length penalties are steep — a $30 roundtable on a $50 question
loses by design; over-length is penalized in Communication AND flagged as ceremony tax).
DELIVERABLE: decision.md — sections: Recommendation; Top 3 reasons; Key risk; Reversal
condition. HARD LIMIT: ≤1 page.`,
  },
  {
    id: 'P7', dir: 'p07-ux-critique', planted: 10,
    detail: `Task P7 — UX critique. PROFILE: design/UX (planted key).
SUBSTRATE: Write reference/flow.md — a detailed textual walkthrough of an onboarding/
sign-up + first-run flow for an app (screen by screen: fields, buttons, copy, validation
behavior, error states, what happens on each tap, transitions). Embed ~10 discoverable
usability problems keyed to recognized heuristics (Nielsen-ish): no error recovery on a
failed step, state loss on back-navigation, unlabeled required fields, destructive action
without confirm, hidden system status during a long operation, inconsistent affordance,
poor empty-state, no way to skip/defer, jargon in error copy, forced account creation
before value. Mix obvious + 2–3 SUBTLE (e.g. the state-loss and error-recovery ones).
Describe the flow NEUTRALLY as a spec/handoff doc — do not flag the problems.
DELIVERABLE: ux-critique.md — sections: Summary; Issues (prioritized, each: severity,
heuristic, concrete fix); Quick wins vs. larger fixes. ~2–3 pp.`,
  },
  {
    id: 'P8', dir: 'p08-bug-hunt', planted: 1,
    detail: `Task P8 — Bug hunt. PROFILE: engineering (FULLY OBJECTIVE key).
REAL REPO: Clone a SMALL, permissively-licensed (MIT/BSD/Apache) Python or JS library into
a temp dir (good candidates: a small parsing/format/date/slug utility — e.g.
github.com/pallets/itsdangerous, github.com/un33k/python-slugify, github.com/jmoiron/
humanize-like libs; pick one whose core logic is ~1–2k LOC and has a clear function-level
surface). Vendor the relevant subset of source (the module(s) a bug would live in, plus
its tests) into reference/. Then INJECT EXACTLY ONE realistic bug into one function — a
plausible regression a real PR might introduce (off-by-one, wrong boundary, swapped
operands, mishandled edge/empty/None, wrong default, broken short-circuit). It must be
REPRODUCIBLE from a symptom you describe in the brief, and NOT caught by the vendored
tests (so "why did tests miss it" has a real answer). Record exact repo URL + license +
commit SHA + the file:line and before/after of your injection in answer-key.md and in
success-criteria.md § provenance. Do NOT mention the bug or your edit in brief.md — only a
user-visible symptom ("when I pass X, I get Y, expected Z").
DELIVERABLE: root-cause.md — sections: Root cause (file:line + mechanism); How it produces
the symptom; Minimal fix; Why existing tests miss it. ~1–2 pp.`,
  },
  {
    id: 'P9', dir: 'p09-postmortem', planted: 4,
    detail: `Task P9 — Incident postmortem. PROFILE: incident/ops (planted key; FABRICATED
realistic logs, no repo needed). SUBSTRATE: Write reference/ with realistic incident
artifacts: timeline.md (terse event log with timestamps — alerts firing, deploys, oncall
actions, recovery), logs.md (excerpts: app errors, a deploy marker, DB/latency metrics,
a config-change line), and chat.md (oncall chatter). Engineer a coherent incident where
the TRUE ROOT CAUSE is detectable by correlating the artifacts (e.g. a config/flag change
or a deploy that, combined with a load condition, exhausts a connection pool / triggers a
retry storm). Key 4 items: K1 the true root cause; K2 and K3 two genuine CONTRIBUTING
factors (e.g. missing alert, no circuit breaker, a runbook gap); K4 a TEMPTING-BUT-WRONG
decoy cause that a hasty reader would blame (e.g. an unrelated error that was already
present, or "the database" when it was the pool config). A good postmortem fingers K1, cites
K2/K3, and explicitly DISMISSES K4 with evidence.
DELIVERABLE: postmortem.md — sections: Summary; Timeline; Root cause vs contributing
factors; What we ruled out & why; Remediations (with owners/sequencing). ~2–3 pp.`,
  },
  {
    id: 'P10', dir: 'p10-code-review', planted: 8,
    detail: `Task P10 — Code review. PROFILE: engineering (planted key, recall + PRECISION).
REAL REPO: Clone a small permissively-licensed repo. Author a realistic FEATURE-ADD PR as
a unified diff saved to reference/pr.diff (and include enough surrounding real source in
reference/ that the diff is reviewable in context — vendor the touched files at their
pre-PR state too). Inject ~8 defects of GRADED subtlety into the diff: e.g. an off-by-one,
a concurrency/race or shared-state bug, a security slip (unvalidated input / injection /
secret handling), a behavior regression to existing functionality, a resource leak, an
error swallowed, a wrong-default/edge bug, and one genuinely SUBTLE logic error. ALSO
include clean, correct hunks that look suspicious but are fine (precision bait — a solver
that flags them loses precision). Key each real defect (file:line in the diff, severity).
Record repo URL + license + commit SHA in answer-key.md and success-criteria.md §
provenance. brief.md = a neutral "please review this PR" request (PR title + description of
the intended feature), NOT a list of what's wrong.
DELIVERABLE: review.md — sections: Summary/verdict; Findings (each: severity, file:line,
problem, suggested fix); Nits (optional). ~2 pp.`,
  },
  {
    id: 'P11', dir: 'p11-test-strategy', planted: 0,
    detail: `Task P11 — QA / test strategy. PROFILE: quality (rubric-scored).
SUBSTRATE: Write reference/feature-spec.md — a spec for a moderately complex feature (e.g.
a scheduled-export feature, or a multi-step checkout, or a permissions/sharing model).
Include at least one HIGH-RISK INTEGRATION SEAM that a generic "test the happy path + some
edges" plan would miss (e.g. a timezone/DST boundary in scheduling, an eventual-consistency
window, a third-party webhook retry, a partial-failure/rollback path). The quality signal
is a RISK-BASED plan that finds the scary seams, says what NOT to test and why, and picks
proportionate tooling/CI gates — not an exhaustive checklist.
DELIVERABLE: test-strategy.md — sections: Risk assessment (what can hurt us most);
Coverage plan by layer; Explicitly out of scope (+why); Tooling & CI gates. ~2 pp.`,
  },
]

const SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['id', 'dir', 'filesWritten', 'plantedKeyCount', 'briefEndsWithStanzas', 'notes'],
  properties: {
    id: { type: 'string' },
    dir: { type: 'string' },
    filesWritten: { type: 'array', items: { type: 'string' }, description: 'absolute paths actually written' },
    plantedKeyCount: { type: ['integer', 'null'], description: 'number of keyed items in answer-key.md, or null for rubric-only tasks' },
    briefEndsWithStanzas: { type: 'boolean', description: 'true if brief.md ends with the Deliverable + ambiguity stanzas' },
    provenance: { type: ['string', 'null'], description: 'P8/P10: repo URL + license + commit SHA; else null' },
    notes: { type: 'string', description: 'one-line note on what was authored / any risk to flag' },
  },
}

phase('Author')
log(`Authoring ${SPECS.length} P-track tasks in parallel (Opus 4.8)…`)

const results = await parallel(SPECS.map((spec) => () =>
  agent(
    `${PREAMBLE}\n\n========================================\nYOUR TASK: ${spec.id}\n` +
    `Write your package to: ${TASKS_DIR}/${spec.dir}/\n` +
    `(create the directory; brief.md + reference/* are cell-facing; success-criteria.md` +
    `${spec.planted ? ' + answer-key.md (sealed, ' + spec.planted + ' keyed items target)' : ''} are harness-only)\n\n` +
    spec.detail +
    `\n\nWhen done, return the structured manifest. Verify on disk before returning.`,
    { label: spec.id, phase: 'Author', model: 'opus', schema: SCHEMA }
  )
))

const ok = results.filter(Boolean)
log(`Authored ${ok.length}/${SPECS.length} task packages.`)
return {
  authored: ok,
  failures: SPECS.filter((s) => !ok.find((r) => r && r.id === s.id)).map((s) => s.id),
}
