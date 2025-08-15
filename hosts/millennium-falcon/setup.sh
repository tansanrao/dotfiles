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

# DECLARATIVE PACKAGE MANAGEMENT
# Only packages listed below will remain installed
# Any brew packages/casks not in these lists will be REMOVED
# MAS apps cannot be removed via CLI but will be reported
#
# To skip removal of unlisted packages (install-only mode):
#   SKIP_REMOVAL=1 ./setup.sh

# Override default package lists for this host if needed
# Using defaults from macos.sh which include all packages
BREW_PACKAGES=($(get_brew_packages))
BREW_CASKS=($(get_brew_casks))
MAS_APPS=($(get_mas_apps))

# Example of how to override with custom lists:
# BREW_PACKAGES=("curl" "wget" "git" "stow" "neovim" "tmux")
# BREW_CASKS=("alacritty" "discord")
# MAS_APPS=("937984704")  # Amphetamine

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

    # Install packages declaratively (removes unlisted packages)
    setup_brew_declaratively "${BREW_PACKAGES[@]}"
    setup_casks_declaratively "${BREW_CASKS[@]}"
    setup_mas_declaratively "${MAS_APPS[@]}"

    # Configure dock
    # configure_dock "${DOCK_APPS[@]}"

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
