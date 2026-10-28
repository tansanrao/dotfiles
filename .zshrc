# XDG defaults
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

# Preserve pnpm-installed global commands; mise supplies pnpm itself.
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
path=("$PNPM_HOME/bin" ${path:#"$PNPM_HOME/bin"})

# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Activate before integrations so they use mise's selected tool versions.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Use mise's eza for interactive directory listings on macOS and Linux.
alias ls='eza'

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

# Initialize all available completions before shell integrations.
[[ -d "$HOME/.zsh/pure" ]] && fpath=("$HOME/.zsh/pure" $fpath)
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -Uz compinit
compinit

# Generate completions from the active uv version.
if command -v uv >/dev/null 2>&1; then
  eval "$(uv generate-shell-completion zsh)"
fi
if command -v uvx >/dev/null 2>&1; then
  eval "$(uvx --generate-shell-completion zsh)"
fi

# fzf's pinned mise version provides its own shell integration.
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Pure prompt
autoload -U promptinit
promptinit
if whence -w prompt_pure_setup >/dev/null 2>&1; then
  prompt pure
fi
