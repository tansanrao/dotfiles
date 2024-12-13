#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up Alacritty environment..."

# Define the directory where this script is located (dotfiles repository)
DOTFILES_DIR=$(pwd)

# Define Alacritty configuration directory
ALACRITTY_CONFIG_DIR="$HOME/.config/alacritty"

# 1. Create Alacritty configuration directory
if [[ ! -d "$ALACRITTY_CONFIG_DIR" ]]; then
    echo "Creating Alacritty configuration directory..."
    mkdir -p "$ALACRITTY_CONFIG_DIR"
else
    echo "Alacritty configuration directory already exists."
fi

# 2. Clone Catppuccin themes if not already cloned
CATPPUCCIN_REPO_DIR="$ALACRITTY_CONFIG_DIR/catppuccin"
if [[ ! -d "$CATPPUCCIN_REPO_DIR" ]]; then
    echo "Cloning Catppuccin themes..."
    git clone https://github.com/catppuccin/alacritty.git "$CATPPUCCIN_REPO_DIR"
else
    echo "Catppuccin themes already cloned."
fi

# 3. Symlink alacritty.toml
echo "Symlinking alacritty.toml..."
ln -sf "$DOTFILES_DIR/alacritty.toml" "$ALACRITTY_CONFIG_DIR/alacritty.toml"

echo "Alacritty setup complete! Enjoy your new terminal themes."

