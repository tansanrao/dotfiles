#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Setting up Vim environment..."

# Define the directory where this script is located (dotfiles repository)
DOTFILES_DIR=$(pwd)

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Install Vim if not installed
if ! command_exists vim; then
    echo "Vim not found. Installing Vim..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install vim
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update
        sudo apt install -y vim
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
else
    echo "Vim is already installed."
fi

# 2. Symlink .vimrc
echo "Symlinking .vimrc..."
ln -sf "$DOTFILES_DIR/vimrc" "$HOME/.vimrc"


# 4. Install vim-plug (Vim Plugin Manager) if not installed
PLUG_VIM="$HOME/.vim/autoload/plug.vim"
if [[ ! -f "$PLUG_VIM" ]]; then
    echo "Installing vim-plug..."
    curl -fLo "$PLUG_VIM" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "vim-plug installed successfully."
else
    echo "vim-plug is already installed."
fi

# 5. Install Vim plugins defined in .vimrc
echo "Installing Vim plugins..."
vim +PlugInstall +qall
echo "Vim plugins installed successfully."

echo "Vim setup complete!"

