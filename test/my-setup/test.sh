#!/bin/bash

# This test file is executed against a running container built from the
# 'my-setup' Feature with its default options.
#
#    devcontainer features test --skip-scenarios -f my-setup -i <base image> .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Link the data anchor to a throwaway workspace, independent of onCreateCommand.
WS="$(mktemp -d)"
git -C "$WS" init -q
/usr/local/share/my-setup/init-data.sh "$WS"
export WS D=/mnt/my-setup/data

# Persistent data
check "anchor points to the workspace" bash -c "[ \"\$(readlink \$D)\" = \"\$WS/.devcontainer/.persist\" ]"
check "links point to the data dir" bash -c "[ \"\$(readlink ~/.config/gh)\" = \$D/gh ] && [ \"\$(readlink ~/.claude)\" = \$D/claude ] && [ \"\$(readlink ~/.local/share/opencode)\" = \$D/opencode/data ]"
check "data is writable and not tracked by git" bash -c "touch ~/.config/gh/hosts.yml \$D/zsh-history/.w \$CLAUDE_CONFIG_DIR/.w && [ -z \"\$(git -C \"\$WS\" status --porcelain)\" ]"

# zsh
check "zsh tools are installed" bash -c "command -v zsh && command -v starship && test -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh && test -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
check "managed block appears once" bash -c "[ \"\$(grep -c '# >>> my-setup zsh >>>' ~/.zshrc)\" -eq 1 ]"
# base:debian ships an oh-my-zsh ~/.zshrc; it must be kept, and syntax-highlighting must load after it
check "existing zshrc content is preserved" bash -c "grep -q 'oh-my-zsh' ~/.zshrc"
check "managed block is appended at the end" bash -c "[ \"\$(tail -n 1 ~/.zshrc)\" = '# <<< my-setup zsh <<<' ]"
check "history file points to the data dir" bash -c "grep -q 'HISTFILE=/mnt/my-setup/data/zsh-history/.zsh_history' ~/.zshrc"
check "interactive zsh starts" bash -c "TERM=xterm-256color zsh -i -c 'exit 0'"

# git / gh
check "git and gh are available" bash -c "command -v git && command -v gh"
check "credential helpers are configured" bash -c "git config --global --get-all credential.https://github.com.helper | grep -qF '!gh auth git-credential' && git config --global --get-all credential.https://gist.github.com.helper | grep -qF '!gh auth git-credential'"

# Claude Code / OpenCode
check "claude and opencode are available" bash -c "command -v claude && command -v opencode"
check "CLAUDE_CONFIG_DIR is set" bash -c "[ \"\$CLAUDE_CONFIG_DIR\" = /mnt/my-setup/data/claude ]"

# Report result
reportResults
