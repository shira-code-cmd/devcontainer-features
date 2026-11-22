#!/bin/bash

# This test file is executed against a running container built from the
# 'claude' Feature with its default options.
#
# The devcontainer CLI runs it for each base image in the matrix
# defined in .github/workflows/test.yaml:
#    devcontainer features test --skip-scenarios -f claude -i <base image> .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# claude is installed by the anthropics Feature (dependsOn)
check "claude is available" bash -c "command -v claude"

# The config directory is the persistent mount point
check "CLAUDE_CONFIG_DIR is set" bash -c "[ \"\$CLAUDE_CONFIG_DIR\" = /mnt/claude/config ]"
check "config mount point exists" bash -c "[ -d /mnt/claude/config ]"
check "~/.claude is linked" bash -c "[ \"\$(readlink \"$HOME/.claude\")\" = /mnt/claude/config ]"
check "config dir is writable" bash -c "touch /mnt/claude/config/.write-test && rm /mnt/claude/config/.write-test"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
