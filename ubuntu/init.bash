#!/bin/bash

# Function to prompt for sudo and keep it alive
keep_sudo_alive() {
  while true; do
    sudo -v
    sleep 50
    kill -0 "$$" || exit
  done &
}

# Prompt for sudo access initially
sudo -v

# Start the background process to keep sudo alive
keep_sudo_alive

# Update packages
sudo apt-get update
sudo apt-get upgrade -y

# Install dev environment dependencies
sudo apt-get install --fix-missing -y zsh build-essential vim tmux curl clang \
	clangd bear clang-format lld llvm ccache cmake strace bpftrace gdb \
	xz-utils

# Install QEMU stuff
sudo apt-get install --fix-missing -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon attr

# Cleanup
sudo apt-get dist-clean

# Set default shell to zsh
sudo chsh -s $(which zsh) $SUDO_USER

# Verify change
if [ $? -eq 0 ]; then
  echo "The default shell has been changed to zsh."
  echo "Please log out and log back in for the change to take effect."
else
  echo "Failed to change the default shell."
fi

# Setup zsh
zsh -c zsh/init.zsh
