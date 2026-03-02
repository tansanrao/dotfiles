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

if brew list --formula rust >/dev/null 2>&1; then
  echo "INFO: Removing Homebrew-managed Rust..."
  brew uninstall rust
else
  echo "INFO: No Homebrew rust formula installed."
fi

if ! command -v rustup >/dev/null 2>&1; then
  echo "INFO: Installing rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --default-toolchain stable --profile default --no-modify-path
else
  echo "INFO: rustup already installed"
fi

if [[ -f "$HOME/.cargo/env" ]]; then
  # shellcheck disable=SC1090
  . "$HOME/.cargo/env"
fi

if ! command -v rustup >/dev/null 2>&1; then
  echo "ERROR: rustup is not available after installation." >&2
  exit 1
fi

echo "INFO: Updating rustup and ensuring stable toolchain is default..."
if ! rustup self update; then
  echo "WARN: rustup self update failed; continuing with toolchain update."
fi
rustup toolchain install stable
rustup default stable

echo "INFO: Installing fnm (Fast Node Manager)..."
FNM_INSTALL_DIR="$HOME/.local/share/fnm"
curl -fsSL https://fnm.vercel.app/install \
  | bash -s -- --skip-shell --install-dir "$FNM_INSTALL_DIR" --force-install
export PATH="$FNM_INSTALL_DIR:$PATH"

if ! command -v fnm >/dev/null 2>&1; then
  echo "ERROR: fnm is not available after installation." >&2
  exit 1
fi

node24_latest="$(
  fnm list-remote | awk '
    /^v24\./ {
      split(substr($1, 2), parts, ".")
      minor = parts[2] + 0
      patch = parts[3] + 0
      if (!seen || minor > best_minor || (minor == best_minor && patch > best_patch)) {
        seen = 1
        best_minor = minor
        best_patch = patch
        best_version = $1
      }
    }
    END {
      if (seen) {
        print best_version
      }
    }
  '
)"
if [[ -z "$node24_latest" ]]; then
  echo "ERROR: Could not resolve latest Node 24 release." >&2
  exit 1
fi

echo "INFO: Installing and setting default Node.js to ${node24_latest}..."
fnm install "$node24_latest"
fnm default "$node24_latest"

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
