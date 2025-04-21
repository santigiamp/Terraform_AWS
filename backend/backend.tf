terraform {
  backend "s3" {
    bucket         = "main" # <-- reemplazá este nombre
    key            = "infraestructura/estado/terraform.tfstate"
    region         = "sa-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
