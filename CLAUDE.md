# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages configuration files and development environment setup across multiple hosts using GNU stow, mise for development tools, and platform-specific package managers.

## Core Architecture

- **Host-based configuration**: Each machine has a specific setup in `hosts/[hostname]/setup.sh`
- **Stow-based linking**: Dotfiles are organized in packages (zsh, git, neovim, tmux, alacritty, mise) and symlinked via GNU stow
- **Library functions**: Common functionality is abstracted in `scripts/lib/` with platform-specific implementations
- **Platform support**: macOS (Homebrew), Ubuntu/Debian (apt), RHEL/Fedora (dnf), Arch Linux (pacman)

## Common Commands

### Installation
```bash
# Full installation (detects hostname and runs host-specific setup)
./install.sh

# Manual platform-specific installation
./scripts/macos/setup.sh       # macOS
./scripts/ubuntu/setup.sh      # Ubuntu/Debian
```

### Dotfiles Management
```bash
# Link all dotfiles packages
./scripts/common/stow-dotfiles.sh

# Link specific package
./scripts/common/stow-dotfiles.sh stow neovim

# Unlink package
cd ~/.dotfiles && stow -D neovim
```

### Development Tools (mise)
```bash
# Install configured tools
mise install

# Install specific tool
mise install node@lts python@3.12

# Use tool globally
mise use -g node@lts

# Check installed tools
mise list
```

### Package Management
```bash
# macOS - install packages/casks
brew install neovim tmux zsh
brew install --cask alacritty discord

# Update packages
brew update && brew upgrade
```

### Tmux Plugin Management
```bash
# Install tmux plugins after linking dotfiles
~/.config/tmux/plugins/tpm/bin/install_plugins

# Update tmux plugins
~/.config/tmux/plugins/tpm/bin/update_plugins

# Remove unlisted plugins
~/.config/tmux/plugins/tpm/bin/clean_plugins

# Reload tmux config (from within tmux)
prefix + R
```

## Key Files and Structure

- `install.sh` - Main entry point, detects hostname and delegates to host-specific setup
- `hosts/[hostname]/setup.sh` - Host-specific configuration (millennium-falcon, death-star, x-wing, wukong7)
- `scripts/lib/common.sh` - Cross-platform functions (stow_packages, setup_shell_plugins, install_mise_tools)
- `scripts/lib/macos.sh` - macOS-specific functions (install_homebrew, install_brew_packages, configure_dock)
- `scripts/lib/linux.sh` - Linux-specific functions for various distributions
- `scripts/common/stow-dotfiles.sh` - GNU stow wrapper for linking dotfiles packages

## Configuration Packages

Each application configuration is organized as a stow package:
- `zsh/` - Shell configuration with pure prompt and syntax highlighting
- `git/` - Git configuration and global ignore patterns
- `neovim/` - Neovim configuration and plugins
- `tmux/` - Terminal multiplexer configuration with TPM
- `alacritty/` - Terminal emulator configuration
- `mise/` - Development tool version management

## Development Workflow

1. **Adding new host**: Create `hosts/[hostname]/setup.sh` following existing patterns
2. **Modifying dotfiles**: Edit files in respective package directories, run stow to update symlinks
3. **Adding tools**: Update mise configuration in `mise/.config/mise/config.toml`
4. **Platform packages**: Modify package lists in `scripts/lib/[platform].sh`

## Host Configurations

- **millennium-falcon** - macOS development machine with full productivity stack
- **death-star** - Linux development machine  
- **x-wing** - Linux lab workstation
- **wukong7** - Linux server with minimal setup

New hosts should follow the pattern of sourcing library functions and defining package arrays for their specific needs.