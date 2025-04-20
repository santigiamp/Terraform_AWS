# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.vpc_id}/flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id       = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "vpc-flow-logs"
  })
}

resource "aws_cloudwatch_log_group" "glue_logs" {
  name              = "/aws/glue/jobs"
  retention_in_days = var.log_retention_days
  kms_key_id       = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "glue-jobs-logs"
  })
}

# CloudWatch Metric Alarms
resource "aws_cloudwatch_metric_alarm" "redshift_cpu" {
  alarm_name          = "redshift-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/RedshiftServerless"
  period             = "300"
  statistic          = "Average"
  threshold          = var.cpu_threshold_percent
  alarm_description  = "This metric monitors Redshift CPU utilization"
  
  dimensions = {
    WorkgroupID = var.redshift_workgroup_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = merge(var.tags, {
    Name = "redshift-cpu-alarm"
  })
}

resource "aws_cloudwatch_metric_alarm" "redshift_storage" {
  alarm_name          = "redshift-storage-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "StorageUsage"
  namespace          = "AWS/RedshiftServerless"
  period             = "300"
  statistic          = "Average"
  threshold          = 80
  alarm_description  = "This metric monitors Redshift storage usage"
  
  dimensions = {
    WorkgroupID = var.redshift_workgroup_id
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = merge(var.tags, {
    Name = "redshift-storage-alarm"
  })
}

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "monitoring-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = merge(var.tags, {
    Name = "monitoring-alerts"
  })
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "ServerlessInfrastructure"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RedshiftServerless", "CPUUtilization", "WorkgroupID", var.redshift_workgroup_id]
          ]
          period = 300
          stat   = "Average"
          region = "sa-east-1"
          title  = "Redshift CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RedshiftServerless", "StorageUsage", "WorkgroupID", var.redshift_workgroup_id]
          ]
          period = 300
          stat   = "Average"
          region = "sa-east-1"
          title  = "Redshift Storage Usage"
        }
      }
    ]
  })
} 