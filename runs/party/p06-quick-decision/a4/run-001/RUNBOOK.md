# P6 — A4 (BMAD Party Mode) / run-001 — OPERATOR RUNBOOK (manual)

A4 is the only P6 arm that runs as a **real interactive Claude Code session** (BMAD needs
the installed skill). You drive it; I (orchestrator) scrub + score afterward. Config of
record: `harness/party/arm-configs/a4-party-mode.md`. **A4 runs FIRST in the real ordering**
— its observed **Opus output-token count sets A2's thinking budget**. (I ran A1/A3 ahead of
it only to validate the apparatus; that doesn't touch A4 or A2.)

## Before you start
- Close other CC sessions (BMAD is interactive + gated — divided attention biases the run).
- Start at the top of a fresh Pro 5-hour window if you can (party mode can be token-heavy).

## Setup
```bash
# 1. Fresh, empty, BLIND external dir (no eval marker in the name).
mkdir -p ~/dev/sdd-private/orders-pagesize-a4 && cd ~/dev/sdd-private/orders-pagesize-a4

# 2. Seed the reference the brief points to (and nothing else).
mkdir -p reference
cp ~/dev/sdd-bench/tasks/party/p06-quick-decision/reference/situation.md reference/

# 3. Install BMAD interactively — defaults only: BMad Core + BMad Method (bmm),
#    no expansion packs, no customize.toml. (Pin/record the version it installs.)
npx bmad-method install
ls .claude/skills | grep bmad   # confirm bmad-party-mode is present

# 4. Launch CC pinned to the eval model.
claude --model claude-opus-4-8
```

## Run (neutral-operator rule — you are a wall, not a participant)
1. `/bmad-party-mode`
2. Paste the brief **verbatim** as the kickoff (clipboard):
   ```bash
   pbcopy < ~/dev/sdd-bench/tasks/party/p06-quick-decision/brief.md
   ```
3. **Only these operator messages are permitted** (log every one verbatim in session-log.md):
   - `continue` / `proceed`
   - if any agent asks a question: *"Use your judgment; make a reasonable assumption and tag it [ASSUMPTION]."*
   - when discussion has plainly converged or begun repeating, the locked closing line:
     *"Please wrap up and produce the deliverable specified in the brief as a standalone document."*
   - one permitted write-the-file nudge if it answers inline: *"Write the deliverable to decision.md as specified in the brief."*
   Anything beyond these **voids the cell.**
4. **Do not follow BMAD routing OUT to other workflows** (PRD/architecture/etc.) — decline with the closing line. This track tests party mode itself.
5. **Stop condition (hard cap):** if no deliverable after **3 "continue"s past the closing line**, end and score what exists. Note the cap + trigger in observations.md — a roundtable that can't land a doc is a finding.

## Capture at end of cell (BEFORE closing the session)
1. **`/status`** → paste the full block into `token-log.md` (cost source for A4). Record:
   - `Total cost` (implied USD), `Total duration (API)` (scored time),
   - per-model usage — and **the Opus `output` token count** (this sets A2's budget).
   - **Model check:** confirm the model line is `claude-opus-4-8`. If it drifted → void + rerun.
2. Save the deliverable: `cp decision.md ~/dev/sdd-bench/runs/party/p06-quick-decision/a4/run-001/artifacts/decision.md`
3. Save the roundtable working (needed for the genuine-disagreement observation, same as A3):
   ```bash
   # find the session JSONL for this cell dir and copy it
   SID_DIR=$(ls -dt ~/.claude/projects/*orders-pagesize-a4* | head -1)
   cp "$SID_DIR"/*.jsonl ~/dev/sdd-bench/runs/party/p06-quick-decision/a4/run-001/artifacts/transcript.jsonl
   ```
4. Save BMAD's planning artifacts if any (`_bmad-output/`) → `artifacts/planning/`.

## Observations to jot (observations.md / session-log.md)
- Which agents BMad Master convened + per-message participation.
- Genuine disagreement vs. polite convergence (mirror of A3 — A3's panel *did* genuinely disagree: e.g. the architect pushed back on "just default to max").
- Any fabrication / template-deviation (known upstream report: BMAD-METHOD #2280) — a finding, not a rerun trigger.
- Did it try to route out to PRD/architecture workflows?
- Operator-intervention count (continues + closing line + any question answers).

## After you hand back to me
I will: scrub A4's decision.md → Output label, run it through the blind `fable` scoring
workflow alongside A1/A3, **set A2's `MAX_THINKING_TOKENS` to A4's Opus output count** and
run A2 blind-headless, then re-randomize all four labels (A–D), do the final ≥2-rater blind
scoring, and compute the P6 cost-weighted composite for all four arms.
