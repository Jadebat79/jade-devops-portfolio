# 01. Prerequisites & Environment Setup

> This guide documents the foundational steps required before infrastructure provisioning and application deployment to AWS using Terraform Cloud, CodePipeline, and ECS. These steps enforce security, automation readiness, and production-grade hygiene.

---

## 🔐 AWS Account & IAM Setup

### 1. Admin Access for Terraform

- Create a dedicated **Terraform IAM user** (or assume-role setup for larger orgs)
- Attach policies via IAM groups (start with `AdministratorAccess`, restrict later)
- Enable **MFA** on the user’s console login
- Store secrets in Terraform Cloud or secure vault (not in `.tfvars` or `env`)

### 2. S3 Deployment User

- IAM user with:
  - `s3:PutObject`, `s3:GetObject`, `s3:ListBucket`
- Separate from Terraform user
- Used in CodeBuild + artifact storage

---

## 🏗️ Terraform Cloud Configuration

### 1. Workspace Setup

- Create an **organization** in Terraform Cloud
- Create **workspaces** for:
  - `dev`
  - `staging`
  - `production`

### 2. Version Control Integration

- Link workspace to Bitbucket repo via **VCS connection**
- Enable “Trigger runs on push” (plan runs auto-triggered)
- Manual approval step for `terraform apply`

### 3. Variables

| Type        | Examples                                                    |
| ----------- | ----------------------------------------------------------- |
| Environment | `region`, `environment`, `workspace_name`                   |
| Secrets     | `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `db_password` |
| TF Vars     | `image_tag`, `vpc_cidr_block`, `company`, `project_name`    |

---

## 🌐 Bitbucket / GitHub Integration

- Source code is managed in a Bitbucket workspace (e.g., `enterprise-core/`)
- CodeBuild + CodePipeline use **CodeStar Connections** for auth
- Git submodules enabled for shared logic across services

---

## 💬 Slack Integration (Notifications & Alerts)

### 1. Slack Bot Creation

- Created in Slack API console
- Permissions:
  - `chat:write`, `incoming-webhook`, `channels:read`
- Installed into a workspace with secure token

### 2. Webhook Usage

- Webhook URLs stored in:
  - Terraform variables
  - Lambda or CodeBuild environment variables

### 3. Channels

| Channel Name      | Purpose                         |
| ----------------- | ------------------------------- |
| `#infra-alerts`   | Errors, drift, failures         |
| `#deployments`    | Successful deploy notifications |
| `#staging-alerts` | Specific to lower environments  |

---

## 🌍 DNS & Domain Planning

- Domain managed via **Route53 public hosted zone**
- Subdomains:
  - `api.example.com` → KrakenD or backend LB
  - `app.example.com` → Frontend service LB
- Certificates issued via **ACM (DNS validation)**

---

## 📦 VPC & Subnet Strategy

| Subnet Type       | AZ Spread | Purpose                |
| ----------------- | --------- | ---------------------- |
| Public Subnet AZ1 | Yes       | NAT Gateway, ALB       |
| Public Subnet AZ2 | Yes       | NAT failover, ALB      |
| Private App AZ1   | Yes       | ECS tasks, Lambda, RDS |
| Private App AZ2   | Yes       | HA deployments         |

- All internet-facing resources (ALB, frontend LB) sit in **public subnets**
- ECS tasks, RDS, Redis, RabbitMQ live in **private subnets**

---

## 🔁 VPN or Tunneling for DB Access

- Production RDS is **not publicly accessible**
- SSH tunnel required via bastion or dedicated tunnel VM
- Tools: `sshuttle`, `Session Manager`, `DBTunnel` script

---

## ✅ Summary

Before infrastructure or applications can be provisioned:

- IAM structure must be in place
- Terraform Cloud must be VCS-connected
- Slack + Bitbucket must be wired into CodeBuild/CodePipeline
- VPC + subnet design must support secure, private workloads

> Proceed to [02-vpc-subnet-topology.md](./02-vpc-subnet-topology.md) to see the actual network design and Terraform setup.
