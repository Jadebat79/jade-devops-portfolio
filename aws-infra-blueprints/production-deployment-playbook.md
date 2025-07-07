# AWS Production Deployment Playbook (Terraform + CI/CD)

> A comprehensive, real-world guide for deploying secure, scalable applications to AWS using Terraform, CI/CD pipelines, and best practices for production reliability, observability, and recovery.

---

## 🧱 Prerequisites

### ✅ AWS Account Setup

- **Production AWS Account Access**:

  - Ensure MFA is enabled on all admin accounts
  - Use IAM users/roles with scoped permissions
  - Access keys stored in secure secret manager (never hardcoded)

- **Terraform Administrative User**:

  - IAM user with admin privileges (least privilege enforced)
  - Secrets injected via Terraform Cloud or CI/CD vaults

- **S3 Deployment User**:
  - IAM user with bucket-specific policies (read/write only)
  - Key rotation every 90 days
  - Bucket policy + lifecycle configuration applied

---

## 💬 Slack + AWS Q Integration

- Create a **Slack App** with:
  - `chat:write`, `incoming-webhook`, `channels:read` scopes
- Set up Webhook URLs stored in secrets manager
- Integration tied to AWS Q or alerting bots
- Channels:
  - `#prod-alerts`
  - `#infra-logs`

Test alert flow by simulating `terraform apply` → resource creation → notification trigger.

---

## 🔧 CodeStar Connection Setup

> GitHub, GitHub Enterprise, Bitbucket supported

- Navigate: `AWS Console > Developer Tools > Settings > Connections`
- Create & authenticate CodeStar connection
- Verify connection shows **“Available”** in AWS
- Used for CodePipeline source stages

---

## ⚙️ Terraform Cloud Configuration

- Create Organization & Workspaces
  - `dev`, `staging`, `prod`
- Configure **remote backend execution**
- Sensitive vars:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- Env vars:
  - `TF_VAR_region`
  - `TF_VAR_environment`
  - `TF_VAR_workspace_name`
- Enable version locking and cost estimation

---

## 📁 Terraform Module Structure

| Module             | Purpose                                                    |
| ------------------ | ---------------------------------------------------------- |
| `network.tf`       | VPC, subnets, routing tables                               |
| `aws_alb.tf`       | Load balancer, listeners, target groups                    |
| `ec2.tf`           | Compute instances, autoscaling, instance roles             |
| `rds.tf`           | PostgreSQL or MySQL DB with subnet groups & encryption     |
| `ecr.tf`           | Container registry with lifecycle rules                    |
| `ecs.tf`           | ECS Cluster + service definitions                          |
| `permissions.tf`   | IAM roles, users, and scoped policies                      |
| `s3_buckets.tf`    | Logging, deployment artifacts, backups                     |
| `sns.tf`           | Alerting and notification logic                            |
| `ssm_parameter.tf` | App config and secrets management                          |
| `route53.tf`       | DNS zone, CNAME, A-records                                 |
| `lambda.tf`        | Serverless utilities and triggers                          |
| `keypair.tf`       | SSH key provisioning for EC2                               |
| `domain_apps.tf`   | Pipeline definitions (CodeBuild, CodePipeline, CodeDeploy) |
| `variables.tf`     | Input abstraction for the above modules                    |

---

## 🛠️ Server & Environment Setup

- Health checks implemented on all EC2 instances
- EC2 hardened using:
  - SSH key-only login
  - Disabled root login
  - CIS benchmarks baseline scripts
- Startup scripts provision:
  - MongoDB
  - RabbitMQ (cluster-ready, HA mode)

---

## 🚀 Deployment Process (via Terraform Cloud)

### 1. Infrastructure Provisioning

We use **Terraform Cloud** with version control integration (e.g., GitHub or Bitbucket). The flow is:

- Developer pushes to a branch connected to Terraform Cloud
- Terraform Cloud automatically:
  - Performs `terraform init`
  - Performs `terraform plan`
- A human operator then **reviews the plan and triggers `Apply`** manually via the Terraform Cloud UI
- Infra is provisioned in the following sequence:
  - VPC, subnets, and networking
  - IAM roles, security groups
  - ALBs, RDS, ECS/EKS compute
  - DNS + certificates

---

### 2. Database Configuration (via Secure Tunnel)

- DB is **not exposed publicly**
- Engineers tunnel into the RDS instance from a jump box or bastion host
- Inside the tunnel:
  - Create application-level DB users
  - Validate initial schema
  - Set user permissions & encryption policies

---

### 3. Application Deployment Pipeline (via CodePipeline)

The deployment pipeline follows this structure:

- **CodePipeline
  **[Source] → [CodeBuild] → [CodeDeploy] → [ECS/EKS]\*\*

- **Source**: Connected to VCS (GitHub/Bitbucket) via CodeStar connection
- **Build**:
  - Handled in CodeBuild using a custom `buildspec.yml`
  - Artifact is pushed to ECR or S3
- **Deploy**:
  - ECS or EKS, depending on workload type
  - Targets are validated post-deploy
- **Notification**
  - Slack notifications wired to every stage

---

## 🧪 Post-Deploy Validation

### Load Balancers

- Check **ALB configuration**:
  - Target groups have healthy services
  - Listeners point to correct ports
  - HTTPS routing is functional
- Validate logs + metrics in CloudWatch
- Confirm alerting is firing to Slack on any failures or drift

### 🔐 Security

- Review IAM role bindings and policies
- Validate TLS certificate + ACM setup
- Confirm encryption at rest & in transit
- Check for open ports via SG audit

### 📈 Performance

- Simulate load using `artillery`, `ab`, or JMeter
- Confirm ALB response times, DB IOPS, memory usage
- Trigger autoscaling policies and rollback

### 🔍 Observability

- Dashboards:
  - CPU, memory, ALB latency, ECS container health
- Logs:
  - ECS app logs
  - RDS slow query logs
- Alerts:
  - 5XX alerts
  - Scaling events
  - Dead letter queue failures

---

## 💥 Disaster Recovery

- Snapshots for RDS verified weekly
- Restore tests logged in internal DR tracker
- `terraform destroy && terraform apply` test in sandbox env
- `RTO` and `RPO` documented for each service

---

## 🛠 Maintenance & Patching

- EC2 patching cadence: **monthly**
- Container image scan: **weekly via ECR scan**
- RDS minor version upgrade window: **bi-weekly**
- Infra-as-code repo review: **every sprint**

---

## 📈 Scaling Strategy

- Auto-scaling triggers:
  - CPU > 70% for 5 min → add 1 EC2
  - Requests > 1000/min → scale ECS
- Manual override documented via Slack `/scale` command
- Cost monitoring via AWS Budgets + alert rules
- Monthly review of:
  - Cost anomalies
  - Scaling effectiveness
  - CloudWatch alarms

---

## ✅ Summary

This guide reflects a real, enterprise-level pattern for deploying secure, scalable, production-grade applications to AWS using Terraform and CI/CD automation.

No screenshots, IP, or credentials are included — this documentation focuses on _process ownership, architectural judgment, and reliability engineering_.

> “I don’t deploy to demo. I deploy for uptime.”

# AWS Production Deployment Playbook (Terraform + CI/CD)

> A comprehensive, real-world guide for deploying secure, scalable applications to AWS using Terraform, CI/CD pipelines, and best practices for production reliability, observability, and recovery.

---

## 🧱 Prerequisites

### ✅ AWS Account Setup

- **Production AWS Account Access**:

  - Ensure MFA is enabled on all admin accounts
  - Use IAM users/roles with scoped permissions
  - Access keys stored in secure secret manager (never hardcoded)

- **Terraform Administrative User**:

  - IAM user with admin privileges (least privilege enforced)
  - Secrets injected via Terraform Cloud or CI/CD vaults

- **S3 Deployment User**:
  - IAM user with bucket-specific policies (read/write only)
  - Key rotation every 90 days
  - Bucket policy + lifecycle configuration applied

---

## 💬 Slack + AWS Q Integration

- Create a **Slack App** with:
  - `chat:write`, `incoming-webhook`, `channels:read` scopes
- Set up Webhook URLs stored in secrets manager
- Integration tied to AWS Q or alerting bots
- Channels:
  - `#prod-alerts`
  - `#infra-logs`

Test alert flow by simulating `terraform apply` → resource creation → notification trigger.

---

## 🔧 CodeStar Connection Setup

> GitHub, GitHub Enterprise, Bitbucket supported

- Navigate: `AWS Console > Developer Tools > Settings > Connections`
- Create & authenticate CodeStar connection
- Verify connection shows **“Available”** in AWS
- Used for CodePipeline source stages

---

## ⚙️ Terraform Cloud Configuration

- Create Organization & Workspaces
  - `dev`, `staging`, `prod`
- Configure **remote backend execution**
- Sensitive vars:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
- Env vars:
  - `TF_VAR_region`
  - `TF_VAR_environment`
  - `TF_VAR_workspace_name`
- Enable version locking and cost estimation

---

## 📁 Terraform Module Structure

| Module             | Purpose                                                    |
| ------------------ | ---------------------------------------------------------- |
| `network.tf`       | VPC, subnets, routing tables                               |
| `aws_alb.tf`       | Load balancer, listeners, target groups                    |
| `ec2.tf`           | Compute instances, autoscaling, instance roles             |
| `rds.tf`           | PostgreSQL or MySQL DB with subnet groups & encryption     |
| `ecr.tf`           | Container registry with lifecycle rules                    |
| `ecs.tf`           | ECS Cluster + service definitions                          |
| `permissions.tf`   | IAM roles, users, and scoped policies                      |
| `s3_buckets.tf`    | Logging, deployment artifacts, backups                     |
| `sns.tf`           | Alerting and notification logic                            |
| `ssm_parameter.tf` | App config and secrets management                          |
| `route53.tf`       | DNS zone, CNAME, A-records                                 |
| `lambda.tf`        | Serverless utilities and triggers                          |
| `keypair.tf`       | SSH key provisioning for EC2                               |
| `domain_apps.tf`   | Pipeline definitions (CodeBuild, CodePipeline, CodeDeploy) |
| `variables.tf`     | Input abstraction for the above modules                    |

---

## 🛠️ Server & Environment Setup

- Health checks implemented on all EC2 instances
- EC2 hardened using:
  - SSH key-only login
  - Disabled root login
  - CIS benchmarks baseline scripts
- Startup scripts provision:
  - MongoDB
  - RabbitMQ (cluster-ready, HA mode)

---

## 🚀 Deployment Process

### 1. **Provision Infrastructure**

- `terraform init`
- `terraform plan`
- `terraform apply -auto-approve`
  - Network infra
  - Security groups
  - RDS/S3/ECS/ECR
  - DNS
  - IAM roles

### 2. **Database Config**

- Connect to DB instance securely
- Create application DB users with restricted access
- Validate connection strings
- Define backup plans + snapshot rotation

### 3. **Application Deployment**

- Push code to connected repo
- Trigger CI/CD:
  - **CodePipeline → CodeBuild → ECS → ALB**
  - Slack notifications wired to every stage
- Verify:
  - Health checks
  - Logs flowing to CloudWatch
  - Ingress reachable via HTTPS

---

## 🧪 Post-Deploy Validation

### 🔐 Security

- Review IAM role bindings and policies
- Validate TLS certificate + ACM setup
- Confirm encryption at rest & in transit
- Check for open ports via SG audit

### 📈 Performance

- Simulate load using `artillery`, `ab`, or JMeter
- Confirm ALB response times, DB IOPS, memory usage
- Trigger autoscaling policies and rollback

### 🔍 Observability

- Dashboards:
  - CPU, memory, ALB latency, ECS container health
- Logs:
  - ECS app logs
  - RDS slow query logs
- Alerts:
  - 5XX alerts
  - Scaling events
  - Dead letter queue failures

---

## 💥 Disaster Recovery

- Snapshots for RDS verified weekly
- Restore tests logged in internal DR tracker
- `terraform destroy && terraform apply` test in sandbox env
- `RTO` and `RPO` documented for each service

---

## 🛠 Maintenance & Patching

- EC2 patching cadence: **monthly**
- Container image scan: **weekly via ECR scan**
- RDS minor version upgrade window: **bi-weekly**
- Infra-as-code repo review: **every sprint**

---

## 📈 Scaling Strategy

- Auto-scaling triggers:
  - CPU > 70% for 5 min → add 1 EC2
  - Requests > 1000/min → scale ECS
- Manual override documented via Slack `/scale` command
- Cost monitoring via AWS Budgets + alert rules
- Monthly review of:
  - Cost anomalies
  - Scaling effectiveness
  - CloudWatch alarms

---

## ✅ Summary

This guide reflects a real, enterprise-level pattern for deploying secure, scalable, production-grade applications to AWS using Terraform and CI/CD automation.

No screenshots, IP, or credentials are included — this documentation focuses on _process ownership, architectural judgment, and reliability engineering_.

> “I don’t deploy to demo. I deploy for uptime.”
