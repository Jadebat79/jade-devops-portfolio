# Prometheus + Grafana + Alertmanager Configuration Notes

This Helm values file configures persistent storage for all components of our monitoring stack.

### 📊 Grafana

- **Persistence Enabled**: Prevents loss of dashboards, data sources, and user preferences during pod restarts.
- **Ingress Disabled**: Exposed through a separately managed ingress resource (`grafana-ingress.tf`).
- **Admin Password**: Injected securely via Terraform or Helm secrets.

### 🔎 Prometheus

- **50Gi PVC**: Sized for multiple days of metrics retention depending on scrape interval and target count.
- **StorageClassName**: Configured dynamically to match Hetzner's CSI storage class.

### 🚨 Alertmanager

- **Persistence Enabled**: Ensures silence configs and alert history survive restarts.
- **10Gi PVC**: Sufficient for small to medium-scale alert workloads.

---

## 🚀 Why This Matters

In earlier infra states, all metrics and dashboards were ephemeral.  
This setup introduces:

- Stateful monitoring and alerting
- No loss of data across upgrades or restarts
- A clear separation of config (Terraform) and runtime tuning (Helm)

This config was deployed into a Hetzner K8s cluster via Terraform-backed Helm deployments. Each component is declaratively managed, versioned, and fully reproducible.
