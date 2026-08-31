#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$repo_root/scripts/ubuntu/apt.sh"
"$repo_root/scripts/ubuntu/fnm.sh"
"$repo_root/scripts/ubuntu/rustup.sh"
"$repo_root/scripts/ubuntu/swiftly.sh"
"$repo_root/scripts/ubuntu/zoxide.sh"
"$repo_root/scripts/ubuntu/pure.sh"
"$repo_root/scripts/ubuntu/zsh.sh"
"$repo_root/scripts/ubuntu/tmux.sh"
