# Loki Configuration Notes

This config was deployed to our Hetzner K8s cluster for full-stack observability. Key design goals were:

- Persistent log storage across restarts
- Fast querying for recent logs (hot cache)
- Low operational maintenance overhead
- Self-hosted and cost-efficient (using filesystem + boltdb-shipper)

## 💡 Why These Choices?

- `promtail.enabled = true`: Allows for agentless collection across all nodes.
- `retention_period = 100h`: Logs retained ~4 days to balance cost vs. value.
- `chunk_cache_config`: Speeds up frequent queries—critical for our dev workflows.
- `compactor`: Enabled for automated cleanup of expired logs.
- `boltdb-shipper`: Chosen for its balance of performance and simplicity on local disk.

## 🛠️ Deployment Note

Deployed via Terraform + Helm with dynamic values injected from TF vars. Storage class and PVC bindings are managed via `storageClassName` mapped from Hetzner's CSI driver.
