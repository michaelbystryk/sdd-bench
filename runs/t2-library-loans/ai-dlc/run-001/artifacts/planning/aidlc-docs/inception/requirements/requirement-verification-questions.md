# Requirement Verification Questions

The request is clear and its behavior is fully pinned by `tests/test_loans.py`, so
no functional clarifying questions were required. Only the mandatory extension
opt-in questions applied. Answers were collected via interactive prompt and are
recorded below.

## Question: Security Extensions
Should security extension rules be enforced for this project?

A) Yes — enforce all SECURITY rules as blocking constraints (recommended for production-grade applications)
B) No — skip all SECURITY rules (suitable for PoCs, prototypes, and experimental projects)
X) Other (please describe after [Answer]: tag below)

[Answer]: A — Yes, enforce. (Adds no new dependencies; existing code already follows
the applicable patterns. Most rules are N/A for this in-memory sample service.)

## Question: Property-Based Testing Extension
Should property-based testing (PBT) rules be enforced for this project?

A) Yes — enforce all PBT rules as blocking constraints
B) Partial — enforce PBT rules only for pure functions and serialization round-trips
C) No — skip all PBT rules (suitable for simple CRUD applications or thin layers)
X) Other (please describe after [Answer]: tag below)

[Answer]: C — No, skip. PBT requires the `hypothesis` library (a new dependency),
which the request explicitly forbids. The pinned example-based tests remain the
source of truth.
