#!/usr/bin/env bash
# Main dotfiles installation script
# Detects hostname and runs host-specific setup

set -euo pipefail

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Main installation function
main() {
    # Detect hostname and strip domain portion
    local hostname=$(hostname | cut -d'.' -f1)
    
    # Check if we have a host-specific setup script
    local host_script="$DOTFILES_DIR/hosts/$hostname/setup.sh"
    
    if [[ -f "$host_script" ]]; then
        # Make sure the script is executable
        chmod +x "$host_script"
        
        # Run the host-specific setup script
        bash "$host_script"
        
    else
        echo "ERROR: No host-specific setup found for hostname: $hostname"
        echo "Available host configurations:"
        
        # List available host configurations
        if [[ -d "$DOTFILES_DIR/hosts" ]]; then
            for host_dir in "$DOTFILES_DIR/hosts"/*; do
                if [[ -d "$host_dir" ]]; then
                    host_name=$(basename "$host_dir")
                    echo "  - $host_name"
                fi
            done
        fi
        
        echo
        echo "To set up this machine:"
        echo "  1. Create a host configuration in hosts/$hostname/setup.sh"
        echo "  2. Run one of the existing host setups manually:"
        echo "     bash hosts/[hostname]/setup.sh"
        
        exit 1
    fi
}

# Run main function
main "$@"
