# Wildfly Management Credentials in Kubernetes

This guide describes how to create a Kubernetes Secret with Wildfly management credentials and link it to your Wildfly deployment for secure admin console access.

## Overview

When running Wildfly in Kubernetes, it's best practice to externalize management credentials using Kubernetes Secrets rather than hardcoding them in images or configuration files. This approach provides better security and flexibility for credential management.

## 1. Create the Management Credentials Secret

First, create a Kubernetes Secret containing your desired admin username and password:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: wildfly-management-secret
type: Opaque
data:
  username: YWRtaW4=         # "admin" encoded in base64
  password: U3VwZXJTZWN1cmUxMjM=   # "SuperSecure123" encoded in base64
```

**Note:** The values must be base64 encoded. Use the following commands to encode your credentials:

```bash
echo -n "admin" | base64          # Outputs: YWRtaW4=
echo -n "SuperSecure123" | base64  # Outputs: U3VwZXJTZWN1cmUxMjM=
```

Apply the secret to your cluster:

```bash
kubectl apply -f wildfly-management-secret.yaml
```

## 2. Link the Secret to Your Deployment

### Option A: Using the Wildfly Operator (Recommended)

If using the Wildfly Operator, reference the secret in your `WildFlyServer` resource:

```yaml
apiVersion: wildfly.org/v1alpha1
kind: WildFlyServer
metadata:
  name: wildfly-app
spec:
  applicationImage: "your-wildfly-image:latest"
  secrets:
    - wildfly-management-secret
```

The Operator will automatically mount the secret to `/etc/secrets/wildfly-management-secret/` inside the pod, with:
- Username available at: `/etc/secrets/wildfly-management-secret/username`
- Password available at: `/etc/secrets/wildfly-management-secret/password`

### Option B: Standard Kubernetes Deployment with Volume Mount

For standard Kubernetes deployments, mount the secret as a volume:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wildfly-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wildfly
  template:
    metadata:
      labels:
        app: wildfly
    spec:
      containers:
        - name: wildfly
          image: your-wildfly-image:latest
          ports:
            - containerPort: 8080
            - containerPort: 9990
          volumeMounts:
            - name: mgmt-credentials
              mountPath: "/etc/secrets"
              readOnly: true
      volumes:
        - name: mgmt-credentials
          secret:
            secretName: wildfly-management-secret
```

### Option C: Environment Variables (Alternative)

Alternatively, inject the secret as environment variables:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wildfly-deployment
spec:
  template:
    spec:
      containers:
        - name: wildfly
          image: your-wildfly-image:latest
          env:
            - name: WILDFLY_ADMIN_USER
              valueFrom:
                secretKeyRef:
                  name: wildfly-management-secret
                  key: username
            - name: WILDFLY_ADMIN_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: wildfly-management-secret
                  key: password
```

## 3. Configure Wildfly to Use the Credentials

### Container Startup Script

Create a startup script that reads the credentials and creates the management user:

```bash
#!/bin/bash

if [ -f "/etc/secrets/username" ] && [ -f "/etc/secrets/password" ]; then
    ADMIN_USER=$(cat /etc/secrets/username)
    ADMIN_PASSWORD=$(cat /etc/secrets/password)
    
    # Create management user
    $JBOSS_HOME/bin/add-user.sh \
        --user "$ADMIN_USER" \
        --password "$ADMIN_PASSWORD" \
        --group "" \
        --silent
fi

# Start Wildfly
exec $JBOSS_HOME/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0
```

### Dockerfile Example

```dockerfile
FROM quay.io/wildfly/wildfly:latest

# Copy your startup script
COPY startup.sh /opt/jboss/wildfly/bin/
RUN chmod +x /opt/jboss/wildfly/bin/startup.sh

# Use the startup script as entrypoint
CMD ["/opt/jboss/wildfly/bin/startup.sh"]
```

## 4. Access the Management Console

Once deployed, you can access the Wildfly management console at:
- **Console URL:** `http://your-service:9990/console`
- **Username:** The value you encoded in the secret
- **Password:** The value you encoded in the secret

## Security Best Practices

1. **Use Secrets, not ConfigMaps** for credentials
2. **Restrict RBAC permissions** to limit who can read the secret
3. **Use strong passwords** and rotate them regularly
4. **Enable TLS** for management interfaces in production
5. **Mount secrets as files** rather than environment variables when possible

## Troubleshooting

### Verify Secret Creation
```bash
kubectl get secret wildfly-management-secret -o yaml
```

### Check Secret Mount in Pod
```bash
kubectl exec -it <pod-name> -- ls -la /etc/secrets/
kubectl exec -it <pod-name> -- cat /etc/secrets/username
```

### View Pod Logs
```bash
kubectl logs <pod-name>
```

## Example Complete Deployment

Here's a complete example combining the secret and deployment:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: wildfly-management-secret
type: Opaque
data:
  username: YWRtaW4=
  password: U3VwZXJTZWN1cmUxMjM=

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wildfly-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wildfly
  template:
    metadata:
      labels:
        app: wildfly
    spec:
      containers:
        - name: wildfly
          image: your-wildfly-image:latest
          ports:
            - containerPort: 8080
              name: http
            - containerPort: 9990
              name: management
          volumeMounts:
            - name: mgmt-credentials
              mountPath: "/etc/secrets"
              readOnly: true
      volumes:
        - name: mgmt-credentials
          secret:
            secretName: wildfly-management-secret

---
apiVersion: v1
kind: Service
metadata:
  name: wildfly-service
spec:
  selector:
    app: wildfly
  ports:
    - name: http
      port: 8080
      targetPort: 8080
    - name: management
      port: 9990
      targetPort: 9990
  type: LoadBalancer
```