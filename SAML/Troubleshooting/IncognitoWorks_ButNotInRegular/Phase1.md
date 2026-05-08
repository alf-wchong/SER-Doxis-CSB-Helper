# Phase 1 – Capture and Correlate a Failed Login Attempt

## Objective
Identify the exact point where the login flow breaks by capturing a complete failed login attempt, including browser and server-side evidence.

---

## Step 1 – Capture a HAR File of a Failed Login

### Goal
Record all network requests during a failed login attempt.

### Instructions (Chrome / Edge)

1. Open a **new normal browser window** (NOT Incognito/InPrivate).
2. Press **F12** to open Developer Tools.
3. Go to the **Network** tab.
4. Enable:
   - ✅ "Preserve log"
   - ✅ "Disable cache"
5. Clear any existing logs (click the 🚫 icon).
6. Start recording (if not already active).

---

### Perform the Login

7. Navigate to the Doxis login URL.
8. Perform the login as usual.
9. Wait until:
   - You are logged out again, OR
   - You see the failure behavior (loop, blank page, etc.)

---

### Export the HAR File

10. Right-click anywhere in the Network tab.
11. Click **"Save all as HAR with content"**.
12. Save the file as: `failed-login.har`


---

## Step 2 – Capture Additional Context

Please provide the following details along with the HAR file:

- Username used for login
- Exact timestamp of login attempt (include timezone)
- Browser type and version (e.g., Chrome 122, Edge 120)
- Whether VPN was active (Yes/No)
- Machine type:
- Domain-joined: Yes/No
- Description of what happened:
- Example: “Login succeeds briefly, then redirects back to login”

---

## Step 3 – Capture a Screen Recording (Optional but Recommended)

1. Start screen recording before login.
2. Perform the login attempt.
3. Stop recording after failure occurs.
4. Save as: `failed-login.mp4`


---

## Step 4 – Repeat in Incognito (Control Test)

Repeat the same steps in **Incognito / InPrivate mode**:

- Save HAR as: `working-login-incognito.har`

This helps compare working vs failing scenarios.

---

## Step 5 – Provide Files

Please share the following:

- failed-login.har
- working-login-incognito.har (if available)
- failed-login.mp4 (if recorded)

---

## Step 6 – Internal Correlation (Doxis Team)

Once received, we will:

- Match timestamps with:
- CSB logs
- WebCube logs
- Identify:
- SAML response processing
- Session creation event
- Exact request triggering session invalidation

---

## Expected Outcome

This step will determine:

- Whether the failure occurs:
- During SAML exchange
- Immediately after session creation
- During subsequent application requests

This is required before proceeding to deeper SAML and session analysis.

---  
