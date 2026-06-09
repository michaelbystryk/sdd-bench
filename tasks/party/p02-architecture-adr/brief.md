# Architecture decision: how we handle EU data residency (and what else, if anything, changes with it)

We're the engineering team behind Routable, an appointment-scheduling SaaS. We
have a signed EU customer whose contract requires that EU end-customer personal
data live and be processed in the EU, and we have four months to comply. The
same quarter handed us a latency complaint from our APAC customers (with an SLA
attached) and reopened a long-running internal argument about whether we should
be splitting our monolith into services. These have landed together and we have
to decide how to move — deliberately, not by accident.

`reference/context.md` is our honest write-up of the system, the team, the
constraints, the money, and the three forces pushing on us. Read it closely;
the real difficulty is in how the constraints pull against each other, not in
any one of them alone.

We need an architecture decision record we can take to our CEO this week and
start executing against. The point of the document is not to land on the
"correct" answer — reasonable architects would choose differently here. The
point is to lay out the genuine options, weigh the trade-offs each one forces on
us honestly (including the ones that hurt), commit to a path, and be clear about
what we're accepting and what we're deferring by choosing it. Where the context
is silent or fuzzy, say what you're assuming and move on; don't stall on it.

Write for a technical-enough CEO and a 6-person team that has to live with this
decision and execute it under a hiring freeze. We want to be able to start next
week.

## Deliverable

Produce `adr-001.md` as a standalone Markdown document with these sections:
**Context** (the decision and the forces driving it, in your own words);
**Options considered** (at least three, each with concrete pros and cons);
**Decision** (the path you're committing to, and why this one over the others);
**Consequences** (what this buys us, what it costs us, and explicitly what we're
accepting or deferring); **Revisit triggers** (the specific conditions or
signals that should make us reopen this decision). Target length: ~2–3 pages.

## A note on ambiguity

If anything is ambiguous, make a reasonable assumption and tag it [ASSUMPTION].
