#!/usr/bin/env bash
# save-cell-artifacts.sh — preserve a cell's transcript + screenshots into
# the repo's runs/.../artifacts/ folder, and reconstruct the session-log
# timeline from the Claude Code JSONL.
#
# Run at end of every cell. One command, idempotent (won't re-append if
# Reconstructed timeline section already exists).
#
# Usage:
#   harness/scripts/save-cell-artifacts.sh <task> <methodology> <run-number>
#
# Examples:
#   harness/scripts/save-cell-artifacts.sh t4-fitness-app vibe 001
#   harness/scripts/save-cell-artifacts.sh t4-fitness-app vibe-planmode 001
#   harness/scripts/save-cell-artifacts.sh t4-fitness-app bmad 001
#   harness/scripts/save-cell-artifacts.sh t6-bug-fix spec-kit 001
#
# Cell-directory naming convention this script assumes (must match run-cell.sh):
#   ~/dev/sdd-private/sdd-bench-<slug>-builds/<methodology>/         (run-001)
#   ~/dev/sdd-private/sdd-bench-<slug>-builds/<methodology>-run-NNN/ (re-runs)
# where <slug> is the task's first hyphen-separated segment (t1, t4, t6;
# *-rich tasks use slug `t4rich`).
#
# Steps performed:
#   1. Copy all *.jsonl from the cell's CC project dir into artifacts/
#   2. Run parse-cell-transcript.py on the most-recent JSONL, appending
#      a Reconstructed timeline section to session-log.md (skipped if
#      one already exists)
#   3. If /tmp/<cell-name>-screens/ exists, copy *.png to artifacts/screenshots/
#   4. Print final summary of saved files
#
# Does NOT handle (still manual):
#   - PM persona conversation paste (claude.ai → session-log.md)
#   - Cell working dir snapshot (skip — it's huge with node_modules)
#   - git add / commit

set -euo pipefail

usage() {
  sed -n '2,/^$/p' "$0" | sed 's/^# \?//'
  exit 1
}

[ $# -eq 3 ] || usage

TASK="$1"
METH="$2"
RUN="$3"

TASK_PREFIX="${TASK%%-*}"
BUILDS_SLUG="$TASK_PREFIX"
case "$TASK" in *-rich) BUILDS_SLUG="t4rich" ;; esac
# Per-task blind parent dirs (must match run-cell.sh layout — blindness fix 2026-05-28).
# SDD_BENCH_BUILDS_PARENT env var overrides for parallel-cell scenarios.
if [ -n "${SDD_BENCH_BUILDS_PARENT:-}" ]; then
  BUILDS_PARENT="$SDD_BENCH_BUILDS_PARENT"
  ARCHIVE_PARENT="${SDD_BENCH_ARCHIVE_PARENT:-${BUILDS_PARENT}-archive}"
else
  case "$TASK" in
    t4-fitness-app-rich)
      # Neutral dir name (no eval marker) avoids blindness-leak in cell cwd; relocated under sdd-private (2026-06-01).
      BUILDS_PARENT="${HOME}/dev/sdd-private/strength-app-builds"
      ARCHIVE_PARENT="${HOME}/dev/sdd-private/strength-app-archive"
      ;;
    *)
      # Private build/evidence repos relocated under ~/dev/sdd-private/ (2026-06-01).
      BUILDS_PARENT="${HOME}/dev/sdd-private/sdd-bench-${BUILDS_SLUG}-builds"
      ARCHIVE_PARENT="${HOME}/dev/sdd-private/sdd-bench-${BUILDS_SLUG}-archive"
      ;;
  esac
fi
CELL_SUB="$METH"
[ "$RUN" != "001" ] && CELL_SUB="${METH}-run-${RUN}"
# Launch path — where the cell was when CC started writing the project dir.
# Always the builds parent, even if the cell has since been auto-archived by a
# later run-cell.sh invocation. CC's project dir naming reflects the launch
# path, not the cell's current location.
LAUNCH_DIR="${BUILDS_PARENT}/${CELL_SUB}"
CC_PROJ="${HOME}/.claude/projects/$(printf '%s' "$LAUNCH_DIR" | sed 's#/#-#g')"
# Cell dir reference — current location (builds if not yet archived, else archive).
CELL_DIR="$LAUNCH_DIR"
[ ! -d "$CELL_DIR" ] && [ -d "${ARCHIVE_PARENT}/${CELL_SUB}" ] && CELL_DIR="${ARCHIVE_PARENT}/${CELL_SUB}"
CELL_NAME="${BUILDS_SLUG}-${CELL_SUB}"
HARNESS_DIR="${HOME}/dev/sdd-bench"
RUN_DIR="${HARNESS_DIR}/runs/${TASK}/${METH}/run-${RUN}"
ARTIFACTS_DIR="${RUN_DIR}/artifacts"
SESSION_LOG="${RUN_DIR}/session-log.md"
SCREENS_TMP="/tmp/${CELL_NAME}-screens"
PARSER="${HARNESS_DIR}/harness/scripts/parse-cell-transcript.py"

echo "Saving artifacts for cell: ${CELL_NAME}"
echo "  CC project:        ${CC_PROJ}"
echo "  Run logbook dir:   ${RUN_DIR}"
echo "  Screenshots (tmp): ${SCREENS_TMP}"
echo ""

# Sanity: the run logbook must already exist
if [ ! -d "$RUN_DIR" ]; then
  echo "ERROR: run logbook directory not found: $RUN_DIR" >&2
  echo "Did you mean a different task/methodology/run? Check spelling." >&2
  exit 2
fi

mkdir -p "$ARTIFACTS_DIR"

# 1. JSONL copy — top-level session transcripts AND nested sub-agent transcripts
#    (CC writes Task/sub-agent sessions to <session-id>/subagents/agent-*.jsonl;
#    a flat `cp *.jsonl` misses them, losing the delegated work — e.g. Plan Mode
#    and BMAD spawn sub-agents). Preserve the <session>/subagents/ structure.
if [ -d "$CC_PROJ" ]; then
  cp "$CC_PROJ"/*.jsonl "$ARTIFACTS_DIR/" 2>/dev/null || true
  sub=0
  while IFS= read -r -d '' f; do
    rel="${f#"$CC_PROJ"/}"
    mkdir -p "$ARTIFACTS_DIR/$(dirname "$rel")"
    cp "$f" "$ARTIFACTS_DIR/$rel"
    sub=$((sub + 1))
  done < <(find "$CC_PROJ" -mindepth 2 -name '*.jsonl' -print0 2>/dev/null)
  top=$(find "$ARTIFACTS_DIR" -maxdepth 1 -name '*.jsonl' 2>/dev/null | wc -l | tr -d ' ')
  echo "[1/3] Copied $top top-level + $sub sub-agent JSONL file(s) to artifacts/"
else
  echo "[1/3] WARN: CC project dir not found at $CC_PROJ"
  echo "      (Was the cell run in ${CELL_DIR}? Check path.)"
fi

# 2. Reconstructed timeline
if [ -f "$SESSION_LOG" ] && [ -d "$CC_PROJ" ]; then
  latest_jsonl=$(ls -t "$CC_PROJ"/*.jsonl 2>/dev/null | head -1)
  if [ -n "$latest_jsonl" ]; then
    if grep -q "Reconstructed timeline" "$SESSION_LOG"; then
      echo "[2/3] SKIP: session-log.md already has Reconstructed timeline (delete the section to re-run)"
    else
      python3 "$PARSER" --jsonl "$latest_jsonl" --append "$SESSION_LOG"
      echo "[2/3] Reconstructed timeline appended to session-log.md (from $(basename "$latest_jsonl"))"
    fi
  fi
elif [ ! -f "$SESSION_LOG" ]; then
  echo "[2/3] WARN: session-log.md not found at $SESSION_LOG"
fi

# 3. Screenshots
if [ -d "$SCREENS_TMP" ]; then
  png_count=$(find "$SCREENS_TMP" -maxdepth 1 -name '*.png' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$png_count" -gt 0 ]; then
    mkdir -p "$ARTIFACTS_DIR/screenshots"
    cp "$SCREENS_TMP"/*.png "$ARTIFACTS_DIR/screenshots/"
    echo "[3/3] Copied $png_count screenshot(s) to artifacts/screenshots/"
  else
    echo "[3/3] No screenshots in $SCREENS_TMP"
  fi
else
  echo "[3/3] No /tmp/${CELL_NAME}-screens/ directory (skip if you didn't use idb)"
fi

# Summary
echo ""
echo "=== Final artifacts in ${ARTIFACTS_DIR} ==="
find "$ARTIFACTS_DIR" -type f 2>/dev/null | sort | sed "s|${ARTIFACTS_DIR}/|  |"

echo ""
echo "Still manual:"
echo "  - Save PM persona claude.ai conversation (paste into session-log.md's PM section, or save as artifacts/pm-convo.md)"
echo "  - git add + commit"
