#!/usr/bin/env bash
# Minimal fallback linker when GNU stow is unavailable.

set -euo pipefail

STOW_DIR=""
TARGET_DIR="$HOME"
COMPONENTS_CSV=""
DRY_RUN=false

BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
BACKUP_USED=false

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
Usage: scripts/link-with-symlinks.sh --stow-dir <path> --target-dir <path> --components <csv> [--dry-run]
EOF
}

parse_args() {
  while (( "$#" > 0 )); do
    case "$1" in
      --stow-dir)
        if (( "$#" < 2 )); then
          err "--stow-dir requires a value"
          exit 1
        fi
        STOW_DIR="$2"
        shift
        ;;
      --target-dir)
        if (( "$#" < 2 )); then
          err "--target-dir requires a value"
          exit 1
        fi
        TARGET_DIR="$2"
        shift
        ;;
      --components)
        if (( "$#" < 2 )); then
          err "--components requires a CSV value"
          exit 1
        fi
        COMPONENTS_CSV="$2"
        shift
        ;;
      --components=*)
        COMPONENTS_CSV="${1#*=}"
        ;;
      --dry-run)
        DRY_RUN=true
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

  if [[ -z "$STOW_DIR" || -z "$COMPONENTS_CSV" ]]; then
    err "--stow-dir and --components are required"
    usage
    exit 1
  fi
}

should_skip_entry() {
  local component="$1"
  local rel="$2"

  case "$component" in
    zsh)
      case "$rel" in
        .config/zsh/pure|.config/zsh/pure/*|.config/zsh/zsh-syntax-highlighting|.config/zsh/zsh-syntax-highlighting/*|.config/zsh/.zcompdump|.config/zsh/.zcompdump*|.config/zsh/.zsh_history)
          return 0
          ;;
      esac
      ;;
    tmux)
      case "$rel" in
        .config/tmux/plugins|.config/tmux/plugins/*)
          return 0
          ;;
      esac
      ;;
  esac

  return 1
}

backup_existing() {
  local dest="$1"
  local rel="$2"
  local backup_path="$BACKUP_DIR/$rel"

  if [[ "$DRY_RUN" == "true" ]]; then
    info "[dry-run] Backup: $dest -> $backup_path"
    return
  fi

  mkdir -p "$(dirname "$backup_path")"
  mv "$dest" "$backup_path"
  BACKUP_USED=true
  warn "Backed up existing path: $dest -> $backup_path"
}

ensure_directory() {
  local dir_path="$1"
  local rel="$2"

  if [[ -d "$dir_path" && ! -L "$dir_path" ]]; then
    return
  fi

  if [[ -e "$dir_path" || -L "$dir_path" ]]; then
    backup_existing "$dir_path" "$rel"
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    info "[dry-run] mkdir -p $dir_path"
  else
    mkdir -p "$dir_path"
  fi
}

link_path() {
  local src="$1"
  local rel="$2"
  local dest="$TARGET_DIR/$rel"
  local parent

  parent="$(dirname "$dest")"
  ensure_directory "$parent" "$(dirname "$rel")"

  if [[ -L "$dest" ]]; then
    if [[ "$(readlink "$dest")" == "$src" ]]; then
      info "Already linked: $dest"
      return
    fi
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    backup_existing "$dest" "$rel"
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    info "[dry-run] ln -s $src $dest"
  else
    ln -s "$src" "$dest"
    info "Linked: $dest -> $src"
  fi
}

link_component() {
  local component="$1"
  local package_dir="$STOW_DIR/$component"
  local src rel dest

  if [[ ! -d "$package_dir" ]]; then
    warn "Missing package directory, skipping: $package_dir"
    return
  fi

  info "Linking component via fallback: $component"
  while IFS= read -r -d '' src; do
    rel="${src#$package_dir/}"

    if should_skip_entry "$component" "$rel"; then
      continue
    fi

    dest="$TARGET_DIR/$rel"
    if [[ -d "$src" && ! -L "$src" ]]; then
      ensure_directory "$dest" "$rel"
      continue
    fi

    link_path "$src" "$rel"
  done < <(find "$package_dir" -mindepth 1 -print0)
}

main() {
  parse_args "$@"

  if [[ ! -d "$STOW_DIR" ]]; then
    err "stow directory not found: $STOW_DIR"
    exit 1
  fi

  local components=()
  IFS=',' read -r -a components <<< "$COMPONENTS_CSV"
  if (( "${#components[@]}" == 0 )); then
    warn "No components provided; nothing to do."
    return
  fi

  local component
  for component in "${components[@]}"; do
    component="${component//[[:space:]]/}"
    [[ -n "$component" ]] || continue
    link_component "$component"
  done

  if [[ "$DRY_RUN" == "true" ]]; then
    info "Fallback linking dry run complete."
    return
  fi

  if [[ "$BACKUP_USED" == "true" ]]; then
    info "Existing paths were backed up under: $BACKUP_DIR"
  fi
  info "Fallback linking complete."
}

main "$@"
