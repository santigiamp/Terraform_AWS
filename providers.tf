terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  profile = "vscode-dev"
  region = "sa-east-1"
  # Las credenciales se pueden proporcionar de varias formas:
  # 1. Variables de entorno: AWS_ACCESS_KEY_ID y AWS_SECRET_ACCESS_KEY
  # 2. Archivo de credenciales: ~/.aws/credentials
  # 3. Directamente aquí (no recomendado):
  # access_key = "tu_access_key"
  # secret_key = "tu_secret_key"
}
