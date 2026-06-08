# Doxis 14.x AWS Lab Reference Architecture

## Environment Overview

This architecture is intended for:

* Doxis 14.x Kubernetes deployment
* Single-user lab and demonstration environment
* Approximately 5 concurrent users
* AWS-managed infrastructure wherever practical
* Low operational overhead
* Functional validation rather than performance benchmarking

Estimated AWS cost:

* Monthly: approximately **$402.36/month** 

[Estimator Calculator worksheet](https://calculator.aws/#/estimate?id=3e639db52701deb9c8c3f6a8cb2fa3e61b252724).

---

# Doxis Components

## Kubernetes Components

* Doxis CSB
* Doxis Admin
* Doxis Storage
* Doxis Agent
* Doxis Fulltext
* Doxis FIPS
* Doxis Business Studio
* Doxis WebCube
* Doxis MobileCube

## Non-Kubernetes Components

* Doxis Imaging Service

---

# DNS Design

The environment uses a wildcard domain:

```text
*.doxis.example.com
```

Example hostnames:

```text
webcube.doxis.example.com
mobilecube.doxis.example.com
businessstudio.doxis.example.com
admin.doxis.example.com
agent.doxis.example.com
```

All public traffic enters through a single Application Load Balancer.

---

# Service Dependency Matrix

| AWS Service               | Used By                                                  |
| ------------------------- | -------------------------------------------------------- |
| Amazon EKS                | All Kubernetes-based Doxis components                    |
| Amazon EC2 (Linux)        | EKS worker nodes hosting Doxis workloads                 |
| Amazon EC2 (Windows)      | Doxis Imaging Service                                    |
| Amazon RDS PostgreSQL     | CSB, Admin, FIPS                                         |
| Amazon S3                 | Doxis Storage                                            |
| Amazon OpenSearch Service | Doxis Fulltext                                           |
| Application Load Balancer | WebCube, MobileCube, Business Studio, CSB REST endpoints |
| Route53                   | DNS for Doxis hostnames                                  |
| AWS Certificate Manager   | TLS certificate for ALB                                  |
| AWS Secrets Manager       | Database credentials and application secrets             |
| CloudWatch                | Monitoring and logging                                   |
| VPC                       | Networking for all services                              |

---

# Amazon EKS

## Purpose

Provides the managed Kubernetes control plane for:

* CSB
* Admin
* Storage
* Agent
* Fulltext
* FIPS
* Business Studio
* WebCube
* MobileCube

## Calculator Sizing

* 1 EKS Cluster 

### Pros

* Managed Kubernetes control plane
* Supports future scaling
* Minimal operational overhead
* Native AWS integrations

### Cons

* EKS control plane cost is relatively high compared to lab workload
* More complex than a VM-only deployment

### Assessment

Appropriately sized.

---

# Linux Worker Nodes

## Purpose

Host all Kubernetes workloads.

## Calculator Sizing

* 2 × t3a.xlarge
* Linux
* 50 GB EBS each
* Spot pricing model 

### Effective Capacity

* 8 vCPU total
* 32 GB RAM total

### Pros

* Sufficient capacity for all enabled Doxis services
* Provides scheduling flexibility
* Supports node maintenance without immediately impacting workloads
* Good cost-to-capacity ratio

### Cons

* Spot interruptions may impact demonstrations
* Adequate for a single-user lab

### Assessment

Appropriately sized for a lab.

If demonstration reliability becomes important, move from Spot to On-Demand.

---

# Amazon Elastic Container Registry (ECR)

## Purpose

Amazon Elastic Container Registry (ECR) serves as the private container image repository for all Doxis container images deployed into the EKS cluster.

ECR is required because the official Doxis container registry is not publicly accessible from customer AWS environments. Doxis images must therefore be synchronized into a customer-controlled ECR repository prior to deployment.

Images stored in ECR include:

* Doxis CSB
* Doxis Admin
* Doxis Storage
* Doxis Agent
* Doxis Fulltext
* Doxis FIPS
* Doxis Business Studio
* Doxis WebCube
* Doxis MobileCube

## Usage

Container deployment workflow:

```text
Doxis Registry
      ↓
Image Synchronization
      ↓
Amazon ECR
      ↓
Amazon EKS Worker Nodes
      ↓
Doxis Pods
```

Kubernetes worker nodes pull container images directly from ECR during:

* Initial deployment
* Pod creation
* Node replacement
* Application upgrades
* Scheduled restarts

## Recommended Configuration

### Repository Structure

A separate ECR repository should be maintained for each Doxis component:

```text
doxis-csb
doxis-admin
doxis-storage
doxis-agent
doxis-fulltext
doxis-fips
doxis-businessstudio
doxis-webcube
doxis-mobilecube
```

### Image Retention

Recommended lifecycle policy:

* Retain latest 5–10 versions
* Automatically remove older images
* Preserve tagged release versions

### Authentication

EKS worker nodes should access ECR using IAM roles attached to the worker node instances.

No static credentials should be stored inside Kubernetes.

## Pros

* Native AWS integration
* High availability
* Private image storage
* Simplified authentication through IAM
* Eliminates dependency on external registries during runtime
* Reduces deployment risk caused by third-party registry outages
* Supports image vulnerability scanning

## Cons

* Additional image synchronization process required
* Slight increase in storage costs
* Requires management of repository lifecycle policies

## Assessment

Strongly recommended.

ECR should be considered a mandatory component of the AWS reference architecture whenever Doxis container images are not directly accessible from the target AWS environment.

For this lab environment, ECR provides a secure and operationally simple method of distributing Doxis container images to the EKS worker nodes.

---

# Windows EC2 Instance

## Purpose

Dedicated host for:

* Doxis Imaging Service

## Calculator Sizing

* t3a.large
* Windows Server
* 100 GB storage
* Spot pricing model 

### Pros

* Cost-efficient
* Adequate for rendering workloads
* Dedicated server prevents rendering load from impacting Kubernetes

### Cons

* Spot interruptions can affect document rendering availability
* Limited headroom for heavy rendering workloads

### Assessment

Appropriately sized for a lab.

---

# Amazon RDS PostgreSQL

## Purpose

Hosts:

* CSB databases
* Admin database
* FIPS database

Multiple databases and schemas are hosted on the same PostgreSQL instance.

## Calculator Sizing

* db.t4g.medium
* Single AZ
* 100 GB gp3 storage 

### Pros

* Appropriate entry-level managed database
* Sufficient for lab workload
* Low cost
* Easily scalable

### Cons

* Single-AZ deployment
* No automatic failover
* Not production-grade availability

### Assessment

Appropriately sized.

---

# Amazon S3

## Purpose

Primary content storage backend for:

* Doxis Storage

## Calculator Sizing

* 100 GB S3 Standard Storage 

### Pros

* Native storage mechanism for Kubernetes deployment
* Extremely durable
* Virtually unlimited scalability
* Low cost

### Cons

* None for this workload

### Assessment

Appropriately sized.

---

# Amazon OpenSearch Service

## Purpose

Used by:

* Doxis Fulltext

## Calculator Sizing

* 1 × t3.small.search
* 10 GB gp3 storage 

### Pros

* Lowest-cost managed search platform
* Supports functional testing
* Supports indexing and search validation

### Cons

* Very small memory footprint
* Limited indexing capacity
* Not suitable for performance testing
* Not representative of production sizing

### Assessment

Acceptable for lab use.

---

# Application Load Balancer

## Purpose

Provides ingress routing for:

* WebCube
* MobileCube
* Business Studio
* CSB REST services

## Calculator Sizing

* 1 Application Load Balancer 

### Pros

* Supports path and host-based routing
* Integrates directly with EKS
* Centralized TLS termination

### Cons

* Cost can appear high relative to small workloads

### Assessment

Appropriately sized.

---

# Route53

## Purpose

Provides DNS for:

```text
*.doxis.example.com
```

## Calculator Sizing

* 1 Hosted Zone 

### Pros

* Native AWS integration
* Low administrative overhead

### Cons

* None for this workload

### Assessment

Appropriately sized.

---

# AWS Certificate Manager (ACM)

## Purpose

Provides TLS certificate for:

```text
*.doxis.example.com
```

Used by:

* Application Load Balancer

## Calculator Sizing

* 0 exportable wildcard certificate
* 0 exportable FQDN certificates 

### Pros

* Single certificate covers all Doxis hostnames
* Automatic renewal
* Native ALB integration
* No certificate management burden

### Cons

* None for this workload

### Assessment

Correct architecture.

---

# AWS Secrets Manager

## Purpose

Stores:

* PostgreSQL credentials
* Tenant database credentials
* FIPS credentials
* OpenSearch credentials
* Future S3 credentials (if required)
* Internal service credentials
* Future LDAP/SMTP credentials

## Calculator Sizing

* 10 secrets
* 12 API calls per day 

### Pros

* Centralized secret management
* Supports secret rotation
* Eliminates plaintext credentials in Helm values
* Aligns with AWS security best practices

### Cons

* Additional monthly cost
* Requires application integration or external secret synchronization

### Assessment

Strongly recommended.

This should be considered part of the reference architecture rather than an optional enhancement.

---

# Amazon CloudWatch

## Purpose

Monitoring and logging for:

* EKS
* EC2
* RDS
* OpenSearch

## Calculator Sizing

* 50 metrics
* 10 GB logs
* 1 dashboard 

### Pros

* Sufficient visibility for troubleshooting
* Centralized monitoring

### Cons

* Log retention costs can grow over time

### Assessment

Appropriately sized.

---

# Amazon VPC

## Purpose

Provides networking for:

* EKS
* EC2
* RDS
* OpenSearch
* ALB

## Calculator Sizing

* Single public IPv4
* Basic lab networking assumptions 

### Pros

* Simple
* Low cost

### Cons

* Not designed for production-level resiliency

### Assessment

Appropriately sized.

---

# Services Explicitly Not Included

The following AWS services are intentionally excluded because they are not required by the supplied Doxis charts or deployment model:

| Service                  | Reason                                     |
| ------------------------ | ------------------------------------------ |
| Amazon EFS               | No shared filesystem requirement           |
| ElastiCache / Redis      | No Redis dependency                        |
| SQS                      | No queueing requirement                    |
| SNS                      | No notification requirement                |
| AWS Backup               | Not required for lab                       |
| NAT Gateway              | Cost outweighs benefit for lab environment |
| In-cluster Elasticsearch | Replaced by AWS OpenSearch                 |
| In-cluster OpenSearch    | Replaced by AWS OpenSearch                 |

---

# Final Assessment

This architecture is complete for a Doxis 14.x lab environment.

The only remaining architectural decision is whether Spot instances are acceptable for:

* Linux worker nodes
* Windows Imaging Service

If demonstration stability is important, migrate those workloads to On-Demand instances. Otherwise, the environment is appropriately sized, uses managed AWS services where beneficial.
