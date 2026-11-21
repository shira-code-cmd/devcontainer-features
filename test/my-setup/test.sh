#!/bin/bash

# This test file is executed against a running container built from the
# 'my-setup' Feature with its default options (installTools=true).
#
# The devcontainer CLI runs it for each base image in the matrix
# defined in .github/workflows/test.yaml:
#    devcontainer features test --skip-scenarios -f my-setup -i <base image> .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Tools installed by 'my-setup' when installTools=true (the default)
check "ripgrep is available" bash -c "command -v rg"
check "fzf is available" bash -c "command -v fzf"
check "jq is available" bash -c "command -v jq"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
