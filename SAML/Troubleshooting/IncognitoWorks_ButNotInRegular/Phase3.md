# Phase 3 -- Validate Kerberos/WIA Hypothesis

## Objective

Confirm whether Windows Integrated Authentication (Kerberos) is causing
the issue.

------------------------------------------------------------------------

## Step 1 -- Full Browser Restart

1.  Close all browser windows
2.  Ensure all processes are terminated
3.  Reopen browser
4.  Attempt login

------------------------------------------------------------------------

## Step 2 -- Clear Cookies

1.  Clear cookies for:
    -   Doxis domain
    -   IdP domain
2.  Retry login

------------------------------------------------------------------------

## Step 3 -- Disable WIA (if possible)

-   Remove site from "Local Intranet" zone
-   Or disable automatic logon

Retry login

------------------------------------------------------------------------

## Step 4 -- Force Fresh Authentication

-   Use IdP policy (e.g., Conditional Access)
-   Force MFA or re-authentication

------------------------------------------------------------------------

## Step 5 -- Compare with Incognito

Confirm that: - Incognito works - Normal mode fails

------------------------------------------------------------------------

## Expected Outcome

If disabling WIA resolves the issue: → Root cause is Kerberos-based
silent authentication

[Phase 4](./Phase4.md)
