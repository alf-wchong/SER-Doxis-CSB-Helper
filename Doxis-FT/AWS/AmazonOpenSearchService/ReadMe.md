# Configuring Doxis Fulltext Service Containers to Use AWS OpenSearch Service

## Overview

This document describes how to configure a containerized Doxis Fulltext Service deployment running under Docker Compose to use **AWS OpenSearch Service** as its full text engine.

This configuration applies to:

* Doxis CSB 14.4.x
* Doxis Fulltext Service running in Docker containers
* AWS OpenSearch Service (managed OpenSearch cluster)

This document explicitly does **not** apply to:

* Amazon OpenSearch Serverless
* Elasticsearch self-managed clusters
* OpenSearch Serverless collections

The Doxis documentation distinguishes between:

* `Elasticsearch/OpenSearch`
* `Amazon OpenSearch Serverless`

AWS OpenSearch Service belongs to the first category and must therefore be configured as a normal OpenSearch backend. 

---

# Architecture

Typical deployment:

```text
+---------------------------+
| Docker Host               |
|                           |
|  +-------------------+    |
|  | dx4-fulltext      |    |
|  +-------------------+    |
|            |              |
|            | HTTPS        |
|            v              |
|  AWS OpenSearch Service   |
|  Managed Cluster          |
+---------------------------+
```

The Doxis Fulltext Service container communicates directly with the AWS OpenSearch Service endpoint over HTTPS.

---

# Important Distinction

## AWS OpenSearch Service

Use standard OpenSearch configuration:

```properties
opensearch.client.hosts
```

or corresponding Docker environment variables.

## AWS OpenSearch Serverless

Uses completely different parameters:

```properties
opensearch.client.aws.host
opensearch.client.aws.region
```

The Doxis documentation states:

> “If both a connection to Amazon OpenSearch Serverless and a connection to OpenSearch On Premises or Amazon OpenSearch are configured, Amazon OpenSearch Serverless will be used.” 

Therefore:

* Do **not** configure any `aws.host` parameter
* Do **not** configure Serverless-specific environment variables

---

# Supported Versions

Doxis CSB 14.4 supports:

* OpenSearch 2.19+
* OpenSearch 3.5
* Amazon OpenSearch Service in corresponding versions

The installation guide explicitly states:

> “Amazon OpenSearch (in one of the above versions) … can be used.” 

---

# Docker Environment Variable Mapping

The Docker Image Guide explains that all `sednaft.properties` parameters can be mapped to environment variables by:

1. Converting to uppercase
2. Replacing dots with underscores
3. Prefixing with `DX4_`

Example from the guide:

```text
opensearch.client.aws.host
→ DX4_OPENSEARCH_CLIENT_AWS_HOST
```



Therefore:

| sednaft.properties           | Docker Environment Variable      |
| ---------------------------- | -------------------------------- |
| `opensearch.client.hosts`    | `DX4_OPENSEARCH_CLIENT_HOSTS`    |
| `opensearch.client.ssl`      | `DX4_OPENSEARCH_CLIENT_SSL`      |
| `opensearch.client.user`     | `DX4_OPENSEARCH_CLIENT_USER`     |
| `opensearch.client.password` | `DX4_OPENSEARCH_CLIENT_PASSWORD` |

---

# Recommended Configuration

## Example AWS OpenSearch Endpoint

Example managed cluster endpoint:

```text
search-doxis-prod-abc123.eu-central-1.es.amazonaws.com
```

Example HTTPS endpoint:

```text
https://search-doxis-prod-abc123.eu-central-1.es.amazonaws.com
```

---

# Example `dx4-csb.env`

Create or extend the Docker environment file:

```properties
# -------------------------------------------------------------------
# Doxis CSB connection
# -------------------------------------------------------------------

DX4_CSB_HOSTNAME=dx4csb
DX4_CSB_PORT=8080

# -------------------------------------------------------------------
# AWS OpenSearch Service configuration
# -------------------------------------------------------------------

DX4_OPENSEARCH_CLIENT_HOSTS=search-doxis-prod-abc123.eu-central-1.es.amazonaws.com:443
DX4_OPENSEARCH_CLIENT_SSL=true

# Optional: basic authentication
DX4_OPENSEARCH_CLIENT_USER=doxis_fulltext
DX4_OPENSEARCH_CLIENT_PASSWORD=SuperSecurePassword123

# -------------------------------------------------------------------
# Fulltext JVM settings
# -------------------------------------------------------------------

DX4_FULLTEXT_HEAP_MAX="-XX:MaxRAMPercentage=75"

# -------------------------------------------------------------------
# Logging
# -------------------------------------------------------------------

DX4_FULLTEXT_LOGDEV=STDOUT_FILE
```

---

# Important Notes About `DX4_OPENSEARCH_CLIENT_HOSTS`

The Docker guide shows the legacy Elasticsearch variable:

```properties
DX4_FULLTEXT_ELASTIC_HOSTS=myElasticHostname:9200
```



However, for OpenSearch, the modern parameter is:

```properties
DX4_OPENSEARCH_CLIENT_HOSTS
```

The host value:

* must include hostname and port
* must not include path components
* should normally use port `443`
* should not include `https://`

Correct:

```properties
DX4_OPENSEARCH_CLIENT_HOSTS=search-prod.eu-central-1.es.amazonaws.com:443
```

Incorrect:

```properties
DX4_OPENSEARCH_CLIENT_HOSTS=https://search-prod.eu-central-1.es.amazonaws.com
```

---

# Docker Compose Example

## `docker-compose.yml`

```yaml
version: '3.8'

services:

  dx4-fulltext:
    image: dx4-fulltext:14.4.0

    container_name: dx4-fulltext

    env_file:
      - dx4-csb.env

    ports:
      - "3099:3099"

    volumes:
      - dx4Shared:/home/doxis4/shared

    healthcheck:
      test:
        [
          "CMD",
          "wget",
          "--no-proxy",
          "--spider",
          "http://localhost:3099/isAlive"
        ]
      start_period: 90s
      interval: 30s
      timeout: 10s
      retries: 3

    restart: unless-stopped

volumes:
  dx4Shared:
```

This structure is based on the official [Docker Image Guide](https://services.sergroup.com/documentation/#/view/PD_CSB_Short/14.4.0/en-us/DIG_Doxis_CSB/WEBHELP/CSB/topics/reference-run-image-dockercompose.html) example. 

---

# Starting the Environment

Start the container:

```bash
docker compose up -d
```

The Docker guide defines the same startup command. 

---

# Verifying Connectivity

## Container Health

Check Doxis Fulltext Service readiness:

```bash
curl http://localhost:3099/isReady
```

Expected result:

```text
HTTP 200
```

The Docker guide documents the same endpoint. 

---

# Verifying OpenSearch Connectivity

Check logs:

```bash
docker logs dx4-fulltext
```

Successful startup should show:

* OpenSearch client initialization
* successful cluster connection
* index initialization

Typical errors include:

* SSL trust failures
* authentication failures
* DNS resolution failures
* incorrect endpoint format

---

# TLS / Certificate Considerations

AWS OpenSearch Service uses public TLS certificates.

If custom CA certificates are required, the Docker guide supports automatic import into the Java truststore.

Certificates placed in:

```text
/home/doxis4/shared/certificate
```

are automatically imported. 

Optional override:

```properties
DX4_CERTIFICATE_IMPORT_DIR=/home/doxis4/myCertDir
```

---

# IAM vs Basic Authentication

AWS OpenSearch Service can use:

* Internal user database
* IAM authentication
* SAML
* Cognito

Doxis Fulltext Service supports standard OpenSearch username/password authentication.

Recommended approach:

* enable OpenSearch internal users
* create dedicated service account
* grant index permissions only

Example:

```text
Username: doxis_fulltext
Role: fulltext_rw
```

---

# Required OpenSearch Permissions

The Doxis Fulltext Service requires index-level permissions including:

* create index
* update index
* read documents
* write documents

The Serverless documentation lists analogous permissions such as:

* `CreateIndex`
* `UpdateIndex`
* `ReadDocument`
* `WriteDocument`



Equivalent permissions are required in AWS OpenSearch Service security roles.

---

# Example OpenSearch Security Role

Example role permissions:

```json
{
  "cluster_permissions": [
    "cluster_composite_ops"
  ],
  "index_permissions": [
    {
      "index_patterns": [
        "dx4*"
      ],
      "allowed_actions": [
        "create_index",
        "write",
        "read",
        "manage"
      ]
    }
  ]
}
```

---

# Common Misconfiguration

## Incorrect: Using Serverless Parameters

Do not configure:

```properties
DX4_OPENSEARCH_CLIENT_AWS_HOST
DX4_OPENSEARCH_CLIENT_AWS_REGION
```

These activate OpenSearch Serverless mode.

---

# Common Misconfiguration

## Incorrect Endpoint Format

Incorrect:

```properties
DX4_OPENSEARCH_CLIENT_HOSTS=https://endpoint
```

Correct:

```properties
DX4_OPENSEARCH_CLIENT_HOSTS=endpoint:443
```

---

# Common Misconfiguration

## SSL Disabled

AWS OpenSearch Service requires HTTPS.

Always configure:

```properties
DX4_OPENSEARCH_CLIENT_SSL=true
```

---

# Persistent Volumes

The Docker guide strongly recommends persistent shared volumes. 

Minimum recommended volume:

```yaml
volumes:
  - dx4Shared:/home/doxis4/shared
```

---

# Production Recommendations

## Recommended Settings

```properties
DX4_FULLTEXT_HEAP_MAX="-XX:MaxRAMPercentage=75"
DX4_FULLTEXT_LOGDEV=STDOUT_FILE
DX4_NETWORKADDRESS_CACHE_TTL=60
```

---

# Security Recommendations

## Use Dedicated Service Accounts

Do not use:

* master users
* administrative OpenSearch users

Use:

* dedicated Doxis Fulltext user
* least privilege permissions

---

# Security Recommendations

## Avoid Plaintext Passwords

Recommended approaches:

* Docker secrets
* Kubernetes secrets
* Vault integration
* environment injection from CI/CD

---
# Additional Section: Extending the `dx4-fulltext` Image with AWS Troubleshooting Tools

This section describes how to extend the official `dx4-fulltext` Docker image to include AWS operational and troubleshooting tooling such as:

* AWS CLI v2
* `awscurl`
* `curl`
* `jq`
* DNS/network debugging utilities

The goal is to simplify troubleshooting of:

* AWS OpenSearch Service connectivity
* IAM credential resolution
* TLS/certificate issues
* DNS/network routing
* SigV4 authentication validation

This section assumes:

* Docker Compose deployment
* Containers running on an EC2 instance
* IAM permissions provided via the EC2 instance role (preferred)
* Ubuntu 24.04-based Doxis image

The base image is documented as:

```text id="3y0g1v"
Ubuntu 24.04.3 LTS
```

---

# Why Additional Tooling Is Useful

The standard `dx4-fulltext` image is intentionally minimal and does not include:

* AWS CLI
* `awscurl`
* `dig`
* `nslookup`
* `jq`

These tools are extremely useful when troubleshooting:

| Problem                  | Tool                          |
| ------------------------ | ----------------------------- |
| Verify IAM credentials   | `aws sts get-caller-identity` |
| Verify DNS               | `dig`, `nslookup`             |
| Verify TLS               | `openssl s_client`            |
| Verify OpenSearch access | `awscurl`                     |
| Inspect JSON responses   | `jq`                          |

---

# Recommended Authentication Model

## Preferred: EC2 Instance Profile (IAM Role)

Do **not** hardcode:

```text id="i6vt6v"
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

Instead, use:

* EC2 Instance Profile
* IAM Role attached to the EC2 instance
* IMDSv2 credential retrieval

This is the AWS-recommended approach.

The container automatically inherits credentials from:

```text id="n0eqoo"
http://169.254.169.254/latest/meta-data/
```

through the AWS SDK credential chain.

Advantages:

* no secrets in Docker Compose
* automatic credential rotation
* centralized IAM management
* easier auditing
* reduced secret leakage risk

---

# Example IAM Policy

Example EC2 role policy:

```json id="0zuj36"
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "es:ESHttpGet",
        "es:ESHttpPost",
        "es:ESHttpPut",
        "es:ESHttpDelete",
        "es:ESHttpHead"
      ],
      "Resource": [
        "arn:aws:es:eu-central-1:123456789012:domain/doxis-prod/*"
      ]
    }
  ]
}
```

---

# Creating a Custom Docker Image

## Directory Structure

```text id="oq0r0x"
.
├── Dockerfile
├── docker-compose.yml
└── dx4-csb.env
```

---

# Example Dockerfile

## Ubuntu 24.04-Based Extension

```dockerfile id="pwghku"
FROM dx4-fulltext:14.4.0

USER root

RUN apt-get update && \
    apt-get install -y \
        curl \
        unzip \
        jq \
        dnsutils \
        iputils-ping \
        net-tools \
        less \
        groff \
        python3 \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------------
# Install AWS CLI v2
# ------------------------------------------------------------------

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
        -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# ------------------------------------------------------------------
# Install awscurl
# ------------------------------------------------------------------

RUN pip3 install --break-system-packages awscurl

USER doxis4
```

---

# Build the Custom Image

```bash id="5v5s3m"
docker build -t dx4-fulltext-aws:14.4.0 .
```

---

# Docker Compose Example

Update the Fulltext service:

```yaml id="fz3pcl"
dx4-fulltext:
  image: dx4-fulltext-aws:14.4.0

  container_name: dx4-fulltext

  env_file:
    - dx4-csb.env

  ports:
    - "3099:3099"

  volumes:
    - dx4Shared:/home/doxis4/shared

  restart: unless-stopped
```

---

# Validating IAM Credentials

## Test Credential Resolution

Enter the container:

```bash id="11f0i4"
docker exec -it dx4-fulltext bash
```

Verify credentials:

```bash id="q3svry"
aws sts get-caller-identity
```

Expected result:

```json id="94h2eu"
{
  "UserId": "AROAXXXXXXXXXXXXX",
  "Account": "123456789012",
  "Arn": "arn:aws:sts::123456789012:assumed-role/doxis-ec2-role/i-0123456789abcdef"
}
```

This confirms:

* IAM role inheritance works
* IMDS access works
* AWS SDK credential chain works

---

# Testing OpenSearch Connectivity

## DNS Resolution

```bash id="1zthfx"
dig search-doxis-prod.eu-central-1.es.amazonaws.com
```

---

# TLS Verification

```bash id="g4f4aw"
openssl s_client \
  -connect search-doxis-prod.eu-central-1.es.amazonaws.com:443
```

Verify:

* TLS handshake succeeds
* certificate chain is trusted

---

# Testing Signed OpenSearch Requests

## Using `awscurl`

Example cluster health query:

```bash id="kt7uh0"
awscurl \
  --service es \
  --region eu-central-1 \
  https://search-doxis-prod.eu-central-1.es.amazonaws.com/_cluster/health
```

Expected output:

```json id="f0j1qh"
{
  "cluster_name": "doxis-prod",
  "status": "green"
}
```

---

# Testing Index Access

Example:

```bash id="i8r66j"
awscurl \
  --service es \
  --region eu-central-1 \
  https://search-doxis-prod.eu-central-1.es.amazonaws.com/_cat/indices?v
```

---

# Verifying Doxis Fulltext Configuration

Inside the container:

```bash id="zz0j2g"
cat /home/doxis4/shared/dx4Fulltext/sedna.conf/sednaft.properties
```

Verify:

```properties id="dkbhw4"
opensearch.client.hosts=search-doxis-prod.eu-central-1.es.amazonaws.com:443
opensearch.client.ssl=true
```

Ensure these are absent:

```properties id="4tb87v"
opensearch.client.aws.host
opensearch.client.aws.region
```

because those activate OpenSearch Serverless mode.

---

# Optional: Force IMDSv2 Usage

For improved security, enforce IMDSv2 on the EC2 instance.

Example:

```bash id="1b1bje"
aws ec2 modify-instance-metadata-options \
  --instance-id i-0123456789abcdef \
  --http-tokens required
```

---

# Optional: Restrict Metadata Access

If desired, Docker can explicitly allow IMDS access:

```yaml id="c3wn3x"
extra_hosts:
  - "169.254.169.254:169.254.169.254"
```

Usually unnecessary on EC2.

---

# Troubleshooting Matrix

| Symptom                        | Likely Cause                        |
| ------------------------------ | ----------------------------------- |
| `Unable to locate credentials` | EC2 role missing                    |
| `401 Unauthorized`             | insufficient OpenSearch permissions |
| `403 Forbidden`                | IAM policy denies ESHttp actions    |
| `SSLHandshakeException`        | TLS trust issue                     |
| `UnknownHostException`         | DNS/network issue                   |
| `Connection refused`           | security group or endpoint issue    |

---

# Security Recommendations

## Recommended

* EC2 Instance Profile
* least privilege IAM policy
* HTTPS only
* restricted OpenSearch access policy
* VPC-only OpenSearch endpoint

## Avoid

* hardcoded AWS secrets
* public OpenSearch domains
* broad `es:*` permissions
* disabling TLS validation

---

# Example Production Configuration

## `dx4-csb.env`

```properties id="8rz7vz"
DX4_CSB_HOSTNAME=dx4csb
DX4_CSB_PORT=8080

DX4_OPENSEARCH_CLIENT_HOSTS=search-doxis-prod.eu-central-1.es.amazonaws.com:443
DX4_OPENSEARCH_CLIENT_SSL=true

DX4_FULLTEXT_HEAP_MAX="-XX:MaxRAMPercentage=75"

DX4_FULLTEXT_LOGDEV=STDOUT_FILE
```

No AWS keys required.

---

# Summary

Recommended production architecture:

```text id="r8u2mh"
Doxis Fulltext Container
    ↓
EC2 Instance Role
    ↓
AWS IMDSv2
    ↓
AWS OpenSearch Service
```

Recommended tooling additions:

* AWS CLI v2
* `awscurl`
* `jq`
* `dnsutils`
* TLS/network diagnostics

Recommended authentication model:

* EC2 Instance Profile
* IAM Role
* no static AWS credentials

To configure Doxis Fulltext Service containers for AWS OpenSearch Service:

Use:

```properties
DX4_OPENSEARCH_CLIENT_HOSTS=<endpoint>:443
DX4_OPENSEARCH_CLIENT_SSL=true
DX4_OPENSEARCH_CLIENT_USER=<user>
DX4_OPENSEARCH_CLIENT_PASSWORD=<password>
```

Do not use:

```properties id="lc1njz"
DX4_OPENSEARCH_CLIENT_AWS_HOST
DX4_OPENSEARCH_CLIENT_AWS_REGION
```

because those activate Amazon OpenSearch Serverless mode instead.
