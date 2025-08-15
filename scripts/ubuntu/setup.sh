#!/usr/bin/env bash
# Ubuntu setup script

set -euo pipefail

# Check if running on Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    echo "ERROR: This script is for Ubuntu/Debian systems only!"
    exit 1
fi

# Update package lists
sudo apt update -qq

# Install essential packages
sudo apt install -y -qq \
    curl \
    wget \
    git \
    build-essential \
    stow

# Install development tools
sudo apt install -y -qq \
    neovim \
    tmux \
    zsh \
    ripgrep \
    fd-find \
    fzf \
    bat \
    htop \
    jq \
    tree \
    unzip \
    zip \
    rsync

# Install mise (development tool version manager)
if ! command -v mise &> /dev/null; then
    curl -s https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Install zoxide (smarter cd command)
if ! command -v zoxide &> /dev/null; then
    curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi


# Fix bat command name (it's called batcat on Ubuntu)
if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/batcat ~/.local/bin/bat
fi

# Fix fd command name (it's called fdfind on Ubuntu)
if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
    mkdir -p ~/.local/bin
    ln -sf /usr/bin/fdfind ~/.local/bin/fd
fi 