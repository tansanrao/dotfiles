# For when tmux attach causes problems with old agent in envvars
fixssh() {
  eval $(tmux show-env -s |grep '^SSH_')
}

# remove from known_hosts helper for when VMs are torn down and rebuilt regularly
rm_keys() {
  ssh-keygen -f "/home/tansanrao/.ssh/known_hosts" -R $1
}

ssh-jump() {
  # Help message
  if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: ssh-jump <username>@<host> <jumphost>"
    echo "or:    ssh-jump <host> <jumphost>"
    return 1
  fi

  # Grab hosts from arguments
  host=$1
  jump_host=$2

  # Execute ssh command
  ssh -A -J $jump_host $host
}
