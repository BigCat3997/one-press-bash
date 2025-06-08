#!/bin/bash
# Purpose: Run Terraform plan.
# --------------------------------------

while read var; do
    [ -z "${!var}" ] && { echo "$var is empty or not set."; exit 1; }
done << EOF
TARGET_TERRAFORM_MODULE_PATH
AZURE_BACKEND_RESOURCE_GROUP
AZURE_STORAGE_ACCOUNT_NAME
AZURE_CONTAINER_NAME
AZURE_BLOB_KEY
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
ARM_CLIENT_ID
ARM_CLIENT_SECRET
EOF

cd $TARGET_TERRAFORM_MODULE_PATH
terraform init \
    -backend-config="resource_group_name=${AZURE_BACKEND_RESOURCE_GROUP}" \
    -backend-config="storage_account_name=${AZURE_STORAGE_ACCOUNT_NAME}" \
    -backend-config="container_name=${AZURE_CONTAINER_NAME}" \
    -backend-config="key=${AZURE_BLOB_KEY}"
terraform plan

cd - > /dev/null