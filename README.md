# Dotfiles
Root-first, deterministic dotfiles bootstrap for a known-good OS matrix.

## Quick Start
```bash
git clone https://github.com/tansanrao/dotfiles ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh scripts/*.sh tests/container/*.sh
./install.sh
```

## Supported Hosts
- macOS (Homebrew + Brewfile)
- Fedora 43
- Rocky Linux 9 / 10
- CentOS Stream 9 / 10
- Ubuntu 24.04 LTS / 25.10

## Installer Behavior
`./install.sh` bootstraps by default.

- Linux default mode is root-first:
- If root: run privileged bootstrap directly.
- If non-root + usable sudo: run privileged bootstrap via sudo.
- If sudo is unavailable (or unusable in non-interactive mode): fail with guidance to rerun with `--no-root`.
- macOS runs bootstrap + Brewfile by default.

### Fallback Modes
Only two Linux fallback modes are supported:
- `--no-root`: user-space bootstrap path (no package-manager installs as root).
- `--no-stow`: use built-in symlink linker when GNU stow is unavailable.

Compatibility:
- `--allow-link-fallback` is kept as a deprecated alias for `--no-stow`.
- EL10 hosts auto-enable no-stow linker mode when `stow` is unavailable.

### Other Flags
- `--only a,b,c`: restrict dotfile components (`git,zsh,tmux,neovim,ghostty`).
- `--skip-plugins`: skip zsh/tmux plugin clone/update.
- `--dry-run`: print actions without mutating files.

## Toolchain Strategy
- Node.js is standardized via `fnm` to latest `v24.x` on each run.
- Rust is standardized via `rustup` stable.
- Linux Neovim is installed from upstream release tarballs (`v0.11.6` target), enforcing LazyVim minimum `>= 0.11.2`.

## Example Runs
```bash
# default root-first behavior
./install.sh

# explicit user-space + no-stow fallback
./install.sh --no-root --no-stow

# focused server setup
./install.sh --no-root --no-stow --only zsh,tmux,neovim
```

## Plugin Paths
Plugins are cloned into user data locations:
- Zsh plugins: `${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/plugins/zsh`
- TPM: `${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm`

## Container Test Matrix
Run Linux matrix tests:
```bash
./scripts/test-install-matrix.sh --suite all
```

Subset examples:
```bash
./scripts/test-install-matrix.sh --suite root --images fedora,rocky9,rocky10,cs9,cs10,ubuntu2404,ubuntu2510
./scripts/test-install-matrix.sh --suite guards --images fedora,rocky9,rocky10,cs9,cs10,ubuntu2404,ubuntu2510
./scripts/test-install-matrix.sh --suite noroot --images fedora,rocky9,rocky10,cs9,cs10,ubuntu2404,ubuntu2510
```

Optional report:
```bash
./scripts/test-install-matrix.sh --suite all --json-report tests/artifacts/report.json
```
