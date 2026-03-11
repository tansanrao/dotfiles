#!/usr/bin/env bash
# Bootstrap supported Ubuntu hosts for dotfiles usage.

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

if [[ "${VERSION_ID:-}" != 24.04* && "${VERSION_ID:-}" != 25.10* ]]; then
  fatal "bootstrap-ubuntu.sh targets Ubuntu 24.04.x and 25.10 only (detected: ${VERSION_ID:-unknown})"
fi

bootstrap_init "$NO_ROOT" "$DRY_RUN"

if [[ "$NO_ROOT" != "true" ]]; then
  info "Refreshing apt metadata..."
  run_root_cmd env DEBIAN_FRONTEND=noninteractive apt-get update

  info "Installing Ubuntu package set..."
  run_root_cmd env DEBIAN_FRONTEND=noninteractive apt-get -y install \
    ca-certificates curl wget unzip git stow tmux zsh ripgrep fd-find fzf bat htop zoxide eza jq yq tree \
    build-essential pkg-config
else
  info "Skipping root package installation in --no-root mode"
fi

ensure_rustup_toolchain
ensure_node24_latest

if [[ "$NO_ROOT" != "true" ]]; then
  if ! has_cmd fd && ! has_cmd fdfind; then
    if ! ensure_cargo_crate "fd-find" "fd"; then
      fatal "Failed to install fd via cargo"
    fi
  fi

  if ! has_cmd zoxide; then
    if ! ensure_cargo_crate "zoxide" "zoxide"; then
      fatal "Failed to install zoxide via cargo"
    fi
  fi

  if ! has_cmd eza; then
    if ! ensure_cargo_crate "eza" "eza"; then
      fatal "Failed to install eza via cargo"
    fi
  fi

  if ! has_cmd fzf; then
    if ! ensure_fzf_user_binary; then
      fatal "Failed to install fzf user binary"
    fi
  fi
else
  info "Skipping cargo/direct tool installs in --no-root mode"
fi

if [[ "$NO_ROOT" == "true" ]]; then
  install_or_upgrade_neovim_linux user
else
  install_or_upgrade_neovim_linux root
fi

missing=()
for cmd in cargo node npm nvim; do
  if ! has_cmd "$cmd"; then
    missing+=("$cmd")
  fi
done

if [[ "$NO_ROOT" != "true" ]]; then
  for cmd in git zsh tmux eza zoxide fzf; do
    if ! has_cmd "$cmd"; then
      missing+=("$cmd")
    fi
  done
  if ! has_cmd fd && ! has_cmd fdfind; then
    missing+=("fd/fdfind")
  fi
fi

if (( ${#missing[@]} > 0 )); then
  fatal "Ubuntu bootstrap incomplete; missing required command(s): ${missing[*]}"
fi

info "Ubuntu bootstrap complete."
