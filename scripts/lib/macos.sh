#!/usr/bin/env bash
# macOS function library for host scripts

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

# Check if running on macOS
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is for macOS only!"
        return 1
    fi
    return 0
}

# Install Homebrew if not present
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    brew update -q
}

# Install command-line tools via Homebrew
install_brew_packages() {
    local packages=("$@")

    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi

    brew install "${packages[@]}"
}

# Install cask applications via Homebrew
install_brew_casks() {
    local casks=("$@")

    if [[ ${#casks[@]} -eq 0 ]]; then
        return 0
    fi

    brew install --cask "${casks[@]}"
}

# Install Mac App Store apps
install_mas_apps() {
    local apps=("$@")

    if [[ ${#apps[@]} -eq 0 ]]; then
        return 0
    fi

    # Install mas-cli if not present
    if ! command -v mas &> /dev/null; then
        brew install mas
    fi

    for app_id in "${apps[@]}"; do
        mas install "$app_id"
    done
}

# Configure dock with specific applications
configure_dock() {
    local apps=("$@")

    if [[ ${#apps[@]} -eq 0 ]]; then
        return 0
    fi

    # Check if dockutil is installed
    if ! command -v dockutil &> /dev/null; then
        brew install dockutil
    fi

    # Remove all current dock items
    dockutil --remove all --no-restart

    # Add applications to dock
    for app in "${apps[@]}"; do
        if [[ -e "$app" ]]; then
            dockutil --add "$app" --no-restart
        fi
    done

    # Add Downloads folder to dock
    local downloads_path="$HOME/Downloads"
    if [[ -d "$downloads_path" ]]; then
        dockutil --add "$downloads_path" --view grid --display stack --sort name --section others --no-restart
    fi

    # Restart Dock to apply changes
    killall Dock
}

# Common package sets for easy reuse
get_essential_packages() {
    echo "curl wget git stow"
}

get_development_packages() {
    echo "neovim tmux zsh ripgrep fd fzf bat htop mise zoxide texlive"
}

get_dev_tools_packages() {
    echo "jq tree"
}

get_essential_casks() {
    echo "alacritty discord logi-options+"
}

get_development_casks() {
    echo "zed font-im-writing-nerd-font font-ia-writer-mono font-ia-writer-duo font-ia-writer-quattro orbstack"
}

get_productivity_casks() {
    echo "slack obsidian rectangle zotero skim zoom"
}

get_essential_mas_apps() {
    echo "937984704"  # Amphetamine
}

get_development_mas_apps() {
    echo "497799835"   # Xcode
}

get_productivity_mas_apps() {
    echo "975937182"  # Fantastical
}

# Configure macOS system defaults
configure_system_defaults() {
    print_info "Configuring macOS system defaults..."

    # LaunchServices - Disable quarantine
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # NSGlobalDomain settings
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Dock settings
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock show-recents -bool false
    defaults write com.apple.dock launchanim -bool true
    defaults write com.apple.dock mouse-over-hilite-stack -bool true
    defaults write com.apple.dock orientation -string "bottom"
    defaults write com.apple.dock tilesize -int 48

    # Finder settings
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
    defaults write com.apple.finder AppleShowAllExtensions -bool true
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    defaults write com.apple.finder QuitMenuItem -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder ShowStatusBar -bool true

    # Configure sudo Touch ID authentication (disable)
    local pam_sudo_local="/etc/pam.d/sudo_local"
    if [[ -f "$pam_sudo_local" ]]; then
        print_info "Removing sudo Touch ID authentication..."
        sudo rm -f "$pam_sudo_local"
    fi

    print_info "System defaults configured. Some changes may require a restart to take effect."
}
