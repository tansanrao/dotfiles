#!/usr/bin/env bash
# Bootstrap script for Ubuntu/Debian - Install essential tools and packages

set -euo pipefail

echo "INFO: Setting up Ubuntu/Debian prerequisites..."

# Verify we're on a Debian-based system
if ! command -v apt &> /dev/null; then
    echo "ERROR: This script is for Ubuntu/Debian systems only (apt not found)"
    exit 1
fi

# Update package lists
echo "INFO: Updating package lists..."
sudo apt update -qq

# Install snapd if not present
if ! command -v snap &> /dev/null; then
    echo "INFO: Installing snapd..."
    sudo apt install -y snapd
    sudo systemctl enable --now snapd.socket
    sudo ln -sf /var/lib/snapd/snap /snap 2>/dev/null || true
    export PATH="/snap/bin:$PATH"
fi

# Install packages from apt-packages.txt
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

# Install snap packages
if [[ -f "packages/snap-packages.txt" ]]; then
    echo "INFO: Installing snap packages..."
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        
        # Parse package line - split into array
        read -ra parts <<< "$line"
        package="${parts[0]}"
        
        if [[ -n "$package" ]]; then
            # Check if already installed
            if snap list "$package" &>/dev/null; then
                echo "INFO: $package already installed via snap"
            else
                echo "INFO: Installing $package via snap..."
                # Install with all remaining arguments as flags
                sudo snap install "${parts[@]}"
            fi
        fi
    done < packages/snap-packages.txt
    
    # Create alias for nvim -> neovim if needed
    if snap list nvim &>/dev/null && ! command -v neovim &> /dev/null; then
        sudo snap alias nvim neovim 2>/dev/null || true
    fi
fi

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

echo "SUCCESS: Ubuntu/Debian bootstrap complete!"