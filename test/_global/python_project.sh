#!/bin/bash

# The 'test/_global' folder is a special test folder that is not tied to a single feature.
#
# This test file is executed against a running container constructed
# from the value of 'python_project' in the test/_global/scenarios.json file.
#
# It verifies the combination used by a real Python project:
#   - my-setup provides the common VS Code configuration (including Python),
#     zsh (starship), git/gh, Node.js, Claude Code and OpenCode
#
# This test can be run with the following command (from the root of this repo)
#    devcontainer features test --global-scenarios-only .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# zsh is installed by 'my-setup' (or already present in the base image)
check "zsh is available" bash -c "command -v zsh"

# starship and the zsh configuration are provided by the 'my-setup' Feature
check "starship is available" bash -c "command -v starship"
check "zshrc has the managed block" bash -c "grep -q '# >>> my-setup zsh >>>' \"$HOME/.zshrc\""

# Python comes from the base image
check "python is available" bash -c "command -v python"

# Node.js, Claude Code and OpenCode are installed through my-setup's dependsOn
check "node is available" bash -c "command -v node"
check "claude is available" bash -c "command -v claude"
check "opencode is available" bash -c "command -v opencode"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
