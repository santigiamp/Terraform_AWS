variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
  default = {
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "customer_gateway_ip" {
  description = "IP address of the customer gateway"
  type        = string
  default = "1.2.3.4"
}

# Database credentials
variable "db1_username" {
  description = "Username for database 1"
  type        = string
  sensitive   = true
}

variable "db1_password" {
  description = "Password for database 1"
  type        = string
  sensitive   = true
}

variable "db1_host" {
  description = "Host for database 1"
  type        = string
}

variable "db2_username" {
  description = "Username for database 2"
  type        = string
  sensitive   = true
}

variable "db2_password" {
  description = "Password for database 2"
  type        = string
  sensitive   = true
}

variable "db2_host" {
  description = "Host for database 2"
  type        = string
} 

variable "glue_job_name" {
  default = "etl_job"
}

variable "glue_crawler_name" {
  default = "crawler-db1"
}

variable "staging_bucket_name" {
  default = "mvp-staging-bucket"
}