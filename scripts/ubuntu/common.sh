#!/usr/bin/env bash

ubuntu_scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$ubuntu_scripts_dir/../.." && pwd)"

log() {
  printf '\n==> %s\n' "$1"
}

require_ubuntu() {
  if [[ "$(uname -s)" != "Linux" || ! -r /etc/os-release ]]; then
    echo "This installer only supports Ubuntu Linux." >&2
    exit 1
  fi

  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    echo "This installer only supports Ubuntu (detected: ${PRETTY_NAME:-unknown})." >&2
    exit 1
  fi

  if (( EUID == 0 )) && [[ -n "${SUDO_USER:-}" ]]; then
    echo "Run this script as your normal user; it will invoke sudo when needed." >&2
    exit 1
  fi
}

run_as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    sudo "$@"
  fi
}

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
