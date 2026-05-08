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
12. Save the file as:
