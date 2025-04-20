variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
}

variable "redshift_admin_username" {
  description = "Admin username for Redshift"
  type        = string
  default     = "admin"
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource"
  type        = number
  default     = 7
}

variable "vpc_id" {
  description = "ID de la VPC donde se crearán los grupos de seguridad"
  type        = string
} 