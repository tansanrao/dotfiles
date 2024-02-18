# For when tmux attach causes problems with old agent in envvars
fixssh() {
  eval $(tmux show-env -s |grep '^SSH_')
}

# remove from known_hosts helper for when VMs are torn down and rebuilt regularly
rm_keys() {
  ssh-keygen -f "/home/tansanrao/.ssh/known_hosts" -R $1
}
