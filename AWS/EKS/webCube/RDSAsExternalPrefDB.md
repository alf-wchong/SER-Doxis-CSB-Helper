# Doxis webCube on Kubernetes with AWS RDS PostgreSQL and Kubernetes Secrets 🧩

Configure a Tomcat-based Doxis webCube container so that webCube stores its user settings and server-profile data in an external AWS RDS PostgreSQL database instead of the embedded Derby database.

The key design decision is this: **do not use the chart-native `webcube.db.*` path when database credentials must be supplied securely through Kubernetes Secrets**. The chart exposes database URL and driver parameters, but it does not document a first-class username/password Secret reference. The workaround is to mount a Tomcat `webcube.xml` context file from a Kubernetes Secret, define the PostgreSQL datasource in that file, and configure webCube to use the JNDI name declared by that Tomcat resource.


## What this setup accomplishes ✅

1. AWS RDS PostgreSQL hosts the webCube user-settings database.
2. Kubernetes stores the webcube.xml file (that contains the Tomcat datasource) as a Secret.
3. The Secret is mounted as Tomcat’s `webcube.xml` context file.
4. webCube is configured to use the JNDI datasource name, for example `jdbc/webCube`.
5. webCube persists user settings and server profiles in PostgreSQL instead of Derby.

The Doxis documentation supports using an external database for user settings via a JNDI resource. The default embedded database is Apache Derby, while an external database is referenced through a JNDI name such as `jdbc/<Name>`.[^installation-external-db] [^installation-jndi-user-settings]

## Assumptions used

The examples use placeholder values. Replace them with values from the customer environment.

| Item | Example value |
|---|---|
| Kubernetes namespace | `doxis` |
| Helm release name | `webcube` |
| Kubernetes Secret name | `webcube-db-context` |
| AWS RDS endpoint | `webcube-postgres.cluster-abcdefghijkl.eu-west-1.rds.amazonaws.com` |
| PostgreSQL port | `5432` |
| Database name | `webcube` |
| Database username | `<DB_USERNAME>` |
| Database password | `<DB_PASSWORD>` |
| Tomcat JNDI datasource name | `jdbc/webCube` |
| Tomcat context file path | `/home/doxis4/tomcat/conf/Catalina/localhost/webcube.xml` |

## Step 1 — Prepare the AWS RDS PostgreSQL database 🗄️

Create or identify an AWS RDS PostgreSQL instance that is reachable from the EKS worker nodes running webCube.

At minimum, confirm the following:

- The RDS security group allows inbound PostgreSQL traffic from the EKS node security group, usually TCP `5432`.
- The EKS pods can resolve the RDS endpoint through DNS.
- The database exists, for example `webcube`.
- The database user exists, for example `<DB_USERNAME>`.
- The user has permissions to create required schema objects and to read/write/update/delete data used by webCube.

A representative JDBC URL looks like this:

```text
jdbc:postgresql://webcube-postgres.cluster-abcdefghijkl.eu-west-1.rds.amazonaws.com:5432/webcube
```

Do not put the username and password into the Helm `values.yaml`. They will be placed inside a Kubernetes Secret as part of the Tomcat context file.

## Step 2 — Create the Tomcat `webcube.xml` datasource file 🔐

The Doxis-provided webCube image runs webCube in Tomcat. For Tomcat, the datasource can be declared as a `Resource` in the web application context file.

Create a local file named `webcube.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Context path="/webcube">
  <Resource
    auth="Container"
    driverClassName="org.postgresql.Driver"
    maxActive="4"
    maxIdle="2"
    maxWait="5000"
    name="jdbc/webCube"
    type="javax.sql.DataSource"
    url="jdbc:postgresql://webcube-postgres.cluster-abcdefghijkl.eu-west-1.rds.amazonaws.com:5432/webcube"
    username="<DB_USERNAME>"
    password="<DB_PASSWORD>"
  />
</Context>
```

The important field is `name="jdbc/webCube"`. Later, the same value must be configured in the webCube administration console under **System Settings > Global Settings > JNDI name for database with user settings**.

## Step 3 — Store `webcube.xml` as a Kubernetes Secret 🧾

Create the namespace if it does not already exist:

```bash
kubectl create namespace doxis
```

Create a Kubernetes Secret from the local file:

```bash
kubectl -n doxis create secret generic webcube-db-context \
  --from-file=webcube.xml=./webcube.xml
```

Verify that the Secret exists:

```bash
kubectl -n doxis get secret webcube-db-context
```

For GitOps-based deployments, define the Secret through your approved secret-management process instead of committing credentials to Git. For example, use External Secrets Operator, Sealed Secrets, SOPS, or the platform’s existing secret workflow. The resulting Kubernetes Secret still needs to contain a key named `webcube.xml`.

## Step 4 — Configure Helm values to mount the Secret into Tomcat ⚙️

Use this pattern to mount your own Tomcat context file. Keep `webcube.db.enabled: false`; otherwise, the chart-generated database configuration may overwrite or conflict with the mounted `webcube.xml`.

```yaml
webcube:
  db:
    # Disable the chart-generated external DB configuration.
    # Secret-based approach is to mount a site-specific Tomcat context file.
    enabled: false

extraVolumes:
  - name: webcube-db-context
    secret:
      secretName: webcube-db-context

extraVolumeMounts:
  - name: webcube-db-context
    mountPath: /home/doxis4/tomcat/conf/Catalina/localhost/webcube.xml
    subPath: webcube.xml
    readOnly: true
```

The reason for `webcube.db.enabled: false` is practical: when `webcube.db.enabled` is set to `true`, the chart generates its own database configuration, which can overwrite the mounted `webcube.xml`.

The chart-native database parameters are still useful to understand the chart’s intent, but they are not sufficient for this Secret-based credential pattern because the Helm Chart Guide documents the external database connection URL and driver settings, not a first-class username/password Secret reference.[^helm-db-params]

## Step 5 — Deploy or upgrade webCube 🚀

Install or upgrade the Helm release with the values file:

```bash
helm upgrade --install webcube <path-or-repo>/doxis-webcube \
  --namespace doxis \
  --values values-webcube-rds.yaml
```

Watch the rollout:

```bash
kubectl -n doxis rollout status deployment/webcube
```

Confirm that the pod is running:

```bash
kubectl -n doxis get pods -l app.kubernetes.io/instance=webcube
```

If your chart uses different labels or deployment names, adjust the selector accordingly.

## Step 6 — Confirm the Tomcat context file is mounted 🔎

Find the webCube pod name:

```bash
POD=$(kubectl -n doxis get pod \
  -l app.kubernetes.io/instance=webcube \
  -o jsonpath='{.items[0].metadata.name}')
```

Check that `webcube.xml` exists in the expected Tomcat location:

```bash
kubectl -n doxis exec "$POD" -- \
  ls -l /home/doxis4/tomcat/conf/Catalina/localhost/webcube.xml
```

Optionally inspect the file content:

```bash
kubectl -n doxis exec "$POD" -- \
  sed -n '1,120p' /home/doxis4/tomcat/conf/Catalina/localhost/webcube.xml
```

Treat this output as sensitive because it contains database credentials.

## Step 7 — Set the JNDI name in the webCube admin console 🧭

Open the webCube administration console:

```text
https://<webcube-host>/webcube/admin
```

Then configure:

```text
System Settings > Global Settings > JNDI name for database with user settings = jdbc/webCube
```

The value must exactly match the `name` attribute in the Tomcat `Resource`:

```xml
name="jdbc/webCube"
```

This is the handoff point between Tomcat and webCube: Tomcat provides the datasource, and webCube is told which JNDI resource to use for its user-settings database. The Installation Guide describes this same concept: `derby` uses the embedded Apache Derby database, while a value like `jdbc/<Name>` points webCube to an external JNDI datasource.[^installation-jndi-user-settings]

> [!IMPORTANT]
> Save the setting.

## Step 8 — Restart the webCube pod 🔄

> [!IMPORTANT]
> The pod needs to be restarted after saving the JNDI setting.[^webcube-admin-global-settings]

Restart the deployment:

```bash
kubectl -n doxis rollout restart deployment/webcube
kubectl -n doxis rollout status deployment/webcube
```

If the deployment name differs, get the exact name first:

```bash
kubectl -n doxis get deployments
```

## Step 9 — Validate persistence ✅

After the pod restarts:

1. Log back in to the webCube administration console.
2. Create or adjust a test setting that is safe to change, or create a test CSB server profile if appropriate.
3. Save and apply the setting.
4. Restart the webCube pod again.
5. Confirm that the setting remains available after restart.

Server profiles are relevant because the Administrator Guide states that server-profile parameters are stored in the user settings database.[^admin-server-profiles] Once webCube is pointed to the PostgreSQL-backed JNDI datasource, those server-profile settings should persist there rather than in Derby.

## Troubleshooting 🛠️

### The mounted `webcube.xml` disappears or is overwritten

Check whether `webcube.db.enabled` is set to `true`. For this Secret-mounted `webcube.xml` approach, use:

```yaml
webcube:
  db:
    enabled: false
```

The chart-generated database configuration can conflict with the mounted Tomcat context file when the chart-native DB path is enabled.[^webcube-admin-global-settings]

### webCube still uses Derby

Check the admin setting:

```text
System Settings > Global Settings > JNDI name for database with user settings
```

If it is set to `derby`, webCube uses the embedded Apache Derby database. Set it to the Tomcat resource name, for example:

```text
jdbc/webCube
```

The Installation Guide documents this distinction between `derby` and a JNDI name such as `jdbc/<Name>`.[^installation-jndi-user-settings]

### PostgreSQL connection fails

Check these items:

- The RDS endpoint is correct.
- The RDS security group allows inbound TCP `5432` from EKS.
- The database name exists.
- The username and password in `webcube.xml` are correct.
- The database user has the required permissions.
- The PostgreSQL JDBC driver is available in the webCube container.

The Helm Chart Guide lists `org.postgresql.Driver` as the default external database driver class and includes a JDBC driver URL parameter for downloading the PostgreSQL driver.[^helm-db-params]

### The pod starts, but settings do not persist after restart

Confirm all three layers line up:

1. The Secret contains `webcube.xml`.
2. The file is mounted to:

   ```text
   /home/doxis4/tomcat/conf/Catalina/localhost/webcube.xml
   ```

3. The webCube admin setting is exactly:

   ```text
   jdbc/webCube
   ```

If any of those values differ, webCube may not use the external datasource.

## Recommended final files 📦

A minimal deployment folder could look like this:

```text
webcube-rds/
├── README.md
├── values-webcube-rds.yaml
└── webcube.xml                  # do not commit if it contains real credentials
```

For real deployments, do not commit `webcube.xml` with production credentials. Store it in the organization’s approved secret-management system and let that system create the Kubernetes Secret.

## Summary

For a secure AWS RDS PostgreSQL setup, configure webCube through Tomcat JNDI. The practical sequence is:

1. Define the PostgreSQL datasource in `webcube.xml`.
2. Store `webcube.xml` as a Kubernetes Secret.
3. Mount the Secret into Tomcat’s context-file location.
4. Keep `webcube.db.enabled: false` to avoid chart-generated conflicts.
5. Set webCube’s **JNDI name for database with user settings** to `jdbc/webCube`.
6. Restart the pod and validate persistence.

That gives webCube a persistent PostgreSQL-backed server profile and user-settings database.

---

[^helm-db-params]: *Doxis webCube Helm Chart Guide*, [**Parameters > webCube application parameters**](https://services.sergroup.com/documentation/api/documentations/75/420/1222/WEBHELP/index.html#webcube-application-parameters). The chart documents `webcube.db.enabled`, `webcube.db.driverClass`, `webcube.db.connectionUrl`, and `webcube.db.jdbcDriverUrl` for external database configuration.

[^installation-external-db]: *Doxis Web 14.4.0 Installation Guide*, [**Section 6: Configuring external databases**](https://services.sergroup.com/documentation/api/documentations/7/600/1929/WEBHELP/APP_webCube/topics/top_adm_userprefs.html). The guide describes using JNDI resources for external databases.

[^installation-jndi-user-settings]: *Doxis Web 14.4.0 Installation Guide*, [**Section 9.7: Using JNDI resources for new user settings**](https://services.sergroup.com/documentation/api/documentations/7/600/1929/WEBHELP/APP_webCube/topics/tsk_adm_userprefs_jndi_register_admconsole.html). The guide distinguishes `derby` for the embedded Apache Derby database from `jdbc/<Name>` for an external JNDI datasource.

[^admin-server-profiles]: *Doxis Web 14.4.0 Administrator Guide*, [**Section 2.1: Understanding server profiles**](https://services.sergroup.com/documentation/api/documentations/7/600/1928/WEBHELP/APP_webCube/topics/con_adm_serverprofiles.html). The guide states that server-profile parameters are stored in the user settings database.

[^webcube-admin-global-settings]: Set [**System Settings > Global Settings > JNDI name for database with user settings**](https://services.sergroup.com/documentation/api/documentations/7/600/1928/WEBHELP/APP_webCube/topics/ref_adm_globalsettings.html) to the same value, and restart the webCube pod after saving.
