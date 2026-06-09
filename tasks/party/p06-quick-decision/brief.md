# Pick the default page size for our new orders list endpoint

We're about to merge a new internal list endpoint, `GET /v1/orders`, and I need
to settle one small open question before it goes in: what should the **default
page size** be when the client doesn't specify a `limit`?

Everything you need to decide is in `reference/situation.md` — what the endpoint
is, what the payload looks like, how the one client (our internal ops console)
actually uses it, the load, and the few things already locked. There are four
candidate values floated in there; you don't have to pick from that list, but
they're a reasonable starting frame.

This is a low-stakes, reversible call — the default is a hardcoded constant we
can change in a one-line PR later, and it's not a contract with anyone external.
I don't need a deep study; I need a clear pick I can drop into standup and defend
in thirty seconds. Don't overthink it. Tell me the number, why, the one thing
most likely to make me regret it, and when I should revisit the choice.

## Deliverable

Produce `decision.md` as a standalone Markdown document with these sections:
**Recommendation** (the single value, stated up front); **Top 3 reasons** (the
strongest support for the pick, no more than three); **Key risk** (the one thing
most likely to make this the wrong call); **Reversal condition** (the concrete
signal that should trigger changing the default). Target length: **one page or
less** — this is a quick decision and the document should read like one.

## A note on ambiguity

If anything is ambiguous, make a reasonable assumption and tag it [ASSUMPTION].
