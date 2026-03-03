# Dotfiles
Root-first, multi-OS dotfiles with guarded no-root and no-stow fallbacks.

## Quick Start
```bash
git clone https://github.com/tansanrao/dotfiles ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh scripts/*.sh tests/container/*.sh
./install.sh
```

## Supported Hosts
- macOS (Homebrew + Brewfile)
- Fedora
- Rocky Linux 9 / 10
- CentOS Stream 9 / 10
- Ubuntu 24.04 LTS

## Installer Behavior
`./install.sh` now bootstraps by default.

- Linux default mode is root-first:
- If root: run privileged bootstrap directly.
- If non-root + usable sudo: run privileged bootstrap via sudo.
- If sudo is unavailable (or unusable in non-interactive mode): fail with guidance to rerun with `--no-root`.
- macOS runs bootstrap + Brewfile by default.

### Flags
- `--no-root`: enable user-space bootstrap fallback on Linux (best-effort installs; unavailable tools are skipped with warnings).
- `--only a,b,c`: restrict dotfile components (`git,zsh,tmux,neovim,ghostty`).
- `--skip-plugins`: skip zsh/tmux plugin clone/update.
- `--allow-link-fallback`: allow symlink linker when `stow` is missing.
- `--dry-run`: print actions without mutating files.

## Neovim Strategy
- Linux uses a pinned upstream Neovim release (`v0.11.6`) via official tarball install.
- LazyVim minimum is enforced (`>= 0.11.2`).
- This avoids stale distro Neovim on EL/Ubuntu channels.

## Root vs No-Root Examples
```bash
# default root-first behavior
./install.sh

# explicit user-space fallback
./install.sh --no-root --allow-link-fallback

# focused server setup
./install.sh --no-root --allow-link-fallback --only zsh,tmux,neovim
```

## Plugin Paths
Plugins are cloned into user data locations:
- Zsh plugins: `${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/plugins/zsh`
- TPM: `${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm`

## Container Test Matrix
Run Linux matrix tests (full install assertions):
```bash
./scripts/test-install-matrix.sh --suite all
```

Subset examples:
```bash
./scripts/test-install-matrix.sh --suite root --images fedora,rocky9,ubuntu2404
./scripts/test-install-matrix.sh --suite guards --images rocky9,ubuntu2404
./scripts/test-install-matrix.sh --suite noroot --images cs9,cs10
```

Optional report:
```bash
./scripts/test-install-matrix.sh --suite all --json-report tests/artifacts/report.json
```

## Legacy Local Cleanup
If you previously had plugin clones in `stow/`, remove legacy local copies:
```bash
rm -rf \
  ~/.dotfiles/stow/zsh/.config/zsh/pure \
  ~/.dotfiles/stow/zsh/.config/zsh/zsh-syntax-highlighting \
  ~/.dotfiles/stow/tmux/.config/tmux/plugins
```
