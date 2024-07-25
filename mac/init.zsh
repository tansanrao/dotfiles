#!/bin/zsh

# Function to prompt for sudo and keep it alive
keep_sudo_alive() {
  while true; do
    sudo -v
    sleep 50
    kill -0 "$$" || exit
  done &
}

# Prompt for sudo access initially
sudo -v

# Start the background process to keep sudo alive
keep_sudo_alive

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

# Setup tmux
zsh -c tmux/init.zsh

# Setup taskfile
zsh -c task/init.zsh
