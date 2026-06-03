# sdd-bench

**Spec-Driven Development Methodology Evaluation**

*T4 six-way complete; T1 six-way (v0.5) in progress*

---

## Context for Claude Code

This document is the working brief for an in-flight project comparing spec-driven development (SDD) methodologies on controlled tasks. It was developed in conversation with Claude (claude.ai) and is being handed to a Claude Code session for continued execution.

**Author:** Operator. This eval is intended as a methodology contribution to the SDD field.

**Constraint:** Claude Pro subscription (no separate API budget). Instrumentation adapted to manual logbook protocol — see Instrumentation section.

**Status:** Repo live; T4 hexad complete (all six methodologies scored). Next: T1 six-way (v0.5). This document is the frozen eval **design** — the live operating snapshot (what's done / what's next) lives in `analysis/handoff.md`.

---

## Project Overview

### Thesis being tested

**Spec-driven development methodologies have a discovery gap — they all degrade as task ambiguity increases.** This eval measures that degradation quantitatively.

### Positioning

An **early, exploratory cross-methodology comparison of SDD approaches** with:

- Human-stand-in PM persona (controls for operator behavior across methodologies)
- Blind, anonymized 2-rater LLM panel on code dims + operator adjudication on planning dims (blind and aware conditions kept separate, never averaged — see § Scoring)
- Open harness allowing community-driven expansion
- Six tasks (T1–T6) varying on complexity × ambiguity axis, plus a brief-quality variant (T4-rich)

Complementary to (not duplicating) Taghavi & Bhavani 2026 ("Spec Kit Agents: Context-Grounded Agentic Workflows", arXiv 2604.05278), which evaluated augmentations *within* one methodology. This work evaluates *across* methodologies.

Also complementary to ranthebuilder.cloud's April 2026 blog post "I Tested Three Spec-Driven AI Tools," which compared GSD / Spec Kit / OpenSpec / TaskMaster on a single serverless Python backend feature with a 13-category 1-5 rubric (single reviewer, no anchored scales, no cost axis, no PM persona control). sdd-bench sits between blog-tier opinion (ranthebuilder) and within-methodology academic work (Taghavi & Bhavani): controlled cross-methodology eval with anchored scales, cost as first-class metric, locked PM persona, and a 2×2 brief-quality variant — six methodologies × six tasks.

### Framing

"An Exploratory Comparison of SDD Methodologies on Real Tasks: First Findings" — not "The Definitive Benchmark." Exploratory framing protects the v0.1 single-run design from n=1 critique while inviting community expansion.

### Audience

- Senior PMs / engineers choosing methodologies for AI-assisted teams
- Methodology authors (BMAD, Spec Kit, AI-DLC / AWS maintainers)
- Agent-platform / developer-tooling teams interested in methodology-level eval


---

## Methodologies Under Test

Six configurations representing distinct points on the SDD spectrum:

| Methodology | Type | Represents |
|---|---|---|
| **BMAD v6.8.0** | Multi-agent lifecycle | "Structured methodology" pole |
| **AI-DLC** | AWS rules-driven lifecycle (run on Claude Code) | "Heavily-gated full lifecycle"; methodology-not-tool, MIT-0 |
| **OpenSpec** | Lightweight proposal → apply → archive state machine | "Minimal structured SDD"; ranked #1 in April 2026 ranthebuilder.cloud independent eval |
| **GitHub Spec Kit** | Slash-command linear flow (`/speckit-specify` → `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`) | "Lean spec-first" pole; 93K+ GitHub stars (May 2026) |
| **Vibe Plan Mode** | Vanilla Claude Code + built-in Plan Mode toggled on; no methodology layer | "Minimum effective planning" — built-in feature only |
| **Vibe Claude Code** | No methodology, just Claude Code defaults | **Control** |

The control is critical. Without it, the eval can't claim methodology adds value over zero methodology.

**Vibe Plan Mode** was added 2026-05-25 as a 5th variant to probe the "minimum effective methodology" question: is the planning step alone enough, or is the structured pipeline (Spec Kit / AI-DLC / BMAD) doing real additional work beyond Plan Mode? It sits between Vibe (no planning) and Spec Kit (full planning pipeline) on the structure spectrum.

**OpenSpec** was added 2026-05-26 as a 6th methodology after market research surfaced its April 2026 independent ranking (#1 in 13-category eval on a serverless Python backend at ranthebuilder.cloud, but on n=1 task with n=1 reviewer — not yet cross-validated). sdd-bench's contribution: confirm or refute that ranking on a different task (T4 Expo fitness app) at higher rigor (anchored scales, cost axis, PM persona control, eventual matched-pair). OpenSpec slots between Plan Mode and Spec Kit on the structure spectrum (lighter than Spec Kit's full pipeline; more disciplined than Plan Mode's single plan).

**AI-DLC** is the 6th methodology, finalized 2026-05-26. It's AWS's open-source (MIT-0) rules-driven lifecycle methodology — Inception → Construction → Operations with mandatory human approval gates at nearly every stage. We run it on **Claude Code** (the same agent, model, and token-capture harness as the other five cells in its hexad), so within each task-hexad the tool and model are held fixed and *methodology* is the only variable. (Model is pinned to the vendor-recommended era per task — Opus 4.7/xhigh for T1–T4-vague, Opus 4.8/high for T4-rich; see the model-policy note in § Instrumentation.) On the structure spectrum it sits in the structured-SDD cluster near Spec Kit, likely heavier (full-lifecycle framing + per-unit Construction loop + dense "DO NOT PROCEED" approval gates).

See `harness/methodology-configs/` for full configuration of each.

---

## Task Set

Seven tasks arranged on a complexity × ambiguity grid, with a brief-quality variant of T4:

|  | **Low ambiguity** | **High ambiguity** |
|---|---|---|
| **Low complexity** | T1: Postal-code validator + CLI (greenfield) · T2: Library API extension (brownfield) | — |
| **Medium complexity** | T3: CSV/OpenAPI endpoint | T4: Expo fitness app (vague brief) |
| **Medium complexity (brief variant)** | T4-rich: Expo fitness app (PM-quality brief, same task) | — |
| **Brownfield (feature)** | — | T5: Actual Budget feature |
| **Brownfield (bug)** | T6: OSS bug-fix (issue from active repo) | — |
| **Greenfield + external integration** | T7: Actual Budget web client (PM intent doc, open stack) | — |

**Note on T4 / T4-rich:** these are the same app task with two different briefs. T4 uses the vague 10-sentence brief in `tasks/t4-fitness-app/brief.md`; T4-rich uses a full PM-quality brief (problem statement, user, value, in/out scope, success criteria, UX principles, open assumptions) in `tasks/t4-fitness-app-rich/brief.md`. The pair tests **brief quality × methodology** as a second experimental axis — does good PM upstream compensate for methodology choice downstream?

**Note on T6:** the bug-fix task tests *diagnostic + surgical* capability against the *additive + planning-heavy* capability of T5. Same brownfield meta-skill (read + respect an existing codebase) but different operational mode.

**Note on T7 (added 2026-05-28):** T7 is greenfield like T1/T4, but with two T-unique twists. (1) The build target is a real third-party SDK (`@actual-app/api`) with a runtime constraint — it's a Node package, so a pure browser SPA can't import it. Bad planning hits this at hour 2; good planning surfaces it during spec. (2) The tech stack is **deliberately not locked** — the PM intent doc tells the cell to "pick the modern web stack you'd recommend in May 2026." Stack choice + rationale becomes a scored dimension. Together these test "does the methodology research current ecosystem reality and engage the integration boundary up front, or default to training-data muscle memory and discover the constraint at runtime." Brief is written in **PM intent-doc style** — declarative, voice-forward, with a user-base profile in `reference/users.md` (the three personas v1 is for, plus survey data) — modeling a near-future SDLC where a staff PM at a real product company writes intent and engineering owns execution. The framing is the **PM at Actual Budget itself** writing intent for the Actual engineering team about a new public web client. This puts the doc in the register it belongs in (product-company PM↔engineering handoff) and brings public-product constraints into scope: OSS license, contributor-maintainable stack, accessibility floor, i18n-readiness, E2E-encrypted-budget support, deployment-matrix compatibility (Fly/PikaPods/Docker/bare-Node), no telemetry. The brief includes success metrics, risks, and an explicit RFC ask — the engineering-facing artifact a cell should produce alongside code.

**Note on T2 (retasked 2026-05-27):** T2 was originally "better search" — a deliberately vague discovery prompt. It was retired before any cell ran because it required authoring a believable docs corpus (a content project, not a spec), had no clean objective scorer, and duplicated the discovery-gap probe that the T4 vague/rich pair already runs more rigorously (the pair measures ambiguity as a *differential* on a fixed task; an isolated high-ambiguity cell has no known-correct answer to score against). T2 is now a small brownfield API extension — objectively scored, a recognizable archetype, and the small/clean entry point of the **brownfield gradient: T2 (small extension) → T5 (large feature) → T6 (large bug).** Consequence: the low-complexity / high-ambiguity grid cell is intentionally vacant; the discovery axis is carried at medium complexity by T4 / T4-rich.

### T1: Postal-code validator + CLI *(low complexity, low ambiguity — the greenfield floor)*

Full task definition: `tasks/t1-postal-validator/brief.md`. Summary here. **Broadened 2026-05-27** from a bare validation *module* to a module **+ CLI** — a pure validator saturated the quality dimensions (everyone passes the same cases), so T1 only discriminated on cost; the CLI (arg parsing, I/O modes, exit codes, help, error UX, core/CLI separation) gives the quality axis room to vary while keeping the task fully specified and stdlib-only.

**Brief:**
> "Implement a Python package `postal_validator` that validates and normalizes postal codes for Canada, US, and UK per the rules in `reference/formats.md`, plus a small CLI. Expose `validate(code, country) -> ValidationResult` and `normalize(code, country) -> str`. The CLI runs as `python -m postal_validator validate <code> --country <CC>`, supports `--json`, reads a list from stdin, and uses meaningful exit codes. Tests in `tests/` must pass. Reject invalid input cleanly, handle whitespace and case, stdlib only."

**Reference artifacts:**

- `reference/formats.md` — exact, complete rules per country (CA `ANA NAN` with letter restrictions; US ZIP / ZIP+4; UK simplified outward+inward) + the API and CLI contracts.
- `starter/tests/` — pre-written pytest, the objective scorer: `test_core.py` (~38 cases) + `test_cli.py` (8 cases). Verified coherent against a throwaway reference impl (46 passing); the impl is **not** shipped — the methodology writes it.
- `starter/pyproject.toml` — skeleton with pytest config.

**What it tests:** the floor, now with a quality surface. Two findings: (1) the **ceremony tax** — does methodology burn multiples more cost on a trivial specified task without changing the binary outcome; (2) whether that cost buys a *better* CLI (help, error UX, clean core/CLI separation) or just the same green bar.

**Measurable outcomes:** test pass rate (binary objective), tokens, time, LOC; quality dims 1–4, 7, 9–12 (UI/UX/Security `n/a`); methodology-overhead ratio.

### T2: Library API extension *(low complexity, low ambiguity — the brownfield workhorse)*

Full task definition: `tasks/t2-library-loans/brief.md`. Summary here.

**Brief:**
> "Here's a small FastAPI lending-library service (in `starter/`). Add three endpoints: check out a book (`POST /loans`), return a book (`POST /loans/{loan_id}/return`), and list a member's loans (`GET /members/{member_id}/loans`). The behavior is pinned by `tests/test_loans.py` — make those tests pass. Match the conventions already established in `app/`, keep the existing book/member tests green, and don't add new dependencies. Produce PR-ready code."

**Reference artifacts:**

- `starter/` — a ~6-endpoint FastAPI + Pydantic v2 service (books + members) with planted conventions: an `AppError` → JSON-envelope handler, router → service → repository layering, `*Create`/`*Read` schema split, a reusable `Page` pagination envelope.
- `starter/tests/` — passing book/member suite (11 tests) + the target loan suite (`test_loans.py`, 10 tests, failing). The visible tests are the objective scorer (as in T1/T3).
- No `reference/` directory — **the codebase is the reference.** The methodology must read `app/` to learn how to extend it.

**What it tests:** reading and respecting an existing codebase's conventions on a small, bounded extension — the most common real-world dev task. The discriminator is **convention adherence**: a correct implementation written in a style alien to `app/` (inline `HTTPException`, logic in the router, no schema split) scores low even when tests pass. Tests assert the error/pagination envelopes, so some convention adherence is objectively measured; the structural conventions (layering, schema split) are scored subjectively (rubric dims 3 + 4, load-bearing).

**Measurable outcomes:**

- Binary: existing tests still pass; loan tests pass (count /10); no new deps; convention-adherence binary cut (see `success-criteria.md`)
- Quality rubric dims 1–4, 7–12 (UI/UX `n/a`; Security applies)
- Tokens, time, LOC, methodology-overhead ratio

### T3: CSV import endpoint to OpenAPI spec *(medium complexity, low ambiguity — the workhorse)*

**Brief:**
> "Build a CSV import endpoint per the attached OpenAPI spec. Use FastAPI, Pydantic v2, async. The endpoint accepts a CSV upload, validates rows against a schema, returns a per-row results summary. Use the test suite. Implement error handling for malformed CSV, missing required columns, type mismatches, and partial success cases."

**Reference artifacts:**

- `openapi.yaml` — fully specified endpoint with request/response schemas
- `tests/` — integration tests via httpx (happy path, malformed, partial-success, large files, embedded newlines, UTF-8 BOM, mixed line endings)
- `sample_csvs/` — 8 CSVs covering test scenarios
- `pyproject.toml` with FastAPI/Pydantic v2 pinned

**What it tests:** the middle of the curve. Realistic backend feature work. Pydantic v2 specifically is a trap — models trained on v1 patterns can silently produce v1 code that fails subtle tests.

**Measurable outcomes:** test pass rate (cleanest scorer), tokens, time, code quality (separation of concerns, Pydantic v2 patterns, async correctness, error response quality), intermediate artifacts quality

### T4: Expo fitness app *(medium complexity, high ambiguity — the personal-scope test)*

**Brief:**

```
Build me a strength training app I can use during workouts.

The app lets me:
- Pick a program from a list (5x5, 5x3, plus one I haven't decided yet — pick one)
- Configure how many days per week I want to train (3 or 4)
- See today's workout when I open the app
- Log each set with weight and reps as I do it
- See my progress over time on the four lifts

The four lifts are: squat, bench press, overhead press, deadlift.

I want it to feel good to use mid-workout — hands sweaty, between sets,
glancing at it. The weight selector specifically should be fast.

Build it in Expo. Target iOS and Android. SQLite or AsyncStorage is fine
for storage; doesn't need to sync.

Ship something that builds and runs in Expo Go.
```

**Reference artifacts (`me.md`):**

- "I lift 4 days a week, intermediate. Bench 225, squat 315, dead 405, OHP 145."
- "I want to switch between programs occasionally without losing history."
- "I don't want to think about math mid-workout — show me the next weight."

**What it tests:** product-scoping discipline. State machines (in-workout, between sets, rest), data modeling that compounds, UX under physical constraints, platform-specific concerns.

**Deliberate vague spots (measurement targets):**

- "plus one I haven't decided yet — pick one" — forces product decision
- "feel good to use mid-workout" — forces UX engagement
- "see my progress over time" — analytics decision (charts? tables?)
- No mention of auth, account, sync, sharing — forces scoping call

**Measurable outcomes:**

- Scope clarity score (0-5)
- Assumption surfacing (count)
- Builds and runs in Expo Go (binary)
- Feature inventory rubric (0-5 per dimension: programs supported, set logging, progression logic correct, history view, UX affordances)
- Code quality (TypeScript usage, component structure, state management, data model)
- Tokens, time, LOC

**Note on stack choice:** Expo (not Swift) is intentional. Single-platform Swift would contaminate the comparison by simplifying the task. Cross-platform mess is part of what the eval tests.

### T5: Actual Budget feature *(brownfield, real codebase)*

**Target:** [actualbudget/actual](https://github.com/actualbudget/actual) — TypeScript Electron + web + React Native, envelope budgeting, MIT, ~80K LOC.

**Feature candidate:** "Custom date range presets for reports" (This Quarter, Last 6 Months, YTD) — touches reports module, date-range picker, preference persistence. Small, bounded, real-user-requested.

**Alternative features (in priority order):**

1. "Skip month" option for scheduled transactions
2. Bulk-edit category for transaction list

**Brief:**
> "Here's a fork of Actual Budget (commit pinned). Implement issue #XXXX, which asks for [feature]. The issue describes the desired behavior. Make it land cleanly — match the project's conventions, don't break existing tests, write new tests for the new behavior, and produce a PR-ready branch with appropriate commits."

**Reference artifacts:**

- Repo at pinned commit
- Issue text (real, from actual tracker)
- `CONTRIBUTING.md`
- Existing test suite
- `task.md` saying just: "Implement this feature."

**What it tests:** reading and respecting an existing codebase's conventions, locating where in 80K LOC a change belongs, working within a real test framework, producing diffs that a maintainer would accept.

**Measurable outcomes:**

- Existing tests still pass (binary)
- New tests added and passing (count + pass rate)
- Convention adherence (0-5, manual review)
- PR-readiness score (0-5: auto-merge / light review / heavy review / rejected / embarrassing)
- Files touched, LOC added/changed (oversized diffs to small features = failure mode)
- Did the methodology read relevant existing code? (inspect planning artifacts)

**Aspiration:** recruit one Actual Budget maintainer/contributor as blind reviewer for T5.

### T4-rich: Expo fitness app, PM-quality brief variant *(added in v0.1; runs v0.8)*

**Same task as T4** (Expo strength-training app, same four lifts, same user, same Expo Go target). **Different brief** — instead of the 10-sentence vague brief, T4-rich uses a full PM-quality brief at `tasks/t4-fitness-app-rich/brief.md`. The brief includes (at minimum):

- Problem statement (why this matters, what pain it solves)
- User (specific person, context — same `me.md` reference as T4)
- Value (what success looks like for the user)
- In scope (explicit list, not implicit)
- Non-goals (auth / social / sync / sharing → stated, not silent)
- Constraints (Expo, SQLite/AsyncStorage, Expo Go runtime, TS preferred)
- Success criteria (measurable: under N taps, under N seconds)
- UX principles (sweaty hands, dark mode, large tap targets, screen-on)
- Open assumptions ("AsyncStorage is fine for v1, push back if not")
- Stretch goals (out of scope for v1; design data model to accommodate)

**What it tests:** brief quality × methodology interaction. Paired with T4 results, gives a 2×2 matrix that answers:
- How much does good PM upstream compensate for methodology choice downstream?
- Does Vibe still go silent on a rich brief (Vibe-trait) or does it engage (briefs drive behavior)?
- Do structured methodologies become redundant when the brief is excellent?

**Measurable outcomes:** same rubric as T4 (Quality axis + Cost axis); applicability matrix unchanged. The pair's *differential* is the finding.

**Operator note:** T4-rich brief is authored by the operator (PM by trade) before v0.8. Locked at commit time. Reuses T4's `reference/me.md`.

### T6: OSS bug-fix *(brownfield-surgical, real codebase)* — added in v0.1; runs v0.9

**Target:** TBD — mid-sized active OSS repo, *different from T5's Actual Budget* for breadth. Candidates and selection criteria in Open Questions §7.

**Brief:**
> "Here's a fork of [repo] (commit pinned). Fix issue #XXXX — see `reference/issue.md`. Diagnose the root cause, produce a minimal fix, and add a regression test. Match the project's conventions, don't break existing tests. Produce a PR-ready branch with appropriate commits."

**Reference artifacts:**

- Repo at pinned commit
- Issue text (real, from tracker — `reference/issue.md`)
- `CONTRIBUTING.md` from the repo
- Existing test suite
- `task.md`: "Fix this bug."

**What it tests:** *diagnostic + surgical* capability, distinct from T5's *additive + planning-heavy* feature work. SDD methodologies may underperform here — their planning pipelines assume feature work, not investigation. Hypothesis: Vibe may *win* on T6 because diving into code beats planning a fix.

**Measurable outcomes:**

- Existing tests still pass (binary)
- Regression test added that fails on old code and passes on new code (binary)
- Root cause identified correctly (manual review, 0–5)
- Diff scope minimal — LOC bounded; touched-files count bounded (oversized fixes to small bugs = failure mode)
- Convention adherence (0–5)
- PR-readiness (0–5)
- Did the methodology read enough code to localize the bug? (inspect planning artifacts)

**Aspiration:** recruit a contributor of the chosen repo as blind reviewer for T6.

---

### T7: Actual Budget web client *(greenfield + real external SDK, open stack)* — added in v0.1; runs v1.2

**Target:** A self-hosted Actual Budget sync server (pinned, operator-managed) seeded with a representative household envelope budget (the largest user segment per Actual's Q1 2026 research). The cell builds a **web client** from scratch that talks to the server via `@actual-app/api`. The intent doc positions the author as a **staff PM at Actual Budget Inc.** writing intent for the Actual engineering team — the new web client is positioned as Actual's third first-class surface alongside desktop and mobile.

**Brief:**
> "We're shipping a web client for Actual. v1 is five features (accounts overview, account transactions, current-month envelopes, allocate-envelope inline edit, add-transaction) targeting our three user personas (Household Couple, Solo Self-Hoster, Side-Business Operator). **Pick the modern web stack you'd recommend in May 2026** — defend it in your RFC; the community will read it. SDK has a runtime constraint worth surfacing early. Must work across the existing deployment matrix (Fly/PikaPods/Docker/bare-Node) and against E2E-encrypted budgets. No telemetry, no third-party tracking, MIT-licensed, i18n-ready, AA accessibility on core flows."

Cell-facing brief is written as a **PM intent document** with header metadata (From: Product, To: Engineering, Status: Intent), TL;DR, Why-now, Users + personas (linked to `users.md`), Success metrics, Features, Out-of-scope, Stack-open guidance, Constraints (OSS-public-product), UX principles, Three user moments (one per persona), Risks, Open assumptions, References, Stretch. Modeling a near-future SDLC where a staff PM at a real product company writes intent and engineering owns the RFC + execution.

**Reference artifacts:**

- `reference/users.md` — user base summary, three primary personas with defining moments + survey data + GitHub Discussion context + hosted-offering churn signals
- `reference/api-quickref.md` — common `@actual-app/api` methods + notes on the Node-only runtime
- `reference/server-info.md` — server URL, sync ID, password placeholders + optional E2E-encrypted variant for cells that want to validate encrypted-budget support

**What it tests:** **(a)** stack-choice quality under an open prompt — does the methodology research 2026 ecosystem reality or pattern-match training-data defaults? **(b)** external-SDK boundary discovery — does the methodology surface the Node-only constraint in planning, or smash into it at implementation? T7 is also the **only** task in the suite where UI + UX are heavily load-bearing scoring dimensions against PM-stated UX principles.

**Measurable outcomes:**

- App starts; server connection succeeds; budget loads (binary)
- All five features functional end-to-end against seeded data (binary, per feature)
- Cents-accurate amount handling across the round-trip (binary, spot-check)
- Stack pick rationale documented in planning artifacts (binary + 0–5 quality)
- Node-SDK constraint surfaced in planning vs. discovered at implementation (timing score)
- No credentials committed to repo (binary)
- UI/UX scored against brief's UX principles (modal-on-allocation = fail intent; >4 taps to log a transaction = mediocre)

**Verification:** Chrome extension drives the browser, walks the three scenarios in §9 of the brief, queries the server post-write to confirm the round-trip. Web analogue of T4's idb-on-iOS-sim workflow.

**Aspiration:** invite an Actual Budget maintainer to review the resulting client(s) and weigh in on which methodology's stack pick + architecture they'd be most willing to maintain.

---

## PM Persona

The PM persona is a test-harness component, not a methodology participant. Same model instance — matched to each task's pinned model era (Opus 4.7 for T1–T4-vague, Opus 4.8 for T4-rich) — with a frozen system prompt, used across all cells of all methodologies to respond to clarifying questions.

### System prompt (v1, hash-pending)

```
You are the Product Manager for a project being built by a development team
using an AI coding methodology. You are responding to clarifying questions
from that team during planning or implementation.

Your character:
- You have moderate context on the project (only what's in the original brief).
- You are busy. You give short, decisive answers. You do not write specs in
  your replies — that's the team's job.
- You make product calls when asked. You pick one option rather than listing
  trade-offs. If pressed for rationale, give one sentence.
- You treat "use your best judgment" as a valid answer when a question is out
  of scope or would require info you don't have.
- You do not volunteer information. Answer only what was asked.
- You do not flatter, encourage, or comment on the methodology. You are not
  a coach. You are a stakeholder.

Response policy:
- Direct questions about scope/intent/priorities: answer in 1-3 sentences.
- Questions about technical implementation choices ("should we use X library?"):
  reply "Your call — pick what's appropriate."
- Questions that would require info you don't have: reply "I don't have that
  detail. Use your best judgment and document the assumption."
- Requests to validate a draft spec or plan: read it, give a one-paragraph
  reaction noting one to three concerns or confirmations. Don't rewrite it.
- Requests to choose between presented options: pick one. State which.
  Don't deliberate.

You do not break character. You do not refer to the methodology by name.
You do not acknowledge that you are an AI or that this is an evaluation.
You are the PM. The team is asking you questions. You answer.

The project brief follows.

---

[BRIEF.MD CONTENT PASTED HERE PER TASK]

---

[REFERENCE/ME.MD CONTENT PASTED HERE IF APPLICABLE]
```

### Calibration before locking

Before running any cell, spend one session pressure-testing the persona:

1. Open fresh Claude session with persona system prompt + T4 brief
2. Ask 5-10 questions a methodology might ask
3. Read answers: consistent? Over-explained? Decisive? Uses "best judgment" appropriately?
4. Tweak prompt until persona feels right
5. Lock final version in `harness/pm-persona-v1.md`, hash it, note hash in README

### Behavioral rules across cells

- One PM persona system prompt, hashed and version-locked, used for every cell of every task
- Per-task brief loaded into persona at start of every cell, identical content
- Fresh persona session per cell (no cross-cell context bleed)
- Operator forwards questions verbatim — no editorial smoothing — pastes responses verbatim back
- Light cleaning OK: strip methodology-specific terminology (agent names), keep substantive question
- No augmenting questions with operator knowledge or framing

### What the PM does NOT do

- Does not proactively volunteer answers to questions that weren't asked
- Does not adjust thoroughness based on which methodology is asking
- Does not contaminate Vibe by giving it what BMAD would have extracted

---

## Protocol

### Operator behavior

**Run each methodology faithfully per its documentation.** Accept defaults. Forward product/scope questions to PM persona; answer methodology-mode/tooling questions per the locked configuration. Do not improvise. Do not skip required phases. Do not add custom configuration not specified in the config file.

### Question routing: PM persona vs operator

| Forward to PM persona | Operator answers per config |
|---|---|
| Product intent, scope, priorities | Whether to run an optional methodology mode |
| User goals, target audience | Tooling/configuration choices |
| Feature decisions, tradeoffs | Workflow timing (continue now or pause) |
| Validation criteria, success metrics | Whether to use a particular agent next |
| Any product-strategy question | Anything about *how* the methodology runs |

The PM persona answers questions about *what is being built*. The operator answers questions about *how the methodology runs*.

### End-of-cell rules

A cell ends when:

1. The methodology declares the work complete, OR
2. Operator detects a stall (10 consecutive minutes with no progress), OR
3. A phase fails three times consecutively (document and mark cell-incomplete), OR
4. Rate limit interrupts session (document, mark cell-rate-limited)

Cells that complete via #2-#4 are still data — they reveal methodology failure modes. Do not discard.

### No reruns of "bad" attempts

If a methodology produces broken output, that's data. Publish it. Do not rerun just because the result was disappointing. Radical transparency = the defense of single-run v0.1.

---

## Instrumentation

### Constraint: Claude Pro subscription, no API key

- LiteLLM + Langfuse proxy approach not viable for Pro auth (consumer OAuth, not API key)
- Manual logbook protocol instead

### Per-cell logbook (three files)

**`session-log.md`** — chronological run log with timestamps:

```
## T<n>-<methodology> / Run <NNN> / <date>

[HH:MM] Started <methodology> session. Pasted brief verbatim. No prior context.
[HH:MM] <Methodology> asked: "..."
[HH:MM] Forwarded to PM persona. Response: "..."
[HH:MM] Pasted PM response back.
[HH:MM] <Methodology> began <action>.
...
[HH:MM] <Methodology> declared done.
[HH:MM] Captured token totals (see token-log.md).
[HH:MM] Build attempt — see build-result.md.
```

**`token-log.md`** — token capture from Claude Code `/status` or equivalent:

```
## Token Capture

Captured via /status command at end of session.
Screenshot at: <link>

Session input tokens: <n>
Session output tokens: <n>
Cached read tokens: <n>
Cached write tokens: <n>

Implied cost if billed at API rates: $X.XX

Notes:
- Pro subscription, no direct billing
- Numbers as displayed by Claude Code CLI
- Screenshot retained for verification
```

**`artifacts/`** — all code produced, chat transcripts (exported), PM persona transcripts, build attempt output, methodology planning artifacts (PRDs, architecture docs, etc.)

### Rate limit mitigation

- Start cells at the beginning of a fresh 5-hour Pro window
- Spread T4/T5 cells across days, not stacked
- If rate-limited mid-cell: document throttle time, pause cleanly, resume when window resets, note in session log
- The scored time metric (API compute time) is unaffected by rate-limit pauses — the model isn't inferring during a throttle. The disclosed wall-clock/active-session numbers should subtract pause duration

### Disclosure paragraph for writeup

> Token measurement was performed via Claude Code's built-in session reporting with screenshot verification, due to the use of Pro subscription authentication. Per-call traces were not captured. Aggregate session-level token counts and timestamps are recorded for each cell. Reviewers can reproduce by running the same brief through the same methodology with similar instrumentation.

---

## Scoring Rubric

### Objective metrics (instrumented, run-time)

- **Tokens consumed** (input, output, cached separately)
- **API compute time** (raw model-inference time — the scored time metric; excludes tool/operator latency)
- **Wall-clock time** (start to working artifact — disclosed context, not scored)
- **Human-touch time** (operator minutes at gates / reviewing / redirecting)
- **Human interventions** (count of operator corrections / mid-flight redirections)

### Objective output metrics

- **Tests passing rate** (where tests exist: T1, T3, T5)
- **Build/run success** (T4: Expo Go launches; T5: existing tests still pass)
- **Spec adherence rate** (binary per requirement from brief)
- **LOC produced**, files touched/produced

### Subjective quality metrics (double-rated, blinded to methodology where possible)

5-point scale on each dimension:

- **Code quality:** correctness, readability, structure, testability, idiomatic
- **Specification quality:** how well did the methodology articulate intent before code?
- **Scope clarity:** did it document what's in/out and why?
- **Assumption surfacing:** explicit assumption tags / decision records produced
- **For T5 specifically:** convention adherence, PR-readiness

### Failure mode characterization (qualitative)

- Where each methodology broke down
- What categories of mistake it made
- What it did surprisingly well

### Blinded review process

Strip methodology labels from outputs when sending to second reviewer. Identify only as "Output A through L" or similar. Score, then unblind.

For T5: aspire to recruit an Actual Budget maintainer for convention-adherence scoring.

---

## Versioning Roadmap

| Version | Scope | Approximate effort |
|---|---|---|
| **v0.1** | T4-Vibe only | Done (2026-05-22 → 2026-05-25) |
| **v0.2** | + T4 Spec Kit | +1 week |
| **v0.3** | + T4 AI-DLC | +1-2 weeks |
| **v0.4** | T4 full **six-way** comparison (vague brief) — adds OpenSpec | First headline finding |
| **v0.5** | T1 six-way (cheap, validates apparatus) | +1 weekend |
| **v0.6** | T2 six-way | +2 weekends |
| **v0.7** | T3 six-way | +2 weekends |
| **v0.8** | T4-rich six-way (PM-quality brief variant of T4) | tests brief-quality × methodology axis; run as hexad×3 |
| **v0.9** | T6 six-way (OSS bug-fix, brownfield-surgical) | +3-4 weeks |
| **v1.0** | + T5 six-way (brownfield-feature) + full writeup | +3-4 weeks |
| **v1.2** | + T7 six-way (Actual web client — greenfield + external SDK, open stack, intent-doc brief) | +3-4 weeks |
| **v2.0** *(if traction)* | Expand to 3 runs per cell across all tasks | +2-3 months |

Each version is shippable on its own. Each push is a moment to assess "is this getting traction, should we continue."

### Traction definition for v2.0 expansion

Expand to 3 runs/cell only if:

- 2,000+ views in first week of v1.0, OR
- Named maintainer/researcher engages (BMAD's Brian Madison, Spec Kit team, AWS AI-DLC team, vocal Spec Kit user with audience), OR
- Inbound from an agentic-platforms team or adjacent, OR
- Direct request to run more cells from someone with credibility

---

## Budget

### v0.1 (T4-Vibe only)

- API: $0 (Pro subscription)
- Time: 1 weekend (instrumentation setup not needed; repo + brief + persona + run + writeup)

### v0.4 (full T4 six-way)

- API: $0-50 (mostly Pro; AI-DLC runs on Claude Code, no separate auth/billing)
- Time: ~3-4 weekends elapsed

### v1.0 (all 6 tasks, single-run)

- API: ~$100-200 if API needed for instrumentation rigor on T5/BMAD
- Time: ~13-17 weekends elapsed; 4-6 months realistic

### v2.0 hypothetical (3 runs per cell)

- API: ~$1,300-$1,700 USD
- Time: +2-3 months on top of v1.0

### Cost grid reference (per-cell, single-run, USD if billed at API rates)

Columns in structure-spectrum order. **Pre-run estimates** in the spirit of the original grid (Plan Mode just above Vibe; OpenSpec between Plan Mode and Spec Kit) — *not* measured actuals. Measured per-cell costs live in the run logbooks and `analysis/<task>/` (e.g. the scored T4 hexad: Vibe $5.84 · OpenSpec $7.16 · Plan Mode $7.78 · Spec Kit $13.21 · AI-DLC $19.15 · BMAD $75.85).

|  | Vibe | Plan Mode | OpenSpec | Spec Kit | AI-DLC | BMAD |
|---|---:|---:|---:|---:|---:|---:|
| T1 | $1.50 | $2.00 | $2.50 | $3.00 | $3.75 | $10.00 |
| T2 | $2.75 | $3.50 | $4.50 | $5.50 | $7.00 | $18.00 |
| T3 | $4.00 | $5.50 | $6.50 | $8.00 | $10.00 | $25.00 |
| T4 | $14.00 | $18.00 | $22.00 | $28.00 | $35.00 | $90.00 |
| T5 | $7.00 | $9.50 | $12.00 | $15.00 | $20.00 | $40.00 |
| T6 | $5.00 | $6.50 | $8.00 | $10.00 | $13.00 | $28.00 |
| T7 | $10.00 | $13.00 | $16.00 | $20.00 | $26.00 | $55.00 |

On Pro: implied costs only. Actual billing flat at $20/month with rate limits.

---

## Repo Structure

```
sdd-bench/
├── README.md                  ← orientation + methodology summary + harness hashes
├── CLAUDE.md                  ← harness guardrail (read first; "don't run cells here")
├── PROJECT-BRIEF.md           ← this document (frozen eval design / source of truth)
├── tasks/
│   ├── t1-postal-validator/   # brief.md, reference/formats.md, starter/{pyproject.toml,tests/}, success-criteria.md, README.md
│   ├── t2-library-loans/      # brief.md, starter/{app/,tests/,pyproject.toml} — code is the reference (no reference/ dir), success-criteria.md, README.md
│   ├── t3-csv-openapi/        # reference/{openapi.yaml,sample_csvs/}, starter/{pyproject.toml,tests/}
│   ├── t4-fitness-app/        # brief.md, reference/me.md, success-criteria.md  (vague brief)
│   ├── t4-fitness-app-rich/   # brief.md, reference/me.md, starter/, success-criteria.md  (PM-quality brief variant)
│   ├── t5-actual-feature/     # reference/  (brownfield feature — repo pin + issue TBD)
│   ├── t6-bug-fix/            # brief.md, reference/, starter/, success-criteria.md  (brownfield bug — tldraw; issue TBD)
│   └── t7-actual-client/      # brief.md (intent doc — PM at Actual to Actual eng), reference/{users.md,api-quickref.md,server-info.md}, success-criteria.md  (greenfield + external SDK, open stack)
├── harness/
│   ├── pm-persona-v1.md                    ← locked system prompt (sha256 in README)
│   ├── pm-persona-calibration-set.md
│   ├── pm-persona-calibration-transcript.md
│   ├── scoring-rubric.md                   ← Quality axis + Cost axis + headline pair
│   ├── scoring-rubric-changelog.md
│   ├── scoring-prompt.md
│   ├── evaluation-prompt.md
│   ├── operator-runbook.md                 ← how to run a cell
│   ├── methodology-configs/                ← the six locked configs (source of truth)
│   │   ├── vibe-claudecode.md
│   │   ├── vibe-planmode.md
│   │   ├── openspec.md
│   │   ├── spec-kit.md
│   │   ├── ai-dlc.md
│   │   └── bmad.md
│   └── scripts/                            # run-cell.sh, save-cell-artifacts.sh, parse-cell-transcript.py
├── runs/
│   └── <task>/<methodology>/run-NNN/       ← per cell: session-log.md, token-log.md,
│       │                                     build-result.md, observations.md, artifacts/
│       └── methodologies: vibe · vibe-planmode · openspec · spec-kit · ai-dlc · bmad
└── analysis/
    ├── handoff.md             ← living operating snapshot (status, decisions log, next actions)
    ├── README.md
    ├── harness-sessions/      ← archived harness-session timelines
    └── <task>/                ← per-task cross-cell writeups (e.g. t4-fitness-app/{scoring-matrix,feature-matrix,rigor-pass-tie-audit}.md)
```

---

## Methodology Configurations

Each methodology's full, locked configuration lives in its own file under
`harness/methodology-configs/` — **those files are the source of truth.** This
brief deliberately does not inline them: a previous copy here drifted out of sync
when methodologies were added, so the canonical text now lives in one place only.

| Methodology | Config file | One-line summary |
|---|---|---|
| Vibe Claude Code *(control)* | `vibe-claudecode.md` | Vanilla Claude Code, no methodology layer |
| Vibe Plan Mode | `vibe-planmode.md` | Vanilla Claude Code with built-in Plan Mode toggled on |
| OpenSpec | `openspec.md` | Lightweight propose → apply → archive delta-spec workflow |
| GitHub Spec Kit | `spec-kit.md` | Slash-command pipeline (`/specify` → `/clarify` → `/plan` → `/tasks` → `/implement`) |
| AI-DLC | `ai-dlc.md` | AWS rules-driven lifecycle (Inception → Construction → Operations) run on Claude Code |
| BMAD | `bmad.md` | Multi-agent lifecycle (Analyst → PM → Architect → Dev → QA) |

Each config pins versions, setup, workflow, enabled/disabled optional features,
and end-of-cell rules. Read the relevant file before running that methodology's
cell.

---

## Related Work

### Cited reference

**Taghavi, P. & Bhavani, S. (2026). "Spec Kit Agents: Context-Grounded Agentic Workflows." arXiv 2604.05278.**

Built a multi-agent SDD pipeline (PM + developer roles) with read-only probing hooks grounding each Spec Kit phase (Specify, Plan, Tasks, Implement) in repository evidence. Evaluated 128 runs covering 32 features across five repositories. Context-grounding hooks improved judged quality by +0.15 on a 1-5 composite LLM-as-judge score. On SWE-bench Lite, achieved 58.2% Pass@1.

**Position relative to sdd-bench:** Taghavi & Bhavani evaluated augmentations *within* one methodology. sdd-bench evaluates *across* methodologies. Complementary; cite explicitly.

### Existing infrastructure being intentionally NOT used in v0.1

- **LiteLLM** (open-source AI gateway) — would be ideal with API access; not viable on Pro auth
- **Langfuse / Helicone** (LLM observability) — same constraint
- **Forge** (autonomous SDD loop for Claude Code) — single-methodology autonomous SDD harness
- **The Factory** (self-evolving meta-harness with auto-discovered eval dimensions) — adjacent but different
- **ECC (everything-claude-code)** — single-harness optimization, not cross-methodology

### Authoritative SDD references

- **Piskala, D. (2026). "Spec-Driven Development: From Code to Contract in the Age of AI Coding Assistants." arXiv 2602.00180.** Three-level rigor framework (spec-first, spec-anchored, spec-as-source). Use this vocabulary.
- **Marri (2026). "Constitutional Spec-Driven Development." arXiv 2602.02584.** Security-by-construction follow-on.
- **GitHub Spec Kit official docs:** github.github.com/spec-kit
- **BMAD-METHOD:** github.com/bmad-code-org/BMAD-METHOD
- **Wikipedia entry:** "Spec-driven development" (exists as of 2026)
- **Bryan Finster, "5-Minute DevOps: Spec-Driven Development Isn't New":** the "BDD with branding" position

---

## Decisions Locked

1. **Single-run v0.1** (n=1), with vibe Claude Code triple-runned for variance baseline (~$60 add at API rates; effectively free on Pro)
2. **Harness repo public from v0.8**; per-task evidence + transcript repos stay private (originally scoped "private through v0.4 release")
3. **Exploratory framing** in title and writeup tone (not "definitive benchmark")
4. **PM persona is test-harness component, not contender** — sdd-bench tests six existing methodologies, not seven
5. **EDPL/BDM/ASM are NOT in this eval** — they get a separate follow-up post that builds on sdd-bench's neutrality credit
6. **T4 stack: Expo, not Swift** (preserves cross-platform complexity dimension)
7. **T5 target: Actual Budget** (with "Custom date range presets for reports" as primary feature candidate)
8. **No API budget** — Pro subscription only; manual logbook protocol
9. **Methodology config files locked per methodology** — see harness/methodology-configs/
10. **Same operator (Michael) runs all cells** — disclosed as known confound; methodology fidelity managed via locked configs and PM persona
11. **Single PM persona** (calibrated middle-engagement) for v0.1; sensitivity analysis deferred

---

## Open Questions

Original v0.1 questions (resolution status noted):

1. ~~**Repo name:** `sdd-bench` proposed.~~ **Resolved:** `sdd-bench` confirmed.
2. ~~**6th-methodology setup path:** does it run under the operator's existing Pro auth?~~ **Resolved 2026-05-26:** the 6th methodology is **AI-DLC** (AWS's open-source, MIT-0 rules-driven lifecycle). It runs on **Claude Code** under the operator's existing Pro subscription — rules in `CLAUDE.md` + `.aidlc-rule-details/`, no separate install, IDE, or authentication. Same model (pinned per task era — see § Methodologies) and `/status` token capture as the other five cells. See `harness/methodology-configs/ai-dlc.md`.
3. **Second reviewer for blinded scoring:** who? Recruit before v0.4.
4. **T5 feature confirmation:** "Custom date range presets" vs "Skip month for scheduled txns" vs alternative. Browse Actual's issue tracker, pick the cleanest currently-open ask. *Defer until v1.0 approaches.*
5. **Exact BMAD v6 toggles:** any I missed? Defer until BMAD cell is approached (likely v0.4).

New questions added in v0.1+ (post-cell expansion of scope):

6. **T4-rich brief content:** operator (PM by trade) to author the PM-quality brief at `tasks/t4-fitness-app-rich/brief.md`. Must include: problem statement, user, value, in scope, non-goals, constraints, success criteria, UX principles, open assumptions, stretch goals. Lock before v0.8 cell execution.
7. **T6 repo + issue selection:** pick one mid-sized active OSS repo and one specific issue. Pin the commit. Candidates:
    - `tldraw/tldraw` (TS, ~150K LOC, focused canvas scope, responsive maintainers) — best for clean experiment
    - `immich-app/immich` (TS/Node/Svelte, ~300K LOC, self-hostable for verification, hundreds of triaged bugs) — best for real-world feel
    - `cal.com` (TS/Next.js, large but most modern stack) — best for industry relatability
    - Alternative: `directus/directus`, `gin-gonic/gin`, `PocketBase`
    - **Selection criteria:** medium-sized; recent activity; issue is reproducible with steps; fix scope 5–50 LOC; requires reading ~100–500 LOC to localize; has regression-test convention.
    - Use a *different* repo from T5's Actual Budget for breadth.
    - Lock before v0.8 cell execution.

---

## Remaining Work

The repo, harness, and the full T4 vague-brief hexad are done. The **live action
queue — what's done, what's next, blockers — lives in `analysis/handoff.md`**;
this section is the durable roadmap view, not a step-by-step checklist.

In roadmap order:

1. **Finish the T4-rich six-way** (v0.8) — re-run Vibe on the sanitized v0.3
   rich brief, then the remaining methodologies; score against
   `tasks/t4-fitness-app-rich/success-criteria.md`. Tests brief-quality ×
   methodology as a differential against T4-vague.
2. **Run the T1–T3 six-ways** (v0.5–v0.7) — cheaper cells that validate the
   apparatus across the greenfield floor (T1), brownfield extension (T2), and
   the workhorse backend (T3).
3. **Lock T6 before v0.8** — repo is `tldraw/tldraw`; pick the specific issue per
   the §7 criteria (reproducible, 5–50 LOC fix, deterministic regression test),
   pin the commit, fill the brief placeholders.
4. **Lock T5 before v1.0** — confirm the Actual Budget feature + issue, pin the
   commit.
5. **Recruit the second blinded reviewer** (Open Questions §3) before publishing
   the v0.4 headline; aspire to a maintainer reviewer for T5/T6.
6. **Publish** each version as it lands (`analysis/<task>` writeups → public repo
   with exploratory framing).

How to run and score a cell: `harness/operator-runbook.md` +
`harness/scoring-rubric.md`. Per-cell logbook templates are pre-scaffolded under
`runs/<task>/<methodology>/run-NNN/`.

---

## Closing notes for the Claude Code session

This document is the eval **design** and lives at the repo root as `PROJECT-BRIEF.md`. Refer back to it as the source of truth for design decisions. When in doubt about a methodology config, scoring criterion, or workflow rule — check here first before improvising.

The single most important discipline: **do not move design questions back into discussion when they should be in execution.** Open questions exist; address them in the open-questions queue. Locked decisions stay locked unless v0.2+ explicitly revisits them.

For live status, the decisions log, and the current next action, see `analysis/handoff.md` — the operating snapshot kept current as cells complete. This design doc and that snapshot are the two files a resuming session should read first (after `CLAUDE.md`).

---

*Generated from claude.ai conversation, May 2026. v0.4 in flight (T4 hexad complete).*
