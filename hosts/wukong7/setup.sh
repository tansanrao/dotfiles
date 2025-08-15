#!/usr/bin/env bash
# Host-specific setup for wukong7 (Linux server)

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source library functions
source "$DOTFILES_DIR/scripts/lib/common.sh"
source "$DOTFILES_DIR/scripts/lib/linux.sh"

# Host configuration
HOSTNAME="wukong7"

# Check we're on Linux
check_linux || exit 1

# Define packages for this host (minimal server setup)
# Override with minimal packages for server
get_cli_packages() {
    local distro=$(detect_linux_distro)
    case "$distro" in
        debian)
            echo "curl wget git build-essential stow neovim tmux zsh htop rsync"
            ;;
        rhel)
            echo "curl wget git gcc gcc-c++ make stow neovim tmux zsh htop rsync"
            ;;
        arch)
            echo "curl wget git base-devel stow neovim tmux zsh htop rsync"
            ;;
        *)
            echo "curl wget git stow neovim tmux zsh htop rsync"
            ;;
    esac
}

CLI_PACKAGES=($(get_cli_packages))
GUI_PACKAGES=()  # No GUI packages for server

# Define dotfiles (no GUI tools for server)
DOTFILES_PACKAGES=($(get_server_dotfiles))

# Define mise tools (none for server)
MISE_TOOLS=($(get_server_mise_tools))

# Main setup function
main() {
    # Update packages
    update_packages
    
    # Install packages
    install_system_packages "${CLI_PACKAGES[@]}" "${GUI_PACKAGES[@]}"
    
    # Skip development tools like mise, zoxide on server
    # fix_ubuntu_commands not needed without fd/bat
    
    # Set hostname
    set_hostname "$HOSTNAME"

    # Create directories
    create_host_directories "$HOME/workspace"
    
    # Setup shell and tmux plugins
    setup_shell_plugins
    setup_tmux_plugins
    
    # Stow dotfiles
    stow_packages "${DOTFILES_PACKAGES[@]}"
    
    # Skip mise tools on server (none configured)
    
    # Change shell to zsh
    change_shell_to_zsh
}

# Run main function
main "$@" 