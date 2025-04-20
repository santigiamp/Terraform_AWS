# This file lists resources and their depends_on attributes.
# It was automatically generated.

# main.tf
module.networking: depends_on = []
module.security: depends_on = [module.networking]
module.redshift: depends_on = [module.networking, module.security]
module.glue: depends_on = [module.redshift, module.staging]
module.staging: depends_on = [module.staging, module.glue]
module.monitoring: depends_on = [module.redshift, module.networking]

# glue/glue_main.tf
resource.aws_iam_role.glue_role: depends_on = []
resource.aws_iam_role_policy_attachment.glue_service: depends_on = [resource.aws_iam_role.glue_role]
resource.aws_iam_role_policy.glue_s3_access: depends_on = [resource.aws_iam_role.glue_role]
resource.aws_glue_catalog_database.main: depends_on = []
resource.aws_glue_connection.redshift: depends_on = []
data.aws_secretsmanager_secret_version.db1_credentials: depends_on = []
data.aws_secretsmanager_secret_version.db2_credentials: depends_on = []
resource.aws_glue_connection.db1: depends_on = [data.aws_secretsmanager_secret_version.db1_credentials]
resource.aws_glue_connection.db2: depends_on = [data.aws_secretsmanager_secret_version.db2_credentials]
resource.aws_glue_crawler.main: depends_on = [resource.aws_iam_role.glue_role, resource.aws_glue_catalog_database.main]
resource.aws_glue_job.main: depends_on = [resource.aws_iam_role.glue_role, resource.aws_glue_connection.db1, resource.aws_glue_connection.db2, resource.aws_glue_connection.redshift]
data.aws_subnet.selected: depends_on = []

# monitoring/monitoring_main.tf
resource.aws_cloudwatch_log_group.vpc_flow_logs: depends_on = []
resource.aws_cloudwatch_log_group.glue_logs: depends_on = []
resource.aws_cloudwatch_metric_alarm.redshift_cpu: depends_on = [resource.aws_sns_topic.alerts]
resource.aws_cloudwatch_metric_alarm.redshift_storage: depends_on = [resource.aws_sns_topic.alerts]
resource.aws_sns_topic.alerts: depends_on = []
resource.aws_cloudwatch_dashboard.main: depends_on = []

# networking/networking_main.tf
resource.aws_vpc.vpc: depends_on = []
resource.aws_subnet.main: depends_on = [resource.aws_vpc.vpc]
resource.aws_security_group.redshift: depends_on = [resource.aws_vpc.vpc]
resource.aws_flow_log.vpc_flow_log: depends_on = [resource.aws_iam_role.vpc_flow_log_role, resource.aws_cloudwatch_log_group.flow_log_group, resource.aws_vpc.vpc]
resource.aws_cloudwatch_log_group.flow_log_group: depends_on = []
resource.aws_iam_role.vpc_flow_log_role: depends_on = []
resource.aws_iam_role_policy.vpc_flow_log_policy: depends_on = [resource.aws_iam_role.vpc_flow_log_role]
resource.aws_route_table.main: depends_on = [resource.aws_vpc.vpc, resource.aws_vpn_gateway.main]
resource.aws_route_table_association.main: depends_on = [resource.aws_subnet.main, resource.aws_route_table.main]
resource.aws_vpn_gateway.main: depends_on = [resource.aws_vpc.vpc]
resource.aws_customer_gateway.main: depends_on = []
resource.aws_vpn_connection.main: depends_on = [resource.aws_vpn_gateway.main, resource.aws_customer_gateway.main]
resource.aws_vpn_connection_route.db1: depends_on = [resource.aws_vpn_connection.main]
resource.aws_vpn_connection_route.db2: depends_on = [resource.aws_vpn_connection.main]

# redshift/redshift_main.tf
data.aws_secretsmanager_secret_version.admin_credentials: depends_on = []
resource.aws_redshiftserverless_namespace.main: depends_on = []
resource.aws_redshiftserverless_workgroup.main: depends_on = [resource.aws_redshiftserverless_namespace.main]
resource.aws_redshiftserverless_snapshot.main: depends_on = [resource.aws_redshiftserverless_namespace.main]

# security/security_main.tf
resource.aws_kms_key.redshift: depends_on = []
resource.aws_kms_alias.redshift: depends_on = [resource.aws_kms_key.redshift]
resource.aws_kms_key.logs: depends_on = []
resource.aws_kms_alias.logs: depends_on = [resource.aws_kms_key.logs]
resource.random_password.redshift_password: depends_on = []
resource.aws_secretsmanager_secret.redshift_admin: depends_on = [resource.aws_kms_key.redshift]
resource.aws_secretsmanager_secret_version.redshift_admin: depends_on = [resource.aws_secretsmanager_secret.redshift_admin, resource.random_password.redshift_password]
resource.aws_security_group.glue: depends_on = []
resource.aws_secretsmanager_secret.db1_credentials: depends_on = []
resource.aws_secretsmanager_secret.db2_credentials: depends_on = []
resource.aws_secretsmanager_secret_version.db1_credentials: depends_on = [resource.aws_secretsmanager_secret.db1_credentials]
resource.aws_secretsmanager_secret_version.db2_credentials: depends_on = [resource.aws_secretsmanager_secret.db2_credentials]

# staging/staging_main.tf
resource.aws_s3_bucket.main: depends_on = [resource.random_string.bucket_suffix]
resource.random_string.bucket_suffix: depends_on = []
resource.aws_s3_bucket_versioning.main: depends_on = [resource.aws_s3_bucket.main]
resource.aws_s3_bucket_server_side_encryption_configuration.main: depends_on = [resource.aws_s3_bucket.main]
resource.aws_s3_bucket_lifecycle_configuration.staging: depends_on = [resource.aws_s3_bucket.main]
resource.aws_s3_bucket_policy.glue_access: depends_on = [resource.aws_s3_bucket.main]
resource.aws_cloudwatch_metric_alarm.s3_size: depends_on = [resource.aws_sns_topic.alerts]
resource.aws_cloudwatch_metric_alarm.s3_objects: depends_on = [resource.aws_sns_topic.alerts]
resource.aws_sns_topic.alerts: depends_on = []
resource.aws_sfn_state_machine.etl_orchestration: depends_on = [resource.aws_iam_role.step_functions]
resource.aws_iam_role.step_functions: depends_on = []
resource.aws_iam_role_policy.step_functions: depends_on = [resource.aws_iam_role.step_functions]
