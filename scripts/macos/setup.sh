#!/usr/bin/env bash
# macOS setup script

set -euo pipefail

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "ERROR: This script is for macOS only!"
    exit 1
fi

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
brew update -q

# Install command-line tools
brew install \
    curl \
    wget \
    git \
    stow \
    neovim \
    tmux \
    zsh \
    ripgrep \
    fd \
    fzf \
    bat \
    htop \
    mise \
    zoxide \
    jq \
    tree

# Install GUI applications
brew install --cask \
    alacritty \
    font-im-writing-nerd-font

# Install Mac App Store apps
if ! command -v mas &> /dev/null; then
    brew install mas
fi

mas install 937984704  # Amphetamine 