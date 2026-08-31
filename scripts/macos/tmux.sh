#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source_file="$repo_root/.config/tmux/tmux.conf"
target_file="$HOME/.config/tmux/tmux.conf"
target_dir="$(dirname "$target_file")"

if [[ ! -e "$source_file" ]]; then
  echo "missing source: $source_file" >&2
  exit 1
fi

mkdir -p "$target_dir"

if [[ -L "$target_file" ]]; then
  current="$(readlink "$target_file")"

  if [[ "$current" == "$source_file" ]]; then
    echo "ok: $target_file -> $source_file"
    exit 0
  fi

  rm "$target_file"
  ln -s "$source_file" "$target_file"
  echo "fixed: $target_file -> $source_file"
  exit 0
fi

if [[ -e "$target_file" ]]; then
  if [[ -f "$target_file" ]] && cmp -s "$source_file" "$target_file"; then
    rm "$target_file"
    ln -s "$source_file" "$target_file"
    echo "linked matching file: $target_file -> $source_file"
    exit 0
  fi

  backup="${target_file}.backup.$(date +%Y%m%d%H%M%S)"
  mv "$target_file" "$backup"
  ln -s "$source_file" "$target_file"
  echo "backed up existing target: $backup"
  echo "linked: $target_file -> $source_file"
  exit 0
fi

ln -s "$source_file" "$target_file"
echo "linked: $target_file -> $source_file"
