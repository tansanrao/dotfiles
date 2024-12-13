#!/bin/bash

echo "Starting dotfiles setup..."

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Running macOS setup..."
    ./mac-setup.sh
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Running Linux setup..."
    ./linux-setup.sh
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

