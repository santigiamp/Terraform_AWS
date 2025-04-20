output "redshift_workgroup_endpoint" {
  description = "Endpoint del workgroup de Redshift Serverless"
  value       = module.redshift.redshift_endpoint
}

output "glue_catalog_database" {
  description = "Name of the Glue catalog database"
  value       = module.glue.catalog_database_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = module.networking.subnet_id
}

output "step_functions_arn" {
  description = "ARN de la máquina de estados de Step Functions"
  value       = module.staging.step_functions_arn
}
