# Infraestructura Serverless AWS

Este proyecto implementa una infraestructura serverless en AWS utilizando Terraform, que incluye servicios como Amazon Redshift Serverless, AWS Glue, S3 para staging, y componentes de red necesarios.

## Arquitectura

La infraestructura está organizada en los siguientes módulos:

### 1. Networking (`./networking`)
- VPC con soporte DNS
- Subnet en sa-east-1a
- Security Groups para Glue y Redshift
- VPN Gateway y Customer Gateway
- Flow Logs para monitoreo de tráfico
- Route Tables para enrutamiento VPN

### 2. Security (`./security`)
- KMS Keys para encriptación
  - Redshift Key
  - Logs Key
- Secrets Manager para credenciales
  - Redshift admin credentials
  - DB credentials
  - DB1 credentials
  - DB2 credentials
- Security Group for Glue

### 3. Staging (`./staging`)
- Bucket S3 para datos de staging
  - Encriptación SSE-KMS
  - Versionado habilitado
  - Políticas de retención (30 días)
  - Estructura de prefijos organizada
- S3 bucket for main data

### 4. Redshift (`./redshift`)
- Namespace Serverless
- Workgroup con:
  - Capacidad base: 16 RPUs
  - Máximo: 32 RPUs
  - Auto-pausa después de 30 minutos
  - Conexión VPC
  - Encriptación KMS
- Snapshots automáticos
  - Retención: 7 días

### 5. Glue (`./glue`)
- Conexiones JDBC
  - Redshift
  - Bases de datos on-premise vía VPN
- Crawler para catalogar datos
  - Lee desde bucket de staging
  - Inferencia de esquema automática
- Job ETL
  - Formato de salida: Parquet
- Catalog Database
- IAM Role con permisos necesarios

### 6. Monitoring (`./monitoring`)
- CloudWatch Dashboard
  - Métricas de Redshift
  - Métricas de S3
- CloudWatch Alarms
  - CPU de Redshift
  - Uso de almacenamiento
  - Tamaño de bucket
  - Número de objetos
- SNS Topics para alertas
  - Notificaciones encriptadas

## Seguridad

### Encriptación
- **S3**: SSE-KMS
- **Redshift**: KMS
- **Logs**: KMS
- **Notificaciones**: KMS

### Control de Acceso
- IAM Roles con principio de mínimo privilegio
- Políticas de bucket S3 restrictivas
- Grupos de seguridad VPC
- VPN para conexiones on-premise

### Monitoreo y Auditoría
- CloudWatch Logs
- VPC Flow Logs
- Métricas y alarmas
- Notificaciones SNS

## Requisitos

- Terraform >= 1.0.0
- AWS CLI configurado
- Acceso a AWS con permisos para crear:
  - VPC y recursos de red
  - Redshift Serverless
  - AWS Glue
  - S3
  - KMS
  - Secrets Manager
  - IAM Roles y Políticas

## Configuración

### Variables

El proyecto utiliza las siguientes variables principales:

```hcl
variable "tags" {
  description = "Default tags to apply to all resources."
  type        = map(any)
  default = {
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
```

### Networking

Configuración de red:
- CIDR VPC: 10.0.0.0/16
- CIDR Subnet: 10.0.1.0/24
- Región: sa-east-1
- Availability Zone: sa-east-1a

## Uso

1. Inicializar Terraform:
```bash
terraform init
```

2. Revisar el plan de ejecución:
```bash
terraform plan
```

3. Aplicar la configuración:
```bash
terraform apply
```

## Estructura del Proyecto

```
.
├── main.tf              # Configuración principal
├── providers.tf         # Configuración de proveedores
├── variables.tf         # Variables globales
├── outputs.tf          # Outputs globales
├── terraform.tfvars    # Valores de variables
├── networking/         # Configuración de red
├── security/          # Configuración de seguridad
├── staging/               # Configuración de S3
├── redshift/         # Configuración de Redshift
├── glue/            # Configuración de Glue
└── monitoring/      # Configuración de monitoreo
```

## Flujo de Datos

1. **Extracción**:
   - Conexión VPN a bases de datos on-premise
   - Extracción por Glue Jobs
   - Almacenamiento en S3 (formato Parquet)

2. **Validación**:
   - Verificación de archivos en S3
   - Inferencia de esquema por Crawler
   - Notificaciones de estado

3. **Carga**:
   - Transformación por Glue Jobs
   - Carga en Redshift
   - Actualización de catálogo

4. **Monitoreo**:
   - Métricas de proceso
   - Alertas de anomalías
   - Logs de auditoría

## Costos Estimados

El proyecto incluye una estimación de costos mensuales basada en la configuración actual:

- Redshift Serverless: ~$XXX/mes
- S3: ~$XXX/mes
- Glue: ~$XXX/mes
- CloudWatch: ~$XXX/mes
- Otros servicios: ~$XXX/mes

Total estimado: ~$XXX/mes

*Nota: Los costos pueden variar según el uso real y las tarifas actuales de AWS.* 