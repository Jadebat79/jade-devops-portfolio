# 11. CI/CD Pipeline (Build, Deploy, CodePipeline)

> This section describes how CI/CD pipelines are designed and triggered using CodePipeline, CodeBuild, and CodeDeploy — for both frontend and backend microservices.

---

## 🧱 Components

| Component | Purpose |
|----------|---------|
| **CodeStar Connection** | VCS integration with Bitbucket |
| **CodePipeline** | Automates build → deploy flow |
| **CodeBuild** | Compiles app and builds Docker image |
| **CodeDeploy** | Deploys container to ECS (Fargate) |
| **buildspec.yml** | Declares build steps and artifacts |

---

## 🔁 Pipeline Structure

```text
Source (Bitbucket) → Build (CodeBuild) → Deploy (CodeDeploy)
```

- Source stage uses CodeStar Connection for webhook
- Build stage uses `buildspec.yml` to:
  - Install deps
  - Build Docker image
  - Push to ECR
  - Export task definition + AppSpec

---

## 🧪 buildspec.yml Example (Node/NextJS)

```yaml
version: 0.2
phases:
  build:
    commands:
      - npm install
      - npm run build
      - docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
      - docker push $IMAGE_REPO_NAME:$IMAGE_TAG
artifacts:
  files:
    - imagedefinitions.json
```

---

## 🚀 Blue/Green Deploy with CodeDeploy

- AppSpec file in build artifacts defines:
  - Task Definition to deploy
  - Container port and target group
- CodeDeploy handles:
  - Pre-traffic hooks (optional)
  - Traffic shifting
  - Health check validation

---

## 🧠 Deployment Triggers

- Push to main/production branch
- Manual approval step (optional)
- Notifications sent via SNS to Slack

---

## ✅ Summary

This CI/CD setup provides:

- Consistent delivery for all ECS services
- Unified deployment interface (CodePipeline)
- Build artifact traceability
- Fully automated blue/green traffic shifting

> Back to [index.md](./index.md)
