#!/usr/bin/env bash
# run-cell.sh — set up a methodology cell run: mkdir, install methodology
# deps, copy brief to clipboard, print launch instructions, wire pm-ask to
# this cell.
#
# Usage:
#   run-cell.sh <task> <methodology> <run-number>
#
# Examples:
#   run-cell.sh t4-fitness-app vibe 001
#   run-cell.sh t4-fitness-app vibe-planmode 001
#   run-cell.sh t4-fitness-app spec-kit 001
#   run-cell.sh t4-fitness-app bmad 001
#   run-cell.sh t4-fitness-app ai-dlc 001
#   run-cell.sh t6-bug-fix vibe 001
#
# Cell dir convention (per-task "builds" dir, one subfolder per methodology):
#   ~/dev/sdd-private/sdd-bench-<slug>-builds/<methodology>/
#   where <slug> is the task's first hyphen-separated segment (t1, t2, t4, t6).
#   run-001 uses the bare <methodology>/ subfolder (matches the published
#   sdd-bench-<slug>-builds evidence-repo layout); re-runs (run-NNN, NNN>001)
#   get <methodology>-run-NNN/ to avoid clobbering run-001.
#   EXCEPTION: *-rich tasks use slug `t4rich` (own builds dir; never collides
#   with t4-vague or the existing sdd-bench-t4-builds evidence repo).
#
# Does:
#   1. Validates task brief + run logbook dir exist
#   2. mkdirs the cell dir (warns if non-empty)
#   3. Runs methodology install (npx bmad-method install / specify init / nothing)
#   4. Seeds starter/ (tests + skeleton) and reference/ spec files into the cell,
#      for tasks that have them (T1/T2/T3 code tasks; T4 has neither)
#   5. Writes .pm-ask-cell so pm-ask auto-detects this cell
#   6. Copies brief.md (+ me.md if present) to clipboard / first message
#   7. Prints launch instructions; auto-launch methodologies start claude with
#      the brief as the first message
#
# Does NOT:
#   - Launch claude itself (operator does that — preserves interactive control)
#   - Forward questions / score / commit (operator-driven steps)

set -euo pipefail

usage() {
  sed -n '/^# /,/^$/p' "$0" | head -40 | sed 's/^# \?//'
  exit 1
}

[ $# -eq 3 ] || usage

TASK="$1"
METH="$2"
RUN="$3"

HARNESS="${SDD_BENCH_HARNESS:-$HOME/dev/sdd-bench}"
# Model pin: CC's built-in default lags new releases (Opus 4.8 released 2026-05-28
# but `claude` default was still 4.7 as of that date). Pin via --model so cells
# don't silently run on a stale model. Override per-run with SDD_BENCH_MODEL.
# Policy: latest Opus at hexad start (see analysis/handoff.md + memory).
MODEL="${SDD_BENCH_MODEL:-claude-opus-4-8}"
TASK_PREFIX="${TASK%%-*}"
BUILDS_SLUG="$TASK_PREFIX"
# *-rich tasks get their own slug so they never collide with t4-vague or the
# published sdd-bench-t4-builds evidence repo.
case "$TASK" in
  *-rich) BUILDS_SLUG="t4rich" ;;
esac
# Blindness fix (2026-05-28): cells launching into a shared parent with
# methodology-named subdirs leak the eval design — Vibe inferred "this is the
# vibe track of a benchmark" by listing the parent and seeing sibling
# methodology cells (esp. openspec/'s completed mobile/ build). Fix: per-task
# blind parent dirs with NO "sdd-bench" marker, plus a pre-launch archive step
# that moves all sibling cells out before the new one starts.
if [ -n "${SDD_BENCH_BUILDS_PARENT:-}" ]; then
  # Manual override: isolated parent dir for parallel-cell scenarios
  # (e.g., launching BMAD alongside an in-progress AI-DLC without crashing it
  # via auto-archive). Concurrent CC sessions remain a runbook fidelity caveat.
  BUILDS_PARENT="$SDD_BENCH_BUILDS_PARENT"
  ARCHIVE_PARENT="${SDD_BENCH_ARCHIVE_PARENT:-${BUILDS_PARENT}-archive}"
else
  case "$TASK" in
    t4-fitness-app-rich)
      # Neutral dir name (no eval marker) avoids blindness-leak in cell cwd; relocated under sdd-private (2026-06-01).
      BUILDS_PARENT="$HOME/dev/sdd-private/strength-app-builds"
      ARCHIVE_PARENT="$HOME/dev/sdd-private/strength-app-archive"
      ;;
    *)
      # Legacy layout for T1/T2/T3/T4-vague (already-completed evidence-repo paths).
      # Private build/evidence repos relocated under ~/dev/sdd-private/ (2026-06-01).
      BUILDS_PARENT="$HOME/dev/sdd-private/sdd-bench-${BUILDS_SLUG}-builds"
      ARCHIVE_PARENT="$HOME/dev/sdd-private/sdd-bench-${BUILDS_SLUG}-archive"
      ;;
  esac
fi
# run-001 → bare <methodology>/ (matches evidence-repo layout); re-runs get a suffix.
CELL_SUB="$METH"
[ "$RUN" != "001" ] && CELL_SUB="${METH}-run-${RUN}"
CELL_DIR="$BUILDS_PARENT/$CELL_SUB"
CELL_NAME="${BUILDS_SLUG}-${CELL_SUB}"
# Brief selection: defaults to brief.md; override via SDD_BENCH_BRIEF env var
# (e.g., SDD_BENCH_BRIEF=brief-no-runtime.md for run-002 no-runtime variant).
BRIEF_FILE="${SDD_BENCH_BRIEF:-brief.md}"
BRIEF="$HARNESS/tasks/$TASK/$BRIEF_FILE"
ME="$HARNESS/tasks/$TASK/reference/me.md"
RUN_DIR="$HARNESS/runs/$TASK/$METH/run-$RUN"

# Validate
if [ ! -f "$BRIEF" ]; then
  echo "ERROR: brief not found at $BRIEF" >&2
  echo "  (Is the task '$TASK' correct? Check tasks/ for valid task slugs.)" >&2
  exit 2
fi
if [ ! -d "$RUN_DIR" ]; then
  echo "ERROR: run logbook dir not found at $RUN_DIR" >&2
  echo "  (Was the run scaffolded? Expected: runs/$TASK/$METH/run-$RUN/)" >&2
  exit 2
fi

# Blindness: archive any prior sibling cell dirs so the new cell launches into
# an empty parent (Vibe leak fix, 2026-05-28). Moves completed cells from
# BUILDS_PARENT to ARCHIVE_PARENT before the new one is created. The current
# cell's own dir is skipped (re-running an existing cell should not move it).
mkdir -p "$BUILDS_PARENT" "$ARCHIVE_PARENT"
for dir in "$BUILDS_PARENT"/*/; do
  [ -d "$dir" ] || continue
  prior=$(basename "$dir")
  if [ "$prior" != "$CELL_SUB" ]; then
    mv "$dir" "$ARCHIVE_PARENT/" && \
      echo "✓ Archived prior cell: $prior → $ARCHIVE_PARENT/$prior (blindness: new cell launches into empty parent)"
  fi
done

# Cell dir setup
mkdir -p "$CELL_DIR"
cd "$CELL_DIR"

# Warn if non-empty (other than .pm-ask-cell which we'll overwrite)
non_pm_files=$(find . -mindepth 1 -maxdepth 1 -not -name '.pm-ask-cell' 2>/dev/null | wc -l | tr -d ' ')
if [ "$non_pm_files" -gt 0 ]; then
  echo "⚠ WARN: Cell dir is non-empty:"
  ls -la | head -10 | sed 's/^/    /'
  echo "  Continue setup anyway? [y/N]"
  read -r ans
  [ "${ans:-N}" = "y" ] || [ "${ans:-N}" = "Y" ] || { echo "Aborted."; exit 1; }
fi

# Methodology-specific install
echo ""
echo "=== Methodology setup ($METH) ==="
case "$METH" in
  vibe|vibe-planmode)
    echo "No methodology install needed for $METH."
    ;;
  spec-kit)
    if [ ! -d .specify ] && ! command -v specify >/dev/null 2>&1; then
      echo "ERROR: 'specify' CLI not found. Install Spec Kit first." >&2
      exit 3
    fi
    if [ ! -d .specify ]; then
      echo "Running: specify init . (may prompt interactively)"
      specify init . || { echo "WARN: specify init failed."; }
    else
      echo "Spec Kit already initialized in this dir."
    fi
    ;;
  openspec)
    if [ ! -d .opsx ] && [ ! -d .openspec ]; then
      echo "Running OpenSpec install per openspec.dev (verify command at run time)"
      echo "  Common install paths (try in order):"
      echo "    1) npx openspec init"
      echo "    2) npm install -g openspec && openspec init"
      echo "    3) See https://openspec.dev/ for current install instructions"
      echo ""
      echo "Operator: please run the correct OpenSpec install now, then continue."
      read -p "Press Enter when OpenSpec is installed in this dir... " _
    else
      echo "OpenSpec already initialized in this dir."
    fi
    ;;
  bmad)
    if [ ! -d _bmad ]; then
      echo "Running: npx bmad-method install"
      echo "Per harness/methodology-configs/bmad.md: select only BMad Core + BMad Method (default checked items)."
      npx bmad-method install
    else
      echo "BMAD already installed in this dir."
    fi
    ;;
  ai-dlc)
    # AI-DLC = rules in CLAUDE.md + .aidlc-rule-details/ (runs on Claude Code, not Kiro).
    # Expects the v0.1.8 release extracted at $AIDLC_SRC (default ~/Downloads/aidlc-rules).
    AIDLC_SRC="${AIDLC_SRC:-$HOME/Downloads/aidlc-rules}"
    if [ ! -f CLAUDE.md ] || ! grep -qi "ai-dlc\|aidlc" CLAUDE.md 2>/dev/null; then
      if [ -f "$AIDLC_SRC/aws-aidlc-rules/core-workflow.md" ]; then
        echo "Installing AI-DLC v0.1.8 rules from $AIDLC_SRC"
        cp "$AIDLC_SRC/aws-aidlc-rules/core-workflow.md" ./CLAUDE.md
        mkdir -p .aidlc-rule-details
        cp -R "$AIDLC_SRC/aws-aidlc-rule-details/"* .aidlc-rule-details/
        echo "✓ CLAUDE.md + .aidlc-rule-details/ installed. Verify with /config after launch."
      else
        echo "ERROR: AI-DLC v0.1.8 release not found at $AIDLC_SRC/aws-aidlc-rules/core-workflow.md" >&2
        echo "  Download the v0.1.8 release from awslabs/aidlc-workflows and extract so that" >&2
        echo "  \$AIDLC_SRC/aws-aidlc-rules/ + \$AIDLC_SRC/aws-aidlc-rule-details/ exist" >&2
        echo "  (or set AIDLC_SRC to wherever you extracted it). See methodology-configs/ai-dlc.md." >&2
        exit 3
      fi
    else
      echo "AI-DLC rules already present (CLAUDE.md)."
    fi
    ;;
  *)
    echo "WARN: unknown methodology '$METH'. No install run."
    ;;
esac

# Seed task inputs the methodology builds against (code tasks; T4 has neither).
#   starter/   → test suite + project skeleton, copied to the cell root (the
#                tests are the objective scorer; the methodology writes the impl).
#   reference/ → spec files the brief points to by path (e.g. formats.md). me.md
#                is personal context, pasted inline into the first message instead.
STARTER_DIR="$HARNESS/tasks/$TASK/starter"
REF_DIR="$HARNESS/tasks/$TASK/reference"
if [ -d "$STARTER_DIR" ]; then
  cp -R "$STARTER_DIR"/. "$CELL_DIR"/
  echo "✓ Seeded starter/ into the cell root (tests + skeleton)."
fi
if [ -d "$REF_DIR" ] && find "$REF_DIR" -type f ! -name 'me.md' | grep -q .; then
  mkdir -p "$CELL_DIR/reference"
  cp -R "$REF_DIR"/. "$CELL_DIR/reference/"
  rm -f "$CELL_DIR/reference/me.md"
  echo "✓ Seeded reference/ spec files into the cell."
fi

# Blindness fix (2026-05-28): pm-ask state lives OUTSIDE the cell working dir.
# Previously stored as $CELL_DIR/.pm-ask-cell, which the cell could read via
# `ls -la` + `cat`, directly leaking the methodology name. Now stored in
# ~/.cache/sdd-bench/active-cell — pm-ask reads from there.
PM_STATE_DIR="$HOME/.cache/sdd-bench"
mkdir -p "$PM_STATE_DIR"
echo "$TASK/$METH/$RUN" > "$PM_STATE_DIR/active-cell"
# Parallel-mode (custom BUILDS_PARENT): also write a per-cell cache file so
# multiple concurrent cells can each be addressed without racing on the global
# active-cell file. Operator must still use `pm-ask --cell <id> "..."` explicit
# in parallel mode (last cell to launch wins active-cell, so default-fallback
# is unreliable). Per-cell file is informational + backup.
if [ -n "${SDD_BENCH_BUILDS_PARENT:-}" ]; then
  echo "$TASK/$METH/$RUN" > "$PM_STATE_DIR/cell-${METH}-${RUN}"
  PARALLEL_NOTE='⚠ PARALLEL MODE detected (SDD_BENCH_BUILDS_PARENT is set). Multiple cells may be racing on ~/.cache/sdd-bench/active-cell. ALWAYS use pm-ask --cell '"$TASK/$METH/$RUN"' "..." explicitly when forwarding clarifying questions from THIS cell.'
else
  PARALLEL_NOTE=""
fi
echo ""
echo "✓ Wrote $PM_STATE_DIR/active-cell — pm-ask reads cell context from here (cell working dir is blind to methodology name)."
if [ -n "$PARALLEL_NOTE" ]; then
  echo ""
  echo "$PARALLEL_NOTE"
  echo ""
fi

# Build the first-message content for auto-launch (brief + me.md combined,
# optionally prefixed with a methodology-specific command like /specify)
BRIEF_CONTENT=$(cat "$BRIEF")
ME_CONTENT=$(cat "$ME" 2>/dev/null || echo "")

if [ -n "$ME_CONTENT" ]; then
  COMBINED_MSG="${BRIEF_CONTENT}

---

Reference (reference/me.md):

${ME_CONTENT}"
else
  COMBINED_MSG="$BRIEF_CONTENT"
fi

# Methodology-specific launch.
# LAUNCH_NOTE: optional instruction printed before launch (e.g. "paste the brief"
# when the brief is NOT auto-submitted as a positional arg).
LAUNCH_NOTE=""
case "$METH" in
  vibe)
    LAUNCH_CMD=(claude --model "$MODEL" "$COMBINED_MSG")
    LAUNCH_HUMAN="claude --model $MODEL \"<brief + me.md combined as first message>\""
    AUTO_LAUNCH=1
    ;;
  vibe-planmode)
    # Do NOT pass the brief as a positional arg: in CC 2.1.x,
    # `claude --permission-mode plan "<prompt>"` does NOT hold Plan Mode for that
    # first message (it processes the brief in default mode). Launch into the
    # Plan-Mode TUI empty; the operator pastes the brief (on the clipboard) so the
    # first message is processed in Plan Mode. Matches the proven T4 path
    # ("Plan Mode on. Brief pasted.").
    LAUNCH_CMD=(claude --model "$MODEL" --permission-mode plan)
    LAUNCH_HUMAN="claude --model $MODEL --permission-mode plan   (then paste the brief: Cmd+V + Enter)"
    LAUNCH_NOTE='Plan Mode TUI opens EMPTY and already in plan mode (footer shows "plan mode"). Paste the brief with Cmd+V — it is on your clipboard — then press Enter. That submits it as the first message, in Plan Mode.'
    AUTO_LAUNCH=1
    ;;
  spec-kit)
    # Spec Kit 0.8.13+ installs as CC skills with `speckit-` prefix
    # (not bare `/specify`). Canonical pipeline:
    #   /speckit-specify → /speckit-clarify → /speckit-plan
    #   → /speckit-tasks → /speckit-implement (and optional /speckit-analyze)
    SK_MSG="/speckit-specify ${COMBINED_MSG}"
    LAUNCH_CMD=(claude --model "$MODEL" "$SK_MSG")
    LAUNCH_HUMAN="claude --model $MODEL \"/speckit-specify <brief + me.md>\""
    AUTO_LAUNCH=1
    ;;
  openspec)
    # OpenSpec three-phase state machine: propose → apply → archive.
    # Installed slash commands (verified 2026-05-27 from ~/.claude/commands/opsx):
    #   /opsx:propose, /opsx:apply, /opsx:archive, /opsx:continue, /opsx:explore.
    # NOTE: it's /opsx:propose, NOT /opsx:proposal (the latter errors: "Unknown
    # command: /opsx:proposal. Did you mean /opsx:propose?").
    # Auto-launches with the propose phase fired against the brief.
    OS_MSG="/opsx:propose ${COMBINED_MSG}"
    LAUNCH_CMD=(claude --model "$MODEL" "$OS_MSG")
    LAUNCH_HUMAN="claude --model $MODEL \"/opsx:propose <brief + me.md>\""
    AUTO_LAUNCH=1
    ;;
  bmad)
    # BMAD's analyst invocation syntax depends on what its installer
    # printed. Don't auto-launch; print instructions instead.
    AUTO_LAUNCH=0
    ;;
  ai-dlc)
    # AWS activation phrase: "Using AI-DLC, <intent>". CLAUDE.md (installed above)
    # carries the workflow rules; this first message triggers the gated workflow.
    AIDLC_MSG="Using AI-DLC, ${COMBINED_MSG}"
    LAUNCH_CMD=(claude --model "$MODEL" "$AIDLC_MSG")
    LAUNCH_HUMAN="claude --model $MODEL \"Using AI-DLC, <brief + me.md>\""
    AUTO_LAUNCH=1
    ;;
  *)
    AUTO_LAUNCH=0
    ;;
esac

# Also copy brief to clipboard as a backup (in case operator wants it)
echo "$COMBINED_MSG" | pbcopy
echo "✓ Brief + me.md copied to clipboard (auto-launch sends them as the first message; Plan Mode opens empty — paste it, see the note below)."

echo ""
echo "=== During the cell ====================================="
echo "  Forward clarifying questions to PM persona:"
echo "    pm-ask 'verbatim question text'"
echo "  Save idb screenshots to:"
echo "    /tmp/$CELL_NAME-screens/"
echo "  Operator log:  $RUN_DIR/session-log.md  (sparse events only)"

echo ""
echo "=== When done ==========================================="
echo "  $HARNESS/harness/scripts/save-cell-artifacts.sh $TASK $METH $RUN"
echo "  (copies JSONL + appends reconstructed timeline + copies screenshots)"

echo ""
echo "Working dir:  $(pwd)"
echo "Run logbook:  $RUN_DIR"
echo "Cell name:    $CELL_NAME"

echo ""
echo "=== Launch =============================================="
if [ "$AUTO_LAUNCH" = "1" ]; then
  echo "Will run: $LAUNCH_HUMAN"
  if [ -n "$LAUNCH_NOTE" ]; then
    echo ""
    echo "  ⚠ $LAUNCH_NOTE"
  fi
  echo ""
  echo "▶ Press Enter to launch (start your stopwatches NOW); Ctrl+C to abort and launch manually..."
  read -r _
  exec "${LAUNCH_CMD[@]}"
else
  case "$METH" in
    bmad)
      echo "  BMAD just printed its analyst-invocation syntax (look up the scroll if you missed it)."
      echo "  Launch: claude --model $MODEL"
      echo "    → Invoke Analyst (Mary) per BMAD's instructions"
      echo "    → Cmd+V to paste brief + me.md (already in clipboard)"
      echo "    → Forward PM- and UX-shaped Qs via pm-ask"
      ;;
  esac
fi
