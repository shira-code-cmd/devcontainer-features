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

# Persistent data lives in <workspace>/.devcontainer/.my-setup. The workspace
# is unknown at build time, so everything points at this anchor, which
# init-data.sh (onCreateCommand) links to the workspace directory.
DATA_ROOT="/mnt/my-setup"
DATA_DIR="${DATA_ROOT}/data"
HISTORY_DIR="${DATA_DIR}/zsh-history"

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

# ---- persistent data (workspace) ----

# The anchor directory must be writable by the remote user at runtime.
# updateRemoteUserUID may change the UID after build, so use the sticky bit.
mkdir -p "${DATA_ROOT}"
chmod 1777 "${DATA_ROOT}"

mkdir -p /usr/local/share/my-setup
cat > /usr/local/share/my-setup/init-data.sh <<EOF
#!/bin/bash
# Create <workspace>/.devcontainer/.my-setup and link ${DATA_DIR} to it.
# Lifecycle commands run in the workspace folder; an argument overrides it.
set -e

workspace="\${1:-\$PWD}"
data="\${workspace}/.devcontainer/.my-setup"

mkdir -p "\${data}"/gh "\${data}"/zsh-history "\${data}"/claude \\
    "\${data}"/opencode/config "\${data}"/opencode/data "\${data}"/opencode/state
chmod 700 "\${data}"
# The directory ignores itself, so tokens and history are never committed.
if [ ! -f "\${data}/.gitignore" ]; then
    printf '*\\n' > "\${data}/.gitignore"
fi

ln -sfn "\${data}" "${DATA_DIR}"
EOF
chmod 755 /usr/local/share/my-setup/init-data.sh

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
            echo "Remove it and rebuild so the persistent data directory can be used." >&2
            exit 1
        fi
    fi

    mkdir -p "$(dirname "$link")"
    ln -s "$target" "$link"
    chown -h "${USER_NAME}:${USER_GROUP}" "$link"
}

link_dir "${USER_HOME}/.config/gh" "${DATA_DIR}/gh"

# ---- Claude Code ----

# CLAUDE_CONFIG_DIR points at ${DATA_DIR}/claude, so ~/.claude.json is stored
# inside it. Keep ~/.claude usable for paths that do not honor CLAUDE_CONFIG_DIR.
link_dir "${USER_HOME}/.claude" "${DATA_DIR}/claude"

# ---- OpenCode ----

link_dir "${USER_HOME}/.config/opencode" "${DATA_DIR}/opencode/config"
link_dir "${USER_HOME}/.local/share/opencode" "${DATA_DIR}/opencode/data"
link_dir "${USER_HOME}/.local/state/opencode" "${DATA_DIR}/opencode/state"

# Make opencode available regardless of the shell's login configuration.
if [ -x "${USER_HOME}/.opencode/bin/opencode" ]; then
    ln -sf "${USER_HOME}/.opencode/bin/opencode" /usr/local/bin/opencode
fi
