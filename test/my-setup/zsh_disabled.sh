#!/bin/bash

# This test file is executed against a running container built from the
# 'my-setup' Feature with all options disabled.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

check "zsh is available" bash -c "command -v zsh"
check "starship is not installed" bash -c "! command -v starship"

check "autosuggestions is not installed" bash -c "test ! -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
check "syntax highlighting is not installed" bash -c "test ! -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

check "zshrc has the managed block" bash -c "grep -q '# >>> my-setup zsh >>>' \"$HOME/.zshrc\""
check "managed block appears once" bash -c "[ \"\$(grep -c '# >>> my-setup zsh >>>' \"$HOME/.zshrc\")\" -eq 1 ]"
check "starship is not initialized" bash -c "! grep -q 'starship init zsh' \"$HOME/.zshrc\""
check "autosuggestions is not loaded" bash -c "! grep -q 'zsh-autosuggestions.zsh' \"$HOME/.zshrc\""
check "syntax highlighting is not loaded" bash -c "! grep -q 'zsh-syntax-highlighting.zsh' \"$HOME/.zshrc\""

check "interactive zsh starts" bash -c "TERM=xterm-256color zsh -i -c 'exit 0'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
