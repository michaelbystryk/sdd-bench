# P-track A4 (BMAD party mode) — reusable operator runbook

Canonical steps for any task's A4 cell. Per-task specifics (cell dir, brief, deliverable
filename) are in the table at the bottom. Config of record: `arm-configs/a4-party-mode.md`.
A4 is human-operated (locked decision) and runs **before A2** (its Opus output-token count
sets A2's thinking budget). Default invocation = **mixed-model** (personas downgraded to a
cheaper model by design — that's the locked, ecological-validity cell; see brief § Decisions
locked #4 carve-out).

## Setup (per task)
```bash
mkdir -p <CELL_DIR> && cd <CELL_DIR>
# reuse the existing BMAD v6.8.0 install (installer can't go headless; copying is fine)
cp -R ~/dev/sdd-private/orders-pagesize-a4/_bmad .
cp -R ~/dev/sdd-private/orders-pagesize-a4/.claude .
mkdir -p reference && cp ~/dev/sdd-bench/tasks/party/<TASK>/reference/* reference/   # NEVER copy answer-key.md / success-criteria.md
ls .claude/skills | grep party        # confirm bmad-party-mode
pbcopy < ~/dev/sdd-bench/tasks/party/<TASK>/brief.md
claude --model claude-opus-4-8
```
> ⚠ Planted-truth tasks (P1/P5/P8) ship a sealed `answer-key.md` as a *sibling* of
> `reference/`. Copy only `reference/*` into the cell — never the key or success-criteria.

## Run (wall rule — only these messages, log each verbatim)
1. `/bmad-party-mode`   (default; mixed-model)
2. Paste the brief (Cmd+V).
3. Permitted: `continue` / *"Use your judgment; make a reasonable assumption and tag it [ASSUMPTION]."* / closing line *"Please wrap up and produce the deliverable specified in the brief as a standalone document."* / one write-the-file nudge. Decline route-outs to PRD/architecture. Anything else voids the cell.
4. Stop rule: 3 `continue`s past the closing line → end, score what exists.

## Capture before closing
```bash
cd <CELL_DIR>; D=~/dev/sdd-bench/runs/party/<TASK>/a4/run-001/artifacts
cp <DELIVERABLE> "$D/<DELIVERABLE>"
SID=$(ls -dt ~/.claude/projects/*<cell-dir-slug>* | head -1)
cp "$SID"/*.jsonl "$D/transcript.jsonl"
mkdir -p "$D/subagents" && cp "$SID"/*/subagents/agent-*.jsonl "$D/subagents/" 2>/dev/null || true
cp -r _bmad-output "$D/planning/" 2>/dev/null || true
```
- Run **`/status`**, paste into `runs/party/<TASK>/a4/run-001/token-log.md`. Record implied
  cost, API time, **Opus output tokens** (sets A2's budget), and the **persona subagent
  model** (read from `subagents/agent-*.jsonl` — expect a cheaper model on the default run).
- Confirm top-level model = `claude-opus-4-8`.

## Per-task fill-ins

| Task | `<TASK>` | `<CELL_DIR>` | `<cell-dir-slug>` | `<DELIVERABLE>` |
|---|---|---|---|---|
| P1 threat model | `p01-threat-model` | `~/dev/sdd-private/threat-model-a4` | `threat-model-a4` | `threat-model.md` |
| P5 prioritization | `p05-prioritization` | `~/dev/sdd-private/roadmap-a4` | `roadmap-a4` | `roadmap.md` |
| P8 bug hunt | `p08-bug-hunt` | `~/dev/sdd-private/bug-hunt-a4` | `bug-hunt-a4` | `root-cause.md` |

## After handback
I run A2 at the matched thinking budget, scrub all arms, blind-score (rubric + recall-floor +
decoy-precision against the sealed key), and compute the per-task headline. Optional A4-opus
companion per task if you want the model-constant control (as on P6).
