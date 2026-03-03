#!/usr/bin/env bash
# Neovim installation helpers for Linux hosts.

if [[ -n "${BOOTSTRAP_NEOVIM_LOADED:-}" ]]; then
  return 0
fi
BOOTSTRAP_NEOVIM_LOADED=1

LAZYVIM_MIN_NVIM_VERSION="0.11.2"
NVIM_TARGET_VERSION="${NVIM_TARGET_VERSION:-0.11.6}"

current_nvim_version() {
  if ! has_cmd nvim; then
    return 1
  fi

  nvim --version 2>/dev/null | awk 'NR==1 {sub(/^v/, "", $2); print $2}'
}

nvim_asset_arch() {
  case "$(uname -m)" in
    x86_64) printf 'x86_64\n' ;;
    aarch64|arm64) printf 'arm64\n' ;;
    *)
      return 1
      ;;
  esac
}

verify_sha256() {
  local file="$1"
  local checksum_file="$2"

  if has_cmd sha256sum; then
    (cd "$(dirname "$file")" && sha256sum -c "$(basename "$checksum_file")")
    return
  fi

  if has_cmd shasum; then
    local expected actual
    expected="$(awk '{print $1}' "$checksum_file")"
    actual="$(shasum -a 256 "$file" | awk '{print $1}')"
    if [[ "$expected" != "$actual" ]]; then
      return 1
    fi
    return
  fi

  warn "No checksum utility found (sha256sum/shasum). Skipping checksum verification."
}

install_or_upgrade_neovim_linux() {
  local install_mode="$1" # root|user

  if [[ "$(uname -s)" != "Linux" ]]; then
    fatal "install_or_upgrade_neovim_linux only supports Linux"
  fi

  local arch
  if ! arch="$(nvim_asset_arch)"; then
    fatal "Unsupported architecture for Neovim binaries: $(uname -m)"
  fi

  local current_version=""
  if current_version="$(current_nvim_version 2>/dev/null)"; then
    if semver_ge "$current_version" "$NVIM_TARGET_VERSION"; then
      info "Neovim $current_version already satisfies target >= $NVIM_TARGET_VERSION"
      return
    fi
  fi

  local archive="nvim-linux-${arch}.tar.gz"
  local checksum_file="${archive}.sha256sum"
  local release_tag="v${NVIM_TARGET_VERSION}"
  local base_url="https://github.com/neovim/neovim/releases/download/${release_tag}"
  local tmpdir=""
  tmpdir="$(mktemp -d)"

  if [[ "$BOOTSTRAP_DRY_RUN" == "true" ]]; then
    info "[dry-run] install Neovim $NVIM_TARGET_VERSION ($archive) in mode: $install_mode"
    rm -rf "$tmpdir"
    return
  fi

  download_file "$base_url/$archive" "$tmpdir/$archive"

  if try_download_file "$base_url/$checksum_file" "$tmpdir/$checksum_file"; then
    if ! verify_sha256 "$tmpdir/$archive" "$tmpdir/$checksum_file"; then
      rm -rf "$tmpdir"
      fatal "Checksum verification failed for $archive"
    fi
  else
    warn "Checksum sidecar not available for $archive; continuing without checksum verification."
  fi

  tar -xzf "$tmpdir/$archive" -C "$tmpdir"

  local source_dir="$tmpdir/nvim-linux-${arch}"
  if [[ ! -d "$source_dir" ]]; then
    rm -rf "$tmpdir"
    fatal "Unexpected Neovim archive layout: missing $source_dir"
  fi

  local prefix install_dir bin_link
  if [[ "$install_mode" == "root" ]]; then
    prefix="/usr/local"
  else
    prefix="$HOME/.local"
  fi

  install_dir="$prefix/opt/nvim-$NVIM_TARGET_VERSION"
  bin_link="$prefix/bin/nvim"

  if [[ "$install_mode" == "root" ]]; then
    run_root_cmd mkdir -p "$prefix/opt" "$prefix/bin"
    run_root_cmd rm -rf "$install_dir"
    run_root_cmd mkdir -p "$install_dir"
    run_root_cmd cp -a "$source_dir/." "$install_dir/"
    run_root_cmd ln -sfn "$install_dir/bin/nvim" "$bin_link"
  else
    run_cmd mkdir -p "$prefix/opt" "$prefix/bin"
    run_cmd rm -rf "$install_dir"
    run_cmd mkdir -p "$install_dir"
    run_cmd cp -a "$source_dir/." "$install_dir/"
    run_cmd ln -sfn "$install_dir/bin/nvim" "$bin_link"
    export PATH="$prefix/bin:$PATH"
  fi

  rm -rf "$tmpdir"

  local installed_version=""
  if installed_version="$(current_nvim_version 2>/dev/null)"; then
    if semver_ge "$installed_version" "$LAZYVIM_MIN_NVIM_VERSION"; then
      info "Neovim ready: $installed_version (LazyVim minimum: $LAZYVIM_MIN_NVIM_VERSION)"
      return
    fi
  fi

  fatal "Installed Neovim does not satisfy LazyVim minimum version $LAZYVIM_MIN_NVIM_VERSION"
}
