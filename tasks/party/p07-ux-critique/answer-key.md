# P7 — Answer Key (SEALED) — UX critique of the Tallyroo onboarding flow

**Do not seed.** Never enters a cell directory. Planted-truth task: objective recall
against this key, scored found / partial / missed per item plus a precision note.

Ground truth: 10 usability problems embedded in `reference/flow.md`. Each is keyed to a
recognized usability heuristic (Nielsen's 10 + common UX-debt patterns). The flow is
written as a neutral spec/handoff doc and does NOT flag any of these as problems — the
solver must recognize them. Difficulty is mixed: 7 obvious-to-moderate, 3 subtle
(K2 state-loss, K4 error-recovery dead-end, K9 destructive-back). Subtle items are
second-order / interaction-level, not surface config typos.

Detectability note: every item below is fully determined by the text of `flow.md`, but
several are no longer stated as a flagged defect — the behavior is described in neutral
implementation prose and the solver must read it against usability principles to recognize
the problem. In particular the state/navigation items (K2, K9) are folded into surrounding
narrative rather than dedicated "Back navigation" paragraphs, and K10 must be reconstructed
by collating the primary control across screens (the old summary table has been removed).
A solver does not need outside knowledge of the app. Conversely none of these is guessable
without reading flow.md (the specific copy, transitions, and state behavior are the
evidence).

---

### K1 — Forced account creation before any value [obvious]
- What it is: The app shows zero functional value until the user has created an account,
  verified email, and finished setup; there is no guest/try-first path. The very first
  screen after splash forces "Create account" or "Sign in" with no third option.
- Where detectable: `flow.md` Screen 1 (Welcome) — only two buttons, "Create account" and
  "Sign in"; the Summary line "Tallyroo has no functionality available without an account."
- Heuristic: Forced registration before value / "User control & freedom"; conversion
  anti-pattern (gating value behind signup).
- Minimum credit: Solver notes value is gated behind mandatory account creation with no
  guest/explore/skip-signup path, and that this should be deferrable.

### K2 — State loss on back-navigation from the password screen [subtle]
- What it is: Sign-up is split across two screens (email on Screen 2, password on
  Screen 3). Tapping the device/OS Back button on Screen 3 returns to Screen 2 but the
  email field is re-rendered EMPTY — the previously entered email is discarded and must be
  retyped. Progress is silently lost on a normal navigation action.
- Where detectable: Cross-reference required. Screen 2 describes the email field as binding
  to "a fresh per-presentation view-model, so whatever it holds reflects the current
  presentation of the screen rather than any prior session." Screen 3's forward/back prose
  states the back gesture "pop[s] to Screen 2 (Email), which is re-presented from scratch on
  each arrival per its per-presentation binding (see Screen 2); a forward tap from there
  re-runs the email step." The solver must connect "re-presented from scratch" + "per-
  presentation binding" to realize the previously-typed email is gone and must be retyped.
  No paragraph states "the email is lost" outright. Note Screen 3 deliberately reassures
  that the *password* is retained server-side — the contrast (password kept, email dropped)
  is the tell, not a blanket "progress is lost."
- Heuristic: "User control & freedom" / error prevention; unsaved-state loss on back.
- Minimum credit: Solver identifies that going back loses the already-entered email (state
  not preserved) and that the field should retain its value. Just saying "navigation is
  confusing" without the data-loss mechanic is partial.

### K3 — Required fields are unlabeled as required [moderate]
- What it is: On the profile setup screen, "Display name" and "Home currency" are
  mandatory (the Continue button is disabled until both are filled) but neither carries any
  required indicator, and the screen presents them identically to the genuinely optional
  "Monthly budget" field. The user cannot tell which fields are required until they try to
  proceed.
- Where detectable: `flow.md` Screen 5 (Profile setup) — the field rows carry no asterisk /
  "required" text; "Finish setup" stays greyed until Display name + Home currency hold a
  value, while Monthly budget alone carries the "Optional" helper line. The closing sentence
  ("nothing in the layout, ordering, or per-field chrome distinguishes the two that gate
  submission from the one that does not") states the symptom without naming it a defect; the
  solver infers the user can't tell which fields are required up front.
- Heuristic: "Visibility of system status" / error prevention; unlabeled required fields.
- Minimum credit: Solver notes required fields aren't marked as required (no indicator /
  indistinguishable from optional), so the user can't tell what's mandatory up front.

### K4 — Failed email-verification step has no recovery path [subtle]
- What it is: After sign-up the app sends a verification email and shows a screen with only
  an "I've verified — continue" button. If the email never arrives (or the link expired),
  there is no "Resend email," no "Change email address," and no "Skip for now." The single
  button, when tapped before verification completes, shows an error and returns the user to
  the same dead-end screen. The user is stuck with no way to recover in-app.
- Where detectable: `flow.md` Screen 4 (Verify email). The doc no longer enumerates the
  missing controls. It states the "I've verified — continue" button "is the only interactive
  element rendered in the body," that on failure the banner appears and "the screen
  otherwise returns to its initial rendered state," and — in a separate trailing paragraph —
  that the verification email "is dispatched once, on entry to the screen ... the build does
  not re-fire it after that." The solver must infer from "only interactive element" + "does
  not re-fire" that there is no resend, no change-address, and no skip — i.e. a failed/lost
  verification has no in-app recovery. The Back gesture is also noted disabled here, sealing
  the dead-end.
- Heuristic: "Help users recognize, diagnose, and recover from errors"; no error recovery.
- Minimum credit: Solver identifies the verification step is a dead-end on failure — no
  resend / change-address / skip — leaving the user with no in-app way forward. Naming only
  that copy is bad without the missing-recovery point is partial.

### K5 — Hidden system status during a long operation [moderate]
- What it is: When the user taps "Finish setup," the app performs a multi-second server
  call (creating the account workspace + importing starter categories). During this the UI
  shows no spinner, no progress, and no disabled state — the screen appears frozen and the
  button stays tappable, inviting repeat taps.
- Where detectable: `flow.md` Screen 5 → "On Finish setup" paragraph: the round-trip "can
  run for several seconds," and "The screen holds its rendered state until the call returns —
  the same controls stay on screen and accept taps throughout." No sentence says "no
  spinner" outright; the solver infers from "holds its rendered state" + "accept taps
  throughout" that there is no progress feedback and the button invites repeat taps.
- Heuristic: "Visibility of system status"; missing progress/loading feedback.
- Minimum credit: Solver notes the long finish-setup operation gives no loading/progress
  feedback (and the button stays tappable), so the user can't tell it's working.

### K6 — Destructive action without confirmation [obvious]
- What it is: On the first-run home screen, each sample/starter category row has a trash
  icon that permanently deletes the category on a single tap — no confirmation dialog, no
  undo. An accidental tap is unrecoverable.
- Where detectable: `flow.md` Screen 6 (Home / first run) — "Tapping the trash icon on a
  category row deletes it immediately. No confirmation prompt or undo is offered."
- Heuristic: "Error prevention" / "User control & freedom"; destructive action w/o confirm
  or undo.
- Minimum credit: Solver flags the one-tap permanent delete with no confirm/undo and
  recommends a confirmation or undo affordance.

### K7 — Poor / unhelpful empty state [moderate]
- What it is: If the user deletes all starter categories (or before any expense is added),
  the home screen's main area shows only the literal text "No data." centered on a blank
  screen — no explanation, no illustration, and no call-to-action or button to add the
  first expense/category. The user is left with no guidance on what to do next.
- Where detectable: `flow.md` Screen 6 — empty-state paragraph: "the list area displays the
  text 'No data.' with no further guidance or action."
- Heuristic: Empty-state design / "Recognition rather than recall"; dead-end empty state.
- Minimum credit: Solver notes the empty state is unhelpful (bare "No data." with no
  guidance or add-action) and should onboard the user toward a first action.

### K8 — Jargon / unactionable error copy [moderate]
- What it is: When sign-in or sign-up fails server-side, the error shown to the user is a
  raw technical/jargon string ("Error 422: validation_failed (constraint: unique_email)")
  rather than plain language explaining what went wrong and what to do. The user is exposed
  to internal codes and constraint names.
- Where detectable: `flow.md` Screen 2 — on failure the banner is "surfaced to the user
  exactly as the service returns it: 'Error 422: validation_failed (constraint:
  unique_email)'." The doc frames this neutrally (as faithful pass-through of the API
  string); the solver recognizes that a raw code/constraint name shown to an end user is the
  defect.
- Heuristic: "Match between system and the real world" / error-message quality; jargon in
  copy.
- Minimum credit: Solver flags the error message exposes raw codes/jargon and should be
  rewritten in plain, actionable language (e.g. "That email is already registered — sign
  in instead?").

### K9 — Destructive back-button on profile setup discards the whole account [subtle]
- What it is: On the profile-setup screen (Screen 5), pressing the OS Back button does NOT
  return to the previous screen — it silently deletes the just-created (unverified) account
  and dumps the user back to the Welcome screen, with no warning and no confirmation. A
  habitual back-press destroys all sign-up progress. This is distinct from K2 (field-level
  loss): here Back is wired to an unannounced destructive teardown.
- Where detectable: `flow.md` Screen 5, folded into the closing narrative (no longer a
  "Back navigation" heading): the screen "is presented without a back chevron," but "The
  OS/hardware Back gesture is still live, however, and resolves to `DELETE /signup/abandon`:
  it tears down the account assembled across Screens 2–4 and drops the user back at Screen 1
  (Welcome)." The destructiveness is conveyed by the `DELETE .../abandon` endpoint + "tears
  down the account" + "runs the moment the gesture is recognized, with the screen showing
  nothing between the gesture and the return." No sentence says "no warning/confirmation"
  explicitly — the absence is shown by the gesture executing immediately with nothing
  rendered in between. The solver must read the endpoint semantics and the immediacy to see
  that a habitual back-press silently destroys all sign-up progress.
- Heuristic: "User control & freedom" + "Error prevention"; destructive/ irreversible
  navigation with no warning (consistency-of-control violation — Back means "destroy" here
  but "go back" elsewhere).
- Minimum credit: Solver identifies that Back on the setup screen destroys the new account
  (not just navigates back) without warning, and that this needs a confirm or a
  non-destructive back. Partial if they only restate K2 without the account-destruction.

### K10 — Inconsistent affordance for the primary action [moderate]
- What it is: The primary "advance" control is styled and labeled differently on nearly
  every screen with no consistent pattern: a filled blue button labeled "Continue" on one
  screen, a plain underlined text link labeled "Next" on another, a top-right "Done" in the
  nav bar on another, and a full-width green "Finish setup" on the last. The user must
  re-learn where the forward action lives and what it looks like on each step.
- Where detectable: `flow.md` — the consolidated control-reference table has been REMOVED.
  The solver must now collate the primary "advance" control screen by screen from each
  screen's body description: Screen 1 filled teal button "Create account" (bottom center);
  Screen 2 plain underlined teal text link "Next" (bottom-LEFT, always tappable); Screen 3
  filled teal button "Continue" (full-width, bottom-pinned); Screen 4 filled teal button
  "I've verified — continue"; Screen 5 a top-right nav-bar text action "Done" AND a
  full-width GREEN button "Finish setup" (label, color, and position all differ); Screen 6
  the "+" icon. The variance lives only in the per-screen prose now.
- Heuristic: "Consistency and standards"; inconsistent affordance/placement for the same
  function.
- Minimum credit: **Found** requires the solver to enumerate at least THREE distinct
  primary-control variants drawn from across the flow — e.g. naming the label drift
  (Continue / Next / Done / Finish setup), the form drift (filled button vs. plain text
  link vs. nav-bar action), AND/OR the position/color drift (bottom-pinned vs. bottom-left
  vs. top-right; teal vs. green) — and recommend one consistent pattern. **Partial** if the
  solver only notes a single mismatch (e.g. "the 'Next' on Screen 2 is a text link instead
  of a button") without establishing the across-flow inconsistency, or asserts inconsistency
  generically without citing 3+ concrete variants.

---

## Precision note (false-positive watch)

These are NOT planted defects; a solver asserting them as confident findings counts against
precision (the flow is deliberately fine on these points):

- Password rules ARE shown inline before submission (Screen 3 lists them) — claiming "no
  password requirements shown" is a false positive.
- Email verification IS required for a real reason (stated) — claiming "email verification
  is unnecessary friction" is a defensible design opinion, not a planted issue; don't count
  it as a key hit.
- The flow DOES support "Sign in" for returning users — claiming "no path for existing
  users" is wrong.
- Home currency defaults sensibly by locale on the field (Screen 5) — claiming "currency
  has no default" is a false positive.
- **DECOY — inline email validation.** Screen 2 deliberately describes server-side
  validation on "Next" with a "Looks good" confirmation toast. Claiming "the email field has
  no inline/as-you-type validation" as a confident defect is a precision miss: deferring
  format+uniqueness to a server round-trip (uniqueness genuinely can't be checked client-
  side) is a defensible design, not a planted issue. The planted Screen-2 issue is K8 (the
  raw error copy), NOT the validation timing.
- **DECOY — verify-screen body copy.** The Screen 4 copy ("Check your email" / "We sent a
  verification link to your address. Open it to continue.") is clear, plain, and adequate.
  Flagging the *wording* of the verify screen as unclear/jargon is a precision miss — the
  planted Screen-4 issue is the missing recovery path (K4), not the copy. A solver who
  critiques the copy but misses the recovery dead-end has found a phantom and missed K4.
- **DECOY — tap-target size / contrast / typography.** The closing visual notes state tap
  targets meet the 44pt minimum, teal-on-white buttons pass WCAG AA contrast, and type
  sizes are reasonable. Asserting an accessibility defect on touch-target size or color
  contrast is a precision miss — those are stated as compliant. (Accessibility of the
  *unlabeled required fields* for screen readers is a legitimate extension of K3, not a
  decoy — distinguish.)

## Difficulty spread (for calibration)

- Obvious: K1, K6
- Moderate: K3, K5, K7, K8, K10
- Subtle (second-order / interaction): K2, K4, K9

Target cold-solo recall 3–8 / 10 (post-hardening band). A cold pass should reliably catch
K1/K6/K7 and likely K8; K5 now requires reading past "holds its rendered state" rather than
a literal "no spinner." The three state/recovery items (K2, K4, K9) are folded into prose
and demand cross-referencing or endpoint-semantics reading, and K10 now requires collating
3+ control variants across screens (the summary table was removed) — these four are where
arms separate. A solver that lands ≥9/10 cold means the prose folding was too thin; re-tune.
