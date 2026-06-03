# T6 (OSS bug-fix) / AI-DLC / Run 001 / Session Log

**Methodology:** AI-DLC
**Task:** T6 (OSS bug-fix)
**Run:** 001
**Date:** _fill in YYYY-MM-DD_
**Operator:** —
**Underlying agent:** Claude Code
**Underlying model:** _note actual model + version at session start_
**Claude Code version (if applicable):** _from /status_
**Pro window started:** _HH:MM_
**Cell working directory:** `~/dev/sdd-bench-cells/bug-fix-ai-dlc-run-001`

---

## Manual event log (sparse — operator captures live; transcript fills the rest)

Format: `[HH:MM] <event>`. 24h local time.

```
[HH:MM] Session start. Brief pasted. Stopwatches started.
[HH:MM] OP intervention #1: <reason>
[HH:MM] Rate limit hit. Active stopwatch paused.
[HH:MM] Rate window reset. Resumed.
[HH:MM] Methodology declared done. Stopwatches stopped.
```

---

## Phase tracking (feeds methodology-overhead ratio)

Capture API compute time per phase. Feeds methodology-overhead ratio.

| Phase | API compute time |
|---|---|
| Requirements (EARS) |  |
| Design |  |
| Tasks |  |
| Implementation |  |

---

## Operator time + interventions

| Metric | Value |
|---|---|
| **API compute time (per /status — scored)** | _ h _ m |
| Total session wall-clock (context) | _ h _ m |
| Rate-limit pauses | _ min |
| Active session time (context) | _ h _ m |
| Operator-touch time | _ min |
| Operator intervention count | _ |
| Clarifying questions forwarded to PM | _ |

---

## End-of-cell condition

- [ ] Methodology declared work complete
- [ ] Operator detected stall (10 consecutive min, no progress)
- [ ] Phase failed 3x consecutively
- [ ] Rate limit interrupted session
- [ ] Other (specify)

## Operator notes

---

## Post-cell: reconstruct timeline from CC transcript (Vibe/Spec Kit/BMAD only)

```
python3 ~/dev/sdd-bench/harness/scripts/parse-cell-transcript.py \
  --jsonl $(ls -t ~/.claude/projects/-Users-<user>-dev-sdd-bench-cells-bug-fix-ai-dlc-run-001/*.jsonl | head -1) \
  --append ~/dev/sdd-bench/runs/t6-bug-fix/ai-dlc/run-001/session-log.md
```

---

## PM persona conversation (paste at end of cell)

```
(paste here, or save as artifacts/pm-convo.md and link)
```
