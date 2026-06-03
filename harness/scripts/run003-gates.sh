#!/usr/bin/env bash
# Run objective gates (tsc + tests) for the 6 T4-rich run-003 cells.
# No-runtime scoring: tsc --noEmit + the cell's own test suite. Captures results
# to /tmp/run003-gates/<meth>.txt for the scoring pass. Read-only verification.
set +e
OUT=/tmp/run003-gates
mkdir -p "$OUT"
for M in vibe vibe-planmode spec-kit openspec ai-dlc bmad; do
  # run-003 cells consolidated to sdd-private/sdd-bench-t4rich-builds/run-003/<meth>/ (2026-06-01).
  # NOTE: node_modules were stripped during cleanup — run `npm install` per cell before re-running gates.
  CD=~/dev/sdd-private/sdd-bench-t4rich-builds/run-003/$M
  echo "========== $M ($CD) ==========" | tee "$OUT/$M.txt"
  [ -d "$CD" ] || { echo "NO CELL DIR" | tee -a "$OUT/$M.txt"; continue; }
  cd "$CD" || continue
  echo "--- tsc --noEmit ---" | tee -a "$OUT/$M.txt"
  npx --no-install tsc --noEmit > "$OUT/$M-tsc.log" 2>&1
  TSC=$?
  echo "tsc exit: $TSC ($([ $TSC -eq 0 ] && echo CLEAN || echo "ERRORS: $(grep -c 'error TS' "$OUT/$M-tsc.log")"))" | tee -a "$OUT/$M.txt"
  echo "--- npm test ---" | tee -a "$OUT/$M.txt"
  npm test --silent > "$OUT/$M-test.log" 2>&1
  TST=$?
  # Pull jest/vitest summary lines
  grep -iE "Tests:|Test Suites:|Tests \(|passed|failed|Test Files" "$OUT/$M-test.log" | tail -4 | tee -a "$OUT/$M.txt"
  echo "test exit: $TST" | tee -a "$OUT/$M.txt"
  echo "" | tee -a "$OUT/$M.txt"
done
echo "DONE — logs in $OUT/"
