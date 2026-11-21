#!/bin/bash

# This test file is executed against a running container built from the
# 'opencode' Feature with its default options.
#
# The devcontainer CLI runs it for each base image in the matrix
# defined in .github/workflows/test.yaml:
#    devcontainer features test --skip-scenarios -f opencode -i <base image> .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# opencode is installed by the dirien Feature (dependsOn)
check "opencode is available" bash -c "command -v opencode"

# The opencode directories are symlinks to the persistent mount points
check "config is linked" bash -c "[ -L \"$HOME/.config/opencode\" ]"
check "data is linked" bash -c "[ -L \"$HOME/.local/share/opencode\" ]"
check "state is linked" bash -c "[ -L \"$HOME/.local/state/opencode\" ]"

# The mount points exist inside the image as well
check "config mount point exists" bash -c "[ -d /mnt/opencode/config ]"
check "data mount point exists" bash -c "[ -d /mnt/opencode/data ]"
check "state mount point exists" bash -c "[ -d /mnt/opencode/state ]"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
