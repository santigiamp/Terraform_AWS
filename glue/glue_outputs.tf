output "catalog_database_name" {
  description = "Name of the Glue catalog database"
  value       = aws_glue_catalog_database.main.name
}

output "job_name" {
  description = "Name of the Glue job"
  value       = aws_glue_job.main.name
}

output "crawler_name" {
  description = "Name of the Glue crawler"
  value       = aws_glue_crawler.main.name
}

output "glue_role_arn" {
  description = "ARN of the IAM role used by Glue"
  value       = aws_iam_role.glue_role.arn
} 