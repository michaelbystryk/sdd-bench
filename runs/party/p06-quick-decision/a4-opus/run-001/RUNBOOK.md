# P6 — A4-opus (BMAD party mode, `--model opus`) / run-001 — OPERATOR RUNBOOK

**Paired controlled companion to A4 (default mixed-model).** Same machinery, but all persona
subagents forced to `claude-opus-4-8` via `--model opus`, so A4-opus is **model-constant with
A1–A3**. Question it answers: *does party mode add value when fairly resourced (same model as
the solo arms)?* — removing the "personas were handicapped on Sonnet" objection to A4.
It does NOT change the spawn architecture, so expect still-parallel one-shot personas (no real
debate); this isolates **model**, not machinery shape.

## Why a FRESH dir (blindness)
The original cell (`orders-pagesize-a4`) now holds the prior `decision.md` + `_bmad-output` —
party mode would see a prior answer and be contaminated. Run in a clean dir; reuse the BMAD
install by copying it (faster than reinstall, same v6.8.0).

```bash
# 1. Fresh blind dir + reuse the existing BMAD install + seed reference
mkdir -p ~/dev/sdd-private/orders-pagesize-a4-opus && cd ~/dev/sdd-private/orders-pagesize-a4-opus
cp -R ~/dev/sdd-private/orders-pagesize-a4/_bmad .
cp -R ~/dev/sdd-private/orders-pagesize-a4/.claude .
mkdir -p reference && cp ~/dev/sdd-bench/tasks/party/p06-quick-decision/reference/situation.md reference/
ls .claude/skills | grep party     # confirm bmad-party-mode present

# 2. Brief to clipboard, launch pinned to Opus
pbcopy < ~/dev/sdd-bench/tasks/party/p06-quick-decision/brief.md
claude --model claude-opus-4-8
```

## Run (identical wall rule to A4)
1. **`/bmad-party-mode --model opus`**  ← the only difference from the default cell
2. Paste the brief (Cmd+V) as kickoff.
3. Permitted operator messages only (log verbatim): `continue` / the scripted assumption line
   / the closing line when converged / one write-the-file nudge. Decline route-outs.
4. Stop rule: 3 `continue`s past the closing line → end + score what exists.

## Capture before closing (same as A4)
```bash
cd ~/dev/sdd-private/orders-pagesize-a4-opus
D=~/dev/sdd-bench/runs/party/p06-quick-decision/a4-opus/run-001/artifacts
cp decision.md "$D/decision.md"
SID_DIR=$(ls -dt ~/.claude/projects/*orders-pagesize-a4-opus* | head -1)
cp "$SID_DIR"/*.jsonl "$D/transcript.jsonl"
mkdir -p "$D/subagents" && cp "$SID_DIR"/*/subagents/agent-*.jsonl "$D/subagents/" 2>/dev/null || true
cp -r _bmad-output "$D/planning/" 2>/dev/null || true
```
- Run **`/status`**, paste the block into `a4-opus/run-001/token-log.md`. **Confirm the
  persona subagents now show `claude-opus-4-8`** (that's the whole point — verify the
  `--model opus` took, both in `/status` and in the `subagents/agent-*.jsonl` model field).

## After you hand back
I scrub A4-opus → add it as a **5th output (label E)** to the blind `fable` scoring → recompute
the P6 table with both A4 cells (default mixed vs opus) side by side, and write up whether
fair-resourcing changes the verdict. *Prediction on record: still ties solo on quality (the
call is "50" regardless), costs more than the mixed run → loses the composite by a wider
margin, with no handicap excuse left.*
