# Lumen Analytics — Q3 2026 Roadmap

*Single-squad plan for the quarter, with a defended cut-line.*

## Method

**The lens.** I did not sort by value-over-effort and draw a line. Three forces
in the constraints reorder the backlog more than any value rating does, so I
planned against them first and fit discretionary value into what was left:

1. **One date that cannot move.** The SOC 2 Type II evidence must be in production
   by **8 September (≈ week 10)**. Missing it doesn't cost a week — it slips the
   audit a full quarter to December, and several enterprise deals are
   contractually waiting on that audit. This is the anchor; everything else bends
   around it.
2. **Real capacity, not headline capacity.** Six engineers × 13 weeks is 78ew on
   paper, but the constraints are explicit that none of it survives intact: ~20%
   lost weekly to support/incident/KTLO, two engineers always on-call, and summer
   PTO. Netting the haircut, I plan against **~48ew of deliverable scope**
   [ASSUMPTION: ~46–50ew realistic; I committed ~45ew and held ~3ew as buffer for
   the audit path]. The backlog is 105ew — so this is a roughly 2× over-subscribed
   quarter, and over half of it must be cut.
3. **"Can it actually ship as written?" before "is it valuable?"** Several
   high-value items are undeliverable or hide a foundation underneath them. I
   resolved those first (see Dependencies & risks), because a valuable item that
   can't ship is worth zero this quarter.

**The rules I applied, in order:**

- **Protect the dated commitment first.** The audit critical path is funded,
  front-loaded, and finished with margin — not squeezed against the deadline.
- **Treat foundations as part of the item they unblock.** SAML SSO is not a 5ew
  feature; it is an 11ew program because the identity service it assumes doesn't
  exist yet. I costed the program, not the tip of it.
- **Finish what you start; don't start what you can't finish.** Items that begin a
  capability but can't complete it this quarter (custom formulas, AI summaries)
  are deferred to *open* Q4 rather than half-built now.
- **Fund commitments over demos.** Where capacity was contested, work that
  unblocks already-signed revenue (audit, enterprise SSO) beat work that is
  high-visibility but starts nothing (AI summaries).
- **Sequence in parallel tracks.** After the haircut the squad runs ~3–4 parallel
  streams. The plan pours two foundations early (audit + identity), runs cheap
  independent wins alongside, and lands product value late.

## Sequenced plan

Timing is bucketed: **Early** ≈ weeks 1–5, **Mid** ≈ weeks 5–10, **Late** ≈ weeks
9–13. Total committed scope ≈ 45ew.

| Item | ew | When | Why it sits here |
|---|---|---|---|
| **BL-11** Structured audit-log pipeline | 5 | **Early** | Load-bearing for the audit. SOC 2 logging/monitoring evidence can't rest on unstructured stdout with no retention. Prerequisite for BL-02; start week 1. |
| **BL-03** Identity & user-directory service | 6 | **Early** | The foundation SSO assumes. Also makes the audit's access-control evidence credible (one authoritative role/team store vs. five ad-hoc ones). Pays off twice — start early. |
| **BL-08** Query result caching | 3 | **Early** | Cheap, independent p95 win; pairs with BL-20 in the query/API layer. Quick visible value while foundations are poured. |
| **BL-20** API rate-limit dashboard | 3 | **Early** | Paired with BL-08 per the platform lead; same layer, independent of everything else. |
| **BL-02** SOC 2 evidence dashboard | 5 | **Mid** | The dated deliverable. Builds on BL-11. **Target done ~week 8**, two weeks before the week-10 freeze, to absorb auditor feedback. |
| **BL-04** SAML SSO for enterprise tenants | 5 | **Mid** | Sales-critical and audit-adjacent; builds on BL-03. Resolves logins to real roles/teams now that an authoritative store exists. |
| **BL-16** Slack alerting integration | 4 | **Mid** | Growth PM's highest-leverage retention bet. High value, independent, and (despite "alerting") does **not** touch the sunsetting Streamflow. Runs parallel to the audit track. |
| **BL-01** Saved-view sharing | 4 | **Late** | High-value core-product win; no foundation dependency. Lands once the dated/enterprise work is secured. |
| **BL-13** Onboarding checklist (in-app) | 4 | **Late** | Growth bet; also the step-state model BL-15 (deferred) will need. Pick the half that's load-bearing for the onboarding story. |
| **BL-19** Bulk user import (CSV) | 3 | **Late** | Frequent enterprise-onboarding ask; a cheap rider on BL-03's new user store. |
| **BL-25** Admin SSO session controls | 3 | **Late (flex)** | What enterprise security reviewers ask for alongside SSO; completes the enterprise story. **First item to drop** if velocity sags — nothing depends on it. |

## Cut-line

Everything below is explicitly **not** in Q3, with the reason I'd defend in the
review.

**Cut because it cannot ship as written (not a prioritization call):**

- **BL-07 Real-time live dashboards** — built on Streamflow, which stops new
  channel provisioning 1 Aug and shuts down entirely 30 Sep. Anything we build
  dies the day the quarter ends, and no replacement streaming layer is on this
  backlog. It demos beautifully and prospects asked for it by name; it is still
  undeliverable. **Don't commit it — commit the replacement layer's *design* and
  bring live dashboards back in Q4 on real infrastructure.**
- **BL-09 EU residency export (as written)** — specified to run on the primary
  `us-east` cluster, but EU personal data is contractually confined to
  `eu-central` with *no cross-region replication of raw records*. As written it's
  both a deal-losing compliance breach and technically impossible (the data isn't
  in `us-east`). Needs a re-scope to run inside `eu-central`, where the pipeline
  plumbing doesn't yet live — that's larger than the 4ew tag. **Re-scope and
  schedule for Q4; do not ship the current spec.**

**Deferred — high value but not load-bearing or not dated:**

- **BL-23 AI insight summaries** — leadership's splashy ask, but 6ew, undated, and
  it starts no capability anything else needs. Funding it puts the *audit* at
  risk. Honest framing: high-*visibility*, not high-*leverage* this quarter.
  **Recommendation: a 1-week AI spike to show direction, full build in Q4.**
- **BL-10 Custom metric formulas** — genuine product depth, but 7ew of parser /
  evaluation / edge-case surface is a quarter-killer against fixed commitments,
  and "7ew" items like this routinely become 10. **The right first thing to open
  Q4 — don't half-build it now.**
- **BL-15 Onboarding email drip** — depends on BL-13's step-state tracking; can't
  ship before it. Natural Q4 fast-follow once the checklist lands.
- **BL-12 Audit-log export & search UI** — Med value; not needed for the audit
  itself. Becomes cheap once BL-11 exists, so defer it to Q4 where the cost is low.
- **BL-22 Per-tenant data export (GDPR/DSAR)** — Med, undated. Watch for EU
  contractual pressure; if a customer DSAR clock starts, it jumps the queue.

**Cut — low value for the effort:**

- **BL-21 Legacy v1 chart-renderer rewrite** — 8ew, "Low," for two customers. The
  worst value-per-week on the board. Clearest cut.
- **BL-14 Mobile-responsive layout** — 5ew, Med; not urgent for a desktop-first
  B2B analytics tool. Revisit when there's demand evidence.
- **BL-05 Scheduled CSV report email** — Med, 3ew, no dependency pulling it in.
- **BL-06 Dark mode / BL-24 high-contrast / BL-17 status page / BL-18
  i18n number/date formats** — Low-value polish, ~9ew combined. Cut. *Note:*
  **BL-24 high-contrast** may return via an enterprise accessibility/VPAT
  requirement — if a deal names it, re-evaluate.

## Dependencies & risks called out

**Hard dependencies that reorder the plan:**

- **BL-11 → BL-02 (audit critical path).** The SOC 2 evidence dashboard collates
  audit-trail evidence; today that's unstructured stdout with no schema or
  retention — not auditable. BL-11 must land before BL-02
  [ASSUMPTION: I treat the retained event store as a hard prerequisite for
  audit-grade evidence; if the auditor accepts the current log story, BL-11 drops
  to "strongly recommended" but the date risk remains]. This 10ew chain is the
  only work fenced by the immovable week-10 date — **finish it by ~week 8** to
  leave margin for auditor feedback. This is the one slip that costs a full
  quarter.
- **BL-03 → BL-04 → BL-25 (enterprise program).** SAML SSO is written as if a
  central identity/role/team service already exists; it doesn't. So "5ew SAML" is
  really **11ew** (BL-03 + BL-04), and session controls (BL-25) sit on top of SSO.
  Anyone reading BL-04 as a standalone 5ew item is under-costing the enterprise
  commitment by more than 2×.
- **BL-03 reinforces BL-02.** The identity service also gives the audit a clean,
  authoritative "who has access to what" — building it early pays off on both the
  enterprise *and* the compliance track. This is why BL-03 is Early, not Mid.
- **BL-13 → BL-15.** The onboarding drip nudges users by how far they got through
  setup; the checklist is what knows that. Checklist in-quarter, drip in Q4.
- **BL-08 + BL-20** are paired by design (shared query/API layer), not by hard
  dependency — sequence them together for efficiency.

**Cannot ship as written (see cut-line for detail):**

- **BL-07** — dead on the sunsetting Streamflow vendor; no replacement on the
  backlog.
- **BL-09** — wrong region; a compliance breach *and* technically impossible as
  specified; needs an `eu-central` re-scope larger than its estimate.

**Execution risks to watch:**

- **The haircut is the real risk.** The plan commits ~45ew against ~48ew of
  realistic capacity. If support/incident load runs hotter than the assumed ~20%,
  **BL-25 drops first** (no dependents), then BL-19. The audit path and the
  enterprise foundation are protected and do not absorb the cut.
- **Front-load the dated path; don't trust the week-10 number.** Because the audit
  date costs a full quarter if missed, it gets the only built-in buffer — treat
  ~week 8 as the internal deadline.
- **"High value" was a misleading sort key this quarter.** The three loudest items
  (SAML, live dashboards, AI summaries) were respectively an under-costed program,
  undeliverable, and discretionary. The defensible value is unblocking *signed*
  revenue (the audit and the enterprise SSO deals waiting on it) over chasing
  prospective demos.
