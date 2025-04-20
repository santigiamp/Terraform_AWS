variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
}

variable "namespace_name" {
  description = "Name for the Redshift Serverless namespace"
  type        = string
  default     = "dwh"
}

variable "workgroup_name" {
  description = "Name for the Redshift Serverless workgroup"
  type        = string
  default     = "dwh-rds"
}

variable "max_capacity" {
  description = "Maximum capacity of Redshift Serverless in RPUs"
  type        = number
  default     = 64
}

variable "subnet_id" {
  description = "Subnet ID for Redshift Serverless"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID for Redshift Serverless"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "admin_secret_arn" {
  description = "ARN of the secret containing admin credentials"
  type        = string
} 