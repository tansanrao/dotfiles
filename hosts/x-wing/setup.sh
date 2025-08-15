#!/usr/bin/env bash
# Host-specific setup for x-wing (Linux lab workstation)

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source library functions
source "$DOTFILES_DIR/scripts/lib/common.sh"
source "$DOTFILES_DIR/scripts/lib/linux.sh"

# Host configuration
HOSTNAME="x-wing"

# Check we're on Linux
check_linux || exit 1

# Define packages for this host (shell-only workstation)
# Using default CLI packages from linux.sh
CLI_PACKAGES=($(get_cli_packages))
GUI_PACKAGES=()  # No GUI packages for this shell-only workstation

# Define dotfiles (no GUI apps like alacritty on shell-only workstation)
DOTFILES_PACKAGES=(zsh git neovim tmux mise)

# Define mise tools
MISE_TOOLS=($(get_essential_mise_tools))

# Main setup function
main() {
    # Update packages
    update_packages
    
    # Install packages
    install_system_packages "${CLI_PACKAGES[@]}" "${GUI_PACKAGES[@]}"
    
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