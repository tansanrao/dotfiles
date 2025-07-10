#!/usr/bin/env bash
# Configure macOS Dock - replaces dock.nix functionality

set -euo pipefail

echo "🔧 Configuring macOS Dock..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if dockutil is installed
if ! command -v dockutil &> /dev/null; then
    print_warning "dockutil not found. Please install it first: brew install dockutil"
    exit 1
fi

print_status "Removing all current dock items..."
dockutil --remove all --no-restart

print_status "Adding applications to dock..."

# Add applications to dock (matching the original dock.nix configuration)
apps=(
    "/Applications/Slack.app"
    "/System/Applications/Messages.app"
    "/System/Applications/FaceTime.app"
    "/Applications/Fantastical - Calendar & Tasks.app"
    "/Applications/Alacritty.app"
    "/System/Applications/Music.app"
    "/Applications/Notes.app"
    "/System/Applications/Mail.app"
    "/Applications/Safari.app"
)

for app in "${apps[@]}"; do
    if [[ -e "$app" ]]; then
        print_status "Adding $app"
        dockutil --add "$app" --no-restart
    else
        print_warning "Application not found: $app"
    fi
done

# Add Downloads folder to dock
print_status "Adding Downloads folder to dock..."
downloads_path="$HOME/Downloads"
if [[ -d "$downloads_path" ]]; then
    dockutil --add "$downloads_path" --view grid --display stack --sort name --section others --no-restart
else
    print_warning "Downloads folder not found: $downloads_path"
fi

print_status "Restarting Dock to apply changes..."
killall Dock

print_status "Dock configuration completed! 🎉" 