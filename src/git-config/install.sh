#!/bin/bash
set -e

echo "Activating feature 'git-config'"

GIT_USER_NAME="${GITUSERNAME:-}"
GIT_USER_EMAIL="${GITUSEREMAIL:-}"

USER_NAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_GROUP="$(id -gn "${USER_NAME}")"

# git is not included in some minimal images (e.g. debian:latest).
if ! command -v git >/dev/null 2>&1; then
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "git-config requires git, and only supports Debian/Ubuntu-based images (apt-get not found)." >&2
        exit 1
    fi

    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git
    rm -rf /var/lib/apt/lists/*
fi

git_config_global() {
    HOME="${USER_HOME}" git config --global "$@"
}

if [ -n "${GIT_USER_NAME}" ]; then
    git_config_global user.name "${GIT_USER_NAME}"
fi

if [ -n "${GIT_USER_EMAIL}" ]; then
    git_config_global user.email "${GIT_USER_EMAIL}"
fi

# Same credential helper configuration as `gh auth setup-git`.
# The empty value first resets any inherited helpers for the host.
setup_credential_helper() {
    local host="$1"
    local key="credential.https://${host}.helper"

    git_config_global --unset-all "${key}" >/dev/null 2>&1 || true
    git_config_global --add "${key}" ""
    git_config_global --add "${key}" "!gh auth git-credential"
}

setup_credential_helper github.com
setup_credential_helper gist.github.com

if [ -f "${USER_HOME}/.gitconfig" ]; then
    chown "${USER_NAME}:${USER_GROUP}" "${USER_HOME}/.gitconfig"
fi

# The host's gh configuration is bind-mounted at /mnt/gh/config when the
# container starts. Link it into the remote user's home directory.
mkdir -p /mnt/gh/config
chown -R "${USER_NAME}:${USER_GROUP}" /mnt/gh

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

link_dir "${USER_HOME}/.config/gh" /mnt/gh/config
