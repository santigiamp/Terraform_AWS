# Este archivo define dependencias explícitas entre recursos para el proyecto de data warehouse serverless en AWS.
# Los módulos (networking, security, redshift, staging, glue, monitoring) se definen en main.tf.

# Recursos en el módulo glue (dependencias explícitas)
resource "aws_iam_role" "glue_role" {}

resource "aws_iam_role_policy_attachment" "glue_service" {
  depends_on = [aws_iam_role.glue_role] # Requiere el rol IAM
}

resource "aws_iam_role_policy" "glue_s3_access" {
  depends_on = [aws_iam_role.glue_role] # Requiere el rol IAM
}

resource "aws_glue_catalog_database" "main" {}

resource "aws_glue_connection" "db1" {
  depends_on = [data.aws_secretsmanager_secret_version.db1_credentials] # Requiere credenciales
}

resource "aws_glue_connection" "db2" {
  depends_on = [data.aws_secretsmanager_secret_version.db2_credentials] # Requiere credenciales
}

resource "aws_glue_crawler" "main" {
  depends_on = [aws_iam_role.glue_role, aws_glue_catalog_database.main] # Requiere rol y base de datos
}

resource "aws_glue_job" "main" {
  depends_on = [
    aws_iam_role.glue_role,
    aws_glue_connection.db1,
    aws_glue_connection.db2,
    aws_glue_connection.redshift
  ] # Requiere rol y conexiones
}

# Recursos en el módulo monitoring
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {}

resource "aws_cloudwatch_log_group" "glue_logs" {}

resource "aws_cloudwatch_metric_alarm" "redshift_cpu" {
  depends_on = [aws_sns_topic.alerts] # Requiere tema SNS
}

resource "aws_cloudwatch_metric_alarm" "redshift_storage" {
  depends_on = [aws_sns_topic.alerts] # Requiere tema SNS
}

resource "aws_sns_topic" "alerts" {}

resource "aws_cloudwatch_dashboard" "main" {}

# Recursos en el módulo networking
resource "aws_vpc" "vpc" {}

resource "aws_subnet" "main" {
  depends_on = [aws_vpc.vpc] # Requiere VPC
}

resource "aws_security_group" "redshift" {
  depends_on = [aws_vpc.vpc] # Requiere VPC
}

resource "aws_flow_log" "vpc_flow_log" {
  depends_on = [
    aws_iam_role.vpc_flow_log_role,
    aws_cloudwatch_log_group.flow_log_group,
    aws_vpc.vpc
  ] # Requiere rol, grupo de logs y VPC
}

resource "aws_cloudwatch_log_group" "flow_log_group" {}

resource "aws_iam_role" "vpc_flow_log_role" {}

resource "aws_iam_role_policy" "vpc_flow_log_policy" {
  depends_on = [aws_iam_role.vpc_flow_log_role] # Requiere rol
}

resource "aws_route_table" "main" {
  depends_on = [aws_vpc.vpc, aws_vpn_gateway.main] # Requiere VPC y VPN gateway
}

resource "aws_route_table_association" "main" {
  depends_on = [aws_subnet.main, aws_route_table.main] # Requiere subnet y tabla de rutas
}

resource "aws_vpn_gateway" "main" {
  depends_on = [aws_vpc.vpc] # Requiere VPC
}

resource "aws_customer_gateway" "main" {}

resource "aws_vpn_connection" "main" {
  depends_on = [aws_vpn_gateway.main, aws_customer_gateway.main] # Requiere gateways
}

resource "aws_vpn_connection_route" "db1" {
  depends_on = [aws_vpn_connection.main] # Requiere conexión VPN
}

resource "aws_vpn_connection_route" "db2" {
  depends_on = [aws_vpn_connection.main] # Requiere conexión VPN
}

# Recursos en el módulo redshift
data "aws_secretsmanager_secret_version" "admin_credentials" {}

resource "aws_redshiftserverless_namespace" "main" {}

resource "aws_redshiftserverless_workgroup" "main" {
  depends_on = [aws_redshiftserverless_namespace.main] # Requiere namespace
}

resource "aws_redshiftserverless_snapshot" "main" {
  depends_on = [aws_redshiftserverless_namespace.main] # Requiere namespace
}

# Recursos en el módulo security
resource "aws_kms_key" "redshift" {}

resource "aws_kms_alias" "redshift" {
  depends_on = [aws_kms_key.redshift] # Requiere clave KMS
}

resource "aws_kms_key" "logs" {}

resource "aws_kms_alias" "logs" {
  depends_on = [aws_kms_key.logs] # Requiere clave KMS
}

resource "random_password" "redshift_password" {}

resource "aws_secretsmanager_secret" "redshift_admin" {
  depends_on = [aws_kms_key.redshift] # Requiere clave KMS
}

resource "aws_secretsmanager_secret_version" "redshift_admin" {
  depends_on = [aws_secretsmanager_secret.redshift_admin, random_password.redshift_password] # Requiere secreto y contraseña
}

resource "aws_security_group" "glue" {}

resource "aws_secretsmanager_secret" "db1_credentials" {}

resource "aws_secretsmanager_secret" "db2_credentials" {}

resource "aws_secretsmanager_secret_version" "db1_credentials" {
  depends_on = [aws_secretsmanager_secret.db1_credentials] # Requiere secreto
}

resource "aws_secretsmanager_secret_version" "db2_credentials" {
  depends_on = [aws_secretsmanager_secret.db2_credentials] # Requiere secreto
}

# Recursos en el módulo staging
resource "aws_s3_bucket" "main" {
  depends_on = [random_string.bucket_suffix] # Requiere sufijo para nombre único
}

resource "random_string" "bucket_suffix" {}

resource "aws_s3_bucket_versioning" "main" {
  depends_on = [aws_s3_bucket.main] # Requiere bucket
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  depends_on = [aws_s3_bucket.main] # Requiere bucket
}

resource "aws_s3_bucket_lifecycle_configuration" "staging" {
  depends_on = [aws_s3_bucket.main] # Requiere bucket
}

resource "aws_s3_bucket_policy" "glue_access" {
  depends_on = [aws_s3_bucket.main] # Requiere bucket
}

resource "aws_cloudwatch_metric_alarm" "s3_size" {
  depends_on = [aws_sns_topic.alerts] # Requiere tema SNS
}

resource "aws_cloudwatch_metric_alarm" "s3_objects" {
  depends_on = [aws_sns_topic.alerts] # Requiere tema SNS
}

resource "aws_sfn_state_machine" "etl_orchestration" {
  depends_on = [aws_iam_role.step_functions] # Requiere rol
}

resource "aws_iam_role" "step_functions" {}

resource "aws_iam_role_policy" "step_functions" {
  depends_on = [aws_iam_role.step_functions] # Requiere rol
}