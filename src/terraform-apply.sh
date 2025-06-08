#!/bin/bash
# Purpose: Run Terraform plan.
# --------------------------------------

while read var; do
    [ -z "${!var}" ] && { echo "$var is empty or not set."; exit 1; }
done << EOF
TARGET_TERRAFORM_MODULE_PATH
EOF

cd $TARGET_TERRAFORM_MODULE_PATH
terraform init
terraform apply --auto-approve
cd - > /dev/null