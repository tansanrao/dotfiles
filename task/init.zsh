#!/bin/zsh

# Check if Taskfile.yml is symlinked correctly
TASKFILE_TARGET="$HOME/.config/dotfiles/task/Taskfile.yml"
TASKFILE_LINK="$HOME/Taskfile.yml"
if [ -L "$TASKFILE_LINK" ] && [ "$(readlink $TASKFILE_LINK)" = "$TASKFILE_TARGET" ]; then
  echo "Taskfile.yml is correctly symlinked."
else
  echo "Taskfile.yml is not correctly symlinked. Creating symlink..."
  ln -sf "$TASKFILE_TARGET" "$TASKFILE_LINK"
fi
