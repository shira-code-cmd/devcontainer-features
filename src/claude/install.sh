#!/bin/bash
set -e

echo "Activating feature 'claude'"

USER_NAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_GROUP="$(id -gn "${USER_NAME}")"

CONFIG_DIR=/mnt/claude/config

# This directory is replaced by the bind mount declared in
# devcontainer-feature.json when the container starts.
# CLAUDE_CONFIG_DIR points here, so ~/.claude.json is stored inside it as
# ${CONFIG_DIR}/.claude.json instead of being a separate file mount.
mkdir -p "${CONFIG_DIR}"
chown -R "${USER_NAME}:${USER_GROUP}" /mnt/claude

link_dir() {
    local link="$1"
    local target="$2"

    if [ -L "$link" ]; then
        rm -f "$link"
    elif [ -e "$link" ]; then
        # Only replace an empty directory. Never delete existing data.
        if [ -d "$link" ] && [ -z "$(ls -A "$link" 2>/dev/null)" ]; then
            rm -rf "$link"
        else
            echo "ERROR: ${link} already exists and is not empty." >&2
            echo "Remove it and rebuild so the persistent mount can be used." >&2
            exit 1
        fi
    fi

    mkdir -p "$(dirname "$link")"
    ln -s "$target" "$link"
    chown -h "${USER_NAME}:${USER_GROUP}" "$link"
}

# Keep ~/.claude usable for paths that do not honor CLAUDE_CONFIG_DIR
# (e.g. hook commands or docs that reference ~/.claude/settings.json).
link_dir "${USER_HOME}/.claude" "${CONFIG_DIR}"
