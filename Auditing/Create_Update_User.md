Below is a **step-by-step walkthrough** of how to configure Doxis CSB to audit the creation and update of user accounts.

---

# 🔎 Step 1 — Understand How Audit Trailing Works in Doxis

Audit trailing records user operations performed in the system .

Each recorded operation is automatically indexed with:

* Date
* Category
* Operation type
* User (and role)
* Database affected 

This means that user account creation and modification events can be captured with:

* Who created/updated the account
* When it happened
* What type of operation it was
* Which database was affected

---

# ⚙ Step 2 — Enable Audit Trail Recording (Server Configuration)

Audit trails are **not recorded automatically**. They must be explicitly enabled in the server configuration:

> “Audit trails are only recorded if they have been explicitly enabled in the server configuration.” 

### In CSB (server-side):

1. Open the **CSB administration**.
2. Navigate to the **Audit trail configuration**.
3. Enable audit logging globally (if not already active).
4. Ensure that the relevant categories and operation types are activated for recording.

⚠ Important:
Only operations that are configured for recording will appear in the audit trail.

---

# 🗂 Step 3 — Activate the Correct Categories / Operation Types

The system records operations using:

* Categories (broad classification)
* Operation types (detailed classification) 

To audit user creation and updates:

1. In CSB audit configuration:

   * Locate the category related to **User administration / Organizational elements / Security** (exact naming depends on system configuration).
2. Enable operation types such as:

   * Create user
   * Modify user
   * Change role
   * Delete user (optional but recommended)

If these categories are not activated, the operations will not be recorded.

---

# 🗄 Step 4 — Ensure Database-Level Recording Is Enabled

Some operations are recorded in relation to specific databases:

> “Certain operations are recorded with reference to a database… indexed with the database affected by the operation.” 

In CSB:

* Confirm that auditing is enabled for the relevant organizational database(s).
* If user accounts are stored in a specific directory or identity database, ensure that database is included.

---

# 🔍 Step 5 — Verify the Configuration via Audit Trail Search

After configuration, verify auditing works.

### Open the Audit Trail Search:

Special searches → Audit trail 

### Then:

1. Define a category or operation type 
2. Select the relevant database (if required) 
3. Optionally filter by user/role 
4. Execute the search.

The results will show:

* Indexed operation details 
* Reference objects involved 

You can also:

* Open referenced objects
* View detailed modification data 
* Export to CSV for compliance documentation 

---

# 🧪 Step 6 — Test the Setup

After enabling:

1. Create a test user.
2. Modify that user (e.g., change role).
3. Run an audit trail search filtered by:

   * Category
   * Operation type
   * Your admin account
   * Today’s date

You should see both operations logged.

---

# 🛡 Good Practice Recommendations

For compliance and traceability:

* Enable auditing for:

  * User creation
  * User modification
  * Role changes
  * Access rule changes
  * Audit configuration changes (these are always recorded) 
* Restrict access to audit trail viewing.
* Regularly export logs for backup or compliance archiving.
* Define retention policies.

---

# ✅ Summary

To audit user creation and updates in CSB:

1. Enable audit trailing in server configuration.
2. Activate relevant categories and operation types.
3. Ensure database-level logging is active.
4. Verify via Special searches → Audit trail.
5. Test with controlled user operations.

