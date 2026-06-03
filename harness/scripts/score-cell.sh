#!/usr/bin/env bash
#
# score-cell.sh — fire a fresh claude session to score a completed code-task cell
#
# Usage: score-cell.sh <task> <methodology> <run>
# Example: score-cell.sh t3-csv-openapi vibe 001
#
# What it does:
#   1. Validates the cell exists (cell dir + run dir + token-log filled)
#   2. Builds the scoring prompt (substitutes <TASK> / <METHODOLOGY> / <RUN>)
#   3. Launches `claude "<prompt>"` — a FRESH claude session, NOT the orchestrator.
#      The scoring runs in the current terminal as message 1.
#
# Why a fresh session: keeps the orchestrator (the harness CC session you build
# the eval in) blind to per-cell shipped code. When the hexad blind ≥2-rater
# pass runs later, the orchestrator hasn't read any of the bundles, so it can
# adjudicate cleanly.
#
# What it does NOT score: dims 1, 3, 4, 7, 8, 9 — per v0.3 blind-agents-primary
# (locked at T2 kickoff), those wait for the hexad blind pass on anonymized
# bundles. This script fills binary outcomes + defects + planning dims 10/11/12
# + T3's C-axis retention behavior.

set -euo pipefail

if [ $# -ne 3 ]; then
  echo "Usage: $0 <task> <methodology> <run>" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  $0 t3-csv-openapi vibe 001" >&2
  echo "  $0 t2-library-loans spec-kit 001" >&2
  echo "  $0 t1-postal-validator bmad 001" >&2
  exit 2
fi

TASK="$1"
METH="$2"
RUN="$3"

HARNESS="$HOME/dev/sdd-bench"

# Derive the per-task builds slug (t1 / t2 / t3, *-rich → t4rich)
case "$TASK" in
  t1-*)         SLUG=t1 ;;
  t2-*)         SLUG=t2 ;;
  t3-*)         SLUG=t3 ;;
  t4-fitness-app-rich) SLUG=t4rich ;;
  t4-*)         SLUG=t4 ;;
  t5-*)         SLUG=t5 ;;
  t6-*)         SLUG=t6 ;;
  *)            SLUG="$(echo "$TASK" | cut -d- -f1)" ;;
esac

CELL_DIR="$HOME/dev/sdd-private/sdd-bench-${SLUG}-builds/$METH"
RUN_DIR="$HARNESS/runs/$TASK/$METH/run-$RUN"
TOKEN_LOG="$RUN_DIR/token-log.md"

# --- Validate ---
if [ ! -d "$CELL_DIR" ]; then
  echo "ERROR: cell dir not found at $CELL_DIR" >&2
  echo "  Did the cell actually run? (run-cell.sh creates this dir)" >&2
  exit 1
fi

if [ ! -d "$RUN_DIR" ]; then
  echo "ERROR: run dir not found at $RUN_DIR" >&2
  exit 1
fi

if [ ! -f "$TOKEN_LOG" ]; then
  echo "ERROR: token-log.md not found at $TOKEN_LOG" >&2
  exit 1
fi

# Warn if token-log still has placeholder text (operator forgot to fill /status)
if grep -q "_fill in_" "$TOKEN_LOG" 2>/dev/null; then
  echo "WARN: $TOKEN_LOG still has '_fill in_' placeholders." >&2
  echo "      The scoring agent needs the cost + token counts to compute ratios." >&2
  echo "      Fill them from your /status capture before continuing." >&2
  echo "" >&2
  read -p "Continue anyway? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
fi

# --- Build the prompt ---
read -r -d '' PROMPT <<EOF || true
Score the completed sdd-bench code-task cell $TASK / $METH / run-$RUN.

This is a CODE TASK. The objective scorer is pytest, NOT idb. Do NOT spin up Expo, do NOT walk through any UI.

Paths:
- Cell dir:       $CELL_DIR/
- Run dir:        $RUN_DIR/
- Rubric:         $HARNESS/harness/scoring-rubric.md (v0.3)
- Task overlay:   $HARNESS/tasks/$TASK/success-criteria.md
- README guard:   $HARNESS/tasks/$TASK/README.md (silent-discriminator inventory)
- Full procedure: $HARNESS/harness/scoring-prompt-code-task.md

Follow the procedure in scoring-prompt-code-task.md step-by-step (1 through 14). Use TaskCreate to track.

Critical reminders:
- Do NOT score dims 1, 3, 4, 7, 8, 9 — leave them as \`TBD (blind)\` in observations.md. Those wait for the hexad blind ≥2-rater pass (v0.3 blind-agents-primary protocol locked at T2 kickoff).
- DO score planning dims 10, 11, 12 (single-rater by necessity; planning artifacts ARE the methodology tell). For Vibe specifically: no planning artifacts → score from code comments / README / commits (expect very low — that's the data point).
- DO classify the C-axis retention behavior for T3 (success-criteria.md §3): did the cell ask the PM? tag retention as an [ASSUMPTION]? mention it in README? silently pick a default? Cite evidence (grep results, session-log, pm-convo.md if any). (For T1/T2, skip this step — no C-axis.)
- token-log.md is already filled (cost + tokens + API time + LOC). Use those numbers for cost ratios.
- After completing, STOP and report a summary block. Do NOT commit. Operator reviews and commits.
- Do NOT update scoring-matrix.md, feature-matrix.md, or handoff.md yet — those wait until the full hexad is scored.
EOF

# --- Print info + launch ---
echo "================================================================"
echo " SCORING $TASK / $METH / run-$RUN (code task, fresh claude session)"
echo "================================================================"
echo " Cell dir: $CELL_DIR"
echo " Run dir:  $RUN_DIR"
echo ""
echo " About to launch \`claude\` in THIS terminal with the scoring prompt"
echo " as message 1. The session will:"
echo "   - run pytest in an isolated venv (.venv-score)"
echo "   - check the 5 binary outcomes (or 4 for T1/T2)"
echo "   - count defects from code review"
echo "   - score planning dims 10/11/12 + T3's C-axis retention behavior"
echo "   - fill test-result.md + observations.md (dims 10/11/12 only)"
echo "   - leave code-visible dims (1/3/4/7/8/9) as TBD for the blind pass"
echo ""
echo " Press Ctrl+C to abort, or:"
read -p " Press Enter to launch..."

exec claude "$PROMPT"
