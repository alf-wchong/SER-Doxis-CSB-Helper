# Phase 2 -- Inspect the SAML Assertion

## Objective

Compare SAML assertions between working (Incognito) and failing (normal
browser) scenarios to identify differences in authentication context and
session properties.

------------------------------------------------------------------------

## Step 1 -- Install a SAML Capture Tool

Use one of the following: - Chrome / Edge: "SAML-tracer" extension -
Firefox: "SAML-tracer"

------------------------------------------------------------------------

## Step 2 -- Capture SAML Response (Failing Case)

1.  Open normal browser (domain-joined machine)
2.  Start SAML tracer recording
3.  Perform login
4.  Identify the **SAMLResponse POST** to Doxis ACS endpoint
5.  Export the SAML response as XML or HAR

Save as:

    failing-saml.xml

------------------------------------------------------------------------

## Step 3 -- Capture SAML Response (Working Case)

Repeat in Incognito/InPrivate mode.

Save as:

    working-saml.xml

------------------------------------------------------------------------

## Step 4 -- Compare Key Fields

Compare the following:

-   AuthnInstant
-   SessionIndex
-   NotBefore / NotOnOrAfter
-   IssueInstant
-   NameID
-   Audience / Recipient
-   AuthnContextClassRef (e.g., Kerberos vs MFA)
-   Claims (roles, groups)

------------------------------------------------------------------------

## Step 5 -- Identify Differences

Look specifically for: - Reused SessionIndex - Older AuthnInstant -
Missing or different claims - Different authentication context

------------------------------------------------------------------------

## Deliverables

Provide: - failing-saml.xml - working-saml.xml - Notes on observed
differences

------------------------------------------------------------------------

## Expected Outcome

Determine whether the failing assertion is: - stale - reused -
structurally different

[Phase 3](./Phase4.md)
