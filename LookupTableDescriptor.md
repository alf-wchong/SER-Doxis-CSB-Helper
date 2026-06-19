## Step 1 — Create the Global Value List

Navigate to:

**Miscellaneous → Configuration → Global value lists** 

Create a new value list and define at least two columns:

| Column 1 (Index) | Column 2 (Display) |
| ---------------- | ------------------ |
| 1                | Open               |
| 2                | Closed             |
| 3                | Pending            |

The guide explains that a value list may contain multiple columns, where:

* **Index column** contains the value stored in the database.
* **Display column** contains the text shown to the user. 

Example:

| StatusCode | StatusText |
| ---------- | ---------- |
| 1          | Open       |
| 2          | Closed     |
| 3          | Pending    |

---

## Step 2 — Create the Descriptor

Navigate to the descriptor table and create a new descriptor. 

Configure:

| Property        | Value  |
| --------------- | ------ |
| Name            | Status |
| Type            | Number |
| Decimal places  | 0      |
| Multiple values | None   |
| Usage           | Index  |

The Number type is intended for integer values such as 1, 2, 3. 

---

## Step 3 — Assign the Value List to the Descriptor

Open the descriptor in the **Object Inspector**.

Locate the **Value list** group. The descriptor supports:

* Value list Name
* Display column
* Index column
* Sort column 

Configure:

| Property                    | Value                  |
| --------------------------- | ---------------------- |
| Value list → Name           | Your Global Value List |
| Value list → Display column | Column 2 (StatusText)  |
| Value list → Index column   | Column 1 (StatusCode)  |
| Value list → Sort column    | Optional               |

The guide specifically states that assigning a global value list at the descriptor level allows it to be evaluated by controls and result lists automatically. 

---

## Step 4 — Assign the Descriptor to the Document / E-File / Process Class

Enable the descriptor in the target class.

For example:

* Document Class
* E-File Class
* Process Class

Only descriptors assigned to the class can be used for indexing. 

---

## Step 5 — Add a Selection Control to the Dialog

Open the filing dialog and place a:

* Selection Box
* Database Record Selection Control
* Multivalue Selection Control (if applicable)

Bind the control to the numeric descriptor.

The control will write the descriptor value while presenting the value list choices to the user.

---

## Step 6 — Explicitly Configure the Control (Recommended)

Even though the descriptor already references the value list, I recommend configuring the control as well.

In the control's Object Inspector configure:

| Property       | Value                  |
| -------------- | ---------------------- |
| Value list     | Your Global Value List |
| Display column | Column 2               |
| Index column   | Column 1               |

The guide notes that value lists can be assigned directly to controls and that if a value list is assigned directly to a control, it takes precedence over the descriptor-level assignment.  

---

## Step 7 — Result Lists (Optional but Recommended)

If you want users to see **Open / Closed / Pending** in search results instead of **1 / 2 / 3**:

1. Open the Result List definition.
2. Select the column bound to the descriptor.
3. Assign the same Value List.
4. Set:

   * Display column = StatusText
   * Index column = StatusCode

The guide explicitly supports assigning value lists to result list columns for display substitution. 

---

## Expected Runtime Behavior

| Stored Descriptor Value | User Sees |
| ----------------------- | --------- |
| 1                       | Open      |
| 2                       | Closed    |
| 3                       | Pending   |

The database stores the **Number** value while users interact with the friendly text from the value list. This matches the value-list architecture described in the cubeDesigner guide where the **index column** is stored and the **display column** is shown to users. 
