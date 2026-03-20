# ✅ Transporting Access Rights — Pre-Flight & Execution Checklist

## 🧩 Package Preparation (cubeDesigner)

* ☐ Create a **package definition** in cubeDesigner
* ☐ Include **all objects that carry access rights** (types, classes, configs, etc.)
* ☐ Manually include **dependent objects** (no automatic dependency resolution)
* ☐ Verify all selected objects are **correct and complete**

---

## 👥 Organizational Alignment

* ☐ Confirm required **users, groups, roles, and units exist** in target system
* ☐ If not, ensure they are:

  * ☐ Transported separately, OR
  * ☐ Created manually in target
* ☐ Decide whether matching will be by:

  * ☐ Name (default)
  * ☐ UUID

---

## 📦 Export Configuration (Admin Client)

* ☐ Select correct **package definition** for export
* ☐ Confirm **selective export** is being used (if applicable)

### Access Rights Options

* ☐ Understand default: only **groups, roles, units** are included
* ☐ Enable **“Export user-specific permissions”** (if needed)
* ☐ Confirm **owner rights will be included automatically**

### Access Rules (separate from rights)

* ☐ Leave disabled (default), OR
* ☐ Enable **Export access rules** if explicitly required

---

## 📥 Import Configuration (Target System)

* ☐ Start import in **Admin Client → Transport**

### Critical Rights Settings

* ☐ Ensure **“Import rights and ownerships” is ENABLED**

### Recipient Matching

* ☐ Confirm matching strategy:

  * ☐ By Name
  * ☐ By UUID

### Permission Behavior

* ☐ Choose one:

  * ☐ Merge permissions (add missing only)
  * ☐ Overwrite permissions (replace completely)

### Access Rules (if used)

* ☐ Enable **Import access rules** (only if exported intentionally)

---

## 🧪 Validation

* ☐ Run **Test Run** before actual import
* ☐ Verify:

  * ☐ Objects are correctly mapped
  * ☐ Recipients are correctly resolved
  * ☐ Access rights appear as expected
* ☐ Resolve any errors before proceeding

---

## 🚀 Execution

* ☐ Perform **final import**
* ☐ Monitor logs during import
* ☐ Confirm successful completion

---

## 🔍 Post-Import Verification

* ☐ Validate access rights on key objects
* Confirm:

  * ☐ Group/role/unit permissions applied correctly
  * ☐ User-specific permissions (if included) are correct
  * ☐ Ownership is correct
* Spot-check critical business scenarios

---

## ⚠️ Common Pitfalls

* Forgot to include dependent objects
* Missing users/groups in target system
* User-specific permissions not exported
* “Import rights” option disabled
* Wrong merge/overwrite choice
* Access rules expected but not enabled

---

