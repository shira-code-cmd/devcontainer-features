#!/bin/bash

# This test file is executed against a running container built from the
# 'my-setup' Feature with its default options.
#
#    devcontainer features test --skip-scenarios -f my-setup -i <base image> .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Persistent data: link the anchor to a throwaway workspace so the checks do
# not depend on whether onCreateCommand ran in the test harness.
WS="$(mktemp -d)"
git -C "$WS" init -q 2>/dev/null || true
/usr/local/share/my-setup/init-data.sh "$WS"
DATA="$WS/.devcontainer/.my-setup"
export WS DATA

check "init script is installed" bash -c "[ -x /usr/local/share/my-setup/init-data.sh ]"
check "data anchor points to the workspace" bash -c "[ \"\$(readlink /mnt/my-setup/data)\" = \"\$DATA\" ]"
check "data dir ignores itself" bash -c "[ \"\$(cat \"\$DATA/.gitignore\")\" = '*' ]"
check "data dir is private" bash -c "[ \"\$(stat -c %a \"\$DATA\")\" = 700 ]"
check "init script is idempotent" bash -c "/usr/local/share/my-setup/init-data.sh \"\$WS\" && [ \"\$(readlink /mnt/my-setup/data)\" = \"\$DATA\" ]"

# zsh
check "zsh is available" bash -c "command -v zsh"
check "starship is available" bash -c "command -v starship"
check "autosuggestions is installed" bash -c "test -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
check "syntax highlighting is installed" bash -c "test -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
check "zshrc has the managed block" bash -c "grep -q '# >>> my-setup zsh >>>' \"$HOME/.zshrc\""
check "managed block appears once" bash -c "[ \"\$(grep -c '# >>> my-setup zsh >>>' \"$HOME/.zshrc\")\" -eq 1 ]"
check "autosuggestions is loaded" bash -c "grep -q 'zsh-autosuggestions.zsh' \"$HOME/.zshrc\""
check "starship is initialized" bash -c "grep -q 'starship init zsh' \"$HOME/.zshrc\""
check "syntax highlighting is loaded" bash -c "grep -q 'zsh-syntax-highlighting.zsh' \"$HOME/.zshrc\""
check "history file points to the data dir" bash -c "grep -q 'HISTFILE=/mnt/my-setup/data/zsh-history/.zsh_history' \"$HOME/.zshrc\""
check "history share option is set" bash -c "grep -q 'setopt SHARE_HISTORY' \"$HOME/.zshrc\""
check "history dir is writable" bash -c "touch /mnt/my-setup/data/zsh-history/.w && rm /mnt/my-setup/data/zsh-history/.w"
check "interactive zsh starts" bash -c "TERM=xterm-256color zsh -i -c 'exit 0'"

# git / gh
check "git is available" bash -c "command -v git"
check "gh is available" bash -c "command -v gh"
check "gh config is linked" bash -c "[ \"\$(readlink \"$HOME/.config/gh\")\" = /mnt/my-setup/data/gh ]"
check "gh config is writable" bash -c "touch \"$HOME/.config/gh/hosts.yml\" && [ -f \"\$DATA/gh/hosts.yml\" ]"
check "gh config is not tracked by git" bash -c "[ -z \"\$(git -C \"\$WS\" status --porcelain)\" ]"
check "github credential helper is configured" bash -c "git config --global --get-all credential.https://github.com.helper | grep -F '!gh auth git-credential'"
check "gist credential helper is configured" bash -c "git config --global --get-all credential.https://gist.github.com.helper | grep -F '!gh auth git-credential'"

# Claude Code
check "claude is available" bash -c "command -v claude"
check "CLAUDE_CONFIG_DIR is set" bash -c "[ \"\$CLAUDE_CONFIG_DIR\" = /mnt/my-setup/data/claude ]"
check "~/.claude is linked" bash -c "[ \"\$(readlink \"$HOME/.claude\")\" = /mnt/my-setup/data/claude ]"
check "claude config dir is writable" bash -c "touch \"\$CLAUDE_CONFIG_DIR/.write-test\" && rm \"\$CLAUDE_CONFIG_DIR/.write-test\""

# OpenCode
check "opencode is available" bash -c "command -v opencode"
check "opencode config is linked" bash -c "[ -L \"$HOME/.config/opencode\" ]"
check "opencode data is linked" bash -c "[ -L \"$HOME/.local/share/opencode\" ]"
check "opencode state is linked" bash -c "[ -L \"$HOME/.local/state/opencode\" ]"
check "opencode dirs are writable" bash -c "for d in config data state; do touch /mnt/my-setup/data/opencode/\$d/.w && rm /mnt/my-setup/data/opencode/\$d/.w || exit 1; done"

# Report result
reportResults
