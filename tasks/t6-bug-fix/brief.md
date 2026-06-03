# T6 — OSS bug-fix brief (repo locked: tldraw/tldraw; issue TBD)

> 📋 **TEMPLATE — not yet locked or run** (scheduled v0.9). This is a forward-looking task stub; the operator/harness notes below are roadmap, not part of a cell-facing brief. No cell has been run against T6.

> **Status:** repo locked → **`tldraw/tldraw`** (decided 2026-05-25). Remaining for operator before lock: (1) pick a specific issue from tldraw's tracker, (2) pin the commit, (3) copy issue text to `reference/issue.md`, (4) copy `CONTRIBUTING.md` from the repo to `reference/`, (5) lock this brief by filling in `[ISSUE_NUMBER]` and `[COMMIT_SHA]` placeholders, then committing.

---

## Brief (to be locked once issue is picked)

> "Here's a fork of `tldraw/tldraw` (commit pinned to `[COMMIT_SHA]`). Fix issue `#[ISSUE_NUMBER]` — see `reference/issue.md`. Diagnose the root cause, produce a minimal fix, and add a regression test. Match the project's conventions, don't break existing tests. Produce a PR-ready branch with appropriate commits."

## Reference artifacts (populate before locking)

- `reference/issue.md` — full issue text, verbatim from the tracker (paste with URL + date captured)
- `reference/repo-pin.md` — commit SHA + clone URL + clone instructions
- `reference/CONTRIBUTING.md` — copy from target repo
- `reference/repo-style-notes.md` *(optional)* — any unusual conventions worth noting (e.g., "this project uses biome, not prettier")
- `tasks/t6-bug-fix/starter/task.md` — single-sentence brief seen by the methodology at start: "Fix this bug."

## What this task tests

**Diagnostic + surgical capability**, distinct from T5's *additive + planning-heavy* feature work. Same brownfield meta-skill (read + respect an existing codebase) but a fundamentally different operational mode:

- T5 requires *planning a feature* and *fitting it into existing structure*
- T6 requires *root-cause investigation*, *minimal-change discipline*, and *regression-test craftsmanship*

**Hypothesis:** SDD methodologies may *underperform* on T6. Their planning pipelines assume forward-design work, not investigation. Vibe may *win* on T6 because diving into the code beats planning a hypothetical fix.

## Repo + issue selection criteria

Use these criteria when picking:

**Repo criteria:**
- Mid-sized: ~50K–500K LOC total. Smaller than Vercel-tier huge; larger than a single utility.
- Active maintenance: commits in last 30 days; issues triaged regularly.
- Different stack from T5's Actual Budget (which is TS/Electron/RN) for breadth — or pick a different repo entirely.
- Has CONTRIBUTING.md describing PR conventions.
- Has a CI test suite the methodology can run locally.

**Issue criteria:**
- Reproducible: steps included, or reproducible from a brief read of the description.
- Real user impact: not a "good first issue" toy, not docs-only, not styling-only.
- Fix scope: 5–50 LOC of net change is the target. Reading ~100–500 LOC to localize.
- Has at least an implicit regression-test expectation (e.g., "this used to work in v1.2").
- Not currently being worked on by a maintainer (check for assigned PRs).

## Selected repo: tldraw/tldraw

Locked 2026-05-25. Rationale: focused canvas/whiteboard scope (~150K LOC), responsive maintainers, excellent test coverage → cleanest signal for methodology comparison without framework noise drowning the differences.

URL: https://github.com/tldraw/tldraw
Issue tracker: https://github.com/tldraw/tldraw/issues

**Repos considered but not selected** (preserved for v2.0 if T6 is expanded across multiple repos):
- `immich-app/immich` — TS/Node/Svelte, ~300K LOC, self-hostable. Better for "real-world feel" if v2.0 wants a backend-heavy variant.
- `cal.com` — TS/Next.js, modern stack. Better for industry relatability.
- Alternatives: `directus/directus`, `gin-gonic/gin`, `pocketbase/pocketbase`.

## Measurable outcomes (per scoring-rubric.md + T6-specific)

T6-specific binary outcomes — these are in addition to the 12 quality dimensions, captured in observations.md:

- [ ] Existing test suite still passes
- [ ] Regression test added that fails on the old code and passes on the new code
- [ ] Diff scope minimal: net LOC bounded; files-touched count bounded (oversized fixes to small bugs = failure mode worth scoring)
- [ ] Convention adherence: matches repo's existing style (linter passes, naming consistent, file organization matches)
- [ ] Root cause identified correctly in the methodology's planning artifacts (not just symptom-patched)
- [ ] PR-readiness: a maintainer would accept this with light-or-no review

Plus the standard rubric dimensions, with Scope clarity (dim 11) noted as **load-bearing** for T6 specifically — a methodology's diff minimality is a major signal on bug-fix tasks.

## Aspiration

Recruit a contributor of the chosen repo as a blind reviewer for T6. Match for stack expertise.

---

*Template v0.1 — locked structure. Specific repo + issue selection pending operator decision before v0.8 cell execution.*
