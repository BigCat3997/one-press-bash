#!/bin/bash

set -e

SCRIPTS_WORK_DIR=${SCRIPTS_WORK_DIR:=.}
GLOBAL_ENV_VAR_MANAGER_SCRIPT_PATH="${SCRIPTS_WORK_DIR}/src/functions/global_env_var_manager.sh"
PUBLISH_PREFIX_PATH="${PUBLISH_PREFIX_PATH:-.}"
PUBLISH_FILE_NAME="${PUBLISH_FILE_NAME:-publish.json}"
IS_IMAGE_TAG_BASED_ON_ENV="${IS_IMAGE_TAG_BASED_ON_ENV:-false}"
DOCKER_MULTIPLE_TAGS_ENVS="${DOCKER_MULTIPLE_TAGS_ENVS:-}"
GIT_URL="${GIT_URL:-}"
GIT_COMMIT_ID="${GIT_COMMIT_ID:-}"
GIT_SHORT_COMMIT_ID="${GIT_SHORT_COMMIT_ID:-}"
PIPELINE_NAME="${PIPELINE_NAME:-}"
BUILD_NUMBER="${BUILD_NUMBER:-}"
DOCKER_SERVER_URI="${DOCKER_SERVER_URI:-}"
DOCKER_IMAGE_NAME="${DOCKER_IMAGE_NAME:-}"
DOCKER_IMAGE_TAG="${DOCKER_IMAGE_TAG:-}"
IS_DEFAULT_PUBLIC_ENVS="${IS_DEFAULT_PUBLIC_ENVS:-true}"
MANUALLY_PUBLIC_ENV_VARS="${MANUALLY_PUBLIC_ENV_VARS:-}"
MANUALLY_PRIVATE_ENV_VARS="${MANUALLY_PRIVATE_ENV_VARS:-}"
HOST_PUBLIC_ENV_VARS="${HOST_PUBLIC_ENV_VARS:-}"
HOST_PRIVATE_ENV_VARS="${HOST_PRIVATE_ENV_VARS:-}"

if [[ "$IS_IMAGE_TAG_BASED_ON_ENV" == "true" ]]; then
    IMAGE_TAGS=$(echo "$DOCKER_MULTIPLE_TAGS_ENVS" | jq -c 'reduce .[] as $env ({}; .[$env] = ($env + "." + $ENV.DOCKER_IMAGE_TAG))')
else
    IMAGE_TAGS=$(jq -n --arg tag "$DOCKER_IMAGE_TAG" '{"default":$tag}')
fi

PUBLISHER=$(jq -n \
    --arg git_url "$GIT_URL" \
    --arg git_commit_id "$GIT_COMMIT_ID" \
    --arg git_short_commit_id "$GIT_SHORT_COMMIT_ID" \
    --arg pipeline_name "$PIPELINE_NAME" \
    --arg build_number "$BUILD_NUMBER" \
    --arg docker_server_uri "$DOCKER_SERVER_URI" \
    --argjson image_tags "$IMAGE_TAGS" \
    '{
        git_url: $git_url,
        git_commit_id: $git_commit_id,
        git_short_commit_id: $git_short_commit_id,
        pipeline_name: $pipeline_name,
        build_number: $build_number,
        docker_server_uri: $docker_server_uri,
        image_tags: $image_tags,
    }')

PUBLISH_FILE_PATH="${PUBLISH_PREFIX_PATH}/${PUBLISH_FILE_NAME}"
echo "$PUBLISHER" | jq '.' > "$PUBLISH_FILE_PATH"
# echo "export PUBLISH_FILE_PATH=${PUBLISH_FILE_PATH}" >> $GLOBAL_ENV_VAR_DIR/$GLOBAL_ENV_VAR_FILE
echo $GLOBAL_ENV_VAR_MANAGER_SCRIPT_PATH
sh ${GLOBAL_ENV_VAR_MANAGER_SCRIPT_PATH} "export PUBLISH_FILE_PATH=${PUBLISH_FILE_PATH}"
