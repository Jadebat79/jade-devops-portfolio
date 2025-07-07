# 05. Observability & Alerting (CloudWatch, Logs, Alarms)

> This section details how logs, metrics, alarms, and notifications are configured for ECS-based services using AWS CloudWatch, Metric Filters, SNS, and Slack integrations.

---

## 📦 Logging Architecture

| Component                  | Tool                                                       |
| -------------------------- | ---------------------------------------------------------- |
| **Application Logs**       | AWS CloudWatch Logs                                        |
| **Log Routing**            | ECS Task Definitions with `awslogs` driver                 |
| **Build Logs**             | CodeBuild → S3 & CloudWatch                                |
| **Deployment Logs**        | CodePipeline & CodeDeploy via Console and Cloud Watch Logs |
| **Alarms & Notifications** | CloudWatch Alarms + SNS + AWS Chatbot (Slack)              |

---

## 🧱 CloudWatch Log Groups

Each ECS service has a dedicated CloudWatch log group:

```hcl
resource "aws_cloudwatch_log_group" "servicename-log-group" {
  name              = "${var.project_name}-servicename-${var.environment}-logs"
  retention_in_days = 30
}
```

Additional log groups include:

- `webFE-log-group`
- `krakend-log-group`
- CodeBuild logs to both S3 + CloudWatch

---

## 🔍 Metric Filters for Errors

We use log pattern matching to create custom metrics (e.g., `"Error"` string match):

```hcl
resource "aws_cloudwatch_log_metric_filter" "servicename-log-group" {
  pattern        = "Error"
  log_group_name = aws_cloudwatch_log_group.servicename-log-group.name

  metric_transformation {
    name      = "ErrorCount"
    namespace = "Users and Apps Internal Server Error"
    value     = "1"
  }
}
```

---

## 🚨 CloudWatch Alarms

Custom alarms are triggered when error thresholds are breached:

```hcl
resource "aws_cloudwatch_metric_alarm" "servicename" {
  alarm_name          = "${var.project_name}-servicename-${var.environment}"
  metric_name         = "ErrorCount"
  namespace           = "Users and Apps Internal Server Error"
  threshold           = 1
  evaluation_periods  = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Sum"
  period              = 60
  alarm_actions       = [aws_sns_topic.notif.arn]
}
```

Each service has its own log group + alarm pair.

---

## 📣 SNS + Slack Notifications

We use AWS Chatbot + SNS to route alerts to Slack channels.

### Setup:

- Create SNS topic (e.g., `notif`)
- Use `aws_codestarnotifications_notification_rule` for CodePipeline events
- Use Chatbot integration for Slack channel delivery

Example:

```hcl
resource "aws_codestarnotifications_notification_rule" "frontend_pipeline" {
  resource       = aws_codepipeline.web_frontend_codepipeline.arn
  event_type_ids = ["codepipeline-pipeline-pipeline-execution-failed"]
  target {
    type    = "AWSChatbotSlack"
    address = var.chatbot_arn
  }
}
```

---

## 🧠 Alerting Strategy

| Alarm Type            | Condition                | Action                      |
| --------------------- | ------------------------ | --------------------------- |
| Internal Server Error | `ErrorCount >= 1` in 60s | Notify `#infra-alerts`      |
| ECS Memory Alarm      | `> 80%` usage            | Scale ECS, notify DevOps    |
| Pipeline Failures     | CodePipeline event types | Notify `#deployments` Slack |

---

## 🧪 Validation Checklist

- [x] All ECS task definitions include `awslogs` config
- [x] All services emit logs to CloudWatch
- [x] All metric filters tested with manual `Error` triggers
- [x] Slack channels receive SNS notifications
- [x] Alarm actions are mapped to correct topics

---

## ✅ Summary

This observability stack ensures:

- Logs are persisted and searchable
- Alerts trigger immediately on real conditions
- Notifications are routed to the right human channels
- Incident response is fast, traceable, and transparent

> Proceed to [06-auto-scaling.md](./06-auto-scaling.md) to configure ECS service scaling based on CPU and memory thresholds.
