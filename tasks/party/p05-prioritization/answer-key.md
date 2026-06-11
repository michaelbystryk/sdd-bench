# P5 — Answer key (SEALED, harness-only)

Semi-objective key for the prioritization task. The deliverable is `roadmap.md`;
the "truth" is the set of **trap-insights** a good roadmap must reflect. This key
enumerates 9 planted items. Each is genuinely derivable from
`reference/backlog.md` + `reference/constraints.md` and is NOT inferable from the
backlog's value/effort columns alone — a naive value/effort sort misses every one.

**Scoring note.** Score each item **found / partial / missed** against the
"Minimum credit" line, citing the deliverable line. A roadmap can satisfy an item
either by stating the insight explicitly (in Method / Dependencies / Cut-line
prose) OR by *structuring the sequenced plan so the trap is correctly handled*
(e.g. placing A before B in the table is credit for the dependency edge even if
unstated — but only if the ordering is unambiguous and not coincidental). Prefer
"found" when the plan provably reflects the insight; "partial" when it half-does
(orders it right but for the wrong/no reason, or names the risk but still
schedules it wrong). **Precision note:** also count confidently-asserted
dependencies/constraints that are NOT real for these materials (invented edges,
phantom blockers) — a roadmap that fabricates 6 dependencies has not "found" them.

The naive baseline this key is built against: sort by value desc, then effort asc,
fill to whatever capacity the solver assumes (a naive pass typically over-assumes,
toward the 78 nominal). That baseline ships BL-07 (high/6), BL-04 (high/5) before
BL-03, BL-09 on the primary (us-east) cluster, splits or single-takes BL-13/BL-15,
defers BL-02 past week 10, and keeps BL-21. Every keyed item is a place that
baseline goes wrong. Three decoys are planted in the PM notes to bait a shotgun
solver: BL-16 hyped as "highest-leverage retention bet" (no constraint behind it),
a "pair BL-08 + BL-20" suggestion (no shared state — not a real synergy like K4),
and BL-19 talked up as a frequent ask (a clean Med/3 with no entanglement).
Crediting any of these as a dependency/synergy/blocker is a precision failure.

---

### K1 — SAML SSO (BL-04) silently depends on the identity service (BL-03) [subtlety: moderate]
- What it is: BL-04 must "resolve each login to a Lumen role and team membership," but constraints state there is no authoritative place that knows who a user is or what they're entitled to — roles/team membership are stored ad hoc per feature. BL-03 stands up exactly that authoritative service, so it must ship first or BL-04 has nothing to resolve against. The item text no longer says "the directory," so the solver must connect BL-04's "role and team membership" need to BL-03's charter and to the constraints fact about there being no central source of identity/entitlement.
- Where detectable: `backlog.md:16` (BL-04 resolves login to "a Lumen role and team membership") + `backlog.md:15` (BL-03 = stand up the centralized user/role/team-membership service) + `constraints.md:47-51` (roles/team membership "stored ad hoc, per feature… no one place that authoritatively knows who a user is or what they're entitled to… A few backlog items are written as if such a place already existed").
- Minimum credit: states the dependency in the right direction — BL-03 (the identity/role source) must precede BL-04 (SSO that resolves roles) — with a rationale tied to the missing central directory, OR sequences BL-03 strictly before BL-04 in the plan such that the dependency is the unambiguous reason. Merely scheduling both in the same quarter with no ordering or rationale = partial. Asserting the edge in the wrong direction, or inventing a different prerequisite for BL-04 = missed (and a precision ding).

### K2 — Audit-log export UI (BL-12) depends on the structured audit pipeline (BL-11) [subtlety: moderate]
- What it is: BL-12 lets admins "search and export their tenant's audit events from a UI," but today audit events are unstructured stdout lines you can grep but not query or filter. BL-11 moves those events into a retained, indexed event store — that's the prerequisite. Neither item text names the other; the solver must see that "search/export from a UI" is impossible against the current grep-only stdout state described in constraints, and that BL-11 is the item that fixes that state. Shipping BL-12 before BL-11 = nothing queryable to search.
- Where detectable: `backlog.md:24` (BL-12 = admins "search and export… from a UI") + `backlog.md:23` (BL-11 = move audit events into a "retained, indexed event store") + `constraints.md:52-55` (audit events are "unstructured application log lines written to stdout… you can grep them, but you can't query, filter, or reliably retain them as records").
- Minimum credit: states BL-11 must precede BL-12 with a rationale grounded in the current unqueryable/stdout audit state (not a generic "infra first"), OR sequences BL-11 strictly before BL-12 so the dependency is the unambiguous reason. Scheduling BL-12 without BL-11, or before it, = missed. Same-quarter with no ordering/reason = partial.

### K3 — Live dashboards (BL-07) is invalidated: it builds on Streamflow, which is being sunset [subtlety: moderate]
- What it is: BL-07 is a High-value/6ew item that pushes updates "over Streamflow channels," but Streamflow stops new channel provisioning 1 Aug 2026 and shuts down 30 Sep 2026, with no replacement on this quarter's backlog. Building it this quarter is throwing the work away.
- Where detectable: `backlog.md:19` ("over Streamflow channels") + `constraints.md:31-36` (Streamflow EOL: no new provisioning 1 Aug, full shutdown 30 Sep, replacement not on the backlog, "throwing the work away").
- Minimum credit: cuts or defers BL-07 (does NOT schedule it for build this quarter) AND attributes it to the Streamflow sunset/deprecation. Scheduling BL-07 as a normal build item = missed. Cutting it for the wrong reason (e.g. "low value") = partial.

### K4 — BL-13 and BL-15 share the setup-state layer and must be done together [subtlety: subtle]
- What it is: BL-13 (in-app onboarding checklist) "tracks which of a new user's first-run setup steps are done as they complete them"; BL-15 (onboarding email drip) "nudges users through the setup steps they haven't finished yet, based on how far they've gotten through first-run setup." The word "same" has been removed from BL-15 — neither item now declares the shared layer. The solver must infer from the two behaviors that both require the identical first-run-setup-completion-tracking substrate, that that substrate is the bulk of each item's effort, and therefore that building it once serves both. Splitting them across quarters (or scheduling only one) wastes the duplicated build of the shared layer.
- Where detectable: `backlog.md:25` (BL-13 tracks which first-run setup steps "are done as they complete them") + `backlog.md:27` (BL-15 nudges through "the setup steps they haven't finished yet, based on how far they've gotten through first-run setup"). The PM note `backlog.md:48` ("a couple of 'help new users actually get set up' bets") gestures at the pair but no longer names the IDs or says "same" — it is not sufficient on its own.
- Minimum credit: explicitly identifies that BL-13 and BL-15 are built on the *same* underlying setup-completion-tracking state (inferred from their behavior, since the text never says so) and concludes they should be done adjacently / as one effort, ideally noting combined effort is well under 4+4=8 ew because the shared layer is paid once. Scheduling both in the same quarter without naming the shared substrate = partial. Splitting them, doing only one, or treating them as two independent 4ew items = missed. Note: do NOT award K4 for the BL-08/BL-20 "paired" decoy in the PM notes — those share no state and pairing them is not a real synergy.

### K5 — SOC 2 evidence dashboard (BL-02) is deadline-gated and must land by ~week 10 [subtlety: moderate]
- What it is: BL-02 is the only item feeding the SOC 2 audit, which has a hard, non-moving deadline: evidence must be in production by 8 Sep 2026 (~week 10) or the audit slips a full quarter, blocking enterprise deals. A naive value/effort sort treats it as just another High/5 item with no time pressure and risks scheduling it late or cutting it.
- Where detectable: `backlog.md:14` (BL-02 "evidence our auditor needs at audit time") + `constraints.md:20-29` (audit window opens 15 Sep, evidence frozen 1 week prior → done by 8 Sep ≈ week 10, missing it slips a full quarter, deals waiting).
- Minimum credit: schedules BL-02 to complete by ~week 10 / before the audit freeze AND names the deadline as the reason. Scheduling it but late, or without the deadline rationale = partial; deferring/cutting it = missed.

### K6 — EU residency export (BL-09) as written violates the data-residency rule [subtlety: subtle]
- What it is: BL-09 proposes running the heavy EU-tenant usage export "on the existing primary analytics cluster, where the batch reporting pipeline already lives." The item no longer names a region — it sounds like a sensible reuse of existing infra. The violation only appears by cross-referencing: (a) the primary analytics cluster lives in `us-east` (a platform fact), and (b) EU personal data may only be processed inside the EU/`eu-central`; US regions were never certified for EU personal data and there's no replication of raw EU records out of region (a compliance note, in a *different* section). Chained: BL-09 as written runs an EU-personal-data export in us-east = non-compliant. It must be re-scoped to run in eu-central (a feasibility/effort change, not a value change) or cut.
- Where detectable: requires cross-referencing three facts in three places — `backlog.md:21` (BL-09 runs the EU-tenant export on "the existing primary analytics cluster") + `constraints.md:36-40` (the primary analytics cluster "is hosted in `us-east`," the default home for new export jobs) + `constraints.md:59-67` (EU personal data must be processed "only within the EU"/`eu-central`; "running such a workload anywhere outside the EU is a compliance breach"; US regions "were never certified for EU personal data"; no cross-region replication of raw EU records).
- Minimum credit: flags that BL-09 as written is non-compliant because the export would run in us-east (the primary cluster) while EU personal data must stay in-region — i.e. the solver must make the us-east↔primary-cluster connection, not just gesture at "residency." Then it must re-scope BL-09 to eu-central or cut it. Scheduling BL-09 as-is for build = missed. Vaguely worrying about "EU residency" without identifying that the *primary cluster (us-east)* is the violation = partial. Inventing a residency problem for an item that has none (e.g. BL-22) = precision ding.

### K7 — Real capacity is ~60 ew, not the nominal 78; the naive top-of-list overcommits [subtlety: moderate]
- What it is: The nominal capacity (6 engineers × 13 weeks = 78 ew) is no longer stated as a number anywhere — the constraints describe the haircut only in prose: summer PTO, two engineers always on on-call, and "around a fifth of the squad's time every week" lost to interrupts/KTLO. The solver must compute the nominal 78 themselves, apply the ~20% interrupt drag plus PTO and on-call, and arrive at a realistic budget in the ~55–62 ew range. The full backlog totals ~106 ew; a roadmap that plans to ~78 or ignores the haircut overcommits the quarter.
- Where detectable: `constraints.md:8-17` — derive nominal from "6 engineers" × "13-week quarter" (= 78), then apply the stated drains: "summer PTO takes a real bite," "two engineers are always on the on-call rotation," "around a fifth of the squad's time every week" to interrupts/KTLO, and the explicit instruction to "plan against what's left after the haircut, not the headline number." No "60" and no "78" appear in the text.
- Minimum credit: derives and commits to a realistic capacity budget materially below the 78 nominal — concretely a committed-work total in roughly the 55–65 ew band — *and* shows the budget was reached by netting out the stated drains (not just asserting a number), with the cut-line falling out of that budget. Planning to ~78, or stating no capacity budget at all, = missed. Naming the haircut qualitatively but then committing ~70+ ew of work, or picking an arbitrary number with no derivation = partial.

### K8 — Legacy v1 chart-renderer rewrite (BL-21) is an obvious cut [subtlety: obvious]
- What it is: BL-21 is Low value, 8 ew (the single most expensive item), serving only "two remaining customers." It is the clearest cut — high cost, trivial reach, no constraint forcing it.
- Where detectable: `backlog.md:33` (BL-21 Low / 8 ew, "two remaining customers still use").
- Minimum credit: places BL-21 below the cut-line / out of the quarter, on a cost-vs-reach basis.

### K9 — The low-value cosmetic cluster (BL-06 / BL-17 / BL-18 / BL-24) is the obvious cut tier [subtlety: obvious]
- What it is: A cluster of Low-value polish items — dark mode (BL-06), status page (BL-17), i18n number/date (BL-18), high-contrast theme (BL-24) — that a constrained quarter should cut to protect the deadline-gated and dependency-blocked work. They are not wrong to want eventually, but they lose to everything load-bearing this quarter.
- Where detectable: `backlog.md:18` (BL-06 Low/2), `backlog.md:29` (BL-17 Low/2), `backlog.md:30` (BL-18 Low/3), `backlog.md:36` (BL-24 Low/2).
- Minimum credit: cuts at least 2 of these 4 Low-value polish items below the cut-line with a value-vs-capacity rationale. (Naming the whole cluster as the cut tier is full credit; cutting only one is partial.)

---

## Difficulty spread (for calibration)

- Obvious (2): K8 (BL-21 cut), K9 (cosmetic-cut tier).
- Moderate (5): K1, K2 (dependency edges — no longer named in item text; must be
  inferred from current-state constraints), K3 (deprecation), K5 (deadline
  gating), K7 (capacity haircut — now a prose derivation, not a stated number).
- Subtle (2): K4 (the shared setup-state synergy — the word "same" was removed, so
  it must be inferred from two behaviors), K6 (the residency violation — BL-09 no
  longer names a region; requires chaining primary-cluster→us-east→EU-only across
  two constraint sections).

This key was hardened after a cold solo pass scored 8 found + 1 partial / 9
(ceiling — too easy). The traps that were near-verbatim cues (K6's "us-east" inside
the item, K4's "same completion state," K7's literal "60 not 78," K1/K2's
prerequisite restated in item text) have been moved to inference/cross-reference.
A re-calibrated cold solo pass should now land ~3–6/9: it should still catch
K8/K9 and likely K3/K5, get one of K1/K2, but miss or only-partial K4, K6, K7
(the derivation), and may burn precision on the three PM-note decoys. Target spread
for a strong/deliberative pass: 6–8/9 with clean precision. If a cold pass finds
≥8/9 again or ≤2/9, re-tune phrasing salience and re-log.
