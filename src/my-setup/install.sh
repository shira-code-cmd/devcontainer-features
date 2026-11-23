#!/bin/bash
set -e

echo "Activating feature 'my-setup'"

USER_NAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_GROUP="$(id -gn "${USER_NAME}")"

GIT_USER_NAME="${GITUSERNAME:-}"
GIT_USER_EMAIL="${GITUSEREMAIL:-}"

STARSHIP="${STARSHIP:-true}"
AUTOSUGGESTIONS="${AUTOSUGGESTIONS:-true}"
SYNTAX_HIGHLIGHTING="${SYNTAXHIGHLIGHTING:-true}"
PERSIST_HISTORY="${PERSISTHISTORY:-true}"

HISTORY_DIR="/mnt/zsh-history"

AUTOSUGGESTIONS_FILE="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
SYNTAX_HIGHLIGHTING_FILE="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if ! command -v apt-get >/dev/null 2>&1; then
    echo "my-setup only supports Debian/Ubuntu-based images (apt-get not found)." >&2
    exit 1
fi

packages=()

if ! command -v zsh >/dev/null 2>&1; then
    packages+=(zsh)
fi

if [ "${AUTOSUGGESTIONS}" = "true" ] && [ ! -f "${AUTOSUGGESTIONS_FILE}" ]; then
    packages+=(zsh-autosuggestions)
fi

if [ "${SYNTAX_HIGHLIGHTING}" = "true" ] && [ ! -f "${SYNTAX_HIGHLIGHTING_FILE}" ]; then
    packages+=(zsh-syntax-highlighting)
fi

if [ "${STARSHIP}" = "true" ] && ! command -v starship >/dev/null 2>&1; then
    packages+=(curl ca-certificates)
fi

if [ ${#packages[@]} -gt 0 ]; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${packages[@]}"
    rm -rf /var/lib/apt/lists/*
fi

if [ "${STARSHIP}" = "true" ] && ! command -v starship >/dev/null 2>&1; then
    starship_installer="$(mktemp)"
    curl -fsSL https://starship.rs/install.sh -o "${starship_installer}"
    sh "${starship_installer}" --yes --bin-dir /usr/local/bin
    rm -f "${starship_installer}"
fi

if [ "${AUTOSUGGESTIONS}" = "true" ] && [ ! -f "${AUTOSUGGESTIONS_FILE}" ]; then
    echo "ERROR: ${AUTOSUGGESTIONS_FILE} was not installed." >&2
    exit 1
fi

if [ "${SYNTAX_HIGHLIGHTING}" = "true" ] && [ ! -f "${SYNTAX_HIGHLIGHTING_FILE}" ]; then
    echo "ERROR: ${SYNTAX_HIGHLIGHTING_FILE} was not installed." >&2
    exit 1
fi

ZSHRC="${USER_HOME}/.zshrc"

# Replace a previously managed block so re-running the Feature is idempotent.
if [ -f "${ZSHRC}" ] && grep -qF '# >>> my-setup zsh >>>' "${ZSHRC}"; then
    sed -i '/^# >>> my-setup zsh >>>$/,/^# <<< my-setup zsh <<<$/d' "${ZSHRC}"
fi

touch "${ZSHRC}"

# Do not glue the managed block onto the last line of an existing file.
if [ -s "${ZSHRC}" ] && [ -n "$(tail -c 1 "${ZSHRC}")" ]; then
    printf '\n' >> "${ZSHRC}"
fi

{
    echo '# >>> my-setup zsh >>>'
    if [ "${PERSIST_HISTORY}" = "true" ]; then
        echo "HISTFILE=${HISTORY_DIR}/.zsh_history"
        echo 'HISTSIZE=10000'
        echo 'SAVEHIST=10000'
        echo 'setopt SHARE_HISTORY'
        echo 'setopt HIST_IGNORE_ALL_DUPS'
        echo 'setopt HIST_IGNORE_SPACE'
        echo 'setopt HIST_REDUCE_BLANKS'
    fi
    echo 'autoload -Uz compinit && compinit'
    if [ "${AUTOSUGGESTIONS}" = "true" ]; then
        printf '[ -f %s ] && source %s\n' "${AUTOSUGGESTIONS_FILE}" "${AUTOSUGGESTIONS_FILE}"
    fi
    if [ "${STARSHIP}" = "true" ]; then
        echo 'if command -v starship >/dev/null 2>&1; then'
        echo '  eval "$(starship init zsh)"'
        echo 'fi'
    fi
    if [ "${SYNTAX_HIGHLIGHTING}" = "true" ]; then
        printf '[ -f %s ] && source %s\n' "${SYNTAX_HIGHLIGHTING_FILE}" "${SYNTAX_HIGHLIGHTING_FILE}"
    fi
    echo '# <<< my-setup zsh <<<'
} >> "${ZSHRC}"

chown "${USER_NAME}:${USER_GROUP}" "${ZSHRC}"

# ---- git ----

# git is not included in some minimal images (e.g. debian:latest).
if ! command -v git >/dev/null 2>&1; then
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "my-setup requires git, and only supports Debian/Ubuntu-based images (apt-get not found)." >&2
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

# Named volume for zsh history (mounted at container start, root-owned at first).
mkdir -p "${HISTORY_DIR}"
chown -R "${USER_NAME}:${USER_GROUP}" "${HISTORY_DIR}"
# updateRemoteUserUID may change the user's UID after build, which would leave the
# volume root dir owned by a stale UID. Keep it writable regardless (sticky bit).
chmod 1777 "${HISTORY_DIR}"

link_dir "${USER_HOME}/.config/gh" /mnt/gh/config

# ---- Claude Code ----

# The host's ~/.claude is bind-mounted at /mnt/claude/config when the container
# starts. CLAUDE_CONFIG_DIR points here, so ~/.claude.json is stored inside it.
mkdir -p /mnt/claude/config
chown -R "${USER_NAME}:${USER_GROUP}" /mnt/claude

# Keep ~/.claude usable for paths that do not honor CLAUDE_CONFIG_DIR.
link_dir "${USER_HOME}/.claude" /mnt/claude/config

# ---- OpenCode ----

mkdir -p /mnt/opencode/config /mnt/opencode/data /mnt/opencode/state
chown -R "${USER_NAME}:${USER_GROUP}" /mnt/opencode
# /mnt/opencode/data is a named volume (root-owned at first, and the owner UID may
# change via updateRemoteUserUID). Keep it writable regardless, like the zsh history.
chmod 1777 /mnt/opencode/data

link_dir "${USER_HOME}/.config/opencode" /mnt/opencode/config
link_dir "${USER_HOME}/.local/share/opencode" /mnt/opencode/data
link_dir "${USER_HOME}/.local/state/opencode" /mnt/opencode/state

# Make opencode available regardless of the shell's login configuration.
if [ -x "${USER_HOME}/.opencode/bin/opencode" ]; then
    ln -sf "${USER_HOME}/.opencode/bin/opencode" /usr/local/bin/opencode
fi
