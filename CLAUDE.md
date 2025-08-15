# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a modern personal dotfiles repository that manages configuration files and development environment setup using GNU Stow, Homebrew Bundle, and Make for declarative, cross-platform package management.

## Core Architecture

- **Makefile-driven**: Primary interface using make targets for all operations
- **Declarative packages**: Brewfile for macOS, package lists for Linux  
- **GNU Stow**: Symlink management for dotfiles in stow/ directory
- **Minimal scripting**: Bootstrap scripts only, no complex bash libraries
- **Cross-platform**: macOS (Homebrew), Ubuntu/Debian (apt), RHEL/Fedora (dnf), Arch Linux (pacman)

## Repository Structure

```
~/.dotfiles/
├── Makefile              # Main orchestration - primary interface
├── README.md             # Comprehensive documentation
├── packages/             # Declarative package management
│   ├── Brewfile          # macOS packages (Homebrew Bundle)
│   ├── apt-packages.txt  # Ubuntu/Debian packages
│   └── mise-tools.txt    # Development tools (Node, Python)
├── stow/                 # GNU Stow packages (dotfiles)
│   ├── alacritty/
│   ├── git/
│   ├── mise/
│   ├── neovim/
│   ├── tmux/
│   └── zsh/
├── scripts/              # Minimal bootstrap scripts
│   ├── bootstrap-mac.sh
│   ├── bootstrap-linux.sh
│   └── install-plugins.sh
└── config/               # Optional host-specific overrides
```

## Common Commands

### Primary Interface (Makefile)
```bash
# Main operations
make install        # Install everything for current platform
make help          # Show all available commands
make packages      # Install packages only
make dotfiles      # Install dotfiles via stow
make plugins       # Install zsh/tmux plugins

# Platform-specific
make macos         # Full macOS setup
make linux         # Full Linux setup

# Maintenance
make update        # Update packages and repository
make clean         # Remove dotfile symlinks
make status        # Show installation status
```

### Package Management

#### macOS (Homebrew Bundle)
```bash
# Install packages from Brewfile
brew bundle --file=packages/Brewfile

# Generate Brewfile from current packages
brew bundle dump --file=packages/Brewfile -f

# Remove packages not in Brewfile
brew bundle cleanup --file=packages/Brewfile
```

#### Linux (Package Lists)
```bash
# Install packages from list
xargs -a packages/apt-packages.txt sudo apt install -y
```

### Dotfiles Management (GNU Stow)
```bash
# Install all dotfiles
cd stow && stow -t $HOME */

# Install specific package
cd stow && stow -t $HOME zsh

# Remove dotfiles
cd stow && stow -D -t $HOME */
```

### Development Tools (mise)
```bash
# Install tools from list
while read tool; do mise install "$tool"; done < packages/mise-tools.txt

# Use tools globally
while read tool; do mise use -g "$tool"; done < packages/mise-tools.txt
```

## Key Files and Concepts

- `Makefile` - Primary interface, replaces complex bash scripts
- `packages/Brewfile` - Declarative macOS package management
- `packages/apt-packages.txt` - Simple Linux package list
- `stow/*/` - Each subdirectory is a stow package for an application
- `scripts/bootstrap-*.sh` - Minimal platform setup (install package managers)
- `scripts/install-plugins.sh` - Zsh and tmux plugin installation

## Development Workflow

1. **Adding packages**: Edit Brewfile or apt-packages.txt, run `make packages`
2. **Adding dotfiles**: Create stow package directory, run `make dotfiles`
3. **Host-specific config**: Use `make host-config` to create overrides
4. **Testing changes**: Use `make clean && make install` for fresh setup

## Host Configurations

The new approach supports host-specific configuration through:
- `packages/Brewfile.$(hostname)` - Additional packages per host
- `config/$(hostname)/` - Host-specific dotfile overrides

No complex host-specific setup scripts - keep it simple.

## Migration Notes

This repository was refactored from a complex host-based system to a modern, declarative approach:

- **Removed**: Complex bash libraries, host-specific setup scripts
- **Added**: Makefile orchestration, Brewfile, simplified bootstrap
- **Kept**: GNU Stow, mise, cross-platform support

The new structure follows 2024-2025 best practices for dotfiles management.