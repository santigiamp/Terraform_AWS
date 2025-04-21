resource "aws_s3_bucket" "main" {
  # configuración del bucket
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "staging" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "retention-policy"
    status = "Enabled"

    filter {
      prefix = "staging/"
    }

    expiration {
      days = 30  # Retener datos por 30 días
    }

    noncurrent_version_expiration {
      noncurrent_days = 7  # Retener versiones anteriores por 7 días
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7  # Limpiar multipart uploads incompletos después de 7 días
    }
  }
}

resource "aws_s3_bucket_policy" "glue_access" {
  bucket = aws_s3_bucket.main.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "s3_size" {
  alarm_name          = "staging-bucket-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "BucketSizeBytes"
  namespace          = "AWS/S3"
  period             = "86400"  # 24 horas
  statistic          = "Average"
  threshold          = "10737418240"  # 10 GB
  alarm_description  = "Alarma cuando el tamaño del bucket de staging excede 10 GB"
  
  dimensions = {
    BucketName = aws_s3_bucket.main.bucket
    StorageType = "StandardStorage"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "s3_objects" {
  alarm_name          = "staging-bucket-objects"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "NumberOfObjects"
  namespace          = "AWS/S3"
  period             = "86400"  # 24 horas
  statistic          = "Average"
  threshold          = "100000"  # 100,000 objetos
  alarm_description  = "Alarma cuando el número de objetos en el bucket de staging excede 100,000"
  
  dimensions = {
    BucketName = aws_s3_bucket.main.bucket
    StorageType = "AllStorageTypes"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

resource "aws_sns_topic" "alerts" {
  name = "staging-alerts"
  kms_master_key_id = var.kms_key_arn

  tags = var.tags
}

resource "aws_sfn_state_machine" "etl_orchestration" {
  name     = "etl-orchestration"
  role_arn = aws_iam_role.step_functions.arn

  definition = jsonencode({
    Comment = "ETL Orchestration for multiple databases"
    StartAt = "StartETL"
    TimeoutSeconds = 172800  # 48 horas máximo
    States = {
      StartETL = {
        Type = "Pass"
        Next = "CheckBucketStatus"
      }
      CheckBucketStatus = {
        Type = "Task"
        Resource = "arn:aws:states:::aws-sdk:s3:headBucket"
        Parameters = {
          Bucket = aws_s3_bucket.main.bucket
        }
        Next = "ExtractDB1"
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next = "NotifyFailure"
          }
        ]
        Retry = [
          {
            ErrorEquals = ["States.TaskFailed"],
            IntervalSeconds = 30,
            MaxAttempts = 3,
            BackoffRate = 2.0
          }
        ]
      }
      ExtractDB1 = {
        Type = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = var.glue_job_name
          Arguments = {
            "--database" = "db1"
            "--table" = "table1"
            "--output_path" = "s3://${aws_s3_bucket.main.bucket}/staging/db1/table1/dt=$${$.execution.startTime}"
          }
        }
        Next = "ValidateDB1"
        Retry = [
          {
            ErrorEquals = ["States.TaskFailed"],
            IntervalSeconds = 60,
            MaxAttempts = 3,
            BackoffRate = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next = "NotifyFailure"
          }
        ]
      }
      ValidateDB1 = {
        Type = "Task"
        Resource = "arn:aws:states:::glue:startCrawler.sync"
        Parameters = {
          Name = var.glue_crawler_name
        }
        Next = "ExtractDB2"
        Retry = [
          {
            ErrorEquals = ["States.TaskFailed"],
            IntervalSeconds = 60,
            MaxAttempts = 3,
            BackoffRate = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next = "NotifyFailure"
          }
        ]
      }
      ExtractDB2 = {
        Type = "Task"
        Resource = "arn:aws:states:::glue:startJobRun.sync"
        Parameters = {
          JobName = var.glue_job_name
          Arguments = {
            "--database" = "db2"
            "--table" = "table2"
            "--output_path" = "s3://${aws_s3_bucket.main.bucket}/staging/db2/table2/dt=$${$.execution.startTime}"
          }
        }
        Next = "ValidateDB2"
        Retry = [
          {
            ErrorEquals = ["States.TaskFailed"],
            IntervalSeconds = 60,
            MaxAttempts = 3,
            BackoffRate = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next = "NotifyFailure"
          }
        ]
      }
      ValidateDB2 = {
        Type = "Task"
        Resource = "arn:aws:states:::glue:startCrawler.sync"
        Parameters = {
          Name = var.glue_crawler_name
        }
        Next = "Success"
        Retry = [
          {
            ErrorEquals = ["States.TaskFailed"],
            IntervalSeconds = 60,
            MaxAttempts = 3,
            BackoffRate = 2.0
          }
        ]
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            Next = "NotifyFailure"
          }
        ]
      }
      Success = {
        Type = "Pass"
        End = true
      }
      NotifyFailure = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = aws_sns_topic.alerts.arn
          Message = "ETL process failed"
          Subject = "ETL Failure Notification"
        }
        End = true
      }
    }
  })

  tags = var.tags
}

resource "aws_iam_role" "step_functions" {
  name = "step-functions-etl-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "step_functions" {
  name = "step-functions-etl-policy"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:BatchStopJobRun",
          "glue:StartCrawler",
          "glue:GetCrawler"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.main.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.main.bucket}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [aws_sns_topic.alerts.arn]
      }
    ]
  })
}


