# ~/.zshenv
# Set ZDOTDIR to use custom zsh config directory
export ZDOTDIR="$HOME/.config/zsh"

# Source our custom zshrc if it exists
if [[ -f "$ZDOTDIR/.zshrc" ]]; then
  source "$ZDOTDIR/.zshrc"
fi 
