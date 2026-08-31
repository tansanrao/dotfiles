# XDG defaults
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export PATH="$XDG_DATA_HOME/fnm:$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

# Swiftly
if [[ -f "${SWIFTLY_HOME_DIR:-$XDG_DATA_HOME/swiftly}/env.sh" ]]; then
  source "${SWIFTLY_HOME_DIR:-$XDG_DATA_HOME/swiftly}/env.sh"
fi

# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  [[ -d /opt/homebrew/opt/rustup/bin ]] && export PATH="/opt/homebrew/opt/rustup/bin:$PATH"
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

# fzf (new releases generate their integration; Ubuntu LTS packages ship files)
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    for fzf_script in \
      /usr/share/doc/fzf/examples/completion.zsh \
      /usr/share/doc/fzf/examples/key-bindings.zsh \
      /opt/homebrew/opt/fzf/shell/completion.zsh \
      /opt/homebrew/opt/fzf/shell/key-bindings.zsh; do
      [[ -f "$fzf_script" ]] && source "$fzf_script"
    done
    unset fzf_script
  fi
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
[[ -d "$HOME/.zsh/pure" ]] && fpath=("$HOME/.zsh/pure" $fpath)
[[ -d /opt/homebrew/share/zsh/site-functions ]] && fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -U promptinit
promptinit
if whence -w prompt_pure_setup >/dev/null 2>&1; then
  prompt pure
fi

# pnpm
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
