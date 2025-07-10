#!/usr/bin/env bash
# Host-specific setup for millennium-falcon (macOS development machine)

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source library functions
source "$DOTFILES_DIR/scripts/lib/common.sh"
source "$DOTFILES_DIR/scripts/lib/macos.sh"

# Host configuration
HOSTNAME="millennium-falcon"

# Check we're on macOS
check_macos || exit 1

# Define packages for this host
ESSENTIAL_PACKAGES=($(get_essential_packages))
DEV_PACKAGES=($(get_development_packages))
DEV_TOOLS_PACKAGES=($(get_dev_tools_packages))

# Define casks
ESSENTIAL_CASKS=($(get_essential_casks))
DEV_CASKS=($(get_development_casks))
PRODUCTIVITY_CASKS=($(get_productivity_casks))

# Define MAS apps
ESSENTIAL_MAS_APPS=($(get_essential_mas_apps))
DEV_MAS_APPS=($(get_development_mas_apps))
PRODUCTIVITY_MAS_APPS=($(get_productivity_mas_apps))

# Define dotfiles
DOTFILES_PACKAGES=($(get_development_dotfiles))

# Define mise tools
MISE_TOOLS=($(get_development_mise_tools))

# Define dock applications
DOCK_APPS=(
    "/Applications/Slack.app"
    "/Applications/Alacritty.app"
    "/Applications/Obsidian.app"
    "/Applications/Mail.app"
    "/Applications/Proton Mail.app"
    "/Applications/Fantastical.app"
    "/Applications/Music.app"
    "/Applications/Safari.app"
)

# Main setup function
main() {
    # Install Homebrew
    install_homebrew
    
    # Install packages
    install_brew_packages "${ESSENTIAL_PACKAGES[@]}" "${DEV_PACKAGES[@]}" "${DEV_TOOLS_PACKAGES[@]}"
    install_brew_casks "${ESSENTIAL_CASKS[@]}" "${DEV_CASKS[@]}" "${PRODUCTIVITY_CASKS[@]}"
    install_mas_apps "${ESSENTIAL_MAS_APPS[@]}" "${DEV_MAS_APPS[@]}" "${PRODUCTIVITY_MAS_APPS[@]}"
    
    # Configure dock
    configure_dock "${DOCK_APPS[@]}"
    
    # Configure macOS system defaults
    configure_system_defaults
    
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
}

# Run main function
main "$@" 