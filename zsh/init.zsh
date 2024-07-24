#!/bin/zsh

# Check if Oh My Zsh is installed
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh is already installed."
else
  echo "Oh My Zsh is not installed. Installing..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Check if Pure prompt is installed
PURE_DIR="$HOME/.zsh/pure"
if [ -d "$PURE_DIR" ]; then
  echo "Pure prompt is already installed."
else
  echo "Pure prompt is not installed. Installing..."
  mkdir -p "$HOME/.zsh"
  git clone https://github.com/sindresorhus/pure.git "$PURE_DIR"
fi

# Check if .zshrc is symlinked correctly
ZSHRC_TARGET="$HOME/.config/dotfiles/zsh/zshrc"
ZSHRC_LINK="$HOME/.zshrc"
if [ -L "$ZSHRC_LINK" ] && [ "$(readlink $ZSHRC_LINK)" = "$ZSHRC_TARGET" ]; then
  echo ".zshrc is correctly symlinked."
else
  echo ".zshrc is not correctly symlinked. Creating symlink..."
  ln -sf "$ZSHRC_TARGET" "$ZSHRC_LINK"
fi

# Check if aliases.zsh is symlinked correctly
ALIASES_TARGET="$HOME/.config/dotfiles/zsh/aliases.zsh"
ALIASES_LINK="$HOME/.oh-my-zsh/custom/aliases.zsh"
if [ -L "$ALIASES_LINK" ] && [ "$(readlink $ALIASES_LINK)" = "$ALIASES_TARGET" ]; then
  echo "aliases.zsh is correctly symlinked."
else
  echo "aliases.zsh is not correctly symlinked. Creating symlink..."
  ln -sf "$ALIASES_TARGET" "$ALIASES_LINK"
fi

echo "zsh setup complete."
