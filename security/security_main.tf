resource "aws_iam_user" "infra_admin" {
  name = "infra_admin"
}

resource "aws_iam_user_policy_attachment" "infra_admin_admin_policy" {
  user       = aws_iam_user.infra_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_kms_key" "redshift" {
  description             = "KMS key for Redshift encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowInfraAdminFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_user.infra_admin.arn
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "redshift-kms-key"
  })
}

resource "aws_kms_alias" "redshift" {
  name          = "alias/redshift-key"
  target_key_id = aws_kms_key.redshift.key_id
}

resource "aws_kms_key" "logs" {
  description             = "KMS key for CloudWatch Logs encryption"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowInfraAdminFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_user.infra_admin.arn
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "logs-kms-key"
  })
}

resource "aws_kms_alias" "logs" {
  name          = "alias/logs-key"
  target_key_id = aws_kms_key.logs.key_id
}

resource "random_password" "redshift_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "redshift_admin" {
  name                    = "redshift-admin-credentials"
  kms_key_id             = aws_kms_key.redshift.arn
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name = "redshift-admin-secret"
  })
}

resource "aws_secretsmanager_secret_version" "redshift_admin" {
  secret_id = aws_secretsmanager_secret.redshift_admin.id
  secret_string = jsonencode({
    username = var.redshift_admin_username
    password = random_password.redshift_password.result
  })
}

resource "aws_security_group" "glue" {
  name        = "glue-security-group"
  description = "Security group for AWS Glue"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow inbound traffic from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow outbound traffic to VPC"
  }

  tags = merge(var.tags, {
    Name = "glue-security-group"
  })
}

resource "aws_secretsmanager_secret" "db1_credentials" {
  name        = "db1-credentials"
  description = "Credenciales para la base de datos DB1"
  tags        = var.tags
}

resource "aws_secretsmanager_secret" "db2_credentials" {
  name        = "db2-credentials"
  description = "Credenciales para la base de datos DB2"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "db1_credentials" {
  secret_id = aws_secretsmanager_secret.db1_credentials.id
  secret_string = jsonencode({
    username = var.db1_username
    password = var.db1_password
    host     = var.db1_host
  })
}

resource "aws_secretsmanager_secret_version" "db2_credentials" {
  secret_id = aws_secretsmanager_secret.db2_credentials.id
  secret_string = jsonencode({
    username = var.db2_username
    password = var.db2_password
    host     = var.db2_host
  })
}