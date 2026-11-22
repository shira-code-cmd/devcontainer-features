#!/bin/bash
set -e

echo "Activating feature 'zsh'"

USER_NAME="${_REMOTE_USER:-root}"
USER_HOME="${_REMOTE_USER_HOME:-/root}"
USER_GROUP="$(id -gn "${USER_NAME}")"

STARSHIP="${STARSHIP:-true}"
AUTOSUGGESTIONS="${AUTOSUGGESTIONS:-true}"
SYNTAX_HIGHLIGHTING="${SYNTAXHIGHLIGHTING:-true}"

AUTOSUGGESTIONS_FILE="/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
SYNTAX_HIGHLIGHTING_FILE="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

if ! command -v apt-get >/dev/null 2>&1; then
    echo "zsh only supports Debian/Ubuntu-based images (apt-get not found)." >&2
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
if [ -f "${ZSHRC}" ] && grep -qF '# >>> zsh feature >>>' "${ZSHRC}"; then
    sed -i '/^# >>> zsh feature >>>$/,/^# <<< zsh feature <<<$/d' "${ZSHRC}"
fi

touch "${ZSHRC}"

# Do not glue the managed block onto the last line of an existing file.
if [ -s "${ZSHRC}" ] && [ -n "$(tail -c 1 "${ZSHRC}")" ]; then
    printf '\n' >> "${ZSHRC}"
fi

{
    echo '# >>> zsh feature >>>'
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
    echo '# <<< zsh feature <<<'
} >> "${ZSHRC}"

chown "${USER_NAME}:${USER_GROUP}" "${ZSHRC}"
