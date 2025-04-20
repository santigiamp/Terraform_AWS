output "staging_bucket_name" {
  description = "Name of the staging S3 bucket"
  value       = aws_s3_bucket.staging.bucket
}

output "staging_bucket_arn" {
  description = "ARN of the staging S3 bucket"
  value       = aws_s3_bucket.staging.arn
}

output "step_functions_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.etl_orchestration.arn
} 