# PM Persona Conversation — t4-fitness-app-rich / spec-kit / run-003

Auto-captured by `pm-ask` CLI. Each exchange logged with local timestamp.

Persona file: `harness/pm-persona-v1.md` (sha256 in README)
Task brief: `tasks/t4-fitness-app-rich/brief.md`
Reference: `tasks/t4-fitness-app-rich/reference/me.md`


## Q (2026-05-30 00:11:20 PDT)

Weight rounding rule for percentage-based prescriptions: Programs like 5/3/1, nSuns, and Madcow compute working weights as percentages of a training max, which rarely land on a loadable weight. What rounding rule should apply? Options: A) Round each prescribed weight to the nearest 5 lb (standard-plate increment); B) Round down to the nearest 5 lb (conservative, never over-prescribe); C) Round to the nearest increment achievable from the configured plate inventory (e.g. 2.5 lb if micro-plates owned, else 5 lb); or a different rule.

### A

Option C — round to the nearest increment your configured plate inventory can actually load.

---

## Q (2026-05-30 00:12:10 PDT)

Pinned canonical sources for contested programs (nSuns and GZCLP have multiple variants). Which variants should we pin per program? Options: A) Community-standard variants: nSuns = 9-set 5/3/1 LP (T1+T2, AMRAP-driven TM bump); GZCLP = Cody Lefever base LP (T1 5x3->6x2->10x1, T2 3x10->3x8->3x6, T3 3x15+ AMRAP); 5/3/1 = Wendler 2nd-ed with optional AMRAP; Madcow = standard 5x5 weekly ramp; PPL = Metallicadpa Reddit PPL. B) Same set but 5/3/1 with FSL (First Set Last) instead of BBB. C) You specify exact sources/variants per program.

### A

Option A — community-standard variants.

---

## Q (2026-05-30 00:12:49 PDT)

How should onboarding starting numbers seed each program's working state? Onboarding captures a working weight or estimated 1RM per lift, but linear programs (5x5/GZCLP) start from a working weight while 5/3/1 and nSuns run off a training max (typically 90% of 1RM). Since all 7 programs are seeded at once, what consistent rule converts the entered number into each program's anchor? Options: A) Normalize every entry to an estimated 1RM (via Epley if entered as weight x reps), derive each program's anchor: TM = 90% of e1RM for 5/3/1 and nSuns, conservative working-weight start for linear programs. B) Capture a working weight, use it directly for linear programs and as the training max as-is for 5/3/1/nSuns (no 90% derivation). C) Capture both an e1RM and a starting working weight separately, seed each program from whichever it canonically uses.

### A

Option A — normalize to e1RM, derive each program's anchor (TM at 90% for 5/3/1 and nSuns, conservative working-weight start for linear).

---

## Q (2026-05-30 00:13:30 PDT)

Reconciling chosen training days with a program's native day count. 'Help me pick' filters programs by days, but 'I'll choose' lets the user select any program -- and several have a fixed cadence (Reddit PPL is inherently 6-day, nSuns commonly 4-6, Madcow 3-day). Does day-count flex the program, or does the program define the cadence? Options: A) Program cadence governs: each program runs its canonical day structure; onboarding days filter 'help me pick' and pick a fitting template, but a manually-chosen program keeps its own cadence (PPL stays 6-day). B) Day-count governs: the app adapts/truncates any program to the chosen number of days per week. C) Hybrid: programs with selectable day-counts (nSuns 4/5/6) honor the choice; fixed-cadence programs (PPL) keep theirs.

### A

Option A — program cadence governs. A manually-chosen program runs its canonical structure; PPL stays 6-day.

---

## Q (2026-05-30 00:14:08 PDT)

Warm-up ramp scheme (needs a deterministic rule to be unit-testable). The warm-up ramp is auto-generated up to the working weight. What should the ramp compute from and how many steps? Options: A) Percentage ladder of the working weight -- e.g. empty bar -> ~40% -> 60% -> 80%, each plate-rounded to loadable weight, descending reps, skipped for very light working weights below a threshold. B) Fixed absolute jumps from the bar (e.g. +45 each set) until near the working weight. C) Program-defined warm-up where the program specifies one, else the percentage-ladder default.

### A

Option A — percentage ladder of the working weight, plate-rounded, with a skip threshold for light weights.

---
