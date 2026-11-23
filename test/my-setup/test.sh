#!/bin/bash

# This test file is executed against a running container built from the
# 'my-setup' Feature with its default options.
#
#    devcontainer features test --skip-scenarios -f my-setup -i <base image> .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

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
check "history file points to the mount" bash -c "grep -q 'HISTFILE=/mnt/zsh-history/.zsh_history' \"$HOME/.zshrc\""
check "history share option is set" bash -c "grep -q 'setopt SHARE_HISTORY' \"$HOME/.zshrc\""
check "history mount point exists" bash -c "[ -d /mnt/zsh-history ]"
check "history dir is writable" bash -c "touch /mnt/zsh-history/.w && rm /mnt/zsh-history/.w"
check "interactive zsh starts" bash -c "TERM=xterm-256color zsh -i -c 'exit 0'"

# git / gh
check "git is available" bash -c "command -v git"
check "gh is available" bash -c "command -v gh"
check "gh config is linked" bash -c "[ -L \"$HOME/.config/gh\" ]"
check "gh config mount point exists" bash -c "[ -d /mnt/gh/config ]"
check "github credential helper is configured" bash -c "git config --global --get-all credential.https://github.com.helper | grep -F '!gh auth git-credential'"
check "gist credential helper is configured" bash -c "git config --global --get-all credential.https://gist.github.com.helper | grep -F '!gh auth git-credential'"

# Claude Code
check "claude is available" bash -c "command -v claude"
check "CLAUDE_CONFIG_DIR is set" bash -c "[ \"\$CLAUDE_CONFIG_DIR\" = /mnt/claude/config ]"
check "claude config mount point exists" bash -c "[ -d /mnt/claude/config ]"
check "~/.claude is linked" bash -c "[ \"\$(readlink \"$HOME/.claude\")\" = /mnt/claude/config ]"
check "claude config dir is writable" bash -c "touch /mnt/claude/config/.write-test && rm /mnt/claude/config/.write-test"

# OpenCode
check "opencode is available" bash -c "command -v opencode"
check "opencode config is linked" bash -c "[ -L \"$HOME/.config/opencode\" ]"
check "opencode data is linked" bash -c "[ -L \"$HOME/.local/share/opencode\" ]"
check "opencode state is linked" bash -c "[ -L \"$HOME/.local/state/opencode\" ]"
check "opencode mount points exist" bash -c "[ -d /mnt/opencode/config ] && [ -d /mnt/opencode/data ] && [ -d /mnt/opencode/state ]"

# Report result
reportResults
