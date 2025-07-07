# OpenProject on Kubernetes (Terraform + Helm)

> Fully externalized, production-ready deployment of OpenProject using Terraform + Helm on Hetzner-hosted Kubernetes. Integrated with external PostgreSQL, S3, SMTP, and TLS-secured ingress.

---

## 🧠 Overview

This project provisions an **OpenProject project management system** on Kubernetes using a **modular Helm + Terraform pipeline**. It includes externalized configuration for:

- PostgreSQL database
- S3 object storage
- SMTP email delivery
- Admin credentials and secret key base
- TLS-secured ingress (via separate NGINX + cert-manager stack)

The deployment is designed for **enterprise resilience, clean modularity, and security**—avoiding the use of bundled/internal services and separating concerns for future scaling.

---

## 🏗️ Architecture Highlights

| Component    | Description                                                        |
| ------------ | ------------------------------------------------------------------ |
| Helm Release | `helm_release` with `values.yaml` + dynamic `set{}` overrides      |
| PostgreSQL   | External connection (host/user/password/db injected via variables) |
| S3           | Used for file uploads with secure access keys                      |
| SMTP         | Full email delivery configured using Terraform-injected variables  |
| TLS          | Managed externally via cluster-wide NGINX ingress and cert-manager |
| Secrets      | Rails secret and SMTP credentials handled via `set_sensitive`      |

---

## 📁 Project Structure

```
openproject-k8s/
├── values/
│   └── openproject-base.yaml        # Base configuration (bundled components off)
├── openproject.tf                   # Helm release config
├── ingress.tf                       # Ingress for external access
├── secrets.tf                       # Secure secrets (SMTP, Rails key, etc.)
├── variables.tf                     # Variable declarations
├── main.tf                          # Entry point
├── providers.tf                     # Helm & Kubernetes providers
```

---

## 🧩 Key Configuration Highlights

### 🔐 External PostgreSQL

PostgreSQL is configured as an external DB:

- Host, username, password, and DB name are passed in via Terraform variables.
- Credentials are kept secure using `set_sensitive` blocks in Terraform.

### ☁️ External S3 Storage

S3 is used for file uploads and attachments:

- Bucket name, region, and access credentials passed via variables.
- `directUploads` and V4 signature support enabled for compatibility.

### ✉️ SMTP Configuration

Full SMTP support with:

- Secure login credentials
- TLS auto-enablement
- Sender email and port configuration

### 🔒 Security Context & Hardening

- Non-root container execution
- Pod and container-level security settings
- Privilege escalation disabled
- Read-only root filesystem

---

## 🌐 Ingress Model

- Ingress not managed by the Helm chart
- TLS and routing managed centrally via NGINX ingress controller and cert-manager
- Hostname provided dynamically via Terraform

---

## 🧠 Lessons Learned

- OpenProject Helm charts require fine-tuning for production reliability
- Default resource settings aren’t sufficient for live usage—the app needs explicit CPU and memory allocations to perform well
- Running OpenProject without adjusting resource requests/limits can lead to **sluggish performance**—not unusable, but noticeably suboptimal

---

## 🧱 Next Improvements

- Adjust CPU and RAM requests/limits to improve performance and responsiveness
- Add backup/restore automation for PostgreSQL and file storage
- Configure Prometheus alerts on pod usage and availability
- Automate daily SMTP health-check for email delivery assurance

---

## ✍🏾 Author

**Juliet “Jade” Adjei**  
DevOps Engineer | Platform Builder | Infrastructure Integrator  
📧 [jaynaj79@gmail.com](mailto:jaynaj79@gmail.com)  
🔗 [LinkedIn](https://linkedin.com/in/juliet-adjei-559048b3)

---

## 🔗 Part of My Portfolio

This deployment is part of my broader DevOps portfolio:  
👉 [jade-devops-portfolio](https://github.com/Jadebat79/jade-devops-portfolio)

Real infrastructure. Real integration. No sandbox setups.
