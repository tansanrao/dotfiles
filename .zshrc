# XDG defaults
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export PATH="$HOME/.local/bin:$PATH"

# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# History
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=500000
SAVEHIST=500000
mkdir -p "${HISTFILE:h}"

setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST

# remove from known_hosts helper
function rmkeys() {
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$1"
}

# SSH through multiple jump hosts
function jump() {
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

# fzf
if [[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# fnm
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# Pure prompt
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -U promptinit
promptinit
if whence -w prompt_pure_setup >/dev/null 2>&1; then
  prompt pure
fi
