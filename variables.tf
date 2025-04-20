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

variable "db1_username" {
  description = "Usuario para la base de datos DB1"
  type        = string
  sensitive   = true
}

variable "db1_password" {
  description = "Contraseña para la base de datos DB1"
  type        = string
  sensitive   = true
}

variable "db1_host" {
  description = "Host para la base de datos DB1"
  type        = string
}

variable "db2_username" {
  description = "Usuario para la base de datos DB2"
  type        = string
  sensitive   = true
}

variable "db2_password" {
  description = "Contraseña para la base de datos DB2"
  type        = string
  sensitive   = true
}

variable "db2_host" {
  description = "Host para la base de datos DB2"
  type        = string
}

variable "customer_gateway_ip" {
  description = "IP address of the customer gateway (on-premise)"
  type        = string
  default     = "0.0.0.0"  # Este es un valor por defecto, debe ser reemplazado con la IP real
}

