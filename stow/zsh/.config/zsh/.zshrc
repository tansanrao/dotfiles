# ---------- OS helpers ----------
is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }

# ---------- XDG defaults ----------
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export PATH="$HOME/.local/bin:$PATH"

# ---------- remove from known_hosts helper ----------
function rmkeys() {
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R "$1"
}

# ---------- SSH through multiple jump hosts ----------
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

# ---------- Shared history ----------
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=500000
SAVEHIST=500000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST

# ---------- Cargo ----------
if [[ -f "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi

# ---------- Homebrew prefix (macOS + Linuxbrew) ----------
if command -v brew >/dev/null 2>&1; then
  export BREW_PREFIX="$(brew --prefix)"
fi

# ---------- fzf ----------
if command -v fzf >/dev/null 2>&1; then
  if [[ -n "${BREW_PREFIX:-}" ]]; then
    [[ -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] && source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
    [[ -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh" ]] && source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
  fi
  [[ -f /usr/share/fzf/shell/key-bindings.zsh ]] && source /usr/share/fzf/shell/key-bindings.zsh
  [[ -f /usr/share/fzf/shell/completion.zsh ]] && source /usr/share/fzf/shell/completion.zsh
  [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
  [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh

  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
  elif command -v fdfind >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fdfind --type f --hidden --exclude .git"
  else
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
  fi
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS='--height 30% --layout=reverse --border'
fi

# ---------- zoxide ----------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# ---------- mise ----------
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# ---------- Pure prompt ----------
ZSH_PLUGIN_HOME="$XDG_DATA_HOME/dotfiles/plugins/zsh"
if [[ -d "$ZSH_PLUGIN_HOME/pure" ]]; then
  fpath+=("$ZSH_PLUGIN_HOME/pure")
fi

autoload -U promptinit
promptinit
if whence -w prompt_pure_setup >/dev/null 2>&1 || whence -w prompt_pure >/dev/null 2>&1; then
  prompt pure
fi

# ---------- Syntax highlighting ----------
if [[ -f "$ZSH_PLUGIN_HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$ZSH_PLUGIN_HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ---------- Local environment ----------
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# ---------- macOS niceties ----------
if is_macos; then
  if [[ -n "${BREW_PREFIX:-}" && -d "$BREW_PREFIX/opt/coreutils/libexec/gnubin" ]]; then
    export PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
  fi
fi

# ---------- fnm ----------
for fnm_path in \
  "$HOME/.local/share/fnm" \
  "$HOME/.fnm" \
  "/opt/homebrew/opt/fnm/bin" \
  "/usr/local/opt/fnm/bin"
do
  if [[ -d "$fnm_path" ]]; then
    export PATH="$fnm_path:$PATH"
    break
  fi
done

if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --version-file-strategy=recursive --corepack-enabled --use-on-cd --shell zsh)"
fi

# ---------- ls replacement ----------
if command -v eza >/dev/null 2>&1; then
  alias ls='eza'
fi
