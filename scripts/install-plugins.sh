#!/usr/bin/env bash
# Install shell and tmux plugins

set -euo pipefail

echo "INFO: Installing shell and tmux plugins..."

# Create required directories
mkdir -p ~/.config/zsh
mkdir -p ~/.config/tmux/plugins

# Install pure prompt for zsh
if [[ ! -d ~/.config/zsh/pure ]]; then
  echo "INFO: Installing pure prompt..."
  git clone --quiet https://github.com/sindresorhus/pure.git ~/.config/zsh/pure
else
  echo "INFO: Updating pure prompt..."
  git -C ~/.config/zsh/pure pull --quiet
fi

# Install zsh-syntax-highlighting
if [[ ! -d ~/.config/zsh/zsh-syntax-highlighting ]]; then
  echo "INFO: Installing zsh-syntax-highlighting..."
  git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh/zsh-syntax-highlighting
else
  echo "INFO: Updating zsh-syntax-highlighting..."
  git -C ~/.config/zsh/zsh-syntax-highlighting pull --quiet
fi

# Install TPM (Tmux Plugin Manager)
if [[ ! -d ~/.config/tmux/plugins/tpm ]]; then
  echo "INFO: Installing TPM (Tmux Plugin Manager)..."
  git clone --quiet https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
else
  echo "INFO: Updating TPM..."
  git -C ~/.config/tmux/plugins/tpm pull --quiet
fi

echo "SUCCESS: Plugins installed!"
echo ""
echo "Next steps:"
echo "1. Start a new zsh session to see the pure prompt"
echo "2. In tmux, press prefix + I to install tmux plugins"
echo "3. Restart tmux or source the config: tmux source ~/.config/tmux/tmux.conf"
