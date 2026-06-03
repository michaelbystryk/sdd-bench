#!/usr/bin/env bash
# score-cell-t4rich.sh — autonomous scoring harness for a T4-rich cell.
#
# Spawns a fresh Claude Code session with a full scoring prompt that tells
# the agent to: read context, run build sanity, drive idb walkthrough (run-001
# only), score 12 rubric dims, itemize defects, and fill the cell's
# observations.md + build-result.md.
#
# Usage:
#   harness/scripts/score-cell-t4rich.sh <methodology> <run>
#
# Examples:
#   harness/scripts/score-cell-t4rich.sh vibe 001        # run-001 = build sanity + idb walkthrough
#   harness/scripts/score-cell-t4rich.sh bmad 002        # run-002 = build sanity + source review only
#   harness/scripts/score-cell-t4rich.sh spec-kit 001    # special: domain-only, no idb
#
# Cell sources (consolidated 2026-06-01 to ~/dev/sdd-private/sdd-bench-t4rich-builds/run-NNN/<meth>/):
#   run-NNN (default):  run-<run>/<meth>/
#   run-001 bmad:       run-001/bmad/compound-app/   (app nested in compound-app/)
#
# Run-001 cells share the iOS sim → SERIAL.
# Run-002 cells are source-only build check → PARALLEL-SAFE (xcodebuild -sdk iphonesimulator
# compiles to disk without booting/installing on sim).

set -euo pipefail

# Ensure Maestro + Java in PATH (the agent inherits this env when claude is exec'd)
export PATH="/opt/homebrew/opt/openjdk@17/bin:$HOME/.maestro/bin:$PATH"

usage() {
  echo "Usage: $0 <methodology> <run>"
  echo ""
  echo "Examples:"
  echo "  $0 vibe 001"
  echo "  $0 spec-kit 001"
  echo "  $0 ai-dlc 002"
  echo "  $0 bmad 002"
  echo ""
  echo "Methodologies: vibe, vibe-planmode, openspec, spec-kit, ai-dlc, bmad"
  echo "Runs: 001, 002"
  exit 1
}

[ $# -eq 2 ] || usage

METH="$1"
RUN="$2"

HARNESS="${SDD_BENCH_HARNESS:-$HOME/dev/sdd-bench}"
TASK="t4-fitness-app-rich"
MODEL="${SDD_BENCH_MODEL:-claude-opus-4-8}"

# Validate methodology
case "$METH" in
  vibe|vibe-planmode|openspec|spec-kit|ai-dlc|bmad) ;;
  *) echo "ERROR: unknown methodology '$METH'" >&2; usage ;;
esac

# Validate run
case "$RUN" in
  001|002) ;;
  *) echo "ERROR: run must be 001 or 002 (got $RUN)" >&2; usage ;;
esac

# Resolve cell source per (meth, run). Cells were consolidated from the old scattered
# strength-app-* dirs into ~/dev/sdd-private/sdd-bench-t4rich-builds/run-NNN/<meth>/ (2026-06-01).
# Layout is now uniform; bmad's app is still nested in compound-app/ for run-001.
RICH_ROOT="${SDD_BENCH_BUILDS_REPO:-$HOME/dev/sdd-private/sdd-bench-t4rich-builds}"
if [ "$RUN" = "001" ] && [ "$METH" = "bmad" ]; then
  CELL_SOURCE="$RICH_ROOT/run-001/bmad/compound-app"
else
  CELL_SOURCE="$RICH_ROOT/run-$RUN/$METH"
fi

LOGBOOK="$HARNESS/runs/$TASK/$METH/run-$RUN"
COMPARATOR_RUN=$([ "$RUN" = "001" ] && echo "002" || echo "001")
COMPARATOR="$HARNESS/runs/$TASK/$METH/run-$COMPARATOR_RUN"

# SCREENSHOTS go straight into the PRIVATE builds repo (run-<run>/<meth>/screens/), NOT /tmp and
# NOT the public harness repo. The harness repo ($HARNESS) is public + text-reviewable; bulky binary
# PNGs (~19MB/cell × 12) belong in the private builds repo alongside the source trees. Writing here
# directly means no post-hoc move and nothing transient in /tmp (wiped on reboot).
BUILDS_REPO="$RICH_ROOT"
SCREENSHOTS="$BUILDS_REPO/run-$RUN/$METH/screens"

# Validate paths
[ -d "$CELL_SOURCE" ] || {
  echo "WARN: cell source not found at $CELL_SOURCE" >&2
  echo "      Scorer will note this as a fidelity issue and proceed." >&2
}
[ -d "$LOGBOOK" ] || {
  echo "ERROR: logbook not found at $LOGBOOK" >&2
  exit 1
}

mkdir -p "$SCREENSHOTS"

# Brief path differs for run-002
if [ "$RUN" = "002" ]; then
  BRIEF_FILE="$HARNESS/tasks/$TASK/brief-no-runtime.md"
else
  BRIEF_FILE="$HARNESS/tasks/$TASK/brief.md"
fi

# Build the scoring prompt
PROMPT_HEAD="You are an autonomous scoring agent for sdd-bench T4-rich run-${RUN} / ${METH}.

NOT a build/coding session — you are scoring what was already shipped by the cell. Be thorough, honest, and autonomous. The operator opened this session and walked away.

== Cell context ==
TASK:              ${TASK}
METHODOLOGY:       ${METH}
RUN:               ${RUN}
CELL SOURCE:       ${CELL_SOURCE}
LOGBOOK DIR:       ${LOGBOOK}
RUBRIC:            ${HARNESS}/harness/scoring-rubric.md
BRIEF:             ${BRIEF_FILE}
SUCCESS CRITERIA:  ${HARNESS}/tasks/${TASK}/success-criteria.md
COMPARATOR RUN:    ${COMPARATOR}  (use for paired-Δ analysis at the end)
SCREENSHOTS DIR:   ${SCREENSHOTS}

== Workflow ==

Step 1. READ CONTEXT: rubric, brief, success-criteria, this cell's session-log.md, token-log.md, and the comparator run's token-log.md.

Step 2. BUILD SANITY (uniform across all cells):
    cd ${CELL_SOURCE}
    npm install 2>&1 | tail -8
    npx expo prebuild --platform ios --clean 2>&1 | tail -10
    cd ios 2>/dev/null && pod install 2>&1 | tail -10 || echo 'no ios/ — prebuild failed or cell shipped domain-only'
    # FRESH-BUILD GUARANTEE: build into a CELL-LOCAL derivedDataPath (ios/build), wiped fresh by
    # 'prebuild --clean' each run. Step 3 finds the app HERE, not via a global DerivedData search —
    # a global 'find … | head -1' grabbed a stale sibling-run app (the vibe-002-scored-vibe-001 bug).
    rm -rf build 2>/dev/null || true
    xcodebuild -workspace *.xcworkspace -scheme \"\$(ls -d *.xcworkspace 2>/dev/null | sed 's/\\.xcworkspace//' | head -1)\" -configuration Debug -sdk iphonesimulator -derivedDataPath build build 2>&1 | tail -30 || true

    Record under ${LOGBOOK}/build-result.md 'Build sanity':
    - npm install exit code + warnings
    - expo prebuild exit code + whether ios/android dirs created
    - pod install exit code + Podfile.lock generated?
    - xcodebuild: BUILD SUCCEEDED or BUILD FAILED + first error line
    BUILD SUCCEEDED = green check on source-actually-compiles.
    BUILD FAILED = real defect; itemize."

# Shared Maestro walkthrough block — used for all cells EXCEPT spec-kit run-001
# (which shipped no Expo shell). Both run-001 and run-002 score with the same
# 14-binary-outcome walkthrough for apples-to-apples paired-Δ.
MAESTRO_WALKTHROUGH="
Step 4. MAESTRO WALKTHROUGH — 14 binary outcomes. **Use Maestro (\`maestro\`), NOT idb**. Maestro is installed at \`~/.maestro/bin/maestro\` (PATH exported by the wrapper script). Label-based tapOn + scrollUntilVisible + a11y matching — solves the occlusion + label-fragility issues idb had on prior cells.

    ⚠ LESSONS FROM PRIOR CELLS (don't repeat):
    1. **DO NOT FABRICATE tool output.** If an outcome was BLOCKED (Maestro couldn't find element, navigation failed, etc.), write 'code-verified: <evidence from source>' OR 'BLOCKED: <reason>' — NEVER 'verified via Maestro' unless Maestro's exit code was 0 AND screenshot confirms. Hallucinating tool output is the worst scoring failure.
    2. **Capture screenshots and verify post-tap state.** Maestro's \`takeScreenshot\` is the source of truth — your assertion that 'something changed' must be backed by a real before/after PNG pair.
    3. **Label/text matching** (Maestro's \`tapOn: text:\`), not coordinates. Maestro handles a11y matching natively + retries on flaky elements.
    4. **scrollUntilVisible** for occluded elements (the idb-failure mode Maestro solves).
    5. **DISMISS THE DEV-CLIENT \"Open?\" SYSTEM DIALOG (this is what got run-001 STUCK).** A dev-build deeplink pops a native \"Open in <app>?\" confirmation that the flow can hang on. Put this conditional **FIRST in every flow**, right after \`launchApp\`/deeplink — it auto-taps through when the dialog is present and is a harmless no-op when it's absent. The \`when: visible\` text is a regex substring, so \`'Open in'\` matches 'Open in \"Compound\"?', 'Open in \"ironclad\"?', etc. regardless of the per-cell app name:

    \`\`\`yaml
    - runFlow:
        when:
          visible: 'Open in'
        commands:
          - tapOn: 'Open'
    \`\`\`

    For each binary outcome, write a small YAML flow + run via \`maestro test\`. Pattern:

    \`\`\`bash
    BUNDLE=\$(plutil -extract CFBundleIdentifier raw \"\$APP/Info.plist\" 2>/dev/null)

    cat > /tmp/outcome-02-onboarding.yaml <<EOF
    appId: \$BUNDLE
    ---
    - launchApp:
        clearState: false
    - takeScreenshot: ${SCREENSHOTS}/02a-launch
    - assertVisible:
        text: '.*Beginner.*Intermediate.*Advanced.*'
    - tapOn:
        text: 'Beginner'
    - takeScreenshot: ${SCREENSHOTS}/02b-after-experience
    - assertVisible:
        text: '.*[0-9].*days'
    EOF
    maestro test /tmp/outcome-02-onboarding.yaml 2>&1 | tail -20
    \`\`\`

    Run \`maestro hierarchy\` to inspect what's on screen before authoring a flow.

    For occlusion (the 'Resume workout' button under tab bar that broke Vibe-001's idb run):
    \`\`\`yaml
    - scrollUntilVisible:
        element:
          text: 'Resume workout'
        direction: DOWN
    - tapOn:
        text: 'Resume workout'
    \`\`\`

    Maestro primitives:
    - \`maestro hierarchy\` — current screen's tree
    - \`maestro test <flow.yaml>\` — run a YAML flow
    - \`launchApp\` / \`stopApp\` / \`killApp\` / \`clearState\` — app lifecycle
    - \`tapOn\` / \`longPressOn\` / \`inputText\` — interaction
    - \`assertVisible\` / \`assertNotVisible\` — assertions
    - \`scrollUntilVisible\` / \`scroll\` — scrolling
    - \`takeScreenshot: <path>\` — capture
    - \`back\` / \`hideKeyboard\` — utility

    For EACH outcome: YAML → \`maestro test\` → exit code + screenshot → record PASS/FAIL/BLOCKED with evidence in build-result.md.

    01: app builds + runs (covered in step 3 — 01-launch.png)
    02: onboarding works — experience/days/goal/program-pick/starting-numbers
    03: four lifts present — Today screen shows squat/bench/OHP/deadlift
    04: today's workout on open — working weight AND per-side plate load visible
    05: 1-tap log — most-common log is single tap on prescription value
    06: plate calculator — per-side breakdown; respects bar weight + inventory
    07: rest timer — auto-starts on log, haptic invoked (check code; sim won't vibrate)
    08: backgrounded rest alert — verify local notification fires
    09: quick-switch survives — \`xcrun simctl terminate booted \$BUNDLE; xcrun simctl launch booted \$BUNDLE\`; in-progress set restored?
    10: warm-up ramp — first working set of a lift shows warm-up ramp before
    11: 7 programs canon — Settings/Switch Program; all 7 (5×5, 5×3, 5/3/1, Madcow, GZCLP, nSuns, Reddit PPL); each progresses per canon
    12: flexible scheduling — 3/4/5/6 day options
    13: history persists — terminate + relaunch; sets retained; History screen exists
    14: progress + PRs — log heavy set, PR detection surfaces; e1RM trend + volume charts

    For EACH outcome, record in ${LOGBOOK}/build-result.md: PASS / FAIL / N/A / BLOCKED + 1-line evidence + screenshot filename."

# Branch the workflow per run + methodology
if [ "$RUN" = "001" ] && [ "$METH" = "spec-kit" ]; then
  PROMPT_MID="
Step 3. SPEC KIT RUN-001 SPECIAL: cell shipped pure-domain only (no Expo shell). The build sanity will likely fail (no app/ dir, no full Expo project). Confirm:
    cd ${CELL_SOURCE}
    npm test 2>&1 | tail -20
    npx tsc --noEmit 2>&1 | tail -10

    Score binary outcomes:
    - #1, #4, #5, #7, #8, #9, #13, #14: FAIL (no app exists) with evidence 'methodology declared complete via /speckit-git-commit per documented refusal to write unverifiable Expo shell'
    - #2 (onboarding): FAIL (no UI shipped)
    - #3, #6, #10, #11: score against unit test output (domain logic exists)
    - #12: score against schedule logic in domain
    UI/UX dims (5/6): n/a — no UI to evaluate.
    NO idb walkthrough. NO sim install."
elif [ "$RUN" = "001" ]; then
  PROMPT_MID="
Step 3. INSTALL + LAUNCH ON SIM (iPhone 17 Pro / iOS 26.5):
    xcrun simctl list devices booted | head -5
    # FRESH-BUILD GUARANTEE: find the app in THIS cell's scoped derivedDataPath (ios/build) ONLY —
    # NOT a global DerivedData search. Global search grabbed a stale sibling-run app with the same
    # bundle id (vibe-001 & vibe-002 both = com.compound.strength → 002 scored 001's binary).
    APP=\$(ls -d ${CELL_SOURCE}/ios/build/Build/Products/Debug-iphonesimulator/*.app 2>/dev/null | head -1)
    echo \"Found .app: \$APP\"
    if [ -z \"\$APP\" ]; then echo 'ERROR: no freshly-built .app in cell-scoped ios/build — step-2 build did not produce one. DO NOT install/score a stale app; investigate the build failure first.'; fi
    BUNDLE=\$(plutil -extract CFBundleIdentifier raw \"\$APP/Info.plist\" 2>/dev/null)
    echo \"Bundle id: \$BUNDLE\"
    [ -n \"\$BUNDLE\" ] && xcrun simctl uninstall booted \"\$BUNDLE\" 2>/dev/null || true   # clear any stale install of the same bundle id before installing the fresh build
    [ -n \"\$APP\" ] && xcrun simctl install booted \"\$APP\" 2>&1
    [ -n \"\$BUNDLE\" ] && xcrun simctl launch booted \"\$BUNDLE\" 2>&1
    sleep 4
    xcrun simctl io booted screenshot ${SCREENSHOTS}/01-launch.png
${MAESTRO_WALKTHROUGH}"
else
  # run-002 (no-runtime variant) — but for scoring parity, we STILL build + install + Maestro-walkthrough.
  # The cell wasn't allowed to run during its session, but the source it shipped is real Expo source
  # that prebuild + xcodebuild can compile, and the operator wants apples-to-apples scoring with run-001.
  PROMPT_MID="
Step 3. INSTALL + LAUNCH ON SIM (run-002 — the cell shipped source-only by brief constraint, but we score it via the same full walkthrough as run-001 for apples-to-apples comparison):
    cd ${CELL_SOURCE}
    npm test 2>&1 | tail -10  # confirm tests still pass
    npx tsc --noEmit 2>&1 | tail -10  # confirm types clean
    # build was already done in step 2; proceed to install
    xcrun simctl list devices booted | head -5
    # FRESH-BUILD GUARANTEE: find the app in THIS cell's scoped derivedDataPath (ios/build) ONLY —
    # NOT a global DerivedData search. Global search grabbed a stale sibling-run app with the same
    # bundle id (vibe-001 & vibe-002 both = com.compound.strength → 002 scored 001's binary).
    APP=\$(ls -d ${CELL_SOURCE}/ios/build/Build/Products/Debug-iphonesimulator/*.app 2>/dev/null | head -1)
    echo \"Found .app: \$APP\"
    if [ -z \"\$APP\" ]; then echo 'ERROR: no freshly-built .app in cell-scoped ios/build — step-2 build did not produce one. DO NOT install/score a stale app; investigate the build failure first.'; fi
    BUNDLE=\$(plutil -extract CFBundleIdentifier raw \"\$APP/Info.plist\" 2>/dev/null)
    echo \"Bundle id: \$BUNDLE\"
    [ -n \"\$BUNDLE\" ] && xcrun simctl uninstall booted \"\$BUNDLE\" 2>/dev/null || true   # clear any stale install of the same bundle id before installing the fresh build
    [ -n \"\$APP\" ] && xcrun simctl install booted \"\$APP\" 2>&1
    [ -n \"\$BUNDLE\" ] && xcrun simctl launch booted \"\$BUNDLE\" 2>&1
    sleep 4
    xcrun simctl io booted screenshot ${SCREENSHOTS}/01-launch.png

NOTE: the cell wasn't allowed to run this app during its own session, so any runtime defects you find are honest discoveries — not 'the cell didn't try to fix this' (it couldn't). Record them as defects but contextualize them under the brief's no-runtime constraint.
${MAESTRO_WALKTHROUGH}"
fi

PROMPT_TAIL="
Step 5. SCORE 12 RUBRIC DIMS (0-5 each) in ${LOGBOOK}/observations.md (follow its existing template structure).
    **USE MULTI-AGENT FAN-OUT for the code-visible dims (workflow-style).** The sim walkthrough (Step 4) is serial, but reading source is not — spawn PARALLEL reader sub-agents over the cell source so each dim is grounded in file:line evidence, the way the vibe-001 pass did (it used 2 independent Explore reader agents). Recommended split:
      - Reader A → domain/engine/db: Code quality (3), System design (4), Correctness latent defects (2), Security (8)
      - Reader B → UI/screens/components: UI design (5), UX (6), Robustness (7), delight
      - Reader C → planning artifacts (.specify/ / openspec/ / aidlc-docs/ / _bmad-output/ / Plan Mode plan): Spec (10), Scope (11), Assumptions (12), Documentation (9)
    Use the Workflow tool (parallel/pipeline) if it fits, or simply launch the readers concurrently via the Agent tool in one message. Each reader returns file:line-anchored findings; YOU synthesize into the rubric scores. Do NOT let a reader invent sim/runtime results — code dims are code-evidenced, binary outcomes come from YOUR Step-4 walkthrough only.
    1. Functionality — driven by binary outcomes
    2. Correctness — see defect block
    3. Code quality — read 10-20 source files
    4. System design — data model, separation of concerns
    5. UI design — touch targets, layout density (run-002: score on CODE; spec-kit run-001: n/a)
    6. UX — sweaty-hands, 1-tap log, no-math
    7. Robustness — error handling, edge cases
    8. Security — local SQLite patterns
    9. Documentation — shipped README / CLAUDE.md, NOT planning artifacts
    10. Spec articulation — read planning artifacts (.specify/ / openspec/ / aidlc-docs/ / _bmad-output/ / Plan Mode plan file)
    11. Scope clarity — assumptions documented? scope decisions visible?
    12. Assumption surfacing — count + quality of [ASSUMPTION] tags or equivalent

Step 6. ITEMIZE DEFECTS (Critical / Major / Minor) with one-line evidence each. Compute defects-per-1KLOC.

Step 7. FILL observations.md fully:
    - **Record the scoring instrument: you are running as model \`${MODEL}\` — note 'Scored on: <date> · Scorer model: ${MODEL}' in the observations header** (scores are PROVISIONAL per rubric v0.3 until the blind ≥2-rater pass confirms within 1pt).
    - 12 dim scores + quality sum
    - Defect block
    - Binary outcomes (run-001) or design-verifiable outcomes (run-002)
    - Paired-Δ vs comparator run (cost, quality, LOC, key behavioral differences)
    - Headline finding (one paragraph)

Step 8. OUTPUT a one-paragraph headline verdict at end of final message. Include quality /60 (or /55 if UI+UX n/a), cost, binary count, paired-Δ vs comparator.

Do NOT make code changes to the cell source. You are SCORING, not building or fixing. If you find defects, itemize them; don't fix them.
Do NOT update scoring-matrix.md, feature-matrix.md, or handoff.md — those wait until the full task hexad is scored.
Do NOT commit anything. Operator will review + commit."

PROMPT="${PROMPT_HEAD}${PROMPT_MID}${PROMPT_TAIL}"

echo ""
echo "================================================================"
echo " SCORING ${METH} run-${RUN} (T4-rich, fresh claude session, model: ${MODEL})"
echo "================================================================"
echo " Cell source: ${CELL_SOURCE}"
echo " Logbook:     ${LOGBOOK}"
echo " Comparator:  ${COMPARATOR}"
echo " Screens:     ${SCREENSHOTS}"
echo ""
if [ "$METH" = "spec-kit" ] && [ "$RUN" = "001" ]; then
  echo " ⓘ Spec Kit run-001 shipped no Expo app — no sim needed. Source-only scoring (~10-15 min)."
else
  echo " ⚠ This cell uses the iOS simulator — SERIAL with other scoring sessions."
  echo "   (All 12 cells now use the same Maestro walkthrough flow for apples-to-apples paired-Δ.)"
fi
echo ""
echo " Press Enter to launch (start your stopwatch NOW); Ctrl+C to abort..."
read -r _

exec claude --model "$MODEL" "$PROMPT"
