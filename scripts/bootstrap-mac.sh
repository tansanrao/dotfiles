#!/usr/bin/env bash
# Bootstrap script for macOS - Install essential tools

set -euo pipefail

echo "INFO: Setting up macOS prerequisites..."

# Install Homebrew if not present
if ! command -v brew &>/dev/null; then
  echo "INFO: Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for this session
  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "INFO: Homebrew already installed"
fi

# Update Homebrew
echo "INFO: Updating Homebrew..."
brew update

# Disable annoying macOS features
echo "INFO: Configuring macOS defaults..."

# Keyboard
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
defaults write -g NSAutomaticCapitalizationEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
defaults write -g NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -g WebAutomaticSpellingCorrectionEnabled -bool false
defaults write -g NSAutomaticInlinePredictionEnabled -bool false
defaults write -g NSAutomaticTextCompletionEnabled -bool false
defaults write -g NSAutomaticTextReplacementEnabled -bool false

# Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Apply Finder changes immediately
killall Finder &>/dev/null || true

echo "SUCCESS: macOS bootstrap complete!"
