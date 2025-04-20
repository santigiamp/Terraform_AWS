variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
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