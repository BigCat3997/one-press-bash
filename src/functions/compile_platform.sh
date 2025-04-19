#!/bin/bash
# Purpose: Compile application source code for different platforms.
# --------------------------------------
set -e
#============================================
# Declare required script's paths as dependencies
SCRIPTS_WORK_DIR=${SCRIPTS_WORK_DIR:=.}
GLOBAL_ENV_VAR_MANAGER_SCRIPT_PATH="${SCRIPTS_WORK_DIR}/src/functions/global_env_var_manager.sh"
source ${GLOBAL_ENV_VAR_MANAGER_SCRIPT_PATH}
#============================================

activate_required_env_vars() {
    APP_SOURCE_DIR="${APP_SOURCE_DIR:-${FLOW_BUILD_APP_DIR}/app_source}"
    TARGET_SUB_DIR="${TARGET_SUB_DIR:-}"
    TARGET_BUILD_APP="${TARGET_BUILD_APP:-}"
    TARGET_BUILD_OUTPUT="${TARGET_BUILD_OUTPUT:-}"
    TARGET_PLATFORM="${TARGET_PLATFORM:-}"
    GOAL_COMMAND="${GOAL_COMMAND:-}"
    IS_USE_PRIVATE_LIBS="${IS_USE_PRIVATE_LIBS:-false}"
    NUGET_CONFIG_PATH="${NUGET_CONFIG_PATH:-}"
    SETTINGS_XML_PATH="${SETTINGS_XML_PATH:-}"
    ENV_BUILD_RESOURCE_DIR="${ENV_BUILD_RESOURCE_DIR:-}"
}

maven_compile() {
    local maven_build_work_dir_path="$1"
    local maven_build_output_path="$2"
    local maven_goals="$3"
    local is_use_private_libs="$4"
    local settings_xml_path="$5"

    if [[ "$is_use_private_libs" == "true" ]]; then
        local m2_home="$HOME/.m2"
        if [[ ! -d "$m2_home" ]]; then
            mkdir -p "$m2_home"
            echo "Directory $m2_home created."
        fi

        local dest_settings_xml_path="$m2_home/settings.xml"
        echo "Copying $settings_xml_path to $dest_settings_xml_path"
        cp "$settings_xml_path" "$dest_settings_xml_path"
        cat "$dest_settings_xml_path"
    fi

    maven_goals="${maven_goals:-./mvnw clean package}"
    echo "Running Maven goals: $maven_goals"
    (cd "$maven_build_work_dir_path" && eval "$maven_goals")
}

dotnet_compile() {
    local dotnet_build_work_dir_path="$1"
    local dotnet_build_output_path="$2"
    local dotnet_goals="$3"
    local is_use_private_libs="$4"
    local nuget_config_path="$5"

    if [[ "$is_use_private_libs" == "true" ]]; then
        echo "> Fetching libs from private repository."
        local nuget_home="$HOME/.nuget/NuGet"
        if [[ ! -d "$nuget_home" ]]; then
            mkdir -p "$nuget_home"
            echo "Directory $nuget_home created."
        fi

        local dest_nuget_config_path="$nuget_home/NuGet.Config"
        echo "Copying $nuget_config_path to $dest_nuget_config_path"
        cp "$nuget_config_path" "$dest_nuget_config_path"
        cat "$dest_nuget_config_path"
    fi

    dotnet_goals="${dotnet_goals:-dotnet publish -o $dotnet_build_output_path}"
    echo "Running .NET goals: $dotnet_goals"
    (cd "$dotnet_build_work_dir_path" && eval "$dotnet_goals")
}

npm_compile() {
    local npm_build_work_dir_path="$1"
    local npm_build_output_path="$2"
    local env_build_resource_dir="$3"
    local npm_install_goal="$4"
    local npm_build_goal="$5"

    echo "Copying resources from $env_build_resource_dir to $npm_build_work_dir_path"
    cp -r "$env_build_resource_dir/" "$npm_build_work_dir_path"
    tree "$npm_build_work_dir_path"

    npm_install_goal="${npm_install_goal:-npm install}"
    echo "Running NPM install: $npm_install_goal"
    (cd "$npm_build_work_dir_path" && eval "$npm_install_goal")

    npm_build_goal="${npm_build_goal:-npm run build}"
    echo "Running NPM build: $npm_build_goal"
    (cd "$npm_build_work_dir_path" && eval "$npm_build_goal")
}

compile() {
    local build_work_dir="${APP_SOURCE_DIR}"
    if [[ -n "$TARGET_SUB_DIR" ]]; then
        build_work_dir="${build_work_dir}/${TARGET_SUB_DIR}"
    fi
    if [[ -n "$TARGET_BUILD_APP" ]]; then
        build_work_dir="${build_work_dir}/${TARGET_BUILD_APP}"
    fi

    local build_output_dir="${APP_SOURCE_DIR}"
    if [[ -n "$TARGET_SUB_DIR" ]]; then
        build_output_dir="${build_output_dir}/${TARGET_SUB_DIR}"
    fi
    build_output_dir="${build_output_dir}/${TARGET_BUILD_OUTPUT}"

    echo "Build work directory: $build_work_dir"
    echo "Build output directory: $build_output_dir"
    write_env_vars "export FLOW_TARGET_BUILD_APP_DIR=${build_work_dir}" "export FLOW_TARGET_BUILD_OUTPUT_DIR=${build_output_dir}"

    case "${TARGET_PLATFORM^^}" in
        "DOTNET")
            dotnet_compile \
                "$build_work_dir" \
                "$build_output_dir" \
                "$GOAL_COMMAND" \
                "$IS_USE_PRIVATE_LIBS" \
                "$NUGET_CONFIG_PATH"
            ;;
        "MAVEN")
            maven_compile \
                "$build_work_dir" \
                "$build_output_dir" \
                "$GOAL_COMMAND" \
                "$IS_USE_PRIVATE_LIBS" \
                "$SETTINGS_XML_PATH"
            ;;
        "NPM")
            npm_compile \
                "$build_work_dir" \
                "$build_output_dir" \
                "$ENV_BUILD_RESOURCE_DIR" \
                "$GOAL_COMMAND"
            ;;
        *)
            echo "Unsupported platform: $TARGET_PLATFORM"
            ;;
    esac
}

main() {
    activate_global_env_vars
    activate_required_env_vars
    compile
}

main "$@"