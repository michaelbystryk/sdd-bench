#!/usr/bin/env python3
"""
parse-cell-transcript.py — Reconstruct a cell's session timeline from a
Claude Code JSONL transcript.

Usage:
    parse-cell-transcript.py --jsonl <path>                  # print to stdout
    parse-cell-transcript.py --jsonl <path> --out <path>     # write to file
    parse-cell-transcript.py --jsonl <path> --append <session-log.md>
        # appends a "## Reconstructed timeline" section to session-log.md

The script is methodology-agnostic. The Claude Code JSONL lives at:
    ~/.claude/projects/<cwd-mangled>/<session-uuid>.jsonl

The mangled cwd is the absolute path with '/' replaced by '-', so:
    ~/dev/sdd-bench-cells/t4-vibe-run-001
becomes:
    -Users-<user>-dev-sdd-bench-cells-t4-vibe-run-001

Find the most recent JSONL:
    ls -t ~/.claude/projects/-Users-<user>-dev-sdd-bench-cells-t4-vibe-run-001/*.jsonl | head -1

What's reconstructed:
    - Every user message (operator paste-back or initial brief paste)
    - Every assistant turn (text content, tool_use summaries, errors)
    - Timestamps in local time HH:MM:SS
    - Tool calls grouped (e.g., "[14:32:15] tools: Read × 3, Bash × 2")

What's NOT reconstructed (still requires the operator's manual log):
    - Stopwatch readings (active time, OP-touch time)
    - Intervention flags (you knew you intervened; the transcript shows
      a user message but not the *reason*)
    - Rate-limit pauses (transcript will show a gap; operator log
      explains it)
    - PM persona Q/A (lives in a separate claude.ai conversation;
      paste-save it separately)
"""

import argparse
import json
import sys
from datetime import datetime
from pathlib import Path


def parse_jsonl(path):
    """Yield turn records from the JSONL transcript."""
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            yield rec


def fmt_ts(iso):
    """Convert ISO 8601 to local HH:MM:SS."""
    if not iso:
        return "??:??:??"
    try:
        dt = datetime.fromisoformat(iso.replace("Z", "+00:00"))
        return dt.astimezone().strftime("%H:%M:%S")
    except Exception:
        return "??:??:??"


def extract_text_and_tools(content):
    """From a content field (string or list of blocks), return (text, tool_summary).

    text: the human-readable text portions joined with newlines.
    tool_summary: list of (tool_name, brief_input_preview) tuples.
    """
    texts = []
    tools = []

    if isinstance(content, str):
        return content, []

    if not isinstance(content, list):
        return "", []

    for block in content:
        if not isinstance(block, dict):
            continue
        btype = block.get("type")
        if btype == "text":
            texts.append(block.get("text", ""))
        elif btype == "tool_use":
            name = block.get("name", "?")
            inp = block.get("input", {})
            preview = ""
            if isinstance(inp, dict):
                # Heuristic: prefer 'command' (Bash), 'file_path' (Read/Write/Edit), 'pattern' (Grep)
                for key in ("command", "file_path", "pattern", "query", "description"):
                    if key in inp:
                        val = str(inp[key])
                        preview = val[:80] + ("…" if len(val) > 80 else "")
                        break
            tools.append((name, preview))
        elif btype == "tool_result":
            # Skip from operator log — usually noise
            pass
        elif btype == "thinking":
            # Skip thinking — internal, not operator-visible
            pass

    return "\n".join(t for t in texts if t.strip()), tools


def render_timeline(jsonl_path):
    """Walk the JSONL and produce a markdown timeline."""
    out = []
    out.append("")
    out.append("## Reconstructed timeline (auto-generated from CC transcript)")
    out.append("")
    out.append(f"Source: `{jsonl_path}`")
    out.append(f"Generated: {datetime.now().astimezone().strftime('%Y-%m-%d %H:%M:%S %Z')}")
    out.append("")
    out.append("Format: `[HH:MM:SS] role: content (or tool summary)`. Long content truncated to 500 chars; cross-ref the JSONL for full text. Thinking blocks and tool_results omitted (noise).")
    out.append("")

    first_ts = None
    last_ts = None
    user_count = 0
    assistant_count = 0
    tool_count = 0

    for rec in parse_jsonl(jsonl_path):
        rtype = rec.get("type")
        if rtype not in ("user", "assistant"):
            continue

        ts_iso = rec.get("timestamp", "")
        ts = fmt_ts(ts_iso)
        if first_ts is None:
            first_ts = ts_iso
        last_ts = ts_iso

        msg = rec.get("message", {})
        content = msg.get("content", "")
        text, tools = extract_text_and_tools(content)

        if rtype == "user":
            user_count += 1
            preview = text[:500].replace("\n", " ⏎ ").strip()
            if len(text) > 500:
                preview += "…"
            if preview:
                out.append(f"- `[{ts}]` **USER**: {preview}")
            else:
                out.append(f"- `[{ts}]` **USER**: (no text — likely tool result)")
        else:  # assistant
            assistant_count += 1
            # Emit text first (if any)
            if text.strip():
                preview = text[:500].replace("\n", " ⏎ ").strip()
                if len(text) > 500:
                    preview += "…"
                out.append(f"- `[{ts}]` **ASSISTANT**: {preview}")
            # Then summarize tools (if any)
            if tools:
                tool_count += len(tools)
                # Group by tool name
                by_name = {}
                for name, preview in tools:
                    by_name.setdefault(name, []).append(preview)
                parts = []
                for name, previews in by_name.items():
                    if len(previews) == 1 and previews[0]:
                        parts.append(f"{name}(`{previews[0]}`)")
                    else:
                        parts.append(f"{name} ×{len(previews)}")
                out.append(f"  - tools: {', '.join(parts)}")

    # Summary footer
    out.append("")
    out.append("### Transcript summary")
    out.append("")
    out.append(f"- First timestamp: `{fmt_ts(first_ts) if first_ts else 'n/a'}`")
    out.append(f"- Last timestamp:  `{fmt_ts(last_ts) if last_ts else 'n/a'}`")
    if first_ts and last_ts:
        try:
            dt1 = datetime.fromisoformat(first_ts.replace("Z", "+00:00"))
            dt2 = datetime.fromisoformat(last_ts.replace("Z", "+00:00"))
            delta = dt2 - dt1
            hours, remainder = divmod(int(delta.total_seconds()), 3600)
            minutes, seconds = divmod(remainder, 60)
            out.append(f"- Wall-clock span: **{hours}h {minutes}m {seconds}s** (transcript wall-clock — *disclosed context, not scored*; the scored time metric is **API compute time** from `/status`. For active time subtract rate-limit pauses noted in operator log)")
        except Exception:
            pass
    out.append(f"- User messages: {user_count}")
    out.append(f"- Assistant turns: {assistant_count}")
    out.append(f"- Tool calls: {tool_count}")
    out.append("")

    return "\n".join(out)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--jsonl", required=True, help="Path to Claude Code JSONL transcript")
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--out", help="Write the timeline to this file (overwrites)")
    g.add_argument("--append", help="Append the timeline as a section to this session-log.md")
    args = ap.parse_args()

    jsonl_path = Path(args.jsonl).expanduser().resolve()
    if not jsonl_path.exists():
        print(f"ERROR: JSONL not found: {jsonl_path}", file=sys.stderr)
        sys.exit(1)

    timeline = render_timeline(jsonl_path)

    if args.append:
        out_path = Path(args.append).expanduser().resolve()
        existing = out_path.read_text() if out_path.exists() else ""
        out_path.write_text(existing.rstrip() + "\n\n" + timeline + "\n")
        print(f"Appended reconstructed timeline to: {out_path}", file=sys.stderr)
    elif args.out:
        out_path = Path(args.out).expanduser().resolve()
        out_path.write_text(timeline)
        print(f"Wrote timeline to: {out_path}", file=sys.stderr)
    else:
        print(timeline)


if __name__ == "__main__":
    main()
