#!/usr/bin/env bash
# Bootstrap CentOS Stream / Rocky / RHEL 10 with required CLI tools.

set -euo pipefail

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
fi

is_supported_id=false
case "${ID:-}" in
  rhel|rocky|centos)
    is_supported_id=true
    ;;
esac

if [[ "$is_supported_id" != true ]]; then
  echo "ERROR: This script targets CentOS Stream, Rocky, or RHEL (ID=rhel|rocky|centos)." >&2
  exit 1
fi

if [[ "${VERSION_ID:-}" != 10* ]]; then
  echo "ERROR: This script targets major version 10.x (VERSION_ID=10*)." >&2
  exit 1
fi

echo "INFO: Updating system packages..."
sudo dnf -y upgrade --refresh

echo "INFO: Enabling CRB (best-effort)..."
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --set-enabled crb || true
if command -v crb >/dev/null 2>&1; then
  sudo crb enable || true
fi

echo "INFO: Enabling EPEL (best-effort)..."
if ! rpm -q epel-release >/dev/null 2>&1; then
  if ! sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm; then
    echo "WARN: Failed to install EPEL release package."
  fi
fi

echo "INFO: Installing core CLI tools..."
core_packages=(
  curl
  wget
  git
  neovim
  tmux
  zsh
  ripgrep
  fd-find
  fzf
  bat
  htop
  jq
  yq
  tree
)

sudo dnf -y install "${core_packages[@]}"

echo "INFO: Installing Rust from distro repos..."
sudo dnf -y install rust cargo

echo "INFO: Installing zoxide via cargo..."
if command -v cargo >/dev/null 2>&1; then
  cargo install zoxide
else
  echo "WARN: cargo not available; skipping zoxide install."
fi

echo "INFO: Installing stow from source..."
sudo dnf -y install perl perl-CPAN perl-ExtUtils-MakeMaker gcc make || true
tmp_dir="$(mktemp -d)"
stow_version="2.4.0"
curl -fsSL "https://ftp.gnu.org/gnu/stow/stow-${stow_version}.tar.gz" -o "$tmp_dir/stow.tar.gz"
tar -xzf "$tmp_dir/stow.tar.gz" -C "$tmp_dir"
(
  cd "$tmp_dir/stow-${stow_version}"
  ./configure --prefix="$HOME/.local"
  make
  make install
)
rm -rf "$tmp_dir"
if ! command -v stow >/dev/null 2>&1; then
  echo "WARN: stow install failed; ensure ~/.local/bin is on PATH."
fi

echo "INFO: Installing fnm (Fast Node Manager)..."
if ! command -v fnm >/dev/null 2>&1; then
  curl -fsSL https://fnm.vercel.app/install | bash
fi

echo "INFO: Installing mise..."
if ! command -v mise >/dev/null 2>&1; then
  curl -fsSL https://mise.jdx.dev/install.sh | sh
fi

echo "SUCCESS: RHEL 10 family bootstrap complete."
