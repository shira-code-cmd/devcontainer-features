#!/bin/bash

# This test file is executed against a running container built from the
# 'python' Feature. The Feature only contributes VS Code customizations,
# so there is nothing to install or verify inside the container itself.
#
# The devcontainer CLI runs it for each base image in the matrix
# defined in .github/workflows/test.yaml:
#    devcontainer features test --skip-scenarios -f python -i <base image> .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Smoke test: the container built with the Feature is usable
check "bash is available" bash -c "command -v bash"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
