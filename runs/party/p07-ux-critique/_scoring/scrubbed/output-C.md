# Tallyroo Onboarding — UX Critique (Build 4.2)

## Summary

The onboarding arc is coherent and the screens are individually clean, but the flow has
**two hard dead-ends that will, by themselves, explain the "never reach the home screen"
reports** — and several smaller frictions that explain "it fought them." The two structural
problems are on **Screen 4 (Verify email)**, where a user whose verification email never
arrives has no way to resend it, fix a mistyped address, or even go back; and **Screen 5
(Profile setup)**, where the ordinary OS Back gesture silently destroys the entire account
the user just built. Both fail on a so-so connection or a single fat-fingered tap — exactly
the conditions your test cohort hit.

Underneath those, the flow consistently under-communicates during network calls (no loading
states, controls stay live during multi-second round-trips), exposes raw server error text,
and is fully gated behind sign-up with no way to see the product first. None of the screens
are broken in isolation; the damage is concentrated at the seams — verification, profile
submission, and the first-run home screen. The good news: the worst problems are also among
the cheapest to fix.

The recommendations below are prioritized. If you only do three things before launch, do
**C-1, C-2, and H-1**.

---

## Issues

### Critical — fix before any acquisition spend

**C-1 — Verify-email screen is a dead end when the email doesn't arrive.**
*Screen 4. Violates: error recovery / user control; "help users recover from errors."*
The verification email is sent exactly once, on entry, and "the build does not re-fire it."
There is no **Resend** control, no way to edit the address (the only path back to Screen 2's
email field), and the OS Back gesture is **disabled** here. So any user who: mistyped their
email on Screen 2, hit a spam filter, suffered a delayed/dropped send on a poor connection,
or let the link expire — is permanently stuck on this screen with one button that will only
ever say "Verification not complete." Their sole escape is to kill and reinstall the app.
This is the single most likely cause of installs that never reach Home.
**Fix:** Add a **"Resend email"** link with a 30–60s cooldown. Add **"Wrong address? Change
it"** that returns to Screen 2 with the email editable. Split the error copy: distinguish
"link not clicked yet" from "link expired — we've sent a new one." Best-effort: poll
`verification-status` in the background so verified users advance automatically without
needing to tap the button at all.

**C-2 — Back gesture on Profile setup silently deletes the whole account.**
*Screen 5. Violates: error prevention; user control & freedom; confirmation before
destructive, irreversible action.*
Screen 5 has no back chevron, but the OS/hardware Back gesture is still live and resolves to
`DELETE /signup/abandon` — tearing down the account assembled across Screens 2–4 and dumping
the user at Welcome "the moment the gesture is recognized, with the screen showing nothing
between." A back-swipe is the most reflexive gesture on mobile (the entire flow up to here
trained the user that Back means "go up one step"). Here it means "destroy everything and
start over," with no warning, no confirmation, and no undo. A user who swipes back to
double-check the email they used loses their account silently. This is a textbook "it fought
me" moment and likely a second contributor to the drop-off.
**Fix:** Intercept Back on this screen. Either (a) make it a no-op or pop to a safe step, or
(b) show a confirm dialog: "Leave setup? Your account is saved — you can finish later." Never
call `DELETE /signup/abandon` from an unconfirmed reflexive gesture. If an explicit abandon
path is genuinely needed, make it a labeled, deliberate control.

### High — fix before launch if at all possible

**H-1 — No feedback during multi-second network calls; controls stay tappable.**
*Screens 2, 3, 5. Violates: visibility of system status; error prevention (double-submit).*
On Screen 2 the field stays editable and "Next" stays tappable while `POST /signup/email`
is in flight; on Screen 5 the screen "holds its rendered state… the same controls stay on
screen and accept taps throughout" a round-trip the doc itself says "can run for several
seconds." On a so-so connection this reads as a frozen, unresponsive app and invites repeat
taps (duplicate submits). This is the most pervasive "fought them" symptom across the flow.
**Fix:** On every network action, immediately show a spinner/disabled state on the triggering
control and block re-taps until the call resolves. Apply uniformly to Screens 2, 3, and 5.

**H-2 — Raw server error text shown to users.**
*Screen 2. Violates: error messages in plain language; match between system and real world.*
A duplicate email surfaces verbatim as **"Error 422: validation_failed (constraint:
unique_email)."** It's unreadable to a normal user, leaks implementation detail, and — worse
— misses an obvious recovery: an already-registered email almost always means a returning
user. **Fix:** Map it to "Looks like you already have an account with this email," with an
inline **"Sign in instead"** button that carries the email over to the sign-in screen. Map
malformed-input rejections to a plain "That doesn't look like a valid email address."

**H-3 — Typed email is lost on back navigation.**
*Screens 2 ↔ 3. Violates: user control; minimize re-entry; consistency.*
Screen 2 "binds to a fresh per-presentation view-model," so navigating back from Password
re-presents Email blank — even though the password the user set *is* retained server-side.
The asymmetry is confusing and forces re-typing. **Fix:** Persist the email in the sign-up
view-model (as you already do for the password) and re-populate the field on return.

**H-4 — Instant, unconfirmed category deletion on Home.**
*Screen 6. Violates: error prevention; reversibility (undo); destructive action without
confirmation.*
Each starter category row carries a trash icon — the smallest target in the flow at exactly
44pt, sitting on the swipe-prone right edge — and "tapping… deletes that category
immediately. No confirmation prompt or undo." A first-run user exploring the new screen can
wipe their starter categories by accident, with no recovery. **Fix:** Add an **Undo**
snackbar on delete (cheapest, preferred), or a confirm dialog. Consider moving destructive
delete behind a swipe or an edit mode rather than exposing it on every row at all times.

### Medium — schedule soon; not all blockers

**M-1 — Full gating with no preview of the product.**
*Screen 1. Violates: let users evaluate before committing; reduce up-front cost.*
"Tallyroo has no functionality available without an account… no demo, sample workspace, or
read-only mode." For a personal finance app — where handing over an email and verifying it is
a real ask — requiring full sign-up before the user sees a single screen of value is a
top-of-funnel leak, and you're about to pour paid traffic into it. **Fix (larger, see
below):** Offer a tappable sample/demo workspace or a couple of preview screens before the
"Create account" wall. At minimum, strengthen the Welcome value proposition beyond the
"Spend with intent" tagline so the sign-up ask is motivated.

**M-2 — Required vs. optional profile fields are indistinguishable.**
*Screen 5. Violates: visibility of system status; recognition over recall.*
Display name and Home currency gate submission; Monthly budget does not — yet "nothing in
the layout, ordering, or per-field chrome distinguishes" them. Only the *optional* field is
labeled (with "Optional — you can set this later"). The button sits greyed with no
explanation of what's missing. **Fix:** Mark the two required fields (e.g. "Required" or an
asterisk), and when the disabled button is tapped, highlight the unfilled required field(s).
Also reconsider whether **Display name is needed at all** for a single-user expense tracker —
dropping it removes a required field and shortens the form.

**M-3 — "Next" is a weak, inconsistent affordance and is always tappable.**
*Screen 2. Violates: consistency & standards; affordance/discoverability.*
The primary action is a "plain text link 'Next'… bottom-left… not a button," while every
other step uses a full-width pinned button. It's easy to miss, and it's "always tappable"
even when the field is empty, guaranteeing pointless failed round-trips. **Fix:** Make it the
same full-width primary button used elsewhere, pinned bottom, disabled until the field is
non-empty and passes a basic client-side email format check.

**M-4 — Home empty state is a dead end.**
*Screen 6. Violates: empty states should guide the next action.*
If a user deletes all categories, the body shows only **"No data."** with "no further
guidance, illustration, or action," and "nothing on the empty body indicates" how to add
anything. [ASSUMPTION] Adding an expense requires picking a category, so a user who has
deleted every category may be unable to add expenses at all — making this a functional dead
end, not just a cosmetic one. **Fix:** Replace "No data." with a clear first-action prompt
("Add your first expense" / "Add a category") wired to the relevant action, and ensure
categories can be re-created from this state.

### Low — backlog

**L-1 — Confirmation toast adds latency.** *Screen 2.* The "Looks good" toast before the
transition inserts a deliberate pause on the happy path; once H-1's loading state lands, this
is redundant. Drop it or shorten it.

**L-2 — Duplicate submit affordances on Profile.** *Screen 5.* "Done" (top-right) and
"Finish setup" (bottom) fire the same submission. Harmless but mildly redundant; pick one, or
keep both and ensure both show the H-1 loading state.

**L-3 — Inconsistent primary-action styling across the flow.** *All screens.* Primary actions
vary in shape (text link vs. filled button), placement (bottom-left vs. full-width bottom),
and color (teal throughout, then green on Screen 5's "Finish setup"). The green terminus is a
defensible intentional accent; the rest reads as drift. Standardize on one primary-button
pattern, with color used meaningfully rather than per-screen.

---

## Quick wins vs. larger fixes

**Quick wins — landable this sprint, before launch:**

- **C-1 (partial):** Add **Resend email** (with cooldown) and **Change email** on Screen 4.
  Re-enabling Back here is a one-line change. *(The background-poll auto-advance is the only
  larger part.)*
- **C-2:** Intercept the Back gesture on Screen 5 and gate `DELETE /signup/abandon` behind a
  confirm dialog (or make Back a no-op). Small, high-impact.
- **H-1:** Add spinner + disable-on-tap to network actions on Screens 2, 3, 5. Mechanical,
  repeatable.
- **H-2:** Map the `422` (and malformed-email) responses to human copy + a "Sign in instead"
  link.
- **H-3:** Persist the email in the sign-up view-model so Back doesn't blank it.
- **H-4:** Add an Undo snackbar to category deletion on Screen 6.
- **M-2:** Mark required fields and highlight what's missing when the button is disabled.
- **M-3:** Promote "Next" to the standard primary button; add client-side format check.
- **L-1 / L-2 / L-3:** Copy/styling cleanups; bundle opportunistically.

**Larger fixes — need real design/eng, can follow launch:**

- **M-1:** A demo/sample workspace or pre-auth preview to reduce the cost of the sign-up wall.
  This is a strategic conversion lever but a genuine feature, not a sprint tweak.
- **C-1 (auto-advance):** Background polling / deep-link return so verified users skip the
  manual "I've verified" tap entirely.
- **M-4:** A proper guided empty state on Home, plus ensuring categories are re-creatable —
  touches the (out-of-scope) add-expense and category model.
- **M-2 (display name):** Removing Display name as a required field (or entirely) is small in
  UI but should be confirmed against any downstream dependence on the value.

---

*Notes:* [ASSUMPTION] "so-so connection" in the brief is taken to mean the multi-second
round-trips the handoff describes are the norm, not the exception, for your target users.
[ASSUMPTION] Expense entry requires an existing category (see M-4); if categories are
optional at expense time, M-4 drops from a functional dead end to a cosmetic one but the fix
is unchanged.
