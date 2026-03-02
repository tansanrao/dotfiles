# Dotfiles
A clean, declarative dotfiles repository using GNU Stow and simple bootstrap scripts for cross-platform development environment management.

## Quick Start
```
git clone https://github.com/tansanrao/dotfiles ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh scripts/bootstrap-*.sh
./install.sh
```

## Supported Hosts
- macOS (Homebrew + Brewfile)
- Fedora

## Terminal Agent Pipeline (Ghostty + tmux + Neovim)
- `Shift+Enter` soft newline is enforced in Ghostty with `keybind = shift+enter=text:\n`.
- tmux is standardized on `tmux-256color` with explicit terminal features for RGB/clipboard/focus/title.
- Neovim uses `unnamedplus`; when inside tmux it pins clipboard provider to `tmux`.
- tmux copy-mode uses vi-style selection/copy: `v` to begin selection, `C-v` for rectangle mode, `y` to copy.

### Remote Host Readiness Checks
Run these on remote hosts:
```bash
tmux -V
infocmp -x tmux-256color
echo "$TERM"
tmux info | rg 'Ms|RGB|clipboard'
```

Expected:
- `tmux -V` is `>= 3.2`.
- `tmux-256color` terminfo exists.
- Outside tmux, `TERM` is `xterm-ghostty` or `xterm-256color`.
- Inside tmux, `TERM` is `tmux-256color`.

If `tmux-256color` is missing, install `ncurses-term` (or distro equivalent).

### Validation Commands
```bash
# key propagation (press Enter and Shift+Enter)
cat -v

# truecolor
printf '\033[38;2;255;100;0mTRUECOLOR\033[0m\n'
```

### Codex Fallback Note
- Primary newline behavior comes from Ghostty keybinding and applies to Codex + Claude.
- Codex `0.106.0` does not currently expose a documented `config.toml` keybinding field in the official `config-schema.json`; if this changes in a later release, add a Codex-specific Shift+Enter newline binding there.
