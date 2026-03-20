# How to Transport Access Rights Between Doxis Environments Using Transport Packages

Here’s a clean, practical walkthrough you can follow to **reliably transport access rights (not access rules)** from one Doxis environment to another using transport packages[^1].

---

## Step-by-Step: Transporting Access Rights Between Systems

### Phase 1 — Prepare the Transport Package (cubeDesigner)

#### 1. Create a Package Definition

* Open **cubeDesigner**
* Go to **Miscellaneous → Tools → Transport**
* Create a **new package definition**
* Give it a clear, meaningful name

---

#### 2. Select All Relevant Objects

This is critical.

Access rights are **attached to objects**, not transported independently.
So you must include:

* Object types (e.g., document types, folders, classes)
* Any related configurations
* Anything that carries or influences permissions

👉 Important:

* Dependencies are **not automatically resolved in selective transport**
* You must **manually include dependent objects**

If you miss objects, you may also miss their associated rights.

---

#### 3. Consider Organizational Elements

Access rights are assigned to:

* Users
* Groups
* Roles
* Units

Ensure that:

* These entities **exist in the target system**, OR
* They are **also included via transport (e.g., full transport or separate setup)**

Otherwise, rights may not map correctly during import.

---

### Phase 2 — Export the Transport Package (Admin Client)

#### 4. Start Selective Export

* Open **Doxis Admin Client**
* Go to **Utilities → Transport**
* Select your package definition
* Start **Selective Export**

---

#### 5. Configure Export Options for Access Rights

This is the most important configuration step.

##### Default behavior:

* Only rights assigned to **units, roles, and groups** are included

##### You MUST decide:

#### ✔ Include user-specific permissions (if needed)

* Enable **“Export user-specific permissions”**
* Required if rights are assigned directly to individual users

---

#### ✔ Understand owner rights

* **Owner rights are always included automatically**
* No configuration needed

---

#### ✔ Ignore access rules (unless explicitly required)

* Access rules are **NOT the same as access rights**
* By default, **access rules are NOT exported**
* Only enable them if explicitly needed

---

### Phase 3 — Import Into Target System

#### 6. Start Import

* In **Admin Client → Utilities → Transport**
* Select the exported package
* Start **Import**

---

#### 7. Ensure Rights Are Actually Imported

##### ✔ Keep this ENABLED:

* **“Import rights and ownerships”**

If disabled:

* No rights will be applied
* Imported objects will get new ownership instead

---

#### 8. Map Recipients Correctly (Critical)

Decide how the system matches:

* Users / Groups / Roles / Units

You have two options:

##### Option A — Match by Name (default)

* Works if both systems have identical naming
* Most common scenario

##### Option B — Match by UUID

* Use when systems were cloned or tightly aligned
* More strict matching

---

#### 9. Decide: Merge or Overwrite Permissions

You must choose how rights behave in the target system:

##### Option A — Merge (default behavior)

* Adds missing permissions
* Keeps existing ones intact

##### Option B — Overwrite

* Completely replaces target permissions with source
* Use carefully (can remove existing rights)

---

#### 10. (Optional) Handle Access Rules Separately

Since access rules ≠ access rights:

* They are **not included by default**
* If needed:

  * Enable export AND import of access rules explicitly
* Otherwise, leave them out

---

#### 11. Run a Test Import First

* Use **Test Run**
* Validate:

  * Object mappings
  * Recipient matching
  * Rights application

Fix issues before actual import

---

#### 12. Execute Final Import

* Run the actual import after validation
* Monitor logs and results

---

## Key Rules to Remember

#### 1. Rights are transported WITH objects

You cannot transport access rights alone.

---

#### 2. Default scope is limited

Only:

* Units
* Roles
* Groups
  are included by default

👉 User-level permissions require explicit inclusion

---

#### 3. Owner rights are always included

No configuration needed

---

#### 4. Access rules are separate

They are:

* Not included by default
* Independently controlled

---

#### 5. Target system alignment matters

Rights only work if:

* Recipients (users/groups/etc.) exist
* Matching works (name or UUID)

---

#### 6. Import settings determine outcome

Especially:

* Import rights toggle
* Merge vs overwrite
* Recipient matching

---

## When to Use Full Transport Instead

Use **complete transport** instead of selective if:

* You want **everything including all rights**
* Systems are closely aligned
* You want minimal configuration risk

---
[^1]: [PackagingRights](./PackagingRights.md)
