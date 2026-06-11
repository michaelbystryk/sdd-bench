# Lumen Wallet Platform — Threat Model

*Scope: the as-built architecture described in `reference/system-description.md`
(Lumen v0.9). Lumen is a stored-value wallet and payout product — ~180k users,
~$4M aggregate balance, low-thousands of payouts/day. This document is the
internal security read prepared ahead of partner due diligence and SOC 2.*

Assumptions made where the description is silent are tagged **[ASSUMPTION]**.

---

## 1. Assets & trust boundaries

### Assets (what an attacker wants, ranked by what the business said it cares about)

| Asset | Where it lives | Why it matters |
|---|---|---|
| **Wallet balances / money movement** | `wallets.balance` (Postgres) + Redis cache; `ledger_entries`; payout queue → processor | Direct financial loss. ~$4M at stake. |
| **Customer PII — KYC data** | `kyc_records`: legal name, DOB, national id (SSN/equiv), ID-doc image URL | Regulatory crown jewel; breach is reportable and partner-ending. |
| **Auth credentials in flight** | OTP codes, 30-day bearer JWTs | Account takeover → both assets above. |
| **KYC / "verified" status** | `users` KYC flag | Gates AML/identity controls and transfer/payout limits. |
| **Accountability record** | Request logs (3rd-party SaaS), ledger rows | Needed to investigate fraud and to pass SOC 2. |
| **Secrets** | JWT signing key, processor API key, DB creds (secret manager) | Single HS256 key compromise mints any token, incl. admin. |

### Trust boundaries

1. **Internet → Edge/API gateway → Customer API.** TLS-terminated. Carries all
   customer traffic *and* — because they are publicly reachable — the
   `/webhooks/processor` and `/webhooks/kyc` endpoints.
2. **Unauthenticated → Authenticated (JWT).** Auth middleware verifies a JWT's
   signature + expiry and sets `req.userId`. **This is the only access-control
   gate in the system**, and it checks *authentication*, not *authorization*.
3. **Customer ↔ Admin.** *Nominal but not enforced.* `/admin/*` runs in the same
   process, behind the same middleware, and admin staff hold the same kind of
   JWT as customers. No role/scope claim is described — so this boundary is
   asserted in the architecture but **not technically present**. (See T1.)
4. **Application ↔ Ledger / internal VPC.** The VPC perimeter *is* the trust
   model: "an internal caller is whoever can reach the endpoint." The ledger
   does not re-derive caller identity and does not dedupe applied requests.
5. **Lumen ↔ external SaaS.** Outbound to the payment processor and KYC provider
   (HTTPS, cert-validated). Inbound from them via the public webhooks — a
   boundary that is *crossed inbound with no authentication* (see T3).
6. **Lumen ↔ third-party logging SaaS.** Full request bodies + headers leave
   Lumen's trust boundary entirely and land in a vendor Lumen does not
   administer (see T8).

### Root-cause observation

Four of the highest-severity threats below (T1, T2, T3, T6) share one root
cause: **authorization in Lumen means "a valid JWT is present," not "this
identity is allowed to do this to this resource."** Money movement and PII
exposure are not two separate problems here — they are the same broken
authorization boundary seen from two sides.

---

## 2. Threats (enumerated)

Severity scale: **Critical** (direct, low-effort money theft or mass PII loss) ·
**High** (serious money/PII risk, some precondition) · **Medium** ·
**Low**.

---

### T1 — Admin API authorized by JWT presence, not role → any customer is effectively an admin
**STRIDE: Elevation of Privilege** (+ Tampering, Information Disclosure) · **Critical**

`/admin/*` sits behind the same auth middleware as customer routes; the
middleware only verifies the JWT and sets `req.userId`, and admin staff receive
"the same kind of JWT" as customers. No role/scope claim distinguishing admin is
described. **[ASSUMPTION]** admin authorization is *only* the shared middleware
(the description states no additional check). Then any customer's own valid JWT
reaches:

- `POST /admin/wallets/{id}/adjust {delta, reason}` → write a positive-delta
  ledger adjustment and update balance = **mint money from nothing**, no source
  wallet required.
- `POST /admin/users/{id}/verify` → self-approve KYC, raising one's own limits.
- `GET /admin/users/{id}` → read **any** user's full profile incl. national id.

Consequence: a single customer JWT becomes root over the money system and the
PII store. This is the highest-leverage finding in the system.

---

### T2 — `POST /transfers` trusts the request-supplied `fromWalletId` (no ownership check)
**STRIDE: Elevation of Privilege / Tampering** · **Critical**

The handler authenticates (sets `req.userId`) and then "proceeds with the wallet
ids supplied in the request." No assertion that `fromWalletId` belongs to
`req.userId`. The available-funds rule checks the *source* wallet's balance — i.e.
the victim's — so it passes.

```
POST /transfers
Authorization: Bearer <attacker's own valid JWT>
{ "fromWalletId": <victim>, "toWalletId": <attacker>, "amount": <victim_balance> }
```

`walletId`s are sequential integers, so the attacker simply enumerates from their
own id. Drain any wallet, then `POST /payouts` to cash out. This is the whole
~$4M, exploitable with one ordinary account.

---

### T3 — Public webhooks are unauthenticated → forged KYC approval and forged settlement
**STRIDE: Spoofing / Tampering** · **Critical**

`/webhooks/processor` and `/webhooks/kyc` are publicly reachable and the handlers
"parse JSON, find the referenced record by id, update status." **[ASSUMPTION]** no
HMAC/signature verification exists (none is described). Then any internet caller:

- `POST /webhooks/kyc {userId, decision:"approved"}` → flips that user to
  verified, **raising transfer and payout limits**. This defeats the AML/identity
  control Lumen relies on — a customer can self-approve, bypassing the KYC the
  provider was paid to run.
- `POST /webhooks/processor {<payout/topup id>, status:"settled"/cleared}` → mark
  an unfunded payout settled, or a top-up cleared, crediting a wallet with money
  that never arrived.

Sequential ids mean targets are enumerable, not guessed.

---

### T4 — Payout double-spend: no idempotency anywhere in the payout chain (no attacker required)
**STRIDE: Tampering / Repudiation** · **High** (real-money, occurs under normal operation)

Three at-least-once mechanisms stack onto a processor that is at-least-once
hostile: the Redis queue redelivers on worker death/visibility-timeout; the
worker retries up to 5× on error/timeout; the processor "treats each received
`POST /v1/payouts` as a distinct instruction"; and the ledger "does not track
which requests it has already applied." With no idempotency key, the ordinary
failure — processor accepts the payout but the response is slow, or the worker
dies after sending but before marking `sent` — causes a **second real bank
disbursement**, while the `payouts` row flips to `sent` and looks healthy. At
low-thousands of payouts/day, a small timeout rate is recurring real loss. An
attacker who can induce worker timeouts turns this into a withdrawal lever, but
no attacker is needed.

---

### T5 — Transfer race / TOCTOU → overspend below zero
**STRIDE: Tampering** · **High**

`POST /transfers` does a non-atomic check-then-write ("each transfer processed
independently as its request arrives"), with no row lock and no rate limiting.
Fire N concurrent transfers from one funded wallet: each reads the balance before
any debit lands, all pass the funds check, all write. The wallet goes negative —
value created from nothing. Works **even if T2's ownership check is added**; it is
a pure concurrency defect. The two-copy balance (Postgres column updated in place
+ Redis cache refreshed *after* the writes) also lets displayed and authoritative
balances diverge, hiding the overspend from monitoring.

---

### T6 — IDOR on `GET /wallets/{walletId}` and `/transactions` → mass financial/PII enumeration
**STRIDE: Information Disclosure** · **High**

Read endpoints "load the wallet row by path `walletId`" with no described
ownership predicate; ids are sequential integers. **[ASSUMPTION]** these reads
share the no-ownership-check property the transfer handler explicitly has. One
valid customer token walks `1..180000`, harvesting every wallet's balance and full
ledger (counterparties, amounts, timing) — a transaction graph for the entire
user base.

---

### T7 — OTP brute force → account takeover
**STRIDE: Spoofing** · **High**

6-digit numeric code (10^6 space), 10-minute window, verification retries
allowed, "may request a new code," and **no rate limiting on auth endpoints**
(edge throttling is planned, not deployed). An attacker requests an OTP for a
victim phone number and brute-forces `/auth/otp/verify`; expected success near
~5×10^5 attempts, well within reach unthrottled. One success yields a **30-day,
non-revocable** JWT. Combined with T1/T2 the taken-over account is then root.

---

### T8 — Full request bodies + headers logged to a third-party SaaS → PII + token exposure
**STRIDE: Information Disclosure** · **High** (the worst PII finding; SOC 2 blocker)

The Customer API logs every request with full body **and** headers at INFO and
forwards them to a third-party logging SaaS. That stream carries: OTP codes;
**Authorization bearer JWTs** (HS256, 30-day, no revocation — a token in a log is
a replayable session for up to a month for anyone with log access); and KYC
signup payloads (legal name, DOB, national id). A single log-vendor breach,
insider, or subprocessor exposure = mass SSN + replayable-token disclosure to a
system outside Lumen's control. Directly implicates SOC 2 Confidentiality/Privacy
and almost certainly the customer DPA / subprocessor list.

---

### T9 — KYC PII stored with disk-level encryption only
**STRIDE: Information Disclosure** · **High**

`kyc_records` (name, DOB, national id, doc-image URL) has no column/field-level
encryption; Postgres is disk-encrypted at rest only. Disk-at-rest protects
against *physical media theft* and nothing else — it is transparent to every
logical reader: leaked DB creds, replicas, `pg_dump`, and the **nightly backups
to object storage**, which multiply cleartext copies of ~180k SSNs. **[ASSUMPTION]**
the ID-doc image URL's access model is unstated; if it is not a signed,
short-lived, authz-checked link, a leaked URL (URLs leak via the T8 logs) yields
a government-ID image with no authentication. *This sub-point should be confirmed,
not assumed.*

---

### T10 — No non-repudiation for privileged money movement
**STRIDE: Repudiation** · **High** (control-design blocker for SOC 2)

`POST /admin/wallets/{id}/adjust` is unbounded balance-mint power with a
self-asserted free-text `reason`. There is no maker-checker, no tamper-evident
audit log — only request logs (in the mutable third-party SaaS) and ledger rows
(which are themselves the action, not an independent attestation). Admins share a
customer-grade identity. So a rogue or compromised admin (or someone who lifted an
admin JWT via T8) can inflate a wallet, route a payout, and **deny it** — Lumen
can show money moved but cannot cryptographically attribute *who* moved it or
prove the record was not altered.

---

### T11 — VPC-as-trust-perimeter + caller-blind ledger → foothold = mint money
**STRIDE: Spoofing / Elevation of Privilege** · **Medium** (High if any foothold exists)

The ledger's authorization model is network reachability; it does not
authenticate callers or dedupe. Any foothold inside the VPC — SSRF in the
Customer API, a compromised dependency, or pivoting through the public webhook
handlers — can issue arbitrary debits/credits. The blast radius of a single
internal compromise is the entire money system.

---

### T12 — 30-day JWT, no refresh, no revocation
**STRIDE: Spoofing / Elevation of Privilege** · **Medium**

A single HS256 key signs all tokens, including admin. A stolen token (via T7, T8,
or a lost device) grants 30 days of access with no described revocation path; the
only remediation is rotating the signing key, which logs out every user. Amplifies
T1, T7, T8, T10.

---

## 3. Mitigations

Ordered by leverage. The first group is the "incorrect money movement + PII" core
the business flagged; several fixes close more than one threat.

**P0 — close before due diligence / before anything else**

1. **Enforce resource ownership on every wallet-scoped operation** (T2, T6).
   Assert `wallet.userId === req.userId` in `GET /wallets/{id}`,
   `/transactions`, and the `fromWalletId` path of `POST /transfers`. Also verify
   `bankAccountId` ownership in `POST /payouts`.
2. **Add a real admin role/scope claim, verified independently of authentication**
   (T1, T12). Ideally a separate admin identity (distinct issuer/audience,
   short-lived tokens, second factor). At minimum, a hard role check before any
   `/admin/*` handler runs.
3. **Authenticate the webhooks** (T3). Verify the provider's HMAC signature over
   the raw body (constant-time compare) and reject unsigned/invalid before any
   lookup; add timestamp/nonce against replay. *Authentication, not just an IP
   allowlist or rate limit.*
4. **Stop logging secrets and PII to the third-party SaaS** (T8). Allowlist-based
   log serialization: never log `Authorization`, OTP, or national id/DOB. Then
   **rotate the JWT signing key** to invalidate tokens already shipped to logs,
   and treat historical logs as already-exposed.

**P1 — money-integrity correctness**

5. **Idempotency key end-to-end on payouts** (T4, T11). Generate a key at payout
   creation; send it on every processor attempt incl. retries; key the ledger
   write on it with a unique DB constraint so a replay is a no-op; make
   `pending→sent` a conditional `WHERE status='pending'` update. If the processor
   has no idempotency support, escalate to the vendor and add daily reconciliation
   as compensating control.
6. **Make the transfer atomic** (T5). `SELECT … FOR UPDATE` on the wallet row
   inside the transaction (or a DB-level non-negative-balance constraint) so
   concurrent transfers serialize. Make Redis a read-through cache derived from
   Postgres — never an independent source of truth.
7. **Rate-limit and lock out auth** (T7). Per-phone and per-IP attempt limits on
   `/auth/otp/verify`, cap codes-per-window, invalidate prior codes on reissue.
   Deploy the planned edge throttling in front of auth.

**P2 — confidentiality, accountability, defense-in-depth**

8. **Field-level encryption / tokenization of national id** in `kyc_records`, plus
   encrypted backups with separate key custody (T9). Confirm and enforce signed,
   short-lived, authz-checked ID-doc image URLs.
9. **Tamper-evident audit log + maker-checker** for `/admin/*/adjust` and
   `/verify` (T10), independent of request telemetry; consider transaction limits
   on a single adjustment.
10. **Per-workload identity for internal calls** (mTLS/signed service credentials)
    and authorize ledger writes per operation (T11).
11. **Shorten JWT lifetime + add a refresh/revocation path** (T12).

---

## 4. Residual risk

Even after the mitigations above land, Lumen would still be carrying real risk —
state it plainly for the partner and SOC 2 narratives:

- **Payouts may not be truly idempotent at the vendor.** If the processor does not
  honor an idempotency key, T4 is reduced to *detect-and-reconcile*, not prevent —
  a daily settlement diff catches duplicate disbursements after money has already
  moved. This residual must be named explicitly; it is a vendor dependency, not a
  Lumen-side fix.
- **Historical exposure is already realized.** OTPs, 30-day bearer JWTs, and SSNs
  have already been shipped to the logging SaaS (T8) and SSNs already sit
  cleartext in nightly backups (T9). Redaction and encryption stop *future*
  exposure; prior log retention and existing backups remain disclosed risk until
  they age out / are purged and keys are rotated. Treat tokens in old logs as
  compromised regardless of the fix date.
- **Stolen-credential risk persists.** Ownership checks, admin roles, and webhook
  signatures move the system from "valid JWT = money/PII" to "the *right* stolen
  credential = money/PII" — a far smaller, more auditable surface, but not zero. A
  phished admin token, a stolen service credential, or a leaked HMAC/signing
  secret still grants meaningful access. Defense-in-depth (anomaly detection on
  ledger writes and adjustments, egress controls, short token lifetimes) reduces
  but does not eliminate this.
- **Insider risk at the support tier.** Maker-checker and tamper-evident audit
  make privileged abuse *attributable and harder*, not impossible; ~6 staff with
  balance-adjust power remain a trusted population requiring monitoring and
  separation of duties.
- **Internal network compromise still has elevated blast radius.** Until per-
  workload identity (T11) is fully adopted, a foothold inside the VPC remains more
  valuable than it should be; even after, the VPC is one layer, not a guarantee.
- **OTP-only authentication has a floor.** SMS OTP is phishable and SIM-swappable;
  rate limiting closes brute force but not a targeted SIM-swap account takeover.
  This is an accepted-risk decision the business should make consciously.

---

*Prepared as an internal threat model against the as-built description. Items
tagged **[ASSUMPTION]** — most importantly the absence of an admin role check
(T1), the absence of webhook signature verification (T3), and the ID-doc image
URL access model (T9) — should be confirmed against the code before sign-off, as
they are severity-determining.*
