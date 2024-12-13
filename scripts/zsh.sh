#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up Zsh environment..."

# 1. Define dotfiles directory
DOTFILES_DIR=$(pwd)

# 2. Install Pure Prompt if not installed
PURE_PROMPT_DIR="$HOME/.zsh/pure"

if [[ ! -d "$PURE_PROMPT_DIR" ]]; then
    echo "Pure Prompt not found. Installing Pure Prompt..."
    mkdir -p "$HOME/.zsh"
    git clone https://github.com/sindresorhus/pure.git "$PURE_PROMPT_DIR"
else
    echo "Pure Prompt is already installed."
fi

# 3. Symlink .zshrc
echo "Symlinking .zshrc..."
ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"

# 4. Symlink aliases.zsh
echo "Symlinking aliases.zsh..."
# Ensure the aliases directory exists if you have one
ALIASES_DIR="$HOME/.zsh"
mkdir -p "$ALIASES_DIR"
ln -sf "$DOTFILES_DIR/aliases.zsh" "$ALIASES_DIR/aliases.zsh"

echo "Zsh setup complete!"
