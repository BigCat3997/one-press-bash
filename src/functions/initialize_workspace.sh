#!/bin/bash
# Purpose: Initialize workspace for stage.
# --------------------------------------

GLOBAL_ENV_VAR_DIR="${GLOBAL_ENV_VAR_DIR:-$(pwd)}"
GLOBAL_ENV_VAR_FILE="${GLOBAL_ENV_VAR_FILE:-.env}"
STAGE_NAME="${STAGE_NAME:-}"
APP_SOURCE="${APP_SOURCE:-app_source}"
BOOTSTRAP_BASE_DIR="${BOOTSTRAP_BASE_DIR:-$(pwd)}"
BOOTSTRAP_SECTION="${BOOTSTRAP_SECTION:-bootstrap_section}"
BUILD_BASE_DIR="${BUILD_BASE_DIR:-$(pwd)}"
BUILD_SECTION="${BUILD_SECTION:-build_section}"
BUILD_APP="${BUILD_APP:-build_app}"
BUILD_DOCKER="${BUILD_DOCKER:-build_docker}"
TARGET_BUILD_APP="${TARGET_BUILD_APP:-}"
TARGET_BUILD_OUTPUT="${TARGET_BUILD_OUTPUT:-}"
UNIT_TEST_BASE_DIR="${UNIT_TEST_BASE_DIR:-$(pwd)}"
UNIT_TEST_SECTION="${UNIT_TEST_SECTION:-unit_test_section}"
TARGET_UNIT_TEST_APP="${TARGET_UNIT_TEST_APP:-}"
TARGET_UNIT_TEST_OUTPUT="${TARGET_UNIT_TEST_OUTPUT:-}"
DEPLOYMENT_BASE_DIR="${DEPLOYMENT_BASE_DIR:-$(pwd)}"
DEPLOYMENT_SECTION="${DEPLOYMENT_SECTION:-deployment_section}"

set_up_bootstrap_stage() {
    local bootstrap_base_dir="$1"
    local bootstrap_section="$2"

    local bootstrap_section_path="${bootstrap_base_dir}/${bootstrap_section}"
    echo "> Create section directory at: ${bootstrap_section_path}."
    mkdir -p "${bootstrap_section_path}"
    tree "${bootstrap_section_path}"

    echo "> Expose paths into Azure Devops envs."
    local expose_ado_env_vars="export FLOW_BOOTSTRAP_SECTION_DIR=${bootstrap_section_path}"
    echo "${expose_ado_env_vars}" >> $GLOBAL_ENV_VAR_DIR/$GLOBAL_ENV_VAR_FILE
}

set_up_build_stage() {
    local app_source="$1"
    local build_base_dir="$2"
    local build_section="$3"
    local build_app="$4"
    local build_docker="$5"
    local target_build_app="$6"
    local target_build_output="$7"

    local build_section_path="${build_base_dir}/${build_section}"
    local build_app_path="${build_section_path}/${build_app}"
    local build_docker_path="${build_section_path}/${build_docker}"
    local target_build_output_path="${build_app_path}/${app_source}/${target_build_app}/${target_build_output}"

    trace_paths=$(
        cat <<EOF
Build section path: ${build_section_path}
Build app path: ${build_app_path}
Build docker path: ${build_docker_path}
Target build app path: ${target_build_app_path}
Target build output path: ${target_build_output_path}
EOF
    )
    echo "${trace_paths}"

    echo "> Create section directory at: ${build_section_path}."
    mkdir -p "${build_section_path}"
    mkdir -p "${build_app_path}"
    mkdir -p "${build_docker_path}"
    tree "${build_section_path}"

    echo "> Expose paths into Azure Devops envs."
    local expose_ado_env_vars="export FLOW_BUILD_SECTION_DIR=${build_section_path}"
    echo "${expose_ado_env_vars}" >> $GLOBAL_ENV_VAR_DIR/$GLOBAL_ENV_VAR_FILE
}

set_up_unit_test_stage() {
    local app_source="$1"
    local unit_test_base_dir="$2"
    local unit_test_section="$3"
    local target_unit_test_app="$4"
    local target_unit_test_output="$5"

    local unit_test_section_path="${unit_test_base_dir}/${unit_test_section}"
    local target_unit_test_app_path="${unit_test_section_path}/${app_source}/${target_unit_test_app}"
    local target_unit_test_output_path="${unit_test_section_path}/${app_source}/${target_unit_test_app}/${target_unit_test_output}"

    trace_paths=$(
        cat <<EOF
Unit test section path: ${unit_test_section_path}
Target unit test app path: ${target_unit_test_app_path}
Target unit test output path: ${target_unit_test_output_path}
EOF
    )
    echo "${trace_paths}"

    echo "> Create section directory at: ${unit_test_section_path}."
    mkdir -p "${unit_test_section_path}"
    tree "${unit_test_section_path}"

    echo "> Expose paths into Azure Devops envs."
    local expose_ado_env_vars="export FLOW_UNIT_TEST_SECTION_DIR=${unit_test_section_path}"
    echo "${expose_ado_env_vars}" >> $GLOBAL_ENV_VAR_DIR/$GLOBAL_ENV_VAR_FILE
}

set_up_deployment_stage() {
    local deployment_base_dir="$1"
    local deployment_section="$2"

    local deployment_section_path="${deployment_base_dir}/${deployment_section}"
    echo "> Create deployment section directory at: ${deployment_section_path}."
    mkdir -p "${deployment_section_path}"
    tree "${deployment_section_path}"

    echo "> Expose paths into Azure Devops envs."
    local expose_ado_env_vars="export FLOW_DEPLOYMENT_SECTION_DIR=${deployment_section_path}"
    echo "${expose_ado_env_vars}" >> $GLOBAL_ENV_VAR_DIR/$GLOBAL_ENV_VAR_FILE
}

main() {
    case "$STAGE_NAME" in
    "BOOTSTRAP")
        set_up_bootstrap_stage "$BOOTSTRAP_BASE_DIR" "$BOOTSTRAP_SECTION"
        ;;
    "BUILD")
        set_up_build_stage "$APP_SOURCE" "$BUILD_BASE_DIR" "$BUILD_SECTION" "$BUILD_APP" "$BUILD_DOCKER" "$TARGET_BUILD_APP" "$TARGET_BUILD_OUTPUT"
        ;;
    "UNIT_TEST")
        set_up_unit_test_stage "$APP_SOURCE" "$UNIT_TEST_BASE_DIR" "$UNIT_TEST_SECTION" "$TARGET_UNIT_TEST_APP" "$TARGET_UNIT_TEST_OUTPUT"
        ;;
    "DEPLOYMENT")
        set_up_deployment_stage "$DEPLOYMENT_BASE_DIR" "$DEPLOYMENT_SECTION"
        ;;
    *)
        echo "Unknown stage: $STAGE_NAME"
        exit 1
        ;;
    esac
}

main
