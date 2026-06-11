# Lumen Wallet Platform — Threat Model

*Scope: the as-built architecture in `reference/system-description.md` (v0.9). This
is an internal attacker-and-reviewer read, prioritizing incorrect money movement
and customer-PII exposure. Severity is rated Critical / High / Medium / Low based
on impact (money or PII) × exploitability against this system as described.
Assumptions are tagged [ASSUMPTION].*

---

## Assets & trust boundaries

### Assets (in priority order)

1. **Wallet balances and the ledger** — the source of truth for ~$4M of customer
   funds. Integrity is the single most important property.
2. **Money-movement capability** — `POST /transfers`, `POST /payouts` (irreversible
   cash-out to a bank), and `POST /admin/wallets/{id}/adjust` (mints/burns balance).
3. **Customer KYC PII** — legal name, DOB, national id (SSN/equivalent), and the
   ID-document image, in `kyc_records`. Regulated data; breach is reportable.
4. **Authentication secrets** — SMS OTP codes, the 30-day JWTs, the HS256 signing
   key, the processor API key, DB credentials.
5. **Transaction history** — per-wallet ledger rows (financial PII).
6. **Accountability** — the ability to attribute a money movement to an actor.

### Trust boundaries

- **B1 — Internet ↔ Customer API** (via edge LB). Any anonymous or
  authenticated-but-untrusted client. Currently *unthrottled* at the auth layer.
- **B2 — Customer ↔ Admin privilege.** Both run in the same process, behind the
  *same* auth middleware, and admins hold *the same kind of JWT* as customers.
  This is the weakest boundary in the system (see T1).
- **B3 — Public webhook endpoints ↔ external SaaS.** `/webhooks/processor` and
  `/webhooks/kyc` are publicly reachable and (as described) unauthenticated.
- **B4 — VPC perimeter.** Internal workloads trust each other by network position;
  the ledger does not re-derive a caller identity per request.
- **B5 — Lumen ↔ processor / KYC provider** (outbound HTTPS; real money moves over B5).
- **B6 — Data egress to the third-party logging SaaS** (full bodies + headers).
- **B7 — Data at rest** — Postgres (disk-encrypted only), Redis, nightly backups.

---

## Threats

> Notation: **[STRIDE]** = Spoofing, Tampering, Repudiation, Information disclosure,
> Denial of service, Elevation of privilege.

### T1 — Any customer JWT can call the admin API — **Critical** — [Elevation of privilege]
`/admin/*` sits behind the *same* middleware as the customer API; that middleware
only verifies the JWT signature/expiry and sets `req.userId`, then "the admin
routes then run." No role/claim check is described, and admins carry the same JWT
type as customers. A normal user can therefore call:
- `POST /admin/wallets/{id}/adjust` with a large positive `delta` to **mint balance
  into their own wallet**, then cash it out via `POST /payouts`;
- `POST /admin/users/{id}/verify` to **self-approve KYC** and raise their own limits;
- `GET /admin/users/{id}` to **read any user's full KYC PII** (name, DOB, SSN, doc URL).
This single gap turns every authenticated user into an admin. Direct path to both
top-priority harms (money out + bulk PII).

### T2 — Broken object authorization on transfers (move money from any wallet) — **Critical** — [Elevation of privilege / Tampering]
`POST /transfers` authenticates the JWT but then "proceeds with the wallet ids
supplied in the request." Nothing ties `fromWalletId` to `req.userId`. An attacker
sets `fromWalletId` to a *victim's* wallet and `toWalletId` to their own and drains
it. `walletId`s are sequential integers, so victims are trivially enumerable.

### T3 — IDOR on wallet reads (balance + transaction history) — **High** — [Information disclosure]
`GET /wallets/{walletId}` and `GET /wallets/{walletId}/transactions` load by the
path id with no ownership check, and ids are sequential. Any authenticated user can
walk `1..N` and harvest every user's balance and full transaction history (financial
PII for ~180k users). Same root cause as T2.

### T4 — OTP brute force → account takeover — **Critical** — [Spoofing]
Login is a **6-digit** code (10⁶ space), 10-minute validity, retries allowed, and
**no rate limiting in front of the auth service**. An attacker who knows a target's
phone number can request a code and then hammer `POST /auth/otp/verify`. Within the
10-minute window an unthrottled attacker can cover a large fraction of the keyspace;
repeated `otp/request` calls only help. Result: full takeover of any account,
including support staff (compounding T1). [ASSUMPTION] verify has no per-account
attempt cap; the doc says retries are permitted and lists no cap.

### T5 — Forged processor webhook → fake settlements / fake top-ups — **High** — [Spoofing / Tampering]
`POST /webhooks/processor` is public and, as described, performs no signature/HMAC
verification — it parses the body, finds the referenced payout/transaction, and
updates status. An attacker can POST a forged "top-up cleared" event to **credit a
wallet without real funds**, or mark a fraudulent payout `settled` to hide it.
[ASSUMPTION] a "top-up cleared" event is what credits balance; if top-ups credit via
this path, this is a direct money-creation bug.

### T6 — Forged KYC webhook → self-verify and raise limits — **High** — [Spoofing / Tampering]
`POST /webhooks/kyc` is public and unauthenticated; body is `{ userId, decision }`.
Anyone can POST `{ userId: <victim or self>, decision: "approved" }` to flip an
account to "verified," **raising transfer/payout limits** and defeating the KYC
control entirely. Enables larger-value abuse of T2/T7.

### T7 — Payout authorization & missing debit — **Critical** — [Elevation of privilege / Tampering]
`POST /payouts` takes `{ walletId, amount, bankAccountId }`. No ownership check on
`walletId` is described (same pattern as T2), so a payout can be requested *against
another user's wallet* to the attacker's `bankAccountId`. Worse, the described flow
creates a `pending` row and enqueues a job; the worker calls the processor and marks
`sent` — **no ledger debit of the wallet is mentioned anywhere in the payout path**.
[ASSUMPTION] if balance is never debited for payouts, a wallet can be cashed out
repeatedly with no balance reduction. Both issues move real money out, irreversibly.

### T8 — Payout double-send (no idempotency) — **High** — [Tampering / DoS-of-funds]
The Redis queue redelivers a job if the worker dies mid-job or the visibility window
lapses, and the worker retries up to 5×. The processor "treats each received
`POST /v1/payouts` as a distinct instruction" and **no idempotency key is sent**. A
timeout where the processor *actually succeeded* — or a redelivery — produces a
**duplicate real-world payout**. At low-thousands/day this is a recurring loss, not a
corner case.

### T9 — Transfer race condition / double-spend — **High** — [Tampering]
For `POST /transfers` the balance check and the ledger writes "are issued from the
request handler as ordinary application logic; each transfer is processed
independently." No row lock or atomic ledger transaction is described. Two concurrent
transfers from the same wallet can both pass the "≤ available funds" check before
either debit lands → **overdraft / spend-twice**. The in-place `balance` column
update (rather than a derived sum of ledger rows) makes the divergence durable.

### T10 — Internal ledger trusts network position + no dedupe — **High** — [Spoofing / Tampering / Elevation]
Inside the VPC, "an internal caller is whoever can reach the endpoint," the ledger
"records the debit it is handed and does not re-derive a caller identity," and "does
not track which requests it has already applied across retries." Any compromised
workload, SSRF foothold, or lateral movement can instruct the ledger directly; and
benign retries on these hops **double-apply** debits/credits. Amplifies T8/T9.

### T11 — Full request bodies + headers logged to a third-party SaaS — **Critical** — [Information disclosure]
The API logs **every request with full body and headers at INFO**, forwarded to a
third-party logging SaaS (B6). That stream contains: **OTP codes**, **`Authorization`
bearer JWTs** (valid 30 days → replayable account takeover), transfer/payout details,
and **KYC bodies with SSN/DOB/name**. Anyone with log-search access, or a breach of
the SaaS, gets both live credentials and regulated PII in one place. This is a PII
breach and a credential-theft vector simultaneously.

### T12 — KYC PII stored without field-level encryption — **High** — [Information disclosure]
`kyc_records` holds legal name, DOB, national id, and the document-image URL with
**only cloud disk-level encryption** — no column/field encryption. Disk encryption
protects a stolen physical disk, not a SQL-level compromise, a leaked nightly backup,
an over-broad credential, or T1/T3 exfiltration. [ASSUMPTION] the document-image URL
points to object storage whose own access control isn't described — if it's a
long-lived/unauthenticated URL, the ID images themselves leak.

### T13 — 30-day JWT, HS256, no revocation — **High** — [Spoofing]
Tokens are valid 30 days with no refresh/revocation flow and no role/audience claim.
A token leaked via T11 (or a stolen device) is usable for up to a month with no way
to kill it; there's no mechanism to invalidate sessions after a suspected compromise
or to distinguish admin tokens (feeds T1). HS256 also means the single shared secret
both signs and verifies — its leak forges *any* identity.

### T14 — Unbounded admin balance adjustment with no second control — **High** — [Tampering / Repudiation]
`POST /admin/wallets/{id}/adjust` applies an arbitrary positive/negative `delta` with
just a free-text `reason` — no amount cap, no maker/checker approval, no separate
admin auth factor. A single support account (or any user, via T1) can credit
arbitrary funds. Insider-risk and blast-radius problem even independent of T1.

### T15 — No tamper-evident audit trail for admin actions — **Medium** — [Repudiation]
"There is no dedicated tamper-evident audit log for admin actions beyond the normal
request logs and the ledger rows." Combined with admins sharing the customer identity
type (T1/T13), a disputed or fraudulent adjustment can't be reliably attributed, and
the only record lives in mutable app logs. Undermines SOC 2 / due-diligence directly.

### T16 — No edge rate limiting → SMS-bombing, enumeration, resource exhaustion — **Medium** — [DoS]
Rate limiting is "planned but not yet" in front of auth. `POST /auth/otp/request` can
be abused to **flood a victim's phone with SMS** (and run up SMS cost), to enumerate
which phone numbers are registered, and more broadly the unthrottled API is open to
volumetric DoS. (Also the enabling condition for T4.)

### T17 — Redis cached balance can diverge from the ledger — **Medium** — [Tampering / Information disclosure]
Reads are served from a cached balance in Redis, refreshed after a transfer. If the
cache refresh fails or lags, reads return a wrong balance; because the canonical
`balance` column is itself updated in place (not derived from ledger sums), there is
no authoritative reconciliation point. Mostly a correctness/integrity risk, but a
stale-high cache could be combined with T9 to mislead limit checks.

### T18 — Negative / malformed amount handling — **Medium** — [Tampering]
Bodies are schema-validated for *shape*, but the description doesn't state that
`amount`/`delta` sign and bounds are enforced. [ASSUMPTION] if a negative `amount` is
accepted by `POST /transfers`, it passes the "≤ available funds" check trivially and
inverts the debit/credit direction (pull funds from the destination). Worth an
explicit check even if today's schema happens to forbid it.

---

## Mitigations

**Authorization (T1, T2, T3, T7) — the highest-leverage fixes:**
- Add a real **authorization layer**, not just authentication. Put `/admin/*` behind
  a distinct role/claim check (and ideally a separate auth context for the ~6 staff;
  do not reuse customer JWTs for admin). (T1)
- On every wallet/transfer/payout/transaction handler, **verify the target wallet is
  owned by `req.userId`** before acting. Treat sequential ids as non-secret;
  authorization, not obscurity, is the control. (T2, T3, T7)
- Make `POST /payouts` **debit the ledger atomically** when the payout is created (or
  place a hold), so balance always reflects outstanding payouts. (T7)

**Authentication (T4, T13, T16):**
- Rate-limit and lock `otp/verify` (e.g. small per-account attempt budget, then
  cooldown), invalidate the code on success/expiry, and consider longer codes. Ship
  edge rate limiting now — it's already planned. (T4, T16)
- Shorten JWT lifetime and add a **refresh + revocation** path (token version / deny
  list keyed on user); add explicit role/audience claims. (T13)

**Webhooks (T5, T6):**
- Verify processor and KYC webhooks with the provider's **signature/HMAC** (or mTLS /
  allow-listed source + shared secret) and reject unsigned events. Make webhook
  handlers idempotent and never let a webhook be the sole authority that credits a
  balance or grants verification without correlating to an outbound request. (T5, T6)

**Money-movement integrity (T8, T9, T10, T17, T18):**
- Send an **idempotency key** to the processor (one stable key per payout row) and
  treat retries as the same instruction; reconcile `sent` against processor status
  before re-issuing. (T8)
- Process transfers in a **single DB transaction with row-level locking** (or atomic
  conditional balance update); derive/verify balance from ledger sums. (T9, T17)
- Give internal ledger calls a **caller identity + per-operation idempotency token**;
  don't rely on the VPC alone as the trust perimeter. (T10)
- Enforce **positive, bounded `amount`/`delta`** at the schema boundary. (T18)

**PII & secrets (T11, T12):**
- Stop logging full bodies/headers. **Redact** `Authorization`, OTP codes, and all
  KYC fields; log at the minimum needed and scrub before egress to the SaaS. (T11)
- Add **field-level encryption** (or tokenization) for national id / DOB / name, and
  lock down the ID-document object storage (short-lived signed URLs, authn required).
  Verify backup access controls. (T12)

**Accountability (T14, T15):**
- Add **maker/checker approval and amount caps** to `/admin/wallets/{id}/adjust`. (T14)
- Write an **append-only, tamper-evident admin audit log** (separate from app logs),
  capturing actor, target, before/after, and reason. (T15)

*Suggested order:* T1 → T2/T3/T7 → T11 → T4 → T5/T6 → T8/T9 → the rest. The first
five close the direct paths to "mint/move money" and "bulk PII exfiltration."

---

## Residual risk

After the obvious fixes above, the following risk remains and should be stated plainly
to the partner / SOC 2 reviewers:

- **Insider and admin abuse.** Even with role separation, maker/checker, and an audit
  log, the ~6 support staff can still move money within policy; controls make abuse
  *detectable and attributable*, not impossible. The audit log itself is a trust
  anchor — its integrity and review cadence become the residual control.
- **Stolen-credential / device theft.** Shorter-lived, revocable JWTs shrink but don't
  eliminate the window between compromise and revocation; SMS-OTP remains
  phishable/SIM-swappable. Step-up auth for high-value actions is the next lever.
- **Third-party dependency.** Lumen's money correctness depends on the processor's
  idempotency semantics and the logging/KYC SaaS's own security. A breach at the
  processor, KYC provider, or logging SaaS is outside Lumen's direct control;
  contractual + monitoring controls (and minimizing what's sent to each) are the
  mitigation, and the residual exposure scales with data shared over B5/B6.
- **PII at rest.** Field-level encryption protects against many leak paths but the
  application still decrypts to use the data, so an app-tier compromise (or a repeat of
  T1/T3) can still read PII in flight. Key management becomes the new critical asset.
- **Eventual-consistency gaps.** Idempotency keys and DB transactions make double-spend
  and double-payout rare, but reconciliation between the ledger, the cached balance, and
  the processor's view still needs a periodic **automated reconciliation job** to catch
  residual drift; without it, small discrepancies accumulate silently.
- **Unmodeled surfaces.** This model is built from the v0.9 description only. The mobile/
  web clients, the SMS provider, CI/CD and secret-injection pipeline, and the bank-token
  (`bankAccountId`) issuance flow were not described and are not covered here — each is a
  plausible additional boundary worth a follow-up pass.
