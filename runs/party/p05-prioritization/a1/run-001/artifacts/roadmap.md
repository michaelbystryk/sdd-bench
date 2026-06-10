# Lumen Q3 2026 Roadmap

*Head-of-product plan for the Friday planning review. Sequenced, with an explicit cut-line and the reasoning behind every call.*

---

## Method

**The lens.** I did not sort by value, then effort, then draw a line — that is exactly the failure mode that burned us before. Instead I ranked on four questions, applied in order:

1. **Can it ship at all this quarter?** Some items are undeliverable or illegal *as written* regardless of how much we want them. Those get fixed or cut before anything else is decided.
2. **Is it bound to the one date that does not move?** The SOC 2 freeze (8 Sep, ≈ week 10) slips a full quarter if missed, taking contracted enterprise deals with it. Deadline-bound work is non-negotiable and front-loaded.
3. **Does it unlock other work?** A keystone that several other items quietly depend on is worth more than its own value rating suggests, and must be sequenced *early* so the dependents aren't jammed against quarter-end.
4. **Then, and only then, value density** (customer/revenue impact per engineer-week) decides the rest.

**The capacity math (the real number, not the headline).**

- Headline: 6 engineers × 13 weeks = **78 ew**.
- Less ~20% standing tax for support/incident/KTLO ("a fifth of the squad's time every week"): **−~16 ew**.
- Less summer PTO. `[ASSUMPTION]` ~2 weeks/engineer across the quarter: **−~12 ew**.
- Two of six always on the on-call rotation means a third of the team is interrupt-driven at any time; most of that I treat as already inside the 20% tax, but it argues for the conservative end.

**Realistic deliverable capacity ≈ 45–50 ew. `[ASSUMPTION]`** No headcount, no contractor backfill (finance declined), so there is no buy-back. I plan commitments to **~44 ew** and hold the remainder as buffer — because the on-call/incident tax is a floor, not a ceiling, and the audit cannot absorb a surprise. The backlog totals **107 ew**, so we are committing to roughly **40%** of it. The cut-line is real, not cosmetic.

**The rules that fell out of this.**

- The audit spine (**BL-11 → BL-02**) starts day one and is *done and frozen by week 9* — one week of slack before the week-10 hard freeze.
- The identity keystone (**BL-03**) starts day one too, because everything sales wants (SSO and its riders) sits on top of it and would otherwise collide with quarter-end.
- Anything built on a sunsetting vendor or a region the data can't live in is cut or sent back for re-scoping *now*, not discovered in week 8.

---

## Sequenced plan

Two parallel tracks (the squad supports ~2 streams). **Track A** is the deadline spine; **Track B** is the foundation-plus-enterprise stream. Committed total: **44 ew**.

| Item | When (quarter) | Why it's here, in this slot |
|---|---|---|
| **BL-11** Structured audit-log pipeline (5) | **Wks 1–4 · Track A** | The true origin of the critical path. Today audit events are unstructured stdout — not queryable, not retained. BL-02 cannot produce *audit-grade* evidence without this underneath it. Any slip here eats the audit buffer directly. Start day one. |
| **BL-03** Identity & user-directory service (6) | **Wks 1–5 · Track B** | The quarter's keystone. No authoritative store of users/roles/team-membership exists today. SAML SSO, session controls, bulk import, and teammate-aware sharing all silently depend on it. Rated "Med," but load-bearing — sequenced early so its dependents don't jam against quarter-end. |
| **BL-02** SOC 2 evidence dashboard (5) | **Wks 5–9 · Track A** | The one immovable deadline. Builds directly on BL-11. **Done and frozen by end of week 9**, giving a one-week cushion before the 8 Sep freeze. Missing it slips the audit a full quarter and the deals waiting on it. |
| **BL-04** SAML SSO for enterprise tenants (5) | **Wks 6–9 · Track B** | Sales' loudest ask, High value, same enterprise buyers the audit serves. Builds on BL-03's role/team resolution. Sequenced right after the identity service lands. |
| **BL-12** Audit-log export & search UI (4) | **Wks 9–11 · Track A** | Cheap *because* BL-11 already exists — turns an internal pipeline into customer-facing admin value. A rider on the audit spine, not new foundation. |
| **BL-25** Admin SSO session controls (3) | **Wks 9–11 · Track B** | Enterprise security reviewers ask for this alongside SSO. Natural rider on BL-04 — completes the enterprise-security story in one motion. |
| **BL-16** Slack alerting integration (4) | **Wks 10–12 · Track A** | Growth PM's highest-leverage *retention* bet and a frequent existing-customer ask. High value, independent (routes via webhook, not Streamflow), no dependencies. Our biggest win for current customers. |
| **BL-01** Saved-view sharing (4) | **Wks 11–13 · Track A** | High value at low effort — strong value density. Teammate-aware sharing leans on BL-03, which is by now in place, so it ships clean. |
| **BL-13** Onboarding checklist (in-app) (4) | **Wks 11–13 · Track B** | Growth's onboarding bet, and the prerequisite for the drip: it produces the per-step completion signal BL-15 needs. Must precede BL-15. |
| **BL-15** Onboarding email drip (4) | **Wks 12–13 · Track B** | Closes the onboarding loop. Its "nudge the steps you haven't finished" logic *requires* BL-13's completion state — ordered deliberately after it. |

**Stretch (pull in only if buffer holds, in this order):**
**BL-08 + BL-20** performance pair (6 ew) — the platform lead wants them paired; together they answer the "dashboard is slow / am I near my limit" complaint. Then **BL-19** bulk user import (3 ew) — a cheap, natural follow-on once BL-03 exists, and an enterprise-onboarding ask. Neither is committed; they are the first work to absorb the held buffer if the on-call tax is lighter than feared.

---

## Cut-line — what we are explicitly *not* doing, and why

**Cut because they cannot ship as written (the urgent flags):**

- **BL-07 Real-time live dashboards (High, 6).** The headline cut. It is built on **Streamflow, which stops provisioning new channels on 1 Aug (≈ wk 5) and shuts down entirely on 30 Sep** — the last day of the quarter. We would spend 6 ew building something that cannot accept new channels mid-build and is dead the day we'd ship it. The replacement streaming layer isn't on this backlog. It demos beautifully and big prospects asked for it by name — which is exactly why it needs a *deliberate* "not until we have a streaming platform," not a silent disappearance. **Re-open once a Streamflow replacement is chosen and built.**
- **BL-09 EU residency reporting (Med, 4).** Undeliverable *and* a compliance breach as written. It says run the EU export job "on the existing primary analytics cluster" — that cluster is in **us-east**, and EU personal data must be processed *only* in `eu-central`. There is no cross-region replication, so the data isn't even present in us-east to process. The 4 ew estimate assumes reuse of us-east plumbing that legally cannot be used. **Send back for re-scoping in `eu-central`; re-estimate (almost certainly higher) before it can be committed. `[ASSUMPTION]`**

**Cut on priority — defensible trades, not oversights:**

- **BL-23 AI insight summaries (High, 6).** Leadership's splashy favorite, so this needs a clear reason: it has *no dependency to unlock and no external date forcing it now*, and 6 ew is the cost of our entire onboarding cycle or SSO-controls-plus-Slack. In a deadline-constrained quarter, a pure bet loses to deadline-bound and dependency-unlocking work. It also benefits from the data foundation we're laying now. **Strong Q4 lead candidate — deferred, not killed.**
- **BL-10 Custom metric formulas (High, 7).** Our most expensive item after the legacy rewrite, no deadline, no unlock — and a formula language reliably balloons past its estimate. It deserves a quarter where it gets dedicated focus, not a squeeze against the audit.
- **BL-21 Legacy v1 chart-renderer rewrite (Low, 8).** Highest effort on the board, lowest value, serves **two** customers. Easiest cut to defend.
- **BL-22 Per-tenant data export / GDPR (Med, 4).** No hard date this quarter, and it carries the *same* residency trap as BL-09 — EU-tenant exports must run in `eu-central`. Deferred, with that constraint flagged so it isn't naively built in us-east later.
- **BL-05 (3), BL-14 (5), BL-19 (3)** — Med value, no dependency, no deadline. BL-19 is the best of these and sits just below the line as a stretch item.
- **BL-06 dark mode (2), BL-17 status page (2), BL-18 i18n formats (3), BL-24 high-contrast (2)** — Low value polish. Real, but they lose every contested engineer-week to deadline and keystone work.

---

## Dependencies & risks called out

**Hard dependency chains (these *set* the order):**

- **BL-11 → BL-02 (the audit spine).** BL-02 collates access/control evidence for the auditor. Today's evidence is unstructured stdout you can grep but cannot query or reliably retain. BL-02 could technically be built against those logs, but the output would not be audit-grade — it needs BL-11's retained, indexed event store to be defensible to an auditor. **`[ASSUMPTION]`** Therefore BL-11 must finish (~wk 4) before BL-02 starts. **BL-11 is the single most important item to keep on schedule; a slip there is a slip to the audit, which slips a full quarter.**
- **BL-03 → BL-04 → BL-25 (the identity cluster).** No authoritative user/role/team store exists; the constraints note "a few backlog items are written as if such a place already existed." BL-04 explicitly "resolves each login to a Lumen role and team membership" — that *is* BL-03. BL-25 layers tenant session policy on top of SSO. **`[ASSUMPTION]`** This is the keystone risk: a naive ranking sees BL-03 as "Med" and might cut it, then SAML SSO falls apart in week 8. Build BL-03 first.
- **BL-13 → BL-15 (onboarding).** The drip nudges users through "the steps they haven't finished." That completion state is precisely what BL-13's checklist produces. Build the checklist first or the drip has nothing to read.
- **BL-11 → BL-12, BL-03 → BL-01/BL-19 (cheap riders).** These are cheap *only because* their foundation already shipped. They're sequenced as riders, and their low cost is contingent on the foundation landing first.

**Sequencing / staffing risks:**

- **Foundation contention.** BL-11 (audit pipeline) and BL-03 (identity service) are both platform/data-heavy and likely draw on the *same* one or two senior platform engineers. Running them truly in parallel may not be possible. **If they contend, BL-11 wins** — it's deadline-bound. BL-03 takes the second senior or starts a few days later; that's survivable, the audit slip is not.
- **Buffer discipline.** We commit 44 ew against a realistic 45–50. That ~4–6 ew gap is deliberate cover for the on-call/incident tax, which is a floor. If we spend the buffer on stretch items early and then a bad incident week hits in September, the audit cushion is the first casualty. Hold the buffer until BL-02 is frozen.

**"Can't ship as written" (restating the two that must not reach a sprint board unchanged):**

- **BL-07** — dead vendor; do not start.
- **BL-09** — wrong region; data legally absent and a breach to run where the ticket says. Re-scope before it's a commitment.

**One thing to watch beyond the quarter:** cutting BL-07 leaves the live-dashboard demand unanswered *and* removes our last use of Streamflow before it dies — so the streaming-replacement decision becomes a Q4 priority in its own right, not a backlog afterthought.
