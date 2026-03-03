#!/usr/bin/env bash
# Install shell and tmux plugin dependencies in user space.

set -euo pipefail

COMPONENTS_CSV="zsh,tmux"
DRY_RUN=false
XDG_DATA_HOME_DEFAULT="${XDG_DATA_HOME:-$HOME/.local/share}"
PLUGIN_HOME="$XDG_DATA_HOME_DEFAULT/dotfiles/plugins"

info() {
  printf 'INFO: %s\n' "$1"
}

warn() {
  printf 'WARN: %s\n' "$1"
}

usage() {
  cat <<'EOF'
Usage: scripts/install-plugins.sh [options]

Options:
  --components a,b    Components to manage (supported: zsh, tmux)
  --plugin-home path  Base path for dotfiles plugin data (default: $XDG_DATA_HOME/dotfiles/plugins)
  --dry-run           Print planned actions without mutating files
  -h, --help          Show this help message
EOF
}

parse_args() {
  while (( "$#" > 0 )); do
    case "$1" in
      --components)
        if (( "$#" < 2 )); then
          warn "--components requires a CSV value; ignoring."
        else
          COMPONENTS_CSV="$2"
          shift
        fi
        ;;
      --components=*)
        COMPONENTS_CSV="${1#*=}"
        ;;
      --plugin-home)
        if (( "$#" < 2 )); then
          warn "--plugin-home requires a value; ignoring."
        else
          PLUGIN_HOME="$2"
          shift
        fi
        ;;
      --plugin-home=*)
        PLUGIN_HOME="${1#*=}"
        ;;
      --dry-run)
        DRY_RUN=true
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        warn "Unknown argument: $1"
        ;;
    esac
    shift
  done
}

component_enabled() {
  local needle="$1"
  local component
  local components=()
  IFS=',' read -r -a components <<< "$COMPONENTS_CSV"
  for component in "${components[@]}"; do
    component="${component//[[:space:]]/}"
    if [[ "$component" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

run_cmd() {
  if [[ "$DRY_RUN" == "true" ]]; then
    info "[dry-run] $*"
    return 0
  fi
  "$@"
}

ensure_git_dependency() {
  local name="$1"
  local repo_url="$2"
  local target_dir="$3"

  run_cmd mkdir -p "$(dirname "$target_dir")"

  if [[ ! -d "$target_dir/.git" ]]; then
    if [[ -e "$target_dir" ]]; then
      warn "$name target exists but is not a git repo: $target_dir"
      warn "Remove it manually, then rerun install."
      return
    fi
    info "Installing $name..."
    if [[ "$DRY_RUN" == "true" ]]; then
      info "[dry-run] git clone --quiet $repo_url $target_dir"
      return
    fi
    if ! git clone --quiet "$repo_url" "$target_dir"; then
      warn "Failed to install $name; continuing."
    fi
    return
  fi

  info "Updating $name..."
  if [[ "$DRY_RUN" == "true" ]]; then
    info "[dry-run] git -C $target_dir pull --ff-only --quiet"
    return
  fi
  if ! git -C "$target_dir" pull --ff-only --quiet; then
    warn "Failed to update $name; continuing."
  fi
}

main() {
  parse_args "$@"
  info "Installing/updating plugin dependencies..."

  if ! command -v git >/dev/null 2>&1; then
    warn "git is unavailable; skipping plugin install/update."
    return
  fi

  local did_work=false
  local zsh_plugin_dir="$PLUGIN_HOME/zsh"
  local tmux_plugin_dir="$XDG_DATA_HOME_DEFAULT/tmux/plugins"

  if component_enabled "zsh"; then
    did_work=true
    ensure_git_dependency "pure prompt" "https://github.com/sindresorhus/pure.git" "$zsh_plugin_dir/pure"
    ensure_git_dependency "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$zsh_plugin_dir/zsh-syntax-highlighting"
  fi

  if component_enabled "tmux"; then
    did_work=true
    ensure_git_dependency "TPM (Tmux Plugin Manager)" "https://github.com/tmux-plugins/tpm.git" "$tmux_plugin_dir/tpm"
  fi

  if [[ "$did_work" != "true" ]]; then
    info "No supported plugin-managed components selected; nothing to do."
    return
  fi

  info "Plugin dependency step complete."
}

main "$@"
