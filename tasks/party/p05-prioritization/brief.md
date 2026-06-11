# Help me plan Lumen's Q3 roadmap

I'm the head of product at Lumen, a B2B analytics SaaS. We're heading into Q3
planning and I have a candidate backlog that's roughly twice what one squad can
deliver in a quarter. I need a defensible sequenced roadmap I can take into our
planning review on Friday — not just a ranked list, but an actual quarter plan
with a clear cut-line and the reasoning behind it.

## What I'm giving you

- `reference/backlog.md` — 25 candidate items, each with a rough value rating and
  an effort estimate in engineer-weeks. There are also a few notes I jotted about
  what sales, leadership, and the growth PM are pushing for.
- `reference/constraints.md` — the facts that bound the quarter: our real team
  capacity, a hard external date we're committed to, and a few platform/infra
  realities the engineering leads flagged.

The value and effort columns are a starting point, not the answer. I've been
burned before by a roadmap that was just "sort by value, then by effort, draw a
line" — it looked great on a slide and then fell apart in execution because the
sequencing was wrong and a couple of items couldn't actually ship. I'd rather you
read the backlog and constraints together and tell me what the naive ranking
misses.

## What I need from the plan

- A real **sequence** — what we do, and in roughly what order across the quarter,
  not just a flat priority stack.
- A clear, honest **cut-line**: what we're explicitly NOT doing this quarter, and
  why. I want to be able to defend each cut.
- The **dependencies and risks** that change the order or make something
  undeliverable. If two items are entangled, or one can't ship the way it's
  written, I need to know before we commit, not in week 8.

Be opinionated. If something that looks important shouldn't make the quarter, say
so and tell me why. If something cheap is secretly load-bearing, flag it. Assume
my planning review audience is smart but skeptical and will push on any ordering
that doesn't have a reason behind it.

## Deliverable

Produce `roadmap.md` as a standalone Markdown document with these sections:
**Method** (how you prioritized — the lens and the rules you applied);
**Sequenced plan** (a table: item, when in the quarter, why); **Cut-line** (what's
out and why); **Dependencies & risks called out** (the entanglements, ordering
constraints, and anything that can't ship as written). Target length: about 2
pages of prose plus the table.

## A note on ambiguity

If anything is ambiguous, make a reasonable assumption and tag it `[ASSUMPTION]`.
