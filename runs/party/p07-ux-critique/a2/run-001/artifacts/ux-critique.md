# Tallyroo — Onboarding UX Critique

*Scope: new-user path, build 4.2 (Welcome → Email → Password → Verify email → Profile setup → Home), reviewed against `reference/flow.md` as the shipped behavior.*

---

## Summary

The flow is competently built — the password step, locale-inferred currency, 44pt tap
targets, and WCAG-AA contrast show real care — but it has **two failure modes that are
actively destroying accounts and a handful of friction points that read exactly like the
"it fought me" feedback you're hearing.**

The single biggest driver of "new installs never reach the home screen" is **Screen 4
(Verify email): a one-shot verification with no resend, no way to correct a mistyped
address, and the Back gesture disabled.** Any user whose email is slow, lands in spam, has
an expired link, or was typed wrong is permanently stuck — their only exit is to kill the
app, and the account they started is orphaned. This alone can account for a large slice of
drop-off before you spend a cent on acquisition.

The second is **Screen 5 (Profile setup): the OS Back gesture silently runs
`DELETE /signup/abandon`** — it tears down the fully-assembled account and dumps the user
back to Welcome, with no confirmation and a blank screen in between. On iOS edge-swipe and
Android back, "go back one step" is muscle memory; here it nukes everything the user just
did. Users who made it almost to the finish line are losing their account to a reflex.

Layered on top: the app gates *all* value behind sign-up with no preview, surfaces a raw
`Error 422` string to users, loses the email field on back-navigation, gives no loading
feedback during a multi-second final call, and lets a single mis-tap delete a category with
no undo. None of these is fatal alone, but together they're the "fought me" feeling.

**Recommendation:** the verification dead-end and the destructive Back gesture are
launch-blockers — fix both before driving installs. The rest split cleanly into
land-before-launch quick wins and a post-launch design pass.

---

## Issues (prioritized)

### 🔴 CRITICAL

**1. Back gesture on Profile setup silently deletes the account**
- **Where:** Screen 5. No back chevron is shown, but the OS/hardware Back gesture is live
  and resolves to `DELETE /signup/abandon`, which destroys the account built across
  Screens 2–4 and returns to Welcome — instantly, with no confirmation and nothing rendered
  between the gesture and the return.
- **Violates:** User control & freedom (Nielsen #3); Error prevention (#5); destructive
  action without confirmation. The missing chevron signals "you can't go back," while the
  gesture does the most destructive thing possible — a direct contradiction.
- **Fix:** Stop mapping Back to account teardown. The default should be a no-op or a
  return to the verify/password step with state intact. If an explicit "start over" is
  desired, make it a labeled action behind a confirmation dialog ("Discard your account and
  start over?"). At minimum, intercept the gesture with a confirm prompt and never tear down
  without a "Yes, discard" tap.

**2. Email verification is a one-shot dead-end**
- **Where:** Screen 4. The verification email is sent once on entry and never re-fired.
  The only control is "I've verified — continue"; there is no Resend, no "change email," and
  the Back gesture is disabled. A non-arriving, spam-filed, or expired email — or a typo on
  Screen 2 — leaves the user with no path forward except force-quitting the app.
- **Violates:** User control & freedom (#3); Help users recover from errors (#9); the
  "Verification not complete." banner states the problem but offers no remedy.
- **Fix:** Add a **"Resend email"** action (with a short cooldown + "Sent again" confirmation)
  and a **"Wrong address? Edit email"** link that returns to Screen 2 with the value
  pre-filled. Expand the error copy to name the likely causes ("Didn't get it? Check spam,
  or resend below."). Strongly consider auto-detecting verification via a deep link so the
  user doesn't have to manually poll. [ASSUMPTION] no deep-link auto-detection exists today.

### 🟠 HIGH

**3. Raw API error shown for a duplicate email — and no route to Sign in**
- **Where:** Screen 2, "Next" failure. The user sees the API string verbatim:
  `"Error 422: validation_failed (constraint: unique_email)"`.
- **Violates:** Error messages in plain language, no codes (#9); Match between system and
  the real world (#2). The most common cause — *"you already have an account"* — is exactly
  the case a returning user needs gently redirected, not hit with a constraint name.
- **Fix:** Translate server errors to human copy. For the already-registered case:
  *"Looks like you already have an account with this email,"* with a **"Sign in instead"**
  button that carries the email over. For malformed input: *"That doesn't look like a valid
  email address."* Never surface error codes or constraint names to users.

**4. No loading state during the multi-second "Finish setup" call**
- **Where:** Screen 5 → `POST /profile/complete`. The doc notes this round-trip "can run for
  several seconds," and the screen "holds its rendered state — the same controls stay on
  screen and accept taps throughout."
- **Violates:** Visibility of system status (#1); enables accidental double-submission.
  On a so-so connection the user taps "Finish setup," sees nothing happen, and either taps
  again (firing a second provision call) or — worse — swipes Back, hitting issue #1.
- **Fix:** On tap, disable both "Finish setup" and "Done," show an in-button spinner /
  progress state, and block re-entry until the call returns or fails. Guard the endpoint
  against duplicate submissions. Add a failure path (the doc describes only the success
  transition) with a retry.

**5. Everything is gated behind sign-up — no value shown first**
- **Where:** Screen 1. No "Explore," guest, sample workspace, or read-only mode; "Create
  account" is the only forward path, and the app has zero functionality pre-auth.
- **Violates:** Asking for high commitment before demonstrating value — a well-known
  install→signup drop-off driver, especially for a personal-finance app where trust matters.
- **Fix:** Offer a low-commitment entry: a sample/demo workspace, a one-screen "what you'll
  get" preview, or deferred account creation (let users tap around starter categories, then
  prompt to save). If a hard gate must stay for launch, at least add a one-line value
  statement on Welcome beyond the tagline. *(Larger fix — see below.)*

**6. Email validated only server-side; "Next" always tappable**
- **Where:** Screen 2. Format and uniqueness are checked only on the server when "Next" is
  tapped; the field accepts free text and "Next" is always live.
- **Violates:** Error prevention (#5); efficiency (#7). Every typo costs a full round-trip
  on a slow connection before the user learns anything.
- **Fix:** Validate email *format* inline on the client and only enable/allow "Next" for a
  plausibly-valid address; reserve the server call for the uniqueness check. This also makes
  the "fight" of repeated waits disappear.

### 🟡 MEDIUM

**7. Email field is wiped on back-navigation (asymmetric with password)**
- **Where:** Screens 2–3. The email field binds to a fresh per-presentation view-model, so
  returning to Screen 2 (via Screen 3's back chevron/gesture) re-presents it empty — while
  the password *is* retained server-side. Going back to glance at or change the email forces
  a full re-type.
- **Violates:** Consistency (#4); minimize memory load (#6); user control (#3).
- **Fix:** Persist the entered email for the duration of the sign-up session and re-populate
  it on return, matching the password's retention behavior.

**8. Required vs. optional fields are visually indistinguishable**
- **Where:** Screen 5. Display name and Home currency gate submission; Monthly budget does
  not — yet only the optional field carries helper text ("Optional — you can set this
  later"). The two required fields have identical chrome and no "required" cue, and the
  disabled "Finish setup" button gives no reason it's disabled.
- **Violates:** Visibility of system status (#1); error prevention (#5). (The handoff itself
  flags that "nothing in the layout… distinguishes" them.)
- **Fix:** Mark the two gating fields as required (asterisk or "Required" helper line), and
  when submission is blocked, indicate which field is missing rather than leaving a silently
  greyed button. Since currency is locale-prefilled, Display name is effectively the only
  blocker — consider pre-filling/ making it optional too.

**9. One-tap category delete with no confirmation or undo**
- **Where:** Screen 6. A trash icon sits on every category row (the smallest 44pt target in
  the app) and deletes immediately on tap — no confirm, no undo, row vanishes.
- **Violates:** Error prevention (#5); user control & freedom (#3). A trash icon on every
  row, at minimum size, invites accidental loss.
- **Fix:** Add an undo (snackbar: "Groceries deleted — Undo") or a swipe-to-delete +
  confirm pattern, rather than a persistent one-tap destroyer on each row.

**10. First-run home gives no first-action guidance; empty state is a dead-end**
- **Where:** Screen 6. The starter categories land but nothing points the user to the "+"
  to log an expense. And if categories are all deleted (easy, per #9), the body shows only
  **"No data."** — no illustration, no guidance, no way to restore starter categories, and
  the unlabeled "+" remains the only (unsignposted) action.
- **Violates:** Recognition over recall (#6); helpful empty states; onboarding completion.
- **Fix:** Add a first-run hint pointing at "+" ("Tap + to add your first expense"). Rewrite
  the empty state with a friendly line, an illustration, a clear "Add expense" CTA, and an
  option to restore the starter categories.

### ⚪ LOW

**11. Inconsistent primary-action treatment across the sign-up arc**
- **Where:** Screen 2's primary action is a bottom-left *text link* "Next"; Screen 3 is a
  full-width filled button "Continue"; Screen 5 has both a top-right "Done" and a bottom
  "Finish setup." Within one "Create account" flow, the primary action changes shape,
  label, and position screen to screen.
- **Violates:** Consistency & standards (#4); a text link is a weak signifier for the
  step's main action and is easy to miss.
- **Fix:** Standardize the primary step action as one pattern — a full-width filled button,
  consistently placed and consistently labeled (e.g. "Continue"). Drop or de-emphasize the
  redundant "Done"/"Finish setup" pairing to a single primary control.

**12. Lone green button introduces an unestablished color meaning**
- **Where:** Screen 5's "Finish setup" is green (`#2E8B57`); every other primary is teal.
  Intentional as a "terminus," but a one-off color with no prior meaning can read as a
  different *kind* of action (e.g. confirm vs. caution).
- **Violates:** Consistency (#4). Low impact — flag for the design pass.
- **Fix:** Keep the primary teal for consistency, or formalize green as a deliberate
  "completion" color used elsewhere so it carries meaning rather than surprise.

**13. No visible progress through the multi-step sign-up**
- **Where:** The doc labels Screen 2/3 "step 1 of 2 / 2 of 2," but the nav title on both is
  just "Create account." [ASSUMPTION] step counts are doc annotations and aren't surfaced in
  the UI. Users get no sense of how much is left.
- **Fix:** Add a lightweight step indicator ("Step 1 of 3") or progress bar across the
  sign-up screens to set expectations.

---

## Quick wins vs. larger fixes

### Quick wins — land before launch (config/copy/small logic)
- **#1** Intercept the Screen 5 Back gesture with a confirmation (or make it non-destructive).
  *Launch-blocker; small change, huge impact.*
- **#2** Add "Resend email" + "Edit email" on Screen 4, and richer error copy.
  *Launch-blocker; the resend button is a few hours of work.*
- **#3** Translate the `422` error to human copy + "Sign in instead" for duplicate emails.
- **#4** Disable controls and show a spinner during `POST /profile/complete`; guard against
  double-submit.
- **#6** Inline email format validation before the server call.
- **#7** Persist the email field across back-navigation.
- **#8** Mark required fields on Screen 5.
- **#9** Add undo (or confirm) to category delete.
- **#11/#12** Standardize primary-button style/label; reconsider the green one-off.
- **#13** Add a step indicator to the sign-up screens.

### Larger fixes — need real design/eng work (post-launch or next sprint)
- **#5** Pre-auth value: demo/sample workspace, deferred account creation, or a value
  preview on Welcome. Meaningful product + backend change, but likely your highest-leverage
  conversion lever once the dead-ends are fixed.
- **#2 (extended)** Deep-link auto-detection of email verification so the user doesn't poll
  manually — smoother but a bigger lift than the resend button.
- **#10** Proper first-run guidance and a real empty state (illustration, CTA, restore
  starter categories) — design + content work.
- **Consider** whether email verification must be a hard gate *before* first run at all;
  deferring it until after the user has seen value (a soft prompt on Home) would remove the
  funnel's most dangerous choke point entirely. Worth a design discussion.

---

*Bottom line: fix #1 and #2 before any acquisition spend — they're silently destroying
accounts. The HIGH items will noticeably reduce friction and are mostly quick. The larger
fixes (value-before-signup, real empty states) are where you'll move the conversion needle
once the leaks are plugged.*
