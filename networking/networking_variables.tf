variable "customer_gateway_ip" {
  description = "IP address of the customer gateway (on-premise)"
  type        = string
}

variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for resources"
  type        = string
  default     = "sa-east-1a"
}

variable "glue_security_group_id" {
  description = "ID of the Glue security group"
  type        = string
} 