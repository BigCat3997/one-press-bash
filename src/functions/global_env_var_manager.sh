#!/bin/bash
# Purpose: Manage global environment variables for the build process.
# --------------------------------------
GLOBAL_ENV_VAR_DIR="${GLOBAL_ENV_VAR_DIR:-$(WORKSPACE)}"
GLOBAL_ENV_VAR_FILE="${GLOBAL_ENV_VAR_PATH:-.env}"
GLOBAL_ENV_VAR_FILE_PATH="${GLOBAL_ENV_VAR_DIR}/${GLOBAL_ENV_VAR_FILE}"

write_env_vars() {
    if [ ! -d "$GLOBAL_ENV_VAR_DIR" ]; then
        echo "> Creating directory: $GLOBAL_ENV_VAR_DIR"
        mkdir -p "$GLOBAL_ENV_VAR_DIR"
    fi
    if [ ! -f "$GLOBAL_ENV_VAR_FILE_PATH" ]; then
        echo "> Creating file: $GLOBAL_ENV_VAR_FILE_PATH"
        touch "$GLOBAL_ENV_VAR_FILE_PATH"
    fi

    for input in "$@"; do
        echo "$input" >> "$GLOBAL_ENV_VAR_FILE_PATH"
    done

    echo "> Content written to $GLOBAL_ENV_VAR_FILE_PATH"
}

activate_env_vars() {
    if [ -f "$GLOBAL_ENV_VAR_FILE_PATH" ]; then
        source "$GLOBAL_ENV_VAR_FILE_PATH"
    else
        echo "> File not found: $GLOBAL_ENV_VAR_FILE_PATH"
    fi
}
