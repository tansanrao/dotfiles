#!/usr/bin/env bash
# Common function library for all platforms

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

# Get the dotfiles directory
get_dotfiles_dir() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "$(cd "$script_dir/../.." && pwd)"
}

# Check if stow is available
check_stow() {
    if ! command -v stow &> /dev/null; then
        print_error "GNU stow is not installed!"
        return 1
    fi
    return 0
}

# Stow specific dotfile packages
stow_packages() {
    local packages=("$@")
    local dotfiles_dir=$(get_dotfiles_dir)
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi
    
    if ! check_stow; then
        return 1
    fi
    
    cd "$dotfiles_dir"
    for package in "${packages[@]}"; do
        if [[ -d "$package" ]]; then
            stow --target="$HOME" "$package" >/dev/null 2>&1
        fi
    done
}

# Setup shell plugins
setup_shell_plugins() {
    mkdir -p ~/.config/zsh
    
    # Install pure prompt
    if [[ ! -d ~/.config/zsh/pure ]]; then
        git clone --quiet https://github.com/sindresorhus/pure.git ~/.config/zsh/pure
    fi
    
    # Install zsh-syntax-highlighting
    if [[ ! -d ~/.config/zsh/zsh-syntax-highlighting ]]; then
        git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.config/zsh/zsh-syntax-highlighting
    fi
}

# Setup tmux plugins
setup_tmux_plugins() {
    mkdir -p ~/.config/tmux/plugins
    
    # Install TPM (Tmux Plugin Manager)
    if [[ ! -d ~/.config/tmux/plugins/tpm ]]; then
        git clone --quiet https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
    fi
}

# Install specific mise tools
install_mise_tools() {
    local tools=("$@")
    
    if [[ ${#tools[@]} -eq 0 ]]; then
        return 0
    fi
    
    if ! command -v mise &> /dev/null; then
        return 1
    fi
    
    for tool in "${tools[@]}"; do
        mise install "$tool" >/dev/null 2>&1
    done
}

# Use specific mise tools globally
use_mise_tools_globally() {
    local tools=("$@")
    
    if [[ ${#tools[@]} -eq 0 ]]; then
        return 0
    fi
    
    if ! command -v mise &> /dev/null; then
        return 1
    fi
    
    for tool in "${tools[@]}"; do
        mise use -g "$tool" >/dev/null 2>&1
    done
}

# Common dotfile package sets
get_all_dotfiles() {
    echo "zsh git neovim tmux alacritty mise"
}

get_essential_dotfiles() {
    echo "zsh git"
}

get_development_dotfiles() {
    echo "zsh git neovim tmux alacritty mise"
}

# Common mise tool sets
get_essential_mise_tools() {
    echo "node@lts python@3.12"
}

get_development_mise_tools() {
    echo "node@lts python@3.12"
}

# Create host-specific directories
create_host_directories() {
    local dirs=("$@")
    
    if [[ ${#dirs[@]} -eq 0 ]]; then
        return 0
    fi
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir" >/dev/null 2>&1
    done
}

# Set hostname if different from current
set_hostname() {
    local new_hostname="$1"
    local current_hostname=$(hostname)
    
    if [[ -z "$new_hostname" ]] || [[ "$current_hostname" == "$new_hostname" ]]; then
        return 0
    fi
    
    case "$(uname)" in
        Darwin)
            sudo scutil --set HostName "$new_hostname"
            sudo scutil --set LocalHostName "$new_hostname"
            sudo scutil --set ComputerName "$new_hostname"
            ;;
        Linux)
            sudo hostnamectl set-hostname "$new_hostname" >/dev/null 2>&1
            ;;
    esac
} 