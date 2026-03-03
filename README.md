# Dotfiles
Portable-first dotfiles managed with GNU Stow (or optional symlink fallback).

## Quick Start
```bash
git clone https://github.com/tansanrao/dotfiles ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh scripts/*.sh
./install.sh
```

## Install Modes
`./install.sh` is now configure-only by default:
- Detects installed tools.
- Applies only matching dotfile components.
- Skips missing tools.
- Installs zsh/tmux plugin repos only for selected components.

### Restricted Host Examples
```bash
# Configure only the tools you care about, skip the rest
./install.sh --only zsh,tmux,neovim

# Same as above, but use fallback linker if stow is unavailable
./install.sh --only zsh,tmux,neovim --allow-link-fallback

# Preview actions without changing files
./install.sh --only zsh,tmux,neovim --dry-run
```

### Full Bootstrap (explicit opt-in)
```bash
./install.sh --bootstrap
```
Bootstrap currently supports:
- macOS (Homebrew + `Brewfile`)
- Fedora

## Installer Flags
- `--bootstrap`: run OS bootstrap/package install scripts.
- `--only a,b,c`: limit to selected components (`git,zsh,tmux,neovim,ghostty`).
- `--skip-plugins`: skip zsh/tmux plugin clone/update.
- `--allow-link-fallback`: use `scripts/link-with-symlinks.sh` if GNU Stow is missing.
- `--dry-run`: print actions without changing files.

## Plugin Paths
Plugin repos are cloned into user data paths, not inside `stow/`:
- Zsh plugins: `${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/plugins/zsh`
- TPM: `${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm`

## Legacy Local Cleanup
If you used the old layout, remove legacy local plugin directories under `stow/`:
```bash
rm -rf \
  ~/.dotfiles/stow/zsh/.config/zsh/pure \
  ~/.dotfiles/stow/zsh/.config/zsh/zsh-syntax-highlighting \
  ~/.dotfiles/stow/tmux/.config/tmux/plugins
```

## Terminal Pipeline Notes
- Ghostty: `Shift+Enter` soft newline via `keybind = shift+enter=text:\n`.
- tmux: prefers `tmux-256color`, falls back when terminfo is unavailable.
- Neovim: tries to bootstrap `lazy.nvim`; if unavailable (or no `git`), opens without plugin manager instead of exiting.
