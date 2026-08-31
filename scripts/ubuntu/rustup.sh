#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

require_ubuntu

if [[ -x "$HOME/.cargo/bin/rustup" ]] || command -v rustup >/dev/null 2>&1; then
  echo "ok: rustup is installed"
  exit 0
fi

log "Installing rustup"
curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs |
  sh -s -- -y --no-modify-path --profile minimal --default-toolchain none
