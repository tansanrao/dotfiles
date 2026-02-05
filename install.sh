#!/usr/bin/env bash
# Install dotfiles and bootstrap tools based on host OS.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$REPO_ROOT/stow"
TARGET_DIR="${HOME}"

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
fi

run_bootstrap() {
  case "$(uname -s)" in
    Darwin)
      echo "INFO: Bootstrapping macOS..."
      zsh "$REPO_ROOT/scripts/bootstrap-mac.sh"
      if command -v brew >/dev/null 2>&1; then
        brew bundle --file="$REPO_ROOT/Brewfile"
      else
        echo "WARN: Homebrew not available; skipping Brewfile."
      fi
      ;;
    Linux)
      case "${ID:-}" in
        fedora)
          echo "INFO: Bootstrapping Fedora..."
          bash "$REPO_ROOT/scripts/bootstrap-fedora.sh"
          ;;
        rhel|rocky|centos)
          echo "INFO: Bootstrapping RHEL 10 family..."
          bash "$REPO_ROOT/scripts/bootstrap-rhel10.sh"
          ;;
        *)
          echo "ERROR: Unsupported Linux distro ID: ${ID:-unknown}" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "ERROR: Unsupported OS: $(uname -s)" >&2
      exit 1
      ;;
  esac
}

stow_all() {
  if ! command -v stow >/dev/null 2>&1; then
    echo "WARN: stow not found; skipping dotfile install."
    return
  fi
  if [[ ! -d "$STOW_DIR" ]]; then
    echo "ERROR: stow directory not found at $STOW_DIR" >&2
    exit 1
  fi
  mkdir -p "$TARGET_DIR"
  for pkg in "$STOW_DIR"/*; do
    [[ -d "$pkg" ]] || continue
    pkg_name="$(basename "$pkg")"
    echo "==> Stowing $pkg_name into $TARGET_DIR"
    stow --verbose=2 --dir="$STOW_DIR" --target="$TARGET_DIR" "$pkg_name"
  done
}

run_bootstrap
stow_all

echo "INFO: Installing zsh/tmux plugins..."
bash "$REPO_ROOT/scripts/install-plugins.sh"

echo "SUCCESS: Install complete."
echo "Next steps:"
echo "1. Start a new zsh session to load config"
echo "2. In tmux, press prefix + I to install tmux plugins"
