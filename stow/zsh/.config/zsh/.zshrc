# ---------- OS helpers ----------
is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux() { [[ "$(uname -s)" == "Linux" ]]; }

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

# ---------- Shared history (common across all shells) ----------
# Where to store history
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=500000          # in-memory history lines
SAVEHIST=500000          # lines to save to $HISTFILE

# Write each command to $HISTFILE as soon as it’s executed
setopt INC_APPEND_HISTORY        # append immediately
setopt SHARE_HISTORY             # import new lines from other sessions

# Make the history cleaner and search nicer
setopt EXTENDED_HISTORY          # record timestamps, etc.
setopt HIST_IGNORE_DUPS          # ignore consecutive dups
setopt HIST_SAVE_NO_DUPS         # don't save duplicates
setopt HIST_FIND_NO_DUPS         # don't show dups in searches
setopt HIST_REDUCE_BLANKS        # trim superfluous spaces
setopt HIST_IGNORE_SPACE         # commands starting with a space aren't saved
setopt HIST_EXPIRE_DUPS_FIRST    # expire older dups first when trimming

# ---------- make `fd` available on Ubuntu (symlink fdfind -> fd) ----------
# Put ~/.local/bin early on PATH so our symlink is picked up
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
else
  mkdir -p "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
fi

# On Linux/Ubuntu, `fd` is often installed as `fdfind`. If `fd` is missing,
# create a user-local symlink so tools can just call `fd`.
if is_linux; then
  if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
fi

# ---------- homebrew prefix (macOS + Linuxbrew) ----------
if command -v brew >/dev/null 2>&1; then
  export BREW_PREFIX="$(brew --prefix)"
fi

# ---------- fzf ----------
if command -v fzf >/dev/null 2>&1; then
  # Try Homebrew paths first (macOS or Linuxbrew)
  if [[ -n "$BREW_PREFIX" ]]; then
    [[ -f "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] && source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
    [[ -f "$BREW_PREFIX/opt/fzf/shell/completion.zsh"   ]] && source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"
  fi
  # Debian/Ubuntu package paths
  [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh     ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
  [[ -f /usr/share/doc/fzf/examples/completion.zsh       ]] && source /usr/share/doc/fzf/examples/completion.zsh

  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fd --type f --hidden --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  else
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  fi

  export FZF_DEFAULT_OPTS='--height 30% --layout=reverse --border'
fi

# ---------- zoxide ----------
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# ---------- mise (development tools) ----------
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# ---------- Pure prompt ----------
if [[ -d "$HOME/.config/zsh/pure" ]]; then
  fpath+=("$HOME/.config/zsh/pure")
fi

autoload -U promptinit
promptinit
# Only attempt to use Pure if it’s available
if whence -w prompt_pure_setup >/dev/null 2>&1 || whence -w prompt_pure >/dev/null 2>&1; then
  prompt pure
fi

# ---------- Syntax highlighting ----------
if [[ -f "$HOME/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
  source "$HOME/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# ---------- Local environment ----------
[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# ---------- macOS-specific niceties (safe no-ops on Linux) ----------
if is_macos; then
  # Prefer Homebrew coreutils (if installed) for consistent behavior
  if [[ -n "$BREW_PREFIX" && -d "$BREW_PREFIX/opt/coreutils/libexec/gnubin" ]]; then
    export PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
  fi
fi

# fnm homebrew
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "`fnm env --version-file-strategy=recursive --corepack-enabled --use-on-cd --shell zsh`"
fi

# fnm ubuntu
FNM_PATH="/home/tansanrao/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "`fnm env --version-file-strategy=recursive --corepack-enabled --use-on-cd --shell zsh`"
fi
