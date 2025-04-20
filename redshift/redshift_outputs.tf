output "namespace_id" {
  description = "ID del namespace de Redshift Serverless"
  value       = aws_redshiftserverless_namespace.main.id
}

output "workgroup_id" {
  description = "ID del workgroup de Redshift Serverless"
  value       = aws_redshiftserverless_workgroup.main.id
}

output "redshift_endpoint" {
  description = "Endpoint de Redshift Serverless"
  value       = aws_redshiftserverless_workgroup.main.endpoint
} 