# Lumen Wallet Platform — Threat Model

*Scope: the as-built production architecture described in `reference/system-description.md`
(v0.9). Prepared as an internal security read ahead of partner due-diligence and SOC 2.
Priority weighting per the brief: incorrect money movement and exposure of customer PII,
with the full picture alongside.*

Severity scale: **Critical** (direct, easily-reached loss of funds or bulk PII / total
auth bypass) · **High** (serious money or PII impact, some precondition) · **Medium**
(meaningful but bounded, or requires a prior foothold) · **Low** (hardening).

---

## Assets & trust boundaries

**Assets, ranked by what the brief cares about**

| Asset | Why it matters |
|---|---|
| Wallet balances & the ledger (`wallets.balance`, `ledger_entries`, Redis cached balance) | Authoritative record of customer funds; ~$4M aggregate. Incorrect movement is the top concern. |
| Payout execution path (`payouts` table, payout queue, processor `POST /v1/payouts`) | The only path where money actually leaves Lumen to an external bank. Real, irreversible cash. |
| KYC records (`kyc_records`: legal name, DOB, national id/SSN, ID-document image URL) | Highest-sensitivity customer PII; regulated data. |
| Authentication material (SMS OTP codes, 30-day JWTs, the HS256 signing key) | Compromise = act as any user, including support staff. |
| Account verification state & limits | The verified/limits flag is the only brake on transfer and payout size. |
| Integration credentials (processor API key, DB creds) | Direct money movement / data access if leaked. |

**Trust boundaries (where data or control crosses a privilege level)**

1. **Internet → Edge/API gateway** — all customer and app traffic. TLS terminates here.
2. **Authenticated user ↔ other users' objects** — the boundary that *should* exist
   between `req.userId` and the wallet/payout/user ids supplied in requests. Today this
   boundary is largely unenforced (see T1–T3).
3. **Customer privilege ↔ admin privilege** — `/admin/*` is reached over the same gateway
   and the same auth middleware as customer routes. The intended boundary is not
   evidenced in the description (see T1).
4. **Internet → public webhook endpoints** (`/webhooks/processor`, `/webhooks/kyc`) —
   external SaaS calls in; these endpoints mutate payout/transaction/KYC state.
5. **VPC perimeter** — internal workloads (Customer API, ledger, payout worker, auth)
   trust each other purely by network reachability; the ledger does not re-derive caller
   identity per request.
6. **Lumen → external processors** (payment processor, KYC provider) over HTTPS.
7. **Lumen → third-party logging SaaS** — full request bodies/headers leave the platform.
8. **Data at rest** — Postgres (disk-encrypted only), nightly backups to object storage,
   Redis (cache + payout queue, VPC-internal).

**Systemic observation underlying the threats below:** the system consistently
*authenticates* (proves a valid JWT exists) but does not *authorize* (check that the
caller may act on the specific object or route), and it treats network reachability and
inbound webhook bodies as proof of identity. The same root cause appears in admin routing,
transfers, payouts, the ledger's internal interface, and both webhooks. Several individual
instances are Critical; the *pattern* is the finding a due-diligence reviewer will see.

---

## Threats

### T1 — Admin API has no authorization boundary *(STRIDE: Elevation of Privilege; also Information Disclosure, Tampering)* — **Critical**
`/admin/*` runs behind the *same* auth middleware as customer routes (§7): it "confirms
the JWT is valid and not expired and sets `req.userId`. The admin routes then run." Admin
staff "receive the same kind of JWT" as customers. No role/claim check on admin routes is
described. **[ASSUMPTION] No separate admin authorization exists** — the as-built doc
describes the middleware precisely and would have noted a role gate if present.
**Exploit:** any authenticated customer calls `POST /admin/wallets/{id}/adjust` with a
large positive `delta` to mint balance into their own wallet; calls `GET /admin/users/{id}`
to read any user's full KYC profile (SSN, DOB); calls `POST /admin/users/{id}/verify` to
self-verify and raise limits. **Consequence:** arbitrary money creation, bulk PII read,
KYC bypass — from an ordinary user token.

### T2 — Broken object-level authorization on transfers and payouts (IDOR) *(STRIDE: Elevation of Privilege / Tampering)* — **Critical**
`POST /transfers` accepts `{fromWalletId, toWalletId, amount}` and, per §4, "authenticates
via the JWT … then proceeds with the wallet ids supplied in the request" — it never checks
that `req.userId` owns `fromWalletId`. `POST /payouts` accepts `{walletId, amount,
bankAccountId}` with no described ownership check on `walletId` or `bankAccountId`.
**Exploit:** authenticate as myself, set `fromWalletId`/`walletId` to a victim's wallet
(ids are sequential integers — see T3), and transfer their funds to my wallet or pay them
out to a bank token I control. **Consequence:** direct theft of any user's balance.

### T3 — Enumerable wallet reads expose balances and transaction history (IDOR) *(STRIDE: Information Disclosure)* — **High**
`GET /wallets/{walletId}` and `GET /wallets/{walletId}/transactions` load by the path id
with no ownership check described; `walletId` values are "sequential integers assigned at
account creation" (§4). **Exploit:** walk `walletId` 1…N to harvest every user's balance
and full transaction ledger. **Consequence:** mass disclosure of financial PII; also the
reconnaissance step that makes T2 trivial.

### T4 — Transfer balance check is non-atomic (TOCTOU double-spend) *(STRIDE: Tampering)* — **Critical**
§4: the amount check and ledger writes are "issued from the request handler as ordinary
application logic; each transfer is processed independently," and the balance column is
"updated in place." No row lock or transactional isolation is described. **Exploit:** fire
many concurrent transfers from one wallet; each reads the same pre-debit balance, each
passes the available-funds rule, all debits commit. **Consequence:** spend more than the
wallet holds; the cached Redis balance can also diverge from the column and the ledger.
Requires no auth flaw.

### T5 — Payouts are not idempotent → duplicate real-money disbursement *(STRIDE: Tampering)* — **Critical**
Three statements compound (§5, §8): the Redis queue re-delivers a job if it isn't acked
within the visibility window or the worker dies; the worker retries up to five times on
processor error/timeout; "the ledger does not track which requests it has already applied
across retries"; and "the processor treats each received `POST /v1/payouts` as a distinct
instruction." No idempotency key is sent on the processor call. **Exploit / failure mode:**
a processor call that succeeds but times out on Lumen's side is retried and pays the
destination twice; an attacker who induces timeouts (or load) accelerates this.
**Consequence:** real, irreversible double (or 5×) payouts. This occurs without any
attacker — it is a live reliability defect that moves money.

### T6 — Processor webhook is unauthenticated and state-changing *(STRIDE: Spoofing / Tampering)* — **Critical**
`POST /webhooks/processor` is "publicly reachable" and the handler "parses the JSON body,
finds the referenced payout/transaction by the id in the body, and updates its status"
(§6). No signature/HMAC/shared-secret/source check is described. **Exploit:** an internet
attacker forges a "top-up cleared" event to credit a wallet with no real money, or forges
"payout failed/settled" to drive incorrect reversal/settlement state. **Consequence:**
fabricated balances and corrupted money-movement state from an anonymous request.

### T7 — KYC webhook is unauthenticated → self-service verification *(STRIDE: Spoofing / Elevation of Privilege)* — **High**
`POST /webhooks/kyc` is public and acts on `{userId, decision}`; an `approved` decision
"flips the account to verified, which raises the user's transfer and payout limits" (§6).
**Exploit:** POST `{userId: <mine>, decision: "approved"}` to self-verify and lift limits
without ever passing KYC. **Consequence:** KYC/AML control bypass (a direct due-diligence
finding) and removal of the only brake on transfer/payout size — which amplifies T2.

### T8 — OTP is brute-forceable; auth endpoints are unthrottled *(STRIDE: Spoofing; Denial of Service)* — **High**
§3: 6-digit numeric code, 10-minute expiry, retries allowed, and "rate limiting … is not
yet in front of the auth service; today auth endpoints are reachable without throttling."
**Exploit:** brute-force the ~10⁶ code space against `POST /auth/otp/verify` within the
validity window to take over any phone number's account (which holds a balance and can
request payouts). Separately, spam `POST /auth/otp/request` for a victim number (SMS
bombing) and for cost/availability impact on Lumen's SMS spend. **Consequence:** account
takeover = money movement; plus SMS-cost DoS.

### T9 — Full request bodies and headers (incl. secrets and SSNs) logged to a third party *(STRIDE: Information Disclosure)* — **High**
§10: the Customer API "logs every request with its full body and headers at INFO level,"
forwarded to a third-party logging SaaS, "includ[ing] login, OTP, transfer, payout, and
KYC-related requests." Those payloads contain OTP codes, the **JWT bearer token** (a
header — a ready session-hijack artifact), bank/wallet ids and amounts, and KYC bodies
carrying **legal name, DOB, and national id/SSN**. **Exploit:** anyone with log-search
access — Lumen staff beyond need-to-know, the SaaS vendor, or an attacker who phishes a
logging account — reads live credentials and bulk PII. **Consequence:** credential theft
and large-scale PII exposure outside Lumen's trust boundary.

### T10 — Sensitive KYC data lacks application-level protection at rest *(STRIDE: Information Disclosure)* — **High**
§9: `kyc_records` (name, DOB, national id, document-image URL) are stored as ordinary
columns with only cloud disk-level encryption; "no additional column-level or field-level
encryption." Nightly backups go to cloud object storage. **[ASSUMPTION]** the
document-image URL may be long-lived/guessable and not per-request access-controlled — if
so, that is an IDOR on identity documents. **Exploit:** any DB-read compromise, an
over-broad query, a leaked backup, or a guessable image URL yields plaintext SSNs and ID
images. Disk encryption defends only against stolen physical media. **Consequence:**
regulated-PII breach; a SOC 2 / partner control gap.

### T11 — JWT design: 30-day lifetime, no revocation, single HS256 secret *(STRIDE: Spoofing)* — **Medium**
§3/§11: tokens are valid 30 days, there is no refresh or revocation flow, and signing is
HS256 with one server-side secret. **Exploit:** a stolen token (see T9) is usable for up
to a month with no way to revoke it; if the single HS256 secret leaks, *all* tokens are
forgeable, including admin-staff tokens. **Consequence:** durable session hijack; catastrophic
forgery on key compromise. Interacts directly with T9 (tokens are being logged).

### T12 — Internal trust = network reachability; ledger has no caller identity or idempotency *(STRIDE: Elevation of Privilege / Tampering)* — **Medium**
§8: inter-workload hops trust the VPC as the perimeter; "an internal caller is whoever can
reach the endpoint," the ledger "records the debit it is handed and does not re-derive a
caller identity," and does not dedupe across retries. **Exploit:** a single compromised
internal workload (vulnerable dependency, SSRF from the Customer API, leaked internal
credential) can instruct the ledger to post arbitrary debits/credits. **Consequence:**
post-foothold money movement with no internal authorization to stop it; also the root
cause of T5's missing idempotency.

### T13 — No tamper-evident audit trail for admin actions *(STRIDE: Repudiation)* — **Medium**
§10: "no dedicated tamper-evident audit log for admin actions beyond the normal request
logs and the ledger rows themselves." Admin actions include arbitrary balance adjustments.
**Exploit / consequence:** a malicious or compromised admin — or, via T1, any user reaching
admin routes — adjusts balances with weak attribution and no independent, append-only
record to reconstruct what happened. Undermines incident response and SOC 2 accountability.

### T14 — Unthrottled public surfaces enable abuse / DoS *(STRIDE: Denial of Service)* — **Medium**
No rate limiting is in place (stated for auth, §3; not evidenced elsewhere). Public webhook
endpoints perform DB writes, OTP requests cost real SMS spend, and there is a single
processor API key. **Exploit:** flood OTP requests (cost), webhook endpoints (DB load /
state churn), or login to exhaust resources. **Consequence:** degraded availability and
direct cost, with no per-caller backpressure.

---

## Mitigations

Ordered to retire the most money/PII risk first.

**Immediate (close the critical money paths):**
- **T2 / T1 — enforce authorization, not just authentication.** In every customer handler,
  derive the acting wallet from `req.userId` (or verify ownership of supplied ids) rather
  than trusting `fromWalletId`/`walletId`/`bankAccountId` from the body. For `/admin/*`,
  add a distinct authorization check (an admin role/claim, ideally a separate identity and
  separately-scoped tokens) enforced before any admin route runs.
- **T4 — make transfers atomic.** Perform the balance check and both ledger writes in a
  single serialized DB transaction (e.g. `SELECT … FOR UPDATE` on the source wallet or an
  atomic conditional decrement). Treat the append-only ledger as the source of truth and
  derive/validate the balance from it rather than blindly "updating in place."
- **T5 / T12 — idempotency end-to-end.** Send a unique idempotency key on each processor
  `POST /v1/payouts` and have the ledger record an idempotency key per applied operation so
  retries and queue redeliveries are no-ops. Gate the status transition `pending → sent` on
  a confirmed, deduplicated processor response.
- **T6 / T7 — authenticate inbound webhooks.** Verify the processor's and KYC provider's
  signatures (HMAC/shared secret per their spec) and reject unsigned/invalid calls; add
  source allow-listing as defense in depth. KYC verification state must change only on a
  verified provider callback, never on an unauthenticated body.
- **T8 — throttle auth.** Rate-limit and lock-out `POST /auth/otp/verify` per
  account/IP (a handful of attempts per code), cap `POST /auth/otp/request` per number/time,
  and consider a longer code or device binding. Land the planned edge rate limiting in front
  of the auth service now.

**Near-term (PII and accountability):**
- **T3 — ownership checks + non-enumerable ids.** Authorize wallet reads against
  `req.userId`; migrate external identifiers to non-sequential (UUID) values.
- **T9 — stop logging secrets and PII.** Redact/strip `Authorization` headers, OTP codes,
  national id/DOB, and bank/payout fields before logs leave the service; drop full-body INFO
  logging on auth/KYC/payment paths; confirm the logging SaaS contract and retention.
- **T10 — protect KYC at rest.** Apply column/field-level encryption (or tokenization) to
  national id and DOB, encrypt the document store, lock down the image URL behind
  per-request authorization, and encrypt/access-restrict backups.
- **T13 — tamper-evident admin audit log.** Write admin actions (especially balance
  adjustments and manual verify) to a separate append-only, attributable audit trail.

**Hardening:**
- **T11 — token hygiene.** Shorten JWT lifetime, add a refresh + revocation mechanism (jti
  + denylist or short-lived access tokens), and plan rotation for the HS256 secret (or move
  to asymmetric signing so the verifier doesn't hold a forging key).
- **T12 — internal identity.** Introduce workload identity / mTLS or signed internal
  requests so the ledger authorizes callers rather than trusting the network.
- **T14 — backpressure.** Rate-limit public endpoints (auth, webhooks), and bound OTP send
  volume.

---

## Residual risk

After the fixes above, the following risk remains and should be stated plainly to partners
and SOC 2:

- **VPC-as-perimeter trust persists.** Idempotency and ownership checks close specific
  holes, but until internal calls carry authenticated service identity (T12 hardening), a
  single compromised internal workload still translates to money movement. This is a
  larger architectural lift than the point fixes and will not be fully retired in the first
  pass.
- **Balance/ledger reconciliation is a design property, not a one-time fix.** Atomic
  transactions and idempotency keys *narrow* the window for drift between the ledger, the
  `wallets.balance` column, and the Redis cache, but as long as balance is maintained as a
  separate mutable value rather than always derived from the append-only ledger, divergence
  remains possible. Ongoing reconciliation/monitoring is required.
- **Third-party data exposure does not go to zero.** Even with redacted logs and encrypted
  columns, the KYC provider, SMS provider, payment processor, and logging SaaS still hold or
  transit sensitive data. This becomes a vendor-management, DPA, and sub-processor-review
  obligation rather than a closed technical issue.
- **Fraud/AML posture is continuous.** Fixing KYC-webhook spoofing and self-verify removes
  the technical bypass, but the verified-state/limit model is still the only control between
  a (legitimately or fraudulently) verified account and large payouts. Transaction
  monitoring, velocity limits, and manual review remain ongoing controls, not one-off fixes.
- **Token-theft window remains non-zero.** Shorter-lived, revocable tokens shrink but do not
  eliminate the value of a stolen token between issuance and revocation; endpoint and device
  security continue to matter.
- **Assumption-dependent findings need confirmation.** T1 (no admin authorization), T2/T3
  (no ownership checks), and the T10 document-URL exposure are inferred from a description
  that does not evidence these controls. They should be confirmed against code; if any
  control in fact exists, the corresponding severity drops, but the systemic
  authenticate-without-authorize pattern should still be validated everywhere, not just
  where it is named here.

*Tagged assumptions:* admin routes have no role-based authorization beyond JWT validity
(T1); transfer/payout/wallet-read handlers perform no object-ownership check (T2, T3); the
KYC document-image URL may not be per-request access-controlled (T10). Each is called out
inline above.
