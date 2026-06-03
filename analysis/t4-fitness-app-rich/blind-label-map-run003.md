# T4-rich run-003 (AUTOMATED ARM) — Blind Scoring Label Map

**⚠️ SPOILER. Do not read before blind scoring is complete.**

**Seed:** `20260601` · **Generated:** 2026-06-01 · **Scope:** run-003 automated-arm (no-runtime brief), 6 bundles, A–F.

Run-003 is the **automated arm** — all 6 cells driven headlessly (`claude -p`, no operator), no-runtime brief. This blind pass brings run-003 quality to the same standard as run-001/002 (the prior pass-1 was unblinded/single-rater PROVISIONAL — see `run-003-codebased-summary.md`).

| Blind label | Methodology | Source |
|---|---|---|
| Output A | spec-kit | strength-app-r003-spec-kit/spec-kit-run-003 |
| Output B | bmad | strength-app-r003-bmad/bmad-run-003 |
| Output C | vibe | strength-app-r003-vibe/vibe-run-003 |
| Output D | ai-dlc | strength-app-r003-ai-dlc/ai-dlc-run-003 |
| Output E | openspec | strength-app-r003-openspec/openspec-run-003 |
| Output F | vibe-planmode | strength-app-r003-vibe-planmode/vibe-planmode-run-003 |

**Anonymization:** stripped planning/tell dirs (openspec/ .specify/ specs/ aidlc-docs/ .aidlc-rule-details/ _bmad-output/ ux-designs/ docs/ etc.), CLAUDE.md/AGENTS.md, build/dep/vcs noise + *.jsonl. Scrubbed in-code requirement-IDs (FR-N/Story/Epic/PRD/AR/NFR/UX-DR), epics.md refs, _bmad-output/aidlc-docs/ux-designs path refs, the operator first-name echo, README method-names, and package.json/app.json name+slug (output-F's was `vibe-planmode-run-003`). **Verified 0 word-boundary tells BEFORE raters launched** (lesson from run-002 staging where raters were launched then stopped on leaks). Each bundle = neutral BRIEF.md + code + tests.

**Method:** 8 code-visible dims, 2 fresh Sonnet raters/bundle (pass-1 REVIEW.md + pass-2 REVIEW-2.md, pass-2 blind to pass-1). Planning dims single-rater from un-anonymized artifacts. Workflow `wqcypqy6g`. Labels revealed only after both passes complete.
