module "networking" {
  source                 = "./networking"
  tags                   = var.tags
  customer_gateway_ip    = var.customer_gateway_ip
  glue_security_group_id = module.security.glue_security_group_id
}

module "security" {
  source       = "./security"
  tags         = var.tags
  vpc_id       = module.networking.vpc_id
  vpc_cidr     = "10.0.0.0/16"
  db1_username = var.db1_username
  db1_password = var.db1_password
  db1_host     = var.db1_host
  db2_username = var.db2_username
  db2_password = var.db2_password
  db2_host     = var.db2_host
}

module "redshift" {
  source = "./redshift"

  subnet_id         = module.networking.subnet_id
  security_group_id = module.networking.redshift_security_group_id
  kms_key_arn       = module.security.logs_kms_key_arn
  admin_secret_arn  = module.security.redshift_admin_secret_arn

  tags = var.tags
}

module "glue" {
  source = "./glue"

  subnet_id                  = module.networking.subnet_id
  security_group_id          = module.security.glue_security_group_id
  redshift_connection_string = "jdbc:redshift://${module.redshift.redshift_endpoint}:5439/dev"
  database_name              = "catalogo-db"
  glue_job_name              = var.glue_job_name
  glue_crawler_name          = var.glue_crawler_name
  staging_bucket             = var.staging_bucket_name
  tags                       = var.tags

  depends_on = [module.redshift]
}

module "staging" {
  source = "./staging"

  staging_bucket    = var.staging_bucket_name
  environment       = var.environment
  glue_job_name     = var.glue_job_name
  glue_crawler_name = var.glue_crawler_name
  kms_key_arn       = module.security.logs_kms_key_arn
  tags              = var.tags

  depends_on = [module.security]
}

module "monitoring" {
  source = "./monitoring"

  vpc_id                = module.networking.vpc_id
  redshift_workgroup_id = module.redshift.workgroup_id
  kms_key_arn           = module.security.logs_kms_key_arn

  tags = var.tags

  depends_on = [module.redshift, module.networking]
}