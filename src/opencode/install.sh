#!/bin/bash
set -e

echo "Activating feature 'opencode'"

USER_NAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_GROUP="$(id -gn "${USER_NAME}")"

# These directories are replaced by the bind mounts declared in
# devcontainer-feature.json when the container starts.
mkdir -p /mnt/opencode/config /mnt/opencode/data /mnt/opencode/state
chown -R "${USER_NAME}:${USER_GROUP}" /mnt/opencode

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

link_dir "${USER_HOME}/.config/opencode" /mnt/opencode/config
link_dir "${USER_HOME}/.local/share/opencode" /mnt/opencode/data
link_dir "${USER_HOME}/.local/state/opencode" /mnt/opencode/state

# Make opencode available regardless of the shell's login configuration.
if [ -x "${USER_HOME}/.opencode/bin/opencode" ]; then
    ln -sf "${USER_HOME}/.opencode/bin/opencode" /usr/local/bin/opencode
fi
