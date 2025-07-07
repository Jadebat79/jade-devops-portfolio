# 02. VPC & Subnet Topology

> This section describes how networking is structured for staging and production environments. It includes subnet design, NAT gateway routing, public/private IP planning, and security-first architecture enforcement using Terraform.

## 🧱 VPC Overview

- **VPC CIDR Block**: `var.vpc_cidr_block` (e.g., `10.0.0.0/16`)
- **DNS Support**: Enabled for internal hostname resolution
- **Region**: Dynamic per environment (e.g., `us-east-1`, `eu-west-2`)
- **Deployed via Terraform** with `aws_vpc` and `aws_internet_gateway`

## 🌍 Subnet Structure

| Subnet Type       | CIDR Block (Example) | AZ  | Purpose                    |
| ----------------- | -------------------- | --- | -------------------------- |
| Public Subnet AZ1 | 10.0.0.0/20          | AZ1 | NAT gateway, ALB, ingress  |
| Public Subnet AZ2 | 10.0.16.0/20         | AZ2 | HA NAT fallback, ALB       |
| Private App AZ1   | 10.0.32.0/20         | AZ1 | ECS/EKS tasks, RDS, Lambda |
| Private App AZ2   | 10.0.48.0/20         | AZ2 | Redundant deployment zone  |

Each subnet is created with `aws_subnet`, using dynamic AZ resolution.

All subnet definitions are dynamically generated via:

```hcl
availability_zone = data.aws_availability_zones.available_zones.names[0]
```

## 🔁 Routing Configuration

### Public Route Table

- Connects public subnets to **Internet Gateway**
- Hosts:
  - Application Load Balancers (ALB)
  - NAT Gateway
  - CodeBuild if public

### Private Route Table

- Routes all `0.0.0.0/0` through **NAT Gateway**
- Used by:
  - ECS tasks
  - Lambdas
  - RDS
  - Private services

## 📦 NAT Gateway & EIP

| Resource      | Description                             |
| ------------- | --------------------------------------- |
| NAT Gateway   | Single-AZ per environment (HA optional) |
| Elastic IP    | Allocated for NAT outbound traffic      |
| Public Subnet | Required to host NAT gateway            |

Provisioned using:

```hcl
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_az1.id
}
```

- Enables private subnet resources to access the internet securely
- One NAT per AZ or shared in single-AZ (based on budget/HA design)

## 🔐 Route Table Associations

Each subnet is associated to its route table:

- `aws_route_table_association` for public subnets → public route table
- `aws_route_table_association` for private subnets → NAT-backed private route table

This isolates internal service traffic while keeping ALB & ingress endpoints externally reachable.

## 🔐 Security Group Design

| Security Group           | Used By               | Access Rule                        |
| ------------------------ | --------------------- | ---------------------------------- |
| `service_sg`             | ECS containers        | Ingress from ALB SG only           |
| `load_balancer_sg`       | ALB HTTP (80)         | Public HTTP                        |
| `load_balancer_https_sg` | ALB HTTPS (443)       | Public HTTPS                       |
| `rds_sg`                 | RDS Instance          | Ingress only via tunneling/bastion |
| `frontend_service_sg`    | Frontend containers   | Ingress from frontend LB SG        |
| `krakend_gateway_sg`     | API Gateway (KrakenD) | Ingress from frontend apps         |

### 🧪 Sample Outputs

```bash
# List ALB subnets (public)
aws ec2 describe-subnets --filters "Name=tag:Name,Values=*public*"

# Validate NAT routes
aws ec2 describe-route-tables --query 'RouteTables[*].Routes[*].NatGatewayId'
```

## 🧰 Terraform Resource Highlights

### Internet Gateway

```hcl
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
}
```

### Elastic IP for NAT

```hcl
resource "aws_eip" "nat_eip" {
  vpc = true
}
```

### Private Route Table

```hcl
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}
```

## 📥 Sample AWS CLI Verifications

```bash
# List subnets by tag
aws ec2 describe-subnets --filters "Name=tag:Name,Values=*public*"

# List NAT gateways
aws ec2 describe-nat-gateways

# Confirm route table NAT config
aws ec2 describe-route-tables --query 'RouteTables[*].Routes[*].NatGatewayId'
```

## 🌐 DNS & SSL Considerations

- Route53 zone hosts domain mappings:
  - `api.example.com` → KrakenD or backend ALB
  - `app.example.com` → Frontend ALB
- TLS termination at ALB using ACM certificates (DNS validated)

## 🧠 Frontend & KrakenD Architecture Notes

- KrakenD used as microservice **API Gateway** layer for backend service
- Frontend has its **own ALB**, SSL cert, and Route53 record
- Each ALB is mapped via Route53 and exposed via HTTPS (via ACM)
- KrakenD and Frontend run on separate ECS services and security groups
- Backend microservices not exposed directly to frontend — only via KrakenD

## ✅ Summary

This VPC and subnet design supports:

- Clean separation of public and private compute
- Secure routing via NAT with no direct public access to services
- High-availability architecture with AZ balance
- Scalable, production-grade infrastructure provisioning via Terraform

> Proceed to [03-infrastructure-deployment.md](./03-infrastructure-deployment.md) to define ALBs, ECS services, task definitions, and traffic routing via CodeDeploy.
