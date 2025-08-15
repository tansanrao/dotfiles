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

# Default package lists - override in host-specific scripts
get_brew_packages() {
    # Essential tools + Development tools + Utilities
    echo "curl wget git stow neovim tmux zsh ripgrep fd fzf bat htop mise zoxide texlive jq tree"
}

get_brew_casks() {
    # Essential casks + Development casks + Productivity casks
    echo "alacritty discord logi-options+ zed font-im-writing-nerd-font font-ia-writer-mono font-ia-writer-duo font-ia-writer-quattro orbstack slack obsidian rectangle zotero skim zoom"
}

get_mas_apps() {
    # Mac App Store apps with comments
    echo "937984704"  # Amphetamine
    echo "497799835"  # Xcode
    echo "975937182"  # Fantastical
}

# Declarative package management functions

# Get currently installed brew packages (excluding dependencies)
get_installed_brew_packages() {
    brew leaves 2>/dev/null | tr '\n' ' '
}

# Get currently installed brew casks
get_installed_brew_casks() {
    brew list --cask 2>/dev/null | tr '\n' ' '
}

# Get currently installed MAS apps (IDs only)
get_installed_mas_apps() {
    if command -v mas &> /dev/null; then
        mas list 2>/dev/null | awk '{print $1}' | tr '\n' ' '
    fi
}

# Remove brew packages not in the desired list
remove_unlisted_brew_packages() {
    local desired=("$@")
    local installed=($(get_installed_brew_packages))
    
    # Create associative array for desired packages
    declare -A desired_map
    for pkg in "${desired[@]}"; do
        desired_map["$pkg"]=1
    done
    
    # Find and remove packages not in desired list
    for pkg in "${installed[@]}"; do
        if [[ -z "${desired_map[$pkg]}" ]]; then
            print_info "Removing unlisted brew package: $pkg"
            brew uninstall --force "$pkg" 2>/dev/null || true
        fi
    done
}

# Remove brew casks not in the desired list
remove_unlisted_brew_casks() {
    local desired=("$@")
    local installed=($(get_installed_brew_casks))
    
    # Create associative array for desired casks
    declare -A desired_map
    for cask in "${desired[@]}"; do
        desired_map["$cask"]=1
    done
    
    # Find and remove casks not in desired list
    for cask in "${installed[@]}"; do
        if [[ -z "${desired_map[$cask]}" ]]; then
            print_info "Removing unlisted brew cask: $cask"
            brew uninstall --cask --force "$cask" 2>/dev/null || true
        fi
    done
}

# Remove MAS apps not in the desired list
remove_unlisted_mas_apps() {
    local desired=("$@")
    local installed=($(get_installed_mas_apps))
    
    # Create associative array for desired apps
    declare -A desired_map
    for app_id in "${desired[@]}"; do
        desired_map["$app_id"]=1
    done
    
    # Find apps not in desired list (MAS doesn't support uninstall via CLI)
    local unlisted=()
    for app_id in "${installed[@]}"; do
        if [[ -z "${desired_map[$app_id]}" ]]; then
            unlisted+=("$app_id")
        fi
    done
    
    if [[ ${#unlisted[@]} -gt 0 ]]; then
        print_warning "The following MAS apps are not in your desired list but cannot be removed via CLI:"
        for app_id in "${unlisted[@]}"; do
            local app_name=$(mas list | grep "^$app_id" | cut -d' ' -f2-)
            echo "  - $app_name (ID: $app_id)"
        done
        echo "Please remove them manually via Launchpad or Finder if desired."
    fi
}

# Declarative setup - ensures only specified packages are installed
setup_brew_declaratively() {
    local packages=("$@")
    
    print_info "Setting up Homebrew packages declaratively..."
    
    # Install desired packages
    install_brew_packages "${packages[@]}"
    
    # Remove unlisted packages (unless SKIP_REMOVAL is set)
    if [[ -z "${SKIP_REMOVAL:-}" ]]; then
        remove_unlisted_brew_packages "${packages[@]}"
        # Clean up
        brew autoremove 2>/dev/null || true
    else
        print_warning "Skipping removal of unlisted packages (SKIP_REMOVAL is set)"
    fi
}

# Declarative setup for casks
setup_casks_declaratively() {
    local casks=("$@")
    
    print_info "Setting up Homebrew casks declaratively..."
    
    # Install desired casks
    install_brew_casks "${casks[@]}"
    
    # Remove unlisted casks (unless SKIP_REMOVAL is set)
    if [[ -z "${SKIP_REMOVAL:-}" ]]; then
        remove_unlisted_brew_casks "${casks[@]}"
    else
        print_warning "Skipping removal of unlisted casks (SKIP_REMOVAL is set)"
    fi
}

# Declarative setup for MAS apps
setup_mas_declaratively() {
    local apps=("$@")
    
    print_info "Setting up Mac App Store apps declaratively..."
    
    # Install desired apps
    install_mas_apps "${apps[@]}"
    
    # Check for unlisted apps (cannot remove programmatically)
    if [[ -z "${SKIP_REMOVAL:-}" ]]; then
        remove_unlisted_mas_apps "${apps[@]}"
    else
        print_warning "Skipping check for unlisted MAS apps (SKIP_REMOVAL is set)"
    fi
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
