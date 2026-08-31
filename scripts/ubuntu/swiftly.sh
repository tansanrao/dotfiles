#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

require_ubuntu

swiftly_home="${SWIFTLY_HOME_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/swiftly}"
if [[ -x "$swiftly_home/bin/swiftly" && -f "$swiftly_home/env.sh" ]]; then
  echo "ok: swiftly is initialized"
  exit 0
fi

log "Installing swiftly"
temp_dir=""

cleanup() {
  if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
    rm -rf -- "$temp_dir"
  fi
}
trap cleanup EXIT

if command -v swiftly >/dev/null 2>&1; then
  swiftly_command="$(command -v swiftly)"
else
  temp_dir="$(mktemp -d)"
  archive="$temp_dir/swiftly-$(uname -m).tar.gz"
  curl -fsSL "https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz" -o "$archive"
  tar -xzf "$archive" -C "$temp_dir"
  swiftly_command="$temp_dir/swiftly"
fi

SWIFTLY_HOME_DIR="$swiftly_home" "$swiftly_command" init \
  --skip-install \
  --assume-yes \
  --quiet-shell-followup \
  --no-modify-profile
