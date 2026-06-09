# Postmortem: payments-api 5xx surge (2026-05-14)

On Thursday 2026-05-14 our `payments-api` service — the one that authorizes checkout for
the web and mobile storefronts — degraded badly for about 50 minutes during the early
afternoon. Checkout authorizations started failing with 5xx errors, peaking around one in
five requests, before oncall mitigated and recovered the service. No data was lost, but
customers saw failed checkouts during a high-traffic sale window, so leadership wants a
proper writeup.

I've pulled together what we have into `reference/`:

- `reference/timeline.md` — the reconstructed event log (alerts, the deploy, oncall
  actions, recovery), assembled from PagerDuty, the deploy bot, and oncall notes.
- `reference/logs.md` — log and metric excerpts people referenced during the incident:
  app error lines, the release's config/flag changes, and the key metric series before and
  during the event.
- `reference/chat.md` — the oncall chatter from the incident channel.

I need a real postmortem, not a status update. The incident channel threw out a few
theories in the heat of the moment, and I'd rather the writeup work from the evidence than
from whoever spoke loudest. Specifically I want it to land on the actual root cause and
distinguish it from the things that merely contributed or were coincidental, so we fix the
right things. Where the chat or timeline asserts a cause, treat it as a claim to check
against the logs and metrics, not as settled fact.

The remediations are the part leadership will actually act on, so make them concrete: each
one should have an owner role and a rough sequencing (what we do today vs. this week vs.
this quarter), and they should map to specific things this incident exposed — not generic
"improve monitoring" boilerplate.

Audience: the engineering team that owns the service plus their director. Blameless tone —
name decisions and gaps, not people.

## Deliverable

Produce `postmortem.md` as a standalone Markdown document with these sections: Summary;
Timeline; Root cause vs contributing factors; What we ruled out & why; Remediations (with
owners/sequencing). Target length: ~2–3 pages.

## A note on ambiguity

If anything is ambiguous, make a reasonable assumption and tag it [ASSUMPTION].
