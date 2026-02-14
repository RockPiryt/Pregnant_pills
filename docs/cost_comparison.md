## Cost Comparison – Compute & Control Plane (eu-west-1)

> Estimated for a small workload running 24/7 (~730 hours/month).  
> Costs include compute and control plane only (no storage, data transfer, NAT Gateway, or monitoring costs).

| Variant | What You Pay For | Estimated Monthly Cost (eu-west-1) |
|----------|------------------|------------------------------------|
| **EC2 + k3s (Spot)** | EC2 Spot instance, no control plane fee | Usually the cheapest option, but subject to interruption |
| **EC2 + k3s (On-Demand)** | EC2 On-Demand instance | t3.small ~ **$0.023/h → ~$16–17/month** |
| **EKS + Managed Nodes** | EKS control plane + EC2 worker nodes | EKS control plane ~ **$0.10/h → ~$73/month** + EC2 |

---

## Database Strategy Comparison

| Database Variant | Advantages | Disadvantages | Recommended Use Case |
|------------------|------------|---------------|----------------------|
| **PostgreSQL in-cluster (Deployment / StatefulSet)** | Lowest initial cost, full control | You manage HA, backups, upgrades, recovery | Development, testing, learning environments |
| **Amazon RDS (PostgreSQL)** | Managed backups, Multi-AZ support, operational simplicity | Instance + storage costs | Production-like environment without operational overhead |
| **Aurora Serverless v2 (PostgreSQL-compatible)** | Autoscaling, pay-per-use model, can scale down significantly | May become expensive under constant high load | Fargate + variable traffic workloads |

---

## Architectural Implications

- **Stateless workloads** (e.g., Flask application pods) are ideal for:
  - Fargate
  - Horizontal scaling
  - Auto-recovery scenarios

- **Stateful workloads** (e.g., PostgreSQL) should be:
  - Externalized from Kubernetes in production
  - Managed via RDS or Aurora
  - Designed with backup and disaster recovery in mind

This separation ensures:

- Clear distinction between compute and data layers
- Reduced operational risk
- Improved scalability
- Better cost predictability

