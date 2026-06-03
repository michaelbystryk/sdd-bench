#!/usr/bin/env bash
# Scaffold run-003 logbook dirs for the T4-rich AUTOMATED ARM (all 6 methodologies).
# run-003 is a no-human-in-the-loop headless replication (cell-headless.sh +
# claude -p). Marked throughout as NOT directly comparable to manual 001/002 on
# the cost/blindness axes. Brief variant: brief-no-runtime.md (source+tests only).
set -euo pipefail
HARNESS="${SDD_BENCH_HARNESS:-$HOME/dev/sdd-bench}"
TASK="t4-fitness-app-rich"
DATE="2026-05-29"

label_for() {
  case "$1" in
    vibe)          echo "Vibe Claude Code (vanilla, no methodology layer)" ;;
    vibe-planmode) echo "Vibe Plan Mode" ;;
    openspec)      echo "OpenSpec" ;;
    spec-kit)      echo "Spec Kit" ;;
    ai-dlc)        echo "AI-DLC" ;;
    bmad)          echo "BMAD" ;;
  esac
}

for METH in vibe vibe-planmode openspec spec-kit ai-dlc bmad; do
  DIR="$HARNESS/runs/$TASK/$METH/run-003"
  mkdir -p "$DIR/artifacts/turns"
  L="$(label_for "$METH")"

  cat > "$DIR/session-log.md" <<EOF
# T4-rich (PM-quality brief) / $L / Run 003 / Session Log

> ⚠ **AUTOMATED ARM — no human in the loop.** run-003 is a headless replication
> driven by \`harness/scripts/cell-headless.sh\` (\`claude -p --dangerously-skip-permissions\`),
> with clarifying questions answered by the locked PM persona via \`pm-ask\`.
> The operator role is played by an orchestrating agent, not a person. The cost
> axis is captured from \`claude -p --output-format json\` (\`total_cost_usd\`,
> \`duration_api_ms\`, per-model token usage), **not** from \`/status\`.
> **NOT directly comparable to the manual runs 001/002** on operator-touch,
> intervention, or wall-clock metrics. Treat as a separate automated arm.

**Methodology:** $L
**Task:** T4-rich · **Brief variant:** \`brief-no-runtime.md\` (source + tests only)
**Run:** 003 (automated)
**Date:** $DATE
**Operator:** orchestrating agent (supervising)
**Underlying model:** claude-opus-4-8 (pinned via --model)
**Cell working directory:** \`~/dev/sdd-private/strength-app-builds/<cell>\` (archived to \`~/dev/sdd-private/strength-app-archive/\` per blindness protocol)

---

## Automated event log

\`\`\`
(filled by the orchestrator: phase boundaries, pm-ask forwards, end trigger)
\`\`\`

## Phase tracking (feeds methodology-overhead ratio)

(filled by the orchestrator)

## Clarifying questions forwarded to PM persona

See \`artifacts/pm-convo.md\` (auto-captured by pm-ask). Count: _

## End-of-cell condition

- [ ] Methodology declared work complete
- [ ] Orchestrator detected stall
- [ ] Phase failed 3x consecutively
- [ ] Rate limit interrupted session
- [ ] Other

## Reconstructed timeline (auto-generated from CC transcript)

(appended by save-cell-artifacts.sh / parse-cell-transcript.py post-cell)
EOF

  cat > "$DIR/token-log.md" <<EOF
# T4-rich (PM-quality brief) / $L / Run 003 / Token Capture (AUTOMATED ARM)

> Captured from \`claude -p --output-format json\` per turn (aggregated by
> \`cell-headless.sh cost\`). NOT a \`/status\` capture — headless arm.

## Raw counts (aggregated across all headless turns)

| Metric | Value |
|---|---|
| Total API cost (sum total_cost_usd) | \$_ |
| API compute time (sum duration_api_ms) | _ |
| Opus input tokens | _ |
| Opus output tokens | _ |
| Opus cache-read tokens | _ |
| Opus cache-write tokens | _ |
| Web searches | _ |
| Headless turns (phases) | _ |

## Time + intervention summary

| Metric | Value |
|---|---|
| API compute time (scored) | _ |
| Operator-touch | n/a (automated arm — no human operator) |
| Operator interventions | n/a (automated arm) |
| Clarifying questions to PM | _ |
| LOC produced | _ |
| Sub-agents spawned | _ |

## Derived ratios (filled during scoring)

| Ratio | Value |
|---|---|
| Quality per 1K tokens | _ |
| Quality per API hour | _ |
| Defects per 1KLOC | _ |
| Methodology overhead ratio | _ |
| Cost per binary outcome | \$_ |
| Quality per dollar | _ |
EOF

  cat > "$DIR/build-result.md" <<EOF
# T4-rich (no-runtime) / $METH / Run 003 / Build Result (AUTOMATED ARM)

> **No-runtime variant.** Cell did NOT build or run the app. Verification is
> source-review + tests-only, consistent with run-002's no-runtime scoring lens.

## Design-verifiable outcomes (per \`brief-no-runtime.md\` §9)

### Domain logic (unit-testable, primary)
- [ ] All 7 programs prescribe + progress per pinned canon
- [ ] Plate calculator (per-side breakdown, respects bar weight + inventory)
- [ ] Warm-up ramp (auto-generated, excluded from PRs/progression)
- [ ] e1RM (Epley) + PR detection (weight / reps / e1RM, main working sets only)
- [ ] Auto-populate (today's set from last time)
- [ ] Workout advances on completion (not by calendar date)

### Code structure (source-reviewable, primary)
- [ ] Onboarding flow (§4a) screens + routing + state machine
- [ ] Today's workout screen + components wired to domain
- [ ] Set logging (1-tap common case visible in code)
- [ ] Rest timer (service/hook/component + intervals + haptic)
- [ ] Backgrounded rest (notification scheduling code)
- [ ] Quick-switch resilience (state hydration code paths)
- [ ] Live Activity (best-effort: stub/scaffold acceptable)
- [ ] History persistence (SQLite schema + migration + repo code)
- [ ] Progress / PR detection UI components

### Engineering hygiene (verifiable)
- [ ] \`tsc --noEmit\` clean
- [ ] \`npm test\` passes
- [ ] Non-goals honored (no auth/cloud/social/etc.)

### No-runtime constraint adherence
- [ ] Cell did NOT run native build / sim commands
- [ ] Cell wrote full UI code (components + screens), not just domain
- [ ] Cell's planning artifacts acknowledged the no-runtime scope

## Source listing

\`\`\`
(tree -L 3 -I 'node_modules|.expo|.git' — paste post-cell)
\`\`\`
EOF

  cat > "$DIR/observations.md" <<EOF
# T4-rich (PM-quality brief) / $L / Run 003 / Observations (AUTOMATED ARM)

**Reviewer:** _ (scored post-cell, blind) · **Scored on:** _ · **Evidence basis:** CODE-BASED (no-runtime)

> ⚠ **Automated arm.** Cell driven headlessly (no human in loop). Score the
> ARTIFACT on the same rubric, but record cost-axis comparisons against run-002
> with the automated-arm caveat (no operator-touch/intervention signal exists).

(QUALITY AXIS / DEFECTS / BINARY OUTCOMES / COST AXIS / HEADLINE — filled at scoring)
EOF

  echo "scaffolded run-003: $METH"
done
echo "DONE"
