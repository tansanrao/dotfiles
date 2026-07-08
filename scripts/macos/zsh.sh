#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

link_file() {
  local source="$1"
  local target="$2"
  local target_dir
  target_dir="$(dirname "$target")"

  if [[ ! -e "$source" ]]; then
    echo "missing source: $source" >&2
    return 1
  fi

  mkdir -p "$target_dir"

  if [[ -L "$target" ]]; then
    local current
    current="$(readlink "$target")"

    if [[ "$current" == "$source" ]]; then
      echo "ok: $target -> $source"
      return 0
    fi

    rm "$target"
    ln -s "$source" "$target"
    echo "fixed: $target -> $source"
    return 0
  fi

  if [[ -e "$target" ]]; then
    if [[ -f "$target" ]] && cmp -s "$source" "$target"; then
      rm "$target"
      ln -s "$source" "$target"
      echo "linked matching file: $target -> $source"
      return 0
    fi

    local backup
    backup="${target}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    ln -s "$source" "$target"
    echo "backed up existing target: $backup"
    echo "linked: $target -> $source"
    return 0
  fi

  ln -s "$source" "$target"
  echo "linked: $target -> $source"
}

link_file "$repo_root/.zshrc" "$HOME/.zshrc"
