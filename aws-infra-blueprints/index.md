# AWS DevOps Infrastructure Deployment Guide

> This repository documents the real-world, production-grade infrastructure deployment strategies used in AWS across frontend, backend, and multi-tenant microservice applications using Terraform, ECS, ALB, RDS, and CodePipeline.

---

## 📁 Documentation Structure

| Section                          | File                                                                     |
| -------------------------------- | ------------------------------------------------------------------------ |
| 🔑 Prerequisites & Setup         | [01-prerequisites.md](./01-prerequisites.md)                             |
| 🌍 VPC & Subnet Design           | [02-vpc-subnet-topology.md](./02-vpc-subnet-topology.md)                 |
| 🛠 Infrastructure Deployment      | [03-infrastructure-deployment.md](./03-infrastructure-deployment.md)     |
| 🗄 Database Setup & Security      | [04-database-setup.md](./04-database-setup.md)                           |
| 📊 Observability & Alerting      | [05-observability-and-alerting.md](./05-observability-and-alerting.md)   |
| ⚖ Auto-Scaling                   | [06-auto-scaling.md](./06-auto-scaling.md)                               |
| 🔔 Notifications & Alerts        | [07-notification-and-alerts.md](./07-notification-and-alerts.md)         |
| 🛡 Disaster Recovery              | [08-disaster-recovery.md](./08-disaster-recovery.md)                     |
| ✅ Deployment Checklists         | [09-deployment-checklists.md](./09-deployment-checklists.md)             |
| 🌐 API Gateway Routing (KrakenD) | [10-api-gateway-krakend-routing.md](./10-api-gateway-krakend-routing.md) |
| 🚀 CI/CD Pipeline                | [11-ci-cd-pipeline.md](./11-ci-cd-pipeline.md)                           |

---

## 🧠 Purpose

This guide was created to:

- Capture production patterns deployed using Terraform
- Show real CI/CD flows using AWS native tooling
- Document decisions and designs used across real workloads
- Serve as a reference for reuse, learning, and team onboarding

---

## 🚀 What This Covers

- ECS Fargate services with CodeDeploy blue/green deployment
- Infrastructure as code using Terraform Cloud
- Secure VPC subnet architecture with NAT and DNS
- Private RDS database provisioning and access via tunnel
- Slack-integrated observability and real-time alerts
- Production-grade auto-scaling, rollback, and DR

---

## 🔗 Related Portfolio Projects

This documentation supports projects found in:

- [jade-devops-portfolio](https://github.com/Jadebat79/jade-devops-portfolio)
- [observability-monitoring-stack](https://github.com/Jadebat79/observability-monitoring-stack)
- [airbyte-prod-deployment](https://github.com/Jadebat79/airbyte-prod-deployment)
- [openproject-deployments](https://github.com/Jadebat79/openproject-deployments)

---

## ✍🏾 Author

**Juliet “Jade” Adjei**  
DevOps Engineer | Platform Builder | System Integrator  
📧 [jaynaj79@gmail.com](mailto:jaynaj79@gmail.com)  
🔗 [LinkedIn](https://linkedin.com/in/juliet-adjei-559048b3)

---

_“I don’t deploy to demo. I deploy for uptime.”_
