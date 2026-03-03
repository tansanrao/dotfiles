#!/usr/bin/env bash
# Portable-first dotfiles installer.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_DIR="$REPO_ROOT/stow"
TARGET_DIR="$HOME"

BOOTSTRAP=false
SKIP_PLUGINS=false
ALLOW_LINK_FALLBACK=false
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
  cat <<'EOF'
Usage: ./install.sh [options]

Portable-first behavior (default):
  - configures only components whose tools are already installed
  - does not run OS bootstrap/package install steps unless --bootstrap is set

Options:
  --bootstrap             Run OS bootstrap scripts and Brewfile (explicit opt-in)
  --only a,b,c            Limit component install to a CSV subset
  --skip-plugins          Skip plugin dependency install/update
  --allow-link-fallback   Use built-in symlink linker when GNU stow is unavailable
  --dry-run               Print planned actions without changing files
  -h, --help              Show this help message

Components:
  git, zsh, tmux, neovim, ghostty
EOF
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

stow_ignore_regex_for_component() {
  case "$1" in
    zsh)
      # Ignore legacy local/plugin artifacts that may exist in a developer checkout.
      echo '(^|/)\.config/zsh/(pure|zsh-syntax-highlighting|\.zcompdump|\.zsh_history)(/|$)'
      ;;
    tmux)
      # Ignore legacy TPM location under the stow package.
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
      --bootstrap)
        BOOTSTRAP=true
        ;;
      --skip-plugins)
        SKIP_PLUGINS=true
        ;;
      --allow-link-fallback)
        ALLOW_LINK_FALLBACK=true
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

run_bootstrap() {
  local os
  os="$(uname -s)"

  if [[ "$BOOTSTRAP" != "true" ]]; then
    info "Bootstrap disabled (portable configure-only mode)."
    return
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    info "[dry-run] Bootstrap requested for OS: $os"
    return
  fi

  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
  fi

  case "$os" in
    Darwin)
      info "Bootstrapping macOS..."
      zsh "$REPO_ROOT/scripts/bootstrap-mac.sh"
      if command -v brew >/dev/null 2>&1; then
        info "Applying Brewfile..."
        brew bundle --file="$REPO_ROOT/Brewfile"
      else
        warn "Homebrew not available; skipping Brewfile."
      fi
      ;;
    Linux)
      case "${ID:-}" in
        fedora)
          info "Bootstrapping Fedora..."
          bash "$REPO_ROOT/scripts/bootstrap-fedora.sh"
          ;;
        *)
          err "Bootstrap is only supported on Fedora for Linux hosts (detected: ${ID:-unknown})."
          exit 1
          ;;
      esac
      ;;
    *)
      err "Bootstrap is unsupported on OS: $os"
      exit 1
      ;;
  esac
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

  if [[ "$ALLOW_LINK_FALLBACK" != "true" ]]; then
    err "GNU stow is not installed. Re-run with --allow-link-fallback to use the built-in symlink linker."
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
  detect_components
  print_summary
  run_bootstrap
  apply_links
  install_plugins

  info "Install flow complete."
}

main "$@"
