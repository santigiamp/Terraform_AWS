variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
}

variable "subnet_id" {
  description = "ID de la subred para las conexiones de Glue"
  type        = string
}

variable "security_group_id" {
  description = "ID del grupo de seguridad para las conexiones de Glue"
  type        = string
}

variable "redshift_connection_string" {
  description = "Cadena de conexión para Redshift"
  type        = string
}

variable "database_name" {
  description = "Nombre de la base de datos de Glue"
  type        = string
}

variable "staging_bucket" {
  description = "Nombre del bucket de staging"
  type        = string
} 