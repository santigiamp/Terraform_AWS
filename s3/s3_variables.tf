variable "tags" {
  description = "Tags comunes para todos los recursos"
  type        = map(string)
}

variable "kms_key_arn" {
  description = "ARN de la clave KMS para encriptación del bucket"
  type        = string
} 