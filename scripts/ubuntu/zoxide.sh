#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

require_ubuntu

if [[ -x "$HOME/.local/bin/zoxide" ]] || command -v zoxide >/dev/null 2>&1; then
  echo "ok: zoxide is installed"
  exit 0
fi

log "Installing zoxide"
mkdir -p "$HOME/.local/bin"
curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
