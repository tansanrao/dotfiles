#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

require_ubuntu

packages=(
  build-essential
  ca-certificates
  curl
  fzf
  git
  gnupg
  tmux
  unzip
  zsh
)

log "Installing Ubuntu CLI packages"
run_as_root apt-get update
run_as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${packages[@]}"
