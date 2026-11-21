#!/bin/bash

# This test file is executed against a running container built from the
# 'git-config' Feature with its default options.
#
# The devcontainer CLI runs it for each base image in the matrix
# defined in .github/workflows/test.yaml:
#    devcontainer features test --skip-scenarios -f git-config -i <base image> .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

check "git is available" bash -c "command -v git"
check "gh is available" bash -c "command -v gh"

# The host gh configuration is mounted at /mnt/gh/config and linked into $HOME
check "gh config is linked" bash -c "[ -L \"$HOME/.config/gh\" ]"
check "gh config mount point exists" bash -c "[ -d /mnt/gh/config ]"

# The credential helper is the same one that `gh auth setup-git` configures
check "github credential helper is configured" bash -c "git config --global --get-all credential.https://github.com.helper | grep -F '!gh auth git-credential'"
check "gist credential helper is configured" bash -c "git config --global --get-all credential.https://gist.github.com.helper | grep -F '!gh auth git-credential'"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
