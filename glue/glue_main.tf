resource "aws_iam_role" "glue_role" {
  name = "GlueRedshiftRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "glue-s3-access"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.staging_bucket}",
          "arn:aws:s3:::${var.staging_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_glue_catalog_database" "main" {
  name = var.database_name
  
  tags = merge(var.tags, {
    Name = var.database_name
  })
}

resource "aws_glue_connection" "redshift" {
  name = "redshift-connection"
  
  connection_properties = {
    JDBC_CONNECTION_URL = var.redshift_connection_string
    JDBC_ENFORCE_SSL   = "true"
  }

  physical_connection_requirements {
    availability_zone      = data.aws_subnet.selected.availability_zone
    security_group_id_list = [var.security_group_id]
    subnet_id             = var.subnet_id
  }

  tags = merge(var.tags, {
    Name = "redshift-connection"
  })
}

data "aws_secretsmanager_secret_version" "db1_credentials" {
  secret_id = "db1-credentials"
}

data "aws_secretsmanager_secret_version" "db2_credentials" {
  secret_id = "db2-credentials"
}

locals {
  db1_credentials = jsondecode(data.aws_secretsmanager_secret_version.db1_credentials.secret_string)
  db2_credentials = jsondecode(data.aws_secretsmanager_secret_version.db2_credentials.secret_string)
}

resource "aws_glue_connection" "db1" {
  name = "db1-connection"
  connection_type = "JDBC"
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgresql://${local.db1_credentials.host}:5432/db1"
    USERNAME           = local.db1_credentials.username
    PASSWORD           = local.db1_credentials.password
  }
  physical_connection_requirements {
    availability_zone      = data.aws_subnet.selected.availability_zone
    security_group_id_list = [var.security_group_id]
    subnet_id             = var.subnet_id
  }

  tags = merge(var.tags, {
    Name = "db1-connection"
  })
}

resource "aws_glue_connection" "db2" {
  name = "db2-connection"
  connection_type = "JDBC"
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgresql://${local.db2_credentials.host}:5432/db2"
    USERNAME           = local.db2_credentials.username
    PASSWORD           = local.db2_credentials.password
  }
  physical_connection_requirements {
    availability_zone      = data.aws_subnet.selected.availability_zone
    security_group_id_list = [var.security_group_id]
    subnet_id             = var.subnet_id
  }

  tags = merge(var.tags, {
    Name = "db2-connection"
  })
}

resource "aws_glue_crawler" "main" {
  name          = "redshift-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.main.name

  s3_target {
    path = "s3://${var.staging_bucket}/staging"
  }

  tags = merge(var.tags, {
    Name = "redshift-crawler"
  })
}

resource "aws_glue_job" "main" {
  name     = "redshift-etl"
  role_arn = aws_iam_role.glue_role.arn
  glue_version = "3.0"
  worker_type  = "G.1X"
  number_of_workers = 2
  timeout     = 2880  # 48 horas máximo
  max_retries = 3     # Reintentos en caso de fallo

  command {
    script_location = "s3://${var.staging_bucket}/scripts/etl.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language" = "python"
    "--continuous-log-logGroup"          = "/aws/glue/jobs"
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = "true"
    "--output_format"                    = "parquet"
    "--output_path"                      = "s3://${var.staging_bucket}/staging"
    "--enable-job-insights"              = "true"
    "--job-bookmark-option"              = "job-bookmark-enable"
    "--TempDir"                          = "s3://${var.staging_bucket}/temporary/"
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://${var.staging_bucket}/spark-logs/"
  }

  execution_property {
    max_concurrent_runs = 2
  }

  connections = [
    aws_glue_connection.db1.name,
    aws_glue_connection.db2.name,
    aws_glue_connection.redshift.name
  ]

  tags = merge(var.tags, {
    Name = "redshift-etl"
  })
}

data "aws_subnet" "selected" {
  id = var.subnet_id
} 