#!/bin/bash

# The 'test/_global' folder is a special test folder that is not tied to a single feature.
#
# This test file is executed against a running container constructed
# from the value of 'my_setup_with_common_utils' in the test/_global/scenarios.json file.
#
# This verifies that 'my-setup' works alongside the official 'common-utils' Feature.
#
# This test can be run with the following command (from the root of this repo)
#    devcontainer features test --global-scenarios-only .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Tools installed by 'my-setup' when installTools=true
check "ripgrep is available" bash -c "command -v rg"
check "fzf is available" bash -c "command -v fzf"
check "jq is available" bash -c "command -v jq"

# Tool installed by the official 'common-utils' Feature
check "zsh from common-utils is available" bash -c "command -v zsh"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
