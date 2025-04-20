data "aws_secretsmanager_secret_version" "admin_credentials" {
  secret_id = var.admin_secret_arn
}

locals {
  admin_credentials = jsondecode(data.aws_secretsmanager_secret_version.admin_credentials.secret_string)
}

resource "aws_redshiftserverless_namespace" "main" {
  namespace_name      = var.namespace_name
  admin_username     = local.admin_credentials.username
  admin_user_password = local.admin_credentials.password
  db_name            = "dev"
  kms_key_id         = var.kms_key_arn

  tags = merge(var.tags, {
    Name = var.namespace_name
  })
}

resource "aws_redshiftserverless_workgroup" "main" {
  namespace_name = aws_redshiftserverless_namespace.main.id
  workgroup_name = "main-workgroup"
  base_capacity = 16
  
  config_parameter {
    parameter_key   = "enable_user_activity_logging"
    parameter_value = "true"
  }

  config_parameter {
    parameter_key   = "query_group"
    parameter_value = "default"
  }

  config_parameter {
    parameter_key   = "max_query_execution_time"
    parameter_value = "86400000"  # 24 horas en milisegundos
  }

  config_parameter {
    parameter_key   = "max_query_queue_time"
    parameter_value = "3600000"   # 1 hora en milisegundos
  }

  config_parameter {
    parameter_key   = "require_ssl"
    parameter_value = "true"
  }

  enhanced_vpc_routing = true
  publicly_accessible  = false
  security_group_ids  = [var.security_group_id]
  subnet_ids          = [var.subnet_id]

  tags = var.tags
}

resource "aws_redshiftserverless_snapshot" "main" {
  namespace_name = aws_redshiftserverless_namespace.main.namespace_name
  snapshot_name  = "${var.namespace_name}-snapshot"
  retention_period = 7
} 