# AI-DLC — sdd-bench Configuration

> **AWS's AI-Driven Development Lifecycle.** A *methodology*, not a tool: markdown rule/steering files the agent follows. "Fundamentally a methodology, not a tool … works with any IDE, agent, or model." Three-phase adaptive workflow — **Inception → Construction → Operations** — with mandatory human approval gates at nearly every stage. Open-source (awslabs/aidlc-workflows, MIT-0).
>
> **We run it on Claude Code** — keeping the agent + model + token measurement identical to the other five methodologies. The whole hexad is then single-tool / single-model, so *methodology* is the only variable.

## Version pinning
- AI-DLC: **v0.1.8** (awslabs/aidlc-workflows, released 2026-04-20; record exact commit at run time). MIT-0.
- Underlying agent: **Claude Code (Pro)** (see "Why Claude Code").
- Underlying model: **claude-opus-4-7** (same as Vibe / Plan Mode / OpenSpec / Spec Kit / BMAD).
- Subscription: Claude Pro.

## Why Claude Code
AI-DLC is tool-agnostic by design ("works with any IDE, agent, or model") and ships first-class Claude Code support, so running it there keeps the eval clean:
1. **Model:** identical `claude-opus-4-7` as every other cell.
2. **Token measurement:** the same `/status` capture used across the other five methodologies.
Plus: same idb dev-build harness, same cost axis. The whole hexad is single-tool / single-model, so *methodology* is the only variable measured.

## Setup
- Download the **v0.1.8** release zip from awslabs/aidlc-workflows.
- In a fresh workspace (cell dir):
  ```bash
  cp aidlc-rules/aws-aidlc-rules/core-workflow.md ./CLAUDE.md
  mkdir -p .aidlc-rule-details
  cp -R aidlc-rules/aws-aidlc-rule-details/* .aidlc-rule-details/
  ```
- Verify: start Claude Code in the workspace, run `/config`, and ask *"What instructions are currently active in this project?"* — confirm the AI-DLC core-workflow is loaded.
- No custom rules/steering beyond the AI-DLC release.

## Workflow
- Kick off by pasting the brief with the activation phrase: **"Using AI-DLC, &lt;brief&gt;"**.
- AI-DLC self-drives an **adaptive, risk-based** workflow — it runs only the stages that add value for the request ("the workflow adapts to the work, not the other way around"):
  - **Inception:** Workspace Detection (always) → Reverse Engineering (brownfield only) → Requirements Analysis (always; minimal/standard/comprehensive depth) → User Stories (conditional) → Workflow Planning (always) → Application Design (conditional) → Units Generation (conditional).
  - **Construction** (per unit of work; each unit fully designed + coded before the next): Functional Design → NFR Requirements → NFR Design → Infrastructure Design (all conditional) → Code Generation (Plan, then Generate) → then **Build and Test** (always, after all units).
  - **Operations:** placeholder in v0.1.8 — the cell ends at this boundary.
- **Artifacts** land in `aidlc-docs/` (`inception/`, `construction/`, plus `aidlc-state.md` + `audit.md`); **application code at the workspace root, never in `aidlc-docs/`.**
- **Approval gates (important for the cost axis):** AI-DLC stops at nearly every stage with **"DO NOT PROCEED until user confirms,"** delivering questions as *structured multiple-choice in files* (not chat). The operator clears these gates as part of the eval's operator role — count them as **baseline operator-touch, NOT interventions** (same convention as Plan Mode's plan-approval). Time and tally them.
- **Product/scope questions → PM persona** (`harness/pm-persona-v1.md`), verbatim. Distinguish workflow-approval gates (operator clears) from genuine product/scope questions (→ PM).
- Track Inception vs. Construction time to feed a methodology-overhead ratio.

## Optional features
- **Opt-in extensions** (`extensions/*.opt-in.md` — security baseline, property-based testing): **TAKE per AI-DLC's recommendation** — eval policy is to test each methodology as a real user would, taking its recommendations. AI-DLC is the only methodology that scaffolds property-based testing, so adopting it is part of the methodology, not a deviation (run-001 scored its PBT suite as a genuine robustness strength, not an asterisk).
- **Adaptive path selection:** ENABLED — letting AI-DLC choose its stages from the brief *is* the methodology.
- **AIDLC Evaluator / Design Reviewer** scripts: NOT used (would contaminate the cell).
- Custom steering beyond the AI-DLC release: DISALLOWED.

## End of cell
- Cell ends when **Build and Test completes** and AI-DLC asks *"Ready to proceed to Operations?"* — stop there (Operations is a v0.1.8 placeholder), OR
- A stage fails 3× consecutively (document; treat as cell-incomplete), OR
- Operator detects a stall (10 consecutive min, no progress), OR
- Rate limit interrupts the session.

## Notes / disclosure
- **Most approval-gated methodology in the eval.** AI-DLC's dense "DO NOT PROCEED" gates make it operator-touch-heavy *by design*. That is a **measured property (operator-touch time), not a confound** — record it; it's the sharpest contrast against OpenSpec's near-autonomous single-kickoff run.
- **Structure-spectrum placement:** structured-SDD cluster, near Spec Kit and likely heavier (full-lifecycle framing + per-unit Construction loop + dense gating). Headline comparison the cell answers: **rules-driven + heavily gated (AI-DLC) vs. explicit operator-driven pipeline (Spec Kit) vs. lightweight delta specs (OpenSpec) — all on the same model + tool.**
- **Uniform measurement:** same token capture + idb dev-build harness as every other Claude Code cell — no measurement asymmetry across the hexad.
- **Lifecycle caveat:** v0.1.8's Operations phase is a placeholder — the eval exercises Inception + Construction only. Note this when comparing "lifecycle completeness" (AI-DLC's nominal Operations advantage over Spec Kit is not yet real in v0.1.8).
