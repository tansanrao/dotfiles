#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
brewfile="$repo_root/Brewfile"

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

load_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    return 0
  fi

  if [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
    return 0
  fi

  echo "Homebrew was installed, but brew was not found on PATH." >&2
  return 1
}

install_homebrew
load_homebrew

echo "Updating Homebrew..."
brew update

echo "Installing macOS packages from $brewfile..."
brew bundle install --file "$brewfile"
