#!/usr/bin/env bash
# Dotfiles installer for macOS and Ubuntu 24+.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$REPO_ROOT/stow"
TARGET_DIR="$HOME"

SKIP_PLUGINS=false
DRY_RUN=false
ONLY_COMPONENTS=""
LINUX_PRIVILEGED=false

ALL_COMPONENTS=(git zsh tmux neovim ghostty)
LINUX_COMPONENTS=(git zsh tmux neovim)
MAC_COMPONENTS=(git zsh tmux neovim ghostty)
SELECTED_COMPONENTS=()
SKIPPED_COMPONENTS=()

info() {
  printf 'INFO: %s\n' "$1"
}

warn() {
  printf 'WARN: %s\n' "$1"
}

err() {
  printf 'ERROR: %s\n' "$1" >&2
}

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options]

Default behavior:
  - Detect host OS and run the matching bootstrap script
  - macOS uses the existing Homebrew bootstrap flow
  - Ubuntu 24+ installs packages/toolchains only with root or sudo
  - Ubuntu without root/sudo links dotfiles only

Options:
  --only a,b,c           Limit component install to a CSV subset
  --skip-plugins         Skip plugin dependency install/update
  --dry-run              Print planned actions without changing files
  -h, --help             Show this help message

Components:
  macOS: git, zsh, tmux, neovim, ghostty
  Ubuntu: git, zsh, tmux, neovim
USAGE
}

component_command() {
  case "$1" in
    git) echo "git" ;;
    zsh) echo "zsh" ;;
    tmux) echo "tmux" ;;
    neovim) echo "nvim" ;;
    ghostty) echo "ghostty" ;;
    *) return 1 ;;
  esac
}

component_is_known() {
  local component="$1"
  local candidate
  for candidate in "${ALL_COMPONENTS[@]}"; do
    if [[ "$candidate" == "$component" ]]; then
      return 0
    fi
  done
  return 1
}

array_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "$item" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

join_by_comma() {
  local IFS=","
  printf '%s' "$*"
}

refresh_user_tool_path() {
  local fnm_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fnm"
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$fnm_dir:$PATH"
}

host_supported_components() {
  case "$(uname -s)" in
    Darwin)
      printf '%s\n' "${MAC_COMPONENTS[@]}"
      ;;
    Linux)
      printf '%s\n' "${LINUX_COMPONENTS[@]}"
      ;;
    *)
      return 1
      ;;
  esac
}

stow_ignore_regex_for_component() {
  case "$1" in
    zsh)
      echo '(^|/)\.config/zsh/(pure|zsh-syntax-highlighting|\.zcompdump|\.zsh_history)(/|$)'
      ;;
    tmux)
      echo '(^|/)\.config/tmux/plugins(/|$)'
      ;;
    *)
      echo ""
      ;;
  esac
}

parse_args() {
  while (( "$#" > 0 )); do
    case "$1" in
      --skip-plugins)
        SKIP_PLUGINS=true
        ;;
      --dry-run)
        DRY_RUN=true
        ;;
      --only)
        if (( "$#" < 2 )); then
          err "--only requires a CSV value"
          exit 1
        fi
        ONLY_COMPONENTS="$2"
        shift
        ;;
      --only=*)
        ONLY_COMPONENTS="${1#*=}"
        ;;
      --bootstrap)
        err "--bootstrap has been removed. Bootstrap is now default behavior."
        exit 1
        ;;
      --no-root|--no-stow|--allow-link-fallback)
        err "$1 is no longer supported. Ubuntu privilege and stow fallback modes are detected automatically."
        exit 1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        err "Unknown argument: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

linux_has_root() {
  [[ "$(uname -s)" == "Linux" ]] || return 1
  if [[ "$EUID" -eq 0 ]]; then
    return 0
  fi
  if command -v sudo >/dev/null 2>&1; then
    sudo -n true >/dev/null 2>&1 || [[ -t 0 && -t 1 ]]
    return
  fi
  return 1
}

ubuntu_major_supported() {
  local version_id="$1"
  local major="${version_id%%.*}"
  [[ "$major" =~ ^[0-9]+$ ]] && (( major >= 24 ))
}

resolve_linux_bootstrap_script() {
  if [[ ! -f /etc/os-release ]]; then
    err "Missing /etc/os-release; cannot determine Linux distribution"
    exit 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release

  case "${ID:-}" in
    ubuntu)
      if ubuntu_major_supported "${VERSION_ID:-}"; then
        echo "$REPO_ROOT/scripts/bootstrap-ubuntu.sh"
      else
        err "Unsupported Ubuntu version: ${VERSION_ID:-unknown} (expected major version 24 or newer)"
        exit 1
      fi
      ;;
    *)
      err "Unsupported Linux distro ID: ${ID:-unknown} (expected ubuntu)"
      exit 1
      ;;
  esac
}

run_bootstrap() {
  local os script
  os="$(uname -s)"

  case "$os" in
    Darwin)
      script="$REPO_ROOT/scripts/bootstrap-mac.sh"
      if [[ "$DRY_RUN" == "true" ]]; then
        info "[dry-run] Would run macOS bootstrap: $script"
      else
        info "Bootstrapping macOS..."
        zsh "$script"
        if command -v brew >/dev/null 2>&1; then
          info "Applying Brewfile..."
          brew bundle --file="$REPO_ROOT/Brewfile"
        else
          warn "Homebrew not available; skipping Brewfile."
        fi
      fi
      ;;
    Linux)
      script="$(resolve_linux_bootstrap_script)"
      if linux_has_root; then
        LINUX_PRIVILEGED=true
      else
        LINUX_PRIVILEGED=false
      fi

      local args=()
      if [[ "$DRY_RUN" == "true" ]]; then
        args+=("--dry-run")
      fi

      info "Bootstrapping Linux via $(basename "$script")..."
      bash "$script" "${args[@]}"
      ;;
    *)
      err "Unsupported OS: $os"
      exit 1
      ;;
  esac
}

detect_components() {
  local candidates=()
  local supported=()
  local supported_component
  while IFS= read -r supported_component; do
    [[ -n "$supported_component" ]] || continue
    supported+=("$supported_component")
  done < <(host_supported_components)

  if [[ -n "$ONLY_COMPONENTS" ]]; then
    IFS=',' read -r -a candidates <<< "$ONLY_COMPONENTS"
  else
    candidates=("${supported[@]}")
  fi

  local component
  for component in "${candidates[@]}"; do
    component="${component//[[:space:]]/}"
    [[ -n "$component" ]] || continue

    if ! component_is_known "$component"; then
      err "Unknown component in --only list: $component"
      exit 1
    fi

    if ! array_contains "$component" "${supported[@]}"; then
      err "Component is not supported on this host: $component"
      exit 1
    fi

    if array_contains "$component" "${SELECTED_COMPONENTS[@]-}"; then
      continue
    fi

    if [[ -d "$STOW_DIR/$component" ]]; then
      SELECTED_COMPONENTS+=("$component")
    else
      SKIPPED_COMPONENTS+=("$component (missing package directory: $STOW_DIR/$component)")
    fi
  done
}

print_summary() {
  if (( "${#SELECTED_COMPONENTS[@]}" > 0 )); then
    info "Selected components: $(join_by_comma "${SELECTED_COMPONENTS[@]}")"
  else
    warn "No components selected (none detected or all filtered)."
  fi

  if (( "${#SKIPPED_COMPONENTS[@]}" > 0 )); then
    local item
    for item in "${SKIPPED_COMPONENTS[@]}"; do
      warn "Skipped: $item"
    done
  fi
}

apply_links_with_stow() {
  local component ignore_regex
  for component in "${SELECTED_COMPONENTS[@]}"; do
    if [[ ! -d "$STOW_DIR/$component" ]]; then
      warn "Component package missing at $STOW_DIR/$component; skipping."
      continue
    fi

    info "Applying component via stow: $component"
    if [[ "$DRY_RUN" == "true" ]]; then
      if ignore_regex="$(stow_ignore_regex_for_component "$component")" && [[ -n "$ignore_regex" ]]; then
        stow --no --restow --verbose=2 --ignore="$ignore_regex" --dir="$STOW_DIR" --target="$TARGET_DIR" "$component"
      else
        stow --no --restow --verbose=2 --dir="$STOW_DIR" --target="$TARGET_DIR" "$component"
      fi
      continue
    fi

    if ignore_regex="$(stow_ignore_regex_for_component "$component")" && [[ -n "$ignore_regex" ]]; then
      stow --restow --verbose=2 --ignore="$ignore_regex" --dir="$STOW_DIR" --target="$TARGET_DIR" "$component"
    else
      stow --restow --verbose=2 --dir="$STOW_DIR" --target="$TARGET_DIR" "$component"
    fi
  done
}

apply_links() {
  if (( "${#SELECTED_COMPONENTS[@]}" == 0 )); then
    warn "No dotfiles were linked because no components were selected."
    return
  fi

  if [[ ! -d "$STOW_DIR" ]]; then
    err "stow directory not found at $STOW_DIR"
    exit 1
  fi

  mkdir -p "$TARGET_DIR"

  if command -v stow >/dev/null 2>&1; then
    apply_links_with_stow
    return
  fi

  if [[ ! -x "$REPO_ROOT/scripts/link-with-symlinks.sh" ]]; then
    err "Fallback linker script not found or not executable: scripts/link-with-symlinks.sh"
    exit 1
  fi

  local component_csv
  component_csv="$(join_by_comma "${SELECTED_COMPONENTS[@]}")"
  info "GNU stow not found; using symlink fallback for: $component_csv"

  if [[ "$DRY_RUN" == "true" ]]; then
    bash "$REPO_ROOT/scripts/link-with-symlinks.sh" \
      --stow-dir "$STOW_DIR" \
      --target-dir "$TARGET_DIR" \
      --components "$component_csv" \
      --dry-run
  else
    bash "$REPO_ROOT/scripts/link-with-symlinks.sh" \
      --stow-dir "$STOW_DIR" \
      --target-dir "$TARGET_DIR" \
      --components "$component_csv"
  fi
}

install_plugins() {
  if [[ "$SKIP_PLUGINS" == "true" ]]; then
    info "Skipping plugin install/update (--skip-plugins)."
    return
  fi

  if [[ "$(uname -s)" == "Linux" && "$LINUX_PRIVILEGED" != "true" ]]; then
    info "Skipping plugin install/update because root/sudo is unavailable on Linux."
    return
  fi

  local plugin_components=()
  if array_contains "zsh" "${SELECTED_COMPONENTS[@]-}"; then
    plugin_components+=("zsh")
  fi
  if array_contains "tmux" "${SELECTED_COMPONENTS[@]-}"; then
    plugin_components+=("tmux")
  fi

  if (( "${#plugin_components[@]}" == 0 )); then
    info "No plugin-managed components selected; skipping plugin install/update."
    return
  fi

  local component_csv
  component_csv="$(join_by_comma "${plugin_components[@]}")"

  if [[ ! -f "$REPO_ROOT/scripts/install-plugins.sh" ]]; then
    warn "Plugin installer script not found; skipping plugin install/update."
    return
  fi

  info "Installing/updating plugins for: $component_csv"
  if [[ "$DRY_RUN" == "true" ]]; then
    bash "$REPO_ROOT/scripts/install-plugins.sh" --components "$component_csv" --dry-run
  else
    bash "$REPO_ROOT/scripts/install-plugins.sh" --components "$component_csv"
  fi
}

main() {
  parse_args "$@"
  run_bootstrap
  refresh_user_tool_path
  detect_components
  print_summary
  apply_links
  install_plugins
  info "Install flow complete."
}

main "$@"
