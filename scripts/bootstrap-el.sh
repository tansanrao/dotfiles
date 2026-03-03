#!/usr/bin/env bash
# Bootstrap Rocky Linux / CentOS Stream hosts.

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
Usage: scripts/bootstrap-el.sh [--no-root] [--dry-run]
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

case "${ID:-}" in
  rocky|centos)
    ;;
  *)
    fatal "bootstrap-el.sh supports rocky/centos IDs only (detected: ${ID:-unknown})"
    ;;
esac

major="${VERSION_ID%%.*}"
if [[ "$major" != "9" && "$major" != "10" ]]; then
  fatal "bootstrap-el.sh supports major versions 9 and 10 (detected: ${VERSION_ID:-unknown})"
fi

bootstrap_init "$NO_ROOT" "$DRY_RUN"

if [[ "$NO_ROOT" != "true" ]]; then
  info "Refreshing DNF metadata..."
  run_root_cmd dnf -y makecache --refresh

  if ! has_cmd crb; then
    run_root_cmd dnf -y install dnf-plugins-core
  fi

  if has_cmd crb; then
    run_root_cmd crb enable
  else
    run_root_cmd dnf config-manager --set-enabled crb
  fi

  epel_rpm="https://dl.fedoraproject.org/pub/epel/epel-release-latest-${major}.noarch.rpm"
  run_root_cmd dnf -y install "$epel_rpm"
  run_root_cmd dnf -y makecache --refresh

  if [[ "$major" == "9" ]]; then
    info "Installing EL9 package set..."
    run_root_cmd dnf -y install \
      curl wget unzip git stow tmux zsh ripgrep fd-find fzf bat htop jq yq tree zoxide \
      gcc make pkgconf-pkg-config perl-File-Copy
  else
    info "Installing EL10 package set..."
    run_root_cmd dnf -y install \
      curl wget unzip git tmux zsh ripgrep fd-find fzf bat htop jq yq tree \
      gcc make pkgconf-pkg-config perl-File-Copy
  fi
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
  fatal "EL bootstrap incomplete; missing required command(s): ${missing[*]}"
fi

info "EL bootstrap complete for ${ID:-unknown} ${VERSION_ID:-unknown}."
