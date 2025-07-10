#!/usr/bin/env bash
# GNU Stow dotfiles management script

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Function to check if stow is available
check_stow() {
    if ! command -v stow &> /dev/null; then
        echo "ERROR: GNU stow is not installed!"
        case "$(uname)" in
            Darwin)
                echo "Install with: brew install stow"
                ;;
            Linux)
                echo "Install with your package manager: apt install stow"
                ;;
        esac
        exit 1
    fi
}

# Function to stow a package
stow_package() {
    local package="$1"
    local package_dir="$DOTFILES_DIR/$package"
    
    if [[ ! -d "$package_dir" ]]; then
        echo "ERROR: Package directory not found: $package"
        return 1
    fi
    
    cd "$DOTFILES_DIR"
    stow --target="$HOME" "$package" >/dev/null 2>&1
}

# Function to stow all packages
stow_all() {
    packages=(
        "zsh"
        "git"
        "neovim"
        "tmux"
        "alacritty"
        "mise"
    )
    
    for package in "${packages[@]}"; do
        if [[ -d "$DOTFILES_DIR/$package" ]]; then
            stow_package "$package"
        fi
    done
}

# Main function
main() {
    check_stow
    
    local command="${1:-stow}"
    local package="${2:-}"
    
    case "$command" in
        stow)
            if [[ -n "$package" ]]; then
                stow_package "$package"
            else
                stow_all
            fi
            ;;
        *)
            stow_all
            ;;
    esac
}

# Run main function
main "$@" 