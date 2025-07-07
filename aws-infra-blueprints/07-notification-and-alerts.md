# 07. Notification and Alerts (Slack, SNS, CodeStar)

> This section documents how deployment and infrastructure alerts are routed to Slack via AWS Chatbot, SNS, and CodeStar Notifications. It ensures DevOps and developers are informed of critical events in real time.

---

## 📦 Notification Channels Used

| Channel             | Description                              |
| ------------------- | ---------------------------------------- |
| **#infra-alerts**   | System errors, failed builds, log alarms |
| **#deployments**    | Pipeline success/failure notifications   |
| **#staging-alerts** | Pre-production issues                    |

---

## 📣 Slack Integration via AWS Chatbot

We integrate Slack channels with AWS using **AWS Chatbot**.

### Setup Overview

1. Slack workspace connected via Chatbot console
2. Channel authorized in Chatbot with proper permissions
3. Slack notifications triggered via SNS or CodeStar

---

## 📨 SNS Topics

Used as the main trigger for alarms and deployment status updates.

```hcl
resource "aws_sns_topic" "notif" {
  name = "deployment-alerts-topic"
}
```

SNS is linked to:

- CloudWatch alarms
- CodeDeploy events
- CodePipeline failures

---

## 🔁 CodeStar Notifications

Set up to track pipeline status changes:

```hcl
resource "aws_codestarnotifications_notification_rule" "servicename_pipeline" {
  detail_type    = "BASIC"
  event_type_ids = [
    "codepipeline-pipeline-stage-execution-failed",
    "codepipeline-pipeline-pipeline-execution-succeeded",
    "codepipeline-pipeline-pipeline-execution-failed"
  ]
  resource = aws_codepipeline.servicename_codepipeline.arn

  target {
    type    = "AWSChatbotSlack"
    address = var.chatbot_arn
  }
}
```

---

## 🚨 Alarm Routing

### CloudWatch Alarms → SNS → Slack

```hcl
resource "aws_cloudwatch_metric_alarm" "webFE" {
  alarm_name   = "webFE-internal-errors"
  metric_name  = "ErrorCount"
  namespace    = "Mesh Frontend Internal Server Error"
  threshold    = 1
  evaluation_periods = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic    = "Sum"
  period       = 60
  alarm_actions = [aws_sns_topic.notif.arn]
}
```

---

## 🧠 Best Practices

- Separate notification channels by environment (prod vs staging)
- Limit SNS fanout to only relevant Slack channels
- Tag alarms and notifications with:
  - `Project`
  - `Environment`
  - `Service` (for filtering/searching)

---

## 🧪 Testing

- Trigger a manual pipeline failure → verify Slack alert
- Deploy faulty container → verify CloudWatch error and alert
- Manually publish to SNS → confirm alert receipt

---

## ✅ Summary

Slack + SNS + Chatbot + CodeStar combine to create a reliable alerting mesh. This ensures:

- Devs get real-time alerts about what they ship
- Infra issues are surfaced to operators immediately
- Auditing and feedback are fast and traceable

> Proceed to [08-disaster-recovery.md](./08-disaster-recovery.md) to understand failover, backups, and RTO protection.
