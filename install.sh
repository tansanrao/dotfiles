#!/usr/bin/env bash
# Root-first dotfiles installer with deterministic Linux bootstraps.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$REPO_ROOT/stow"
TARGET_DIR="$HOME"

NO_ROOT=false
SKIP_PLUGINS=false
NO_STOW=false
USED_ALLOW_LINK_FALLBACK_ALIAS=false
DRY_RUN=false
ONLY_COMPONENTS=""

ALL_COMPONENTS=(git zsh tmux neovim ghostty)
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
  - Linux bootstrap is root-first by default (root or sudo)
  - Apply dotfile links for detected installed components

Options:
  --no-root              Use user-space bootstrap fallback (Linux)
  --no-stow              Use built-in symlink linker when GNU stow is unavailable
  --only a,b,c           Limit component install to a CSV subset
  --skip-plugins         Skip plugin dependency install/update
  --allow-link-fallback  Deprecated alias for --no-stow
  --dry-run              Print planned actions without changing files
  -h, --help             Show this help message

Components:
  git, zsh, tmux, neovim, ghostty
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
      --no-root)
        NO_ROOT=true
        ;;
      --skip-plugins)
        SKIP_PLUGINS=true
        ;;
      --no-stow)
        NO_STOW=true
        ;;
      --allow-link-fallback)
        NO_STOW=true
        USED_ALLOW_LINK_FALLBACK_ALIAS=true
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

  if [[ "$USED_ALLOW_LINK_FALLBACK_ALIAS" == "true" ]]; then
    warn "--allow-link-fallback is deprecated; use --no-stow."
  fi
}

is_el10_host() {
  if [[ "$(uname -s)" != "Linux" || ! -f /etc/os-release ]]; then
    return 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release

  case "${ID:-}" in
    rocky|centos)
      [[ "${VERSION_ID%%.*}" == "10" ]]
      ;;
    *)
      return 1
      ;;
  esac
}

resolve_linux_bootstrap_script() {
  if [[ ! -f /etc/os-release ]]; then
    err "Missing /etc/os-release; cannot determine Linux distribution"
    exit 1
  fi

  # shellcheck disable=SC1091
  . /etc/os-release

  case "${ID:-}" in
    fedora)
      echo "$REPO_ROOT/scripts/bootstrap-fedora.sh"
      ;;
    rocky|centos)
      local major
      major="${VERSION_ID%%.*}"
      if [[ "$major" == "9" || "$major" == "10" ]]; then
        echo "$REPO_ROOT/scripts/bootstrap-el.sh"
      else
        err "Unsupported ${ID:-unknown} version: ${VERSION_ID:-unknown}"
        exit 1
      fi
      ;;
    ubuntu)
      if [[ "${VERSION_ID:-}" == 24.04* ]]; then
        echo "$REPO_ROOT/scripts/bootstrap-ubuntu.sh"
      else
        err "Unsupported Ubuntu version: ${VERSION_ID:-unknown} (expected 24.04.x)"
        exit 1
      fi
      ;;
    *)
      err "Unsupported Linux distro ID: ${ID:-unknown}"
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

      if [[ "$NO_ROOT" != "true" && "$EUID" -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
        err "No root or sudo privileges detected. Re-run with --no-root for user-space bootstrap."
        exit 1
      fi

      local args=()
      if [[ "$NO_ROOT" == "true" ]]; then
        args+=("--no-root")
      fi
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
  if [[ -n "$ONLY_COMPONENTS" ]]; then
    IFS=',' read -r -a candidates <<< "$ONLY_COMPONENTS"
  else
    candidates=("${ALL_COMPONENTS[@]}")
  fi

  local component cmd
  for component in "${candidates[@]}"; do
    component="${component//[[:space:]]/}"
    [[ -n "$component" ]] || continue

    if ! component_is_known "$component"; then
      err "Unknown component in --only list: $component"
      exit 1
    fi

    if array_contains "$component" "${SELECTED_COMPONENTS[@]-}"; then
      continue
    fi

    cmd="$(component_command "$component")"
    if command -v "$cmd" >/dev/null 2>&1; then
      SELECTED_COMPONENTS+=("$component")
    else
      SKIPPED_COMPONENTS+=("$component (missing command: $cmd)")
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

  local use_no_stow="$NO_STOW"
  if [[ "$use_no_stow" != "true" ]] && is_el10_host; then
    use_no_stow=true
    info "EL10 detected; using --no-stow linker mode by default."
  fi

  if [[ "$use_no_stow" != "true" ]]; then
    err "GNU stow is not installed. Re-run with --no-stow to use the built-in symlink linker."
    exit 1
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
