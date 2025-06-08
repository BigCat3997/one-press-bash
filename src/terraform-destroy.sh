#!/bin/bash
# Purpose: Run Terraform plan.
# --------------------------------------

while read var; do
    [ -z "${!var}" ] && { echo "$var is empty or not set."; exit 1; }
done << EOF
TARGET_TERRAFORM_MODULE_PATH
EOF

set -e
if [ -z "$LOCAL_DATA_PATH" ]; then
    echo "Do not use local data file."
else
    echo "Use local data file."
    cp -r $LOCAL_DATA_PATH/. $TARGET_TERRAFORM_MODULE_PATH

    echo "Verify files."
    tree $TARGET_TERRAFORM_MODULE_PATH
fi

cd $TARGET_TERRAFORM_MODULE_PATH
terraform init
terraform destroy --auto-approve
cd - > /dev/null