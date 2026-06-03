# Requirements Verification Questions

The functional requirements for `postal_validator` are fully specified by `reference/formats.md`
and the contract in `tests/test_core.py` + `tests/test_cli.py`, so no functional clarifications
are needed. The questions below cover the mandatory extension opt-ins and approval cadence.

## Question 1: Security Baseline Extension
Should security extension rules be enforced for this project?

A) Yes — enforce all SECURITY rules as blocking constraints (recommended for production-grade applications)
B) No — skip all SECURITY rules (suitable for PoCs, prototypes, and experimental projects)
X) Other (please describe after [Answer]: tag below)

Context: This is a self-contained, offline parsing/validation utility with no network, auth,
secrets, persistence, or external attack surface. Input is still handled safely regardless.

[Answer]: B

## Question 2: Property-Based Testing Extension
Should property-based testing (PBT) rules be enforced for this project?

A) Yes — enforce all PBT rules as blocking constraints
B) Partial — property-style tests for pure functions / round-trips, implemented with the
   standard library only (e.g. `random` + the existing test runner), since the project mandates
   no third-party dependencies (so no `hypothesis`)
C) No — skip all PBT rules
X) Other (please describe after [Answer]: tag below)

Context: validate()/normalize() are pure functions with normalization round-trips — good PBT
candidates — but the "standard library only" constraint rules out `hypothesis`, and it is not
installed in this environment.

[Answer]: B

## Question 3: Approval Cadence
How would you like to handle the AI-DLC approval gates for this small, fully-specified task?

A) Pause for explicit approval at every stage gate (Requirements, Planning, Code Gen, Build & Test)
B) Approve the plan once, then proceed autonomously through code generation and build/test,
   pausing only if a real decision or ambiguity arises
X) Other (please describe after [Answer]: tag below)

[Answer]: B
