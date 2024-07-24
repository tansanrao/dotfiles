#!/bin/zsh

# Check if .vimrc is symlinked correctly
VIMRC_TARGET="$HOME/.config/dotfiles/vim/vimrc"
VIMRC_LINK="$HOME/.vimrc"
if [ -L "$VIMRC_LINK" ] && [ "$(readlink $VIMRC_LINK)" = "$VIMRC_TARGET" ]; then
  echo ".vimrc is correctly symlinked."
else
  echo ".vimrc is not correctly symlinked. Creating symlink..."
  ln -sf "$VIMRC_TARGET" "$VIMRC_LINK"
fi
