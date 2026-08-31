#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

require_ubuntu

pure_dir="$HOME/.zsh/pure"
if [[ -f "$pure_dir/pure.zsh" && -f "$pure_dir/async.zsh" ]]; then
  echo "ok: Pure prompt is installed"
  exit 0
fi

if [[ -e "$pure_dir" ]]; then
  echo "$pure_dir exists but is not a valid Pure prompt checkout." >&2
  exit 1
fi

log "Installing Pure prompt"
mkdir -p "$(dirname "$pure_dir")"
git clone --depth 1 https://github.com/sindresorhus/pure.git "$pure_dir"
