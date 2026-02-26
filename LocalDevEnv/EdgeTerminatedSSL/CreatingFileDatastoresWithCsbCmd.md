# Doxis CSB (14.3.x) — Configure Storage Service + File System Adapter + Datastore for customer "Train" using csbcmd

> Notes:
> - These steps were executed inside the csbcmd container/shell.
> - csbcmd requires you to log in to BOTH Admin Service and CSB for the tenant-scoped operations
>   (importing the node into the tenant and assigning adapters/datastores).

## 1) Log in to Admin Service (DOMAIN scope)
### Account: Superadmin (domain)
```bash
csbcmd login.admin --host dx4-admin --port 9080 --user Superadmin --password '***REDACTED***'
```

## 2) Log in to CSB (TENANT scope)
### Account: Supervisor (role admins) in customer/tenant/org: Train
```bash
csbcmd login.csb --host dx4-csb --port 8080 --user Supervisor --password '***REDACTED***' --customer Train
```

## 3) Verify Storage Service node exists and is alive (DOMAIN scope)
### Uses Admin Service session
```bash
csbcmd show.domainstatus --storageService
```

## 4) IMPORTANT: Ensure the Storage Service "external" connection is reachable from csbcmd runtime
 Problem observed:
 - storage.dx4localdev.duckdns.org resolved to 127.0.0.1 inside the csbcmd container, causing StorageService ping to fail.
 
 Fix: 
 - Change Storage Service node connection to internal docker DNS name and port.

# Uses Admin Service session
```bash
csbcmd storage.service.change.admin --name DCDX4Storage --host dx4-storage --port 8080 --protocol HTTP --context storagesystem
```

## 5) Create filesystem storage adapter at domain level (DOMAIN scope)
### Uses Admin Service session
 File system path is the absolute path on the Storage Service host (here: inside dx4-storage container)
```bash
csbcmd storage.adapter.create.fs --name DockerVolume --storageServiceName DCDX4Storage --path /home/doxis4/dx4Storage
```

## 6) Import Storage Service node into tenant/customer/org "Train" (TENANT scope)
### Requires BOTH sessions: Admin Service + CSB (logged into Train)

```bash
csbcmd storage.service.import --name DCDX4Storage
```

## 7) Assign adapter to Storage Service for tenant/customer/org "Train" (TENANT scope)
### Requires BOTH sessions: Admin Service + CSB (logged into Train)
```bash
csbcmd storage.service.addadapter --storageAdapterName DockerVolume --storageServiceName DCDX4Storage
```
## 8) Create datastore on that adapter for tenant/customer/org "Train" (TENANT scope)
### Requires BOTH sessions: Admin Service + CSB (logged into Train)
 __internalName must have no spaces__
 ```bash
csbcmd storage.adapter.adddatastore --storageServiceName DCDX4Storage --storageAdapterName DockerVolume --internalName ds_dockervol_dx4Storage --dataStoreName "Train DockerVol dx4Storage"
```

## 9) Verify Storage Service node status again
```bash
csbcmd show.domainstatus --storageService
```
