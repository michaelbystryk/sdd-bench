# Tallyroo Onboarding — Usability Critique

*Scope: the new-user flow as shipped in build 4.2 — Welcome → Email → Password → Verify email → Profile setup → Home (first run), per the engineering/design handoff. Reviewed as a new user on an unreliable connection. Findings point to specific screens and behaviors and propose fixes an engineer or designer can act on this sprint.*

---

## Summary

The flow is structurally sound and parts of it are genuinely good — the password step (Screen 3) does inline rule-checking with a disabled-until-valid button, which is exactly right. But the onboarding has **three failure points that will directly cost you installs**, plus a cluster of smaller frictions that match the "it fought me" feedback.

The headline read: the leak you're seeing before Home is almost certainly concentrated at **email verification (Screen 4)**, which can become a literal dead end, and at the **Welcome gate (Screen 1)**, which asks for full commitment before showing any value. A third issue — the back gesture on **Profile setup (Screen 5)** silently deleting the user's entire account — won't show up clearly in funnel data but will quietly send people back to the start, where some won't return. None of the three are stylistic; they're points where a normal user cannot proceed, loses work, or gets a frightening message.

The good news: most of the high-severity fixes are small and additive. The one expensive recommendation (ungating the app) is a roadmap bet, not a sprint task, and is called out separately so it doesn't get confused with the quick wins.

---

## Issues

Severity scale: **Critical** = blocks completion or destroys user data; **High** = significant drop-off or confusion risk; **Medium** = friction that erodes trust; **Low** = polish.

### 1. Verify-email can become a permanent dead end — **Critical**
*Heuristic: User control & freedom; Error recovery (Nielsen #3, #9)*
**Where:** Screen 4. The verification email is sent exactly once, on entry, and is never re-sent. The OS back gesture is disabled here. The only control re-checks verification status.
**Why it hurts:** A single typo on Screen 2 (`alex@gmial.com`) is unrecoverable — the mail goes nowhere, the user can't go back to fix the address, there's no resend, and the only button checks a status that will never flip. The non-typo cases (slow delivery, spam folder) are nearly as bad: no "didn't get it?" path. This is the most likely single cause of installs that never reach Home.
**Fix:** Add two affordances to Screen 4: a **"Resend email"** link (with a short cooldown), and a **"Wrong address? Change it"** link that returns the user to an editable email step. Keep back disabled if you want — the fix is a forward escape hatch, not re-enabling back. Bonus: poll verification status in the background and auto-advance so the user doesn't have to tap at all.

### 2. Back gesture on Profile setup silently deletes the whole account — **Critical**
*Heuristic: Error prevention; User control & freedom (Nielsen #5, #3); Consistency (#4)*
**Where:** Screen 5. There's no back chevron, but the OS back gesture is live and resolves to `DELETE /signup/abandon`, tearing down the account built across Screens 2–4 and dropping the user at Welcome — instantly, with nothing shown in between and no confirmation.
**Why it hurts:** Screens 2, 3, and 6 train the user that back means "go back one step." Here the identical gesture is irreversible destruction. A user who reflexively swipes back to double-check something loses their account and lands back at the Welcome gate — a place some won't pass a second time.
**Fix:** Intercept the back gesture on Screen 5 and show a confirmation sheet — *"Leave setup? Your account will be discarded."* — defaulting to **Cancel**. The destructive call already exists; you're only gating it behind a confirm. (~½ day.)

### 3. Raw API error string shown to the user — **Critical (trivial to fix)**
*Heuristic: Help users recognize, diagnose, and recover from errors (Nielsen #9); Match between system and real world (#2)*
**Where:** Screen 2. On an already-registered email the banner reads, verbatim: **"Error 422: validation_failed (constraint: unique_email)"**.
**Why it hurts:** It's meaningless and alarming to a human, and it hides the one useful action — this person already has an account and should **sign in**. A recoverable moment becomes a wall.
**Fix:** Map known errors to plain copy with a next step: `unique_email` → *"Looks like you already have an account."* with a **Sign in** link. Add a friendly generic fallback for anything else. **Never surface server codes anywhere in this flow** — audit the other network calls (Screens 4, 5) for the same leak. (~A few hours.)

### 4. No loading state on multi-second network calls — **High**
*Heuristic: Visibility of system status (Nielsen #1)*
**Where:** Screen 5's `POST /profile/complete` "can run for several seconds" with controls still live and no spinner; the same gap exists on Screen 2's and Screen 4's calls.
**Why it hurts:** The user taps "Finish setup," nothing visibly happens, and they tap again (double-submit) or — worse — reflexively swipe back into the account-deletion trap in Issue 2. The app feels frozen exactly when it's doing the most.
**Fix:** On every in-flight call, disable the triggering control and show an inline spinner / progress state until it returns. Mechanical, and it directly de-risks Issues 2 and 5.

### 5. Required fields aren't marked — the *optional* one is — **High**
*Heuristic: Error prevention; Visibility of system status (Nielsen #5, #1)*
**Where:** Screen 5. "Finish setup" stays disabled until **Display name** and **Home currency** are filled, but the only field with helper text is **Monthly budget** — *"Optional — you can set this later."* The two required fields look identical and unlabeled; the one optional field is the one that's marked.
**Why it hurts:** The user faces a greyed-out button with no indication of what it wants. (Currency is locale-prefilled, so in practice Display name is the silent blocker — which makes the unexplained disabled state more puzzling, not less.)
**Fix:** Add a required indicator to Display name and Home currency, and/or show the disabled button's reason (*"Add a display name to finish"*). Small.

### 6. Category delete is instant and irreversible on the home screen — **High**
*Heuristic: Error prevention; User control & freedom (Nielsen #5, #3)*
**Where:** Screen 6. A 44pt trash icon sits on the right edge of every category row and deletes immediately — no confirmation, no undo.
**Why it hurts:** It's the easiest accidental tap in the app, on the primary screen, and the loss is permanent. A new user exploring their starter categories can wipe them by mistake.
**Fix:** Delete-with-undo — remove the row and show a snackbar *"Category deleted — Undo"* for a few seconds. (Preferred over a confirm dialog, which gets tiring on a list.) Cheap.

### 7. Inconsistent and over-permissive primary action on Email — **Medium**
*Heuristic: Consistency & standards; Error prevention (Nielsen #4, #5)*
**Where:** Screen 2's primary action is a plain teal **text link "Next,"** bottom-left, and it's **always tappable** — even on an empty field. Screen 3's primary is a full-width filled button, disabled until valid. The two sign-up steps disagree on what "primary action" looks like.
**Why it hurts:** A primary action styled as a text link reads as secondary and is easy to miss; being always-tappable invites a wasted server round-trip on empty/garbage input (painful on a slow connection). The inconsistency with Screen 3 makes the flow feel unsystematic.
**Fix:** Make "Next" a filled button consistent with Screen 3, and add a lightweight client-side email-format check that keeps it disabled until the field looks like an email. Reserve the server round-trip for uniqueness.

### 8. Email is forgotten on back-navigation; password is remembered — **Medium**
*Heuristic: Consistency & standards; User control & freedom (Nielsen #4, #3)*
**Where:** Screens 2–3. The email field binds to a fresh per-presentation view-model, so popping back from Password to Email shows a **blank** field — the user retypes their email. The password, by contrast, is retained server-side across the same navigation.
**Why it hurts:** The asymmetry ("it remembers my password but forgets my email") is precisely the kind of thing that reads as the app fighting the user. It also forces an unnecessary re-validation round-trip.
**Fix:** Persist the entered email in the sign-up view-model instead of re-presenting blank. This is also the keystone for Issue 1 — a durable email value lets you pre-fill the "change address" field on the verify screen.

### 9. First-run empty state is a dead end — **Low**
*Heuristic: Help and guidance; Recognition over recall (Nielsen #10, #6)*
**Where:** Screen 6. With no categories/expenses, the body shows only **"No data."** — no illustration, no copy, no pointer to the "+" that's the sole way to add anything.
**Why it hurts:** It's the user's first *owned* screen and it says nothing about what to do next. Low impact relative to the leaks above, but a missed first impression — and now easier to reach given Issue 6.
**Fix:** Replace "No data." with a short prompt and a button — *"Add your first expense"* wired to the existing "+". Behind the higher-priority fixes.

### 10. No visible progress through onboarding — **Low**
*Heuristic: Visibility of system status (Nielsen #1)*
**Where:** Sign-up steps are internally "1 of 2" but the screen titles read only "Create account"; the user has no sense of how many steps remain.
**Why it hurts:** Uncertainty about length increases abandonment, especially when verification adds a perceived extra step.
**Fix:** Add a lightweight step indicator (e.g., "Step 1 of 3") or progress bar across the sign-up screens. Low effort, low urgency.

> **Strategic note — not a sprint item:** The entire app is gated behind sign-up (Screen 1): no demo, sample workspace, or read-only mode before authentication. For a low-stakes personal expense tracker, requiring email + password before showing any value is very likely the **largest top-of-funnel leak**, and it's where install-campaign spend will be least efficient. This is flagged deliberately as a **product/roadmap bet, not a quick win** — a true guest/demo mode requires a client-side workspace and a sign-up migration path, since today the workspace is server-provisioned at `POST /profile/complete`. Recommend scoping it as a fast-follow; do not block launch on it, but do not let its cost keep it off the roadmap. **[ASSUMPTION]** The category — personal finance — is one where users expect to try before trusting; if your positioning assumes pre-committed users (e.g., arriving from a paid sign-up), this matters less.

---

## Quick wins vs. larger fixes

**Quick wins — landable before launch (copy, a confirm dialog, a spinner, a string map):**

- **#3** — Replace the raw "Error 422…" string with plain copy + a Sign in link; audit other calls for leaked codes. *(hours)*
- **#2** — Confirmation sheet on the Screen 5 back gesture before `DELETE /signup/abandon`. *(~½ day)*
- **#5** — Mark required fields (or explain the disabled button) on Profile setup. *(small)*
- **#6** — Delete-with-undo snackbar for category rows. *(small)*
- **#4** — Loading/disabled states on the three in-flight network calls. *(small, mechanical)*
- **#9 / #10** — Empty-state CTA and a step indicator, if time allows. *(small, lower urgency)*

**Larger fixes — real design/eng work, plan deliberately:**

- **#1** — Resend + change-email (and ideally background auto-advance) on the verify screen. This is the single highest-impact change for the drop-off you're seeing; it's larger because it touches verification state and the editable-email path. **Prioritize it even though it isn't a one-liner** — it depends partly on #8.
- **#8** — Persist the entered email across back-navigation (view-model change). Keystone for #1.
- **#7** — Unify the primary-action pattern across sign-up (button, not text link) and add client-side email validation.
- **Strategic gate (Screen 1)** — Demo/guest mode. Roadmap bet; scope as a fast-follow, not a launch blocker.

**Recommended sequence for this sprint:** ship the five quick wins (#2–#6) first — they're cheap and two of them stop active data loss — then land #1 + #8 together as the focused larger fix before you turn on acquisition spend. Everything else can follow.
