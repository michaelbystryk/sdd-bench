# Builder activation — discovery

## Problem framing

The funnel you trust tells a sharper story than "people poke around and don't build anything." Land‑in‑app is fine (>90%). The single biggest leak is the **very next step: under a third of landed accounts ever connect a data source.** Everything downstream (publish, second viewer) is a smaller drop on a smaller base. So the problem is not diffuse "stickiness" — it is concentrated at one gate.

The reframe I'd push: **our self‑serve activation path has a hard dependency on a technical, credentialed, network‑level action — connecting a live data source — and our user base is majority non‑technical (≈40% ops, ≈25% founder, ≈20% engineer).** We are effectively asking an ops person to do an engineer's job, alone, in their first session. Three independent signals point the same way:

- Successful accounts skew heavily toward having an **engineer on the team**, even though engineers are a minority of signups.
- Median time‑to‑first‑connection is **~4 days, not 4 minutes** — that lag looks like "I had to go find credentials / file an IT ticket / wait for someone," not "I struggled with a screen for ten minutes."
- The top support category is **data connections**, and much of it is **firewall / IP‑allowlist** — i.e. not a UI problem at all, but a network/access problem the buyer's own IT controls.

What we genuinely don't know: *why* a given non‑technical account fails to connect — whether they **can't** (no credentials, no network access), **don't understand** (connection strings, SSL), or **don't bother** (no concrete first tool worth the effort). We have no in‑session instrumentation and — the most important gap — **the funnel isn't cut by role yet.** That one cut is cheap and would move several of these hypotheses immediately.

I'd also retire two distractions. The **power users** wanting JS / version control / staging are *already activated*; building for them is retention/expansion of a winning segment, not the up‑front bleed. And the **editor redesign** can't be the primary cause: ~70% of accounts never reach the editor at all, because they never connect. The editor matters only for the connect→publish drop, which is real but downstream and smaller in absolute terms.

## Hypotheses (ranked)

| # | Hypothesis | Why this rank | Whose theory |
|---|-----------|---------------|--------------|
| H1 | **Capability/access gate.** Non‑technical users can't self‑complete the connection — they lack DB credentials and/or network access (firewall/allowlist). Engineers succeed because they can. | Strongest: three converging signals (engineer skew, 4‑day lag, firewall tickets). | Reframes Sales + Support |
| H2 | **Value/intent gate.** Many signups are evaluators/tire‑kickers with no concrete first tool in mind, so they never invest in the connection hassle. Growing top‑of‑funnel may be lowering intent. | Co‑leading; confounded with H1 — both predict "non‑technical users stall at connect" for different reasons and opposite remedies. | (none — my addition) |
| H3 | **Comprehension gate.** The connection step itself is confusing (connection strings, SSL) even for those with access. | Real (Support's "genuine confusion" slice) but likely a minority of the connect failures. | Support |
| H4 | **No guided quick win.** Lack of onboarding/wizard means no early momentum. | Partly right, wrong remedy — a wizard doesn't hand someone DB credentials or open a firewall. | Sales |
| H5 | **Editor confusion.** Canvas is hard, people bounce. | Most never reach it; affects only connect→publish. | Designer |
| H6 | **Missing power features.** | Serves an already‑activated segment; irrelevant to the front‑end bleed. | Power users |

H1 and H2 are the contest that matters. The plan below is built to **separate them**, because they look identical in the funnel but imply opposite quarters of work.

## Riskiest assumptions

The direction I find most credible is H1 (with H2 as its live rival). The beliefs we'd be betting on — ranked by how much it hurts to be wrong:

1. **That the 4‑day lag is caused by chasing access, not by low interest / coming back later.** If it's really H2 (procrastination, no clear job), then removing the connection barrier converts nobody and we've built the wrong thing.
2. **That non‑technical users even want to connect a *real production* source in session one.** Their first‑session job may be "is this worth my time?" — better served by sample/demo data than by a smoother connection flow.
3. **That lowering the connection barrier produces a *used* tool, not just a stall moved downstream** to the editor or to "no second viewer."
4. **That the network/firewall blocker is fixable by us at all.** Some is genuinely customer‑side IT; without a connector/agent/tunnel or a sample‑data path, no UI change touches it.
5. **That the apparent template lift is causal, not selection.** [ASSUMPTION] you'd act on templates partly on this belief; it's currently untested.

## Discovery plan

Cheap checks for the next 1–2 weeks. [ASSUMPTION] you can join self‑reported role to funnel events, read support tickets, email recent signups, and ship a fake‑door.

1. **Cut the existing funnel by role** (this week, analytics only).
   *Tests H1/H5.* Split land→connect→publish→2nd‑viewer by ops / founder / engineer.
   **Validates H1:** ops/founder convert far worse *specifically at connect*; engineers convert fine. **Invalidates:** roles connect at similar rates, or the big role gap is at the editor (→ H5).

2. **Read 20–30 connection support tickets + any session replays** (2–3 days, data you already have).
   *Tests H1 vs H3.* Categorize: can't (network/credentials) vs. don't‑understand (strings/SSL) vs. abandoned‑without‑trying.
   **Validates H1:** access/network dominates. **Invalidates / supports H3:** comprehension dominates.

3. **Interview 8–12 stalled non‑technical accounts** (signed up, never connected; 1 week).
   *Tests H1 vs H2 — the key disambiguation.* Ask what they were trying to build, what stopped them, whether they had DB access.
   **H1:** "didn't have the credentials / had to ask IT." **H2:** "just looking, no specific tool in mind." **H3:** "couldn't figure out the screen."

4. **Fake‑door / sample‑data path** (1–2 weeks): a one‑click "explore with sample data — build a tool without connecting your source," even as a single seeded dataset or a fake‑door button.
   *Tests whether connection is THE blocker (H1) vs. value/editor (H2/H5).*
   **Validates H1:** stalled non‑technical users who skip connection reach a published tool at a much higher rate → remedy is a no‑connection first win, not a wizard or editor redesign. **Invalidates:** they still don't build → it's intent (H2) or editor (H5).

5. **Resolve the template question cleanly** (1 week): randomize new accounts into template‑prominent vs. not, or at minimum do a role‑/intent‑matched comparison.
   **Validates templates causal:** template cohort still activates better after matching. **Invalidates:** the lift disappears → it was selection, as you suspected.

Sequence #1 and #2 first (they use data you already hold and could reorder the whole picture by Friday), run #3 in parallel, and only commit to #4/#5 once interviews tell you which gate is real. If #1+#3 land on H1, the quarter is about a credential‑free first win and a delegate‑to‑an‑engineer flow — **not** the wizard, the editor redesign, or the power features the loudest voices are asking for.
