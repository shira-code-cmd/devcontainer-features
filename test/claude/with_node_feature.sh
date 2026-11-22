#!/bin/bash

# This test verifies the 'with_node_feature' scenario in scenarios.json, where
# Node.js comes from the official 'node' Feature instead of the base image.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

check "node is available" bash -c "command -v node"
check "claude is available" bash -c "command -v claude"
check "CLAUDE_CONFIG_DIR is set" bash -c "[ \"\$CLAUDE_CONFIG_DIR\" = /mnt/claude/config ]"
check "~/.claude is linked" bash -c "[ \"\$(readlink \"$HOME/.claude\")\" = /mnt/claude/config ]"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
