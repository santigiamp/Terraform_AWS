#!/bin/bash

set -e

echo "🚀 Iniciando configuración del backend remoto para Terraform..."

# 1. Comprobamos si la tabla DynamoDB ya existe
echo "🔍 Verificando si la tabla de locks existe en AWS..."
LOCK_TABLE="terraform-locks"
REGION="sa-east-1"
TABLE_EXISTS=$(aws dynamodb describe-table --table-name "$LOCK_TABLE" --region "$REGION" 2>/dev/null || echo "not_found")

if [[ "$TABLE_EXISTS" == "not_found" ]]; then
  echo "⚠️  La tabla DynamoDB '$LOCK_TABLE' no existe. Creándola temporalmente sin backend..."

  echo "🧪 Comentando el backend para aplicar la tabla..."
  sed -i.bak '/^terraform {/,/^}/s/^/\/\//' backend.tf

  terraform init
  terraform apply -auto-approve -target=aws_dynamodb_table.terraform_locks

  echo "✅ Tabla creada. Restaurando backend..."
  mv backend.tf.bak backend.tf
else
  echo "✅ La tabla '$LOCK_TABLE' ya existe."
fi

# 2. Inicializar el backend remoto
echo "🔄 Inicializando backend remoto en S3..."
terraform init

echo "🎉 Backend remoto inicializado correctamente."
