### Problem statement

You are dealing with a **SAML SSO login issue in Doxis (14.3.1, WebCube via browser)** affecting **domain-joined (corporate) machines** at the customer site.
Internal issue ticket [SUPP017501](https://ser-group.atlassian.net/browse/SUPP-17501)

#### Observed behavior

* **Fails:** Normal browser session on domain-joined machines
* **Works:**

  * Incognito / InPrivate mode
  * Non-domain-joined machines
  * Your own Doxis laptop (even without incognito)

#### Key technical context already identified

* The IdP is **Azure AD / ADFS**, using **Windows Integrated Authentication (Kerberos)** for domain-joined machines.
* In normal browser mode:

  * Browser silently authenticates via Kerberos (no login prompt)
  * IdP issues SAML assertion based on **existing Windows session**
* This results in:

  * Potentially **stale SAML assertion** (`AuthnInstant` / `SessionIndex`)
  * No fresh authentication challenge

#### Current hypothesis (already established)

* The issue is **not a hard authentication failure**, but rather:

  * A **session lifecycle / freshness mismatch** between:

    * IdP-issued SAML assertion
    * Doxis session expectations
* Specifically:

  * Doxis accepts the login initially (`SAML SSO login granted`)
  * But then **invalidates the session shortly after**

#### Evidence from logs

From both `log-08.txt` and `web-stdout.log`:

* Successful SAML login events:

  ```
  SAML SSO login granted for <user>
  ```
* Immediately followed (within seconds/minutes) by:

  ```
  Session with id '...' is invalidated
  session ... removed as master session
  ```
* This pattern repeats multiple times → indicates:

  * **Session creation succeeds**
  * **Session is actively invalidated shortly after**, not expiring naturally

No errors observed:

* No rejection in CSB logs
* No errors in WebCube logs
* Confirms:
  → **Doxis is not rejecting the SAML response at login time**

#### Additional constraints / attempts

* `MaximumAuthenticationLifetime = 0`

  * Helps in non-domain scenarios
  * Ineffective here because Kerberos bypasses interactive login
* Customer considering:

  * MFA enforcement (but may not guarantee freshness per request)
* Requested feature:

  * Support for `ForceAuthn=true` in SAML AuthnRequest to force fresh authentication

#### Current state of troubleshooting

* Confirmed:

  * Issue is environment-specific (domain-joined + Kerberos SSO)
  * No explicit errors in logs
  * Sessions are created then invalidated
* Missing:

  * Visibility into **why Doxis invalidates the session**
  * Whether invalidation is triggered by:

    * Session mismatch (SessionIndex, token reuse)
    * Parallel sessions / refresh logic
    * Token freshness / replay protection
    * CSB ↔ WebCube session coordination

---

### Concise summary

This is a **post-authentication session invalidation issue**, not an authentication failure:

> Kerberos-based silent SSO produces a SAML assertion that Doxis accepts, but shortly after, Doxis invalidates the session—likely due to session freshness, reuse, or mismatch constraints—leading to failed user login experience on domain-joined machines.

---

### Structured troubleshooting plan

#### Phase 1 — Confirm the exact failure point

1. **Capture one failed login attempt end-to-end**

   * Use a domain-joined DuPont machine.
   * Use normal browser mode, not private mode.
   * Open DevTools before login.
   * Record:

     * Network HAR file
     * Browser console output
     * Exact timestamp
     * Username
     * Browser type/version
     * Whether VPN is active
     * Whether the user sees an error, redirect loop, blank page, or immediate logout

2. **Correlate logs by timestamp**

   * Match the failed login timestamp to:

     * CSB log
     * WebCube log
     * IdP/Azure AD sign-in log
   * Identify:

     * SAML response received
     * Doxis session ID created
     * First request after login
     * Exact request that causes session invalidation

3. **Increase logging temporarily**
   Enable DEBUG/TRACE logging for:

   * SAML SSO handling
   * Session creation
   * Session invalidation
   * WebCube session handling
   * CSB session refresh task

   Current logs only show:

   * login granted
   * session invalidated
     They do **not** show the invalidation reason.

---

#### Phase 2 — Inspect the SAML assertion

Ask DuPont to capture and provide the SAML response for:

1. Working case:

   * Incognito/InPrivate
   * Non-domain-joined machine

2. Failing case:

   * Normal browser
   * Domain-joined machine

Compare:

* `AuthnInstant`
* `SessionIndex`
* `NameID`
* `NotBefore`
* `NotOnOrAfter`
* `IssueInstant`
* `InResponseTo`
* `AuthnContextClassRef`
* User identifier / mapped login attribute
* Group/role claims
* Whether MFA claim is present
* Whether Kerberos/WIA authentication context is shown
* Whether the same `SessionIndex` is reused

Primary question:

> Is the failing SAML assertion structurally accepted but considered stale, reused, or mismatched after session creation?

---

#### Phase 3 — Validate the current hypothesis

Test these cases deliberately:

1. **Normal browser after full browser restart**

   * Close all browser processes.
   * Clear cookies for Doxis and IdP.
   * Retry.

2. **Normal browser with existing Windows session**

   * Expected to fail if Kerberos silent auth is the trigger.

3. **Normal browser with Kerberos/WIA disabled for the Doxis IdP flow**

   * If this works, the root cause is strongly tied to WIA/Kerberos silent SSO.

4. **Force fresh IdP authentication from IdP side**

   * Conditional Access requiring MFA every sign-in may not be enough if session reuse is still allowed.
   * The useful test is forcing a fresh IdP prompt for this application.

5. **Compare private mode**

   * Private mode likely works because it lacks the existing browser/IdP session state.

---

#### Phase 4 — Check Doxis/session behavior

Investigate whether Doxis invalidates the session because of:

* duplicate login/session for same user
* SAML assertion replay detection
* expired/stale `AuthnInstant`
* reused `SessionIndex`
* mismatch between WebCube session and CSB master session
* application-level session timeout
* missing/changed user claims after silent SSO
* dashboard/session initialization failure after login
* load balancer / sticky-session issue

The log pattern suggests the session is created successfully, then removed shortly after. That means the key is not “why SAML login fails,” but:

> What condition triggers `SEDNASessionImpl` invalidation after successful SAML login?

---

#### Phase 5 — Network/browser evidence to request from customer

Ask the customer for:

* HAR capture of failed login
* Screen recording
* SAML response from browser plugin
* Azure AD sign-in log for the same timestamp
* Browser type/version
* Confirmation whether Windows Integrated Authentication is enabled
* Confirmation whether the Doxis URL is in Local Intranet / Trusted Sites zone
* Whether the browser sends Kerberos automatically
* Whether the issue occurs in Chrome, Edge, or both
* Whether clearing IdP/Doxis cookies changes behavior

---

#### Phase 6 — Short-term mitigations

Use these while root cause is investigated:

1. Continue using **InPrivate/Incognito**.
2. Ask DuPont to disable WIA/Kerberos silent auth for this app if possible.
3. Configure IdP-side policy to require fresh auth for the Doxis enterprise application.
4. Test MFA enforcement, but do not assume it solves the issue unless it prevents assertion/session reuse.
5. If feasible, use a browser profile that does not silently pass Windows credentials.

---

#### Phase 7 — Product/configuration options to investigate

Ask internally whether Doxis/CSB supports:

* `ForceAuthn=true` in SAML AuthnRequest
* configurable AuthnRequest parameters
* retrying SAML login with `ForceAuthn=true` after session rejection
* disabling or adjusting assertion/session freshness validation
* logging the exact reason for session invalidation
* accepting Kerberos/WIA-authenticated SAML assertions differently
* configurable handling of `SessionIndex`

---
