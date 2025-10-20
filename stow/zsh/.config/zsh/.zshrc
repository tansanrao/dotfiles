# ~/.config/zsh/.zshrc
# Main zsh configuration file

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# Enable completion system
autoload -Uz compinit
compinit

# Enable vi mode
bindkey -v

# Aliases
alias ls="ls --color=auto"
alias ll="ls -la"
alias vi="nvim"
alias vim="nvim"

# Helper functions
# For when tmux attach causes problems with old agent in envvars
function fixssh() {
  eval $(tmux show-env -s |grep '^SSH_')
}

# remove from known_hosts helper
function rmkeys() {
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R $1
}

# SSH through multiple jump hosts
function jump() {
  # Check for minimum number of arguments (1 jump host + 1 final host)
  if (( $# < 2 )); then
    echo "Usage: jump host1 [host2 ... hostN]" >&2 
    return 1
  fi

  local -a hosts=("$@")
  local last_host="${hosts[-1]}"
  local -a proxies=("${hosts[@]:0:$#hosts-1}")
  local jump_string="${(j:,:)proxies}"

  ssh -A -J "${jump_string}" "${last_host}"
}

# Load tool integrations if available
# fzf
if command -v fzf >/dev/null 2>&1; then
  # Enable fzf key bindings and fuzzy completion (Homebrew installation)
  if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  fi

  if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/completion.zsh
  fi

  # fzf configuration
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  export FZF_DEFAULT_OPTS='--height 30% --layout=reverse --border'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# zoxide (smarter cd command)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi


# mise (development tools)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Pure prompt setup
if [[ -d ~/.config/zsh/pure ]]; then
  fpath+=(~/.config/zsh/pure)
  autoload -U promptinit
  promptinit
  prompt pure
fi

# Syntax highlighting
if [[ -f ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Source local environment file if it exists
if [[ -f "$HOME/.local/bin/env" ]]; then
  source "$HOME/.local/bin/env"
fi

if [[ -d ~/.nvm ]]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi
