# Lumen Wallet Platform — Threat Model

*Scope: the as-built architecture in `reference/system-description.md` (v0.9). This
is an internal attacker's-eye and reviewer's read, focused — per the brief — on
incorrect money movement and exposure of customer PII, with the rest of the
picture included. Findings name the actual endpoint, flow, or trust boundary
involved.*

Assumptions are tagged **[ASSUMPTION]** inline. The most consequential ones: the
description states the admin API "sits behind the **same** auth middleware" that
only validates the JWT and sets `req.userId`, and never mentions a role/admin
claim — so I assume **no role check exists**. The transfer handler is described
as "proceeds with the wallet ids supplied in the request"; payout and wallet-read
handlers are described the same way with no ownership check — so I assume **none
of them verify that the wallet belongs to the caller**. The webhook handlers are
described as parsing and acting on the body with no mention of signature
verification — so I assume **webhooks are unauthenticated**.

---

## Assets & trust boundaries

**Assets, roughly in priority order**

1. **Money-movement authority** — the ability to cause a debit/credit in the
   ledger or a real payout to a bank via the processor. This is the crown jewel;
   ~$4M aggregate balance and real funds leave the system through `/v1/payouts`.
2. **Ledger & balance integrity** — `ledger_entries`, the `wallets.balance`
   column, and the Redis cached balance must agree and be correct.
3. **Customer PII** — `kyc_records`: legal name, DOB, national id (SSN), and the
   ID-document image URL; plus phone numbers and bank-account references. Highest
   regulatory sensitivity.
4. **Authentication secrets** — OTP codes, the 30-day JWTs, the HS256 signing
   key, the processor API key, DB credentials.
5. **KYC verification status** — the flag that raises transfer/payout limits and
   underpins AML posture.
6. **Availability** of login, transfers, and payouts.
7. **Accountability records** — ledger rows and request logs that establish who
   did what (needed for SOC 2 and dispute handling).

**Trust boundaries**

- **Internet → Edge/API** — untrusted clients; no edge rate limiting in front of
  auth yet (§3).
- **One authenticated user → another user's objects** — the per-object
  authorization boundary. *Currently not enforced* on wallet reads, transfers,
  and payouts.
- **Customer → admin** — the privilege boundary at `/admin/*`. *Currently the
  same boundary as "is logged in at all."*
- **External SaaS → webhook receiver** — `/webhooks/processor` and
  `/webhooks/kyc` are public and *currently unauthenticated*.
- **VPC perimeter → internal workloads** — the network is the only internal
  trust control; the ledger does not re-derive caller identity (§8).
- **Lumen → third-party logging SaaS** — full request bodies and headers egress
  here (§10).
- **Lumen → processor / KYC provider** — outbound, holding API keys.
- **Data at rest** — Postgres (disk-encrypted only) and nightly backups to object
  storage.

For completeness, the description establishes several controls that are *already
sound* and are not re-litigated below: parameterized ORM queries (SQLi out of
scope), schema validation of request bodies, TLS everywhere with cert
validation, secrets in a secret manager, and dependency scanning in CI.

---

## Threats

Severity scale: **Critical** (direct money loss or mass PII exposure, low
effort) · **High** (serious money/PII impact, some constraint) · **Medium** ·
**Low**.

### T1 — Transfer from any wallet (broken object-level authz on `POST /transfers`) · *Tampering / Elevation* · **Critical**
The handler authenticates the JWT (sets `req.userId`) and then "proceeds with the
wallet ids supplied in the request" (§4) **[ASSUMPTION: `fromWalletId` is never
checked against `req.userId`]**. Because `walletId`s are sequential integers (§4),
any logged-in user can call `POST /transfers {fromWalletId: <victim>, toWalletId:
<self>, amount}` and drain an arbitrary wallet into their own. This is direct,
scalable theft of customer funds with a normal account and no special access.

### T2 — Cash out any wallet (broken authz on `POST /payouts`) · *Elevation / Tampering* · **Critical**
`POST /payouts {walletId, amount, bankAccountId}` (§5) has the same pattern: no
described check that `walletId` belongs to the caller, and no described check that
`bankAccountId` is the caller's. An attacker can request a payout *from a victim
wallet to their own bank token* — money leaves the platform irreversibly. Worse
than T1 because funds exit to an external bank rather than staying in-system.

### T3 — Read any wallet balance and transaction history (IDOR) · *Information Disclosure* · **High**
`GET /wallets/{walletId}` and `GET /wallets/{walletId}/transactions` load by the
path id with no described ownership check (§4). Sequential ids let an attacker
enumerate all ~180k wallets, harvesting balances and full transaction histories
(counterparties, amounts, timing) — a privacy breach and reconnaissance for T1/T2.

### T4 — Any customer can use the admin API (`/admin/*`) · *Elevation of Privilege* · **Critical**
The admin API runs under the **same** middleware as the customer API, which only
confirms the JWT is valid/unexpired and sets `req.userId`; admin staff carry "the
same kind of JWT" as customers (§7) **[ASSUMPTION: no admin role/claim is
checked]**. Consequences for any logged-in attacker:
- `POST /admin/wallets/{id}/adjust {delta, reason}` — **mint money** by writing a
  positive adjustment to any wallet, or zero out a victim.
- `GET /admin/users/{id}` — read **any user's full KYC PII** (name, DOB, SSN, doc
  image) — mass PII exfiltration by id enumeration.
- `POST /admin/users/{id}/verify` — **self-promote KYC status**, raising one's own
  transfer/payout limits and bypassing the AML gate before running T2 at scale.
This single missing check turns every customer into an admin.

### T5 — OTP brute force → account takeover · *Spoofing* · **Critical**
Login is a **6-digit numeric** OTP (10^6 space) with a 10-minute window, the user
"may retry verification" with no described attempt cap, and **auth endpoints have
no rate limiting** (§3) **[ASSUMPTION: `/auth/otp/verify` has no per-code attempt
lockout]**. An attacker who knows a target phone number can request a code and
then spray guesses; even a modest request rate exhausts a meaningful fraction of
the space within the validity window. Successful guess = full account takeover,
which then unlocks T1/T2/T4. The lack of throttling makes this practical, not
theoretical.

### T6 — Forged processor webhook → fabricate settlements and top-ups · *Spoofing / Tampering* · **Critical**
`POST /webhooks/processor` is public and acts on the body to update payout/
transaction status, including marking a top-up as cleared (§6) **[ASSUMPTION: no
signature/HMAC verification]**. An attacker can POST a forged event claiming a
**top-up cleared**, crediting a wallet with money that never arrived — then
transfer or cash it out. They can also force payouts to `settled`/`failed` to
hide or manufacture state. Credits real spendable balance from nothing.

### T7 — Forged KYC webhook → self-approve verification · *Spoofing / Elevation* · **High**
`POST /webhooks/kyc {userId, decision}` is public and flips KYC status, and an
`approved` decision "raises the user's transfer and payout limits" (§6). Forging
`{userId: <self>, decision: "approved"}` bypasses identity verification and
raises limits — undermining AML obligations and amplifying the blast radius of
T1/T2. Can also be used to grief others (forced `rejected`).

### T8 — Duplicate payouts from missing idempotency · *Tampering* · **Critical**
The payout queue redelivers when "the worker process dies mid-job or a delivery
is not acknowledged within the visibility window," and the worker retries "up to
five, with backoff" on processor errors/timeouts; the processor "treats each
received `POST /v1/payouts` as a distinct instruction" (§5). With **no idempotency
key** on the processor call and a worker that calls the processor *before*
updating the row to `sent`, a worker crash or a slow-but-successful processor
response after a timeout causes the **same payout to be paid more than once** —
real money out the door, repeatedly. The internal ledger likewise "does not track
which requests it has already applied across retries" (§8), so the corresponding
debit can also be double-applied or skipped.

### T9 — Transfer race condition / overdraw · *Tampering* · **High**
The amount check and the two ledger writes "are issued from the request handler as
ordinary application logic," and "each transfer is processed independently as its
request arrives" (§4) **[ASSUMPTION: no row lock or serializable transaction
around check-then-write]**. Two concurrent transfers from the same wallet can both
read the pre-debit balance, both pass the "may not exceed available funds" check,
and both commit — overdrawing the wallet (a double-spend). The absence of auth
rate limiting (§3) makes firing concurrent requests easy.

### T10 — Secrets and PII in request logs · *Information Disclosure (+ Spoofing)* · **Critical**
The API logs **every request with its full body and headers at INFO** and forwards
to a third-party logging SaaS (§10). That captures, in cleartext, in an external
system: **OTP codes** (login bodies), **JWT bearer tokens** (Authorization
headers), **national id/SSN, DOB, legal name** (KYC signup bodies), and **bank
account references**. Anyone with log access — Lumen staff or the SaaS — can read
PII *and* replay tokens / OTPs to take over accounts. This is simultaneously the
largest PII exposure and a credential-theft channel feeding T5.

### T11 — KYC PII at rest has no field-level protection · *Information Disclosure* · **High**
`kyc_records` (name, DOB, SSN, doc image URL) is stored as ordinary columns with
**only cloud disk-level encryption — no column/field encryption** (§9), and
backups go nightly to object storage (§9). Disk encryption protects against a
stolen physical disk but not against an application/DB compromise, a leaked
backup, or an over-broad credential — in all of which the SSN/DOB set up is
readable. **[ASSUMPTION: the ID-document image bucket's own access controls are
unspecified and may be similarly broad.]**

### T12 — Long-lived, unrevocable JWTs; single HS256 secret · *Spoofing / Elevation* · **High**
JWTs are valid **30 days with no refresh and no described revocation** (§3). A
token stolen via T10, a lost device, or a phished session is usable for up to a
month with no way to kill it. Because signing is **HS256 with one server-side
secret**, leakage of that secret (e.g. via the same broad logging/secrets
exposure) lets an attacker **forge a token for any `sub`** — universal
impersonation. There is no per-user invalidation on suspected compromise.

### T13 — Flat VPC trust; ledger accepts unauthenticated internal instructions · *Spoofing / Elevation* · **Medium**
The VPC is "treated as the trust perimeter," internal hops carry no per-request
caller identity, and the ledger "records the debit it is handed and does not
re-derive a caller identity" (§8). Any foothold inside the VPC — a compromised
dependency, an SSRF in the API or webhook receiver, a misconfigured workload —
can instruct the ledger to credit/debit arbitrarily. This is a severity
*multiplier*: it converts a single intrusion into direct money movement and turns
the public webhook receiver (which lives in the same network) into a pivot point.

### T14 — Weak admin accountability / repudiation · *Repudiation* · **Medium**
Admins authenticate with "the same kind of JWT" as customers and there is "no
dedicated tamper-evident audit log for admin actions beyond the normal request
logs and the ledger rows" (§§7, 10). With ~6 staff holding `adjust` power, a
malicious or compromised admin can move balances and read PII with no
attributable, tamper-evident trail — and a customer/admin distinction is hard to
draw after the fact. The `wallets.balance` column is "updated in place" (§4),
overwriting prior state; only the append-only ledger preserves history, and
nothing protects it from a privileged writer. Directly relevant to SOC 2.

### T15 — No rate limiting → OTP/SMS abuse and DoS · *Denial of Service* · **Medium**
With auth unthrottled (§3), `POST /auth/otp/request` can be hammered to **send
SMS at attacker-chosen volume** — toll fraud against the SMS provider and SMS-
bombing of arbitrary phone numbers — and any endpoint can be flooded. Couples
with T5 (brute force) and T9 (race) as the enabling weakness behind several
threats.

### T16 — Balance cache desync · *Tampering / integrity* · **Low–Medium**
Balance lives in both `wallets.balance` and a Redis cache that read endpoints
serve (§4). If a refresh fails or races, reads return a stale balance. Today the
*transfer check* reads the source wallet row (not the cache), which limits direct
money impact, but the divergence undermines reconciliation and could mislead
support and customers — and would become exploitable if any check ever trusts the
cache.

---

## Mitigations

Ordered to stop money loss and PII exposure first.

**Stop the money-movement and privilege bleeds (do immediately):**
- **T1/T2/T3 — enforce object-level authorization.** In the transfer, payout, and
  wallet-read handlers, require that the referenced wallet is owned by
  `req.userId`; reject otherwise. For payouts, also confirm `bankAccountId`
  belongs to the caller. Switch externally exposed ids to non-sequential
  (UUID/opaque) values as defense-in-depth against enumeration.
- **T4 — add a real authorization layer to `/admin/*`.** Introduce an
  admin/role claim (or a separate admin identity system) and a middleware check
  distinct from "is authenticated." Best practice: a separate admin auth domain
  with **MFA** and SSO, not the customer JWT.
- **T6/T7 — authenticate webhooks.** Verify the processor's and KYC provider's
  signatures (HMAC/asymmetric) on every webhook before acting; reject unsigned/
  invalid. Add replay protection (timestamp + nonce) and, where offered, IP
  allow-listing. For top-up clearing specifically, reconcile against the
  processor rather than trusting the event alone.
- **T8 — make payouts idempotent end to end.** Send a stable idempotency key
  (e.g. payout row id) on every `POST /v1/payouts` so retries/redeliveries
  collapse to one payment; transition the row through an intermediate
  `sent_pending` state *before* the processor call and only finalize on confirmed
  response; have the ledger dedupe by operation id. Add daily reconciliation
  against the processor's record of executed payouts.

**Close the PII and credential exposures:**
- **T10 — stop logging secrets and PII.** Redact/deny-list Authorization headers,
  OTP fields, and KYC/bank fields before logging; drop full-body logging on auth,
  KYC, transfer, and payout routes. Review what already sits in the logging SaaS
  and purge.
- **T11 — protect KYC at rest.** Add application- or column-level encryption (or a
  tokenization/KMS-envelope scheme) for SSN/DOB and the document reference;
  encrypt and access-restrict backups and the document bucket; minimize retention.
- **T5/T15 — throttle auth.** Per-phone and per-IP rate limits on
  `/auth/otp/request` and `/auth/otp/verify`, a hard attempt cap per OTP with
  lockout/backoff, and consider an 8-digit code. Ship the planned edge rate
  limiting in front of auth.
- **T12 — shorten and revoke tokens.** Introduce short-lived access tokens + a
  refresh flow with server-side revocation (a session/`jti` denylist); support
  per-user invalidation on compromise. Plan a path to asymmetric signing (RS/ES)
  so verification doesn't share the signing secret.

**Integrity, internal trust, accountability:**
- **T9 — serialize transfers.** Wrap check-and-write in a single DB transaction
  with row-level locking (or a `balance >= amount` conditional update / a
  `CHECK (balance >= 0)` constraint) so concurrent debits cannot both pass.
- **T13 — authenticate internal calls.** Add service identity (mTLS or signed
  internal tokens) and have the ledger authorize and **dedupe by operation id**;
  segment the publicly exposed webhook receiver from money-moving internals.
- **T14 — tamper-evident admin audit.** Append-only, integrity-protected audit
  log of every admin action with the acting admin identity; keep `balance`
  reconstructable from the ledger (treat the column as a cache of ledger state).
- **T16 — single source of truth for balance.** Derive/validate balance from the
  ledger; treat Redis purely as a cache with explicit invalidation and a
  reconciliation job.

---

## Residual risk

After the fixes above, Lumen would still be carrying the following — this is what
a partner reviewer and the SOC 2 effort should see stated plainly:

- **Insider / compromised-admin risk.** Even with `/admin/*` locked to an MFA'd
  admin role and a tamper-evident audit log, ~6 staff retain the power to adjust
  balances and read full KYC PII. Audit logging makes abuse *detectable and
  attributable*, not *impossible*. Residual exposure scales with the number of
  privileged staff and the speed of review.
- **Stolen-but-valid sessions.** Short-lived tokens with revocation shrink the
  window, but a phished OTP or a live token still grants access until it expires
  or is revoked. SMS OTP itself remains vulnerable to SIM-swap and SS7
  interception — an inherent limit of the chosen auth factor.
- **Trusted third parties.** The processor, the KYC provider, the SMS provider,
  the logging SaaS, and the cloud provider are all inside the trust envelope. A
  compromise or insider at any of them (forged-but-validly-signed webhooks, a
  leaked backup at the cloud provider, residual data in the logging SaaS) is only
  partially mitigated by our controls. Reconciliation against the processor bounds
  financial impact but does not eliminate it.
- **VPC compromise is still high-impact.** Service-to-service auth and ledger
  dedupe raise the bar, but a sufficiently deep intrusion (e.g. theft of a service
  identity or the signing/DB secrets) still reaches money movement and PII. The
  blast radius of a single foothold remains large for a money platform.
- **Reconciliation and consistency gaps.** Idempotency keys and DB constraints
  prevent the known double-spend/double-payout paths, but novel race conditions or
  a desync between ledger, balance, and the processor's view can still produce
  incorrect balances until caught by reconciliation. The control of last resort is
  monitoring and a tested reconciliation/clawback process, which should be treated
  as a first-class requirement, not a backstop.
- **PII minimization.** Encrypting SSN/DOB reduces exposure on compromise but does
  not remove the regulatory liability of holding it; the lowest residual risk
  comes from retaining less (shorter retention, tokenized references, deferring to
  the KYC provider as system of record where possible).

**Bottom line:** the highest-severity issues (T1, T2, T4, T5, T6, T8, T10) are
each independently sufficient to cause direct fund loss or mass PII exposure today
and are low-effort to exploit; they should be treated as the gating items before
any partner due-diligence or SOC 2 walkthrough. The architecture is otherwise
conventional and several base controls are already sound — the gaps are
concentrated in authorization, webhook authenticity, idempotency, and logging
hygiene rather than in the platform layer.
