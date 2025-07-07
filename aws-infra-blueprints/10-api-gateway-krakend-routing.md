# 10. API Gateway Routing (KrakenD for Microservices)

> This section documents how KrakenD is used as an API gateway layer to unify routing and access control across multiple backend ECS microservices.

---

## 🧠 Why KrakenD?

KrakenD is used to:
- Aggregate microservice endpoints into a unified API
- Enforce centralized rate limits and auth
- Isolate public traffic from internal ECS services
- Cut down on the need for per-service ALBs

---

## 🔁 Architectural Role

```text
Client (Frontend) ➝ HTTPS ALB ➝ KrakenD ➝ Internal ECS Services
```

- KrakenD runs as its own ECS service
- Frontend calls only KrakenD
- KrakenD config defines all route mappings to ECS service endpoints

---

## 🧱 Infrastructure Setup

- KrakenD ECS service deployed behind the **backend ALB**
- Task definition includes:
  - Custom KrakenD config file
  - Log driver integration
- Target group health checks on `/__health`
- Only KrakenD is publicly accessible among backend services

---

## 🛠 KrakenD Configuration Example

```json
{
  "endpoints": [
    {
      "endpoint": "/users",
      "method": "GET",
      "backend": [
        {
          "url_pattern": "/api/v1/users",
          "host": ["http://users-service.internal"]
        }
      ]
    }
  ]
}
```

- `host` maps to internal ECS service DNS
- All routes start from `/` and are exposed via `krakend-api.meshapps.io`

---

## 🔐 Security

- KrakenD is deployed in private subnets but exposed via ALB
- TLS is terminated at ALB (with ACM certificate)
- ALB forwards to KrakenD on HTTP/8000
- ECS services accept traffic only from KrakenD’s security group

---

## ✅ Summary

KrakenD provides:

- Clean, isolated API surface
- Dynamic microservice routing
- Centralized ingress control
- Cost optimization (1 ALB vs many)

> Proceed to [11-ci-cd-pipeline.md](./11-ci-cd-pipeline.md) to see how CodePipeline and CodeBuild deliver both frontend and backend updates.
