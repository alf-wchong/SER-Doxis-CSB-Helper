## Endpoint to query audit trail via REST

The spec defines:

* **POST** `/auditTrail/search` (operationId `searchAuditRecords`) 
* It searches audit trail entries and explains that the object IDs involved in an action are stored in **target references** (`target1Reference`, `target2Reference`, `target3Reference`). 
* **Important constraint:** you must provide at least one repository **unless** `searchInGlobalTable=true`. 
* The operation type numbers can be determined via `GET /auditCategories` or `GET /auditCategories/{categoryId}`. 

Also note the base server path in the spec is:

* `"/restws/publicws/rest/api/v1"` 

So the full URL is typically:
`https://<host>/restws/publicws/rest/api/v1/auditTrail/search`

## The request body fields you should use (exact schema)

The request body is `AuditQueryWsTO`. 

Key fields (from the schema):

* `searchInGlobalTable` (boolean) 
* `contentRepositoryIds` (array of repository UUIDs) 
* `target1References` / `target2References` / `target3References` (arrays of `AuditTargetReferenceWsTO`)  
* `startDate` / `endDate` (date-time) 
* `userLoginNames`, `roleIds`, etc. 
* `operationTypeNrs` or operation type range (`operationTypeStartNr`, `operationTypeEndNr`) 
* `orderByStatements` and `maxHits` 

Each target reference object (`AuditTargetReferenceWsTO`) can include:

* `referenceId` (the object UUID)
* `contentRepositoryId`
* `schemaMetaType` (includes `RECORD` among many enums)
* `instanceDate` 

## Concrete example: find who logically deleted your record UUID

Because your record deletion only showed up when you used `--globalSearch` in csbcmd, you’ll likely want:

* `searchInGlobalTable: true`
* `target1References` containing your UUID with `schemaMetaType: "RECORD"`

### Example payload (global):

```json
{
  "searchInGlobalTable": true,
  "target1References": [
    {
      "referenceId": "0a5b062f-bd40-45ba-8caa-c20bd57038cc",
      "schemaMetaType": "RECORD"
    }
  ],
  "orderByStatements": [
    { "orderColumn": "TIMESTAMP", "orderType": "ASC" }
  ],
  "maxHits": 200
}
```

The `orderByStatements` column enums include `TIMESTAMP`, and you can sort ASC/DESC. 

Then look in the response `AuditRecordWsTO` for:

* `timestamp`
* `userLoginName`
* `operationTypeNr`
* `target1Reference.referenceId` (should match your UUID)

## Concrete example: find who logically deleted your record UUID but **scoped to a repository** *and* still include the global table

* set `searchInGlobalTable: true`
* set `contentRepositoryIds: ["<repo-uuid>"]`

That matches the OpenAPI fields: `searchInGlobalTable` and `contentRepositoryIds`. 

### Example request (scoped + global)

```bash
curl -X POST "https://<csb-host>/restws/publicws/rest/api/v1/auditTrail/search" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "searchInGlobalTable": true,
    "contentRepositoryIds": ["0bbb062f-bd40-45ba-8caa-c20bd57cccccshow"],
    "target1References": [
      {
        "referenceId": "0a5b062f-bd40-45ba-8caa-c20bd57038cc",
        "schemaMetaType": "RECORD"
      }
    ],
    "orderByStatements": [
      { "orderColumn": "TIMESTAMP", "orderType": "ASC" }
    ],
    "maxHits": 200
  }'
```

### What to look for in the response

In the returned `AuditRecordWsTO` entries, the delete event should be the one with:

* `operationTypeDescription` / `operationTypeNr` corresponding to **logical delete**
* `timestamp` = deletion time
* `userLoginName` = who deleted it
* `target1Reference.referenceId` = your record UUID 
