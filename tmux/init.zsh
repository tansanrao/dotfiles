#!/bin/zsh

# Check if .tmux.conf is symlinked correctly
TMUXCONF_TARGET="$HOME/.config/dotfiles/tmux/tmux.conf"
TMUXCONF_LINK="$HOME/.tmux.conf"
if [ -L "$TMUXCONF_LINK" ] && [ "$(readlink $TMUXCONF_LINK)" = "$TMUXCONF_TARGET" ]; then
  echo ".tmux.conf is correctly symlinked."
else
  echo ".tmux.conf is not correctly symlinked. Creating symlink..."
  ln -sf "$TMUXCONF_TARGET" "$TMUXCONF_LINK"
fi

# Check if tpm is installed
TPM_DIR="$HOME/.tmux/plugins/tpm"
TPM_REPO="https://github.com/tmux-plugins/tpm"

if [ -d "$TPM_DIR" ]; then
	echo "$TPM_DIR already exists. Checking repository..."
	cd "$TPM_DIR"
	CURRENT_REPO=$(git config --get remote.origin.url)
	if [ "$CURRENT_REPO" = "$TPM_REPO" ]; then
		echo "Correct repository. Pulling latest changes..."
		git pull
		zsh -c $HOME/.tmux/plugins/tpm/bin/install_plugins
	else
		echo "Incorrect repository. Please check your setup."
	fi
else
	echo "Cloning tpm repository..."
	git clone "$TPM_REPO" "$TPM_DIR"
	cd "$TPM_DIR"
	zsh -c $HOME/.tmux/plugins/tpm/bin/install_plugins
fi

echo "tmux setup complete."
