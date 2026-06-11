# Threat model for the Lumen wallet platform

We run Lumen, a stored-value wallet and payout product (users hold a balance,
transfer to each other, and cash out to their bank). We're preparing for a
partner due-diligence review and a SOC 2 effort, and before any of that we want
an honest internal security read on the system as it actually exists today.

`reference/system-description.md` is the as-built architecture writeup our
platform team prepared for exactly this purpose — components, data flows, the
auth model, storage, the external integrations (a payment processor and a KYC
provider), the admin panel, and the background payout jobs. It's written
neutrally; nothing in it is flagged as good or bad. Treat it as the source of
truth for how the system works.

We want you to think like an attacker and like a reviewer. Where could this
system be abused — to move money it shouldn't, to read data it shouldn't, to act
as someone it isn't, to dodge accountability, or to fall over? We care most
about anything that could result in incorrect money movement or exposure of
customer PII, but we want the whole picture, not just the scary headline. For
each thing you find, we need to understand how severe it is and what to do about
it, and we need a clear-eyed statement of what risk we'd still be carrying after
the obvious fixes.

Be specific to *our* system. A generic security checklist isn't useful to us; we
want findings that name the actual endpoint, flow, or trust boundary in the
description and explain the concrete way it could be exploited here and what the
consequence would be.

## Deliverable

Produce `threat-model.md` as a standalone Markdown document with these sections:
**Assets & trust boundaries**; **Threats** (enumerated — each threat with its
STRIDE category and a severity rating); **Mitigations**; **Residual risk**.
Target length: ~2–4 pages.

## A note on ambiguity

If anything is ambiguous, make a reasonable assumption and tag it [ASSUMPTION].
