# Tallyroo — Onboarding & First-Run Flow (Engineering / Design Handoff)

*Build: 4.2 (iOS + Android). This document is the implemented behavior as shipped in the
current build, screen by screen, for the new-user path: sign-up through first run. It is
the source of truth for the QA pass and for the design review. It describes what the app
currently does, not what it should do.*

Platform notes: full-screen modal navigation; the OS/hardware Back gesture (Android back
button, iOS edge-swipe) is enabled on every screen unless stated. All server calls go to
`api.tallyroo.app`. Copy strings are quoted verbatim as they appear in the build.

---

## Summary

Tallyroo is a personal expense tracker. A new user installs the app, creates an account,
verifies their email, sets up a profile, and lands on the home screen with a set of starter
spending categories. Tallyroo has no functionality available without an account — the app
is fully gated behind sign-up; there is no demo, sample workspace, or read-only mode prior
to authentication.

The flow below covers six screens: Welcome → Email → Password → Verify email → Profile
setup → Home (first run).

---

## Screen 1 — Welcome

**What it shows.** Full-bleed brand illustration, the wordmark "Tallyroo", and a one-line
tagline "Spend with intent." Two controls, stacked, centered near the bottom:

- A filled teal button: **"Create account"**
- Below it, a teal text link: **"Sign in"**

There are no other controls on this screen. There is no "Continue as guest", "Explore the
app", "Maybe later", or any path that proceeds without authenticating.

**On "Create account":** transition (slide-left) to Screen 2.
**On "Sign in":** transition to the sign-in screen (returning-user path, out of scope for
this doc — it collects email + password and lands the user on Screen 6).

---

## Screen 2 — Email (sign-up step 1 of 2)

**What it shows.** Nav bar with a back chevron (top-left) and the title "Create account".
Body:

- A heading: "What's your email?"
- A single text field, placeholder "you@example.com", keyboard type = email. The field
  binds to a fresh per-presentation view-model, so whatever it holds reflects the current
  presentation of the screen rather than any prior session.
- A primary action rendered as a **plain text link "Next"** at the bottom-left of the
  content area (not a button; teal underlined text). It is always tappable.

**Validation.** Email format and uniqueness are validated on the server when "Next" is
tapped; the field accepts free text up to that point and a confirmation toast ("Looks
good") is shown briefly on a successful check before the transition fires.

**On "Next":**
- The app calls `POST /signup/email`. While this call is in flight the field stays editable
  and "Next" stays tappable.
- On success → transition (slide-left) to Screen 3.
- On failure (already-registered email, or malformed input the server rejects) → a red
  banner appears at the top of the screen with the text returned by the API, surfaced to
  the user exactly as the service returns it: **"Error 422: validation_failed (constraint:
  unique_email)"**. The field retains the typed text. The user stays on Screen 2.

---

## Screen 3 — Password (sign-up step 2 of 2)

**What it shows.** Nav bar with a back chevron (top-left) and title "Create account". Body:

- Heading: "Create a password"
- A password field (secure entry) with a show/hide eye toggle.
- A requirements list rendered directly under the field, always visible: "At least 8
  characters", "One number", "One uppercase letter". Each line shows a check as the rule is
  satisfied.
- A primary action rendered as a **filled teal button labeled "Continue"**, full width,
  pinned to the bottom. It is disabled until all three password rules are satisfied.

**On "Continue":** the app calls `POST /signup/password`, then transitions to Screen 4. The
password just set is retained server-side for the session, so a user who navigates forward
and back within sign-up does not lose it. The nav back chevron and the OS back gesture both
pop to Screen 2 (Email), which is re-presented from scratch on each arrival per its
per-presentation binding (see Screen 2); a forward tap from there re-runs the email step.

---

## Screen 4 — Verify email

**What it shows.** Upon arriving here the app has already sent a verification email to the
address from Screen 2 (a `POST /signup/send-verification` fired automatically on entry).
Body:

- An illustration of an envelope.
- Heading: "Check your email"
- Body copy: "We sent a verification link to your address. Open it to continue."
- A single control: a filled teal button **"I've verified — continue"**, pinned bottom.
  This is the only interactive element rendered in the body. The hardware/OS Back gesture is
  disabled on this screen.

**On "I've verified — continue":**
- The app calls `GET /signup/verification-status`.
- If the email has been verified → transition to Screen 5.
- If the email has NOT yet been verified (link not clicked, or it expired) → a red banner
  appears: **"Verification not complete."** and the user remains on Screen 4. The button
  re-enables so the same call can be re-attempted; the screen otherwise returns to its
  initial rendered state.

The verification email itself is dispatched once, on entry to the screen (the automatic
`POST /signup/send-verification` noted above); the build does not re-fire it after that, and
the address it targets is the one captured back on Screen 2.

---

## Screen 5 — Profile setup

**What it shows.** Nav bar titled "Set up your profile" with a **"Done"** text action in
the top-right corner of the nav bar. Body, a vertical form:

- **Display name** — text field, placeholder "e.g. Alex". Same label weight and field
  chrome as the other rows; no helper text sits beneath it.
- **Home currency** — a dropdown/picker, pre-selected to the currency inferred from the
  device locale (e.g. "USD" on a US device). Rendered with the same chrome as Display name;
  no helper text beneath it.
- **Monthly budget** — a numeric field, placeholder "0.00", with a small grey helper line
  beneath it reading "Optional — you can set this later."
- At the bottom, a **full-width green button labeled "Finish setup"**.

The "Finish setup" button (and the top-right "Done" action, which fires the same submission)
sits greyed until both Display name and Home currency hold a value; Monthly budget may be
left blank and submission still proceeds. The three rows are presented as a single uniform
list and nothing in the layout, ordering, or per-field chrome distinguishes the two that
gate submission from the one that does not.

**On Finish setup (or Done):**
- The app calls `POST /profile/complete`, which provisions the user's workspace on the
  server and imports a set of starter spending categories. On a typical connection this
  round-trip can run for several seconds. The screen holds its rendered state until the call
  returns — the same controls stay on screen and accept taps throughout — at which point it
  transitions to Screen 6.

This screen is presented without a back chevron in its nav bar. The OS/hardware Back gesture
is still live, however, and resolves to `DELETE /signup/abandon`: it tears down the account
assembled across Screens 2–4 and drops the user back at Screen 1 (Welcome) to begin again.
That path runs the moment the gesture is recognized, with the screen showing nothing between
the gesture and the return to Welcome.

---

## Screen 6 — Home (first run)

**What it shows.** This is the main app screen the user lands on after setup. Top nav bar
titled "Tallyroo" with a top-right **"+"** icon button (adds an expense). Below the nav
bar:

- A horizontal "This month" total reading "$0.00".
- A list of the starter spending categories imported during setup (e.g. "Groceries",
  "Transport", "Dining", "Bills", "Fun"). Each category is a row showing the category name,
  a colored dot, a running total ("$0.00"), and a **trash icon** on the right edge of the
  row.

**Category row — trash icon.** Tapping the trash icon on a category row deletes that
category immediately. No confirmation prompt or undo is offered; the row disappears on tap
and the category is removed.

**Empty state.** If the user has deleted all categories (or in any state where the category
list is empty and no expenses exist), the list area displays the text **"No data."**
centered in the body, with no further guidance, illustration, or action. The top-right "+"
remains the only way to add anything, but nothing on the empty body indicates that or
prompts a first action.

**Adding an expense.** Tapping "+" opens an add-expense sheet (amount, category picker,
date, optional note). This sheet is out of scope for this handoff; the first-run flow ends
at the user landing on Screen 6.

---

## Visual/theming notes (as built)

A few cross-cutting rendering notes for the QA pass:

- The brand teal (`#0E7C7B`) is the fill for the primary buttons; the same teal is used for
  the text-link styling on the Welcome "Sign in" and the Email "Next" affordances.
- The "Finish setup" button on Screen 5 is the one primary control rendered in green
  (`#2E8B57`) rather than teal; it is the visual terminus of the sign-up arc.
- Tap targets across the flow meet the 44pt minimum; the trash icon on Screen 6 rows is the
  smallest at exactly 44pt square.
- Body copy uses the system font at 16pt; headings at 22pt semibold. Contrast ratios on the
  teal-on-white buttons were checked against WCAG AA and pass.

*End of handoff.*
