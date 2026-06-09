# Test strategy for Scheduled Exports

We're about to build **Scheduled Exports** — recurring, unattended report exports
delivered to email, customer cloud storage, or a webhook. The full feature spec is
in `reference/feature-spec.md`. It's approved; the squad starts building next
sprint.

I'm the eng lead. This is the first thing we've ever shipped that runs on a timer
in the background and reaches out to other people's systems, so I don't fully
trust my own instincts on where it'll bite us. I need a **test strategy** I can put
in front of the squad and our QA partner before we write a line of code — so we
agree up front on where the testing effort goes.

What I do *not* want is a 200-line checklist that tests every field and every happy
path equally. We have a fixed amount of QA time and a Q3 date. I want a plan that's
**honest about where the real risk is** and spends the effort there — and that's
equally honest about what we're deliberately *not* going to test, and why, so
nobody feels like we skipped something by accident.

Specifically I want help with:

- Where can this feature actually hurt us — what are the failure modes that would
  cause a customer to get a wrong file, a missing file, a duplicate file, or a
  file at the wrong moment? Rank them.
- For the things that matter, what's the right *level* to test at (unit /
  integration / contract / end-to-end / production checks) — I don't want to pay
  for a full e2e suite where a cheap unit test would catch it, or vice versa.
- What we should explicitly **not** spend test effort on for v1, with the reasoning,
  so it's a decision and not an oversight.
- What tooling and CI gates are proportionate here — what blocks a merge, what runs
  nightly, what we watch in production rather than test before release.

Assume a competent squad and a normal CI setup (we run a test suite on every PR and
can add jobs). Don't write the tests — I want the strategy and the reasoning behind
the priorities, not test code.

## Deliverable

Produce `test-strategy.md` as a standalone Markdown document with these sections:
**Risk assessment** (what can hurt us most, ranked); **Coverage plan by layer**
(what to test and at which level); **Explicitly out of scope** (what you're not
testing for v1, and why); **Tooling & CI gates** (what blocks merge, what runs
when). Target length: ~2 pages (roughly 800–1,200 words); a short ranked table or
two is welcome, prose over exhaustive checklists.

## A note on ambiguity

If anything is ambiguous, make a reasonable assumption and tag it [ASSUMPTION].
