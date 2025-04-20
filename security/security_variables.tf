variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Number of days to wait before deleting a KMS key"
  type        = number
  default     = 7
}

variable "redshift_admin_username" {
  description = "Username for Redshift admin"
  type        = string
  default     = "admin"
} 