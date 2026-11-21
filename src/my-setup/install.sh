#!/bin/bash
set -e

if ! command -v zsh >/dev/null 2>&1; then
    if ! command -v apt-get >/dev/null 2>&1; then
        echo "my-setup only supports Debian/Ubuntu-based images (apt-get not found)." >&2
        exit 1
    fi

    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends zsh
    rm -rf /var/lib/apt/lists/*
fi
