# Dotfiles

Simple dotfiles repository for installing tools, configuring plugins, and linking dotfiles.

## Quick Start

```bash
git clone https://github.com/tansanrao/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## Overview

This repository handles:
- Tool installation via package managers
- Plugin configuration for shell and terminal
- Dotfile linking via GNU stow

### Supported Platforms

- macOS (Homebrew)
- Ubuntu/Debian (apt)
- RHEL/Fedora (dnf)
- Arch Linux (pacman)

### Configured Applications

- Shell: zsh with pure prompt and syntax highlighting
- Editor: Neovim
- Terminal: Alacritty
- Multiplexer: tmux
- Version Control: git
- Development tools: node, python (via mise)

## Directory Structure

```
.
├── install.sh          # Main installation script
├── hosts/              # Host-specific configurations
├── zsh/                # Zsh configuration
├── git/                # Git configuration  
├── neovim/             # Neovim configuration
├── tmux/               # Tmux configuration
├── alacritty/          # Alacritty configuration
├── mise/               # Development tool configuration
└── scripts/lib/        # Library functions
```

## Installation

Run the main script which detects your hostname and runs the appropriate setup:

```bash
./install.sh
```

This will:
1. Install system packages
2. Set up shell and tmux plugins
3. Link dotfiles using stow
4. Configure development tools with mise

## Host Configurations

The repository supports multiple hosts:

- **millennium-falcon** - macOS development machine
- **death-star** - Linux development machine
- **x-wing** - Linux lab workstation
- **wukong7** - Linux server

To create a new host configuration, add a setup script in `hosts/[hostname]/setup.sh`.

## Manual Setup

### Install System Packages

**macOS:**
```bash
./scripts/macos/setup.sh
```

**Ubuntu:**
```bash
./scripts/ubuntu/setup.sh
```

### Link Dotfiles

```bash
# Install stow
# macOS: brew install stow
# Ubuntu: sudo apt install stow

./scripts/common/stow-dotfiles.sh
```

### Set Up Development Tools

```bash
# Install mise
curl https://mise.run | sh

# Install development tools
mise install
```
