variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
}

variable "redshift_workgroup_id" {
  description = "ID of the Redshift Serverless workgroup"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "cpu_threshold_percent" {
  description = "CPU utilization threshold for Redshift alarm"
  type        = number
  default     = 80
}

variable "kms_key_arn" {
  description = "ARN of KMS key for CloudWatch logs encryption"
  type        = string
} 