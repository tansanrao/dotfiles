#!/bin/zsh

# Install homebrew
zsh -c homebrew/install.zsh

# Install brew dependencies
cd homebrew
brew bundle
echo 'homebrew setup complete.'

# Setup zsh
cd ..
zsh -c zsh/init.zsh

# Set default settings
zsh -c mac/set-defaults.zsh

# Install atuin
zsh -c atuin/init.zsh

# Setup vim
zsh -c vim/init.zsh
