# 06. Auto-Scaling (ECS Fargate)

> This section documents the setup of ECS service auto-scaling based on CPU and memory thresholds using AWS Application Auto Scaling.

---

## ⚙️ Auto Scaling Strategy

Each ECS service is configured to scale independently based on:

- **CPU Utilization**
- **Memory Utilization**

Target tracking policies ensure ECS tasks scale out or in without human intervention, reacting to workload pressure in near real-time.

---

## 📦 Target Configuration

Each ECS service is registered as an auto scaling target:

```hcl
resource "aws_appautoscaling_target" "servicename_ecs_target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.servicename-aws-ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
```

---

## 🔁 Policy: Memory-Based Scaling

```hcl
resource "aws_appautoscaling_policy" "servicename_memory_policy" {
  name               = "servicename-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.servicename_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.servicename_ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.servicename_ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80
  }
}
```

---

## 🔁 Policy: CPU-Based Scaling

```hcl
resource "aws_appautoscaling_policy" "servicename_cpu_policy" {
  name               = "servicename-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.servicename_ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.servicename_ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.servicename_ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 80
  }
}
```

---

## 🧠 Configuration Details

| Parameter          | Value   |
| ------------------ | ------- |
| Min Capacity       | `1`     |
| Max Capacity       | `2`     |
| CPU Threshold      | `80%`   |
| Memory Threshold   | `80%`   |
| Scale-In Cooldown  | Default |
| Scale-Out Cooldown | Default |

These thresholds can be tuned based on performance testing results.

---

## 🧪 Testing Autoscaling

1. Deploy with only 1 task
2. Simulate load (e.g., 1000+ requests/min)
3. Monitor ECS Service for task count increase
4. Observe alarms in CloudWatch Metrics
5. Confirm scale-in after load normalizes

---

## ✅ Summary

This auto-scaling configuration allows ECS services to adapt to:

- Traffic spikes (scale-out)
- Idle periods (scale-in)
- Predictable performance tuning
- Efficient resource usage in Fargate pricing model

> Proceed to [07-notification-and-alerts.md](./07-notification-and-alerts.md) to configure Slack notifications, Chatbot alerts, and AWS CodeStar pipeline events.
