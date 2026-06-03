#!/usr/bin/env bash
# cell-headless.sh — drive a methodology cell as an UNATTENDED headless
# `claude -p` session, for the automated-arm eval (run-003+).
#
# This is the automation analogue of run-cell.sh + the operator's live session.
# It is the SINGLE wrapper through which permission-bypassing `claude -p` runs,
# so it can be whitelisted with one scoped Bash allow-rule. Every cell runs in a
# fresh, blind, isolated dir; the cell never sees eval/harness framing.
#
# ⚠ Runs `claude -p --dangerously-skip-permissions` so the cell can build the
#   app autonomously (no human to approve file writes / npm / expo). Authorized
#   by the operator for the automated arm only. Cells run in
#   ~/dev/sdd-private/strength-app-builds/ (T4-rich; neutral name avoids eval-leak
#   in cell cwd) or ~/dev/sdd-private/sdd-bench-<slug>-builds/.
#
# Subcommands:
#   probe  <dir> <prompt>                       cheap headless smoke test in <dir>
#   setup  <task> <meth> <run>                  cell dir + tooling + active-cell (no claude)
#   drive  <task> <meth> <run> <prompt|@file>   start a fresh headless session
#   resume <task> <meth> <run> <sid> <prompt>   continue a session by id
#   cost   <task> <meth> <run>                  aggregate cost/tokens across turns
#
# drive/resume save each turn's full result JSON to
#   runs/<task>/<meth>/run-<run>/artifacts/turns/turn-NNN.json
# and print a compact summary (session_id, is_error, num_turns, RESULT text) so
# the orchestrating agent can read the cell's output and decide the next step
# (forward a clarifying question to pm-ask, fire the next phase, or stop).
#
# Model: pinned to claude-opus-4-8 (latest-Opus policy). Override SDD_BENCH_MODEL
# (e.g. claude-haiku-4-5 for cheap validation).

set -euo pipefail

HARNESS="${SDD_BENCH_HARNESS:-$HOME/dev/sdd-bench}"
CACHE="$HOME/.cache/sdd-bench"
mkdir -p "$CACHE"
# Model: env var > cache/model file > default. The cache-file path lets the
# orchestrator pick the model without an env-var prefix (which would break the
# scoped Bash allow-rule that keys on the command starting with this script path).
MODEL="${SDD_BENCH_MODEL:-$(cat "$CACHE/model" 2>/dev/null || echo claude-opus-4-8)}"

die() { echo "ERROR: $*" >&2; exit 2; }

# ---- path logic (mirrors run-cell.sh) ---------------------------------------
cell_paths() {
  local task="$1" meth="$2" run="$3"
  TASK_PREFIX="${task%%-*}"
  BUILDS_SLUG="$TASK_PREFIX"
  case "$task" in *-rich) BUILDS_SLUG="t4rich" ;; esac
  case "$task" in
    t4-fitness-app-rich)
      # Neutral dir name (no eval marker) avoids blindness-leak in cell cwd; relocated under sdd-private (2026-06-01).
      BUILDS_PARENT="$HOME/dev/sdd-private/strength-app-builds"
      ARCHIVE_PARENT="$HOME/dev/sdd-private/strength-app-archive" ;;
    *)
      # Private build/evidence repos relocated under ~/dev/sdd-private/ (2026-06-01).
      BUILDS_PARENT="$HOME/dev/sdd-private/sdd-bench-${BUILDS_SLUG}-builds"
      ARCHIVE_PARENT="$HOME/dev/sdd-private/sdd-bench-${BUILDS_SLUG}-archive" ;;
  esac
  [ -n "${SDD_BENCH_BUILDS_PARENT:-}" ] && BUILDS_PARENT="$SDD_BENCH_BUILDS_PARENT"
  CELL_SUB="$meth"; [ "$run" != "001" ] && CELL_SUB="${meth}-run-${run}"
  # Automated-arm isolation (run >= 003): each cell gets its own parent dir so
  # all cells coexist on disk for scoring (no sibling-archiving churn), matching
  # run-002's isolated-parent layout. Deterministic, so drive/resume/cost agree.
  case "$run" in
    001|002) : ;;
    *) BUILDS_PARENT="$HOME/dev/sdd-private/strength-app-r${run}-${meth}"
       ARCHIVE_PARENT="${BUILDS_PARENT}-archive" ;;
  esac
  CELL_DIR="$BUILDS_PARENT/$CELL_SUB"
  CELL_NAME="${BUILDS_SLUG}-${CELL_SUB}"
  RUN_DIR="$HARNESS/runs/$task/$meth/run-$run"
  TURNS_DIR="$RUN_DIR/artifacts/turns"
}

# ---- shared headless invocation ---------------------------------------------
# Runs claude -p in $CELL_DIR, appends result JSON to the turns dir, prints
# a compact summary. Args: <resume-sid-or-empty> <prompt>
run_turn() {
  local sid="$1" prompt="$2" mode="${3:-skip}"
  mkdir -p "$TURNS_DIR"
  local n; n=$(printf '%03d' "$(( $(ls "$TURNS_DIR"/turn-*.json 2>/dev/null | wc -l | tr -d ' ') + 1 ))")
  local out="$TURNS_DIR/turn-$n.json"
  local -a cmd=(claude -p --model "$MODEL" --output-format json)
  if [ "$mode" = "plan" ]; then
    cmd+=(--permission-mode plan)          # planning phase: read-only, no edits
  else
    cmd+=(--dangerously-skip-permissions)  # build phase: autonomous edits/bash
  fi
  [ -n "$sid" ] && cmd+=(--resume "$sid")
  ( cd "$CELL_DIR" && "${cmd[@]}" "$prompt" </dev/null ) > "$out" 2>"$out.err" || {
    echo "TURN_ERROR (exit $?). stderr:"; tail -5 "$out.err" >&2; }
  python3 - "$out" <<'PY'
import sys, json
try:
    d = json.load(open(sys.argv[1]))
except Exception as e:
    print("PARSE_FAIL", e); sys.exit(0)
print("SESSION:", d.get("session_id"))
print("IS_ERROR:", d.get("is_error"))
print("NUM_TURNS:", d.get("num_turns"))
print("API_MS:", d.get("duration_api_ms"))
print("COST_USD:", d.get("total_cost_usd"))
print("STOP:", d.get("stop_reason"))
print("---RESULT---")
print((d.get("result") or "")[:4000])
PY
  echo "TURN_JSON: $out"
}

cmd="${1:-}"; shift || true
case "$cmd" in
  probe)
    DIR="$1"; PROMPT="$2"
    mkdir -p "$DIR"
    ( cd "$DIR" && claude -p --model "$MODEL" --dangerously-skip-permissions \
        --output-format json "$PROMPT" </dev/null ) | python3 -c "
import sys,json
d=json.load(sys.stdin)
print('SESSION:',d.get('session_id'),'IS_ERROR:',d.get('is_error'),'NUM_TURNS:',d.get('num_turns'))
print('RESULT_HEAD:',(d.get('result') or '')[:800])
"
    ;;

  setup)
    TASK="$1"; METH="$2"; RUN="$3"
    cell_paths "$TASK" "$METH" "$RUN"
    # Brief: env var > cache/brief file > default (cache-file avoids an env-var
    # prefix that would break the scoped allow-rule).
    BRIEF_FILE="${SDD_BENCH_BRIEF:-$(cat "$CACHE/brief" 2>/dev/null || echo brief.md)}"
    BRIEF="$HARNESS/tasks/$TASK/$BRIEF_FILE"
    ME="$HARNESS/tasks/$TASK/reference/me.md"
    [ -f "$BRIEF" ] || die "brief not found: $BRIEF"
    [ -d "$RUN_DIR" ] || die "run logbook dir not found: $RUN_DIR"

    # Blindness: archive sibling cells so the parent holds only this cell.
    mkdir -p "$BUILDS_PARENT" "$ARCHIVE_PARENT"
    for dir in "$BUILDS_PARENT"/*/; do
      [ -d "$dir" ] || continue
      prior=$(basename "$dir")
      [ "$prior" = "$CELL_SUB" ] && continue
      mv "$dir" "$ARCHIVE_PARENT/" 2>/dev/null && echo "archived sibling: $prior"
    done
    mkdir -p "$CELL_DIR"

    # Methodology install (non-interactive).
    case "$METH" in
      vibe|vibe-planmode) : ;;
      spec-kit)
        if [ ! -d "$CELL_DIR/.specify" ]; then
          ( cd "$CELL_DIR" && specify init . --here --integration claude --force --no-git >/dev/null 2>&1 ) \
            || echo "WARN: specify init may have failed"
        fi ;;
      openspec)
        # /opsx:* commands are global (~/.claude/commands/opsx); init sets up the
        # project's openspec/ structure. Non-interactive: --tools claude --force.
        if [ ! -d "$CELL_DIR/openspec" ]; then
          ( cd "$CELL_DIR" && openspec init . --tools claude --force >/dev/null 2>&1 ) \
            || echo "WARN: openspec init may have failed"
        fi ;;
      ai-dlc)
        AIDLC_SRC="${AIDLC_SRC:-$HOME/Downloads/aidlc-rules}"
        if [ -f "$AIDLC_SRC/aws-aidlc-rules/core-workflow.md" ]; then
          cp "$AIDLC_SRC/aws-aidlc-rules/core-workflow.md" "$CELL_DIR/CLAUDE.md"
          mkdir -p "$CELL_DIR/.aidlc-rule-details"
          cp -R "$AIDLC_SRC/aws-aidlc-rule-details/"* "$CELL_DIR/.aidlc-rule-details/" 2>/dev/null || true
        else
          echo "WARN: AI-DLC rules not found at $AIDLC_SRC"
        fi ;;
      bmad)
        # Non-interactive: --yes + explicit modules (core=BMad Core, bmm=BMad
        # Method) + --tools claude. Matches the run-002 interactive selection.
        if [ ! -d "$CELL_DIR/_bmad" ]; then
          ( cd "$CELL_DIR" && npx -y bmad-method install --yes --modules core,bmm --tools claude >/dev/null 2>&1 ) \
            || echo "WARN: bmad install failed"
        fi ;;
    esac

    # Seed starter/reference if present (T4 has neither).
    if [ -d "$HARNESS/tasks/$TASK/starter" ]; then
      cp -R "$HARNESS/tasks/$TASK/starter/". "$CELL_DIR/"
    fi
    if [ -d "$HARNESS/tasks/$TASK/reference" ] && \
       find "$HARNESS/tasks/$TASK/reference" -type f ! -name me.md | grep -q .; then
      mkdir -p "$CELL_DIR/reference"
      cp -R "$HARNESS/tasks/$TASK/reference/". "$CELL_DIR/reference/"
      rm -f "$CELL_DIR/reference/me.md"
    fi

    # pm-ask state (outside cell dir — blindness).
    echo "$TASK/$METH/$RUN" > "$CACHE/active-cell"

    # Build combined kickoff (brief + me.md) OUTSIDE the cell dir.
    KICK="$CACHE/kickoff-$METH-$RUN.md"
    { cat "$BRIEF"; [ -f "$ME" ] && printf '\n\n---\n\nReference (reference/me.md):\n\n' && cat "$ME"; } > "$KICK"

    # Phase-1 prompt with the methodology's kickoff prefix (so `drive` can fire
    # the first phase directly). vibe-planmode/bmad are driven specially by the
    # orchestrator (plan-mode permission dance / analyst invocation).
    case "$METH" in
      spec-kit) PFX="/speckit-specify " ;;
      openspec) PFX="/opsx:propose " ;;
      ai-dlc)   PFX="Using AI-DLC, " ;;
      *)        PFX="" ;;
    esac
    KICK1="$CACHE/kick1-$METH-$RUN.md"
    { printf '%s' "$PFX"; cat "$KICK"; } > "$KICK1"

    echo "CELL_DIR=$CELL_DIR"
    echo "CELL_NAME=$CELL_NAME"
    echo "RUN_DIR=$RUN_DIR"
    echo "KICKOFF_FILE=$KICK"
    echo "PHASE1_FILE=$KICK1"
    echo "BRIEF_USED=$BRIEF_FILE"
    ;;

  drive)
    TASK="$1"; METH="$2"; RUN="$3"; P="$4"
    cell_paths "$TASK" "$METH" "$RUN"
    [ -d "$CELL_DIR" ] || die "cell dir missing — run setup first: $CELL_DIR"
    case "$P" in @*) PROMPT="$(cat "${P#@}")" ;; *) PROMPT="$P" ;; esac
    run_turn "" "$PROMPT"
    ;;

  drive-plan)
    # Plan-mode first turn (read-only) — for vibe-planmode's planning phase.
    TASK="$1"; METH="$2"; RUN="$3"; P="$4"
    cell_paths "$TASK" "$METH" "$RUN"
    [ -d "$CELL_DIR" ] || die "cell dir missing — run setup first: $CELL_DIR"
    case "$P" in @*) PROMPT="$(cat "${P#@}")" ;; *) PROMPT="$P" ;; esac
    run_turn "" "$PROMPT" plan
    ;;

  resume)
    TASK="$1"; METH="$2"; RUN="$3"; SID="$4"; P="$5"
    cell_paths "$TASK" "$METH" "$RUN"
    case "$P" in @*) PROMPT="$(cat "${P#@}")" ;; *) PROMPT="$P" ;; esac
    run_turn "$SID" "$PROMPT"
    ;;

  cost)
    TASK="$1"; METH="$2"; RUN="$3"
    cell_paths "$TASK" "$METH" "$RUN"
    python3 - "$TURNS_DIR" <<'PY'
import sys, glob, json, os
d = sys.argv[1]
files = sorted(glob.glob(os.path.join(d, "turn-*.json")))
tot_cost = 0.0; tot_api = 0; tot_turns = 0
models = {}
for f in files:
    try: j = json.load(open(f))
    except Exception: continue
    tot_cost += j.get("total_cost_usd") or 0
    tot_api  += j.get("duration_api_ms") or 0
    tot_turns += j.get("num_turns") or 0
    for m, u in (j.get("modelUsage") or {}).items():
        a = models.setdefault(m, dict(inp=0, out=0, cr=0, cw=0, cost=0.0, web=0))
        a["inp"]  += u.get("inputTokens", 0)
        a["out"]  += u.get("outputTokens", 0)
        a["cr"]   += u.get("cacheReadInputTokens", 0)
        a["cw"]   += u.get("cacheCreationInputTokens", 0)
        a["cost"] += u.get("costUSD", 0.0)
        a["web"]  += u.get("webSearchRequests", 0)
print(f"TURNS_FILES: {len(files)}")
print(f"TOTAL_COST_USD: {tot_cost:.4f}")
print(f"TOTAL_API_MS: {tot_api}  ({tot_api/1000/60:.1f} min)")
print(f"SUM_NUM_TURNS: {tot_turns}")
for m, a in sorted(models.items()):
    print(f"MODEL {m}: in={a['inp']} out={a['out']} cache_r={a['cr']} cache_w={a['cw']} web={a['web']} cost=${a['cost']:.4f}")
PY
    ;;

  *)
    sed -n '2,40p' "$0" | sed 's/^# \?//'
    exit 1 ;;
esac
