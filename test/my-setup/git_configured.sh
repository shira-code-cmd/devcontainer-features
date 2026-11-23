#!/bin/bash

# This test verifies the 'git_configured' scenario in scenarios.json, where both
# 'gitUserName' and 'gitUserEmail' are provided.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

check "user.name is configured" bash -c "git config --global user.name | grep -qx 'Test User'"
check "user.email is configured" bash -c "git config --global user.email | grep -qx 'test@example.com'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
