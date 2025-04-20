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