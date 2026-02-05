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

echo "SUCCESS: macOS bootstrap complete!"
