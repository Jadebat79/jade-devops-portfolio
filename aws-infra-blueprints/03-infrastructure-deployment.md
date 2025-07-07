# 03. Infrastructure Deployment (ECS, ALB, Fargate, CodeDeploy)

> This section documents the deployment architecture used to provision and manage backend and frontend applications using ECS (Fargate), Application Load Balancers, and AWS CodeDeploy with a blue-green deployment strategy.

---

## 🚀 Overview

This architecture supports:

- Containerized microservices on **ECS Fargate**
- **Blue/Green deployments** using CodeDeploy
- Load balancing via two **Application Load Balancers (ALBs)**
- Internal-only backend services routed through **KrakenD**
- Secure HTTPS frontend routing with ACM & Route53

---

## 🧱 Core Components

| Component            | Description                                               |
| -------------------- | --------------------------------------------------------- |
| **ECS Cluster**      | Fargate-based, multi-AZ cluster                           |
| **Task Definitions** | JSON-defined container specs, env vars, resource settings |
| **ALBs**             | Two ALBs: one for KrakenD (backend), one for frontend     |
| **CodeDeploy**       | Handles zero-downtime deployments with blue/green flow    |
| **Target Groups**    | Point to ECS containers running on dynamic IPs            |
| **Listeners**        | Handle port forwarding and path routing                   |
| **Services**         | ECS services with deployment strategy and scaling config  |

---

## 📦 Task Definitions

- Defined via `aws_ecs_task_definition`
- Configured with:
  - Container name, port, CPU/mem
  - Secrets via environment variables
  - CloudWatch log group integration
  - Health check endpoints (e.g., `/docs`)

Example:

```json
"portMappings": [
  {
    "containerPort": 8000,
    "hostPort": 8000
  }
]
```

---

## 🌐 Load Balancer Architecture

This infrastructure uses **only two Application Load Balancers (ALBs)**:

| ALB              | Purpose                                                                     |
| ---------------- | --------------------------------------------------------------------------- |
| **Backend ALB**  | Exposes **KrakenD API Gateway**, which proxies to all backend microservices |
| **Frontend ALB** | Exposes the frontend (e.g., React/Next.js app) securely via HTTPS           |

All backend ECS services (e.g., users, auth, payments, etc.) are **not publicly exposed**. Instead:

- They are registered as **internal services** within the cluster
- KrakenD forwards requests to them based on routing rules
- Each service is registered in **KrakenD config** with its internal ECS service DNS or IP
- This ensures:
  - Cost-efficiency (no per-service ALB)
  - Decoupling between public traffic and internal microservice logic
  - Simplified DNS + cert management

---

### 🔁 KrakenD Flow Example

```
Internet ➝ ALB (KrakenD) ➝ KrakenD ➝ /auth ➝ Auth Service
                              ⤷ /users ➝ Users Service
                              ⤷ /billing ➝ Billing Service
```

Each backend ECS service:

- Has its own ECS task definition and service
- Registers internal-only target groups
- Connects to KrakenD via the service discovery layer (or static IP for Fargate)

---

### 🔐 Security Isolation

- KrakenD service is the **only backend-facing endpoint**
- Backend ECS services have **no external ALB**, only **KrakenD** as a client
- Security groups restrict ingress to backend ECS containers from:
  - KrakenD security group
  - VPC internal CIDRs

---

## 💚 Blue/Green Deployment (CodeDeploy)

- Each ECS service is deployed using CodeDeploy with:
  - `aws_codedeploy_app`
  - `aws_codedeploy_deployment_group`
- Strategy:
  - Deploy to `green` target group
  - Route traffic using ALB listener rules
  - Validate health checks
  - Terminate `blue` target group

```hcl
deployment_style {
  deployment_option = "WITH_TRAFFIC_CONTROL"
  deployment_type   = "BLUE_GREEN"
}
```

---

## ⚙️ ECS Service Settings

- **Launch Type**: Fargate
- **Desired Count**: Usually `1`–`3`
- **Network Mode**: `awsvpc` (for IP-based routing)
- **Security Groups**: App-specific + ALB attached
- **Target Group Attachment**: Dynamically updated by CodeDeploy

---

## 📥 Health Checks

Each target group configures:

- Path (e.g., `/docs`, `/health`)
- Timeout (3s)
- Interval (300s)
- Matcher: `200-399`
- Minimum healthy targets before deploy is considered successful

---

## 🔐 Ingress Security

- ALB security groups allow inbound `80` and `443`
- ECS services allow only ingress from associated ALBs
- No public IPs for ECS containers

---

## 🗂️ Terraform Modules Used

| Module          | Purpose                               |
| --------------- | ------------------------------------- |
| `alb.tf`        | Application Load Balancer + Listeners |
| `ecs.tf`        | ECS service and cluster definitions   |
| `task-def.tf`   | Task container settings               |
| `codedeploy.tf` | Deployment config + group             |
| `route53.tf`    | DNS record management                 |
| `cert.tf`       | SSL cert request + validation (ACM)   |

---

## ✅ Summary

This deployment pattern ensures:

- Centralized ingress via two ALBs only (KrakenD + frontend)
- No-downtime upgrades using CodeDeploy
- Secure routing via HTTPS + ALB
- Internal-only ECS services (private subnet)
- Simple rollback in case of deployment failure

> Proceed to [04-database-setup.md](./04-database-setup.md) to see how the database layer is provisioned and securely accessed via tunneling.
