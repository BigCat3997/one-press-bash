#!/bin/bash
# Purpose: Build and publish Docker images.
# --------------------------------------
set -e
#============================================
# Declare required script's paths as dependencies
SCRIPTS_WORK_DIR=${SCRIPTS_WORK_DIR:=.}
GLOBAL_ENV_VAR_MANAGER_SCRIPT_PATH="${SCRIPTS_WORK_DIR}/src/functions/global_env_var_manager.sh"
source ${GLOBAL_ENV_VAR_MANAGER_SCRIPT_PATH}
#============================================

# Fetch required environment variables
activate_required_env_vars() {
    PUBLISH_FILE_PATH="${PUBLISH_FILE_PATH:-}"
    DOCKER_RESOURCE_WORK_DIR="${DOCKER_RESOURCE_WORK_DIR:-}"
    DOCKER_TARGET_DOCKERFILE="${DOCKER_TARGET_DOCKERFILE:-}"
    TARGET_BUILD_OUTPUT_PATH="${TARGET_BUILD_OUTPUT_PATH:-$FLOW_TARGET_BUILD_OUTPUT_DIR}"
    TARGET_BUILD_DOCKER_PATH="${TARGET_BUILD_DOCKER_PATH:-$FLOW_BUILD_DOCKER_DIR}"
    DOCKER_DOCKERFILE_NAME="${DOCKER_DOCKERFILE_NAME:-Dockerfile}"
    DOCKER_BUILD_PATH="${DOCKER_BUILD_PATH:-.}"
    DOCKERS_ARGS_JSON="${DOCKERS_ARGS_JSON:-[]}"
    DOCKER_IS_PRIVATE_REGISTRY="${DOCKER_IS_PRIVATE_REGISTRY:-false}"
    DOCKER_SERVER_URI="${DOCKER_SERVER_URI:-}"
    DOCKER_SERVER_USERNAME="${DOCKER_SERVER_USERNAME:-}"
    DOCKER_SERVER_PASSWORD="${DOCKER_SERVER_PASSWORD:-}"
    DOCKER_IMAGE_TAG_TARGET_ENV="${DOCKER_IMAGE_TAG_TARGET_ENV:-}"
}

# Parse publisher file
parse_publisher_file() {
    local publish_file_path="$1"
    if [[ -f "$publish_file_path" ]]; then
        echo "Parsing publisher file: $publish_file_path"
        PUBLISHER=$(cat "$publish_file_path" | jq '.')
        IMAGE_NAME=$(echo "$PUBLISHER" | jq -r '.image_name')
        IS_IMAGE_TAG_BASED_ON_ENV=$(echo "$PUBLISHER" | jq -r '.is_image_tag_based_on_env')
        if [[ "$IS_IMAGE_TAG_BASED_ON_ENV" == "true" ]]; then
            IMAGE_TAG=$(echo "$PUBLISHER" | jq -r ".image_tags.${DOCKER_IMAGE_TAG_TARGET_ENV}")
        else
            IMAGE_TAG=$(echo "$PUBLISHER" | jq -r '.image_tags.base')
        fi
    else
        echo "File does not exist: $publish_file_path"
        exit 1
    fi
}

# Build Docker image
build_docker_image() {
    local image_name="$1"
    local tag="$2"
    local build_context="$3"
    local build_args="$4"
    local docker_is_private_registry="$5"
    local docker_server_uri="$6"
    local docker_server_username="$7"
    local docker_server_password="$8"
    local target_build_docker_path="$9"

    if [[ "$docker_is_private_registry" == "true" ]]; then
        echo "> Docker login."
        echo "$docker_server_password" | docker login "$docker_server_uri" --username "$docker_server_username" --password-stdin
    fi

    echo "> Start building the Docker image."
    local appended_args=()

    # Parse build arguments
    if [[ -n "$build_args" && "$build_args" != "[]" ]]; then
        echo "Parsing build arguments..."
        for build_arg in $(echo "$build_args" | jq -c '.[]'); do
            key=$(echo "$build_arg" | jq -r 'keys[0]')
            value=$(echo "$build_arg" | jq -r ".[\"$key\"]")
            appended_args+=("--build-arg" "$key=$value")
        done
    fi

    echo "Building Docker image: $image_name:$tag"
    docker build \
        -t "$image_name:$tag" \
        "${appended_args[@]}" \
        "$build_context"

    echo "Pushing Docker image: $image_name:$tag"
    docker push "$image_name:$tag"
}

execute() {
    activate_global_env_vars
    activate_required_env_vars

    # Parse publisher file
    parse_publisher_file "$PUBLISH_FILE_PATH"

    # Prepare paths
    TARGET_DOCKER_RESOURCE_PATH="${DOCKER_RESOURCE_WORK_DIR}/${DOCKER_TARGET_DOCKERFILE}"
    echo "> Prepare resources to build Docker image."
    echo "Target build output path: $TARGET_BUILD_OUTPUT_PATH"
    echo "Target build Docker path: $TARGET_BUILD_DOCKER_PATH"
    echo "Target Docker resource path: $TARGET_DOCKER_RESOURCE_PATH"

    echo "Verifying content of target Docker resource path: $TARGET_DOCKER_RESOURCE_PATH"
    tree "$TARGET_DOCKER_RESOURCE_PATH"

    echo "Copying content of target Docker resource and build output to target build Docker path."
    
    ls -la "$TARGET_BUILD_OUTPUT_PATH"
    ls -la "$TARGET_DOCKER_RESOURCE_PATH"
    ls -la "$TARGET_BUILD_DOCKER_PATH"

    cp -r "$TARGET_BUILD_OUTPUT_PATH" "$TARGET_BUILD_DOCKER_PATH"
    cp -r "$TARGET_DOCKER_RESOURCE_PATH" "$TARGET_BUILD_DOCKER_PATH"

    echo "Verifying content of target build Docker path: $TARGET_BUILD_DOCKER_PATH"
    tree "$TARGET_BUILD_DOCKER_PATH"

    # # Build Docker image
    # build_docker_image \
    #     "$IMAGE_NAME" \
    #     "$IMAGE_TAG" \
    #     "$DOCKER_BUILD_PATH" \
    #     "$DOCKERS_ARGS_JSON" \
    #     "$DOCKER_IS_PRIVATE_REGISTRY" \
    #     "$DOCKER_SERVER_URI" \
    #     "$DOCKER_SERVER_USERNAME" \
    #     "$DOCKER_SERVER_PASSWORD" \
    #     "$TARGET_BUILD_DOCKER_PATH"

    # echo "> Add tag on pipeline."
    # echo "image_name=$IMAGE_NAME"
    # echo "image_tag=$IMAGE_TAG"
}

# Run the script
execute