# Operator Runbook

Step-by-step protocol for running a single sdd-bench cell.

> **Read this end-to-end the morning of a cell.** Don't improvise during a run — keep the runbook open.

A cell is: **one methodology × one task × one run**, scored against `harness/scoring-rubric.md` and the task's `success-criteria.md`. Same operator (you) runs every cell. PM persona answers product questions. Manual copy/paste between methodology + persona is the experimental control.

---

## TL;DR — the 3-command workflow

```
# 1. Set up the cell (mkdir, install, brief→clipboard, instructions)
~/dev/sdd-bench/harness/scripts/run-cell.sh <task> <methodology> <run>

# 2. During the cell, forward PM questions one command at a time
pm-ask "verbatim question text"

# 3. End of cell: save JSONL + screenshots + reconstruct timeline
~/dev/sdd-bench/harness/scripts/save-cell-artifacts.sh <task> <methodology> <run>
```

Example for T4 Spec Kit run 001:
```
~/dev/sdd-bench/harness/scripts/run-cell.sh t4-fitness-app spec-kit 001
pm-ask "Should the progress chart show single-rep max or top working set?"
~/dev/sdd-bench/harness/scripts/save-cell-artifacts.sh t4-fitness-app spec-kit 001
```

Read on for the full protocol — the scripts remove ceremony, but the operator judgment loop (start/stop stopwatches, log events, answer tooling Qs per config, score post-cell) stays manual.

---

## What you'll measure

Two parallel axes (per the rubric):

- **Quality axis** — filled in post-cell during scoring (12 dimensions + defect count + binary outcomes)
- **Cost axis** — captured during the cell (tokens + **API compute time** via `/status` — API compute time is the scored time metric; stopwatches give the disclosed-context wall-clock/active numbers; operator-touch + interventions in session-log)

Headline finding = the (Quality, Cost) pair.

---

## Pre-cell setup (~5 min with the launcher; ~15 min without)

### 1. Timing tools

Two simultaneous stopwatches. Easiest: **iPhone Stopwatch app** (multiple named timers in iOS 17+). Note: the **scored** time metric is **API compute time** read from `/status` at close — the stopwatches capture the disclosed-context wall-clock/active numbers and the operator-touch signal, not the scored figure.

| Stopwatch | Tracks | Run while | Pause when |
|---|---|---|---|
| **Total active** | Active session time (disclosed context) | Methodology is working | Rate-limit pause |
| **Operator touch** | Cumulative operator engagement | YOU are actively engaging (`pm-ask`, redirect, paste) | You go back to idle/waiting |

### 2. Pricing lookup (only if rates changed since last cell)

- Open https://anthropic.com/pricing
- Find current Claude Opus 4.7 rates: input / output / cache read / cache write per MTok
- token-log.md templates have rates pre-filled — only re-check if you suspect a change

### 3. Pro window + concurrent-session check

- Note when your last Pro 5-hour window started (use `/status` in any CC session to see)
- Ideal start: top of a fresh window
- **Concurrent CC sessions rule by methodology:**
  - **Vibe** — concurrent OK (methodology is autonomous; minimal operator engagement is methodologically consistent). Document any concurrent sessions in session-log.
  - **Vibe Plan Mode / Spec Kit / OpenSpec / BMAD / AI-DLC** — close all other CC sessions before starting. These have approval gates and frequent PM forwards. Divided attention biases operator-touch + intervention metrics.

### 4. PM channel — pick one (pm-ask recommended)

**Option A: `pm-ask` CLI (recommended, faster)**

`pm-ask` uses local `claude -p` with the locked persona prompt as `--system-prompt`, auto-detects the cell from `.pm-ask-cell` (written by `run-cell.sh`), auto-logs Q+A to `artifacts/pm-convo.md`. No window switching, no manual Project setup.

**One-time PATH setup** (so you can just type `pm-ask` instead of the full path):
```
ln -sf ~/dev/sdd-bench/harness/scripts/pm-ask ~/.local/bin/pm-ask
```

**Operational note:** Claude Code takes over the current terminal. To use `pm-ask` you need a SECOND terminal tab (Cmd+T in your terminal app). Or run pm-ask from any shell with `--cell` / `SDD_BENCH_CELL` override — see During the cell → Product/scope question section.

**Option B: claude.ai Project (web UI, fallback)**

If you prefer the web UI (or pm-ask errors), set up a claude.ai Project once per cell:
1. claude.ai → New Project, name `sdd-bench PM persona — <task>`
2. **Project instructions:** paste contents of `harness/pm-persona-v1.md`
3. **Project knowledge:** upload `tasks/<task>/brief.md` and `tasks/<task>/reference/*.md`
4. Start a new chat in the project — this is your PM channel for the entire cell
5. At end of cell, copy/paste the entire conversation into `runs/.../artifacts/pm-convo.md` (pm-ask saves this automatically; manual paste needed only for the fallback)

Either source is canonical — same persona prompt, same Opus 4.7 model.

### 5. Logbook files open in editor

For live note-taking (sparse manual events — transcripts fill the rest):

- `~/dev/sdd-bench/runs/<task>/<methodology>/run-NNN/session-log.md`
- `~/dev/sdd-bench/runs/<task>/<methodology>/run-NNN/token-log.md`
- `~/dev/sdd-bench/runs/<task>/<methodology>/run-NNN/build-result.md` (T4, T4-rich, T5 — Expo/build artifacts)
- `~/dev/sdd-bench/runs/<task>/<methodology>/run-NNN/test-result.md` (T1, T2, T3 — pytest is the objective scorer)
- `~/dev/sdd-bench/harness/methodology-configs/<methodology>.md` — quick reference for what's allowed/disallowed

---

## Starting the cell

### Step 1 — run the launcher

```
~/dev/sdd-bench/harness/scripts/run-cell.sh <task> <methodology> <run-number>
```

Examples:
- `run-cell.sh t4-fitness-app vibe 001`
- `run-cell.sh t4-fitness-app vibe-planmode 001`
- `run-cell.sh t4-fitness-app spec-kit 001`
- `run-cell.sh t4-fitness-app bmad 001`
- `run-cell.sh t6-bug-fix vibe 001`

What it does automatically:
- Validates task brief + run logbook exist
- mkdirs the cell dir `~/dev/sdd-bench-<slug>-builds/<methodology>/` (run-001; re-runs get `-run-NNN`). `<slug>` = task's first segment (t1, t2, t4, t6; `*-rich` → `t4rich`). Warns if non-empty.
- Runs methodology install if needed (`npx bmad-method install` / `specify init` / nothing for Vibe variants)
- **Seeds `starter/` (tests + skeleton) + `reference/` spec files into the cell** for code tasks (T1/T2/T3); T4 has neither (brief + me.md pasted inline instead)
- Writes `.pm-ask-cell` in the cell dir so `pm-ask` auto-detects this cell's context
- Copies brief.md content to clipboard
- Prints the methodology-specific launch command + paste instructions

What's still manual:
- You launch `claude` yourself per the printed instructions — preserves your interactive control of the session
- You paste the brief (Cmd+V) and the me.md reference

### Step 2 — let the launcher auto-launch (or launch manually per instructions)

The launcher AUTO-LAUNCHES claude with the brief + me.md pre-loaded as the first message for these methodologies:

| Methodology | Launcher behavior |
|---|---|
| **Vibe** | Auto-launches: `claude "<brief + me.md>"` — first message fires immediately on Enter |
| **Vibe Plan Mode** | Auto-launches `claude --permission-mode plan` **with no prompt** (opens empty, already in Plan Mode); you **paste** the brief (Cmd+V + Enter — it's on the clipboard) so message 1 lands in Plan Mode. ⚠️ Passing the brief as a positional arg (`claude --permission-mode plan "<brief>"`) does **not** hold Plan Mode for that first message in CC 2.1.x — that's why the launcher leaves the prompt empty. |
| **OpenSpec** | Auto-launches: `claude "/opsx:propose <brief + me.md>"` — command is `/opsx:propose` (verified 2026-05-27; **not** `/opsx:proposal`, which errors). Full set: `/opsx:propose` `/opsx:apply` `/opsx:archive` `/opsx:continue` `/opsx:explore`. |
| **Spec Kit** | Auto-launches: `claude "/speckit-specify <brief + me.md>"` — `/speckit-specify` fires with brief as arg immediately; you continue with `/speckit-clarify` / `/speckit-plan` / `/speckit-tasks` / `/speckit-implement` |
| **AI-DLC** | `claude` in a cell dir whose `CLAUDE.md` = AI-DLC core-workflow (+ `.aidlc-rule-details/`); first message `Using AI-DLC, <brief + me.md>`. Runs on Claude Code. |
| **BMAD** | Manual: `claude`, then invoke Analyst (Mary) per BMAD's install-output syntax → paste brief from clipboard (BMAD's analyst-invocation varies by install) |

For the auto-launch methodologies, the launcher prompts:
```
▶ Press Enter to launch (start your stopwatches NOW); Ctrl+C to abort and launch manually...
```

The brief + me.md is ALSO copied to your clipboard as a backup (in case you Ctrl+C and want to launch manually).

### Step 3 — universal start sequence (in the methodology session)

1. **Start both stopwatches the moment you hit Enter on the launcher's prompt.** That's when the methodology starts processing the brief.
2. Verify clean session — for CC-based methodologies: `/status` (after the first response) should show no prior context, no CLAUDE.md, current model.
3. Note in session-log: `[HH:MM] Session start. <Methodology> version <X.Y.Z>. Pro window started ~HH:MM. Brief + me.md auto-loaded as first message via run-cell.sh.`
4. **Step back. Let the methodology drive.** Don't suggest tools, libraries, phases, or sequencing.

---

## During the cell — handling questions

### Product/scope question from methodology

Anything about: scope, intent, priorities, user goals, UX, validation criteria, success metrics, feature decisions.

**Setup before the first question:** open a second terminal tab (Cmd+T) — CC has taken over the cell terminal. `cd` to the cell dir so pm-ask auto-detects via `.pm-ask-cell`. (Or set `SDD_BENCH_CELL` env var / use `--cell` flag — table below.)

**Per question:**

1. **Start "Operator touch" stopwatch**
2. Highlight question in methodology terminal, Cmd+C
3. Switch to pm-ask terminal tab:
   ```
   pm-ask "<paste the question>"
   ```
   Light cleaning OK: strip methodology-specific terminology (e.g., "Mary asks:" → just the question). Keep substance verbatim.
4. Response prints to stdout. Copy it.
5. Cmd+\` (or Cmd+Tab) → methodology terminal, Cmd+V, Enter
6. **Stop "Operator touch" stopwatch**, note increment
7. `pm-ask` auto-logs Q+A to `artifacts/pm-convo.md` with timestamp — no manual logging.
8. Quick one-liner in session-log.md:
    ```
    [HH:MM] Forwarded Q to PM via pm-ask, pasted response back. [OP touch: +Xm]
    ```

**Long questions via stdin heredoc:**
```
pm-ask <<'EOF'
We're considering adding a "skip workout" button. Should this:
1. Just move to next rotation slot without logging
2. Mark workout as skipped (visible in history)
3. Be cut entirely
EOF
```

**Cell override options** (when not in the cell dir):
| Mode | Example |
|---|---|
| In cell dir (auto-detect via `.pm-ask-cell`) | `cd ~/dev/sdd-bench-<slug>-builds/<methodology>; pm-ask "question"` |
| Env var (export once, reuse) | `export SDD_BENCH_CELL=t4-fitness-app/spec-kit/001; pm-ask "question"` |
| Flag (one-off) | `pm-ask --cell t4-fitness-app/spec-kit/001 "question"` |
| Single-call env | `SDD_BENCH_CELL=t4-fitness-app/spec-kit/001 pm-ask "question"` |

**Expected response shape** — the persona answers in 1-3 sentences, decisive, in character:
```
$ pm-ask "What's the priority — speed of logging vs. flexibility of editing past sets?"
Speed of logging. Editing past sets can be added later; it must not slow the live logging path.
```

**pm-ask behavior:**
- Uses local `claude -p` with the locked persona prompt as `--system-prompt`
- Persona's tokens go to a separate CC session_id → does NOT contaminate the cell's `/status` numbers
- Re-pipes prior conversation history each call so persona has within-cell context (matches the brief's "fresh persona session per cell" rule)
- Same model (Opus 4.7) and same persona text as the claude.ai workflow
- Help: just run `pm-ask` with no args

### Tooling/methodology question (operator-answered per config)

"Should I use TypeScript?" / "Expo Router or React Navigation?" / "Should I run /clarify next?" / "Fast vs Coaching working mode?" — these are operator-answered per the methodology config, NOT forwarded to PM.

- Read `harness/methodology-configs/<methodology>.md` and answer per the locked rules
- For Vibe: "anything Claude Code does by default: ALLOWED" — answer "use your default"
- For Spec Kit: follow canonical pipeline, don't skip phases
- For BMAD: pick the default-recommended option (e.g., "Fast" not "Coaching")
- For AI-DLC: artifacts in `aidlc-docs/` (see config)

Log in session-log:
```
[HH:MM] <Methodology> asked tooling Q: "<verbatim>"
[HH:MM] Operator answered per config: "<answer>".
```

**Don't count as an intervention.** Methodology-mode/tooling questions are baseline operator-touch for that methodology. Interventions = unplanned redirections only.

### Stall / failure / rate limit

| Condition | Action |
|---|---|
| 10 consecutive min, no progress | Log stall in session-log. Decide: wait, redirect, or end cell. |
| Phase failed 3x consecutively | Log. End cell (per all methodology configs). |
| Rate limit hit | Pause "Total active" stopwatch. Log pause start. Wait for window reset. Resume + restart stopwatch. Log resume. |
| You feel like intervening | Don't, unless config explicitly says to. The temptation IS the data — note in session-log without acting. |

---

## During the cell — periodic tracking

**Every ~30 min (cost tracking only):** `/status` in the methodology session → screenshot → save to `/tmp/<cell-name>-screens/status-<HH:MM>.png` (the save-cell-artifacts script picks them up at end of cell). Builds a token-over-time curve. `/status` is operator-local — its output is **not** sent to the model, so this is invisible to the cell. This cost snapshot is the *only* tracking you do inside the live session; everything evaluative happens after the cell ends.

**Phase inflections:** log when the methodology shifts modes:
- Planning → coding
- Coding → testing
- Testing → debugging
- Implementation → review (or QA approval, for BMAD)

For methodologies with explicit phases (Spec Kit / OpenSpec / AI-DLC / BMAD / Vibe Plan Mode), log each phase boundary timestamp. This feeds the methodology overhead ratio in scoring.

**idb walkthrough is a SCORING activity — do it AFTER the cell ends, never during** (T4/T4-rich/T5 only; code tasks T1/T2/T3 have no app to walk — they score via `pytest`). Driving the running app to verify/score outcomes belongs in the separate scoring block (§ Scoring), not the live session.

> **Blindness guardrail (load-bearing).** The cell must never observe anything that reveals it's a methodology being evaluated or scored. No scoring chatter in the session, no eval/harness language typed into it, no app walkthrough while it's still running. The brief + seeded files are already sanitized of eval framing (see each task's `README.md`); keep the *session* equally clean. Scoring is done later, blind, in a separate block.

Save walkthrough screenshots (captured during scoring) to `/tmp/<cell-name>-screens/`; the save-artifacts script copies them to `artifacts/screenshots/`.

---

## Ending the cell

**End trigger** (mark which in session-log):

- [ ] Methodology declared work complete
- [ ] Operator detected stall (10 consecutive min)
- [ ] Phase failed 3x consecutively
- [ ] Rate limit (un-waited-through)
- [ ] Other (specify)

### Closing sequence

1. **Stop both stopwatches.** Note final readings:
   - "Total active" → `Active session time` in token-log (disclosed context)
   - Sum of "Operator touch" increments → `Operator-touch time`
   - Count of `[OP intervention]` entries (NOT methodology-mode answers) → `Operator intervention count`
   - At `/status` (step 3), record **API compute time** → this is the scored time metric (not the stopwatch figures)
2. Log wall-clock end + summary:
   ```
   [HH:MM] <Methodology> declared done.
   Active: Xh Ym. OP touch: Xm. Interventions: N. Questions to PM: N.
   ```
3. `/status` final → **both** screenshot to `/tmp/<cell-name>-screens/status-final.png` **and paste the "Session" summary text into `token-log.md`** (the paste is grep-able + diff-able; the screenshot is the verification backstop). On the paste, the **`Total duration (API)` line is the scored API compute time**; `Total duration (wall)` is disclosed context. Capturing this live is **mandatory** — it is NOT reconstructable from the saved JSONL afterward (the transcript's `turn_duration` is *active* time = model + tools, not API compute). T4-AI-DLC lost its API figure exactly this way and could only be floored from the transcript.
4. Fill in `token-log.md`:
   - Raw counts from the `/status` paste/screenshot
   - **API compute time** = the `Total duration (API)` line (the scored time metric)
   - Cost calc using pre-filled rates: `(input/1M × 5) + (output/1M × 25) + (cache_read/1M × 0.50) + (cache_write/1M × 6.25)`
   - Time + intervention summary (cross-ref session-log)
5. **Run the objective scorer:**
   - **Code tasks (T1, T2, T3):** in the cell dir, run `pip install pytest && pytest -v`. Record the pass counts + the stdlib-only / no-new-deps check in `test-result.md`. Note time from session start → first green suite.
   - **Build-artifact tasks (T4, T4-rich, T5):** attempt the build in the cell dir (e.g., `npx expo start`); use idb to walk the binary outcomes (load via `xcrun simctl openurl booted "exp://localhost:8081"`; screenshot states; verify persistence via terminate+reopen). Note time from session start → first working build, and `expo start` → first usable UI. Log to `build-result.md`.
6. **Run save-cell-artifacts.sh:**
   ```
   ~/dev/sdd-bench/harness/scripts/save-cell-artifacts.sh <task> <methodology> <run>
   ```
   Does: copies cell's CC JSONL into artifacts/, runs parse-cell-transcript.py to append `## Reconstructed timeline` to session-log.md, copies idb screenshots from `/tmp/<cell-name>-screens/`. Idempotent.
   - **Verify the `.jsonl` actually landed:** `ls runs/<task>/<methodology>/run-NNN/artifacts/*.jsonl`. It's the recovery source for token counts (and the active-time backstop) if the `/status` paste is ever lost. T4-AI-DLC's transcript was missed here and had to be hand-recovered from `~/.claude/projects/` later — don't rely on that fallback existing.
7. **PM persona conversation:**
   - If you used `pm-ask`: already saved to `artifacts/pm-convo.md` automatically. Nothing to do.
   - If you used the claude.ai Project fallback: copy the conversation, paste into `artifacts/pm-convo.md`.
   - If the PM channel was never used (e.g., Vibe-pure asked zero questions): create `artifacts/pm-convo.md` with `(no PM exchanges — methodology asked zero clarifying questions)`.
8. **Save any methodology-produced planning artifacts** (BMAD's `_bmad-output/`, Spec Kit's `/specify` outputs, OpenSpec's `openspec/changes/`, AI-DLC's `aidlc-docs/`, etc.):
   ```
   cp -r ~/dev/sdd-bench-<slug>-builds/<methodology>/_bmad-output \
         ~/dev/sdd-bench/runs/<task>/<methodology>/run-<run>/artifacts/planning/
   ```
   (adjust path per methodology — save-cell-artifacts.sh doesn't handle these)
9. **Do NOT bulk-copy the cell working directory** (node_modules is hundreds of MB). The app source lives at `~/dev/sdd-bench-<slug>-builds/<methodology>/` on disk; that's the canonical artifact. Each task's `~/dev/sdd-bench-<slug>-builds/` doubles as the per-task public evidence repo (git-init it, `.gitignore` excludes `node_modules`/`.expo`/native dirs, then push — mirrors `sdd-bench-t4-builds`). If you need a clean tarball, exclude `node_modules`, `.expo`, `.git`.
10. `git add` + commit (the run-folder artifacts + any logbook changes). Close all windows. Step away.

---

## Scoring (next day OR delegated to a Claude Code session via idb walkthrough)

**Wait at minimum until a different focused block.** Same-day scoring biases — you'll over-credit effort or under-credit defects you watched yourself.

**Two scoring paths** depending on operator preference:

### Path A — Operator scores manually (gold standard)

Open observations.md + rubric + success-criteria side by side. Use the app for 5+ minutes as a real user. Score by hand. This is what caught BMAD's post-finish UX defect and the plate-calculator miss. Slower but most defensible.

### Path B — Operator delegates idb-driven scoring to a Claude Code harness session

Use the `harness/scoring-prompt.md` template — paste it into a harness CC session (the one you're working in for sdd-bench, NOT a cell session) with the cell name. The agent will:
1. Boot the cell's Expo bundler if not running
2. Drive Expo Go on iOS Sim via `idb` (commands documented below)
3. Walk through all 7 binary outcomes via `idb ui tap` + screenshots
4. Read planning artifacts and source code
5. Draft observations.md (quality dims + defects + cost ratios + headline)
6. Update scoring-matrix.md + feature-matrix.md + handoff doc
7. Stop and ask operator to review/adjust before commit

This is faster and worked well for T4-BMAD + T4-Spec Kit cells. **Caveat: still requires operator to use the app personally for 5+ minutes** — happy-path idb walkthroughs miss what user-perspective review catches (e.g., BMAD's "UI looked worse than Plan Mode" gestalt, plate calculator absence). Treat agent scoring as a strong first pass; the operator's lived review is the final layer.

### idb-driven walkthrough — canonical commands

When scoring an Expo cell (T4 / T4-rich / T5 if applicable), the iOS Sim walkthrough uses these idb commands. Companion needs to be running first:

```bash
export PATH=~/Library/Python/3.9/bin:/opt/homebrew/bin:$PATH
pgrep -f idb_companion >/dev/null || idb_companion --udid <SIM-UDID> > /tmp/idb-companion.log 2>&1 &
```

Find the simulator UDID once:
```bash
xcrun simctl list devices booted | grep -E 'Booted' | head -1
```

**Canonical walkthrough sequence for T4-class cells:**

```bash
mkdir -p /tmp/<cell-name>-screens
SCREENS=/tmp/<cell-name>-screens

# 1. Wipe Expo Go to force first-run flow
xcrun simctl terminate booted host.exp.Exponent
xcrun simctl uninstall booted host.exp.Exponent
APP=$(find ~/Library/Developer/CoreSimulator/Devices -name "Expo-Go-*.tar.app" -type d 2>/dev/null | head -1)
xcrun simctl install booted "$APP"

# 2. Open the cell's app via Expo dev URL (bundler must already be running)
xcrun simctl openurl booted "exp://localhost:8081"
sleep 12   # wait for bundle to load
xcrun simctl io booted screenshot $SCREENS/01-fresh-launch.png

# 3. Dump UI tree to find button coordinates (points, not pixels)
idb ui describe-all | python3 -c "
import sys,json
d=json.loads(sys.stdin.read())
def w(e):
    if not isinstance(e,dict):return
    label=e.get('AXLabel') or e.get('AXValue') or ''
    t=e.get('type','?')
    if t != 'Other' and (label.strip() or t in ('Button','TextField')):
        f=e.get('frame',{})
        x=int(f.get('x',0)+f.get('width',0)/2)
        y=int(f.get('y',0)+f.get('height',0)/2)
        print(f'{t}@({x},{y}) {label!r}')
    for c in e.get('children',[]):w(c)
w(d) if isinstance(d,dict) else [w(x) for x in d]
"

# 4. Tap UI elements by point coordinates
idb ui tap <x> <y>

# 5. Swipe to scroll
idb ui swipe <x1> <y1> <x2> <y2> --duration 0.3

# 6. Type into a TextField (after tapping it first)
idb ui tap <x> <y>; sleep 1; idb ui text "315"

# 7. Screenshot per significant state
xcrun simctl io booted screenshot $SCREENS/<NN-name>.png

# 8. After walkthrough: kill Expo Go + reopen to verify persistence
xcrun simctl terminate booted host.exp.Exponent
xcrun simctl openurl booted "exp://localhost:8081"
sleep 12
xcrun simctl io booted screenshot $SCREENS/NN-after-reopen.png
```

**Coordinates note:** idb uses POINTS (not pixels). iPhone 17 Pro = 402×874 pts. Tab bar at y=815-817 in points. Always re-`describe-all` after navigation since modal sheets / scroll position shift element positions.

**Companion troubleshooting:** if `idb ui tap` returns "Failed to connect to companion at address TCPAddress(host='localhost', port=10882)", the companion isn't running. Restart it per the export PATH + pgrep + idb_companion command above.

**Dev-build cells (T4-rich and any non-Expo-Go cell):** these don't load via Expo Go — the runtime *is* the app. Adjust the canonical sequence:
- **Skip the Expo Go wipe/install.** Build + install the dev build instead: `npx expo run:ios` (prebuilds + Xcode-builds + installs + launches into the booted sim), or install a prebuilt simulator `.app` from `eas build -p ios --profile development --local` (with `"ios": { "simulator": true }` in `eas.json`) via `xcrun simctl install booted <path>.app`.
- **Launch by bundle id, not an `exp://` URL:** `xcrun simctl launch booted <bundle.id>` (find it in `app.json` → `ios.bundleIdentifier`).
- **Persistence checks** terminate/relaunch the app's *own* bundle id (not `host.exp.Exponent`): `xcrun simctl terminate booted <bundle.id>` then `xcrun simctl launch booted <bundle.id>`.
- **Live Activity / Dynamic Island:** use a Pro-model sim (iPhone 17 Pro). Lock the sim (Hardware ▸ Lock) to see the lock-screen Live Activity; the Dynamic Island shows on the unlocked home screen. Screenshot both during an active rest timer.
- idb `ui describe-all` / `tap` / `swipe` / screenshots work identically once the app is foregrounded.
- ⚠️ `npx expo run:ios` needs Xcode + CocoaPods locally and takes **minutes** on first build (not the ~12s Expo Go bundle) — budget for it, and don't treat a slow first build as a failure.

### Manual scoring — when you do it yourself

There's a reusable evaluation prompt at `harness/scoring-prompt.md` you can paste into a fresh Claude Code session to do the scoring with full context handoff. Or score manually:

1. Open `runs/<task>/<methodology>/run-NNN/observations.md`
2. Open `harness/scoring-rubric.md` next to it
3. Open `tasks/<task>/success-criteria.md` next to it
4. **Exercise the artifact yourself.** Use the app for 5+ minutes as a real user — this catches what idb happy-path walkthroughs miss (caught the BMAD post-finish UX defect and the plate-calculator miss on T4).
5. Read planning artifacts the methodology produced — score Spec articulation, Scope clarity, Assumption surfacing.
6. Read the code — score Code quality, System design, Robustness, Security, Documentation.
7. Score UI design + UX (if applicable) by using the artifact as the intended user.
8. Fill in `# QUALITY AXIS` section (12 dims, 0.5 increments permitted per v0.1.2 changelog).
9. Fill in `# COST AXIS` section using token-log + session-log values, compute the 6 derived ratios.
10. Write the `# HEADLINE FINDING` one-liner covering BOTH axes.
11. Fill in scope-handling notes + failure-mode characterization free-form.
12. **Update `analysis/t<n>-<task>/scoring-matrix.md`** with this cell's scores. Replace this methodology's column's _TBD_ entries for ALL sections: 12 quality dims, defect counts (severity × source), binary outcomes (per success-criteria.md), cost axis (tokens / $ / time / interventions / questions / overhead-ratio), and the 6 derived ratios. Add the cell's headline-verdict row to the "Headline finding per cell" table. Re-bold any rows where this cell tied/beat the prior best. See the "How to extend this matrix" section at the bottom of the matrix doc.
13. **Update `analysis/t<n>-<task>/feature-matrix.md`** (separate file — features, not scores) with this cell's feature data (which features built / cut / missed). The matrix has placeholder columns for unscored methodologies; replace your column's *TBD* entries with ✅ / ⚪ / ❌ / 🚫 per its legend. If this completes the matrix (all 6 methodologies on a task), also update the headline-for-the-writeup paragraph.
14. **Update `analysis/handoff.md`** decisions log with: "Scored <cell>: Q <N>/55, $ <cost>, <one-line verdict>." If a sharp finding emerged that the rest of the eval should know about, add a section.
15. `git add` + commit observations.md + scoring-matrix + feature-matrix + handoff doc.

If a second reviewer is available: strip methodology label from the cell dir before sending, score independently, then unblind.

**Critical:** the operator's user-perspective hands-on review is what makes this eval defensible. The brief explicitly positions "blinded human review (stronger than LLM-as-judge for code quality)." Don't automate this step.

---

## Stopwatch quick reference

```
START OF CELL
   ┌──────────────────────────────────────────────┐
   │  run-cell.sh fires                           │
   │     ↓                                        │
   │  [HH:MM] paste brief into claude             │
   │     ↓                                        │
   │  ▶ START both stopwatches                    │
   │     ↓                                        │
   │  methodology works                           │
   │  (you wait, occasionally engage)             │
   │     ↓                                        │
   │  question arrives → ▶ start OP touch         │
   │                  → pm-ask "verbatim"         │
   │                  → paste response back       │
   │                  → ⏸ stop OP touch           │
   │                                              │
   │  rate limit → ⏸ pause Total active           │
   │            → wait for window reset           │
   │            → ▶ resume Total active           │
   │                                              │
   │  done → ⏹ stop both                          │
   │      → save-cell-artifacts.sh                │
   │      → record final readings in token-log    │
   └──────────────────────────────────────────────┘
END OF CELL
```

---

## Per-methodology variations

### Vibe
- No methodology install
- No explicit phases — log natural inflections
- `Methodology overhead ratio` reported as `n/a`
- End signal: Claude Code declares done
- Concurrent CC sessions OK (autonomous methodology)

### Vibe Plan Mode
- No methodology install
- Launcher runs `claude --permission-mode plan` with **no prompt** (TUI opens already in Plan Mode); you paste the brief (Cmd+V + Enter) so message 1 is processed in Plan Mode. Do NOT pass the brief as a positional arg — it won't hold Plan Mode for the first message (CC 2.1.x).
- Two-phase: Plan Mode (planning + revisions until approval) + Implementation (post-approval)
- Plan-approval taps are baseline operator-touch — NOT interventions
- Track plan revision count (low = converged easily; high > 2 = methodology struggled)
- End signal: Claude Code declares done
- Concurrent sessions NOT OK (approval gate divides attention)

### OpenSpec
- Install: per https://openspec.dev/ (run-cell.sh handles invocation; verify command at run-time — OpenSpec install commands may have evolved)
- Open-source, MIT-licensed, no API key / MCP server required
- Installs as CC skills (`.claude/skills/`)
- Three-phase state machine: **proposal → apply → archive**. Don't skip phases.
- Canonical slash commands (verified 2026-05-27 from `~/.claude/commands/opsx`): `/opsx:propose` → `/opsx:apply` → `/opsx:archive` (plus `/opsx:continue`, `/opsx:explore`). It's `/opsx:propose`, **not** `/opsx:proposal`.
- Proposal-phase clarifying questions forwarded to PM persona via `pm-ask`
- End signal: `/opsx:archive` completes for the proposal
- Concurrent sessions NOT OK
- **2026 context:** OpenSpec was ranked #1 in the April 2026 ranthebuilder.cloud independent eval (13 categories, single Python serverless backend, single reviewer). sdd-bench is cross-validating that ranking on a different task (T4 Expo fitness app) at higher rigor.

### Spec Kit
- Install: `specify init .` (run-cell.sh handles this)
- Spec Kit 0.8.13+ installs as CC **skills** in `.claude/skills/speckit-*` with the `speckit-` prefix
- Canonical pipeline: `/speckit-specify` → `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement` (and optionally `/speckit-analyze`)
- `/speckit-clarify` questions forwarded to PM persona via `pm-ask`
- Don't skip canonical pipeline phases
- End signal: `/speckit-implement` declares all tasks complete
- Concurrent sessions NOT OK
- **Gotcha (2026-05-26 cell):** earlier Spec Kit versions used bare `/specify`; 0.8.13 changed to `/speckit-specify`. If you see `Unknown command: /specify`, the slash command is `/speckit-specify`.

### AI-DLC
- Methodology, not a tool (awslabs/aidlc-workflows v0.1.8, MIT-0) — runs on **Claude Code**. Full config: `harness/methodology-configs/ai-dlc.md`.
- Install: download the v0.1.8 release; in the cell dir `cp aidlc-rules/aws-aidlc-rules/core-workflow.md ./CLAUDE.md` + `cp -R aidlc-rules/aws-aidlc-rule-details/* .aidlc-rule-details/`. Verify with `/config`.
- Kick off with `Using AI-DLC, <brief>`. Phases: Inception → Construction → Operations (Operations is a v0.1.8 placeholder — cell ends at Build-and-Test).
- **Most approval-gated methodology:** stops with "DO NOT PROCEED until user confirms" at nearly every stage — clear those as **baseline operator-touch** (NOT interventions); route genuine product/scope questions to the PM persona.
- Decline the opt-in extensions (security baseline, property-based testing) for baseline parity.
- Token measurement: same Claude Code `/status` capture as every other cell; model = `claude-opus-4-7`.
- Concurrent sessions NOT OK (dense approval gates + PM forwards).

### BMAD
- Install: `npx bmad-method install` (run-cell.sh handles this; you'll see the module-select prompt — pick BMad Core + BMad Method only, leave others unchecked)
- v6.8.0 installs as CC **skills** invoked as slash commands (`/bmad-agent-analyst`, `/bmad-create-prd`, `/bmad-quick-dev`, …), not a single orchestrator.
- **Policy: accept BMAD's own adaptive routing** (set 2026-05-27; matches AI-DLC). Let BMAD assess the task and pick its path — full lifecycle OR a `/bmad-quick-dev` one-shot for small work. Its right-sizing **is the finding, not a failure** — *provided the kickoff was neutral.* An operator-steered quick-dev (you nudged it to build) doesn't count → void + redo neutrally.
- **Kick off NEUTRALLY** so the path is BMAD's, not yours: **`/bmad-help` + paste brief** (the router — it assesses the task and recommends a path). ⚠ **Do NOT kick off with `/bmad-agent-analyst`** — it traps BMAD in the analyst persona, who then codes everything herself in one session (a lean, self-contained path that skips PRD/UX/architecture/epics ceremony). Confirmed on T4-rich run-003: the analyst kickoff produced a $22 lean build; the `/bmad-help` router produced the full lifecycle (17 planning artifacts, $32). Don't say "just build it" (→ quick-dev) and don't say "do every phase" (→ full ceremony). Follow `/bmad-help`'s recommended next step.
- Phase skills it may route through: `/bmad-product-brief` → `/bmad-create-prd` → `/bmad-agent-ux` → `/bmad-create-architecture` → `/bmad-create-epics-and-stories` → `/bmad-dev-story` → `/bmad-code-review`; or `/bmad-quick-dev`. (Mary ≈ Analyst, Paige/John ≈ PM, Sally ≈ UX, Winston ≈ Architect, James ≈ Dev, Linus ≈ QA.)
- **Record what BMAD routed to** (e.g. "analyst → quick-dev" vs full lifecycle) — the routing choice per task is a primary finding. Each phase boundary is worth timestamping.
- Token-heavy on the full path (T4-BMAD burned 47% of weekly quota — start at top of a fresh Pro window); on trivial tasks it may right-size and run cheap. **Don't read a low cost / quick-dev path as failure** — it's BMAD's routing choice.
- Forward BOTH PM-shaped AND UX-shaped questions to PM persona via `pm-ask` (v0.1; no separate UX persona)
- "Working mode" / "Coaching path" questions answered per config ("Fast path" default)
- End signal: BMAD declares the work complete (QA approval on the full path, or the build on quick-dev)
- Concurrent sessions NOT OK

---

## Automated arm (run-003+): headless cell driving

An **automated arm** runs the cells with **no human in the loop**: each cell is a real, blind, headless `claude -p` session driven by `harness/scripts/cell-headless.sh`, with the PM persona answering clarifying questions via `pm-ask`. The operator role is played by an orchestrating agent. **This arm is NOT directly comparable to the manual arms on operator-touch / intervention / wall-clock** — record it as a separate caveated arm (every run-003 logbook is stamped accordingly). First run: T4-rich run-003 (all 6 methodologies, 2026-05-30).

### Why it exists and what it is faithful to
- Faithful: real methodology tooling installed per-cell, real slash-command pipelines, blind cell dirs, the locked PM persona answering product questions, real cost from `claude -p --output-format json` (`total_cost_usd`, `duration_api_ms`, per-model `modelUsage`) — **cleaner and more reliable than `/status`**.
- Not faithful: no human operator (so no operator-touch/intervention signal), and the human-in-the-loop clarification rhythm is replaced by an agent operator. Use `brief-no-runtime.md` (source + tests only) — a headless cell can't faithfully do `expo run:ios`/sim, and no-runtime makes it comparable to run-002.

### The apparatus
- **`harness/scripts/cell-headless.sh`** — the single wrapper through which every permission-bypassing `claude -p` runs (so one scoped allow-rule covers it). Subcommands: `setup <task> <meth> <run>` (isolated per-cell parent `~/dev/strength-app-r<run>-<meth>/`, tooling install, blind `active-cell`, phase-1 prefix file), `drive` / `drive-plan` (plan mode) / `resume <sid>` (per-turn JSON saved to `runs/.../artifacts/turns/turn-NNN.json`, prints SESSION/IS_ERROR/RESULT so the operator can read + decide), `cost` (aggregates across turns).
- **Model/brief selection via cache-files**, NOT env vars: write `~/.cache/sdd-bench/model` (e.g. `claude-opus-4-8`) and `~/.cache/sdd-bench/brief` (e.g. `brief-no-runtime.md`). An env-var prefix (`SDD_BENCH_MODEL=… cell-headless.sh …`) would break the scoped Bash allow-rule, which keys on the command *starting with* the script path.
- **Permission grant (one-time, by the operator):** the auto-mode classifier hard-blocks an AI from self-authorizing `--dangerously-skip-permissions` or from editing settings to whitelist a bypass wrapper. The **operator** must add the allow-rules themselves (e.g. via `! python3 …` in-session or `/permissions`): `Bash(/Users/.../cell-headless.sh:*)` and `Bash(/Users/.../pm-ask:*)`.

### Driving each methodology (what worked)
- **vibe** — one `drive @phase1`; runs to completion in a single call. No phases.
- **vibe-planmode** — `drive-plan @phase1` (plan mode, read-only) → read plan → `resume <sid> "approved, implement"` (build mode). Two turns.
- **spec-kit** — `setup` runs `specify init . --here --integration claude --force --no-git` (the `--integration claude` is required — bare init defaults to Copilot/`.github`). Then `drive @phase1` (= `/speckit-specify`), `resume` through `/speckit-clarify` (forward its questions to `pm-ask`, resume with answers) → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`.
- **openspec** — `/opsx:*` are **global** commands (`~/.claude/commands/opsx/`); `setup` runs `openspec init . --tools claude --force`. Drive `/opsx:propose` → `/opsx:apply` → `/opsx:archive`.
- **ai-dlc** — rules copied from `$AIDLC_SRC`. Heavily gated: it writes a question file and waits. Read it, route product Qs to `pm-ask`, decline the Security + Property-Based-Testing extension opt-ins per config, fill the answer file, resume "done". Clear subsequent approval gates with "approve & continue".
- **bmad** — ⚠ **its TUI installer cannot run headless** (`npx bmad-method install --yes` still prompts for the install directory and hangs). Install by **copying a prior cell's `_bmad/` + `.claude/skills/bmad-*`** into the new cell. Kick off with **`/bmad-help` + brief** (the router — NOT `/bmad-agent-analyst`, which traps it in the analyst-codes-everything path; see the BMAD config note). Drive with **pure deferral** ("proceed with your recommended next step") — never steer toward "build"/"implementation" (that voids the run per the neutrality policy). Route product Qs to `pm-ask`; clear gates; let BMAD self-declare done.

### Gotchas (load-bearing)
- **The Workflow tool is the wrong vehicle for this.** A fan-out workflow with a `StructuredOutput` schema hard-fails the whole run if any operator-agent ends without emitting the schema, and **workflow subagents abandon the 40-min build phases** (they hit a turn/time budget mid-build). **Long build phases MUST run as main-thread background `claude -p` calls** (like a backgrounded `cell-headless.sh drive`). Use agents only for short, judgment-heavy planning/gate turns — or just drive from the main thread.
- **Rate limits** ("session limit · resets HH:MM") interrupt long concurrent builds even on upgraded plans. The errored turn still records its real spend in the turn JSON (and `cost` includes it). Resume the same `<sid>` after reset — no work lost.
- **`claude -p` JSON ≠ `/status` token labels** but carries everything needed: aggregate per-cell with `cell-headless.sh cost`.

## Revision history

The runbook evolves as cells teach us what's clunky. Changes should leave the protocol backwards-compatible (or call out the migration in `scoring-rubric-changelog.md`).

- **v0.1 — 2026-05-22** — Initial, pre-T4-Vibe.
- **v0.2 — 2026-05-26** — Added launcher automation (`run-cell.sh`, `pm-ask`, `save-cell-artifacts.sh`) after T4 matched triad complete. Workflow reduced to 3 commands; ~15-30 min of ceremony removed per cell. `pm-ask` CLI replaces claude.ai window-switching for PM persona (web UI now fallback). Vibe Plan Mode launch uses `claude --permission-mode plan` flag (no Shift+Tab needed). Concurrent-session rule refined per-methodology (Vibe OK; structured methodologies require single-session). Added explicit warning against bulk-copying cell working directory.
- **v0.3 — 2026-05-27** — Generalized the apparatus for code tasks (T1/T2/T3). Cell dirs moved from the single shared `~/dev/sdd-bench-cells/` to per-task `~/dev/sdd-bench-<slug>-builds/<methodology>/` (run-001 bare; re-runs `-run-NNN`); each per-task builds dir doubles as that task's public evidence repo (like `sdd-bench-t4-builds`). `run-cell.sh` now seeds `starter/` (tests + skeleton) + `reference/` spec files into the cell for tasks that have them. Code tasks score via `pytest` → `test-result.md` (the T1/T2/T3 analog of `build-result.md`); no idb walkthrough. Retired the legacy 2.5 GB `sdd-bench-cells/` scratch dir (T4 source preserved in the pushed `sdd-bench-t4-builds` repo). Sanitized T1 + T2 `brief.md` (and seeded reference/starter) of all eval/harness framing so a cell can't detect the evaluation — see each task's `README.md`.
- **v0.4 — 2026-05-27** — Plan Mode launch fix. `run-cell.sh` now launches `claude --permission-mode plan` with **no positional prompt** (operator pastes the clipboard brief as message 1) — passing the brief as a positional arg does NOT hold Plan Mode for the first message in CC 2.1.x, so the brief was being processed in default mode. Added a generic `LAUNCH_NOTE` mechanism to print per-methodology "paste the brief" instructions before launch.
- **v0.5 — 2026-05-30** — Added the **Automated arm (run-003+)** section + apparatus (`harness/scripts/cell-headless.sh`, `scaffold-run003.sh`). First automated arm: T4-rich run-003 (all 6 methodologies, headless `claude -p`, PM persona via `pm-ask`, cost from `claude -p` JSON). Key lessons captured: the Workflow tool is the wrong vehicle (StructuredOutput hard-fail + subagents abandon long builds → drive long builds from main-thread background); model/brief via cache-files not env-prefix (scoped allow-rule); BMAD's installer can't go headless (copy a prior install); Spec Kit needs `--integration claude`; OpenSpec `/opsx:*` are global; operator must self-add the bypass allow-rules (classifier blocks AI self-authorization). Automated arm is a **separate caveated arm** — not comparable to manual runs on operator-touch/intervention/wall-clock.

When you finish a cell and notice friction the runbook didn't anticipate, add a note and bump the version.
