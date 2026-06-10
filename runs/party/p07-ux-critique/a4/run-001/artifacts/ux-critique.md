# Tallyroo Onboarding — Usability Critique

*Scope: the new-user path as shipped in build 4.2 — Welcome → Email → Password → Verify
email → Profile setup → Home (first run), per `reference/flow.md`. Reviewed as a new user on
a so-so connection arriving from a paid install. Where the handoff is silent, assumptions are
tagged [ASSUMPTION].*

---

## Summary

**This onboarding flow is not ready to take paid traffic.** The flow is sound in outline —
six clean screens, a sensible arc — but it ships with four structural traps that will
manufacture exactly the two symptoms test-flight reported: a cohort that *never reaches home*,
and a setup that *"felt like it fought them."*

The "never reaches home" leak is concentrated in three places: the **fully-gated entry**
(Screen 1 asks for an account before showing a single pixel of product), the **email-verification
dead end** (Screen 4 sends the mail once, offers no resend, and disables Back — a sealed room
on a slow or spam-prone connection), and the **back-gesture that silently deletes the entire
account** on Profile setup (Screen 5). The "fought them" feeling comes from a cluster of
smaller betrayals: the email field is **wiped every time you navigate back**, the way forward
on Screen 2 is a **plain text link** where every other screen uses a button, and a **raw API
error string** is shown verbatim to users.

The encouraging part: most of these are *bounded* fixes, not a redesign. As the eng read below
notes, several share a single root cause — the build doesn't distinguish "navigating away" from
"destroying state," and doesn't lock controls while a network call is in flight. Fix those two
patterns once and five separate issues fall.

**One recommendation overrides all others: do not spend on acquisition until the four
launch-blockers (Issues 1–4) are fixed and step-level funnel instrumentation is shipped.**
There are no funnel analytics today. Paying for installs into an uninstrumented funnel with
known dead ends means buying a drop-off number you can't read and can't attribute.

---

## Issues (prioritized)

### CRITICAL — launch-blockers; fix before any acquisition spend

**1. The app is fully gated — no value before commitment.**
*Severity: Critical · Heuristic: User control & freedom; commitment-before-value anti-pattern · Screen 1 (Welcome).*
The only two doors are "Create account" and "Sign in." A user arriving from an ad has seen
nothing of the product and is asked to commit an email and password to find out what it does.
Cold paid traffic converts poorly against a hard signup gate, so the **single largest leak is
here, before a character is typed.** [ASSUMPTION] paid installs skew low-intent; with no funnel
data we can't assume the audience is warm.
*Fix:* Add a third path — "Take a look first" → a read-only sample Home pre-filled with the
starter categories and demo numbers, plus a persistent "Create account to save" bar. If a true
demo is too much this sprint, ship the cheap version: a one-card value preview between Welcome
and Email, with a "Maybe later" that lands on the sample. (This is the biggest lever and the
most work — see Larger fixes.)

**2. Email verification is a dead end — sent once, no resend, Back disabled.**
*Severity: Critical · Heuristic: Help users recover from errors (#9); User control & freedom (#3); Visibility (#1) · Screen 4 (Verify email).*
The verification email fires once on entry and is never re-sent; there is no resend control, no
way to correct a mistyped address, and the OS Back gesture is disabled. The only button re-checks
status and re-shows "Verification not complete." On a so-so connection — slow mail, spam folder,
expired link, or a typo'd address from Screen 2 — the user is trapped with no in-app recovery.
This is a silent, permanent funnel leak and the prime suspect for the "never reached home" cohort.
Combined with Issue 3, a typo'd email here is *terminal*.
*Fix (ship this sprint):* Add a **"Resend email" control with a 30–60s cooldown**; show the
**actual target address** ("Sent to alex@…") so typos are caught; add a **"Wrong email? Change it"**
link that safely returns to the Email screen; mention checking spam. *Open question for the
product lead (see note below):* whether email verification should be a hard gate before the user
sees any value at all, or be deferred until after first run.

**3. The email field is wiped on every back-navigation (silent data loss).**
*Severity: Critical · Heuristic: Error prevention (#5); Recognition over recall (#6); User control (#3) · Screens 2↔3.*
The email field binds to a fresh per-presentation view-model, so leaving Screen 2 and returning —
e.g. tapping Back from Password to fix a typo — empties the field, and coming forward re-runs the
whole email step. This is the main corridor of the flow, not an edge case, and it reads as the app
being broken. It is the most direct cause of "felt like it fought them."
*Fix:* Hoist the signup view-model out of per-screen scope into a flow-level/session model — the
same lifecycle that already retains the password server-side. The email should still be in the
field when the user returns, and the redundant re-POST should stop.

**4. OS Back on Profile setup silently deletes the entire account.**
*Severity: Critical · Heuristic: Error prevention (#5); User control & freedom (#3); least astonishment · Screen 5 (Profile setup).*
Screen 5 has no back chevron, but the OS/hardware Back gesture is still live and resolves to
`DELETE /signup/abandon` — it tears down the account assembled across Screens 2–4 and dumps the
user at Welcome instantly, with no confirmation and a blank screen in between. A back-swipe is the
most reflexive gesture on a phone (muscle memory, especially on Android edge-swipe). One twitch
and a user who *just verified their email* — the most expensive survivor in the funnel — has to
start over. [ASSUMPTION] "abandon" is genuinely destructive server-side and not recoverable on
re-entry; if so, this is data destruction wired to the most common gesture on the platform — most
likely a wiring bug, not a design choice.
*Fix:* Intercept the back gesture on this screen. Either suppress it (the pattern already exists
on Screen 4 — quick win), or gate it behind a confirm dialog ("Leave setup? Your account will be
deleted."). Architecturally: **decouple "leave this screen" from "destroy the account" — those
should never have been the same action.**

### HIGH — fix this sprint if capacity allows; fast-follow at the latest

**5. Raw API error string shown verbatim to the user.**
*Severity: High · Heuristic: Help users recognize/recover from errors (#9); Match system to real world (#2) · Screen 2 (Email).*
On a failed email check the banner prints `Error 422: validation_failed (constraint: unique_email)`.
This is a debugging string a human can't act on — and the one error users will actually hit here is
"email already registered," i.e. a *returning user mis-routed into signup* whose obvious recovery
(go sign in) is completely buried.
*Fix:* Map the handful of known server constraints to human copy client-side. Already-registered →
"Looks like you already have an account. **Sign in?**" (inline link). Malformed → inline "That
doesn't look like a valid email." Default everything else to a generic retry message. Don't render
the raw string. Cheap, high-impact.

**6. The primary "Next" action is a plain bottom-left text link.**
*Severity: High · Heuristic: Consistency & standards (#4); signifier/affordance basics · Screen 2 (Email).*
Every other forward action in the flow is a filled button (Screen 3 pins a full-width "Continue").
On Screen 2 the way forward is underlined teal text in the bottom-left — the spot the eye trusts
least for "advance." It doesn't read as the primary action, it's misplaced, and it breaks the
rhythm set everywhere else. It's also always tappable, so it fires on empty/invalid input.
*Fix:* Make it the same pinned, full-width, filled teal button as Screen 3's "Continue."

**7. Required vs. optional fields are visually indistinguishable, and the disabled button never says why.**
*Severity: High · Heuristic: Visibility (#1); Error prevention (#5); Recognition over recall (#6) · Screen 5 (Profile setup).*
Display name and Home currency are required; Monthly budget is optional — yet Budget is the *only*
field with helper text, and nothing marks the two that actually gate submission. The "Finish setup"
button sits greyed until both are filled, but the user is never told why. Classic disabled-with-no-
explanation: poking a dead button with no idea what it wants.
*Fix:* Mark required fields (asterisk or "Required"), and either enable the button with inline
validation on tap, or show a hint near the disabled button ("Add a display name and currency to
continue").

### MEDIUM — fast-follow; won't sink launch

**8. No in-flight feedback on submits (double-submit / race exposure).**
*Severity: Medium (rises on slow connections) · Heuristic: Visibility of system status (#1) · Screens 2 and 5.*
On Screen 2, "Next" stays tappable and the field editable while `POST /signup/email` is in flight,
with no spinner — on a laggy network the user taps again, firing a second call, possibly with
different text (which response wins the transition is undefined). On Screen 5, `POST /profile/complete`
runs *several seconds* with all controls left live; re-tapping "Finish setup" / "Done" risks a
double-provision (duplicate workspace or starter categories). [ASSUMPTION] neither endpoint is
idempotent.
*Fix:* Apply a uniform in-flight lock everywhere the app POSTs — disable the control, show a
spinner/busy state, ignore taps until the call resolves. Server-side idempotency keys are the
durable backstop (larger fix), but the client lock closes the common case now.

**9. Category delete is immediate, with no confirmation and no undo.**
*Severity: Medium · Heuristic: User control & freedom / emergency exit (#3); Error prevention (#5) · Screen 6 (Home).*
The trash icon deletes a category on a single tap, no confirm, no undo — and it's the smallest
target in the flow (exactly 44pt) sitting on the swipe-prone right edge. Destructive and
irreversible on a screen the user is still learning. Blast radius is small (categories are
recreatable), so it's post-conversion, but it's a genuine footgun.
*Fix:* Add an undo snackbar ("Groceries deleted — Undo") backed by a short soft-delete window —
the standard, friendlier pattern over a confirm dialog.

**10. Empty-state on Home is a dead "No data." with no path forward.**
*Severity: Medium · Heuristic: Help & documentation (#10); Visibility (#1) · Screen 6 (Home).*
Delete all categories and the body shows centered "No data." — no illustration, no guidance, and
no hint that the top-right "+" is the only way back to having anything. New users don't yet know "+"
is load-bearing, so it reads as broken.
*Fix:* Make the empty state actionable: "No categories yet — tap + to add one," ideally with a
button right there.

### LOW — backlog

**11. The lone green primary button in an otherwise all-teal system.**
*Severity: Low · Heuristic: Consistency & standards (#4) · Screen 5 (Profile setup).*
Every primary control in the flow is teal (`#0E7C7B`); "Finish setup" is suddenly green
(`#2E8B57`) at the exact moment of commitment, whispering "different system / different meaning."
[ASSUMPTION] the green was intentional "go/success," but the flow already has a success language
(the "Looks good" toast, the requirement checks).
*Fix:* Make it teal like everything else. Trivial.

---

## The pattern underneath (why this matters for a two-person team)

Most of what's hurting this flow isn't visual design — it's **state lifecycle**. Four of the
issues share one root cause: *the build doesn't separate "navigating away" from "destroying state,"
and doesn't lock controls while async work is in flight.* The wiped email field (3), the
account-teardown on Back (4), and both double-submit races (8) are the same gap wearing different
clothes. Write two patterns once and they all fall:

- **(a) One signup-session model** that owns email + password + verification address through the
  whole flow (the password already lives there — extend it).
- **(b) A uniform in-flight lock** — disable control, show spinner, ignore taps — applied to every
  POST.

Grouped a different way, every symptom collapses into three structural traps: **dead ends with no
escape hatch** (1, 2), **state loss that punishes progress** (3, 4), and **an interface that fights
its own affordances** (5, 6, 7, 9). The dead ends and the state loss are what kill the
"never-reached-home" cohort; the affordance problems are what make it feel like a fight.

---

## Quick wins vs. larger fixes

**A note on what we can and can't see.** The handoff *evidences that the traps exist*; it does not
evidence *which are sprung, or at what volume* — that Screen 4 is the biggest drop, that the
back-teardown fires in the wild, that double-submits occur are all [ASSUMPTION]. The cheapest way
to convert those guesses into numbers, and the highest-leverage item on this whole list, is
**step-level instrumentation shipped before launch** (an afternoon of work): a `screen_reached`
event on each of the six screens (your entire drop-off curve), plus a
`verify_continue_tapped {verified | not_verified}` event (your Screen-4 kill rate — the prime
suspect). Just after launch, add `signup_email_error_shown` (how many "new installs" are actually
returning users), `signup_abandon_fired` with source screen (proves/disproves the silent teardown),
and `profile_submit_tapped` vs. `profile_complete_success` (exposes double-submit). Pair the funnel
with five recorded Screen-4 sessions to learn the *why* events can never tell you.

### Quick wins — land before launch (hours to ~half a day each)
- **Suppress or confirm OS Back on Screen 5** (Issue 4). Reuse the Back-disable pattern already on
  Screen 4. *Do this first — it prevents total loss of your most expensive users.*
- **Resend button + visible address + "change email" link on Screen 4** (Issue 2). The send endpoint
  exists; resend needs only a cooldown. The single biggest stop-the-bleeding fix for the cohort.
- **In-flight lock on all three submits** (Issue 8). Write once, apply to Screens 2 and 5.
- **Human error copy + "Sign in?" recovery on Screen 2** (Issue 5). A small switch on error code.
- **"Next" → pinned full-width teal button on Screen 2** (Issue 6). Pure styling/layout.
- **Mark required fields + explain the disabled button on Screen 5** (Issue 7).
- **Actionable empty state on Screen 6** (Issue 10); **make "Finish setup" teal** (Issue 11).
- **Ship `screen_reached` + `verify_continue` instrumentation** (prerequisite to acquisition spend).

### Larger fixes — real design/eng; sequence deliberately
- **Persist the signup view-model across the flow** (Issue 3). The binding change is small, but
  deciding correct re-entry behavior and removing the redundant re-POST makes it ~half-day of real
  work — and it's the structural fix that also unblocks "change email" on Screen 4.
- **A pre-account explore / sample mode** (Issue 1). The biggest lever and the most work. Even the
  cheap version (value-preview card + sample Home) is worth more than the first week of ad spend.
- **Reconsider email verification as a hard pre-value gate** (Issue 2, deeper cut). Adding resend
  stops the bleeding; *deferring* verification until after first run is a larger product decision
  that may matter more — flagged for the product lead, not assumed here.
- **Server-side idempotency keys** on `/signup/email` and `/profile/complete` (Issue 8, durable
  backstop), and **webhook/deep-link auto-advance** on verification (Issue 2, the real fix that
  removes the manual re-check). Both can wait behind their client-side stopgaps.
- **Undo / soft-delete for category deletion** (Issue 9). Post-conversion; not launch-critical.

---

*Bottom line: Issues 1–4 are the funnel and must be fixed before you spend; Issues 5–7 should
ride the same sprint; everything else is fast-follow. Ship the instrumentation alongside the
fixes — it's the difference between fixing the right thing and guessing.*
