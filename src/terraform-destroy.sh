#!/bin/bash
# Purpose: Run Terraform plan.
# --------------------------------------

while read var; do
    [ -z "${!var}" ] && { echo "$var is empty or not set."; exit ; }
done << EOF
TARGET_TERRAFORM_MODULE_PATH
EOF

cd $TARGET_TERRAFORM_MODULE_PATH
terraform init \
    -backend-config="resource_group_name=${AZURE_BACKEND_RESOURCE_GROUP}" \
    -backend-config="storage_account_name=${AZURE_STORAGE_ACCOUNT_NAME}" \
    -backend-config="container_name=${AZURE_CONTAINER_NAME}" \
    -backend-config="key=${AZURE_BLOB_KEY}"
terraform destroy --auto-approve
cd - > /dev/null