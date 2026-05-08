# Phase 4 -- Analyze Doxis Session Behavior

## Objective

Identify why sessions are invalidated after successful login.

------------------------------------------------------------------------

## Step 1 -- Enable Debug Logging

Enable DEBUG for: - SAML processing - Session creation - Session
invalidation

------------------------------------------------------------------------

## Step 2 -- Reproduce Issue

Perform login and capture: - timestamps - session IDs

------------------------------------------------------------------------

## Step 3 -- Correlate Events

Find: - login success - session creation - invalidation trigger

------------------------------------------------------------------------

## Step 4 -- Check for Causes

Investigate: - duplicate sessions - session reuse - expired tokens -
mismatch in claims

------------------------------------------------------------------------

## Deliverables

Provide logs with timestamps.

------------------------------------------------------------------------

## Expected Outcome

Identify exact reason for session invalidation.

[Phase 5](./Phase5.md)
