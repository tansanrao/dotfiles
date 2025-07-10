#!/usr/bin/env bash
# Linux function library for host scripts

# Simple output functions
print_info() {
    echo "INFO: $1"
}

print_warning() {
    echo "WARNING: $1"
}

print_error() {
    echo "ERROR: $1"
}

# Check if running on Linux
check_linux() {
    if [[ "$(uname)" != "Linux" ]]; then
        print_error "This script is for Linux only!"
        return 1
    fi
    return 0
}

# Detect Linux distribution
detect_linux_distro() {
    if command -v apt &> /dev/null; then
        echo "debian"
    elif command -v dnf &> /dev/null; then
        echo "rhel"
    elif command -v pacman &> /dev/null; then
        echo "arch"
    else
        echo "unknown"
    fi
}

# Update package lists
update_packages() {
    local distro=$(detect_linux_distro)
    
    case "$distro" in
        debian)
            sudo apt update -qq
            ;;
        rhel)
            sudo dnf check-update -q || true
            ;;
        arch)
            sudo pacman -Sy --quiet
            ;;
        *)
            print_warning "Unknown Linux distribution, skipping package update"
            ;;
    esac
}

# Install packages via system package manager
install_system_packages() {
    local packages=("$@")
    local distro=$(detect_linux_distro)
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi
    
    case "$distro" in
        debian)
            sudo apt install -y -qq "${packages[@]}"
            ;;
        rhel)
            sudo dnf install -y -q "${packages[@]}"
            ;;
        arch)
            sudo pacman -S --noconfirm --quiet "${packages[@]}"
            ;;
        *)
            print_error "Unknown Linux distribution. Please install packages manually: ${packages[*]}"
            return 1
            ;;
    esac
}

# Install development tools via various methods
install_development_tools() {
    # Install mise (development tool version manager)
    if ! command -v mise &> /dev/null; then
        curl -s https://mise.run | sh
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # Install zoxide (smarter cd command)
    if ! command -v zoxide &> /dev/null; then
        curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi
    
    # Install direnv
    if ! command -v direnv &> /dev/null; then
        curl -sfL https://direnv.net/install.sh | bash
    fi
}

# Fix command names on Ubuntu (bat -> batcat, fd -> fdfind)
fix_ubuntu_commands() {
    local distro=$(detect_linux_distro)
    
    if [[ "$distro" != "debian" ]]; then
        return 0
    fi
    
    # Fix bat command name (it's called batcat on Ubuntu)
    if command -v batcat &> /dev/null && ! command -v bat &> /dev/null; then
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/batcat ~/.local/bin/bat
    fi
    
    # Fix fd command name (it's called fdfind on Ubuntu)
    if command -v fdfind &> /dev/null && ! command -v fd &> /dev/null; then
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/fdfind ~/.local/bin/fd
    fi
}

# Change default shell to zsh
change_shell_to_zsh() {
    if [[ "$SHELL" == "/usr/bin/zsh" ]] || [[ "$SHELL" == "/bin/zsh" ]]; then
        return 0
    fi
    
    if command -v zsh &> /dev/null; then
        chsh -s $(which zsh)
    fi
}

# Common package sets for easy reuse
get_essential_packages() {
    local distro=$(detect_linux_distro)
    
    case "$distro" in
        debian)
            echo "curl wget git build-essential stow"
            ;;
        rhel)
            echo "curl wget git gcc gcc-c++ make stow"
            ;;
        arch)
            echo "curl wget git base-devel stow"
            ;;
        *)
            echo "curl wget git stow"
            ;;
    esac
}

get_development_packages() {
    local distro=$(detect_linux_distro)
    
    case "$distro" in
        debian)
            echo "neovim tmux zsh ripgrep fd-find fzf bat htop"
            ;;
        rhel)
            echo "neovim tmux zsh ripgrep fd-find fzf bat htop"
            ;;
        arch)
            echo "neovim tmux zsh ripgrep fd fzf bat htop"
            ;;
        *)
            echo "neovim tmux zsh"
            ;;
    esac
}

get_utility_packages() {
    echo "jq tree rsync"
} 