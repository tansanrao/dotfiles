#!/usr/bin/env bash
# Bootstrap script for Linux - Install essential tools and packages

set -euo pipefail

echo "INFO: Setting up Linux prerequisites..."

# Detect package manager
if command -v apt &> /dev/null; then
    PACKAGE_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    PACKAGE_MANAGER="dnf"
elif command -v pacman &> /dev/null; then
    PACKAGE_MANAGER="pacman"
else
    echo "ERROR: No supported package manager found (apt, dnf, pacman)"
    exit 1
fi

echo "INFO: Detected package manager: $PACKAGE_MANAGER"

# Update package lists
case "$PACKAGE_MANAGER" in
    apt)
        echo "INFO: Updating package lists..."
        sudo apt update -qq
        
        echo "INFO: Installing packages from apt-packages.txt..."
        if [[ -f "packages/apt-packages.txt" ]]; then
            xargs -a packages/apt-packages.txt sudo apt install -y
        fi
        
        # Fix Ubuntu command names (bat -> batcat, fd -> fdfind)
        if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
            mkdir -p ~/.local/bin
            ln -sf /usr/bin/batcat ~/.local/bin/bat
        fi
        
        if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
            mkdir -p ~/.local/bin
            ln -sf /usr/bin/fdfind ~/.local/bin/fd
        fi
        ;;
    dnf)
        echo "INFO: Updating package cache..."
        sudo dnf check-update -q || true
        
        # Convert apt package names to dnf equivalents
        echo "INFO: Installing packages..."
        sudo dnf install -y curl wget git gcc gcc-c++ make stow neovim tmux zsh ripgrep fd-find fzf bat htop jq tree rsync
        ;;
    pacman)
        echo "INFO: Updating package database..."
        sudo pacman -Sy --quiet
        
        # Convert apt package names to pacman equivalents
        echo "INFO: Installing packages..."
        sudo pacman -S --noconfirm --quiet curl wget git base-devel stow neovim tmux zsh ripgrep fd fzf bat htop jq tree rsync
        ;;
esac

# Install mise if not present
if ! command -v mise &> /dev/null; then
    echo "INFO: Installing mise..."
    curl -s https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# Install zoxide if not present
if ! command -v zoxide &> /dev/null; then
    echo "INFO: Installing zoxide..."
    curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

echo "SUCCESS: Linux bootstrap complete!"