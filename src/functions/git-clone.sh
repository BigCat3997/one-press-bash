#!/bin/bash
# Purpose: Clone source code from Git Repository.
# --------------------------------------
APP_SOURCE_BASE_DIR="${APP_SOURCE_BASE_DIR:-$(pwd)}"
APP_SOURCE="${APP_SOURCE:-app_source}"
IS_PRIVATE_REPO="${IS_PRIVATE_REPO:-false}"
GIT_BRANCH="${GIT_BRANCH:-master}"
GIT_URL="${GIT_URL}"
GIT_USERNAME="${GIT_USERNAME}"
GIT_TOKEN="${GIT_TOKEN}"
IS_DELETE_GIT_DIR="${IS_DELETE_GIT_DIR:-false}"
GIT_COMMIT_ID=""
GIT_SHORT_COMMIT_ID=""

clone_repo() {
    local app_source_base_dir="$1"
    local app_source="$2"
    local is_private_repo="$3"
    local git_branch="$4"
    local git_url="$5"
    local git_username="$6"
    local git_token="$7"
    local is_delete_git_dir="$8"

    local app_source_dir="${app_source_base_dir}/${app_source}"

    if [ "$is_private_repo" = true ]; then
        local git_protocol="${git_url%%://*}://"
        local git_uri="${git_url#*://}"
        local credential_url="${git_protocol}${git_username}:${git_token}@${git_uri}"
    else
        local credential_url="$git_url"
    fi

    echo "> Cloning app source..."
    mkdir -p "$app_source_dir"
    cd "$app_source_dir" || exit

    git clone "$credential_url" .
    git checkout "$git_branch"
    local git_commit_id
    git_commit_id=$(git rev-parse HEAD)
    local git_short_commit_id
    git_short_commit_id=$(git rev-parse --short HEAD)

    if [ "$is_delete_git_dir" = true ]; then
        echo "> Remove .git directory."
        rm -rf .git
    fi

    cd "$app_source_base_dir" || exit
    echo "> Verify content of source."
    ls "$app_source_dir"

    GIT_COMMIT_ID="$git_commit_id"
    GIT_SHORT_COMMIT_ID="$git_short_commit_id"
}

main() {
    clone_repo "$APP_SOURCE_BASE_DIR" "$APP_SOURCE" "$IS_PRIVATE_REPO" "$GIT_BRANCH" "$GIT_URL" "$GIT_USERNAME" "$GIT_TOKEN" "$IS_DELETE_GIT_DIR"
}

main "$@"
