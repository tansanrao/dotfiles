#!/usr/bin/env bash
# Install shell and tmux plugins

set -euo pipefail

echo "INFO: Installing shell and tmux plugins..."

# Create required directories
mkdir -p ~/.config/zsh
mkdir -p ~/.config/tmux/plugins

ensure_git_dependency() {
  local name="$1"
  local repo_url="$2"
  local target_dir="$3"

  mkdir -p "$(dirname "$target_dir")"

  if [[ ! -d "$target_dir/.git" ]]; then
    if [[ -d "$target_dir" ]]; then
      echo "WARN: $name target exists but is not a git repo: $target_dir"
      echo "WARN: Remove it manually, then rerun install."
      return
    fi
    echo "INFO: Installing $name..."
    git clone --quiet "$repo_url" "$target_dir"
    return
  fi

  echo "INFO: Updating $name..."
  git -C "$target_dir" pull --ff-only --quiet
}

# Manually managed git dependencies (clone or update on each run)
ensure_git_dependency "pure prompt" "https://github.com/sindresorhus/pure.git" "$HOME/.config/zsh/pure"
ensure_git_dependency "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.config/zsh/zsh-syntax-highlighting"
ensure_git_dependency "TPM (Tmux Plugin Manager)" "https://github.com/tmux-plugins/tpm.git" "$HOME/.config/tmux/plugins/tpm"

echo "SUCCESS: Plugins installed!"
echo ""
echo "Next steps:"
echo "1. Start a new zsh session to see the pure prompt"
echo "2. In tmux, press prefix + I to install tmux plugins"
echo "3. Restart tmux or source the config: tmux source ~/.config/tmux/tmux.conf"
