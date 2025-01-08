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

# load aliases if exists
if [[ -f "$HOME/.zsh/aliases.zsh" ]]; then
	source "$HOME/.zsh/aliases.zsh"
fi

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

# makes color constants available
autoload -U colors
colors

# enable autocd and interactive comments
setopt autocd
setopt interactive_comments

# enable colored output from ls, etc. on FreeBSD-based systems
export CLICOLOR=1

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

# Enable mise
if [[ -f "/opt/homebrew/bin/mise" ]]; then
	eval "$(/opt/homebrew/bin/mise activate zsh)"
fi
