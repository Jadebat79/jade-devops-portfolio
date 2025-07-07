# 08. Disaster Recovery (Multi-AZ, Backups, Termination Protection)

> This section documents the disaster recovery strategies used to protect infrastructure and data in the event of failure. It includes backup configurations, multi-AZ deployments, and recovery protocols.

---

## 🛡️ Core Strategies

| Layer        | Protection Strategy                        |
|-------------|---------------------------------------------|
| **Compute**  | ECS in Multi-AZ with ALB failover          |
| **Database** | RDS Multi-AZ, automated backups, PITR      |
| **Storage**  | S3 versioning + lifecycle management       |
| **Infra**    | Terraform state recovery, locking, history |
| **Human**    | Manual snapshot triggers before major ops  |

---

## 🌐 Multi-AZ Deployments

- **RDS**: `multi_az = true` ensures standby replica in second AZ
- **ECS**: Services run in subnets across at least 2 AZs
- **ALB**: Spread across public subnets in different AZs
- **Subnets**: Public/private pairs per AZ (at minimum)

---

## 💾 Backup Configuration

### RDS:
```hcl
backup_retention_period = 7
backup_window           = "03:00-03:30"
```

- Automated snapshots taken nightly
- Point-In-Time Recovery (PITR) enabled
- Manual snapshot created before deployments

### S3:
```hcl
versioning {
  enabled = true
}
```

- S3 buckets used for CodeBuild artifacts and backups have versioning enabled
- Lifecycle policies used to clean up old data or transition to Glacier

---

## 🔐 Deletion Protection

### RDS:
```hcl
deletion_protection = true
```

- Prevents accidental deletion of production DB instances

### Terraform:
- `lifecycle { prevent_destroy = true }` used on critical modules
- Terraform Cloud workspaces have version history and soft-deletion

---

## 📁 Snapshots & Image Backups

| Resource    | Snapshot Type     | Frequency |
|-------------|-------------------|-----------|
| RDS         | Manual + Automated | Daily     |
| ECS Task Defs | Immutable history via revisions | Always |
| ECR         | Image tags (SHA-based) | Every deploy |
| S3          | Object versioning   | On write  |

---

## 🔄 Restore & Failover

### RDS:
- Use latest snapshot to restore to new instance
- Apply parameter groups + subnet groups manually
- Validate access + integrity via staging environment before cutover

### ECS:
- Redeploy from latest task definition
- Reassociate service with target group via `CodeDeploy`

---

## ⏱️ RTO & RPO

| Metric | Value           |
|--------|------------------|
| RTO    | < 1 hour         |
| RPO    | ≤ 24 hours (nightly) |

---

## ✅ Summary

Disaster recovery in this architecture is built on:

- AZ-level redundancy
- Daily automated backups
- Manual pre-deployment snapshots
- Terraform + Git-based infra state
- Protection from accidental deletion

> Proceed to [09-deployment-checklists.md](./09-deployment-checklists.md) for post-deploy validation and rollback plans.
