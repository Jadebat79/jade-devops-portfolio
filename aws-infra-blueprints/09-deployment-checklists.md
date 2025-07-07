# 09. Deployment Checklists (Validation, Rollback, Readiness)

> This section provides a structured set of checklists and validation routines to follow before, during, and after deployments. It also defines rollback procedures in case of failure.

---

## ✅ Pre-Deployment Checklist

| Item | Action |
|------|--------|
| 🔒 Secrets Verified | All env variables present in Terraform or CodeBuild |
| 🔁 ECS Task Def | Valid and matches intended container version |
| 🧪 Database | Migration tested in staging and backed up |
| 🧱 Infra Changes | Terraform plan reviewed and approved |
| 🔔 Slack Notification | Team notified of deployment window |
| 💾 Manual Snapshot | Created for RDS + S3 (if applicable) |

---

## 🚀 Deployment Flow (CodePipeline)

1. **Source Pull** via CodeStar Connection (GitHub or Bitbucket)
2. **Build** Phase via CodeBuild:
   - Uses `buildspec.yml`
   - Artifacts output to S3
3. **Deploy** Phase via CodeDeploy:
   - ECS Blue/Green deployment
   - Health checks via target groups
4. **Post-Deploy Lambda** (optional):
   - Triggers post-processing, notifications, or sync

---

## 🔍 Post-Deployment Validation

| Layer        | Check |
|--------------|-------|
| ECS Service  | Task is healthy, no restart loop |
| ALB Target Group | All targets show "healthy" |
| Logs         | No new errors in last 10 minutes |
| RDS          | Application can read/write data |
| ALB Listener | HTTPS reachable (443), Route53 resolves |
| Metrics      | No CloudWatch alarms triggered |
| Slack Alerts | Notifications received in `#deployments` |

---

## 🔁 Rollback Procedure (CodeDeploy)

1. Open AWS Console → CodeDeploy
2. Revert to previous **deployment revision**
3. ALB routes back to **blue** target group
4. ECS tasks auto-rollback to prior task def
5. Validate rollback using health checks and logs

---

## 🔁 Rollback Procedure (Terraform)

For infrastructure-level issues:

1. Review last applied `plan` from Terraform Cloud
2. Re-apply previous version or rollback via `terraform apply` (manual)
3. If critical, destroy and redeploy staging environment

---

## 🧠 Incident Triage Playbook

| Scenario | Action |
|----------|--------|
| 🚫 Deploy failed in build stage | Check buildspec logs in CodeBuild |
| 🟡 Deploy failed in health check | Investigate ECS logs + target group |
| 🔴 Post-deploy error | Trigger rollback and open incident |
| 🧩 Missing config/secret | Update TF var and re-trigger build |

---

## 📝 Tips for Stability

- Always tag ECS task definitions with Git SHA + timestamp
- Run migrations **before** ALB switches traffic
- Use `depends_on` in Terraform for sequencing
- Write `post_deploy_check.sh` script to automate tests

---

## ✅ Summary

This deployment validation and rollback playbook ensures:

- Every deploy is predictable, observable, and reversible
- Teams follow a shared process for success and recovery
- Customers never see broken experiences from rollouts

> Proceed to [index.md](./index.md) for an overview and link to the complete DevOps deployment suite.
