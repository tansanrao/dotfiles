#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

require_ubuntu

log "Configuring tmux"
link_file "$repo_root/.config/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
