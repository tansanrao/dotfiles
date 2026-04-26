# Dotfiles

Dotfiles bootstrap for macOS workstations and Ubuntu servers/containers.

## Quick Start
```bash
git clone https://github.com/tansanrao/dotfiles ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh scripts/*.sh tests/container/*.sh
./install.sh
```

## Supported Hosts
- macOS with Homebrew and the tracked `Brewfile`
- Ubuntu major version 24 or newer

Linux hosts other than Ubuntu are intentionally unsupported.

## Installer Behavior
`./install.sh` bootstraps by default.

Rerunning `./install.sh` is safe. It reapplies links and updates managed tools/plugins instead of requiring a clean machine.

macOS behavior is unchanged:
- Run `scripts/bootstrap-mac.sh`.
- Apply the tracked `Brewfile` when Homebrew is available.
- Link macOS-relevant dotfile components, including Ghostty when installed.

Ubuntu behavior is privilege-aware:
- If running as root or with usable sudo, install apt packages and toolchains.
- If root/sudo is unavailable, skip package installs, Rust, Node, pnpm, Neovim, and plugins.
- Dotfiles are still linked in no-root mode.

## Linking
- Use GNU `stow` when available.
- On privileged Ubuntu, install `stow` through apt when it is missing.
- If `stow` is unavailable, use the built-in symlink fallback automatically.
- Repeated runs restow or reuse existing fallback symlinks.

## Options
- `--only a,b,c`: restrict dotfile components.
- `--skip-plugins`: skip zsh/tmux plugin clone/update.
- `--dry-run`: print actions without mutating files.
- `-h`, `--help`: show help.

Supported components:
- macOS: `git,zsh,tmux,neovim,ghostty`
- Ubuntu: `git,zsh,tmux,neovim`

## Toolchain Strategy
Privileged Ubuntu installs:
- Rust via `rustup` stable.
- Node.js via `fnm`, pinned to the latest `v24.x` available at install time.
- pnpm via Corepack.
- Neovim from upstream Linux release tarballs (`v0.11.6` target), enforcing LazyVim minimum `>= 0.11.2`.

On rerun, these steps update existing managed installs where appropriate and skip work that already satisfies the target version.

## Plugin Paths
Plugins are cloned only during privileged installs:
- Zsh plugins: `${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles/plugins/zsh`
- TPM: `${XDG_DATA_HOME:-$HOME/.local/share}/tmux/plugins/tpm`

## Container Test Matrix
Run Ubuntu matrix tests:
```bash
./scripts/test-install-matrix.sh --suite all
```

Subset examples:
```bash
./scripts/test-install-matrix.sh --suite root --images ubuntu2404
./scripts/test-install-matrix.sh --suite noroot --images ubuntu2404
./scripts/test-install-matrix.sh --suite guards --images ubuntu2204
```

Optional report:
```bash
./scripts/test-install-matrix.sh --suite all --json-report tests/artifacts/report.json
```
