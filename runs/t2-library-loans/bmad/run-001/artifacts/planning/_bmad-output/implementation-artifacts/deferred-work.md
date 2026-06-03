# Deferred Work

Items surfaced during review but intentionally out of scope for the current change.

## From: spec-loans-api (review, 2026-05-27)

- **Concurrency safety of the in-memory store (latent, design-level).** `LoanService.checkout` does a check-then-act on the member's active-loan count and a read-modify-write on `Book.available_copies`. FastAPI runs sync endpoints in a threadpool, so two concurrent checkouts could both pass the `MAX_ACTIVE_LOANS` or `available_copies > 0` guard and drive state past its invariant (limit exceeded, or `available_copies` negative). This is a property of the deliberately single-process, in-memory repository design (`repository.py` docstring; spec explicitly scopes out a persistence/DB backend), not unique to this story — the same applies to any future mutating endpoint. Resolve when/if the store is backed by a real database (transactions/row locks) or a process-wide lock is introduced. Not reproducible by the current sequential test suite.
