#!/usr/bin/env bash
# Bootstrap a Fedora server with required CLI tools.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
fi

if [[ "${ID:-}" != "fedora" ]]; then
  echo "ERROR: This script targets Fedora (ID=fedora)." >&2
  exit 1
fi

echo "INFO: Updating system packages..."
sudo dnf -y upgrade --refresh

echo "INFO: Installing core CLI tools..."
core_packages=(
  curl
  wget
  git
  stow
  neovim
  tmux
  zsh
  ripgrep
  fd-find
  fzf
  bat
  htop
  zoxide
  jq
  yq
  tree
)

sudo dnf -y install "${core_packages[@]}"

echo "INFO: Installing Rust from Fedora repos..."
sudo dnf -y install rust cargo

echo "INFO: Installing fnm (Fast Node Manager)..."
if ! command -v fnm >/dev/null 2>&1; then
  curl -fsSL https://fnm.vercel.app/install | bash
fi

echo "INFO: Installing mise..."
if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.jdx.dev/install.sh | sh
fi

echo "INFO: Stowing dotfiles..."
if command -v stow >/dev/null 2>&1; then
  make -C "$REPO_ROOT" install
else
  echo "WARN: stow not found; skipping dotfile install."
fi

echo "INFO: Installing zsh/tmux plugins..."
bash "$REPO_ROOT/scripts/install-plugins.sh"

echo "SUCCESS: Fedora bootstrap complete."
echo "Next steps:"
echo "1. Start a new zsh session to load config"
echo "2. In tmux, press prefix + I to install tmux plugins"
