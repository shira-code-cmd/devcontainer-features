#!/bin/bash

# This test file is executed against a running container built from the
# 'zsh' Feature on an image that already ships a ~/.zshrc
# (mcr.microsoft.com/devcontainers/base:ubuntu).

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# The existing oh-my-zsh configuration must not be removed
check "existing zshrc content is preserved" bash -c "grep -q 'oh-my-zsh' \"$HOME/.zshrc\""

check "zshrc has the managed block" bash -c "grep -q '# >>> zsh feature >>>' \"$HOME/.zshrc\""
check "managed block appears once" bash -c "[ \"\$(grep -c '# >>> zsh feature >>>' \"$HOME/.zshrc\")\" -eq 1 ]"

# syntax-highlighting must be sourced after the existing configuration
check "managed block is appended at the end" bash -c "[ \"\$(tail -n 1 \"$HOME/.zshrc\")\" = '# <<< zsh feature <<<' ]"

check "interactive zsh starts" bash -c "TERM=xterm-256color zsh -i -c 'exit 0'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
