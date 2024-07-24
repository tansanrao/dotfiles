#!/bin/zsh

# Install atuin
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# Check if config.toml is symlinked correctly
CONFIG_TARGET="$HOME/.config/dotfiles/atuin/config.toml"
CONFIG_LINK="$HOME/.config/atuin/config.toml"
if [ -L "$CONFIG_LINK" ] && [ "$(readlink $CONFIG_LINK)" = "$CONFIG_TARGET" ]; then
  echo "config.toml is correctly symlinked."
else
  echo "config.toml is not correctly symlinked. Creating symlink..."
  ln -sf "$CONFIG_TARGET" "$CONFIG_LINK"
fi

echo "login to atuin after setting up tailscale please"


