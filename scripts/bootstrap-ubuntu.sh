#!/usr/bin/env bash
# Bootstrap Ubuntu 24.04 hosts for dotfiles usage.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# shellcheck source=scripts/lib/bootstrap-common.sh
. "$REPO_ROOT/scripts/lib/bootstrap-common.sh"
# shellcheck source=scripts/lib/neovim.sh
. "$REPO_ROOT/scripts/lib/neovim.sh"

NO_ROOT=false
DRY_RUN=false

while (( "$#" > 0 )); do
  case "$1" in
    --no-root)
      NO_ROOT=true
      ;;
    --dry-run)
      DRY_RUN=true
      ;;
    -h|--help)
      cat <<'USAGE'
Usage: scripts/bootstrap-ubuntu.sh [--no-root] [--dry-run]
USAGE
      exit 0
      ;;
    *)
      fatal "Unknown argument: $1"
      ;;
  esac
  shift
done

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
fi

if [[ "${ID:-}" != "ubuntu" ]]; then
  fatal "bootstrap-ubuntu.sh targets Ubuntu only (detected: ${ID:-unknown})"
fi

if [[ "${VERSION_ID:-}" != 24.04* ]]; then
  fatal "bootstrap-ubuntu.sh targets Ubuntu 24.04.x only (detected: ${VERSION_ID:-unknown})"
fi

bootstrap_init "$NO_ROOT" "$DRY_RUN"

if [[ "$NO_ROOT" != "true" ]]; then
  info "Refreshing apt metadata..."
  run_root_cmd env DEBIAN_FRONTEND=noninteractive apt-get update

  apt_install_if_available \
    ca-certificates curl wget unzip git stow tmux zsh ripgrep fd-find fzf bat htop zoxide eza jq yq tree \
    build-essential pkg-config
else
  warn "Skipping apt package installation in --no-root mode"
fi

ensure_rustup_toolchain
if ! ensure_node_lts; then
  warn "Node/npm setup skipped because fnm is unavailable."
fi

if ! has_cmd fd && ! has_cmd fdfind; then
  if ! ensure_cargo_crate "fd-find" "fd"; then
    warn "Could not install fd via cargo"
  fi
fi

if ! has_cmd zoxide; then
  if [[ "$NO_ROOT" != "true" ]] && apt_has_package zoxide; then
    apt_install_if_available zoxide
  fi
  if ! has_cmd zoxide; then
    if ! ensure_cargo_crate "zoxide" "zoxide"; then
      warn "Could not install zoxide via cargo"
    fi
  fi
fi

if ! has_cmd eza; then
  if [[ "$NO_ROOT" != "true" ]] && apt_has_package eza; then
    apt_install_if_available eza
  fi
  if ! has_cmd eza; then
    if ! ensure_cargo_crate "eza" "eza"; then
      warn "Could not install eza via cargo"
    fi
  fi
fi

if ! has_cmd fzf; then
  if [[ "$NO_ROOT" != "true" ]] && apt_has_package fzf; then
    apt_install_if_available fzf
  fi
  if ! has_cmd fzf; then
    ensure_fzf_user_binary
  fi
fi

if [[ "$NO_ROOT" == "true" ]]; then
  if ! has_cmd zsh; then
    warn "zsh is not installed and cannot be auto-installed in --no-root mode"
  fi
  if ! has_cmd tmux; then
    warn "tmux is not installed and cannot be auto-installed in --no-root mode"
  fi
fi

if [[ "$NO_ROOT" == "true" ]]; then
  install_or_upgrade_neovim_linux user
else
  install_or_upgrade_neovim_linux root
fi

info "Ubuntu bootstrap complete."
