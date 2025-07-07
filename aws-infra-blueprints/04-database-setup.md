# 04. Database Setup (RDS, Subnet Groups, Private Access)

> This section documents how we provision production-ready PostgreSQL instances using AWS RDS. All database infrastructure is isolated in private subnets and accessed securely via tunneling — not exposed publicly.

---

## 🧱 Database Stack Overview

| Component          | Description                                                    |
| ------------------ | -------------------------------------------------------------- |
| **RDS**            | PostgreSQL engine (version `14.10`) with multi-AZ enabled      |
| **Subnet Group**   | Two private subnets (AZ1 & AZ2) for high availability          |
| **Security Group** | Ingress allowed only via app security group or SSH tunnel      |
| **Storage**        | GP3 volumes with 200GB allocated (modifiable)                  |
| **Backup**         | 7-day retention, nightly snapshot, deletion protection enabled |

---

## ⚙️ Terraform Configuration Summary

### RDS Instance

```hcl
resource "aws_db_instance" "rds_instance" {
  engine                  = "postgres"
  instance_class          = "db.t4g.medium"
  allocated_storage       = 200
  storage_type            = "gp3"
  multi_az                = true
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  publicly_accessible     = false
  deletion_protection     = true
  backup_retention_period = 7
}
```

### 🌐 Subnet Group

RDS is deployed in two private subnets, one per AZ:

```hcl

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "mesh-suite-db-main"
  subnet_ids = [
    aws_subnet.private_app_subnet_az1.id,
    aws_subnet.private_app_subnet_az2.id
  ]
}
```

### 🔐 Security Group Design

| Rule          | Value                     |
| ------------- | ------------------------- |
| Ingress port  | `5432`                    |
| Source        | App service SG or bastion |
| Egress        | `0.0.0.0/0` (standard)    |
| Public Access | **Disabled**              |

All inbound access to the DB is restricted to internal services only. No public IP access is allowed.

### 🛡️ Private-Only Access (via Tunneling)

Production DB is accessed by engineers via SSH tunnel, not direct connection.

Connection Strategy
Jump box / bastion host in public subnet (optional)

Use aws ssm start-session for temporary access

Forward local port 5432 to DB endpoint securely

Example:

```bash
ssh -i ~/.ssh/key.pem -L 5432:rds-endpoint.internal:5432 ec2-user@bastion-host
```

### 🔐 Environment Variables for RDS

These are passed securely into ECS task definitions and CodeBuild envs:

| Variable      | Description           |
| ------------- | --------------------- |
| `DB_HOST`     | RDS endpoint hostname |
| `DB_NAME`     | Database name         |
| `DB_USER`     | App database user     |
| `DB_PASSWORD` | Stored in secrets mgr |
| `DB_PORT`     | `5432`                |

### 🔁 Backup & Restore

- Automated daily snapshots via RDS native settings
- Manual snapshot before deploy (recommended)
- PITR (Point-in-Time Recovery) enabled
- Backups retained for 7 days

### 🔄 Maintenance & Versioning

| Setting                    | Value                      |
| -------------------------- | -------------------------- |
| Maintenance Window         | `Sun:00:00-03:00`          |
| Backup Window              | `03:00-03:30`              |
| Engine Version Lock        | Enabled via ignore_changes |
| Auto Minor Version Upgrade | Disabled (manual only)     |

## ✅ Summary

This database architecture ensures:

- All traffic is internal-only
- Encrypted, multi-AZ production PostgreSQL
- Backup, failover, and maintenance hardening
- Zero public exposure, with audit-ready access control

> Proceed to [05-observability-and-alerting.md](./05-observability-and-alerting.md) to explore how logs, metrics, and alarms are configured for real-time monitoring and incident response
