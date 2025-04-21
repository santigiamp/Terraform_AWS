variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
}

variable "environment" {
  description = "Nombre del ambiente (dev, prod, etc.)"
  type        = string
}

variable "glue_job_name" {
  description = "Nombre del job de Glue"
  type        = string
}

variable "glue_crawler_name" {
  description = "Nombre del crawler de Glue"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para encriptación"
  type        = string
}

variable "staging_bucket" {
  description = "Nombre del bucket de staging"
  type        = string
}