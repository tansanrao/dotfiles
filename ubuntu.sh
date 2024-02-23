#!/bin/bash

# Ensure running on Ubuntu 22.04
if [[ $(lsb_release -rs) != "22.04" ]]; then
    echo "This script is intended for Ubuntu 22.04 only."
    exit 1
fi

# Check and cache sudo credentials upfront
check_and_cache_sudo() {
    # Attempt to run a non-destructive command with sudo without a password prompt
    if sudo -n true 2>/dev/null; then
        echo "No password is required for sudo or it's already cached."
    else
        echo "Password is required for sudo, invoking sudo to cache credentials..."
        # The -v option updates the user's timestamp without running a command
        if sudo -v; then
            echo "Sudo credentials are now cached."
        else
            echo "Failed to cache sudo credentials."
            return 1
        fi
    fi
    return 0
}

check_and_cache_sudo
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Function to install dependencies using apt
install_apt_dependencies() {
    echo "Updating package lists..."
    sudo apt-get update

    echo "Installing required packages..."
    sudo apt-get install -y vim tmux curl wget htop

    echo "All packages installed successfully."
}

# Function to write script to keep ssh authorized keys in sync with github
create_update_ssh_keys_script() {
    cat > ~/update_ssh_keys.sh << EOF
#!/bin/bash

# Fetch GitHub keys for tansanrao and update authorized_keys
mkdir -p ~/.ssh
chmod 700 ~/.ssh
curl https://github.com/tansanrao.keys -o ~/.ssh/github_keys_temp
if [ -s ~/.ssh/github_keys_temp ]; then
    mv ~/.ssh/github_keys_temp ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
else
    echo "Failed to fetch GitHub keys or the file is empty. Keeping the existing authorized_keys."
fi
EOF

    chmod +x ~/update_ssh_keys.sh
    echo "SSH keys update script created."
}

# Function to add cron job to run update script
setup_cron_job() {
    # Add a cron job to update SSH keys daily
    (crontab -l 2>/dev/null; echo "@daily $HOME/update_ssh_keys.sh") | crontab -
    echo "Cron job set up to update SSH keys daily."
}



# Function to backup and remove existing file/directory
backup_and_remove() {
    local target=$1
    if [ -f "$target" ] || [ -d "$target" ]; then
        echo "Backing up and removing $target"
        mkdir -p ~/.backup
        mv "$target" ~/.backup/
    fi
}

# Call the function to install apt dependencies
install_apt_dependencies

# Backing up existing tmux files
backup_and_remove ~/.tmux
backup_and_remove ~/.tmux.conf

# Symlinking tmux.conf from dotfiles
ln -s ~/.config/dotfiles/tmux/tmux.conf ~/.tmux.conf
echo "Symlinked tmux.conf to ~/.tmux.conf"

# Backing up existing .vimrc
backup_and_remove ~/.vimrc

# Symlinking .vimrc from dotfiles
ln -s ~/.config/dotfiles/vim/vimrc ~/.vimrc
echo "Symlinked vimrc to ~/.vimrc"

# Backing up existing .bash_aliases
backup_and_remove ~/.bash_aliases

# Symlinking .bash_aliases from dotfiles
ln -s ~/.config/dotfiles/bash_aliases ~/.bash_aliases
echo "Symlinked bash_aliases to ~/.bash_aliases"

# Source .bash_aliases into current shell
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
    echo "Sourced bash_aliases into current shell"
fi

# Prompt the user to set up SSH key synchronization
echo "Do you want to set up SSH key synchronization? [Y/n]: "
read -r response
if [[ -z "$response" ]] || [[ "$response" =~ ^[Yy]$ ]]; then
    create_update_ssh_keys_script
    setup_cron_job
else
    echo "Skipping SSH key synchronization setup."
fi


echo "Ubuntu setup completed."

