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

variable "db1_username" {
  type = string
}

variable "db1_password" {
  type = string
}

variable "db1_host" {
  type = string
}

variable "db2_username" {
  type = string
}

variable "db2_password" {
  type = string
}

variable "db2_host" {
  type = string
}
