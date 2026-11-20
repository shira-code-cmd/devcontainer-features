#!/bin/bash
set -e

if [ "${INSTALLTOOLS}" = "true" ]; then
    apt-get update
    apt-get install -y ripgrep fzf jq
fi