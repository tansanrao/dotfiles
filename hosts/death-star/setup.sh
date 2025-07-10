#!/usr/bin/env bash
# Host-specific setup for death-star (Linux development machine)

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source library functions
source "$DOTFILES_DIR/scripts/lib/common.sh"
source "$DOTFILES_DIR/scripts/lib/linux.sh"

# Host configuration
HOSTNAME="death-star"

# Check we're on Linux
check_linux || exit 1

# Define packages for this host
ESSENTIAL_PACKAGES=($(get_essential_packages))
DEV_PACKAGES=($(get_development_packages))
UTILITY_PACKAGES=($(get_utility_packages))

# Define dotfiles
DOTFILES_PACKAGES=($(get_development_dotfiles))

# Define mise tools
MISE_TOOLS=($(get_development_mise_tools))

# Main setup function
main() {
    # Update packages
    update_packages
    
    # Install packages
    install_system_packages "${ESSENTIAL_PACKAGES[@]}" "${DEV_PACKAGES[@]}" "${UTILITY_PACKAGES[@]}"
    
    # Install development tools
    install_development_tools
    
    # Fix Ubuntu command names if needed
    fix_ubuntu_commands
    
    # Set hostname
    set_hostname "$HOSTNAME"
    
    # Create directories
    create_host_directories "$HOME/workspace"
    
    # Setup shell and tmux plugins
    setup_shell_plugins
    setup_tmux_plugins
    
    # Stow dotfiles
    stow_packages "${DOTFILES_PACKAGES[@]}"
    
    # Setup mise tools
    install_mise_tools "${MISE_TOOLS[@]}"
    use_mise_tools_globally "${MISE_TOOLS[@]}"
    
    # Change shell to zsh
    change_shell_to_zsh
}

# Run main function
main "$@" 