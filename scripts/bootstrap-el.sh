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

  if has_cmd crb; then
    if ! run_root_cmd crb enable; then
      warn "Failed to enable CRB with 'crb enable'; continuing"
    fi
  else
    dnf_install_if_available dnf-plugins-core
    if ! run_root_cmd dnf config-manager --set-enabled crb; then
      warn "Failed to enable CRB via dnf config-manager; continuing"
    fi
  fi

  epel_rpm="https://dl.fedoraproject.org/pub/epel/epel-release-latest-${major}.noarch.rpm"
  if ! run_root_cmd dnf -y install "$epel_rpm"; then
    warn "Failed to install EPEL release package: $epel_rpm"
  fi

  run_root_cmd dnf -y makecache --refresh || true

  dnf_install_if_available \
    curl-minimal wget unzip git stow tmux zsh ripgrep fd-find fzf bat htop jq yq tree zoxide eza \
    gcc make pkgconf-pkg-config perl-File-Copy

  if ! has_cmd stow; then
    warn "GNU stow package is unavailable on this host; attempting source install."
    if ! ensure_gnu_stow; then
      warn "GNU stow source install failed. Use --allow-link-fallback with install.sh if needed."
    fi
  fi
else
  warn "Skipping dnf package installation in --no-root mode"
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
  if [[ "$NO_ROOT" != "true" ]] && dnf_has_package zoxide; then
    dnf_install_if_available zoxide
  fi
  if ! has_cmd zoxide; then
    if ! ensure_cargo_crate "zoxide" "zoxide"; then
      warn "Could not install zoxide via cargo"
    fi
  fi
fi

if ! has_cmd eza; then
  if [[ "$NO_ROOT" != "true" ]] && dnf_has_package eza; then
    dnf_install_if_available eza
  fi
  if ! has_cmd eza; then
    if ! ensure_cargo_crate "eza" "eza"; then
      warn "Could not install eza via cargo"
    fi
  fi
fi

if ! has_cmd fzf; then
  if [[ "$NO_ROOT" != "true" ]] && dnf_has_package fzf; then
    dnf_install_if_available fzf
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

info "EL bootstrap complete for ${ID:-unknown} ${VERSION_ID:-unknown}."
