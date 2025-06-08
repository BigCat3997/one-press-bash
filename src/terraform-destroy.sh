#!/bin/bash
# Purpose: Run Terraform plan.
# --------------------------------------

while read var; do
    [ -z "${!var}" ] && { echo "$var is empty or not set."; exit ; }
done << EOF
TARGET_TERRAFORM_MODULE_PATH
EOF

cd $TARGET_TERRAFORM_MODULE_PATH
terraform init
terraform destroy --auto-approve
cd - > /dev/null