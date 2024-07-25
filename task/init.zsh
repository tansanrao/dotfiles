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

# Pull zsh completions
sudo curl https://raw.githubusercontent.com/go-task/task/main/completion/zsh/_task \
	-o /usr/local/share/zsh/site-functions/_task
