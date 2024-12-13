#!/bin/bash

echo "Setting up Tmux environment..."

# Define dotfiles directory
DOTFILES_DIR=$(pwd)

# Install Tmux if not already installed
if ! command -v tmux &>/dev/null; then
    echo "Installing Tmux..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install tmux
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update && sudo apt install -y tmux
    else
        echo "Unsupported OS for Tmux installation"
        exit 1
    fi
else
    echo "Tmux is already installed."
fi

# Install Tmux Plugin Manager (TPM)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    echo "Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
    echo "Tmux Plugin Manager is already installed."
fi

# Symlink Tmux configuration file
echo "Symlinking Tmux configuration..."
ln -sf "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

# Install Tmux plugins
echo "Installing Tmux plugins..."
"$TPM_DIR/bin/install_plugins"  # Install plugins

echo "Tmux setup complete!"

