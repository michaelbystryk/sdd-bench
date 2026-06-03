# PM Persona Conversation — t4-fitness-app-rich / ai-dlc / run-003

Auto-captured by `pm-ask` CLI. Each exchange logged with local timestamp.

Persona file: `harness/pm-persona-v1.md` (sha256 in README)
Task brief: `tasks/t4-fitness-app-rich/brief.md`
Reference: `tasks/t4-fitness-app-rich/reference/me.md`


## Q (2026-05-30 00:44:15 PDT)

The dev team has a few prioritization/scope decisions for the strength app build. Please pick an option (letter) for each and add one line of reasoning.

Q3 — If scope outruns the sprint, what's the bar for a complete deliverable? A) Depth-first: full core loop for 2-3 programs done correctly, rest scaffolded; B) Breadth-first: all 7 program engines correct + unit-tested first, some UI thinner; C) Balanced: all 7 engines + full core-loop UI, trim polish (Live Activity, charts) first.

Q4 — Canonical program sources for contested variants (nSuns, GZCLP)? A) You pick widely-accepted canonical source per program and document it; B) I'll provide sources; C) You pick for well-defined ones, ask me only about nSuns/GZCLP.

Q5 — May the team proceed with ALL brief §10 open assumptions as stated (lb-only/45lb bar, one active program with all seeded, warm-ups/assistance excluded from PRs, RPE optional, beginner→linear/intermediate→531-or-Madcow/advanced→nSuns-PPL recommendation, Live Activity iOS best-effort with local-notification floor, 6-day first-class, barbell+rack+bench only)? A) Yes proceed with all; B) Mostly, with changes I'll note.

Q6 — If programs must be prioritized, which ordering? A) Simplest-first: 5x5→5x3→GZCLP→Madcow→5/3/1→PPL→nSuns; B) Most-popular-first: 5/3/1→5x5→GZCLP→nSuns→PPL→Madcow→5x3; C) One representative per progression archetype first, then fill in.

Q7 — How far to take the iOS Live Activity in source (no build this sprint)? A) Scaffold config plugin + widget stub w/ TODOs + handoff note, don't wire end-to-end (in-app timer + local notification is the floor); B) Skip entirely, just in-app timer + local-notification floor, document as deferred; C) Fully author widget+plugin as if wired (can't verify).

### A

**Q3 — A.** The headline is the no-math core loop; one program that fully delivers it beats seven that half-work.

**Q4 — A.** You pick and document — I don't have those sources and don't need to approve them.

**Q5 — A.** Proceed with all as stated.

**Q6 — C.** One per archetype first lines up with depth-first and proves the engine model generalizes before you fill in.

**Q7 — A.** Scaffold with a handoff note — it's a best-effort bonus, so don't sink build time into it, but leave the door open.

---
