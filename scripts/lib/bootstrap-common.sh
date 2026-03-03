#!/usr/bin/env bash
# Shared bootstrap helpers for Linux installation scripts.

if [[ -n "${BOOTSTRAP_COMMON_LOADED:-}" ]]; then
  return 0
fi
BOOTSTRAP_COMMON_LOADED=1

BOOTSTRAP_NO_ROOT=false
BOOTSTRAP_DRY_RUN=false
BOOTSTRAP_SUDO_CMD=""

info() {
  printf 'INFO: %s\n' "$1"
}

warn() {
  printf 'WARN: %s\n' "$1"
}

err() {
  printf 'ERROR: %s\n' "$1" >&2
}

fatal() {
  err "$1"
  exit 1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

show_cmd() {
  local cmd=("$@")
  local item
  printf 'INFO: [dry-run]'
  for item in "${cmd[@]}"; do
    printf ' %q' "$item"
  done
  printf '\n'
}

run_cmd() {
  if [[ "$BOOTSTRAP_DRY_RUN" == "true" ]]; then
    show_cmd "$@"
    return 0
  fi
  "$@"
}

run_root_cmd() {
  if [[ "$BOOTSTRAP_NO_ROOT" == "true" ]]; then
    fatal "run_root_cmd called in --no-root mode"
  fi

  if [[ -n "$BOOTSTRAP_SUDO_CMD" ]]; then
    run_cmd "$BOOTSTRAP_SUDO_CMD" "$@"
    return
  fi

  run_cmd "$@"
}

run_shell() {
  local snippet="$1"
  if [[ "$BOOTSTRAP_DRY_RUN" == "true" ]]; then
    info "[dry-run] bash -lc $(printf %q "$snippet")"
    return 0
  fi
  bash -lc "$snippet"
}

run_root_shell() {
  local snippet="$1"
  if [[ "$BOOTSTRAP_NO_ROOT" == "true" ]]; then
    fatal "run_root_shell called in --no-root mode"
  fi

  if [[ "$BOOTSTRAP_DRY_RUN" == "true" ]]; then
    info "[dry-run] root bash -lc $(printf %q "$snippet")"
    return 0
  fi

  if [[ -n "$BOOTSTRAP_SUDO_CMD" ]]; then
    "$BOOTSTRAP_SUDO_CMD" bash -lc "$snippet"
    return
  fi

  bash -lc "$snippet"
}

semver_ge() {
  local a="${1#v}"
  local b="${2#v}"
  [[ "$(printf '%s\n%s\n' "$b" "$a" | sort -V | tail -n1)" == "$a" ]]
}

ensure_local_path() {
  export PATH="$HOME/.local/bin:$PATH"
}

bootstrap_init() {
  local no_root="$1"
  local dry_run="$2"

  BOOTSTRAP_NO_ROOT="$no_root"
  BOOTSTRAP_DRY_RUN="$dry_run"
  BOOTSTRAP_SUDO_CMD=""

  ensure_local_path

  if [[ "$BOOTSTRAP_NO_ROOT" == "true" ]]; then
    info "Bootstrap mode: user-space (--no-root)"
    return
  fi

  if [[ "$EUID" -eq 0 ]]; then
    info "Bootstrap mode: privileged (root)"
    return
  fi

  if has_cmd sudo; then
    if sudo -n true >/dev/null 2>&1; then
      BOOTSTRAP_SUDO_CMD="sudo"
      info "Bootstrap mode: privileged (sudo)"
      return
    fi

    if [[ -t 0 && -t 1 ]]; then
      BOOTSTRAP_SUDO_CMD="sudo"
      info "Bootstrap mode: privileged (sudo, password may be required)"
      return
    fi

    fatal "No usable root or sudo privileges detected in this non-interactive session. Re-run with --no-root for user-space bootstrap."
  fi

  fatal "No root or sudo privileges detected. Re-run with --no-root for user-space bootstrap."
}

ensure_cargo_env() {
  if [[ -f "$HOME/.cargo/env" ]]; then
    # shellcheck disable=SC1090
    . "$HOME/.cargo/env"
  fi
}

fetch_url_stdout() {
  local url="$1"
  if has_cmd curl; then
    curl -fsSL "$url"
    return
  fi
  if has_cmd wget; then
    wget -qO- "$url"
    return
  fi
  fatal "Neither curl nor wget is available to fetch: $url"
}

try_download_file() {
  local url="$1"
  local dest="$2"

  if [[ "$BOOTSTRAP_DRY_RUN" == "true" ]]; then
    info "[dry-run] download $url -> $dest"
    return 0
  fi

  if has_cmd curl; then
    curl -fL --retry 3 --retry-delay 1 -o "$dest" "$url"
    return $?
  fi

  if has_cmd wget; then
    wget -O "$dest" "$url"
    return $?
  fi

  return 1
}

download_file() {
  local url="$1"
  local dest="$2"

  if ! try_download_file "$url" "$dest"; then
    fatal "Failed to download: $url"
  fi
}

ensure_rustup_toolchain() {
  if ! has_cmd rustup; then
    info "Installing rustup..."
    if has_cmd curl; then
      run_shell "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile default --no-modify-path"
    elif has_cmd wget; then
      run_shell "wget -qO- https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile default --no-modify-path"
    else
      fatal "rustup install requires curl or wget"
    fi
  else
    info "rustup already installed"
  fi

  ensure_cargo_env

  if ! has_cmd rustup; then
    fatal "rustup is not available after installation"
  fi

  if [[ "$BOOTSTRAP_DRY_RUN" == "true" ]]; then
    info "[dry-run] rustup self update"
    info "[dry-run] rustup toolchain install stable"
    info "[dry-run] rustup default stable"
    return
  fi

  if ! rustup self update; then
    warn "rustup self update failed; continuing"
  fi

  rustup toolchain install stable
  rustup default stable
}

ensure_fnm() {
  local fnm_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fnm"

  if ! has_cmd fnm; then
    info "Installing fnm..."
    if has_cmd curl; then
      run_shell "curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell --install-dir '$fnm_dir' --force-install"
    elif has_cmd wget; then
      run_shell "wget -qO- https://fnm.vercel.app/install | bash -s -- --skip-shell --install-dir '$fnm_dir' --force-install"
    else
      return 1
    fi
  fi

  export PATH="$fnm_dir:$PATH"

  if ! has_cmd fnm; then
    return 1
  fi

  return 0
}

resolve_latest_node24() {
  local version
  version="$(fetch_url_stdout "https://nodejs.org/dist/index.json" | awk -F'"' '
    /"version":/ {v=$4}
    /"lts":/ {
      if ($4 != "false" && v ~ /^v24\./) {
        print v
        exit
      }
    }
  ')"

  if [[ -z "$version" ]]; then
    return 1
  fi

  printf '%s\n' "$version"
}

expose_node_binaries() {
  local local_bin="$HOME/.local/bin"
  local binary target

  mkdir -p "$local_bin"
  for binary in node npm npx corepack; do
    if has_cmd "$binary"; then
      target="$(command -v "$binary")"
      ln -sfn "$target" "$local_bin/$binary"
    fi
  done
}

ensure_node24_latest() {
  if ! ensure_fnm; then
    fatal "fnm is unavailable after installation attempt"
  fi

  if [[ "$BOOTSTRAP_DRY_RUN" == "true" ]]; then
    info "[dry-run] fnm install <latest-v24.x>"
    info "[dry-run] fnm default <latest-v24.x>"
    info "[dry-run] expose node/npm/npx/corepack under \$HOME/.local/bin"
    return
  fi

  local node24
  if ! node24="$(resolve_latest_node24)"; then
    fatal "Could not resolve latest Node 24 release"
  fi

  info "Installing Node.js 24: $node24"
  fnm install "$node24"
  fnm default "$node24"

  if ! eval "$(fnm env --shell bash)"; then
    fatal "Could not activate fnm environment in current shell"
  fi

  expose_node_binaries
}

ensure_cargo_crate() {
  local crate="$1"
  local binary="$2"

  ensure_cargo_env
  if ! has_cmd cargo; then
    warn "cargo is unavailable; cannot install crate: $crate"
    return 1
  fi

  if [[ "$BOOTSTRAP_DRY_RUN" == "true" ]]; then
    info "[dry-run] cargo install $crate --locked --force"
    return
  fi

  if has_cmd "$binary"; then
    info "Updating cargo crate: $crate"
  else
    info "Installing cargo crate: $crate"
  fi

  if ! cargo install "$crate" --locked --force; then
    warn "cargo install failed for crate: $crate"
    return 1
  fi

  return 0
}

ensure_fzf_user_binary() {
  if has_cmd fzf; then
    return 0
  fi

  local arch
  case "$(uname -m)" in
    x86_64) arch="amd64" ;;
    aarch64|arm64) arch="arm64" ;;
    *)
      warn "Unsupported architecture for fzf user binary install: $(uname -m)"
      return 1
      ;;
  esac

  local tag asset tmpdir
  if [[ "$BOOTSTRAP_DRY_RUN" == "true" ]]; then
    info "[dry-run] install fzf user binary for arch: $arch"
    return 0
  fi

  tag="$(fetch_url_stdout "https://api.github.com/repos/junegunn/fzf/releases/latest" | awk -F'"' '
    /"tag_name":/ {
      if (tag == "") {
        tag = $4
      }
    }
    END {
      if (tag != "") {
        print tag
      }
    }
  ')"

  if [[ -z "$tag" ]]; then
    warn "Could not resolve latest fzf release tag"
    return 1
  fi

  asset="fzf-${tag#v}-linux_${arch}.tar.gz"
  tmpdir="$(mktemp -d)"

  download_file "https://github.com/junegunn/fzf/releases/download/$tag/$asset" "$tmpdir/$asset"
  run_cmd mkdir -p "$HOME/.local/bin"

  if ! tar -xzf "$tmpdir/$asset" -C "$HOME/.local/bin" fzf; then
    rm -rf "$tmpdir"
    warn "Failed to extract fzf user binary"
    return 1
  fi

  rm -rf "$tmpdir"
  info "Installed fzf user binary to $HOME/.local/bin/fzf"
  return 0
}
