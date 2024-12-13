# Preferred Editor
export EDITOR='vim'

# add pure
fpath+=($HOME/.zsh/pure)
autoload -U promptinit; promptinit
prompt pure

# load atuin if exists
if [[ -f "$HOME/.atuin/bin/env" ]]; then
	source "$HOME/.atuin/bin/env"
	eval "$(atuin init zsh)"
fi


