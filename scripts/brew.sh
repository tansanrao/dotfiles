#!/bin/bash

echo "Installing Homebrew and packages..."

# Install Homebrew if not already installed
if ! command -v brew &>/dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install packages
brew bundle

echo "Homebrew setup complete!"

