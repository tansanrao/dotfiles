#!/bin/bash

echo "Setting up macOS environment..."

# Install Xcode Command Line Tools
xcode-select --install

# Run Homebrew setup
./scripts/brew.sh

# Symlink dotfiles
#./scripts/link.sh

