#!/bin/bash

echo "Setting up macOS environment..."

# Install Xcode Command Line Tools
xcode-select --install

# Run Homebrew setup
./scripts/brew.sh

# Setup TMUX
./scripts/tmux.sh

# Setup ZSH
./scripts/zsh.sh

# Setup Vim
./scripts/vim.sh

# Setup Alacritty
./scripts/alacritty.sh

# Set reasonable macOS defaults.
#
# The settings are based on:
#   https://github.com/holman/dotfiles/blob/master/macos/set-defaults.sh

# Disable press-and-hold for keys in favor of key repeat.
defaults write -g ApplePressAndHoldEnabled -bool false

# Use AirDrop over every interface.
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1

# Always open everything in Finder's list view.
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Show the ~/Library folder.
chflags nohidden ~/Library

# Set a really fast key repeat.
defaults write NSGlobalDomain KeyRepeat -int 1

# Set the Finder prefs for showing a few different volumes on the Desktop.
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true


echo "mac defaults setup complete."
