#!/bin/bash

# Function to install Git on Ubuntu
install_git_ubuntu() {
    sudo apt-get update
    sudo apt-get install -y git
}

# Function to check for Git and install Git on macOS through Xcode Command Line Tools if necessary
install_git_macos() {
    if ! type git > /dev/null 2>&1; then
        echo "Git not found. Installing Xcode Command Line Tools..."
        xcode-select --install
        
        # Wait until Xcode Command Line Tools installation is finished
        until xcode-select --print-path &>/dev/null; do
            sleep 5
        done

        # Accept the Xcode Command Line Tools license
        sudo xcodebuild -license accept
    else
        echo "Git is already installed."
    fi
}

# Function to clone dotfiles and execute respective scripts
setup_dotfiles() {
    git clone https://github.com/tansanrao/dotfiles.git ~/.config/dotfiles
    cd ~/.config/dotfiles

    if [ "$1" = "Ubuntu" ]; then
        bash ubuntu.sh
    elif [ "$1" = "macOS" ]; then
        zsh macos.sh
    fi
}

# Detecting OS
OS="Unknown"
case "$(uname -s)" in
    Darwin)
        OS="macOS"
        ;;
    Linux)
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            if [ "$NAME" = "Ubuntu" ]; then
                OS="Ubuntu"
            fi
        fi
        ;;
esac

# Installing Git and setting up dotfiles based on detected OS
case "$OS" in
    "Ubuntu")
        install_git_ubuntu
        setup_dotfiles "Ubuntu"
        ;;
    "macOS")
        install_git_macos
        setup_dotfiles "macOS"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "Setup completed on $OS."

