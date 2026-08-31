#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

require_ubuntu

log "Configuring zsh"
link_file "$repo_root/.zshrc" "$HOME/.zshrc"

user_name="$(id -un)"
zsh_path="$(command -v zsh)"
current_shell="$(getent passwd "$user_name" | cut -d: -f7)"

if [[ "$current_shell" == "$zsh_path" ]]; then
  echo "ok: zsh is already the login shell"
  exit 0
fi

log "Setting zsh as the login shell"
run_as_root chsh -s "$zsh_path" "$user_name"
