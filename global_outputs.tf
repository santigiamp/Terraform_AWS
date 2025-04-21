output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = module.networking.subnet_id
}

output "redshift_endpoint" {
  description = "Endpoint of the Redshift cluster"
  value       = module.redshift.redshift_endpoint
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.staging.bucket_name
}

output "glue_job_name" {
  description = "Name of the Glue job"
  value       = module.glue.glue_job_name
}

output "glue_crawler_name" {
  description = "Name of the Glue crawler"
  value       = module.glue.glue_crawler_name
}

output "redshift_workgroup_id" {
  description = "ID of the Redshift workgroup"
  value       = module.redshift.workgroup_id
}

output "logs_kms_key_arn" {
  description = "ARN of the KMS key for logs"
  value       = module.security.logs_kms_key_arn
}

output "redshift_kms_key_arn" {
  description = "ARN of the KMS key for Redshift"
  value       = module.security.redshift_kms_key_arn
}

output "redshift_admin_secret_arn" {
  description = "ARN of the Redshift admin secret"
  value       = module.security.redshift_admin_secret_arn
} 