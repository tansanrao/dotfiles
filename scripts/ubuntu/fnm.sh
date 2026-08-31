#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

require_ubuntu

fnm_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fnm"
if [[ -x "$fnm_dir/fnm" ]] || command -v fnm >/dev/null 2>&1; then
  echo "ok: fnm is installed"
  exit 0
fi

log "Installing fnm"
mkdir -p "$(dirname "$fnm_dir")"
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
