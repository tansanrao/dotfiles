# Modern Dotfiles

A clean, declarative dotfiles repository using GNU Stow, Homebrew Bundle, and Make for cross-platform development environment management.

## Quick Start

```bash
git clone https://github.com/tansanrao/dotfiles ~/.dotfiles
cd ~/.dotfiles
make install
```

## Features

- **Declarative package management** - Brewfile for macOS, apt/snap for Ubuntu
- **GNU Stow integration** - Clean symlink management
- **Cross-platform support** - macOS and Ubuntu/Debian
- **Minimal complexity** - No custom bash libraries, leverage existing tools
- **Host-specific configs** - Override defaults per machine
- **Development tools** - mise for Node.js, Python, etc.

## Architecture

### Repository Structure

```
~/.dotfiles/
├── Makefile              # Main orchestration
├── README.md             # This file
├── .gitignore
│
├── packages/             # Declarative package management
│   ├── Brewfile          # macOS packages (Homebrew)
│   ├── Brewfile.work     # Host-specific additions (optional)
│   ├── apt-packages.txt  # Ubuntu/Debian packages
│   ├── snap-packages.txt # Snap packages (for latest Neovim)
│   └── mise-tools.txt    # Development tools
│
├── stow/                 # GNU Stow packages (dotfiles)
│   ├── alacritty/
│   ├── git/
│   ├── mise/
│   ├── neovim/
│   ├── tmux/
│   └── zsh/
│
├── scripts/              # Bootstrap scripts
│   ├── bootstrap-mac.sh
│   ├── bootstrap-linux.sh
│   └── install-plugins.sh
│
└── config/               # Host-specific overrides
    ├── millennium-falcon/
    └── death-star/
```

### Core Principles

1. **Declarative over Imperative** - Define desired state, not steps
2. **Use Standard Tools** - Leverage Homebrew Bundle, GNU Stow, Make
3. **Minimal Custom Code** - Avoid complex bash scripting
4. **Cross-Platform** - Clean separation of platform concerns
5. **Idempotent** - Safe to run multiple times

## Usage

### Available Commands

```bash
make help           # Show all available commands
make install        # Install everything for current platform
make packages       # Install packages only
make dotfiles       # Install dotfiles via stow
make plugins        # Install zsh/tmux plugins
make update         # Update packages and repository
make clean          # Remove dotfile symlinks
make status         # Show installation status
```

### Platform-Specific Commands

```bash
make macos          # Full macOS setup
make linux          # Full Ubuntu/Debian setup
make packages-macos # Install Homebrew packages
make packages-linux # Install apt/snap packages
```

### Development Tools

```bash
make mise-tools     # Install Node.js, Python, etc.
```

## Package Management

### macOS (Homebrew)

Packages are defined in `packages/Brewfile`:

```ruby
# CLI tools
brew "git"
brew "neovim"
brew "tmux"

# GUI applications
cask "alacritty"
cask "slack"

# Mac App Store apps
mas "Xcode", id: 497799835
```

**Homebrew Bundle Commands:**
```bash
brew bundle --file=packages/Brewfile          # Install packages
brew bundle dump --file=packages/Brewfile -f  # Generate from current
brew bundle cleanup --file=packages/Brewfile  # Remove unlisted packages
```

### Ubuntu/Debian (apt)

System packages listed in `packages/apt-packages.txt`:

```
git
tmux
zsh
ripgrep
```

Snap packages in `packages/snap-packages.txt`:

```
nvim --classic  # Latest Neovim version
```

**Note**: Neovim is installed via Snap to ensure the latest version on Ubuntu, matching the macOS Homebrew version.

### Development Tools (mise)

Tools defined in `packages/mise-tools.txt`:

```
node@lts
python@3.12
```

## Dotfiles (GNU Stow)

Each application has its own stow package in `stow/`:

```
stow/zsh/
├── .zshenv
└── .config/
    └── zsh/
        ├── .zshrc
        └── aliases.zsh
```

**Stow Commands:**
```bash
stow -d stow -t ~ zsh        # Install zsh config
stow -D -d stow -t ~ zsh     # Remove zsh config
stow -d stow -t ~ */         # Install all configs
```

## Host-Specific Configuration

### Override Packages

Create host-specific Brewfiles:

```bash
# packages/Brewfile.millennium-falcon
brew "docker"
cask "sketch"
```

### Custom Configuration

```bash
mkdir -p config/$(hostname)
# Add host-specific dotfile overrides
```

## Initial Setup

### Prerequisites

**macOS:**
- Xcode Command Line Tools: `xcode-select --install`

**Ubuntu/Debian:**
- sudo access for package installation
- git (usually pre-installed)

### Bootstrap Process

1. **Clone repository**
   ```bash
   git clone https://github.com/username/dotfiles ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Run setup**
   ```bash
   make install
   ```

3. **Post-installation**
   ```bash
   # Change shell to zsh (if not default)
   chsh -s $(which zsh)

   # Install tmux plugins (from within tmux)
   # Press: prefix + I
   ```

## Customization

### Adding New Packages

**macOS:**
```bash
echo 'brew "new-tool"' >> packages/Brewfile
make packages-macos
```

**Ubuntu/Debian:**
```bash
echo "new-tool" >> packages/apt-packages.txt
make packages-linux
```

### Adding New Dotfiles

```bash
mkdir -p stow/app/.config/app
cp ~/.config/app/config.yml stow/app/.config/app/
make dotfiles
```

### Host-Specific Packages

```bash
make host-config  # Creates packages/Brewfile.$(hostname)
```

## Maintenance

### Update Everything

```bash
make update
```

### Check Status

```bash
make status
```

### Remove Symlinks

```bash
make clean
```

### Backup Current Config

```bash
make backup
```

## Troubleshooting

### Common Issues

1. **Stow conflicts** - Remove existing files/symlinks before stowing
2. **Permission errors** - Ensure proper sudo access on Ubuntu
3. **Missing tools** - Run platform bootstrap: `./scripts/bootstrap-mac.sh` or `./scripts/bootstrap-linux.sh`

### Debug Commands

```bash
make lint           # Check for common issues
make status         # Show current state
stow -n -v */      # Dry run stow (from stow/ directory)
```

### Manual Recovery

```bash
# Remove all symlinks and start fresh
make clean
make dotfiles

# Re-run package installation
make packages
```

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)
- [mise Documentation](https://mise.jdx.dev/)
- [Dotfiles Best Practices](https://dotfiles.github.io/)
