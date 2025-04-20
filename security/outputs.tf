output "redshift_kms_key_arn" {
  description = "ARN de la clave KMS para Redshift"
  value       = aws_kms_key.redshift.arn
}

output "logs_kms_key_arn" {
  description = "ARN de la clave KMS para logs"
  value       = aws_kms_key.logs.arn
}

output "redshift_admin_secret_arn" {
  description = "ARN del secret para el admin de Redshift"
  value       = aws_secretsmanager_secret.redshift_admin.arn
}

output "redshift_admin_secret_version" {
  description = "Latest version of the Redshift admin credentials"
  value       = aws_secretsmanager_secret_version.redshift_admin.version_id
}

output "glue_security_group_id" {
  description = "ID del grupo de seguridad para Glue"
  value       = aws_security_group.glue.id
} 