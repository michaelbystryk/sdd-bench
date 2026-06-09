# UX review of the Tallyroo onboarding flow

We're a small product team shipping **Tallyroo**, a personal expense-tracking app on iOS
and Android. We just finished the new-user onboarding flow — install through sign-up,
email verification, profile setup, and the first-run home screen. It's in the current
build (4.2) and we're about to start driving install campaigns.

Before we spend on acquisition, we want a hard look at the experience. Early test-flight
feedback is mixed: a chunk of new installs never reach the home screen, and a few testers
said the setup "felt like it fought them." We don't have clean funnel analytics yet, so
we're working from the flow itself.

`reference/flow.md` is the engineering/design handoff doc for the flow as it actually
ships today — every screen, field, button, the exact copy, what each tap does, the
validation and error behavior, and the transitions. It describes the current behavior, not
an ideal.

What we need from you: a clear-eyed usability critique of this onboarding flow. Go through
it as if you were a new user on a so-so connection, find what's going to cost us users or
frustrate them, and tell us what to fix. We want it grounded in the flow as described —
point to the specific screen and behavior — and we want the fixes concrete enough that an
engineer or designer can act on them this sprint. Prioritize: we can't fix everything
before launch, so be honest about what matters most versus what can wait.

Audience: the product lead and the two-person design/eng team. Assume we know the app but
want an outside expert's eyes on the experience.

## Deliverable

Produce `ux-critique.md` as a standalone Markdown document with these sections: **Summary**
(the headline read on the flow's onboarding health); **Issues** (a prioritized list — for
each issue: a severity, the usability principle or heuristic it violates, the specific
screen/behavior it occurs in, and a concrete fix); **Quick wins vs. larger fixes** (split
the recommendations by effort so we know what we can land before launch versus what needs
real design/eng work). Target length: ~2–3 pages.

## A note on ambiguity

If anything is ambiguous, make a reasonable assumption and tag it [ASSUMPTION].
