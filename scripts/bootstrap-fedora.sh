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
  unzip
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

installed_rust_pkgs=()
for pkg in rust cargo; do
  if rpm -q "$pkg" >/dev/null 2>&1; then
    installed_rust_pkgs+=("$pkg")
  fi
done

if (( ${#installed_rust_pkgs[@]} > 0 )); then
  echo "INFO: Removing Fedora-managed Rust packages: ${installed_rust_pkgs[*]}"
  sudo dnf -y remove "${installed_rust_pkgs[@]}"
else
  echo "INFO: No Fedora-managed rust/cargo packages found."
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

echo "INFO: Installing eza with cargo..."
if ! command -v cargo >/dev/null 2>&1; then
  echo "ERROR: cargo is not available for eza installation." >&2
  exit 1
fi
cargo install eza --locked --force

echo "INFO: Installing fnm (Fast Node Manager)..."
FNM_INSTALL_DIR="$HOME/.local/share/fnm"
curl -fsSL https://fnm.vercel.app/install \
  | bash -s -- --skip-shell --install-dir "$FNM_INSTALL_DIR"
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

echo "INFO: Installing mise..."
if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.jdx.dev/install.sh | sh
fi

echo "SUCCESS: Fedora bootstrap complete."
